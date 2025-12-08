#!/bin/sh
#set -x

WORK_DIR=`dirname $0`
RUN_DIR="/usr/prog/PROGRAM"

MACHINE=AD5X
PID=0026

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

#screwflag为丝杆标志文件,存在说明在工厂里,可任意升级
if [ ! -f $WORK_DIR/screwflag ]; then 
	#第1、2个参数为空,说明没有传递参数,为老版本固件,可升级
	if [ "$1" != "" ] && [ "$2" != "" ];then
		if [ "$1" != "${MACHINE}" ] || [ "$2" != "${PID}" ];then
			echo "Firmware does not match machine type."
			exit 1
		fi
	fi
fi

#========================Start AP And Root Password============================================
SSID_NAME="AD5X"
SSID_PASS=12345678
sync
#========================End AP============================================

create_key()
{
	key_dir=/usr/prog
	key_pair=${key_dir}private.pem
	public_key=${key_dir}key.pub
	private_key=${key_dir}key.priv
	password=abcd

	if [ ! -f ${key_pair} ];then
		export PATH=/usr/prog/openssl-1.0.2d/bin:$PATH
		export OPENSSL_DIR=/usr/prog/openssl-1.0.2d
		export LD_LIBRARY_PATH=$OPENSSL_DIR/lib:$LD_LIBRARY_PATH

		echo "CREATE RSA"
		# Generate the key pair
		openssl genrsa -des3 -passout pass:${password} -out ${key_pair} 2048
		# Save the RSA public key in the file key.pub
		openssl rsa -in ${key_pair} -passin pass:${password} -outform PEM -pubout -out ${public_key}
		# Save the RSA private key in the file key.priv
		openssl rsa -in ${key_pair} -passin pass:${password} -out ${private_key} -outform PEM
	fi
}

