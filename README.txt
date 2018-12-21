README.txt

Developed by Basil Lin
Updated 12/20/18

About:
	This script is designed to remotely configure Cisco Access points via SSH through
	a Cisco controller.

Preconditions:
	All Perl dependencies and SSH must first be installed. Timeout value may be adjusted
	for slower connections/equipment.
	The following packages must be installed-
		sudo apt-get upgrade
		sudo apt-get install gcc
		sudo apt-get install perl
		sudo apt-get install cpanminus
		sudo apt-get install cmake
		sudo cpanm install 'Spreadsheet::XLSX'
		sudo cpanm install 'Spreadsheet::ParceExcel'
		sudo cpanm install 'Spreadsheet::Read'
		sudo apt-get install libssh2-1-dev
		sudo cpan look YAML
		sudo cpanm install 'Net::SSH2'
		sudo cpanm install 'Net::SSH::Expect'
		sudo cpanm install 'Cyrpt::PBKDF2'

Example command to copy files:
	cd /mnt/c/Users/netserv/Downloads
	cp -r Config_Script/ /home/basill/ap/

Usage:
	To run: "perl config.pl <Excel_Sheet_Name> <timeout_value>"
	Script will prompt for controller IP address, username, and password.
	Script will default to timeout of 0.2 seconds if <timeout_value> is left empty.
	Check included excel file for configuration format.

Debugging:
	Unknown Error-
		Upon unknown failure, script will exit with line number.
		Unknown failure is often due to timeout value. Increase timeout value as needed.
		Otherwise, unknown failure can also be due to CLI updates.
	AP Config Error-
		Upon problem with excel AP config, script will display erroneous value and skip
		to the next config. Script does not have to be entirely rerun, and can be run
		again just on the erroneous AP.
	Other Warnings-
		Script will skip 2.4GHz configuration if unavailable. Script will print warning
		to stdout.
	Further Debugging -
		Check out.log for dump of SSH I/O


