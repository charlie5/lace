#!/bin/bash

set -e

export OS=Linux

mkdir -p build

rm -fr dsa

mkdir --parents  dsa/x86_64-unknown-linux-gnu/obj

cp /usr/lib/gcc/x86_64-pc-linux-gnu/15.1.1/adalib/a-sttebu.ali \
    dsa/x86_64-unknown-linux-gnu/obj

export Build_Mode=debug
po_gnatdist -P simple_chat.gpr simple_chat.dsa -cargs -g -largs -g

#rm -fr build
#rm -fr dsa
