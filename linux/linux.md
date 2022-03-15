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

## Root User

- Become root user with `sudo -i`
- Root user should have `#` prompt, normal user will have `$` prompt (at least in CentOS)
  - If the user is in their home directory, a `~` will be displayed near the end of the prompt as well

## File System

- Use the `-p` flag with `mkdir` to make the entire directory structure as input

## VIM

- Comes installed on Ubuntu, needs to be installed on CentOS

**Modes**:
- Command Mode (VIM launches in this by default)
- Insert mode (editing)
- Extended command mode (acessed with `:`)

### Helfpul Commands

- `:se nu` shows line numbers
- `shift+G` goes to the last line
- `gg` goes to the first line
- `yy` to copy line where cursor is
- `#yy` to copy # lines starting with the one where the cursor is
- `p` to paste below, `P` to paste above
- `dd` and `#dd` to cut in the same way as copy
- `u` to undo
- `#w` move cursor forward # words
- `#b` move cursor backwards n words
- `x` to delete (like `DEL` char)
- `/` and the search term (like `/network`) to search
- `:%s/term1/term2` replaces instances of `term1` with `term2`
  - This only replaces the first instance in each line. To replace everywhere, you do add `/g` at the end. Like `:%s/term1/term2/g`

## File Types

Everything in Linux is a file!

- Can run `file <path-to-file>` to see what kind of file something is
- When you run `ls -l`, the first character in the permissions sections says what kind of file something is
  - `-` is a file
  - `d` is a directory
  - `c` is a character file (keyboard)
  - `b` is a block file (disk)
  - `l` is a link (shortcuts)
  - `s` is a socket
  - `p` is a pipe

### Links

- Create a soft link with `ln -s <path-to-original-file> <path-to-new-link>`
- If the original file is moved, the link becomes dead
- Unlink with `unlink <path-to-link>`

## Hostname

- You can set the hostname of the device with the `/etc/hostname` file
  - If you put somethink like `name1.name2.name3`, only `name1` gets put in the prompt
- Once changes are made, update with `hostname name1.name2.name3`

## Filters

- `<` is the command to input something into a command. It's usually hidden/default
  - For example, `grep -i firewall /etc/config/test.txt` is actually `grep -i firewall < /etc/config/test.txt`
- `grep -R` will search directories as well
- `tail -f` will keep the file open dynamically and show new lines

### awk

- `cut` to `awk` example:
  - `cut -d':' -f1` would be `awk -F':' '{print $1}`
  - In awk, `-F` stands for `field separator`, which is like `delimiter`
  - Also, you `'{print $1}'` to print field 1 instead of doing `-f1`

### sed

- `sed` can operate to search and replace kind of like how you can do inside of `vim` with `:%s/term1/term2/g`
- The command is `sed 's/term1/term2/g' <filename>`
  - This just prints the changes on screen, it does not actually write to file
  - To write the changes to the file(s), pass `-i` to the `sed` command

## Redirecting Input and Output

- Running a command and doing `<command> > <filename>` will write the output to the file, replacing whatever is already there
- Using `<command> >> <filename>` will append the output to the file
- Certain kinds of output can be targeted for rediretion:
  - `1>` or `1>>` is standard output and is used by default
  - `2>` or `2>>` is standard error
  - `&>` or `&>>` is everything
- You can redirect to `/dev/null` to have it go nowhere. It's a black hole 
  - Since `/dev/null` is nothing, you can do `cat /dev/null > <file>` to easily clear a file

## Find and Locate

- You can locate files on the host with `file <base-directory> -flags <search-term>`
  - `file` will recursively search all subdirectories off of the given `base-directory`
  - You can give `-name <search-term>` to look for files 
- `file` is a real-time search, so it can be resource intensive. An alternative is `locate`, which searches from the saved database
  - Install with `sudo yum/apt-get install mlocate`
  - Make sure the database is up to date with `updatedb`
  - Run `locate <search-term>`

## Users and Groups

