# -*- coding: utf-8 -*-
import pytest
import requests
from parameterized import parameterized

from ..test_api_1_0 import TEST_API_1_0

class TestAccount(TEST_API_1_0):

    def tearDown(self) -> None:
        self.utils.remove_test_dir()

    def test_account_C1951042(self):
        self.utils.check_response(self)

    def test_account_C1951112(self):
        self.add_admin_user(password=False)
        self.utils.check_response(self, expected_response=204,
                                  body={"email": "test_C{0}@<ssecret_company>.com".format(self.testrail_id)})

    def test_account_C1976149(self):
        self.add_admin_user(password=True)
        self.<ssecret_company>_conn.logout(self.token)
        admin_token = self.<ssecret_company>_conn.login("test_C1976149@<ssecret_company>.com", "Ad!234qw")
        self.utils.check_response(self, body={"currentPassword": "Ad!234qw", "newPassword": "Ad!234qw1"},
                                  expected_response=204, token=admin_token)

    def test_account_C1976152(self):
        name_1 = "test_C{0}@<ssecret_company>.com".format(self.testrail_id)
        name_2 = "test_C{0}_1".format(self.testrail_id)
        self.add_admin_user(password=False)
        self.add_admin_user(password=False, name=name_2)
        self.utils.check_response(self, body=["{0}@<ssecret_company>.com".format(name_2), name_1], expected_response=204)

    def test_account_C1976154(self):
        self.add_admin_user()
        token = self.<ssecret_company>_conn.login("test_C{0}@<ssecret_company>.com".format(self.testrail_id), "Ad!234qw")
        self.utils.check_response(self, expected_response=204,
                                  body={"email": "test_C{0}@<ssecret_company>.com".format(self.testrail_id)}, token=token)

    @parameterized.expand([
        ('C3548607', "GET", "/api/v1/account/get_license_info", 403, ''),
        ('C3548608', "POST", "/api/v1/account/begin_activate", 403, {"email": "testuser2@<ssecret_company>.com"}),
        ('C3548629', "POST", "/api/v1/account/set_new_license", 403, ''),
        ('C3548634', "POST", "/api/v1/account/begin_activate_bulk", 403, ["testuser2@<ssecret_company>.com","testuser3@<ssecret_company>.com"]),
        ('C3548636', "POST", "/api/v1/account/set_offline_license", 403, ''),
        ('C3548609', "POST", "/api/v1/account/begin_activate", 404, {"email": "invalidmail@<ssecret_company>.com"}),
        ('C3548633', "POST", "/api/v1/account/activate/12345asdfg", 404, {"password": "Ad!234qw"}),
        ('C3548635', "POST", "/api/v1/account/begin_activate_bulk", 404,["invalidmail@<ssecret_company>.com", "invalidmail2@<ssecret_company>.com"]),
        ('C3548611', "POST", "/api/v1/account/change_password", 401, { "currentPassword":"Ad!234qw123", "newPassword":"Ad!234qw1" }),

    ], name_func=TEST_API_1_0.custom_name_func)
    @pytest.mark.mt_ready
    def test_account(self, _, method, api_endpoint, expected_response, body):
        self.add_viewer_user() if expected_response == 403 else self.add_admin_user()
        token = self.<ssecret_company>_conn.login(f"test_C{self.testrail_id}@<ssecret_company>.com", "Ad!234qw")
        self.utils.check_response(self, expected_response=expected_response, body=body, header="", params='',
                                  url_suffix=api_endpoint,
                                  method=method, token=token)

    @parameterized.expand([
        ('C3548631', "POST", "/api/v1/account/set_new_license", 401, '', 'invalidtoken'),
        ('C3548638', "POST", "/api/v1/account/set_offline_license", 401, '', 'invalidtoken'),
    ], name_func=TEST_API_1_0.custom_name_func)
    @pytest.mark.mt_ready
    def test_error401_account(self, _, method, api_endpoint, expected_response, body, invalid_token):
        self.utils.check_response(self, expected_response=expected_response, body=body, header="", params='',
                                  url_suffix=api_endpoint,
                                  method=method, token=invalid_token)

    @parameterized.expand([
        ('C3548612', "POST", "/api/v1/account/change_password", 400, [{ "currentPassword":"Ad!234qw", "newPassword":"Ad!234qw" },
                                                                      { "currentPassword":"Ad!234qw", "newPassword":"Ad!2" },
                                                                      { "currentPassword":"Ad!234qw", "newPassword":"Ad!qwqwqw"},
                                                                      { "currentPassword":"Ad!234qw", "newPassword":"Adqqwqwqw" },
                                                                      { "currentPassword":"Ad!234qw", "newPassword":"1231!!2314" }]),
        ('C3548630', "POST", "/api/v1/account/set_new_license", 400, [{},
                                                                      { "bigData": True, "expirationDate": "2038-12-23T00:00:00.000Z", "highAvailability": True,
                                                                        "inUseAdmins": 3, "inUseDesigners": 0, "inUseViewers": 2003, "maxAdmins": 98, }]),
        ('C3548637', "POST", "/api/v1/account/set_offline_license", 400, [{},
                                                                      { "bigData": True, "expirationDate": "2038-12-23T00:00:00.000Z", "highAvailability": True,
                                                                        "inUseAdmins": 3, "inUseDesigners": 0, "inUseViewers": 2003, "maxAdmins": 98, }]),
    ], name_func=TEST_API_1_0.custom_name_func)
    def test_error400_account(self, _, method, api_endpoint, expected_response, body):
        self.add_admin_user()
        token = self.<ssecret_company>_conn.login(f"test_C{self.testrail_id}@<ssecret_company>.com", "Ad!234qw")
        [self.utils.check_response(self, expected_response=expected_response, body=x, header="", params='',
                                  url_suffix=api_endpoint,
                                  method=method, token=token) for x in body]

    @pytest.mark.mt_ready
    def test_account_C3548610(self):
        response = requests.post(f"{self.config.<ssecret_company>_base_url}/api/v1/account/change_password",
                                 data='{ "currentPassword":"Ad!234qw", "newPassword":"Ad!234qw1" }', params='', headers={})
        assert response.status_code == 403