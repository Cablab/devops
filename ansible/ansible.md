# Ansible

**Use Cases**

- Automation: automate any system
- Change Management
- Provisoining: setup servers from scratch/cloud
- Orchestration: large scale automation framework

**How Ansible Connects**

Ansible is a Python library. Instead of requiring an agent to be installed on each host like other services (puppet, chef, etc.), you just need to install the Ansible library. Then, the host that you're running Ansible from (control machine) will connect to other servers to make changes.

- Linux: connects over SSH
- Windows: connects over WINRM
- Cloud Server: connects with API requests
- Switch, Router, Database: dependent on destination

## Ansible Architecture

- **Inventory**: A file that contains info about the hosts that will be operated on (IP, username, password, etc)
- **Modules**: sets of operations that can be performed on remote hosts
- **Playbook**: Specifies which modules to run on each host in the inventory

Upon execution, Ansible will create a Python package including all specified modules, put the package onto the remote hosts, run the Python package on the remote host, and return the output

## Setup and Infra

- Commands to setup are available in [Ansible Installation Docs](https://docs.ansible.com/ansible/latest/installation_guide/index.html)
- By default, Ansible has a global inventory file at `/etc/ansible/hosts`. It will use this if you do not have an inventory file in the directory where you are executing jobs
- General structure of custom inventory (see [Inventory File Structure](#inventory-file-structure))
- Ansible will automatically use SSH new host verification prompts, which makes it annoying because you have to confirm that you want to SSH for each new host. You can change this behavior in `/etc/ansible/ansible.cfg` by finding and un-commenting the `host_key_checking = False` line

## Ansible Ad Hoc Commands

- [Ad Hoc Commands Doc](https://docs.ansible.com/ansible/latest/user_guide/intro_adhoc.html)
- Ad hoc commmands general structure:
  - `ansible -i <path-to-inventory> -m <module-to-run> -a "<module-arguments>" <hostname/group-name/all>`
  - You can specify a single host in the inventory, a full group, or use `all` to run on all hosts
- You can add `--become` at the end of the ad-hoc command to elevate privileges during execution on remote host (like saying `sudo`)
- [Built-in Ad Hoc Command Modules](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)
- [Common Collection Modules](https://docs.ansible.com/ansible/latest/collections/index.html#list-of-collections)

## Playbooks

- Playbooks written in YAML format
- Run a playbook with `ansible-playbook -i <path-to-inventory> <path-to-playbook>`
  - You can check if the YAML syntax of a playbook is valid by adding `--syntax-check`
  - Do a no-op dryrun by adding `-C` to the end of the execution command
  - Get 2 levels of verbose output with `-vv`, 3 levels with `-vvv`, 4 levels with `-vvvv`
- See [Playbook File Structure](#playbook-file-structure) and [exercises/web-db.yaml](exercises/web-db.yaml) for examples
  - Also see [YAML vs JSON Comparison Notes](yaml-json-compare.md) for JSON structure comparison

## Ansible Configuration

- [Ansible Configuration Settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.htm)
- Default file in `/etc/ansible/ansible.cfg`
- Order of Ansible configuration priority:
  - `ANSIBLE_CONFIG=<path-to-file>` environment variable
  - `ansible.cfg` file in current directory
    - This one is easiest to set up at repo level so everyone can use it
  - `~/.ansible.cfg` in home directory
  - `/etc/ansible/ansible.cfg` default settings
- **Global Settings** to understand:
  - `forks` - how many machines to connect to at the same time
  - `host_key_checking` - if True, will prompt confirmation when connecting to a remote host for the first time
  - `log_path = <path-to-logfile>` - sets a file for logging
- See example of custom config file in [exercises/ansible.cfg](exercises/ansible.cfg)

## Variables

- There are a few places you can include variables:
  - Inside the playbook file as part of the task object
  - Individual files in the directory
    - `group_vars/all` sets variables that everyone can use
    - `group_vars/<groupname>` sets variables for a specific group
    - `host_vars/<hostname>` sets variables for a specific host
- Additionally, when a playbook is run, the first thing that actually happens is that Ansible uses the `setup` module to gather `Fact` variables
- You can also store output from a task in usable variables
  - Do this by setting `register: <variable-name>` in the highest level of a given task. You can then use `<variable-name>` as a variable in subsequent tasks
  - If the output captured in a varible is JSON, you can access child fields with the `.` accessor
- Order of Variable preference:
  - ENV variables set during cli execution with `-e` (like `ansible-playbook -e USER=cliuser <playbook-file>`)
  - Variables set in the playbook
  - Variables set in `host_vars/<hostname>`
  - Variables set in `group_vars/<group_name>`
  - Variables set in `group_vars/all`

## Fact Variables and Setup Module

- You can see what facts get gathered at setup by running setup ad hoc, like `ansible -m setup <hostname>`
- You can disable this running by adding `gather_facts: False` into any Play level of an Ansible playbook
- Anything that gets returned by `-m setup` can be used as a variable in a playbook
  - The values are returned as JSON and can be accessed that way as well. For example, if a fact you want to use is returned with nested objects inside, you can use the standard `parent.child.child` dot access for JSON
  - Similarly, you can access list/array values by index with `parent.child[i]`

## Decision Making, Loops, and More

- You can run tasks only when a certain condition is met by setting `when: <condition>` at the task level. Example: `when: ansible_distribution == "Ubuntu"` will only do the task on Ubuntu hosts
- To do a loop, add a `loop:` object at the task level that contains a list of items. The task will loop over each item in the list and set the `{{ item }}` variable's value to be the current item
- See examples in [exercises/provisioning.yaml](exercises/provisioning.yaml)

## File Copying, Template Modules

- If you want a custom file setup on your remote hosts (like overriding an installed service's config file to have settings that are not just default), one of the easiest ways to do it is to make a custom template file
- Templates must go in a `./templates/` directory off of where the playbook is, and template files must end in `j2` extension
- Copy the default file, save it in `./templates/<template-file>.j2`, make the changes locally, and use the Ansible playbook to install the custom version of the file you created
- Template files can also take advantage of variables declared in `./group_vars/all`

## Handlers

- Handlers ([see docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html)) are used so that you don't have to repeat actions every time you run Ansible
- For example, you might restart services (like httpd) when there have been file or configuration changes. If you write a task to restart a service, it'll run every time since it's just set to restart
- A **Handler** is essentially a task that only gets run when called from a different task. In the example above, you only really need to restart httpd if a newer config or file was detected and installed on the host. If there were no changes necessary (nothing to update), the handler doesn't get called
- Setup:
  - Create a `handlers:` block at the same level as the `tasks:` block, but declared after tasks.
  - Code each `handler` identically to how you'd code a `task`
  - In the `task` that you want to call a `handler`, add a `notify:` block at the task-level and pass it a list of handlers to call. Each item in the list should be equal to `<value>` of the `name: <value>` part of the handler

## Roles

- See [Roles Docs](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- With Roles, you create a `./roles/` directory. Inside of the `./roles/` directory, you can run `ansible-galaxy init <role-name>` to automatically set up the structure for each role
- The file structure for each role separates tasks, handlers, templates, files, variables, defaults (lower priority variables), libraries, module utilities, and lookup plugins
- Separation by role: with Roles, tasks only run for their respective roles instead of all tasks running on all hosts and doing checks to skip
- Separation by file: with Roles, since the playbook is broken out and everything is defined separately, the playbook is no longer 1 giant, monolithic file that gets hard to manage
- See example with [roles-playbook.yaml](exercises/roles-playbook.yaml) and [./roles/](exercises/roles/)
- Users can upload premade roles at [Ansible Galaxy](https://galaxy.ansible.com/). If you find a role you like, you can install it easily with commands found in the role on the website

## Ansible for AWS

- [Ansible for AWS Guide Docs](https://docs.ansible.com/ansible/latest/collections/amazon/aws/docsite/guide_aws.html) and the [Amazon.AWS Ansible Module Collection](https://docs.ansible.com/ansible/latest/collections/amazon/aws/index.html#plugins-in-amazon-aws)
- Ansible requires exporting ENVs of an IAM user that has programmatic access to your AWS account, so create an IAM user that has the access you want to give to Ansible, grab the keys, and set the ENVs
- Since Ansible runs on Python, there may be some Python packages that are required to be installed as dependencies so that the AWS Ansible module works. This will show in the output if the Ansible run fails, but it's likely `boto` or `boto3`
- Once you've authenticated properly, you can run tasks against the `localhost` host using modules from the Amazon.AWS collection and it'll work
- You may want output for certain commands (like creating keypairs so you can get/store the private key), so make sure to capture output to registers and handle them appropriately
- See [exercises/aws-playbook.yaml](exercises/aws-playbook.yaml) for examples

## Modules

- See available modules grouped by service type at [Ansible Module Index Docs](https://docs.ansible.com/ansible/2.7/modules/modules_by_category.html)
- [Built-in Ad Hoc Command Modules](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html)

### Debug Module

- As a task, you can call the `debug` module to print information to the console during execution. Some examples are:

```yaml
  tasks:
  - debug:
    var: dbname # print a variable name
  - debug:
    msg: "Value of dbuser is {{ dbuser }}" # print a specific message
```

## Inventory File Structure

```bash
# Structure
<remote-hostname> ansible_host=<remote-host-IP> ansible_user=<remote-host-login-user> ansible_ssh_private_key_file=<path-to-ssh-key-for-remote-user>

[group_name] # don't use hyphens, use underscores
<remote-hostname>
<remote-hostname>

[group_of_groups_name:children]
<group_name>
<group_name>

[group_name:vars]
<variable_name>=<variable-value>
```

### Example

```bash
                            # host-level variables defined at group-level below
web01 ansible_host=10.2.3.4 # ansible_user=devops ansible_ssh_private_key_file=~/.ssh/devops-ssh-key
web02 ansible_host=10.2.3.5 # ansible_user=devops ansible_ssh_private_key_file=~/.ssh/devops-ssh-key

[web_server_group]
web01
web02

[dc_seattle:children]
web_server_group

[web_server_group:vars]
ansible_user=devops
ansible_ssh_private_key_file=~/.ssh/devops-ssh-key
```

- If global group variables and host-level variable both exist, the host-level variables have higher precedence and will be used

## Playbook File Structure

- See [YAML vs JSON Comparison Notes](yaml-json-compare.md) for JSON equivalent to compare

```yaml
---
# First Play
- name: Update web servers
  hosts: webservers
  remote_user: root

  tasks:
  # Task 1
  - name: Ensure apache is at the latest version
    ansible.builtin.yum: # collection name and module to run
      name: httpd        # a parameter of the module
      state: latest      # another parameter of the module

  # Task 2
  - name: Write the apache config file
    ansible.builtin.template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

- name: Update db servers
  hosts: databases
  remote_user: root

  tasks:
  - name: Ensure postgresql is at the latest version
    ansible.builtin.yum:
      name: postgresql
      state: latest
  - name: Ensure that postgresql is started
    ansible.builtin.service:
      name: postgresql
      state: started
```
