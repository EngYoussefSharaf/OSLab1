#!/bin/bash
dir="$1"
malicious_dir="$2"
while true
do
	num=0
	for file in "$malicious_dir"/*
	do
		let num+=1
		echo "$num- $i"
	done
	echo "Pick file by number:"
	read file_num
	if [[ "$file_num" -le "$num" ]]
	then
		count=0
		for file in "$malicious_dir"/*
		do
			let count+=1
			if [[ "$count" -eq "$num" ]]
			then
				echo "input 1: Restore this file back into dir (it was a false positive)"
				echo "Input 2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
				echo "Input 3: Leave this file as-is and go back to the list"
				input choice
				if [[ "$choice" -eq 1 ]]
				then
					cp "$file" "$dir"/$(basename "$file")
					rm "$file"
				fi
				if [[ "$choice" -eq 2 ]]
                                then
					rm "$file"
                              	fi
			fi
		done
	fi
done