- Users and Groups are set up to control access to diretories and files
- Every user has a unique **UID** (user ID)
  - Root user has UID 0, Group ID 0, home directory of `/root`, and shell is `/bin/bash`
  - Normal users have UID 1000-60000, Group ID of 1000-60000, home directory of `/home/username`, and shell is `/bin/bash`
  - Service users (ssh, ftp) have UID 1-999, Group ID 1-999, home directory may be `/var/<service>` or `/etc/<service>` if present, and shell is `/sbin/nologin` or `/sbin/false` or something to prevent shell access
- User's name and UID are stored in `/etc/passwd`
  - Format is `<username>:<letter>:<UID>:<Group ID>:<Home Directory>:<Login Shell>`
  - The `<letter>` may be `x`, indicating the user has a record in `/etc/shadow`
  - User's passwords are stored in `/etc/shadow`, but they are encrypted
- Group names and IDs are stored in `/etc/group`
  - Format is `<Group Name>:<letter>:<Group ID>:<Users belonging to group>`

### Commands and Manipulation

- Command `id <user>` gives information about a user on the system
- `useradd <username>` creates a new user on the system
- `groupadd <group name>` creates a new group on the system
- You can add users to a group in multiple ways:
  - `usermod -aG <group name> <username>`
    - The `G` flag makes the group a secondary group for the user
    - The `g` flag makes the group a primary group for the user
  - You can also edit the `/etc/group` file and append a comma separated list of usernames in the last field for the group that you want to add them to
- `passwd <username>` will allow you to create or change a password for a user
- `last` shows logins to the system
- `lsof -u <username>` shows which files a user has opened
- `userdel <username>` deletes a user
  - With no options, the user's home directory stays in place
  - Pass the `-r` flag to also delete the user's home directory
- `groupdel <group name>` deletes the group

## File Permissions

- Permissions on a link are different than the permission on what is being linked to
- On a directory, `x` permissions means you can `cd` into it, `r` means you can `ls` the directory, and `w` means you can modify/delete the directory
- Change ownership of a file with `chown`
  - Format is `chown <flags> <user>:<group> <path-to-file>`
  - You can pass `-R` to recursively change ownership of everything inside a directory
  - The `:<group>` part is optional
- Change permissions of a file with `chmod`
  - Format is `chmod <u/g/o><+ or -><r/w/x> <path-to-file>`
    - Entities are `u` for user, `g` for group, `o` for others
    - Doing `+` adds the permission, doing `-` takes away the permission
  - Another format is `chmod XYZ <path-to-file>`
    - For `XYZ`, `X` is the number for User permissions, `Y` is the number for group permissions, and `Z` is the number for others' permissions
    - The numbers used range from 0-7 and are determined by thinking of `rwx` as a 3-bit number. You put a 1 in the spot of permissions you want the entity to have and a 0 for permissions you want to remove
      - For example, if you want an entity to have permissions `rw-`, that is `110` and would be represented as `6`
    - Setting a file's permission to `-rwxr-xr--` would be `chmod 754 <file>`

## sudo

- Users in the `sudoers` file can use `sudo` before a command to execute it with root permissions
  - File is `/etc/sudoers`. Nobody has permissions to write to the file by default as a security measure, but the root user can edit it with the `visudo` command
  - Find the line that looks like `root ALL=(ALL) ALL` and put a line under it that looks like `<user> ALL=(ALL) ALL`. This will allow that user to execute commands with sudo
- When a user does a `sudo` command, the system will ask the user to enter their password. You can skip this by editing the user's line in `/etc/sudoers` to look like `<user> ALL=(ALL) NOPASSWD: ALL`
  - This may not be the preferred way to do it. Instead, you can create a file in path `/etc/sudoers.d/<username>` and add the `<username> ALL=(ALL) NOPASSWD: ALL` there. The presence of this file with the correct line is functionally the same
  - You can also add a group into the sudoers file with `%<groupname>` in place of `<user>`
- If you make a syntax error while editing the `/etc/sudoers` file, the OS will ask you what to do. You can enter `e` to go back to editing the file

## Package Management
