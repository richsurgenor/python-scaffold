#!/usr/bin/python

import os
from setuptools import setup, find_packages

package = 'package_name'
setup_dir = os.path.dirname(os.path.abspath(__file__))
version_file = os.path.join(setup_dir, package, 'VERSION')

with open(version_file) as version_file:
    version = version_file.read().strip()

requirements = (
    open(os.path.join(setup_dir,'requirements.txt')).read().splitlines()
    )
required = [line for line in requirements if not line.startswith('-')]

setup(name=package,
      version=version,
      description='description',
      url='https://github.adtran.com/ADTRAN/' + package.replace('_', '-'),
      author='GROUP',
      author_email='GROUP@adtran.com',
      packages=find_packages(),
      install_requires=[required],
      include_package_data=True
      )
