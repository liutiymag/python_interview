import os
import re
import json
import base64
import pprint
import urllib3
import argparse
import requests
import xml.etree.ElementTree as et

from datetime import datetime, timedelta


urllib3.disable_warnings()


def get_results_from_robot_xml(xml_file, default_config_name):
    try:
        xml = et.parse(xml_file).getroot()
    except Exception:
        try:
            # XML preprocessing
            with open(xml_file, encoding='utf-8') as f:
                xml_str = f.read()
            scrubbedXML = re.sub('&.+[0-9]+;', '', xml_str)
            xml = et.fromstring(scrubbedXML)
        except Exception as ex:
            print('Got exception while parsing xml!\n File {} is skipped.\n Exception: {}'.
                  format(xml_file, ex))
            return {}

    # XML parsing
    results_dict = {}
    try:
        for case in xml.iter('test'):
            status_elem = case.find('status')
            error = status_elem.text
            status = status_elem.get('status')
            start_date = status_elem.get('starttime')
            end_date = status_elem.get('endtime')
            name = case.get('name')
            case_id = ''
            for case_tag in case.findall('tag'):
                if case_tag.text.startswith('TC'):
                    case_id = case_tag.text.split('TC')[-1]
                    results_dict.setdefault(case_id, [])
                    break
            if not case_id:
                print(f'Case ID not found for test: {name}')
                continue
            results_dict[case_id].append({'id': case_id,
                                          'configuration_name': default_config_name,
                                          'status': status,
                                          'error': error,
                                          'start_date': start_date,
                                          'end_date': end_date})
        return results_dict
    except Exception as ex:
        print('Got exception while reading testcases list!\n Report is skipped.\n Exception: {}'
              .format(ex))
        return {}


def get_results_from_browserstack_json(json_file):
    results_dict = {}
    with open(json_file, 'r') as f:
        results_data = json.load(f)
        for result in results_data:
            try:
                configuration_name = f"{result['automation_session']['os']} - {result['automation_session']['browser']}"
                case_id = re.match(r"TC(\d+)", result['automation_session']["name"]).group(1)
                results_dict.setdefault(case_id, [])

                if result['automation_session']["status"] == "passed":
                    status = "PASS"
                elif result['automation_session']["status"] == "failed":
                    status = "FAIL"
                else:
                    status = "SKIP"
                error = result['automation_session']["reason"].replace("CLIENT_STOPPED_SESSION", "")

                dt_start = datetime.strptime(result['automation_session']["created_at"], "%Y-%m-%dT%H:%M:%S.%fZ")
                dt_end = dt_start + timedelta(seconds=result['automation_session']["duration"])
                start_date = dt_start.strftime("%Y%m%d %H:%M:%S.%f")[:-3]
                end_date = dt_end.strftime("%Y%m%d %H:%M:%S.%f")[:-3]

                results_dict[case_id].append({'id': case_id,
                                              'configuration_name': configuration_name,
                                              'status': status,
                                              'error': error,
                                              'start_date': start_date,
                                              'end_date': end_date})
            except Exception as ex:
                print('Got exception while reading browserstack json!\n Test is skipped.\n Exception: {}'
                      .format(ex))
        return results_dict


