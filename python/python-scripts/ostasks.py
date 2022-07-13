#!/usr/bin/python3
import os

userlist = ['alpha', 'beta', 'gamma']
print("Adding users to system")
print("-------------------------------------")

# Loop to add user from userlist
for user in userlist:
    exit_code = os.system(f"id {user}")
    if exit_code != 0:
        print(f"User {user} does not exist. Adding...")
        print("-------------------------------------")
        os.system(f"useradd {user}")
    else:
        print(f"User {user} already exists.")
        print("-------------------------------------")

# Check if group exists, add if it doesn't
group = "science"
exit_code = os.system(f"grep {group} /etc/group")
if exit_code != 0:
    print(f"Group {group} does not exist. Adding...")
    print("-------------------------------------")
    os.system(f"groupadd {group}")
else:
    print(f"Group {group} already exists.")
    print("-------------------------------------")

# Add users into group
for user in userlist:
    print(f"Adding user {user} into the {group} group")
    print("-------------------------------------")
    os.system(f"usermod -G {group} {user}")

# Create a directory that "science" group owns
dir = "/opt/science_dir"
print(f"Adding {dir} directory for {group} group ownership")
print("-------------------------------------")

if os.path.isdir(dir):
    print(f"Directory {dir} already exists")
else:
    os.mkdir(dir)

# Setting ownership for directory
print(f"Assigning permission and ownership of {dir} to {group} group")
print("-------------------------------------")
os.system(f"chown :{group} {dir}")
os.system(f"chmod 770 {dir}")