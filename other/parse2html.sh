#!/bin/bash

csv_file="$1"

IFS=","

while read LINE
do

	for single_ in $LINE
	do
	echo "${single_}->"



	done



done < $csv_file


