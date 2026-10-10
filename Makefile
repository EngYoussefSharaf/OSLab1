dir=/home/os/OSLab1/dir
malicious_dir=/home/os/OSLab1/mal_dir
interval_secs=5
.PHONY: prepare run restore
prepare:
	mkdir -p $(malicious_dir)
	mkdir -p $(dir)
run: prepare
	./antivirusd.sh $(dir) $(malicious_dir) $(interval_secs)
restore:
	./restore.sh $(dir) $(malicious_dir) $(interval_secs)
