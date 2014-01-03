#!/usr/bin/perl
use 5.14.2;
use strict;
use warnings;
use JSON;
use Lingua::Han::PinYin;

my @city_arr;
my %city;

my $h2p = Lingua::Han::PinYin->new();

chdir "$ENV{HOME}/desktop-plugins/weather/city_native";
for my $file (<*.json>) {
	open my $json_f,$file or die $!;
	while ( my $line = <$json_f> ){
		my $json_href = from_json($line);
		for (keys $json_href){
			my $sub_href =  $json_href->{$_};
			my $name1 = $sub_href->{name};
			#push @city_arr,$name1;

			my $data_href = $sub_href->{data};
			for (keys $data_href){
				my $city_href = $data_href->{$_};
				my $name2 = $city_href->{name};

				my $city_data_href = $city_href->{data};
				for (keys $city_data_href){
					 my $sub_city_href = $city_data_href->{$_};
 					 my $name3 = $sub_city_href->{name};
					 push @city_arr,"$name3,$name2,$name1";
				}
				
			}
		}
	}
	close $json_f;
}

my %city_py_han;
for (@city_arr ){
	my $pinyin = $h2p->han2pinyin($_);
	$city_py_han{$pinyin} = $_;
}

for (sort keys %city_py_han){
	say $_,':',$city_py_han{$_};
}
