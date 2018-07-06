#!/usr/bin/perl

use strict;
use JSON;
use IO::Socket::INET;
use Data::Dumper;
use Switch;

my $claymore_host = '127.0.0.1';
my $claymore_port = '3333';

my ($socket,$client_socket);


$socket = new IO::Socket::INET (
  PeerHost => $claymore_host,
  PeerPort => $claymore_port,
  Proto => 'tcp',
  ) or die "ERROR in Socket Creation : $!\n";

my $request = '{"id":0,"jsonrpc":"2.0","method":"miner_getstat1"}';
print $socket "$request\n";
my $data = <$socket>;
$socket->close();
my $json = decode_json $data;
my (%stat,@cards);

if (exists $json->{'result'}) {

  my @cldata = @{ $json->{'result'} };
  $stat{miner_version} =  "$cldata[0]";
  $stat{runtime} = $cldata[1]*60;
  my @total_hashrate = split(';', $cldata[2]);
  foreach my $i (@total_hashrate) { if ($i eq 'off') { $i=0; } }
  $stat{total_eth_hashrate} = $total_hashrate[0];
  $stat{eth_shares} = $total_hashrate[1];
  $stat{eth_shares_rejected} = $total_hashrate[2];

  my @detailed_hashrate = split(';', $cldata[3]);
  foreach my $i (@detailed_hashrate) { if ($i eq 'off') { $i=0; } }

  my @total_dcr_hashrate = split(';', $cldata[4]);
  foreach my $i (@total_dcr_hashrate) { if ($i eq 'off') { $i=0; } }
  $stat{total_dcr_hashrate} = $total_dcr_hashrate[0];
  $stat{dcr_shares} = $total_dcr_hashrate[1];
  $stat{dcr_shares_rejected} = $total_dcr_hashrate[2];

  my @detailed_dcr_hashrate = split(';', $cldata[5]);
  foreach my $i (@detailed_dcr_hashrate) { if ($i eq 'off') { $i=0; } }

  my @temperature_fan = split(';', $cldata[6]);

  my @mining_pool = split(';', $cldata[7]);
  $stat{eth_mining_pool} = $mining_pool[0];
  if (scalar (@mining_pool) > 1) { 
    $stat{dcr_mining_pool} = $mining_pool[1];
  }
  my @pool_details = split(';', $cldata[8]);
  $stat{eth_invalid_shares} = $pool_details[0];
  $stat{eth_pool_switches} = $pool_details[1];
  $stat{dcr_invalid_shares} = $pool_details[2];
  $stat{dcr_pool_switches} = $pool_details[3];

  for my $i (0..$#detailed_hashrate) {
    my %card = ( 
      card => $i+1,
      eth_hashrate => $detailed_hashrate[$i], 
      dcr_hashrate => $detailed_dcr_hashrate[$i],
      temperature => $temperature_fan[$i*2],
      fanspeed => $temperature_fan[$i*2+1] );
    push( @cards, \%card );    
  }
} else {
  my @cldata = ();
}

sub print_info
{
  print "{\n";
  print "\t\"data\":[\n\n";
  for my $key ( keys %stat ) {
    print "\t\t\"{#" . uc($key) . "}\":\"" . $stat{$key} . "\",\n";
  }
  print "\n\t]\n";
  print "}\n";
}

sub print_cards
{
  print "{\n";
  print "\t\"data\":[\n\n";
  
  my $first = 1;
  foreach my $card ( @cards ) {
    my %c = %$card;
    print ",\n" if not $first;
    $first = 0;
    print "\t\t{\n";
    for my $key ( keys %c ) {
      print "\t\t\t\"{#" . uc($key) . "}\":\"" . $c{$key} . "\",\n";
    }
    print "\t\t}";
  }
  print "\n\t]\n";
  print "}\n";
}

sub print_card
{
  my $num = $_[0];
  print "{\n";
  print "\t\"data\":[\n\n";
  foreach my $card ( @cards ) {
    my %c = %$card;
    if ($num == $c{card}) {
      for my $key ( keys %c ) {
        print "\t\t\"{#" . uc($key) . "}\":\"" . $c{$key} . "\",\n";
      }
    } 
  }
  print "\n\t]\n";
  print "}\n";
}

switch ($ARGV[0]) {
  case "info" {
    print_info;
  } 
  case "cards" {
    print_cards;
  }
  case "card" {
    print_card($ARGV[1]);
  }
  else { print "\n"; }
}

