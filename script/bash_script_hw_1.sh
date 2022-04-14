#!/bin/bash
#######################################
# Homework: #1
# Owner: Bilkevych Borys
# Group: DevOps
#######################################

# Debugging system
set -e #-x

# Arguments | Args
PARAM=$1
FILE=$2

#######################################
# Check the existing of the file
# Two possible flags: -f and --filename
# Check the the accuracy of extension
# Correct example: "*.csv"
# sudo or root user
#######################################
function file_validation () {
	if [[ $EUID -ne 0 ]]; then
		echo "INFO: Use the sudo command or run it as root";
	fi

	case "$PARAM" in
		-f|--filename )
			echo "INFO: $PARAM is possible to use";;
		* )
			echo "ERROR: Incorrect command flag";
			exit 1
	esac
	
	if [[ -f "$FILE" ]] ; then
		echo "INFO: $FILE exists";
	else
		echo "ERROR: The current file does not exist";
		exit 1
	fi
	
	if [[ "$FILE" == *.csv ]]; then 
		echo "INFO: File extension is correct";
	else
		echo "ERROR: File extension is not correct";
		exit 1 
	fi
}

#######################################
# Check for existing of /backup folder:
# If yes: continue, if no: create
#######################################
function create_backup_folder () {
	if [[ -d "/backup" ]]; then
		echo -e "INFO: The backup folder has been already created\n";
	else
		mkdir /backup
	fi
}

#######################################
# Output the information after:
# Creating user and Adding to group
#######################################
function stdout_info () {
    # print in STD UKRAINE date, user_name and following groups for him
    echo $(TZ=UTC-2 date +%d::%m::%y:%H:%M) \
	"$date $user_name was created and add to following group $group_names"
}

#######################################
# BONUS:
# Create a backup of the user's dir
# And Add it to /backup dir by cron
# Set a timestamp: every 00:00
# Implement it by tar 
#######################################
function crontab_exists() {
	crontab -l 2>/dev/null | grep -q "$user_name" >/dev/null 2>/dev/null
}

function backups_users_dir () {
	# check if the user need backup
	backup=$(echo "${line_array[$(( $argument_count -1 ))]}")
	# exclude the useless chars "all letters and digits"
	backup=$(echo "$backup" | tr -cd '[:alnum:]._-')

	# additional check to avoid the looping
    if ! crontab_exists "$user_name"; then
        # create a crontab for users backup
		if [ "$backup" == "backup" ]; then
			crontab -l 2>/dev/null \
			| { cat; echo "0 0 * * * tar -zcf /backup/${user_name}.tar.gz /home/${user_name}"; } \
			| crontab -
		fi
    fi
}

#######################################
# Create a user
# Set the random password for him
#######################################
function create_user_and_group () {
	# create a random password
	passwd=$(echo $RANDOM | date | sha256sum | base64 | head -c 32; echo)
	# encrypt the password
	encrypted_passwd=$(perl -e 'print crypt($ARGV[0], "password")' "$passwd")
	# add user with password and name
	useradd -m -p "$encrypted_passwd" "$user_name"

	group_names=""
	# go over all the groups between 1 and -1
	for (( i=1; i<$(( argument_count - 1 )); i++ )); do
		# name of the group with double quotes
		group="${line_array[$i]}"
		#delete all the useful chars
		group=$(echo "$group" | tr -cd '[:alnum:]._-')
			
		# create groups and add users to them
		groupadd -f "$group"
		usermod -a -G "$group" "$user_name"
		group_names+=" $group"
	done

	stdout_info "$user_name" "$group_names"
}

#######################################
# Read the *.csv file
#######################################
function read_csv_file () {
	# read line by line from .csv file
	while read -r line || [ -n "$line" ]; do
		# using split by comma and write it to array
		IFS=','; read -ra line_array <<< "$line"

		# set a user name the first elem of array
		user_name=${line_array[0]}
		# number of elements 4 or 3
		argument_count=${#line_array[@]}

		# call the function Create User, Group and Backup
		backups_users_dir "$user_name" "${line_array[@]}"
		create_user_and_group "$user_name"
	done < "$FILE"
}

# start the Program
file_validation "$PARAM" "$FILE"
create_backup_folder
read_csv_file "$FILE"

