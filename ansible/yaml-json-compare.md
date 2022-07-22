# YAML to JSON Comparison

## Spacing Examples

YAML can have lists where each item in the list is an object. The YAML notation for this can be done inline or separated in different lines. Below are examples with JSON equivalents:

**Simple Example**

```yaml
- key1: value1
- 
  key2: value2
```

vs.

```json
[{ "key": "value" },
 {
    "key2": "value2"
 }
]
```

**Full Example**

```yaml
# First object in outer list declared/spacd in line, not on own line
- name: Update web servers
  hosts: webservers
  remote_user: root

  tasks:
  # First task in list declared/spaced in line
  - name: Ensure apache is at the latest version
    ansible.builtin.yum:
      name: httpd
      state: latest
  # Second task in list declared/spaced on its own line
  -
    name: Write the apache config file
    ansible.builtin.template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf

# Second object in outer list declared/spaced on its own line
-
  name: Update db servers
  hosts: databases
  remote_user: root
```

vs.

```json
[
    {
        "name": "Update web servers",
        "hosts": "webservers",
        "remote_user": "root",
        "tasks": [
            {
                "name": "Ensure apache is at the latest version",
                "ansible.builtin.yum": {
                    "name": "httpd",
                    "state": "latest"
                }
            },
            {
                "name": "Write the apache config file",
                "ansible.builtin.template": {
                    "src": "/srv/httpd.j2",
                    "dest": "/etc/httpd.conf"
                }
            }
        ]
    },
    {
        "name": "Update db servers",
        "hosts": "databases",
        "remote_user": "root"
    }
]
```

## Ansible Playbook Examples

**YAML Playbook**

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

**JSON Playbook Equivalent**

```json
[
    {
        "name": "Update web servers",
        "hosts": "webservers",
        "remote_user": "root",
        "tasks": [
            {
                "name": "Ensure apache is at the latest version",
                "ansible.builtin.yum": {
                    "name": "httpd",
                    "state": "latest"
                }
            },
            {
                "name": "Write the apache config file",
                "ansible.builtin.template": {
                    "src": "/srv/httpd.j2",
                    "dest": "/etc/httpd.conf"
                }
            }
        ]
    },
    {
        "name": "Update db servers",
        "hosts": "databases",
        "remote_user": "root",
        "tasks": [
            {
                "name": "Ensure postgresql is at the latest version",
                "ansible.builtin.yum": {
                    "name": "postgresql",
                    "state": "latest"
                }
            },
            {
                "name": "Ensure that postgresql is started",
                "ansible.builtin.service": {
                    "name": "postgresql",
                    "state": "started"
                }
            }
        ]
    }
]
```
