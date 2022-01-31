# Linux Notes

## Linux Principles

- Everything (including hard disks, etc) is considered a file
- Small, single-purpose programs chained together for complex operations
- Avoid Captive User Interface
- Config data stored in text file

**RPM based**: Red Hat, CentOS, Oracle, AWS Linux
- Packages/Software files end in `.rpm`
- Software available from provider (RHEL) only
- Most stable/secure, good for servers

**Debian based**: Ubuntu, Kali
- Open-source packages available from any source
- Because of sourcing and community support, great for automation and DevOps
- Packages/Software files end in `.deb`

## Directory Structure

- `/`, `/root`, `/home/username` - Home Directories
- `/bin`, `/usr/bin`, `/usr/local/bin` - User Executables
  - Commands that are usable by normal users (`cd`, `ls`, etc.)
- `/sbin`, `/usr/sbin`, `/usr/local/sbin` - System Executables
  - Commands only usable by root user (intsalling software, etc)
- `/media`, `/mnt` - Directory mount points (external?)
- `/etc` - Configuration
- `/tmp` - Temporary Files
- `/boot` - Kernels and Bootloader
- `/var`, `/srv` - Server Data
- `/proc`, `/sys` - System Info
- `/lib`, `/usr/lib`, `/usr/local/lib` - Shared Libraries
