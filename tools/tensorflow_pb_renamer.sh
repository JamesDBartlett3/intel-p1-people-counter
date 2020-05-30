#!/bin/bash
for file in */*.pb
do
	if [[ $file =~ ^(.*)_2018_01_28 ]]
	then
		mv "$file" "${file%%/*}/${BASH_REMATCH[1]}_2018_01_28".pb
	fi
done
