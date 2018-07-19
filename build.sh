#!/usr/bin/env bash

out="$PWD/out/$1/"
if [ ! -d $out ]; then
    mkdir -p $out
else
    rm $out*
fi

if [ -n "$2" ]; then
    file="$PWD/$1/$2.sol"
else
    file="$PWD/$1/$1.sol"
fi

solc --bin --abi -o $out $file