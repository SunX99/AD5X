#!/bin/sh

# Author:		chenhe
# Description:	单个固件包升级程序
# Date:			2022-01-21

set -x

WORK_DIR=`dirname $0`

#检测机器的架构,错误马上退出
CHECH_ARCH=`uname -m`
if [ "${CHECH_ARCH}" != "mips" ];then
    echo "Machine architecture error."
    echo ${CHECH_ARCH}
    exit 1
fi

#检测内核版本，错误马上退出
#CHECH_KERNEL=`uname -r`
#if [ "${CHECH_KERNEL}" != "5.6.0-svn539" ];then
#    echo "Kernel version error."
#    echo ${CHECH_KERNEL}
#    exit 1
#fi

# cp -vf /tmp/test /usr/data/
# $1  源文件路径名 /tmp/test
# $2  目标路径名   /usr/data/
cp_file()
{
	SRCFILE="$1"
	DSTFILE="$2`basename $1`"
	if [ ! -f $DSTFILE ];then
		cp -vf ${SRCFILE} $2
		chmod a+x $DSTFILE
	fi
	SRCFILEMD5=`md5sum $SRCFILE | cut -d ' ' -f 1`
	DSTFILEMD5=`md5sum $DSTFILE | cut -d ' ' -f 1`
	while [ "$SRCFILEMD5" != "$DSTFILEMD5" ];
	do
		rm -rf ${DSTFILE}
		cp -vf ${SRCFILE} $2
		chmod a+x $DSTFILE
		sync
		DSTFILEMD5=`md5sum $DSTFILE | cut -d ' ' -f 1`
	done
	#echo ${SRCFILEMD5}
	#echo ${DSTFILEMD5}
}

if [ -f $WORK_DIR/app_startup.sh  ]; then
        cp -f $WORK_DIR/app_startup.sh /usr/prog/
fi

if [ -f $WORK_DIR/sys_start.sh  ]; then
        cp -f $WORK_DIR/sys_start.sh /usr/prog/
fi

sync

cp $WORK_DIR/firmwareExe /usr/prog/PROGRAM/software/
sync

if [ ! -d /usr/prog/config  ]; then
	cp -rf /usr/data/config /usr/prog/
fi

if [ -f $WORK_DIR/printer.base.cfg ]; then
	cp $WORK_DIR/printer.base.cfg  /usr/data/config/
        cp $WORK_DIR/start.sh  /usr/prog/klipper/
        cp $WORK_DIR/virtual_sdcard.py  /usr/prog/klipper/klippy/extras/
        cp $WORK_DIR/query_adc.py  /usr/prog/klipper/klippy/extras/
	chmod a+x /usr/prog/klipper/start.sh
fi

cd /usr/prog/PROGRAM/software
DIR_COUNT=`find -maxdepth 1 -type d | wc -l`
if [ ${DIR_COUNT} -gt 2 ];then
        VERSION=`ls -d [0-9]* | sort -V | head -n 1`
        echo "rm " $VERSION
        rm -r /usr/prog/PROGRAM/software/$VERSION
fi

exit 0
