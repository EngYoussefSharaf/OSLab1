#!/bin/bash
dir="$1"
malicious_dir="$2"
interval_secs="$3"
touch whiteList.txt
function scan {
	for file in "$dir"/*
	do
		if  grep -qxFs "$file" whiteList.txt
		then
			continue
		fi
		if [[ "$file" == *.ps1 ]] || [[ "$file" == *.scr ]] || [[ "$file" == *.vbs ]] || [[ "$file" == *.bat ]] || [[ "$file" == *.exe ]] || grep -Eqis "virus|trojan|malware|worm|ransomware" "$file" 
		then
			echo "$file is malicious and it is DELETED"
			cp "$file" "$malicious_dir/$(basename "$file")"
			rm "$file"
		fi
	done
}
ls -l "$dir" > directory-info.last
scan
while true
do
	ls -l "$dir" > directory-info.new
	if ! cmp -s directory-info.last directory-info.new
	then
		scan
		ls -l "$dir" > directory-info.last
	fi
	sleep "$interval_secs"
done
