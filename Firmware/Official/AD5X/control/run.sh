#!/bin/sh
# Author:		chenhe
# Date:			2022-01-21

set -x

WORK_DIR=`dirname $0`

FIRMWARE_Head_M3=ADM_App.hex
FIRMWARE_M3=AD5X.bin


CHECH_ARCH=`uname -m`
if [ "${CHECH_ARCH}" != "mips" ];then
    echo "Machine architecture error."
    echo ${CHECH_ARCH}
    exit 1
fi

cat $WORK_DIR/mcu.img > /dev/fb0

if [ -f $WORK_DIR/IAPCommand ];then
	chmod a+x $WORK_DIR/IAPCommand
	if [ -f $WORK_DIR/$FIRMWARE_Head_M3 ];then
		echo "burn M3 firmware..."
		$WORK_DIR/IAPCommand $WORK_DIR/$FIRMWARE_Head_M3 /dev/ttyS5
		sync
	fi
fi

if [ -f $WORK_DIR/NationsCommand ];then
        chmod a+x $WORK_DIR/NationsCommand
        if [ -f $WORK_DIR/$FIRMWARE_M3 ];then
                echo "burn M3 firmware..."
                $WORK_DIR/NationsCommand -c -d --fn $WORK_DIR/$FIRMWARE_M3 --v -r
        fi
fi

if [ -f $WORK_DIR/IFSCommand ]; then
	echo "update ifs"
        cp -f $WORK_DIR/IFSCommand  /usr/prog/PROGRAM/control/
        cp -f $WORK_DIR/ifs.hex  /usr/prog/PROGRAM/control/
	chmod a+x $WORK_DIR/ifsF37
	$WORK_DIR/ifsF37 /dev/ttyS4
	$WORK_DIR/IFSCommand $WORK_DIR/ifs.hex /dev/ttyS4
fi
sync

cd /usr/prog/PROGRAM/control/
DIR_COUNT=`find -maxdepth 1 -type d | wc -l`
echo $DIR_COUNT
if [ ${DIR_COUNT} -gt 2 ];then
	CONTROL_VERSION=`ls -d [0-9]* | sort -V | head -n 1`
	echo "rm " $CONTROL_VERSION
        rm -r /usr/prog/PROGRAM/control/$CONTROL_VERSION
fi
exit 0
