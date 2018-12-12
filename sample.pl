#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use Net::SSH2;
use Net::SSH::Expect;

my $file = 'aps.csv';
my @data;
my $controller = "*PROMPT USER*";
my $user = "*PROMPT USER*";
my $password = '*PROMPT USER';
my $command;

#Open file of APs to configure and store in array
open(my $fh, '<', $file) or die "Can't read file '$file' [$!]\n";
while (my $line = <$fh>) {
	chomp $line;
	my @fields = split(/,/, $line);
	push @data, \@fields;
}

#Print array
foreach my $row (@data) {
	foreach my $element (@$row) {
		print $element, "\t";
	}
	print "\n";
}


#Open SSH connection to controller and run commands
my $ssh = Net::SSH::Expect->new(
	host => $controller,
	password => $password,
	user => $user,
	raw_pty => 1
);

my $login_output = $ssh->login();
if($login_output !~ /#/) {
	die "Login has failed. Login output was $login_output";
} else {
	print("Login Successfull!\n");
}

$command = $ssh->exec("configure terminal");

foreach my $row (@data) {
	print("=============================================================================================================================================\n");
	$command = $ssh->exec("configure terminal");
	$ssh->send("ap ${$row}[1]");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("description ${$row}[0]");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("led Dark");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("exit");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("interface Dot11Radio ${$row}[1] 1");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("channel ${$row}[2]");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("exit");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("interface Dot11Radio ${$row}[1] 2");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("channel ${$row}[3]");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$ssh->send("channel-width  40-mhz-extension-channel-above");
	$ssh->waitfor('#\s', 3) or die "prompt '#' not found after 2 seconds.";
	$command = $ssh->exec("end");
	print("$command\n");
	$command = $ssh->exec("show interfaces Dot11Radio ${$row}[1]");
	print("$command\n");
	print("=============================================================================================================================================\n");
}

#Close ssh session
$ssh->close();

#my $command = $ssh->exec("show running-config");
print("Configuration complete.\n");
