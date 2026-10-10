# Lab 2: Simple Antivirus

This project has two shell scripts. The first one watches a folder and moves
dangerous-looking files into a quarantine folder. The second one lets me look at
the quarantined files and decide to restore or delete each one.

## Files in this folder

```
OSLab1/
├── antivirusd.sh      # the antivirus (watches a folder, loops forever)
├── antivirus-cron.sh  # bonus: the same scan, run by cron (one scan, then exit)
├── restore.sh         # the restore tool
├── Makefile           # shortcuts to run everything
└── README.md          # this file
```

## What you need first

Everything is already on Ubuntu except `make`. Install it with:

```bash
sudo apt update
sudo apt install make
```

Then make the scripts runnable (only once):

```bash
chmod +x antivirusd.sh restore.sh
```

## How to run

Open the terminal in this folder.

**1. Start the antivirus**

```bash
make run
```

It creates the quarantine folder if it does not exist, then starts checking the
folder every few seconds. Press `Ctrl+C` to stop it.

**2. Review quarantined files** (after stopping the antivirus)

```bash
make restore
```

You will see a numbered list. Type a number to pick a file, then choose:

- `1` to put the file back (it was safe)
- `2` to delete it for good (it was really bad)
- `3` to go back to the list

**Changing the folders:** the settings are at the top of the Makefile
(`dir`, `malicious_dir`, `interval_secs`). You can also change them in the command:

```bash
make run dir=test_dir malicious_dir=quarantine interval_secs=2
```

**Quick test**

```bash
mkdir test_dir
echo "this is a virus" > test_dir/a.txt
make run dir=test_dir malicious_dir=quarantine interval_secs=2
```

`a.txt` should be reported and moved into `quarantine/`.

Warning: the antivirus deletes files from the watched folder, so test on a
folder you do not care about.

## How the antivirus works

1. It saves a list of the folder (`ls -l`) and scans it right away.
2. Every few seconds it makes a new list and compares it with the old one.
3. If they are the same, it waits. If they are different, it scans again.
4. For each bad file it prints `<file> is malicious and it is DELETED`, copies
   the file to the quarantine folder, and deletes the original.

## Where the bad-file lists are

Both lists are written directly inside the `scan` function in `antivirusd.sh`:

- **Extensions** (`.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`): the five `[[ "$file" == *.ext ]]` checks.
- **Keywords** (`virus`, `trojan`, `malware`, `worm`, `ransomware`): the word
  list inside the `grep -Eqi "..."` command. The `i` makes it ignore capital letters.
  
  
## Bonus 1: Cron job

`antivirus-cron.sh` does the same scan and quarantine as `antivirusd.sh`, but
it scans **once and exits**. There is no `while` loop and no restore menu,
because cron has no terminal for me to type in. Cron is the loop now.

### Prerequisites

- **Cron is installed and running.** Check with `systemctl status cron`. It must
  say `active (running)`. If not, run `sudo systemctl start cron`.
- **The script is executable:** `chmod +x antivirus-cron.sh`. The first line of
  the script must be `#!/bin/bash`.
- **The scan folder and the quarantine folder exist:**
```bash
  mkdir -p /home/os/OSLab1/dir /home/os/OSLab1/mal_dir
```
  If the quarantine folder is missing, `cp` fails but `rm` still runs, so the
  file would be lost.
- **I have permission** to read and delete in `dir`, and to write in `mal_dir`
  and in the log file.
- **I use full paths.** Cron does not start in my project folder, so relative
  paths do not work. Find the home folder with `echo $HOME` and the script's
  full path with `realpath antivirus-cron.sh`.

### Step-by-step: configure the cron job

1. **Test the script by hand first.** If it does not work by hand, it will not
   work in cron.
```bash
   echo "this is a virus" > /home/os/OSLab1/dir/test.txt
   ./antivirus-cron.sh /home/os/OSLab1/dir /home/os/OSLab1/mal_dir
```
   After 23 seconds `test.txt` must be gone from `dir` and be inside `mal_dir`.
2. **Open my crontab:**
```bash
   crontab -e
```
   If it asks for an editor, choose `nano`.
3. **Go to the bottom and add this one line:**
```
   * * * * * /home/os/OSLab1/antivirus-cron.sh /home/os/OSLab1/dir /home/os/OSLab1/mal_dir >> /home/os/OSLab1/antivirus.log 2>&1
```
4. **Save and exit** (in nano: `Ctrl+O`, Enter, `Ctrl+X`).
5. **Check that the line is saved:**
```bash
   crontab -l
```
   The last line must be my job, without `#` at the start.
6. **Test the schedule.** Create a bad file, wait about 1.5 minutes, then check:
```bash
   echo "this is a virus" > /home/os/OSLab1/dir/test2.txt
   ls /home/os/OSLab1/dir        # test2.txt should be gone
   ls /home/os/OSLab1/mal_dir    # test2.txt should be here
   cat /home/os/OSLab1/antivirus.log   # shows "... is malicious and it is DELETED"
```
7. **Stop the job when I finish.** Run `crontab -e` and put `#` at the start of
   the line (or delete the line). Without this, it runs every minute forever.

### How the line works

| Part | Meaning |
|---|---|
| `* * * * *` | minute, hour, day of month, month, day of week: every minute |
| `/home/os/OSLab1/antivirus-cron.sh` | the script (full path) |
| `/home/os/OSLab1/dir` | goes to `$1`, the folder to scan |
| `/home/os/OSLab1/mal_dir` | goes to `$2`, the quarantine folder |
| `>> /home/os/OSLab1/antivirus.log` | adds the normal output to the end of the log file |
| `2>&1` | sends the errors to the same log file |

**Why every minute at second 23?** Cron has no seconds field. Its smallest unit
is one minute, and it starts the job at second 0. So the cron expression is
`* * * * *` and the script has `sleep 23` at the top: it waits 23 seconds and
then scans. The `sleep` is only in the script, not in the crontab line,
otherwise it would wait twice.

### Cron expression: every 3rd Friday of the month at 12:31 am

- 12:31 am is `00:31`, so minute = `31` and hour = `0`.
- Friday is day of week `5`.
- The 3rd Friday of a month is always between day 15 and day 21.

I cannot write `31 0 15-21 * 5`, because when both the day-of-month and the
day-of-week are set, cron runs when **either one** matches. That would run on
every day from 15 to 21 **and** on every Friday. So cron runs every Friday
(`31 0 * * 5`) and the command checks that the day is from 15 to 21:

```
31 0 * * 5 [ "$(date +\%d)" -ge 15 ] && [ "$(date +\%d)" -le 21 ] && /home/os/OSLab1/antivirus-cron.sh /home/os/OSLab1/dir /home/os/OSLab1/mal_dir >> /home/os/OSLab1/antivirus.log 2>&1
```

`date +%d` gives today's day number. In a crontab, `%` has a special meaning, so
it must be written as `\%`.
