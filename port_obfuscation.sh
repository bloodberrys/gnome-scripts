#!/bin/bash

# sudo nc -l 9999 &

# 11000 - 11050
for((i=11000;i<=11050;i++))
do

    sudo nc -l $i &

done

# 11060 - 11100
for((i=11060;i<=11100;i++))
do

    sudo nc -l $i &

done

# 11101 - 11198
for((i=11101;i<=11198;i++))
do

    sudo nc -l $i &

done

# 11200 - 13250

for((i=11200;i<=13250;i++))
do

    sudo nc -l $i &

done


# 14000 - 14699 

for((i=14000;i<=14699;i++))
do

    sudo nc -l $i &

done