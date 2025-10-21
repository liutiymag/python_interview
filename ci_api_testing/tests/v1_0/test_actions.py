# -*- coding: utf-8 -*-
import json

from ..test_api_1_0 import TEST_API_1_0
from http import HTTPStatus


class TestActions(TEST_API_1_0):

    def test_actions_C3548642(self):
        url_suffix = "/api/v1/quest/customAction/newCustomAction"
        res = self.utils.call_api_method("POST", url_suffix, auth=True)
        assert res.status_code == 200, f"Unexpected response {res.status_code}, {res.text}"
        assert res.json()['code'] == "\"use strict\";", f"Unexpected response {res.status_code}, {res.text}"

    def test_actions_C3548643(self):
        url_suffix = "/api/v1/quest/allCustomActions"
        res = self.utils.call_api_method("GET", url_suffix, auth=True)
        assert res.status_code == 200, f"Unexpected response {res.status_code}, {res.text}"
        assert res.json()[0]['code'] == "\"use strict\";", f"Unexpected response {res.status_code}, {res.text}"

    def test_actions_C3548644(self):
        url_suffix = "/api/v1/quest/customAction/newCustomAction"
        res = self.utils.call_api_method("GET", url_suffix, auth=True)
        assert res.status_code == 200, f"Unexpected response {res.status_code}, {res.text}"

    def test_actions_C3548646(self):
        url_suffix = "/api/v1/quest/customAction/newCustomAction"
        expected_response = [
            None,
            {
                "lastErrorObject": {
                    "n": 0
                },
                "value": None,
                "ok": 1
            }
        ]
        res = self.utils.call_api_method("DELETE", url_suffix, auth=True)
        assert res.status_code == 200, f"Unexpected response {res.status_code}, {res.text}"
        assert res.json() == expected_response, f"Unexpected response {res.status_code}, {res.text}"