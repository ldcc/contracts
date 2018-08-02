#!/usr/bin/env bash

out="$PWD/out/solidity/$1/"
if [ ! -d $out ]; then
    mkdir -p $out
else
    rm $out*
fi

if [ -n "$2" ]; then
    file="$PWD/Solidity/$1/$2"
else
    file="$PWD/Solidity/$1/$1"
fi

solc --bin --abi -o $out $file.sol