#!/bin/bash

set -e

rm -fr dsa

export Lace_Build_Mode=debug

gprclean    -r simple_chat.gpr
po_gnatdist -P simple_chat.gpr simple_chat.dsa -cargs -g -largs -g
