#!/bin/sh
set -e

# Install build deps
apt-get update
apt-get install -y tk-dev libgc-dev python-cffi

# Clone pypy image - mercurial doesn't support shallow clones, so this will take some time ... go make a coffee
hg clone https://bitbucket.org/pypy/pypy pypy && cd pypy
hg checkout release-pypy2.7-v5.10.0

# Use pypy to build pypy... this will take some time... go have lunch
cd /pypy/pypy/goal
echo "Building pypy"
pypy ../../rpython/bin/rpython --opt=jit targetpypystandalone.py --objspace-lonepycfiles

# Build stdlib cffi
PYTHONPATH=../.. ./pypy-c ../tool/build_cffi_imports.py

# Package installable executable
cd ../tool/release
./package.py --archive-name=pypy-2.7-v5.10.0-linux

# Clear out the old version of pypy
rm -rf /usr/local/bin/*
rm -rf /usr/local/{lib-python,lib_pypy,site-packages}

# Install the executable over the top of the old pypy
mv /tmp/usession-release-pypy2.7-v5.10.0-current/build/pypy-2.7-v5.10.0-linux  /opt/pypy
ln -sf /opt/pypy/bin/pypy /usr/local/bin/pypy

# Install pip
wget https://bootstrap.pypa.io/get-pip.py
pypy get-pip.py --no-cache-dir
ln -sf /opt/pypy/bin/pip /usr/local/bin/pip
rm get-pip.py

# Remove all the cruft
cd /
rm -rf /tmp/usession-default-current/build
rm -rf prebuilt
rm -rf pypy

# Uninstall build deps
apt-get purge --auto-remove -y tk-dev libgc-dev python-cffi && rm -rf /var/lib/apt/lists/*

