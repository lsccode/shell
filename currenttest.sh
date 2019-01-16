#!/bin/sh
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
