# -*- coding: utf-8 -*-
import os
import re
import time
import json
import shutil
import string
import random

from http import HTTPStatus
from urllib.parse import unquote

from kubernetes import client as k8s_client
from kubernetes import config as k8s_config
from packages.assert_messages import Assert_msg
from packages.exceptions import ResponseStatusException
from packages.flows.<ssecret_company>_api_utils import <ssecret_company>APIUtils
from packages.mongodb import MongoDB
from packages.<ssecret_company>_api import <ssecret_company>API
from packages.<ssecret_company>_config import Config


class Utils:

    def __init__(self, api_version):

        self.api_version = api_version
        self.config = Config()
        self.<ssecret_company>_conn = <ssecret_company>API(self.config.<ssecret_company>_base_url)
        self.token = self.<ssecret_company>_conn.login(self.config.email, self.config.password)
        self.api_util = <ssecret_company>APIUtils(self.<ssecret_company>_conn, self.token)
        self.postman_collection = os.path.join(os.path.dirname(os.path.dirname(
            os.path.dirname(os.path.abspath(__file__)))), '<ssecret_company> REST API.postman_collection.json')
        self.assets_path = None

        # Linux platform function

    @staticmethod
    def id_generator(length=10):
        # characters to generate id from
        characters = list(string.ascii_letters + string.digits)
        # shuffling the characters
        random.shuffle(characters)
        # picking random characters from the list
        password = []
        for i in range(length):
            password.append(random.choice(characters))
        # shuffling the resultant id
        random.shuffle(password)
        # converting the list to string
        return "".join(password)

    @staticmethod
    def execute_cmd(cmd):
        try:
            print('Execute ' + cmd)
            result = os.system(cmd)
            if result != 0:
                return None
            return True
        except Exception as ex:
            print('Error -> {0}'.format(ex))
            raise

    def get_api_version_section(self):
        '''
        :return: dictionary of api version 0.9/1.0/2.0
        '''
        with open(self.postman_collection, encoding='utf-8') as apis:
            all_apis = json.load(apis)
        return self.slice_collection_by_name(all_apis, self.api_version)

    def mongodb_restore(self, collection=None):
        mongodb_restore = MongoDB()

        tar_name = os.path.basename(self.config.mongodb_path)
        source_dir = os.path.join(self.config.working_dir, tar_name.split('.')[0])
        # Delete old .tar file
        tar_path = os.path.join(self.config.working_dir, tar_name)
        if os.path.exists(tar_path):
            self.execute_cmd('rm -rf {0}'.format(tar_path))
        # Download .tar with mongo dump
        result = self.execute_cmd('wget -P {0} {1}'.format(self.config.working_dir, self.config.mongodb_path))
        if result is None:
            raise RuntimeError('Command failed')
        # Delete folder with old unpacked mongo dump
        if os.path.exists(source_dir):
            self.execute_cmd('rm -rf {0}'.format(source_dir))
        # Unpack .tar file
        result = self.execute_cmd(
            'tar xf {0} -C {1}'.format(os.path.join(self.config.working_dir, tar_name), self.config.working_dir))
        if result is None:
            raise RuntimeError('Command failed')
        # Restore mongoDB
        try:
            if collection is not None:
                mongodb_restore.restore_specific_collection(collection, source_dir, 'mongo_dump')
            else:
                mongodb_restore.linux_mongodb_restore(source_dir, 'mongo_dump')
        except Exception as ex:
            print('Mongo Restore Failure\n')
            raise
        return

    def set_up_test(self, test_suite_and_id, api_version_dict):
        '''
        :param test_suite_and_id:
        :param api_version_dict: 0.9/1.0/2.0
        :return: method, url_suffix, header, body, params
        '''
        folders = [section for section in test_suite_and_id[1:] if re.search(r"C[0-9]+", section) is None]
        folder = "_".join(folders)
        # folder = test_suite_and_id[1]
        id = test_suite_and_id[-1]
        self.id = "test_" + id
        folder_dict = self.slice_collection_by_name(api_version_dict, folder)
        test_dict = self.slice_collection_by_name(folder_dict, id, 'request')
        method = test_dict['request']['method']
        header = test_dict['request']['header']
        if ('body' in test_dict['request']) and ('raw' in test_dict['request']['body']):
            body = self.clean_body_json(test_dict['request']['body']['raw'])
        else:
            body = ''
        if 'variable' in test_dict['request']['url']:
            url_suffix = self.generate_url_suffix(test_dict['request']['url']['path'],
                                                  test_dict['request']['url']['variable'])
        else:
            url_suffix = self.generate_url_suffix(test_dict['request']['url']['path'])
        if 'query' in test_dict['request']['url']:
            all_params_dict = {unquote(d['key']): unquote(d['value']) for d in test_dict['request']['url']['query']}
            params = all_params_dict
        else:
            params = ''
        return method, url_suffix, header, body, params

    def generate_url_suffix(self, url_path, url_variables_list=None):
        if url_variables_list != None:
            variable_dict = dict()
            for i in url_variables_list:
                variable_dict[i['key']] = i['value']
            for item in range(0, len(url_path)):
                if url_path[item].startswith(":"):
                    url_path[item] = variable_dict[url_path[item][1:]]
        url_suffix = '/' + "/".join(str(x) for x in url_path)
        return url_suffix

    def slice_collection_by_name(self, collection, name, type=None):
        name = name.replace('_', ' ')
        name = name.split(" ")
        for i in collection['item']:
            if type == 'request':
                if name[0] in i['request']['description']:
                    return i
            else:
                correct = True
                for part in name:
                    if part not in i["name"]:
                        correct = False

                if correct:
                    return i

    def clean_body_json(self, body):
        if body == '':
            return body
        body = body.replace('\r\n  ', '')
        body = body.replace('\r\n', '')
        body = body.replace('\t', '')
        body = body.replace('\n', '')
        body = body.replace('\\', '')
        return json.loads(body)

    def check_response(self, tested_object, method=None, url_suffix=None, params=None,
                       body=None, header=None, expected_response=None, pre_test_id=None,
                       file_upload=False, file_name=None, token=None):
        if method is None:
            method = tested_object.method
        if url_suffix is None:
            url_suffix = tested_object.url_suffix
        if params is None:
            params = tested_object.params
        if body is None:
            body = tested_object.body
        if header is None:
            header = tested_object.header
        if expected_response is None:
            expected_response = 200
        if pre_test_id is not None:
            pre_test_id = pre_test_id.split('C')[-1]

        print("\n{0} {1} url_suffix {2}".format(method, tested_object, url_suffix))
        <ssecret_company>_conn = <ssecret_company>API(self.config.<ssecret_company>_base_url)
        if token is None:
            token = <ssecret_company>_conn.login(self.config.email, self.config.password)
        res = <ssecret_company>_conn.call_api(http_method=method, url_suffix=url_suffix,
                                    params=params, payload=body, token=token, print_request=True,
                                    file_upload=file_upload, file_name=file_name)
        testrail_id = tested_object._testMethodName.split('_C')[-1]
        assert_msg = Assert_msg(testrail_id, res.status_code, expected_response, '')
        msg = 'Response: {0}\nURL SUFFIX: {1}\nRequest URL: {4}\nMethod: {2}\nRequest body: {3}'.format(
            res.text, url_suffix, method, body, res.url)
        if (pre_test_id is not None) and (pre_test_id != testrail_id):
            msg += '\nPrerequisite test failed: {}{}'.format(assert_msg.testrail_baseurl, pre_test_id)
        assert_msg.msg = msg
        print(res.text.encode("utf-8"))
        tested_object.assertEqual(expected_response, res.status_code, assert_msg)
        if "datamodel-exports/stream" in url_suffix: return res
        return res.text

    def call_api_method(self, method, url_suffix, params=None, body=None, auth=False):
        <ssecret_company>_conn = <ssecret_company>API(self.config.<ssecret_company>_base_url)
        token = None
        if auth:
            token = <ssecret_company>_conn.login(self.config.email, self.config.password)
        response = <ssecret_company>_conn.call_api(http_method=method, url_suffix=url_suffix,
                                         params=params, payload=body, token=token, print_request=True)
        return response

    def load_elasticube(self, cube_name):
        <ssecret_company>_conn = <ssecret_company>API(self.config.<ssecret_company>_base_url)
        token = <ssecret_company>_conn.login(self.config.email, self.config.password)
        result = <ssecret_company>_conn.load_elasticube(token, cube_name)
        return result.json()['data']['elasticubeByTitle']['oid']

    def restore_cube(self, cube_name: str, is_live: bool = False):
        cube_f_name = list(filter(lambda x: x.startswith(cube_name), os.listdir(self.assets_path)))[0]
        full_path = os.path.join(self.assets_path, cube_f_name)
        print(f"Importing Cube: {cube_name}")
        oid = self.api_util.elasticube_import_smodel(full_path, cube_name, overwrite=True)
        print(f"{cube_name}:{oid}\n")
        if is_live:
            print(f"Publishing: {cube_name}")
            res = self.<ssecret_company>_conn.publish_live_elasticube(oid, self.token)
            print(f"Published: {res.ok}")

    def publish_sample_dashboard(self, dashboard_name, dashboard_json_path):
        url_suffix = "/api/v1/dashboards"
        with open(dashboard_json_path, 'r+') as fp:
            dashboard_body = json.load(fp)

        dashboard_body['title'] = dashboard_name
        try:
            response = self.<ssecret_company>_conn.call_api("POST", url_suffix=url_suffix, payload=dashboard_body,
                                                  token=self.token)
            return response.json()['oid']
        except (TypeError, KeyError):
            print("Couldn't publish dashboard")

    def get_datamodelId_by_name(self, datamodelName):
        response = self.<ssecret_company>_conn.get_elasticubes(token=self.token).json()
        datamodelID = None
        for model in response:
            if model['title'] == datamodelName:
                datamodelID = model['oid']
                break
        return datamodelID

    def start_build(self, datamodelId):
        response = self.<ssecret_company>_conn.build_elasticube(self.token, datamodelId, "full", 0).json()['data'][
            'buildElasticube']
        return response

    def get_build_status(self, buildId):
        url_suffix = '/api/v2/builds/' + buildId
        try:
            status = self.<ssecret_company>_conn.get_build_status_by_id(buildId, self.token).json()['status']
        except:
            print: "Elasticube is already being built"
            return None
        return status
