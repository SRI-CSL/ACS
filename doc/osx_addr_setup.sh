#!/bin/bash

for s in $(seq 1 1);
do
	for i in $(seq 0 255);
	do
		ifconfig lo0 alias 10.$s.$s.$i/32 up
	done
done
