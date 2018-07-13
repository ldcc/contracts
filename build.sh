#!/usr/bin/env bash

out="$PWD/$1/out/"
if [ ! -d $out ]; then
    mkdir -p $out
else
    rm $out/*
fi

solc --bin --abi -o $out "$1"/"$1".sol