# Assumed steps before this script:

# git clone git@github.com:ista-vamos/vamos.git -b dev
# cd vamos

set -e
set -x

cd $(dirname $0)

DYNAMORIO_SOURCES="OFF"
TESSLA_SUPPORT="OFF"

# setup python virtual environment
if [ ! -d venv/ ]; then
        # echo "Installing python-venv"
        if [ ! python3 -m venv -h &>/dev/null ]; then
                sudo apt-get install python3-venv
        fi
        python3 -m venv venv
        pip install lark
fi

source venv/bin/activate

make DYNAMORIO_SOURCES=$DYNAMORIO_SOURCES TESSLA_SUPPORT=$TESSLA_SUPPORT
make mpt
