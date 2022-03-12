use strict;
open IN,$ARGV[0];
my %all = ();
while(<IN>){
	chomp;
	my @l = split /\t/;
	my ($p1,$p2) = split /-/,$l[0];
	$all{$p1}{$p2} = 1;
	$all{$p2}{$p1} = 1;
}
my @p = keys %all;
my $n_p = $#p +1;
for(my $i=0;$i<@p;$i++){
	my $p1 = $p[$i];
	my %tmp = %{$all{$p1}};
	my @p2 = keys %tmp;
	for(my $j=1;$j<@p2;$j++){
		my $p2 = $p2[$j];
		my %select = ();
		$select{$p1} = 1;$select{$p2} = 1;
		my @select_p = keys %select;


		my $n = 1;
		my $lastn = 0;

		while($n ne $lastn){
			@select_p = keys %select;
			$lastn = $#select_p +1;
			foreach my $p (keys %tmp){
				my $good = 1;
				foreach my $in(keys %select){
					if($in eq $p){next}
					if(!exists $all{$p}{$in}){$good = 0}
				}
				if($good){$select{$p} = 1}
			}
			@select_p = keys %select;
			$n = $#select_p +1;
		}
		@select_p = sort @select_p;
		my $pos = join(";",@select_p);
		print "$i\t$p1\t$p2\t$n\t$pos\n";
	}
}


