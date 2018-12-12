#!/usr/bin/perl
use v5.10;
use strict;
use warnings;
use Net::SSH::Expect;
use Spreadsheet::Read;

my $workbook = ReadData("AP Config Sample Data.xlsx");
my @col_letter = ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H');
my @rows = Spreadsheet::Read::rows($workbook->[1]);
my $enableconfig; #variable for enabling configuration
my $enable24; #variable for enabling 2.4Ghz configuration
my $message; #variable for output error messages
my $error; #variable to know when error occurs

print("IP address of controller: ");
my $controller = "172.19.4.24";#<STDIN>;
chomp $controller;

print("Username: ");
my $user = "netserv";#<STDIN>;
chomp $user;

print("Password: ");
my $password = "CU!hotTP";#<STDIN>;
chomp $password;

my $outfile = "out.log";

#Open SSH connection to controller and run commands
my $ssh = Net::SSH::Expect->new(
	host => $controller,
	password => $password,
	user => $user,
	raw_pty => 1,
	timeout => 3,
	log_file => $outfile,
    exp_debug => 0,
    exp_internal => 0,
);

my $login_prompt = "\r\n\r\n(Cisco Controller) \r\nUser: ";
my $password_prompt = "\rPassword:";

$ssh->run_ssh();
say("Sending username and password...");
my $execuser = $ssh->exec($user);

$ssh->waitfor("(Cisco Controller)") or ($ssh->close and die "Wrong username or password.");
$ssh->send("\n");
$ssh->waitfor("Password:") or ($ssh->close and die "Wrong username or password.");
$ssh->send($user);
$ssh->send($password);
$ssh->waitfor(">") or ($ssh->close and die "Wrong username or password.");

foreach my $i (2 .. scalar @rows) {

	print("."); #lets user know program is still running

	#reset flags
	$enableconfig = 1;
	$error = 0;

	#disable 5 Ghz AP
	$ssh->send("config 802.11a disable " . $workbook->[1]{$col_letter[0].$i});
	
	#error checking
	$ssh->waitfor("invalid", 0.25) and $error = 1;
	$ssh->waitfor("HELP", 0.25) and $error = 1;
	$ssh->waitfor("Invalid", 0.25) and $error = 1;
	if ($error == 1) { #print error and go to next AP if AP name is wrong
		$message = "AP name \"" . $workbook->[1]{$col_letter[0].$i} . "\" is invalid"
		. " (cell " . $col_letter[0].$i . ")" . " Skipping to next AP...";
		print("\n");
		say($message);
		$enableconfig = 0;
		$error = 0;
	}
	
	$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
	
	if ($enableconfig == 1) { #only executes with no AP name error
	
		#configure 5 Ghz channel
		$ssh->send("config 802.11a channel ap " . 
			$workbook->[1]{$col_letter[0].$i} . " " .
			$workbook->[1]{$col_letter[3].$i});
		$ssh->waitfor("Unable", 0.25) and $error = 1;
		if ($error == 1) {
			$message = "AP channel is invalid"
			. " (cell " . $col_letter[3].$i . ")";
			print("\n");
			say($message);
			$error = 0;
		}
		$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
			
		#configure 5 Ghz power
		$ssh->send("config 802.11a txPower ap " . 
			$workbook->[1]{$col_letter[0].$i} . " " .
			$workbook->[1]{$col_letter[4].$i});
		$ssh->waitfor("Invalid", 0.25) and $error = 1;
		if ($error == 1) {
			$message = "AP power level is invalid"
			. " (cell " . $col_letter[4].$i . ")";
			print("\n");
			say($message);
			$error = 0;
		}
		$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
			
		#enable 5 Ghz AP
		$ssh->send("config 802.11a enable " . $workbook->[1]{$col_letter[0].$i});
		$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
		
		#set 2.4Ghz channels
		$enable24 = 1;
		
		#disable 2.4 Ghz AP
		$ssh->send("config 802.11-abgn disable " . $workbook->[1]{$col_letter[0].$i});
		$ssh->waitfor("does not", 0.25) and $enable24 = 0;
		$ssh->waitfor("invalid", 0.25) and $enable24 = 0;
		$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
			
		#only does 2.4Ghz if available
		if ($enable24 == 1) {	
			#configure 2.4 Ghz channel
			$ssh->send("config 802.11-abgn channel ap " . 
				$workbook->[1]{$col_letter[0].$i} . " " .
				$workbook->[1]{$col_letter[6].$i});
			$ssh->waitfor("XOR", 0.25) and $error = 1;
			if ($error == 1) {
				$ssh->send("config 802.11-abgn role " . 
					$workbook->[1]{$col_letter[0].$i} .
					" manual client-serving");
				$ssh->send("config 802.11-abgn channel ap " . 
					$workbook->[1]{$col_letter[0].$i} . " " .
					$workbook->[1]{$col_letter[6].$i});
				$error = 0;
			}
			$ssh->waitfor("Unable", 0.25) and $error = 1;
			if ($error == 1) {
				$message = "AP channel is invalid"
				. " (cell " . $col_letter[6].$i . ")";
				print("\n");
				say($message);
				$error = 0;
			}
			$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
				
			#configure 2.4 Ghz power
			$ssh->send("config 802.11-abgn txPower ap " . 
				$workbook->[1]{$col_letter[0].$i} . " " .
				$workbook->[1]{$col_letter[7].$i});
			$ssh->waitfor("Invalid", 0.25) and $error = 1;
			if ($error == 1) {
				$message = "AP power level is invalid"
				. " (cell " . $col_letter[7].$i . ")";
				print("\n");
				say($message);
				$error = 0;
			}
			$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
				
			#enable 2.4 Ghz AP
			$ssh->send("config 802.11-abgn enable " . $workbook->[1]{$col_letter[0].$i});
			$ssh->waitfor(">") or ($ssh->close and die "Unknown error");
		} else {
			$message = "\nWarning: 2.4Ghz radio not configurable for "
				. "AP in cell " . $col_letter[0].$i . ".";
			say($message);
		}
	}
}

$ssh->close;
print("\n\n");
say("AP configuration complete. Check output for possible errors.\n");

	


