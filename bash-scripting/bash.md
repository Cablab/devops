# Bash Scripting

For this section, I will be practicing writing bash scripts. My scripts will go in [/scripts/practice/](../scripts/practice/). For reference on how the scripts should end up looking, scripts from the instructor were provided and will be stored in [/scripts/pratice/from-instructor/](../scripts/practice/from-instructor/)

## Scripting

- First line is `#!/bin/bash`, which gives the path to the interpreter that should be used to run the contents of the `.sh` shell file
  - `#!` is a character pronounced `shebang`

## System Variables

- `$0` - The name of the script
- `$1` - `$9` - The first 9 arguments passed 
- `$#` - Number of arguments passed
- `$@` - All arguments passed
- `$?` - Exit status of most recently run process
- `$$` - Process ID of current script
- `$USER` - username of user running the script
- `$HOSTNAME` - name of machine running the script
- `$SECONDS` - number of seconds passed since script started
- `$RANDOM` - Returns a random number each time it's used
- `$LINENO` - Returns the current line number in the Bash script

## Quotation Marks

- Single quotes (`'`) remove the meaning of special characters. For example, if `COLOR=blue`, doing `echo "I like $COLOR"` will print `I like blue`. But, if you use `echo 'I like $COLOR`, it will print `I like $COLOR`. 
- To deal with this, you can put print statements in double quotes and use an escape squenct (`\`) in front of any special characters that you want to be printed literally

## Command Substitution

- You can take the output from executing a command and store it in a variable by wrapping the command in backticks or in `$()`.
- Doing `USER=$(who)` will run the `who` command and store its output in the `USER` variable
- For an example, see [6_command_subs.sh](../scripts/practice/from-instructor/6_command_subs.sh)

## Exporting Variables

- The `/etc/profile` is a global profile that gets sourced anytime somebody opens a shell

## User Input

- Read user input with `read <VARIABLE_NAME>`. Whatever the use types will get saved in the variable specified
  - You can make a prompt with `read -p 'Prompt Message: ' <VARIABLE_NAME>`
  - You can make a prompt but not show what the user is typing (like for passwords) with `-sp`

## Boolean Operators

- `! <expression>` - Negates the expression
- `-n <STRING>` - True if the length of `<STRING>` >= 0
- `-z <STRING>` - True if the `<STRING>` is empty (length 0)
- `=` - Equality check for STRINGs
- `!=` - Not Equality check for STRINGs
- `-eq` - Equality check for INTEGERS
- `-gt` - Greater Than for INTEGERS
- `-lt` - Less Than for INTEGERS
- `-d <FILE>` - True if `<FILE>` exists and it's a directory
- `-f <FILE>` - True if `<FILE>` exists
- `s <FILE>` - True if `<FILE>` exists and it's size is greater than 0 (not empty)
- `-w <FILE>` - True if `<FILE>` exists and write permission is granted
- `-x <FILE>` - True if `<FILE>` exists and execute permission is granted

## Simple System Monitoring Script + CRON

- When a `systemd` service is running, it should create a `<service-name>.pid` file in its `/var/run/<service-name>/` directory. You can check if a service is running by checking for that file. For `httpd`, you'd check `ls /var/run/httpd/httpd.pid`
  - When the service stops, it'll delete the file. So the file is only present when running
- If you run that `ls` command and the file doesn't exist, the `ls` command will have a failure exit (because it can't find the file). This means that the value of `$?` will have that failure status
- We can make a script to check for the file, check the exit status of the `ls` command, and start the service if it's stopped
  - Alternatively, you can just directly check if the file exists with `-f <FILE>`
- When the script is ready, you can create a `cron` job to run the script as often as you'd like. You can even store the output in a log somewhere, and now you have a monitoring service with logs.

### Cron Formatting

- Run `crontab -e` to open a file that contains cronjobs stored on the host
- Each line is a differnt job
- The format is `<time-when-job-should-run> <command to run>`
  - Time format is given in `MM HH DOM mm DOW`
    - `MM` - Minute of the hour. So, `27` would run at `XX:27`
    - `HH` - Hour (in military time). So, `18` would run at 6pm
    - `DOM` - Day of Month. So, `13` would run on the 13th of each month
    - `DOW` - Day of Week. Sunday = 0, Saturday = 6
  - You can put `*` in a time value to have it run every possible time for that entry
  - You can give ranges, like for day of week. `1-5` would run Mon-Fri
- When specifying a cron job, you can also direct output. This is a good way to keep log files

### Cron Monitoring Example

- Take [12_monit.sh](../scripts/practice/from-instructor/12_monit.sh), which checks if the `httpd` service is running and attempts to start it if it's not
- Create a cronjob to have it run every minute and redirect its output to a log file. The cron job entry would look like this: `* * * * * <path-to>/11_monit.sh &>> /var/log/monit_httpd.log`

## Password Authentication

- If you try to SSH onto a host and it won't let you sign in with password (just rejects immediately because of publickey), look in `/etc/ssh/sshd_config` for a line that says `PasswordAuthentication no`. If you change it to `PasswordAuthentication yes` and `restart sshd`, you can SSH with password

## Remote Command Execution

- You can run commands on remote hosts without actually SSHing onto them by passing a command into the SSH command. `ssh user@hostname <command-to-run>`. It'll connect, run the command, and bring you back to where you were
- If you do password-based login, you'll have to enter your password each time
- SSH keys are more secure anyway. Create an SSH key pair with `ssh-keygen`. This will create a public key (`.pub`) and private key (no extension) in the `~/.ssh` directory.
  - These work like lock and key. The public SSH key file is a lock that you can give to anybody you want. You keep the private SSH key file and it acts as a key that can open the public lock you've given out
- Send a copy of your public key to a remote host with `ssh-copy-id <user>@<hostname>`
