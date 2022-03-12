use strict;
open IN,$ARGV[0];
my %n = ();
my %all = ();
while(<IN>){
	chomp;
	my @l = split /\t/;
	$n{$l[5]} = $l[3];
	$all{"$l[5]\_str$l[4]"}{$l[6]} = 'A';
}
my $LEN = 29903;
foreach my $sam(keys %n){
	for(my $i=0;$i<$LEN;$i+=100){
		my $select  = int(rand($n{$sam})) + 1;
		for(my $j=$i;$j<=$i+100;$j++){
			if(exists $all{"$sam\_str$select"}{$j}){
				print "$sam\t$j\tA\tstr$select\n";
			}
		}

	}
}
