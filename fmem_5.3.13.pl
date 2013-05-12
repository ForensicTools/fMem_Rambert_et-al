# Theodore Rambert, Gabe Kahen, Tim Lam
# Fmem Script
# Version 1.0.0
# Released Under the MIT License
# Uses Fmem (GPL), Perl (GPL), DD (GPLv3+) & Tk (BSD-style)



#!/usr/local/bin/perl
use strict;
use warnings;
use Tk;
use Tk::DirTree;

my($memsize, $curr_dir);

#starting directory
$curr_dir = '/';

#check our rights
if (index(`whoami`, "root") < 0)
{
	warn "[Error] Must be run as root.\n";
	exit;
}

#check for fmem
if (index(`stat /dev/fmem 2>&1`, "cannot stat") >= 0)
{
	warn "[Error] Fmem not found.\n";
	warn "You can download it from http://hysteria.sk/~niekt0/foriana/fmem_current.tgz\n";
	exit;
}

#pull the amount of installed RAM from logs
my $raw_mem_start = `free -m | grep Mem | awk '{ print \$2}'`;
warn "[Info] Raw memory line: $raw_mem_start";
$memsize = $raw_mem_start;
#$memsize = substr($raw_mem_start, index($raw_mem_start, "/") + 1);
#my $raw_mem_end = index($memsize, "available");
#$memsize = substr($memsize, 0, $raw_mem_end - 2) / 1024;

#create the file browsing window, then hide it
my $top = new MainWindow;
$top->withdraw;

#Create Window
my $mw = MainWindow->new;

my $w = $mw->Frame->pack(-side => 'top', -fill => 'x');

#Save To?
$w->Label(-text => "Destination:")->
			pack(-side => 'left', -anchor => 'e');

$w->Entry(-textvariable => \$curr_dir)->
    		pack(-side => 'left', -anchor => 'e', -fill => 'x', -expand => 1);

$w->Button(-text => "Choose", -command => \&dir)->
			pack(-side=> 'left', -anchor => 'e');

#Size?
my $w2 = $mw->Frame->pack(-side => 'top', -fill => 'x');


$w2->Label(-text => "Size in MB:")->
			pack(-side => 'left', -anchor => 'e');

$w2->Entry(-textvariable => \$memsize)->
    			pack(-side => 'left', -anchor => 'e', -fill => 'x', -expand => 1);

#Fancy Buttons
my $w3 = $mw->Frame->pack(-side => 'top', -fill => 'x');
$w3->Button(-text => "Copy", -command => \&mem, qw/-background cyan/)->
    			pack(-side => 'left');
$w3->Button(-text => "Exit", -command => \&quit, qw/-background red/)->
			pack(-side => 'right', -anchor => 'w');


MainLoop;

sub mem 
{

	#If filename or memsize isn't defined || not a file || if memsize is not a positive number
	if(!defined $curr_dir || !defined $memsize  || !($memsize =~ /^[+]?\d+$/))
	{
		warn "[Error] Undefined directory or memory size\n";
	} 
	else
	{
		my $date = `date`;
		$date =~ s/\s//g;
		$curr_dir .= "/$date\_memory.dd";
		warn "[Info] Writing to: $curr_dir\n";
		warn "[Info] Running: dd if=/dev/fmem of=$curr_dir bs=1M count=$memsize conv=noerror,sync\n";
		my $output = `dd if=/dev/fmem of=$curr_dir bs=1M count=$memsize conv=noerror,sync 2>/dev/null`;
	}
}
sub quit
{
	exit;
}

sub dir
{
	$top = new MainWindow;
	$top->withdraw;
	#create the window...
	my $t = $top->Toplevel;
	$t->title("Choose Output Folder");
	my $ok = 0;

	my $f = $t->Frame->pack(-fill => "x", -side => "bottom");
	my $d;
	$d = $t->Scrolled('DirTree',
		              -scrollbars => 'osoe',
		              -width => 35,
		              -height => 20,
		              -selectmode => 'browse',
		              -exportselection =>1,
		              -browsecmd => sub { $curr_dir = shift },
		              -command => sub { $ok = 1; },
		             )->pack(-fill => "both", -expand => 1);

	$d->chdir($curr_dir);
	$f->Button(-text => 'Ok',
		       -command => sub { $top->destroy; }) ->pack(-side => 'left');;
}
