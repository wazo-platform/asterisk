#!/usr/bin/env python3
# Copyright 2020 The Wazo Authors  (see the AUTHORS file)
# SPDX-License-Identifier: GPL-3.0-or-later

import json
import argparse
from xml.etree import ElementTree

tag_to_quote = [
    'emphasis',
    'filename',
    'literal',
    'replaceable',
    'warning',
]

def trim_spaces(s):
    # Turn all kind of white spaces to a single one
    return ' '.join(s.split())

def reformat_block(s):
    # Replace some tags by quotes and remove all other tags
    for tag in tag_to_quote:
        s = s.replace('<{}>'.format(tag), '"')
        s = s.replace('</{}>'.format(tag), '"')
    elem = ElementTree.fromstring(s)
    s = ElementTree.tostring(elem, encoding='utf8', method='text').decode('utf8')
    return trim_spaces(s)

def extract_para(elem):
    paras = elem.findall('para')
    parts = []
    for para in paras:
        parts.append(reformat_block(ElementTree.tostring(para, encoding='utf8').decode('utf8')))
    return '\n'.join(parts)

def extract_node(elem):
    notes = []
    for note in elem.findall('note'):
        notes.append(extract_para(note))
    return '\n'.join(notes)


def extract_choices(elem):
    result = {}
    for enum in elem.findall('./*enum'):
        description = extract_para(enum) if enum.text else ''
        result[enum.attrib['name']] = description
    return result


def extract_pjsip_option(elem):
    synopsis, description, note = '', '', ''
    choices = {}

    for e in elem:
        if e.tag == 'synopsis':
            synopsis = trim_spaces(e.text)
        if e.tag == 'description':
            description = extract_para(e)
            note = extract_node(e)
            choices = extract_choices(e)

    return {
        'name': elem.attrib['name'],
        'default': elem.attrib.get('default'),
        'synopsis': synopsis,
        'description': description,
        'note': note,
        'choices': choices,
    }


def extract_pjsip_doc_section(elem):
    result = {}
    for option in elem:
        if 'name' not in option.attrib:
            continue
        result[option.attrib['name']] = extract_pjsip_option(option)
    return result


def extract_pjsip_doc(root):
    result = {}
    for section in root.findall(".//*[@name='res_pjsip']/configFile/"):
        result[section.attrib['name']] = extract_pjsip_doc_section(section)
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('file')
    args = parser.parse_args()

    filename = args.file

    root = ElementTree.parse(filename).getroot()
    doc = extract_pjsip_doc(root)
    print(json.dumps(doc))


if __name__ == '__main__':
    main()
