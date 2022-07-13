# Python

## pip

- `pip` is a python package manager. There is `pip` for Python2 and `pip3` for Python3
- If pip isn't natively installed, you can follow [pip Installation Docs](https://pip.pypa.io/en/stable/installation/) to get it installed
  - On Ubuntu use `apt-get install python-pip` and `apt-get install python3-pip`

## Virtual Environments

- You can create virtual environments of Python on your machine
- May need to `pip install virtualenv`
- The benefit of this is that installing dependencies with `pip` in a virtual environment only install to that virtual environment and not the whole system
  - This can be good to have environments with different versions of the same module
- Create a virtual environment in the current directory with `virtualenv <name-of-environment>`
- Change directory into what you just created and you'll see some initial setup files/directories
- In the space, run `source bin/activate` to activate the virtual environment
- Run `deactivate` to end the virtual environment

## Python Syntax

- See [pythons-scripts/syntax.py](python-scripts/syntax.py) for some examples of interesting Python syntax

## Python as a Script

- Python comes installed on Linux, but it may not include python3 by default. You can run `python --version` and `python3 --version` to see what's installed
  - If you need to install one, try `apt search python` or `apt search python3`. You'll probably just want to install one that's just python and the version, like `python3.8`
- You can write python scripts that get executed the same as bash scripts. You just need to put `#!<path/to/python/binary>` at the top of the script so it knows which interpreter to use during execution
  - Standard is usually `#!/usr/bin/python` for Python2 or `#!/usr/bin/python3` for Python3
  - If you don't know the path to the python binary, try `which python` and `which python3`
- To run, just make sure the script is executable and invoke the path of the file
  - Alternatively, you can run `python <script>` or `python3 <script>` to run it yourself

## OS Tasks

- With Python we can automate OS tasks, similarly to how Bash scripts can do the same
- We'll also look at `Fabric`, a Python module that'll make it easy to SSH to other devices and run commands
- For the setup, look at [./vm/Vagrantfile](vm/Vagrantfile) where we created 3 hosts, 1 to run the scripts and 2 to test remote connection and script execution

### OS Module

- `import os` to get the OS module in your Python script
- See documentation at [Python3 OS Docs](https://docs.python.org/3/library/os.html)
- Use `os.system("<os command>")` to run a shell command
  - When run directly in Python prompt, this will return the output and an exit code
- There are lots of other built in commands so you don't have to `os.system("<os command>")` each time. Like `os.chdir()` to change directory

### Fabric module

- Fabric library is not built-in, you need to install it with pip
  - `pip install fabric`
    - For this class we're using a fabric version that's earlier than 2.0, which you can specifically download with `pip install 'fabric<2.0'`
- With fabric, you can create a `fabfile.py` and define functions inside of that file
- Run `fab -l` to see which functions have been defined in fabfiles
- Execute a function from the shell with `fab <function-name>:<arguments>`
- In a `fabfile.py`, do `from fabric.api import *` to import Fabric
- Fabric has a built-in function `local("shell command")` that lets you easily run shell commands
  - This is similar to `os.system("<shell command>")`
- Fabric has a built-in function `run("shell command")` that lets you run commands on a remote host
  - This requires a user existing on the remote host that Fabric can use to login and run commands
  - If Fabric needs root priveleges, remember to add the user to the sudoers file
  - Also make sure that password-based login is enabled
    - This is bad though, so setup key based login with `ssh-keygen` > `ssh-copy-id <user>@<remote-host-IP>` and then turn off password authentication on the remote host
  - Call the Fabric function and specify hostname and username: `fab -H <remote IP> -u <remote user> <fabric-function>:<arguments>`
- Fabric has a built-in function `sudo("<shell command>")` that will escalate privileges
- To pass multiple arguments, use `fab <function-name>:<arg1>,<arg2>`
- If you're running commands on remote hosts, you can also pass multiple hosts at the same time with `fab -H <host-1-IP>,<host-2-IP>`

## Example Scripts

- [./python-scripts/check-file.py](python-scripts/check-file.py) shows how to check if a file/directory exists or not
- [./python-scripts/ostasks.py](python-scripts/ostasks.py) shows how to take a list of users, check if they exist, add them if they don't, create a group and add the users into the group, and create a directory that will have group ownership
- [./python-scripts/fabfile.py](python-scripts/fabfile.py) shows a fabfile for the `Fabric` python module that defines some functions for OS use
