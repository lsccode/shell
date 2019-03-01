#!/bin/sh

if [ "$#" -ne "1" ]; then
    echo "usage: $0 fileSourceDir"
    exit 1
fi

fileType='-name *.cpp -o -name *.h -o -name *.c -o -name *.hpp'

find $1 $fileType | xargs sed -i 's/,\([a-zA-Z0-9]\)/, \1/g'  # add space between para
find $1 $fileType | xargs sed -i 's#\t#    #g'   # subset space
find $1 $fileType | xargs sed -i 's#while(#while (#g'   # while( ->  while (                             
find $1 $fileType | xargs sed -i 's#for(#for (#g'       # for( ->  for ( 
find $1 $fileType | xargs sed -i 's#if(#if (#g'         # if( ->  for ( 
find $1 $fileType | xargs sed -i 's#switch(#switch (#g'  # switch( -> switch (
find $1 $fileType | xargs sed -i 's/\([a-zA-Z0-9]\)=/\1 =/g' # xxx= -> xxx = 
find $1 $fileType | xargs sed -i 's/=\([a-zA-Z0-9]\)/= \1/g' # =xxx -> = xxx 