#!/bin/bash

for s in $(seq 1 3);
do
	for i in $(seq 48 63);
	do
		ifconfig lo0 alias 10.$s.$s.$i/32 delete 2>/dev/null
	done
done
