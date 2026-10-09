#!/bin/bash
dir="$1"
malicious_dir="$2"
interval_secs="$3"
function scan {
	for file in "$dir"/*
	do
		if [[ "$file" == *.ps1 ]] || [[ "$file" == *.scr ]] || [[ "$file" == *.vbs ]] || [[ "$file" == *.bat ]] || [[ "$file" == *.exe ]] || grep -Eq "virus|trojan|malware|worm|ransomware" "$file"
		then
			echo "$file is malicious and it is DELETED"
			cp "$file" "$malicious_dir/$(basename $file)"
			rm "$file"
		fi
	done
}
ls -l "$dir" > dictionary-info.last
scan
while true
do
	ls -l "$dir" > dictionary-info.new
	if ! cmp -s dictionary-info.last dictionary-info.new
	then
		scan
		ls -l "$dir" > dictionary-info.last
	fi
	sleep "$interval_secs"
done
