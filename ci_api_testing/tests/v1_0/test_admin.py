# -*- coding: utf-8 -*-
import os
import time
import pytest

from packages.assert_messages import Assert_msg

from ..test_api_1_0 import TEST_API_1_0


class TestAdmin(TEST_API_1_0):

    def tearDown(self) -> None:
        self.utils.remove_test_dir()

    def test_admin_C1976156(self):
        self.utils.copy_files_to_local()
        self.utils.import_dashboard(os.path.join(self.config.working_dir, self.utils.id, "TEST.dash"))

        lookups = ['"title":"TEST"']
        self.run_and_check_endpoint(lookups=lookups)
        url_suffix = "/api/v1/dashboards/admin?fields=title"
        lookups = ['"title":"TEST"', '"oid"']
        self.params = None
        self.run_and_check_endpoint(url_suffix=url_suffix, lookups=lookups)

    @pytest.mark.mt_ready
    def test_admin_C2001369(self):
        self.utils.check_response(self)

    def test_admin_C2001368(self):
        self.add_admin_user()
        res = self.utils.check_response(self)
        msg = 'Response: {0}\nURL SUFFIX: {1}\nMethod: {2}'.format(res, self.url_suffix, self.method)

    # TODO Fails on Windows, Passes on Linux
    def test_admin_C2001371(self):
        <ssecret_company>_api, token = self.utils.get_<ssecret_company>_api_connection()
        <ssecret_company>_api.create_usage_cube(token)
        <ssecret_company>_api.set_usage(token, True)
        time.sleep(60)
        self.utils.check_response(self)

    def test_admin_C2001372(self):
        <ssecret_company>_api, token = self.utils.get_<ssecret_company>_api_connection()
        <ssecret_company>_api.create_usage_cube(token)
        <ssecret_company>_api.set_usage(token, True)
        time.sleep(20)
        res = self.utils.check_response(self)
        msg = 'Response: {0}\nURL SUFFIX: {1}\nMethod: {2}'.format(res, self.url_suffix, self.method)
        self.assertIn('"title":"Usage - Domains"', res,
                      Assert_msg(self.testrail_id, res, self.body, msg))

    @pytest.mark.mt_ready
    def test_admin_C2001380(self):
        self.utils.copy_files_to_local()
        self.utils.import_dashboard(os.path.join(self.config.working_dir, self.utils.id, "TEST.dash"))
        self.utils.check_response(self)

    def test_admin_C2001381(self):
        self.utils.copy_files_to_local()
        user = self.add_admin_user()
        dash = self.utils.import_dashboard(os.path.join(self.config.working_dir, self.utils.id, "TEST.dash"))
        dash_id = dash.json()["succeded"][0]["oid"]
        user_id = user.json()[0][0]["_id"]
        admin = None
        users = self.<ssecret_company>_conn.get_users(self.token, self.config.host).json()
        for possible in users:
            if possible["userName"] == "autotest@<ssecret_company>.com":
                admin = possible["_id"]
        self.utils.share_dashboard(dash_id, user_id, admin)
        payload = {"ownerId": user_id, "originalOwnerRule": "edit"}
        url_suffix = "/api/v1/dashboards/{id}/admin/change_owner".format(id=dash_id)
        self.run_and_check_endpoint(url_suffix=url_suffix, params={"id": dash_id}, body=payload)
