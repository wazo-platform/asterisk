# Copyright 2020 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later

import os
import json
import unittest
import subprocess

TEST_DIR = os.path.dirname(__file__)
SCRIPT_PATH = os.path.join(TEST_DIR, '..', 'pjsip_doc_extractor.py')
INPUT_PATH = os.path.join(TEST_DIR, 'core-en_US.xml')
EXPECTED_RESULT_PATH = os.path.join(TEST_DIR, 'extracted.json')


class TestPJSIPDocExtractor(unittest.TestCase):

    def test_generated_output(self):
        cmd = [SCRIPT_PATH, INPUT_PATH]

        p = subprocess.run(cmd, capture_output=True)
        result = json.loads(p.stdout)
        with open(EXPECTED_RESULT_PATH, 'r') as f:
            expected = json.load(f)

        assert result == expected
