use Math::Random qw(random_poisson);
use strict;

my $LEN = 29903;
#my ($out,$W,$RATE) = ("test_new7",2,0.000003);
my ($out,$W,$RATE) = @ARGV;
open OU,">$out";

#initaite the reference genome sequence at t0
my @ref_seq = ();
my %seq = ();
my %n = ();
for(my $i=0;$i<=$LEN;$i++){
	@ref_seq[$i] = 'R';
}
$seq{'ref'}{'1'} = join("",@ref_seq);
$n{'ref'} = 1;

my %base = ('A'=>'R','R'=>'A');

open LS,'/mnt/disk2_workspace/jiangyiqi/hCoV/code/GISAID20May11.period.stat.tsv';
my $n_p = 0;
my %n_in_p = ();
while(<LS>){
	chomp;
	my @l = split /\s+/;
	$n_in_p{$l[0]} = $l[1];
	$n_p = $l[0];
}

my $period = 10;

my $period_rate = $period * $RATE;

my $n_sam = 0;
my $lastn = 1;
my @p_e = ();
my @p_b = ();
my @p_n = ();
my @m_e = ();
my @m_b = ();

$p_e[0] = 0;
for(my $i=1;$i<=$n_p;$i++){
	print "\nperiod$i start $lastn\n".localtime();
	my @p = random_poisson($lastn, 1);

	my $total_p = 0;
	foreach my $p(@p){
		$total_p += $p;
	}
	#avoid simulate sample number in periods less than the statisticed sample numbers
	if($total_p < $n_in_p{$i}){
		for(my $r = ($n_in_p{$i} - $total_p) + 5;$r > 0;$r --){
			my $rand = int(rand($#p));
			$p[$rand] ++;
		}
	}


	$p_b[$i] = $p_e[$i-1] + 1;
	my $tmp_n = 0;
	my $lasti = $i - 1;
	for(my $j=0;$j<@p;$j++){
		$m_b[$lasti][$j] = $p_b[$i] + $tmp_n;
		$tmp_n += $p[$j] + 1;
		$m_e[$lasti][$j] = $p_b[$i] + $tmp_n - 1;
	}

	$p_e[$i] = $p_b[$i] + $tmp_n - 1;
	$p_n[$i] = $p_e[$i] - $p_b[$i] + 1;
	$lastn = $tmp_n;
}
$n_sam = $p_e[-1];
print "\nsample numer $n_sam\n".localtime();

my %select = ();
my %real_select = ();
my %m = ();
my %p = ();
for(my $i = $n_p;$i > 0;$i--){
	print "\nselect $i start\n".localtime();
	for(my $n = 0;$n < $n_in_p{$i};$n ++){
		my $new = 0;
		while($new == 0){
			my $rand = $p_b[$i] + int(rand($p_n[$i]));
			my $j = $rand;
			my $id = "p$i\_sam$j";
			if(!exists $select{$id}){
				$new = 1;
				$select{$id} = 1;
				my ($lasti,$lastj) = (0,0);

				$lasti = $i - 1;

				my @tmp1 = @{$m_b[$lasti]};
				my @tmp2 = @{$m_e[$lasti]};
				for(my $m_j=0;$m_j<@tmp1;$m_j++){
					if($rand <= $tmp2[$m_j] && $rand >= $tmp1[$m_j]){
						$lastj = $m_j;
						last;
					}
				}
				$real_select{$id} = 1;
				$m{$id} = "p$lasti\_sam$lastj";
				$p{$id} = $i;
				my ($tmp_lasti,$tmp_lastj) = ($lasti,$lastj);
				my ($tmp_j,$tmp_id) = ();
				for(my $tmp_i=$lasti;$tmp_i>0;$tmp_i--){
					$tmp_j = $tmp_lastj;
					$tmp_id = "p$tmp_i\_sam$tmp_j";
					$tmp_lasti = $tmp_i - 1;
					@tmp1 = @{$m_b[$tmp_lasti]};
					@tmp2 = @{$m_e[$tmp_lasti]};
					for(my $tmp_m_j=0;$tmp_m_j<@tmp1;$tmp_m_j++){
						if($tmp_j >= ($tmp1[$tmp_m_j]-$tmp1[0]) && $tmp_j <=($tmp2[$tmp_m_j]-$tmp1[0])){
							$tmp_lastj = $tmp_m_j;
							last;
						}
					}
					$m{$tmp_id} = "p$tmp_lasti\_sam$tmp_lastj";
					$p{$tmp_id} = $tmp_i;
				}
				last;
			}
		}
	}
}
my @select = keys %p;
my $n_select = $#select + 1;
$W = $W - 1;
my @p = random_poisson($n_select, $W);

my $n = 0;
my %select_m = ();
my %select_p = ();
foreach my $select_sam(keys %p){
	$n{$select_sam} = $p[$n] + 1;
	$select_m{$select_sam} = $m{$select_sam};	
	$select_p{$select_sam} = $p{$select_sam};
	$n ++;
}
print "\nmut start\n".localtime();

my $rate = $period_rate;

foreach my $sam(sort {$select_p{$a}<=>$select_p{$b}} keys %select_p){
	my $n = $n{$sam};
	my $source = ();
	if(exists $p{$select_m{$sam}}){
		$source = $select_m{$sam};
	}else{
		$source = 'ref';
	}
	my @n_source = ();
	my $n_source = 0;
	@n_source = keys %{$seq{$source}};
	$n_source = $#n_source +1;
	
	my %tmp_seq = ();
	my @sam = ();

	for(my $new = 1;$new <= $n;$new ++){
		my $real_new = 0;
		my $select_n_source  = int(rand($n_source)) + 1;
		my @seq = split //,$seq{$source}{$select_n_source};
		while($real_new eq 0){
			@sam = &mut_seq2($rate,@seq);
			my $new_seq = join("",@sam);
			if(!exists $tmp_seq{$new_seq}){
				$real_new = 1;
				$seq{$sam}{$new} = $new_seq;
				$tmp_seq{$new_seq} = 1;
			}
		}
		#print mutation position in selected samples
		if(exists $real_select{$sam}){
			for(my $r = 0;$r < @ref_seq;$r ++){
				if($sam[$r] ne $ref_seq[$r]){
					print OU "$n{$source}\t$select_n_source\t$source\t$n\t$new\t$sam\t$r\t$ref_seq[$r]\t$sam[$r]\n";

				}
			}
		}
	}
}
sub mut_seq{
        (my $rate, my @sam) = @_;
        for(my $p=0;$p<@sam;$p++){
                my $rand = int(rand(int(1/$rate)));
                if($rand == 0){
                        $sam[$p] = $base{$sam[$p]};
                }
        }
        return @sam;
} 
sub mut_seq2{
	(my $rate,my @sam) = @_;
	my $e = $LEN*$rate;
	my $mut_n = random_poisson(1,$e);
	my %in = ();
	my $p = 1;
	while($p<=$mut_n){
		my $rand = int(rand($LEN));
		if(!exists $in{$rand}){
			$sam[$rand] = $base{$sam[$rand]};
			$p ++;
		}
	}
	return @sam;
}
