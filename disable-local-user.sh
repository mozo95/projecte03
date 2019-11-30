#!/bin/bash

# Display the usage and exit.
usage() {
	echo "Usage: ./disable-local-user.sh [-dra] USER [USERN]
	Disable a local Linux account.
	-d Deletes accounts instead of disabling them.
	-r Removes the home directory associated with the account(s).
	-a Creates an archive of the home directory associated with the
	accounts(s)." 1>&2;
	exit 1;
}

# Parse the options.
while getopts ":dra" opt; do
	case "${opt}" in
		d)
			delete=1
			;;
		r)
			remove=1
			;;
		a)
			archive=1
			;;
		# Remove the options while leaving the remaining arguments.
		*)
			echo "Illegal option"
			usage
			;;
	esac
done

# Make sure the script is being executed with superuser privileges.
if [[ "$EUID" -ne "0" ]]
then
	echo "You dont have privileges."
       	exit 1;
fi

# If the user doesn't supply at least one argument, give them help.
if [[ $# -eq "0" ]]
then
	usage
fi

# Loop through all the usernames supplied as arguments.
for arg in "${@}"
do
    if [[ $arg =~ [-][dra] ]]
    then
        echo "Flags used: $arg"
    else 
	    # Make sure the user exists
	    a=$(id -u "$arg" 2>/dev/null)
	    if [[ $? -eq "1" ]]
	    then
		    echo "id: $arg: no such user"
		    exit 1
	    fi
	    # Make sure the UID of the account is at least 1000.
	    if [[ "$a" -lt "1000" ]]
	    then
	    	echo "Refusing to remove $arg account with UID $a"
	    	exit 1;
	    fi
	    # Create an archive if requested to do so.
	    if [[ $archive -eq "1" ]]
	    then
	    	# Make sure the ARCHIVE_DIR directory exists.
	       	mkdir -p "/home/ARCHIVE_DIR"
	    	# Archive the user's home directory and move it into the ARCHIVE_DIR
	    	tar -zcvf "/home/ARCHIVE_DIR/${arg}.tar.gz" "/home/$arg" &> /dev/null
	    fi
	    if [[ $delete -eq "1" ]]
	    then
	    	# Delete the user.
	    	userdel $arg
	    	# Check to see if the userdel command succeeded.
	    	if [[ $? -eq "0" ]]
	    	then
	    		# We don't want to tell the user that an account was deleted when it hasn't been.
	    		echo "User: $arg deleted successfully."
	    	fi
	    else
	    	chage -E0 $arg
	    	if [[ $? -eq "0" ]]
            then
                # We don't want to tell the user that an account was disabled when it hasn't been.
		    	echo "User: $arg disabled successfully."
		    fi
	    fi
	    if [[ $remove -eq "1" ]]
	    then
	    	rm -r "/home/${arg}" &> /dev/null
	    	if [[ $? -eq "0" ]]
            then
                # We don't want to tell the user that an account's directory was deleted when it hasn't been.
                echo "User: $arg directory deleted successfully."
	    	fi
	    fi
    fi
done
