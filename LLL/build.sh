#!/usr/bin/env bash

#out="$PWD/out/lll/$1/"
#if [ ! -d $out ]; then
#    mkdir -p $out
#else
#    rm $out*
#fi

if [ -n "$2" ]; then
    file="$PWD/LLL/$1/$2"
else
    file="$PWD/LLL/$1/$1"
fi

bin=`lllc -x $file.lll`

echo "$bin"