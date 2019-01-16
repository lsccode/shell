#!/bin/sh
localIP="127.0.0.1"
localVersionID=""
localVersionFile="/etc/upinfo.cfg"
configUpgradeIP=""
configUpgradeVersionID=""
configUpgradePackage=""
configUpgradePackageMd5=""

#destFirmDir="/media/firmware/"
#destApp="/"

destFirmDir="test/firmware/"
destApp="test/"

#  get local eth0 ip addr
localIP=`ifconfig eth0 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}'`
#localIP=`ifconfig enp0s8 | grep "inet " | awk '{ print $2}'`
echo "local ip is $localIP"

if [ "$#" -ne "2" ]; then
    echo "usage: $0 <tftp server ip> <checkfile name>"
    exit 2
fi

tftp -gr $2 $1

#  pre process file,delete space and comment
FieldTag=""
FieldValue=""
retCode=0

function linePre()
{
	local inputLine=$*
	inputLine=${inputLine%%#*}
	inputLine=`echo "$inputLine" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
	inputLine=`echo "$inputLine" | sed -e 's/=/ = /g'`  # 替换字符串中的=
	inputLine=`echo "$inputLine" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab	
	
	inputFirstChar=${inputLine:0:1}
	resultEq=$(echo $inputLine | grep "=")

	if [ "$inputFirstChar" == "[" ] ;then
		FieldValue=${inputLine##*[}
		FieldValue=${FieldValue%%]*}
		FieldValue=`echo "$FieldValue" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
		retCode=1
		return 0
	elif [ "$resultEq" != "" ] ; then
		FieldTag=${inputLine%% *}
		FieldValue=${inputLine##* }
		retCode=2
		return 0
	else
		# echo "linePre unknown string"
		retCode=0;
		return 0
	fi
	
	return 0
}

# get current maching update info
function getUpdateInfo()
{
        local readCount=0;
        while read localstring
        do
			linePre $localstring
			if [ "$retCode" -eq 1 ]; then
				if [ "$configUpgradeIP" == "$localIP" ]; then
					#  already get ip
					return 0
				else					
					configUpgradeIP=${FieldValue}
					configUpgradeVersionID=""
					configUpgradePackage=""
					configUpgradePackageMd5=""
				fi				
			elif [ "$retCode" -eq 2 ]; then
				if [ "$FieldTag" == "version_id" ]; then
					configUpgradeVersionID=${FieldValue}
				elif [ "$FieldTag" == "upgrade_package" ]; then
					configUpgradePackage=${FieldValue}
				elif [ "$FieldTag" == "upgrade_package_md5" ]; then
					configUpgradePackageMd5=${FieldValue}
				else
					echo "getUpdateInfo unknown tag"
				fi
			else
				echo "getUpdateInfo unkown string"
			fi	
        done<$1

        return 1;
 
} 

getUpdateInfo $2

#  print current file update info
echo "configUpgradeIP :$configUpgradeIP"
echo "configUpgradeVersionID :$configUpgradeVersionID"
echo "configUpgradePackage :$configUpgradePackage"
echo "configUpgradePackageMd5 :$configUpgradePackageMd5"
echo ""

if [ "$configUpgradeIP" != "$localIP" ]; then
	echo "no config info "
	return 1 
fi

if [ "$configUpgradeIP" == "" ] || [ "$configUpgradeVersionID" == "" ] || \
	[ "$configUpgradePackage" == "" ] || [ "$configUpgradePackageMd5" == "" ];then
	echo "configUpgradePara is none"
	return 1
fi

if [ -f "$localVersionFile" ];then
	localVersionID=`cat $localVersionFile`
	
	if [ "$localVersionID" == "$configUpgradeVersionID" ];then
		echo "local version is up to date"
		return 0
	fi
fi


# get xxxx.tgz from tftp server
tftp -gr $configUpgradePackage $1

if [ $? -ne 0 ];then
	echo "download $configUpgradePackage from $1 error!"
	return 1
fi

downUpgradePackageMd5Temp=`md5sum "$configUpgradePackage"`
downUpgradeSp=`expr index "$downUpgradePackageMd5Temp" " "`
let downUpgradeSp-=1
downUpgradePackageMd5=`expr substr "$downUpgradePackageMd5Temp" 1 $downUpgradeSp`

echo "downUpgradePackageMd5 :$configUpgradePackage $downUpgradePackageMd5"

if [ "$downUpgradePackageMd5" == "$configUpgradePackageMd5" ]; then
	echo "check success"
else
	echo "check failed!"
	return 2
fi

echo ""
echo "start upgrad ,wait ... "

#  mount device ,for temp file 
mkdir -p /media/Storage
mount /dev/mmcblk0p7 /media/Storage

#  mount firmware for upgrade
mkdir -p /media/firmware
mount /dev/mmcblk0p5 /media/firmware

mkdir -p /media/Storage/upgrade
unzip -x $configUpgradePackage -d /media/Storage/upgrade/

find /media/Storage/upgrade/ -name "*.bin" | xargs -i cp -rf {} $destFirmDir
find /media/Storage/upgrade/ -name "*.dtb" | xargs -i cp -rf {} $destFirmDir
find /media/Storage/upgrade/ -name "uImage" | xargs -i cp -rf {} $destFirmDir
find /media/Storage/upgrade/ -maxdepth 2 -type d -name "sample" | xargs -i cp -rf {} $destApp

rm -rf /media/Storage/upgrade
umount /media/Storage

umount /media/firmware

echo "$configUpgradeVersionID" > $localVersionFile


