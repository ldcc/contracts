#!/usr/bin/env bash

out="$PWD/out/$1/"
if [ ! -d $out ]; then
    mkdir -p $out
else
    rm $out*
fi

solc --bin --abi -o $out $PWD/$1/$1.sol