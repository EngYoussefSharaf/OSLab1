#!/bin/bash
dir="$1"
malicious_dir="$2"
interval_secs="$3"
function scan {}
ls -l "$dir" > dictionary-info.last
scan
while true
do
	ls -l "$dir" > dictionary-info.new
	if ! cmp -s dictionary-info.last dictionary-info.new
	then
		scan
		cp dictionary-info.new dictionary-info.last
	fi
	sleep "$interval_secs"
done
