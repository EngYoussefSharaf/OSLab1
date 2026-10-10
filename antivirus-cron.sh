#!/bin/bash
sleep 23
dir="$1"
malicious_dir="$2"
for file in "$dir"/*
do
	if [[ "$file" == *.ps1 ]] || [[ "$file" == *.scr ]] || [[ "$file" == *.vbs ]] || [[ "$file" == *.bat ]] || [[ "$file" == *.exe ]] || grep -Eqis "virus|trojan|malware|worm|ransomware" "$file"
	then
		echo "$file is malicious and it is DELETED"
		cp "$file" "$malicious_dir/$(basename "$file")"
		rm "$file"
	fi
done
