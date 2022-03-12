use strict;
open IN,$ARGV[0];

my %sam = ();
my %all = ();
my %alt = ();
while(<IN>){
	chomp;
	my @l = split /\t/;
	$sam{$l[0]} = 1;
	$all{$l[1]}{$l[0]} = 'A';
	$alt{$l[1]}{'A'} ++;
}

my @pos = keys %all;
my @sam = keys %sam;
my $total = $#sam + 1;

foreach my $pos (@pos){
	my @alt = keys %{$alt{$pos}};
	my $out = '';
	foreach my $alt(@alt){
		$out .= "$alt:$alt{$pos}{$alt};";
		if($alt{$pos}{$alt} < 2 ){delete $all{$pos};}else{
		}
	}
}

my %info = ();
my $info = '';
my $gt = '';
my $ngt = 0;
my ($p1,$p2) = ();
my $out = '';


my @pos = sort {$a<=>$b} keys %all;
for(my $i=0;$i<$#pos;$i++){

	for(my $j=$i+1;$j<@pos;$j++){
		($p1,$p2) = ($pos[$i],$pos[$j]);
		my @alt1 = ('A','R');
		my @alt2 = ('A','R');
		my %count = ();
		my $count = 0;
		%info = ();
		$info = '';

		my @sam1 = keys %{$all{$p1}};
		my @sam2 = keys %{$all{$p2}};
		my %tmp = (%{$all{$p1}},%{$all{$p2}});
		my @sam = keys %tmp;
		$out = '';
		foreach my $sam(@sam){
			if(!exists $all{$p1}{$sam}){$out = 'R'}else{$out = "$all{$p1}{$sam}"}
			if(!exists $all{$p2}{$sam}){$out .= 'R'}else{$out .= "$all{$p2}{$sam}"}
			$count{$out} ++;$count ++;
			$info{$out} .= "$sam;";
		}
		$out = '';
		$count{'RR'} = $total - $count;
		$ngt = 0;
		foreach $gt(sort {$count{$b}<=>$count{$a}} (keys %count)){
			if($count{$gt} > 1){
				$out .= "$gt:$count{$gt};";
				$ngt ++;
			}
		}
		if($ngt eq 4){
			print "$p1-$p2\t$ngt\t$out\n";
		}
	}
}
