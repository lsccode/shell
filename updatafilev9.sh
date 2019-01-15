#!/bin/sh
localIP="127.0.0.1"
checkFileConfigIP="127.0.0.1"
updateFileVersionID="version_id"
updateFileImgLoc="img"
updateFileMd5="md5"

localIP=`ifconfig eth0 | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}'`
#localIP=`ifconfig enp0s8 | grep "inet " | awk '{ print $2}'`
echo "$localIP"

if [ "$#" -ne "2" ]; then
    echo "usage: $0 <tftp server ip> <checkfile name>"
    exit 2
fi

tftp -gr $2 $1

sed -i '/^#.*/d' $2
sed -i '/^[[:space:]]*$/d'  $2
sed -i 's/[[:space:]]*//g'  $2
sync

getUpdateInfo()
{
        local readCount=0;
        while read localstring
        do
                let indexStart=0
                echo "localstring = $localstring"
                indexStart=`expr index "$localstring" "["`
                #echo "indexStart = $indexStart"

                if [ "$indexStart" == 1 ];then
                        let indexStart+=1
                        indexEnd=`expr index "$localstring" "]"`
                        let strLenth=$indexEnd-$indexStart;
                        #checkFileConfigIP=${localstring:$indexStart-1:$strLenth}
                        #echo "checkFileConfigIP :$checkFileConfigIP"
                        checkFileConfigIP=`expr substr "$localstring" $indexStart $strLenth`
                        #echo "expr substr $localstring $indexStart $strLenth"
                        #echo "checkFileConfigIP :$checkFileConfigIP"
                        continue;
                fi

                let indexStart=0
                indexStart=`expr index "$localstring" "="`
                #echo "expr indexStart = "$indexStart""
                if [ "$indexStart" -ne "0" ];then
                        fieldString=`expr substr "$localstring" 1 $indexStart`
                        fileLength=`expr length $fieldString`
                        let fileLength+=1
                        #echo -e "fieldString  $fieldString $fileLength "

                        if [ "$fieldString" == "version_id=" ]
                        then
                                updateFileVersionID=`expr substr "$localstring" $fileLength 60`
                        elif [ "$fieldString" == "img_location=" ]
                        then
                                updateFileImgLoc=`expr substr "$localstring" $fileLength 60`
                        elif [ "$fieldString" == "md5=" ]
                        then
                                updateFileMd5=`expr substr "$localstring" $fileLength 60`
                        else
                                echo "not a valid"
                        fi
                fi
                let indexStart=0
                let readCount+=1
                if [ $readCount -eq 3 ]
                then
                        echo "checkFileConfigIP :$checkFileConfigIP"
                        echo "updateFileVersionID :$updateFileVersionID"
                        echo "updateFileImgLoc :$updateFileImgLoc"
                        echo "updateFileMd5 :$updateFileMd5"
                        echo ""
                        let readCount=0
                fi
                #echo ""
        done<$1

        return 0;
 
} 

getUpdateInfo $2

# while true
# do
        # getUpdateInfo $2
        # if [ $? -ne 0 ];then
                # exit 1
        # fi

# done
# echo "localIP :$localIP"
# echo "checkFileConfigIP :$checkFileConfigIP"
# echo "updateFileVersionID :$updateFileVersionID"
# echo "updateFileImgLoc :$updateFileImgLoc"
# echo "updateFileMd5 :$updateFileMd5"