# 🐧 Linux Commands Cheat Sheet

A quick reference guide for essential Linux commands.

---

## 📁 File Commands

| Command | Description |
|---------|-------------|
| `ls -al` | List all files (including hidden). |
| `pwd` | Show current directory path. |
| `mkdir directory` | Create a new directory. |
| `rm file` | Delete a file. |
| `rm -r directory` | Delete directory recursively. |
| `rm -f file` | Force remove without prompting. |
| `cp file1 file2` | Copy file1 to file2. |
| `cp -r dir1 dir2` | Copy directory recursively. |
| `mv file1 file2` | Rename or move file. |
| `ln -s file link` | Create symbolic link. |
| `touch file` | Create empty file / update timestamp. |
| `cat file` | Output file contents. |
| `less file` | View file with pagination. |
| `head file` | View first 10 lines. |
| `tail file` | View last 10 lines. |
| `tail -f file` | Follow file as it grows. |

---

## 🗂️ Directory Navigation

| Command | Description |
|---------|-------------|
| `cd ..` | Go up one directory level. |
| `cd` | Go to home directory. |
| `cd /test` | Change to /test directory. |

---

## 🔍 Searching

| Command | Description |
|---------|-------------|
| `grep pattern files` | Search for pattern in files. |
| `grep -r pattern dir` | Search recursively in directory. |
| `command \| grep pattern` | Search in command output. |
| `locate file` | Find all instances of a file. |

---

## 📦 Compression / Archiving

| Command | Description |
|---------|-------------|
| `tar cf archive.tar files` | Create tar archive. |
| `tar xf archive.tar` | Extract tar file. |
| `tar czf archive.tar.gz files` | Create gzipped tar. |
| `tar xzf archive.tar.gz` | Extract gzipped tar. |
| `gzip file` | Compress file to .gz. |

---

## ⚙️ Process Management

| Command | Description |
|---------|-------------|
| `top` | Display and manage top processes. |
| `htop` | Interactive process viewer. |
| `ps aux` | View all running processes. |
| `ps -ef` | View all processes (standard format). |
| `ps aux \| grep process_name` | Find specific process ID (PID). |
| `kill pid` | Kill process by PID. |
| `killall process_name` | Kill all processes by name. |
| `bg` | Send process to background. |
| `fg` | Bring process to foreground. |


---

## 🔐 File Permissions

| Command | Description |
|---------|-------------|
| `chmod 777 file` | RWX for everyone. |
| `chmod 755 file` | RWX for owner, RX for others. |
| `chmod 644 file` | RW for owner, R for others. |
| `chown user:group file` | Change file ownership. |

---

## 🌐 Network

| Command | Description |
|---------|-------------|
| `ip addr show` | Display IP addresses & interfaces. |
| `ip route show` | Display routing table. |
| `ping host` | Send ICMP echo request. |
| `whois domain` | Get whois info for domain. |
| `dig domain` | Get DNS info. |
| `host domain` | Resolve domain to IP. |
| `wget url` | Download file from web. |
| `curl url` | Send request & display output. |
| `netstat -pnltu` | View all listening ports. |

---

## 🖥️ Hardware Information

| Command | Description |
|---------|-------------|
| `dmesg` | View boot and system messages. |
| `cat /proc/cpuinfo` | Display CPU information. |
| `cat /proc/meminfo` | Display memory information. |
| `free -h` | Show free and used memory (human-readable). |
| `lsblk` | List block devices (disks and partitions). |
| `lspci -tv` | List PCI devices in tree format. |
| `lsusb -tv` | List USB devices in tree format. |
| `dmidecode` | View hardware info from BIOS. |
| `hdparm -i /dev/sda` | Show disk info. |
| `hdparm -tT /dev/sda` | Read speed test on disk. |
| `badblocks -s /dev/sda` | Test for unreadable blocks. |

---

## 📚 Credits

This cheat sheet is inspired by the excellent work of **Rabin Tunlier**. See the [original post on Reddit](https://www.reddit.com/r/linux/comments/b4khut/basic_linux_commands/) for more details.