update_kernel()
{
	echo "update kernel"
	cd $WORK_DIR
	start_head="kernel-"
	end_tail=".tar.xz"
	ls -1t ${start_head}*${end_tail}
	if [ $? -eq 0 ];then
		file_name=`ls -1t ${start_head}*${end_tail} | head -n 1`
		version_length=`expr ${#file_name} - ${#start_head} - ${#end_tail}`
		kernel_version=${file_name:${#start_head}:${version_length}}
		if [ ! -d ${RUN_DIR}/kernel ];then
			mkdir -p ${RUN_DIR}/kernel
		fi
		temp_dir=${RUN_DIR}/kernel/temp
		if [ -d ${temp_dir} ];then
			rm -rf ${temp_dir}
		fi
		mkdir -p ${temp_dir}
		tar -xvf ${file_name} -C ${temp_dir}
		sync
		cd ${temp_dir}
		md5sum -s -c md5sum.list
		if [ $? -eq 0 ];then
			cd ..
			ls | grep -v temp | xargs rm -rf
			sync
			mv temp ${kernel_version}
			sync
			cd ${kernel_version}
			if [ -f run.sh ];then
				${RUN_DIR}/kernel/${kernel_version}/run.sh
			fi
		else
			cd ..
			rm -rf temp
		fi
	fi
}

update_control()
{
	echo "update control"
	cd $WORK_DIR
	start_head="control-"
	end_tail=".tar.xz"
	ls -1t ${start_head}*${end_tail}
	if [ $? -eq 0 ];then
		file_name=`ls -1t ${start_head}*${end_tail} | head -n 1`
		version_length=`expr ${#file_name} - ${#start_head} - ${#end_tail}`
		control_version=${file_name:${#start_head}:${version_length}}
		echo "${control_version}"
		if [ ! -d ${RUN_DIR}/control ];then
			mkdir -p ${RUN_DIR}/control
		fi
		temp_dir=${RUN_DIR}/control/temp
		if [ -d ${temp_dir} ];then
			rm -rf ${temp_dir}
		fi
		mkdir -p ${temp_dir}
		tar -xvf ${file_name} -C ${temp_dir}
		sync
		cd ${temp_dir}
		md5sum -s -c md5sum.list
		if [ $? -eq 0 ];then
			cd ..
			ls | grep -v temp | xargs rm -rf
			sync
			mv temp ${control_version}
			sync
			cd ${control_version}
			#if [ -f run.sh ];then
			#	${RUN_DIR}/control/${control_version}/run.sh
			#fi
		else
			cd ..
			rm -rf temp
		fi
	fi
}

update_software()
{
	echo "update software"
	cd $WORK_DIR
	start_head="software-"
	end_tail=".tar.xz"
	ls -1t ${start_head}*${end_tail}
	if [ $? -eq 0 ];then
		file_name=`ls -1t ${start_head}*${end_tail} | head -n 1`
		version_length=`expr ${#file_name} - ${#start_head} - ${#end_tail}`
		software_version=${file_name:${#start_head}:${version_length}}
		echo "${software_version}"
		if [ ! -d ${RUN_DIR}/software ];then
			mkdir -p ${RUN_DIR}/software
		fi
		temp_dir=${RUN_DIR}/software/temp
		if [ -d ${temp_dir} ];then
			rm -rf ${temp_dir}
		fi
		mkdir -p ${temp_dir}
		tar -xvf ${file_name} -C ${temp_dir}
		sync
		cd ${temp_dir}
		md5sum -s -c md5sum.list
		if [ $? -eq 0 ];then
			cd ..
			ls | grep -v temp | xargs rm -rf
			sync
			mv temp ${software_version}
			sync
			cd ${software_version}
			if [ -f run.sh ];then
				/${RUN_DIR}/software/${software_version}/run.sh
			fi
		else
			cd ..
			rm -rf temp
		fi
	fi
}

update_library()
{
	echo "update library"
	cd $WORK_DIR
	start_head="library-"
	end_tail=".tar.xz"
	ls -1t ${start_head}*${end_tail}
	if [ $? -eq 0 ];then
		file_name=`ls -1t ${start_head}*${end_tail} | head -n 1`
		version_length=`expr ${#file_name} - ${#start_head} - ${#end_tail}`
		library_version=${file_name:${#start_head}:${version_length}}
		echo "${library_version}"
		if [ ! -d ${RUN_DIR}/library ];then
			mkdir -p ${RUN_DIR}/library
		fi
		temp_dir=${RUN_DIR}/library/temp
		if [ -d ${temp_dir} ];then
			rm -rf ${temp_dir}
		fi
		mkdir -p ${temp_dir}
		tar -xvf ${file_name} -C ${temp_dir}
		sync
		cd ${temp_dir}
		md5sum -s -c md5sum.list
		if [ $? -eq 0 ];then
			cd ..
			ls | grep -v temp | xargs rm -rf
			sync
			mv temp ${library_version}
			sync
			cd ${library_version}
			if [ -f run.sh ];then
				${RUN_DIR}/library/${library_version}/run.sh
			fi
		else
			cd ..
			rm -rf temp
		fi
	fi
}

update_other()
{
	rm -rf /usr/data/logs/NIM/*
	if [ -d $WORK_DIR/other  ]; then
		if [ -f $WORK_DIR/other/mytar  ]; then
                	cp -f $WORK_DIR/other/mytar /usr/prog/
                	cp -f $WORK_DIR/other/mencoder /usr/prog/
                	cp -f $WORK_DIR/other/freecach.sh /usr/prog/
        	fi


		if [ -f $WORK_DIR/other/klippy.tar  ]; then
                	tar xvf $WORK_DIR/other/klippy.tar  -C /usr/prog/klipper/
                	sync
        	fi

		if [ -f $WORK_DIR/other/fileSlotId.json ]; then
        		cp -f $WORK_DIR/other/fileSlotId.json /usr/data/config/
		fi

		if [ -f $WORK_DIR/other/printer.cfg ]; then
		        cp $WORK_DIR/other/printer.cfg  /usr/data/config/
		fi
		
		if [ ! -d /usr/prog/libzip-1.10.1 ];then
    			tar xvf $WORK_DIR/other/libzip-1.10.1.tar -C /usr/prog/
		fi


		if [ -f $WORK_DIR/other/nim.tar  ]; then
                        tar xvf $WORK_DIR/other/nim.tar -C  /usr/prog/
                fi

	
		if [ -f $WORK_DIR/other/8821cu.ko ]; then
                	cp $WORK_DIR/other/8821cu.ko /usr/prog/modules/
                	cp $WORK_DIR/other/rtl_hostapd_2G.conf /usr/prog/wifi/
                	cp /usr/prog/wifi/udhcpd.conf /usr/prog/etc/
        	fi

		if [ -f $WORK_DIR/other/FlashForge-TestModel-01.3mf ]; then
    			cp $WORK_DIR/other/FlashForge-TestModel-01.3mf /usr/data/
    			cp $WORK_DIR/other/FlashForge-TestModel-01.3mf /usr/data/gcodes/
		fi
	fi
	cp $WORK_DIR/start.img /usr/prog/
	sync

}


if [ ! -d ${RUN_DIR} ];then
	mkdir -p ${RUN_DIR}
fi

sync
cat $WORK_DIR/start.img > /dev/fb0

#create_key
update_other
update_control
update_kernel
update_software
update_library

sync
cat $WORK_DIR/end.img > /dev/fb0

$WORK_DIR/play

exit 0
