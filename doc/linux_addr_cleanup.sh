#!/bin/bash

for s in $(seq 1 3);
do
	for i in $(seq 0 255);
	do
		ip addr del 10.$s.$s.$i/32 dev lo
	done
done
