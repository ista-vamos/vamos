#!/bin/bash

# Assumed steps before this script:

# git clone git@github.com:ista-vamos/vamos.git -b dev
# cd vamos

set -e
set -x

cd $(dirname $0)

LLVM_SOURCES="OFF"
DYNAMORIO_SOURCES="OFF"
TESSLA_SUPPORT="OFF"

# setup python virtual environment
if [ ! -f venv/bin/activate ]; then
        # echo "Installing python-venv"
        if [ ! python3 -m venv -h &>/dev/null ]; then
                sudo apt-get install python3-venv
        fi
        python3 -m venv venv
        source venv/bin/activate
        pip install lark
else
        source venv/bin/activate
fi


make LLVM_SOURCES=$LLVM_SOURCES DYNAMORIO_SOURCES=$DYNAMORIO_SOURCES TESSLA_SUPPORT=$TESSLA_SUPPORT
make mpt
