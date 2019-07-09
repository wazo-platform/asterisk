# -*- coding: utf-8 -*-
# Copyright 2017-2019 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0+

import ari as ari_client
import logging
import os
import pytest
from hamcrest import *
from hamcrest import assert_that
from hamcrest import calling
from hamcrest import has_property
from requests.exceptions import HTTPError
from xivo_test_helpers import until
from xivo_test_helpers.bus import BusClient
from xivo_test_helpers.asset_launching_test_case import AssetLaunchingTestCase
from xivo_test_helpers.hamcrest.raises import raises


log_level = logging.DEBUG if os.environ.get('TEST_LOGS') == 'verbose' else logging.INFO
logging.basicConfig(level=log_level)


class AssetLauncher(AssetLaunchingTestCase):

    assets_root = os.path.join(os.path.dirname(__file__), '..', 'assets')
    asset = 'amqp'
    service = 'asterisk'


@pytest.fixture()
def ari():
    AssetLauncher.kill_containers()
    AssetLauncher.rm_containers()
    AssetLauncher.launch_service_with_asset()
    ari_url = 'http://localhost:{port}'.format(port=AssetLauncher.service_port(5039, 'ari_amqp'))
    ari = until.return_(ari_client.connect, ari_url, 'wazo', 'wazo', timeout=5, interval=0.1)

    yield ari

    AssetLauncher.kill_containers()


def test_stasis_amqp_events(ari):
    bus_client = BusClient.from_connection_fields(port=AssetLauncher.service_port(5672, 'rabbitmq'))

    AssetLauncher.docker_exec(["asterisk", "-rx", "module load res_stasis_amqp.so"], service_name='ari_amqp')
    events = bus_client.accumulator("stasis.app.amqp_gateway")

    ari.bridges.create()

    def event_received(events):
        assert_that(events.accumulate(), has_item(
            has_entry('data',
                has_entry('type', 'BridgeCreated')
            )
        ))

    until.assert_(event_received, events, timeout=5)



