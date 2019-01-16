#!/bin/sh
# valueA="		aa =	 bb 	# this is test"
# valueA=${valueA%%#*}
# echo ${#valueA}
# echo "$valueA"
# valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`
# echo ${#valueA}
# echo "$valueA"

# valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
# echo ${#valueA}
# echo "$valueA"

# valueATag=${valueA%% *}
# echo ${#valueATag}
# echo "$valueATag"

# valueAValue=${valueA##* }
# echo ${#valueAValue}
# echo "$valueAValue"

valueA="		aa =	 bb 	# this is test"
valueA=${valueA%%#*}
valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab

valueATag=${valueA%% *}
echo ${#valueATag}
echo "$valueATag"
valueATagLength=${#valueATag}
if [ "$valueATagLength" -ne 0 ];then
	echo "length is not 0"
fi

valueAValue=${valueA##* }
echo ${#valueAValue}
echo "$valueAValue"


valueA="  	#		aa =	 bb 	# this is test"
valueA=${valueA%%#*}
valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`

valueATag=${valueA%% *}
valueATagLength=${#valueATag}

if [ "$valueATagLength" -eq 0 ];then
	echo "length is 0"
fi

valueA="		aa =	 bb 	# this is test"
valueA=${valueA%%#*}
valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab


resultEq=$(echo $valueA | grep "=")
#resultSq=$(echo $valueA | grep "[")

if [ "$resultEq" != "" ] ; then
echo "include = "
valueATag=${valueA%% *}
echo ${#valueATag}
echo "$valueATag"
valueATagLength=${#valueATag}

valueAValue=${valueA##* }
echo ${#valueAValue}
echo "$valueAValue"
fi


echo "no space "
valueA="		aa   =   	bb 	# this is test"

valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
valueA=`echo "$valueA" | sed -e 's/=/ = /g'`  # 替换字符串中的=
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab
valueA=${valueA%%#*}

valueAFirst=${valueA:0:1}
resultEq=$(echo $valueA | grep "=")
echo "first char is $valueAFirst"

if [ "$valueAFirst" == "[" ] ;then
	echo "oh get it"
elif [ "$resultEq" != "" ] ; then
	echo "oh resultEq"
else
	echo "unknown tag"
fi


valueATag=${valueA%% *}
echo ${#valueATag}
echo "$valueATag"
valueATagLength=${#valueATag}
if [ "$valueATagLength" -ne 0 ];then
	echo "length is not 0"
fi

valueAValue=${valueA##* }
echo ${#valueAValue}
echo "$valueAValue"



echo "last version 1"
valueA="	#	aa   =   	bb 	# this is test"

valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
valueA=`echo "$valueA" | sed -e 's/=/ = /g'`  # 替换字符串中的=
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab
valueA=${valueA%%#*}
valueALength=${#valueA}
if [ "$valueALength" -eq 0 ];then
	echo "valueA is  0"
fi



echo "last version 2 "
valueA="  [ 127.0.0.1 ]  # this is test"
valueA=${valueA%%#*}
valueA=`echo "$valueA" | sed -e 's/[\t]/ /g'`  # 替换字符串中的\t
valueA=`echo "$valueA" | sed -e 's/=/ = /g'`  # 替换字符串中的=
valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`  # 去除首尾的空格 tab


valueAFirst=${valueA:0:1}
echo "valueA is ($valueA)first char is $valueAFirst"

if [ "$valueAFirst" == "[" ] ;then
	echo "valueAFirst is [ "
	valueA=${valueA##*[}
	valueA=${valueA%%]*}
	valueA=`echo "$valueA" | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
	echo "$valueA"
elif [ "$resultEq" != "" ] ; then
	echo "oh resultEq"
else
	echo "unknown tag"
fi





