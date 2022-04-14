# Linux Bash

Linux Bash. DevOps. 

## Requirements (for the Bash script):

1. Accepts named arguments --filename and -f.
2. The script terminates if one of the commands returns an error.
3. If the file does not have a .csv prefix, the script should return an error.
4. The script should create a user with a random password.
5. The script should create a group, if it already exists, the script should not execute with an error.
6. Add users to the appropriate groups.
7. After creating the user name and adding it to the group, print [INFO] to stdout:
<dd::mm::yy:HH:MM> <username> has been created and added to the next group <group_name>.
8. Add to the script the ability to back up the /home directory of users. The /backup directory on crone, every day at 00:00 user directory is archived with tar, gz compression format.

## How was this solved?

Using ```set -e``` to output the error, if necessary, and the two global variables ```PARAM``` - first argument and ```FILE``` - second argument.

My bash script was divided into different logical parts (functions) that have their own logic inside. 
The list of functions created is as follows:
- ```file_validation ()``` - consists of different types of checks:
  - whether the first argument is "-f or --filename"
  - if the second argument is a file or not
  - if the command is run as root, or if the command starts with sudo
  - file extension ".csv". 
- ```create_backup_folder ()```- used to create a backup folder for users who need to create a backup according to our .csv file.
- ```stdout_info ()``` - this function outputs stdout[INFO] after creating a username and adding it to a group
- ```crontab_exists ()``` - this makes a special check to see if crontabs exist for users. The following checks are required if someone runs a bash script more than 1 time.
- ```backups_users_dir ()``` - this function is used to create a special cron for users who need backups. The function has been tested, the cron works.
- ```create_user_and_group ()``` - the function checks the existence of the user. I implemented a random password relative to the date. Created new groups and added users to them from our .csv file, then called the function srdout_info to return the information about the user.
- ```read_csv_file ()``` - used to read the .csv file and separate the lines with commas.