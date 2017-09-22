#!/bin/bash
# ./run-bkr-case.sh /kernel/filesystems/ltp-fsstress

runcase()
{
    TEST_NAME=$1
    PACKAGE_NAME=`echo kernel${TEST_NAME} | sed 's/\//-/g'`

    which tee 2>&1 > /dev/null
    if [ $? != 0 ]; then
        yum install -y coreutils
    fi

    rpm -q $PACKAGE_NAME 2>&1 > /dev/null
    if [ $? != 0 ]; then
        yum install -y $PACKAGE_NAME
    fi

    cd /mnt/tests${TEST_NAME}
    cat testinfo.desc  | grep Requires | sed 's/Requires:/yum install -y /' | tee ./install_requires.sh
    chmod a+x ./install_requires.sh
    ./install_requires.sh


    mkdir ~/tests
    make run 2>&1 | tee ~/tests/${PACKAGE_NAME}.log
}


while [ $# -gt 0 ]; do
    runcase $1
    shift
done
