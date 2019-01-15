#!/bin/sh
localIP="127.0.0.1"
localVersionID=""
localVersionFile="/etc/upinfo.cfg"
configUpgradeIP="none"
configUpgradeVersionID="none"
configUpgradePackage="none"
configUpgradePackageMd5="none"

destFirmDir="/media/firmware/"
destApp="/"

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
sed -i '/^#.*/d' $2
sed -i '/^[[:space:]]*$/d'  $2
sed -i 's/[[:space:]]*//g'  $2
sync

# get current maching update info
getUpdateInfo()
{
        local readCount=0;
        while read localstring
        do
                let indexStart=0
                indexStart=`expr index "$localstring" "["`

                if [ "$indexStart" == 1 ];then
                        let indexStart+=1
                        indexEnd=`expr index "$localstring" "]"`
                        let strLenth=$indexEnd-$indexStart;
                        configUpgradeIP=`expr substr "$localstring" $indexStart $strLenth`
                        continue;
                fi

                let indexStart=0
                indexStart=`expr index "$localstring" "="`

                if [ "$indexStart" -ne "0" ];then
                        fieldString=`expr substr "$localstring" 1 $indexStart`
                        fileLength=`expr length $fieldString`
                        let fileLength+=1
                        #echo -e "fieldString  $fieldString $fileLength "
                        if [ "$fieldString" == "version_id=" ]
                        then
                                configUpgradeVersionID=`expr substr "$localstring" $fileLength 60`
                        elif [ "$fieldString" == "upgrade_package=" ]
                        then
                                configUpgradePackage=`expr substr "$localstring" $fileLength 60`
                        elif [ "$fieldString" == "upgrade_package_md5=" ]
                        then
                                configUpgradePackageMd5=`expr substr "$localstring" $fileLength 60`			
                        else
                                echo "not a valid"
                        fi
                fi
                let indexStart=0
                let readCount+=1
                if [ $readCount -eq 3 ]
                then
						if [ "$configUpgradeIP" == "$localIP" ];then
							return 0;
						fi	
                        let readCount=0
                fi
                #echo ""
        done<$1

        return 0;
 
} 

getUpdateInfo $2

#  print current file update info
echo "configUpgradeIP :$configUpgradeIP"
echo "configUpgradeVersionID :$configUpgradeVersionID"
echo "configUpgradePackage :$configUpgradePackage"
echo "configUpgradePackageMd5 :$configUpgradePackageMd5"
echo ""

if [ -f "$localVersionFile" ];then
	localVersionID=`cat $localVersionFile`
fi

if [ "$configUpgradeIP" == "none" ];then
	echo "configUpgradeIP is none"
	return 1
fi

if [ "$configUpgradeVersionID" == "none" ];then
	echo "configUpgradeVersionID is none"
	return 1
fi

if [ "$configUpgradePackage" == "none" ];then
	echo "configUpgradePackage is none"
	return 1
fi

if [ "$configUpgradePackageMd5" == "none" ];then
	echo "configUpgradePackageMd5 is none"
	return 1
fi 

if [ "$localVersionID" == "$configUpgradeVersionID" ];then
	echo "local version is up to date"
	return 1
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


