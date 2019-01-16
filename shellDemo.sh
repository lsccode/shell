#!/bin/sh

#  Shell中变量的原形：${var}
aa='ajax'
echo $aa
echo $aa_AA      #  此句因为不存在aa_AA，所以输出为空
echo ${aa}_AA    #  大括号括起来可识别aa，打印为  ajax_AA


# 批量修改文件名
dst_path=$1
for file in `ls $dst_path`
do
        if [ -d $1/$file ];then 
			echo `$0 $1/$file`    #  此处执行了递归
        elif [ -f $1/$file ]
                then    mv $1/$file $1/${file}._mod
        else
            echo $1/${file} is unknow file type
        fi
 
done;

#  %% % # ## 匹配修改
file="modify_suffix.sh.tar.gz"
echo "${file%%.*}"  # %%右边最长匹配，删除匹配的部分，输出为    modify_suffix
echo "${file%.*}"   #  %右边最短匹配，删除匹配的部分，输出为    modify_suffix.sh.tar
echo "${file#*.}"   #  #为左边最短匹配，删除匹配的部分，输出为  sh.tar.gz
echo "${file##*.}"  #  ##为左边最长匹配，删除匹配的部分，输出为 gz

#  $(cmd), 类似``符号，不过$(cmd) 写法可通过 ‘;’ 分割多个命令

echo $(ls)
cmdoutput=$(ls)
echo ${cmdoutput}

# ()和{}都是对一串的命令进行执行,但有所区别：
# 相同点：
# ()和{}都是把一串的命令放在括号里面,并且命令之间用;号隔开
# 不同点
# ()只是对一串命令重新开一个子shell进行执行,{}对一串命令在当前shell执行
# ()最后一个命令可以不用分号,{}最后一个命令要用分号
# ()里的第一个命令和左边括号不必有空格,{}的第一个命令和左括号之间必须要有一个空格
# ()和{}中括号里面的某个命令的重定向只影响该命令,但括号外的重定向则影响到括号里的所有命令
# 在{}中 第一个命令和{之间必须有空格,结束必须有;
# {}中的修改了$var的值 说明在当前shell执行

var=test
echo $var                 # var 输出 test
(var=notest;echo $var)	  # var 输出变为 notest	
echo $var                 # var 输出保持不变 test
{ var=notest;echo $var;}  # var 输出为 notest
echo $var                 # 大括号输出改变输出 var 变为 notest

{ var1=test1;var2=test2;echo $var1>a;echo $var2;}
cat a

{ var1=test1;var2=test2;echo $var1;echo $var2;}>a
cat a

#  ${var:-string},${var:+string},${var:=string},${var:?string}

# 若变量var为空或者未定义,则用在命令行中用string来替换${var:-string}
# 否则变量var不为空时,则用变量var的值来替换${var:-string}

echo ${a:-bcc}
echo $a
a=ajax
echo ${a:-bcc}
unset a
a=${a:=bbc}
echo $a

# ${var:+string},即只有当var不是空的时候才替换成string,若var为空时则不替换或者说是替换成变量var的值,即空值
a=ajax
echo ${a:+bbc}
echo $a
unset a
echo ${a:+bbc}

# ${var:?string},替换规则:若变量var不为空,则用变量var的值来替换${var:?string},可利用此特性来检查是否设置了变量的值

unset a
#echo ${a:?bbc} # 运行到此行将退出

a=ajax
echo ${a:+`date`}

unset a
echo ${a:-`date`}
echo ${a:-$(date)}

# $((exp)) POSIX标准的扩展计算
# 这种计算是符合C语言的运算符,也就是说只要符合C的运算符都可用在$((exp)),包括三目运算符
# 注意:这种扩展计算是整数型的计算,不支持浮点型和字符串等
# 若是逻辑判断,表达式exp为真则为1,假则为0

unset a
echo $((a=3+2))
echo $a
let $((a++))
#echo $b
echo $a

# 只有在pattern中使用了通配符才能有最长最短的匹配,否则没有最 长最短匹配之分
# 结构中的pattern支持通配符
# * 表示零个或多个任意字符
# ?表示零个或一个任意字符
# [...]表示匹配中括号里面的字符
# [!...]表示不匹配中括号里面的字符

f=a.tar.gz
echo ${f##*.}  # 输出 gz
echo ${f%%.*}  # 输出 a
var=abcdccbbdaa
echo ${var%%d*}  # 输出  abc
echo ${var%d*}  # 输出 abcdccbb 
echo ${var#*d}  # 输出 ccbbdaa
echo ${var##*d} # 输出 aa

#发现输出的内容是var去掉pattern的那部分字符串的值

# == 可用于判断变量是否相等，= 除了可用于判断变量是否相等外，还可以表示赋值。
# = 与 == 在 [ ] 中表示判断(字符串比较)时是等价的，最后两个语句是等价的,例如：
s1="foo"
s2="foo"
[ $s1=$2 ] && echo "equal"
[ $s1==$2 ] && echo "equal"

# 在 (( )) 中 = 表示赋值， == 表示判断(整数比较)，它们不等价，((n=5)) 表示赋值，((n==5)) 表示判断。比如
((n=5))
echo $n
((n==5)) && echo "equal"

#  []
a=abc
if [ $a ];then
	echo "a is not null"
fi

unset a
if [ !$a ];then
	echo "a is null"
fi

# 去除变量中的空格
text=" 123 456 "
echo "$text"
text=${text// /""}
echo ${text}

a='  23423423    '
echo "${a// /}"
a='  2342 3423    '
echo "${a// /}"
a='  2342	3423 '

# '\t'
echo "${a//$'\t'/}"
# 这些方法没有测试，写法参照上面的。
# 去掉尾巴的空格 sed  's/[ \t]*$//g'
# 删除前、后空格，不删除中间空格 sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'
# 删除字符串中所有空格 sed 's/[[:space:]]//g'
text=" 123 456 "
text=`echo $text | sed -e 's/^[ \t]*//g'`

a="  this                 =                    IHave Value  "

if [[ $a =~ "=" ]]; then
#if [[ hest = h??t ]]; then
echo "test..."
fieldtag=${a%%=*}
echo ${#fieldtag}
echo "this is $fieldtag"
fieldvalue=${a##*=}
echo ${#fieldvalue}
echo "this is ${fieldvalue}"
fi

 


