#!/bin/bash
for ((i=1;i<=5000;i++)); do echo "Resolution" $i; ./test -2 2 -2 2 $i ; done