# Lab 2: Simple Antivirus

This project has two shell scripts. The first one watches a folder and moves
dangerous-looking files into a quarantine folder. The second one lets me look at
the quarantined files and decide to restore or delete each one.

## Files in this folder

```
OSLab1/
├── antivirusd.sh   # the antivirus (watches a folder)
├── restore.sh      # the restore tool
├── Makefile        # shortcuts to run everything
└── README.md       # this file
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
