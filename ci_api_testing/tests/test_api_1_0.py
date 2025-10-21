# -*- coding: utf-8 -*-
import json
import time

from packages.assert_messages import Assert_msg
from packages.<ssecret_company>_api import <ssecret_company>API
from http import HTTPStatus
from .test_api_base_class import TestAPIBaseClass


class TEST_API_1_0(TestAPIBaseClass):
    api_version = 'v1.0'

    def create_kpi_alert(self, name, datasource, metadata, source, condition, action, dash_id, user_id):

        result = self.create_kpi_alert_call(self.token, name, datasource, metadata, source, condition, action,
                                            dash_id,
                                            user_id)
        return result

    def create_build_alert(self, name, enabled, source, action, user_id):

        result = self.create_build_alert_call(self.token, name, enabled, source, action, user_id)
        return result

    def get_alert(self, id):

        result = self.get_alert_call(self.token, id)
        return result

    def get_connection_info(self, id):

        result = self.get_connection_call(self.token, id)
        return result

    def import_smodel(self, path):
        with open(path) as cube:
            cube_name = json.loads(cube.read())['title']
        oid = self.api_utils.elasticube_import_smodel(path, cube_name, overwrite=True)
        return oid

    def create_custom_data(self, payload):

        result = self.create_custom_data_call(self.token, payload)
        return result

    def get_dashboard_oid(self, name):

        result = self.get_dashboards_call(self.token)
        for dashboard in result.json():
            try:
                if dashboard["title"] == name:
                    return dashboard["oid"]
            except KeyError:
                continue
        print(result)
        return result

    def share_dashboard(self, user, dash_id):
        users_id = self.<ssecret_company>_conn.get_users(self.token, self.config.host).json()
        autotest_user = None
        admin_1 = None
        nilly = None
        for uid in users_id:
            if uid["userName"] == "autotest@<ssecret_company>.com":
                autotest_user = uid["_id"]
            elif uid["userName"] == "admin1@<ssecret_company>.com":
                admin_1 = uid["_id"]
            elif uid["userName"] == "nilly.ofan@<ssecret_company>.com":
                nilly = uid["_id"]
            elif uid["userName"] == "{0}@<ssecret_company>.com".format(user):
                user = uid["_id"]
        if admin_1 is None and user is None:
            result = self.share_dashboard_call(self.token, dash_id=dash_id, new_owner=autotest_user, new_user=nilly)
        elif user is not None:
            result = self.share_dashboard_call(self.token, dash_id=dash_id, new_owner=autotest_user, new_user=user)
        elif nilly is None:
            result = self.share_dashboard_call(self.token, dash_id=dash_id, new_owner=admin_1, new_user=autotest_user)
        else:
            result = self.share_dashboard_call(self.token, dash_id=dash_id, new_owner=autotest_user, new_user=user)
        return result

    def get_dashboard_widgets(self, dash_id):

        result = self.get_dashboards_widget_call(self.token, dash_id=dash_id)
        return result

    def get_role_id(self, role_name):
        result = self.get_roles_call(self.token).json()
        for role in result:
            if role["displayName"] == role_name:
                return role["_id"]
        return None

    def add_user(self, password, name, role_id, **kwargs):
        if name is None:
            name = self.utils.id
        email = kwargs.get("email", "{0}@<ssecret_company>.com".format(name))
        first_name = kwargs.get("first_name", name)
        last_name = kwargs.get("last_name", name)
        if password:
            result = self.<ssecret_company>_conn.create_user(self.token, email, role_id,
                                                   email, first_name, last_name, [],
                                                   {"language": "en-US"}, "Ad!234qw")
        else:
            result = self.<ssecret_company>_conn.create_user(self.token, email, role_id,
                                                   email, first_name, last_name, [],
                                                   {"language": "en-US"}, None)
        return result

    def delete_user(self, name=None, id=None):
        if id is None:
            id = self.get_user_id(name)
        res = self.<ssecret_company>_conn.delete_user(token=self.token, user_id=id)
        assert res.status_code == HTTPStatus.NO_CONTENT, 'DELETE user failed {}'.format(self.id)

    def get_user_id(self, name):
        users = self.<ssecret_company>_conn.get_users(self.token, "localhost")
        user_id = None
        try:
            for user in users.json():
                if user["userName"] == name:
                    user_id = user["_id"]
                    break

        except (TypeError, KeyError, json.JSONDecodeError):
            self.fail("couldn't get user ID")
        return user_id

    def add_admin_user(self, password=True, name=None, **kwargs):
        admin_role = self.get_role_id("Admin")
        return self.add_user(password, name, admin_role, **kwargs)

    def add_designer_user(self, password=True, name=None, **kwargs):
        role_id = self.get_role_id("Designer")
        return self.add_user(password, name, role_id, **kwargs)

    def add_viewer_user(self, password=True, name=None, **kwargs):
        role_id = self.get_role_id("Viewer")
        return self.add_user(password, name, role_id, **kwargs)

    def add_data_admin_user(self, password=True, name=None, **kwargs):
        role_id = self.get_role_id("Data Admin")
        return self.add_user(password, name, role_id, **kwargs)

    def add_data_designer_user(self, password=True, name=None, **kwargs):
        role_id = self.get_role_id("Data Designer")
        return self.add_user(password, name, role_id, **kwargs)

    def create_kpi_alert_call(self, token, name, datasource, metadata, source, condition, action, dash_id, user_id):
        url_suffix = "/api/v1/alerts"
        payload = {"enabled": True, "name": name, "message": "",
                   "parties": [{"type": "user", "id": user_id}], "category": "kpi", "type": "kpi",
                   "context": {"notifyOnceMet": True, "notifyNotMet": True, "dashboard": dash_id,
                               "kpi": {
                                   "datasource": datasource,
                                   "metadata": metadata},
                               "sources": [source],
                               "locale": "en-US",
                               "condition": condition}, "action": action}
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, params=None, payload=payload, token=token)
        return result

    def create_build_alert_call(self, token, name, enabled, source, action, user_id):
        url_suffix = "/api/v1/alerts"
        payload = {"enabled": enabled, "name": name, "parties": [{"type": "user", "id": user_id}], "category": "system",
                   "type": "build",
                   "context": {"buildSuccess": False, "buildFailed": True, "buildSuccessAfterFailed": True,
                               "backToNormal": False,
                               "sources": [source]}, "action": action}
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, params=None, payload=payload, token=token)
        return result

    def get_alert_call(self, token, id):
        url_suffix = "/api/v1/alerts/{0}".format(id)
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, token=token)
        return result

    def get_connection_call(self, token, id):
        url_suffix = "/api/v1/connection/{0}".format(id)
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, token=token)
        return result

    def create_custom_data_call(self, token, payload):
        url_suffix = "/api/v1/custom_data"
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, token=token, payload=payload)
        return result

    def get_dashboards_call(self, token):
        url_suffix = "/api/v1/dashboards"
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, token=token)
        return result

    def delete_dashboards_call(self, token, dashboardId):
        url_suffix = "/api/v1/dashboards/" + dashboardId
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "DELETE", url_suffix, token=token)
        return result

    def share_dashboard_call(self, token, dash_id, new_owner, new_user=None, subscribe=True, rule="edit"):
        url_suffix = "/api/shares/dashboard/{0}".format(dash_id)
        if new_user is not None:
            payload = {"sharesTo": [{"shareId": new_owner, "type": "user", "subscribe": subscribe, "rule": rule},
                                    {"shareId": new_user, "type": "user", "subscribe": subscribe, "rule": rule}],
                       "sharesToNew": [],
                       "allowChangeSubscription": False,
                       "subscription": {"isDataChange": True, "type": "onUpdate", "schedule": "0 00 22 * * *",
                                        "timezone": -120,
                                        "tzName": "Asia/Jerusalem", "context": {"dashboardid": dash_id},
                                        "active": True, "executionPerDay": 1, "reportType": {"inline": True},
                                        "emailSettings": {"isEmail": True, "isPdf": False}}}
        else:
            payload = {"sharesTo": [{"shareId": new_owner, "type": "user", "subscribe": subscribe, "rule": rule}],
                       "sharesToNew": [],
                       "allowChangeSubscription": False,
                       "subscription": {"isDataChange": True, "type": "onUpdate", "schedule": "0 00 22 * * *",
                                        "timezone": -120,
                                        "tzName": "Asia/Jerusalem", "context": {"dashboardid": dash_id},
                                        "active": True, "executionPerDay": 1, "reportType": {"inline": True},
                                        "emailSettings": {"isEmail": True, "isPdf": False}}}
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, payload=payload, token=token)
        return result

    def get_dashboards_widget_call(self, token, dash_id):
        url_suffix = "/api/v1/dashboards/{0}/widgets".format(dash_id)
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, token=token)
        return result

    def get_roles_call(self, token):
        url_suffix = "/api/roles"
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, token=token)
        return result

    def get_groups_id(self, token):
        url_suffix = "/api/v1/groups"
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "GET", url_suffix, None, None, token)
        return result

    def add_data_security_to_live(self, token, cube_title, table_name, column):
        url_suffix = "/api/v1/elasticubes/live/{0}/datasecurity".format(cube_title)
        body = {"table": table_name, "column": column, "datatype": "text", "shares": [{"type": "default"}],
                "members": [], "allMembers": True, "elasticube": cube_title, "live": True,
                "fullname": "live:{0}".format(cube_title)}

        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, payload=body, token=token)
        return result

    def put_data_security_rule(self, token, data_sec_oid, rule: dict):
        url_suffix = "/api/elasticubes/datasecurity/{0}".format(data_sec_oid)
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "PUT", url_suffix, payload=rule, token=token)
        return result

    def create_dashboard_folder(self, token, folder_name, parent=None):
        url_suffix = "/api/v1/folders"
        if parent is None:
            body = {"name": folder_name}
        else:
            body = {"name": folder_name, "parentId": parent}
        result = <ssecret_company>API.call_api(self.<ssecret_company>_conn, "POST", url_suffix, payload=body, token=token)
        return result

    def run_and_check_endpoint(self, url_suffix=None, body=None, method=None, params=None, expected_code=None,
                               lookups=None, token=None):
        res = self.utils.check_response(self, body=body, url_suffix=url_suffix, params=params, method=method,
                                        expected_response=expected_code, token=token)
        msg = 'Response: {0}\nURL SUFFIX: {1}\nMethod: {2}'.format(res, self.url_suffix, self.method)
        if lookups is not None:
            for look in lookups:
                self.assertIn(look, res, Assert_msg(self.testrail_id, res, self.body, msg))

    def create_group(self, group_name):
        url_suffix = "/api/v1/groups"
        body = {"name": group_name}
        res = self.<ssecret_company>_conn.call_api("POST", url_suffix, None, body, self.token)
        return res.json()["_id"]

    def delete_group(self, group_id):
        url_suffix = "/api/v1/groups/{0}".format(group_id)
        res = self.<ssecret_company>_conn.call_api("DELETE", url_suffix, None, None, self.token)
        return res

    def get_groups_ids(self):
        url_suffix = "/api/v1/groups"
        res = self.<ssecret_company>_conn.call_api("GET", url_suffix, None, None, self.token)
        groups = {}
        for group in res.json():
            if group['name'] != "Admins" and group['name'] != "Everyone":
                groups[group['name']] = group['_id']
        return groups

    def ldap_delete(self):
        url_suffix = "/api/v1/ldap_domains"
        res = self.<ssecret_company>_conn.call_api("GET", url_suffix, None, None, self.token)
        delete_url_suffix = url_suffix + "/bulk"
        if res.text != '[]':
            ldap_id = res.json()[0]['_id']
            params = {"ids": [ldap_id]}
            result = self.<ssecret_company>_conn.call_api("DELETE", delete_url_suffix, params, None, self.token)
            return result

    def wait_build_end(self, buildId):
        for _ in range(300):
            status = self.utils.get_build_status(buildId)
            if status == "done":
                return status
            time.sleep(1)
        return("build failed")

    def publish_live_model(self, oid):
        return self.<ssecret_company>_conn.publish_live_elasticube(oid, self.token)
