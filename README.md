# Disable User Shell Script

This shell script that allows for a local Linux account to be disabled, deleted, and optionally archived.

#### Options
Allows the user to specify the following options:
-d Deletes accounts instead of disabling them.
-r Removes the home directory associated with the account(s).
-a Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /home/ARCHIVE_DIR directory. 
Any other option will cause the script to display a usage statement and exit with an exit status of 1.



```sh
chmod +755 disable-local-user.sh

./disable-local-user.sh
```
