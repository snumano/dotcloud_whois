#!/usr/bin/env python

## Copyright (c) 2011 dotCloud Inc.
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
## THE SOFTWARE.

import os
import sys

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

VERSION = '0.9.5'

if sys.argv[-1] == 'publish':
    os.system('rm -rf *.egg-info')
    os.system('rm -rf build')
    os.system('rm -rf dist')
    os.system('git clean -x -f')
    os.system('python setup.py sdist upload')
    sys.exit()

setup(
    name = 'dotcloud',
    author = 'dotCloud Inc.',
    author_email = 'support@dotcloud.com',
    url = 'http://www.dotcloud.com/',
    version = VERSION,
    packages = [
        'dotcloud',
        'dotcloud.ui',
        'dotcloud.client',
        'dotcloud.packages'
    ],
    scripts  = [
        'bin/dotcloud'
    ],
    install_requires = ['argparse', 'requests==0.14.2', 'colorama'],
    zip_safe = False,
    description = 'dotCloud command-line interface client',
    long_description =
    'Using dotCloud, you can assemble your stack from pre-configured and '
    'heavily tested components. dotCloud supports major application '
    'servers, databases and message buses. '
    '\n'
    'The dotCloud CLI allows you to manage your software deployments on '
    'the dotCloud platform. To use this tool, you will need a dotCloud '
    'account. Register at http://www.dotcloud.com/ to get one!'
)