class AzureAPI:
    def __init__(self, test_plan_id: str, attachment_path: str):
        self.azure_base_url = 'https://dev.azure.com/AHITL/SECRET_PROJECT/_apis'
        self.azure_token = os.getenv('SECRET_PROJECT_AUTOMATION_AZURE_API_TOKEN')
        self.auth_tuple = ('', self.azure_token)
        self.test_plan_id = test_plan_id
        self.attachment_path = attachment_path

    def get_default_configuration_name(self):
        get_configs_url = f'{self.azure_base_url}/test/configurations?api-version=5.0-preview.2'
        gonfigs_response = requests.get(get_configs_url, auth=self.auth_tuple, verify=False)
        gonfigs_json = gonfigs_response.json()
        for config in gonfigs_json['value']:
            if config.get('isDefault', ''):
                return config['name']
        raise Exception('No default configuration found')

    def get_plan_name(self):
        get_plan_url = f'{self.azure_base_url}/testplan/plans/{self.test_plan_id}?api-version=7.2-preview.1'
        plan_response = requests.get(get_plan_url, auth=self.auth_tuple, verify=False)
        plan_json = plan_response.json()
        return plan_json['name']

    def get_suites_by_plan_id(self):
        suites_url = f'{self.azure_base_url}/testplan/plans/{self.test_plan_id}/suites?api-version=7.2-preview.1'
        suites_response = requests.get(suites_url, auth=self.auth_tuple, verify=False)
        suites_json = suites_response.json()
        return suites_json

    def get_test_points_from_suite(self, suite_id):
        suite_url = f'{self.azure_base_url}/test/plans/{self.test_plan_id}/suites/{suite_id}/points?api-version=7.2-preview.2'
        points_response = requests.get(suite_url, auth=self.auth_tuple, verify=False)
        points_json = points_response.json()
        return points_json

    def get_case_related_bugs(self, case_id: str):
        bug_ids = set()
        workitems_url = f'{self.azure_base_url}/wit/workitems/{case_id}'
        # Get test case relations
        params = {'api-version': '7.1-preview.3',
                  '$expand': 'relations'}
        workitems_response = requests.get(workitems_url, params=params, auth=self.auth_tuple, verify=False)
        if workitems_response.status_code != 200:
            raise Exception(f'Cannot get test case relations: {workitems_response.text}')
        workitem = workitems_response.json()
        for relation in workitem.get('relations', []):
            relation_id = relation['url'].split('/')[-1]
            relation_url = f'{self.azure_base_url}/wit/workitems/{relation_id}'
            relation_params = {'api-version': '7.1-preview.3',
                               'fields': 'System.WorkItemType,System.State'}
            relation_response = requests.get(relation_url, params=relation_params, auth=self.auth_tuple, verify=False)
            if relation_response.status_code == 200:
                item_info = relation_response.json()
                if item_info['fields']['System.State'] not in ['Resolved', 'Rejected', 'Closed'] and \
                        item_info['fields']['System.WorkItemType'] == 'Bug':
                    bug_ids.add(relation_id)
        return bug_ids

    def create_test_run(self, test_results: dict):
        # Get test suites
        suites = self.get_suites_by_plan_id()

        # Get test points
        test_points = {}
        for suite in suites['value']:
            print(f'Getting test points from suite: {suite["name"]}')
            suite_points = self.get_test_points_from_suite(suite['id'])
            for point in suite_points['value']:
                case_id = point['testCase']['id']
                if case_id in list(test_results.keys()):
                    for result in test_results[case_id]:
                        if point['configuration']['name'].lower() == result['configuration_name'].lower():
                            print(f'Found Case ID {case_id} - test point ID {point["id"]} - configuration ID {point["configuration"]["id"]}')
                            test_points[point['id']] = {'case_url': point['testCase']['webUrl'],
                                                        'status': result['status'],
                                                        'error': result['error'],
                                                        'start_date': result['start_date'],
                                                        'end_date': result['end_date']
                                                        }
        if len(test_points) == 0:
            print('No test points found for test results')
            return
        print(f'Found {len(test_points)} test points')

        # Create test run
        build_id = os.getenv('BUILD_BUILDID')
        plan_name = self.get_plan_name()
        run_name = f'{plan_name} Run: {str(datetime.now().strftime("%d-%m-%Y %H:%M:%S"))}'
        run_create_url = f'{self.azure_base_url}/test/runs?api-version=7.2-preview.3'
        payload = {'name': run_name,
                   'automated': True,
                   'build': {'id': build_id},
                   'plan': {'id': self.test_plan_id},
                   'pointIds': list(test_points.keys())}
        run_create_response = requests.post(run_create_url, json=payload, auth=self.auth_tuple,
                                            headers={'Content-Type': 'application/json'}, verify=False)
        if run_create_response.status_code != 200:
            raise Exception(f'Cannot create test run: {run_create_response.text}')
        created_run = run_create_response.json()
        print('*' * 90)
        print('Test Run created')
        pprint.pprint(created_run)

        # Get test results
        results_url = f'{self.azure_base_url}/test/runs/{created_run["id"]}/results?api-version=7.2-preview.6'
        get_results_response = requests.get(results_url, auth=self.auth_tuple, verify=False)
        results = get_results_response.json()['value']
        # Update test results
        for test_result in results:
            testpoint_id = int(test_result['testPoint']['id'])
            test_result['state'] = 'Completed'

            started_date_object = datetime.strptime(test_points[testpoint_id]['start_date'],
                                                    '%Y%m%d %H:%M:%S.%f')
            test_result['startedDate'] = started_date_object.strftime('%Y-%m-%dT%H:%M:%S.%fZ')

            completed_date_object = datetime.strptime(test_points[testpoint_id]['end_date'],
                                                      '%Y%m%d %H:%M:%S.%f')
            test_result['completedDate'] = completed_date_object.strftime('%Y-%m-%dT%H:%M:%S.%fZ')

            # Add Test Case link into Comment tab of pipeline results page
            tc_url = test_points[testpoint_id]['case_url']
            test_result['comment'] = f"<a href=\"{tc_url}\" target=\"_blank\">Test Case URL: <u>{tc_url}</u></a>"

            if test_points[testpoint_id]['status'] == 'PASS':
                test_result['outcome'] = 'Passed'
            elif test_points[testpoint_id]['status'] == 'SKIP':
                test_result['outcome'] = 'Paused'
                test_result['comment'] += '\n' + test_points[testpoint_id]['error']
            else:
                test_result['outcome'] = 'Failed'
                test_result['errorMessage'] = test_points[testpoint_id]['error']
                # Add active associated bugs
                active_bugs_ids = self.get_case_related_bugs(test_result['testCase']['id'])
                test_result['associatedBugs'] = [{'id': bug_id} for bug_id in active_bugs_ids]

        results_update_response = requests.patch(results_url, json=results, auth=self.auth_tuple,
                                                 headers={'Content-Type': 'application/json'}, verify=False)
        if results_update_response.status_code != 200:
            raise Exception(f'Cannot update test run results: {results_update_response.text}')
        update_response_json = results_update_response.json()
        print('*' * 90)
        print('Test Results updated')
        pprint.pprint(update_response_json)        

        # Get build duration
        build_url = f'{self.azure_base_url}/build/builds/{build_id}?api-version=7.1-preview.7'
        build_response = requests.get(build_url, auth=self.auth_tuple, verify=False)
        build_start_time = build_response.json()['startTime']

        # Update Test Run state and duration
        run_update_url = f'{self.azure_base_url}/test/runs/{created_run["id"]}?api-version=7.2-preview.3'
        payload = {'state': 'Completed',
                   'startedDate': build_start_time}
        run_update_response = requests.patch(run_update_url, json=payload, auth=self.auth_tuple,
                                             headers={'Content-Type': 'application/json'}, verify=False)
        if run_update_response.status_code != 200:
            raise Exception(f'Cannot update test run state: {run_update_response.text}')
        print('*' * 90)
        print('Test Run state updated')

        # Create Test Run attachment
        if self.attachment_path:
            try:
                with open(os.path.normpath(self.attachment_path), 'rb') as f:
                    encoded_str = str(base64.b64encode(f.read()), 'utf-8')
                create_attachment_url = f'{self.azure_base_url}/test/runs/{created_run["id"]}/attachments?api-version=7.2-preview.1'
                file_name = os.path.basename(self.attachment_path)
                payload = {'stream': encoded_str,
                        'fileName': file_name}
                create_attachment_response = requests.post(create_attachment_url, json=payload, auth=self.auth_tuple,
                                                        headers={'Content-Type': 'application/json'}, verify=False)
                if create_attachment_response.status_code != 200:
                    raise Exception(f'Cannot create test run attachment: {create_attachment_response.text}')
                print('*' * 90)
                print('Test Run attachment created')
            except Exception as ex:
                print('Got exception while creating attachment.\n Exception: {}'
                      .format(ex))                


def main():
    parser = argparse.ArgumentParser(prog='Push test results to Azure')
    parser.add_argument('--report_file', help='Test report file path. BrowserStack json or robot output.xml', required=True)
    parser.add_argument('--attachment', help='The path of attachment for test run', default=None)
    parser.add_argument('--test_plan_id', help='Azure test plan ID', required=True)
    parser.add_argument('--report_type', help='Kind of report type.', choices=['robot_xml', 'browserstack_json'], default='robot_xml')
    args, _ = parser.parse_known_args()
    args_dict = vars(args)

    azure_conn = AzureAPI(args_dict['test_plan_id'], args_dict['attachment'])

    # Get results from report file
    if args_dict['report_type'] == 'robot_xml':
        default_config_name = azure_conn.get_default_configuration_name()
        test_results = get_results_from_robot_xml(os.path.normpath(args_dict['report_file']), default_config_name)
    elif args_dict['report_type'] == 'browserstack_json':
        test_results = get_results_from_browserstack_json(os.path.normpath(args_dict['report_file']))
    else:
        raise ValueError('Invalid report type. Use either robot_xml or browserstack_json.')

    # Get info from Azure
    azure_conn.create_test_run(test_results)


if __name__ == '__main__':
    main()
