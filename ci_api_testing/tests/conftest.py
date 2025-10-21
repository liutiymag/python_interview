import os
import shutil
import pytest
import json
from packages.<ssecret_company>_api import test_name
from packages.<ssecret_company> import <ssecret_company>
from packages.<ssecret_company>_config import Config as config
import argparse

@pytest.fixture(scope="function")
def testrail_id(request):
    """
    Extract testrail id from test name
    """
    testrail_id = request.node.name.split('_C')[-1]
    yield testrail_id

@pytest.fixture(scope="function")
def test_method_name(request):
    """
    Extract test method name
    """
    yield request.node.name
