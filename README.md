# linux_create_users

Objective

In order to ease the process of user management such as user and group creation, administrator can use create_users.sh script to deploy multuple users in short time manner.

Detailed design

The tool can be run from usb stick or copy to the local file system to user home directory together with the list file.
Super user privileges are needed when running the script.

Some preparation is needed before running the tool. 
First create file, suffix or file name is not of importance but the actual formatting is.
Any user added in the file should have the format:

1:user1:group1:user one:/bin/bash

2:user1:group2,group3

In order to be properly parsed the following rules apply:
If user belongs only to one group (primary) number 1  needs to be put on front followed by  the “username” the “group”, “comment” and “shell”   
If the user is part in more than one group number 2  needs to be put on front followed by the “username” and the “group” each group separated by comma..

In order to create the primary groups for loop is running and checking which line starts with 1 in the beginning and runs groupadd on the result. 
For the users there is while loop which checks lines starting with 1 as they are the one which have the primary group. usermod  is run to create users and the primary group, comments (like platform_team) and the shell.
On the end the last while loop make sure that users are added in the proper secondary group or groups.

Once the users are created it will go and setup default password. Each user will be prompted to change the password upon first login.


# last_pass_change.sh
last_pass_change.sh shows the number of days when user password was changed.
If a user password was not changed >=90 days the script will report
the following:
date=2015-12-11;time=10-14;User=testuser;action=expired;lastChange=122d
If password  is about to expire, the last 9 days (80-89) will report:
date=2015-12-11;time=10-14;User=testuser;action=will_expired;lastChage=87d
