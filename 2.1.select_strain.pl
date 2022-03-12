use strict;

my %n = ();
my %all = ();
open IN,$ARGV[0];
while(<IN>){
	chomp;
	my @l = split /\t/;
	$n{$l[5]} = $l[3];
	$all{"$l[5]\_str$l[4]"}{$l[6]} = 'A';
}
my %tmp = ();
foreach my $sam(keys %n){
	my $select  = int(rand($n{$sam})) + 1;
	if(exists $all{"$sam\_str$select"}){
		%tmp = %{$all{"$sam\_str$select"}};
		foreach my $pos(keys %tmp){
			print "$sam\t$pos\tA\tstr$select\n";
		}
	}
}
