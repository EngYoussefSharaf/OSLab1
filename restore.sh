#!/bin/bash
dir="$1"
malicious_dir="$2"
while true
do
	if [[ $(ls "$malicious_dir" | wc -l) -eq 0 ]]
	then
		echo "No malicious files to review."
		exit 0
	else
		echo "Choose a file:"
		num=0
		for file in "$malicious_dir"/*
		do
			let num+=1
			echo "$num- $(basename $file)"
		done
		read file_num
		if [[ "$file_num" -le "$num" ]]
		then
			count=0
			for file in "$malicious_dir"/*
			do
				let count+=1
				if [[ "$count" -eq "$file_num" ]]
				then
					echo "1: Restore this file back into dir (it was a false positive)"
					echo "2: Permanently delete this file from malicious_dir (it was genuinely malicious)"
					echo "3: Go back"
					read choice
					if [[ "$choice" -eq 1 ]]
					then
						cp "$file" "$dir"/$(basename "$file")
						rm "$file"
						echo "Restored $(basename $file) to $dir."
					fi
					if [[ "$choice" -eq 2 ]]
       		                        then
						rm "$file"
						echo "$(basename $file) permanently deleted."
        	                      	fi
				fi
			done
		fi
	fi
done
