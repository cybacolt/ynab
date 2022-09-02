#!/bin/bash

mkdir -p processed

for i in `ls -1 transactions/*`; do
	echo $i
	timestamp=`date +"%Y-%m-%d %H:%M:%S"`
	o=`./ynab.sh last-used transactions $i 2>&1`
	echo "$timestamp $i $o" >> transactions.log
	mv $i processed

	#keeps under rate limit of 200req/h
	sleep 18
done
