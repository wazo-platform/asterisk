# -*- coding: utf-8 -*-
# Copyright 2017-2021 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0+

import ari as ari_client
import logging
import os
import pytest

from hamcrest import assert_that
from hamcrest import calling
from hamcrest import has_property
from requests.exceptions import HTTPError
from xivo_test_helpers import until
from xivo_test_helpers.asset_launching_test_case import AssetLaunchingTestCase
from xivo_test_helpers.hamcrest.raises import raises

log_level = logging.DEBUG if os.environ.get('TEST_LOGS') == 'verbose' else logging.INFO
logging.basicConfig(level=log_level)


class AssetLauncher(AssetLaunchingTestCase):

    assets_root = os.path.join(os.path.dirname(__file__), '..', 'assets')
    asset = 'base'
    service = 'asterisk'


@pytest.fixture()
def ari():
    AssetLauncher.kill_containers()
    AssetLauncher.rm_containers()
    AssetLauncher.launch_service_with_asset()
    ari_url = 'http://127.0.0.1:{port}'.format(port=AssetLauncher.service_port(5039, 'ari'))
    ari = until.return_(ari_client.connect, ari_url, 'wazo', 'wazo', timeout=5, interval=0.1)

    yield ari

    AssetLauncher.kill_containers()


def test_delete_voicemail_message_without_body(ari):
    assert_that(calling(ari.wazo.deleteVoicemailMessage).with_args(body={'wrong_key': 'wrong_value'}),
                raises(HTTPError).matching(has_property('response', has_property('status_code', 400))))


def test_move_voicemail_message_without_body(ari):
    assert_that(calling(ari.wazo.moveVoicemailMessage).with_args(body={'wrong_key': 'wrong_value'}),
                raises(HTTPError).matching(has_property('response', has_property('status_code', 400))))
