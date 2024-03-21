#!/usr/bin/env bash

set -e

PYTHON_VERSION=${1}
if [ -z ${PYTHON_VERSION} ]; then
  PYTHON_VERSION="$(ls -d ${HOME}/python3.8-*)"
fi

if ! ls ${PYTHON_VERSION}-* &> /dev/null; then
  echo "${PYTHON_VERSION} not found. Bye!"
  exit -1
fi

sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo sed -i 's/#\ //g' /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-focal.list

sudo apt-get update

sudo apt-get install -y devscripts equivs
if [ ! -d "${PYTHON_VERSION}" ]; then
  apt-get source ${PYTHON_VERSION}
fi

sudo apt-get build-dep -y ${PYTHON_VERSION}

# we need to temporarily bind mount on top of /tmp, o/w 
# we risk running out of room on the root partition
if [ mount | grep /tmp ]; then
  sudo umount /tmp
fi
mkdir -p ~/tmp
sudo mount --bind ~/tmp /tmp
sudo chown root: ~/tmp
sudo chmod 1777 ~/tmp

cd ${PYTHON_VERSION}
./configure  # --enable-optimizations --with-lto
time debuild -us -uc -j5

sudo umount /tmp
rm -r ~/tmp
