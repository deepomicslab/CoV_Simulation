# CoV_Simulation

Here we presented the scripts used in the simulation of the co-infection.
Main scripts contains five steps:
- generate transmission route with mutations  
- simulate sequencing results
  - with randomly selected co-infected variant  
  - with mixed mutations from variants
- detect the links between SNP loci
- find the max clique



## Details
### Generate transmission route with mutations
```perl 1.contruct_tree.pl [outfile] [w] [r]```  
where r stands for the mutation rate, w stands for the average variant number.

- Load the period statistic file.   
default: ```GISAID20May11.period.stat.tsv```. The columns represent period number and samples number at the period. According to the sample collection time provided in GISAID, we can count the number of samples collected in each period and note the period with the maximum sample number as Pn. We note the collection time and the period of the reference genome as t0 and P0, respectively. Dividing the duration between the sample collection date and t0 to the infectious period, we obtained the period number for each sample.
- Construct the trasmmison route.  
Our simulations are executed assuming that R0 equals 2, which means that each patient could infect two people on average. The distribution of the number of people infected by the same patient conforms to the Poisson distribution.
- Simulate the mutation in transmission.  
The distribution of variants numbers in all samples conformed to a Poisson distribution with ```Lambda = w```. We can obtain a period mutation rate from the infectious period and mutation rate, representing the mutation rate between two neighbouring periods. In a single transmission branch, variants in samples at child branches are random heritages from the variants in the parent branch. 
- Output the SNP loci.  
Output contains all mutations in all variants which we supposed had been sequenced in the simulated trasmmision route.  
Columns reprent: Number of variants in the parent sample, selected variant in the child sample, the parent sample name, number of variants in the child sample, variants number, the child sample name, SNP loci, Reference, Alternative.
```
3       3       p3_sam59        4       2       p4_sam354       4546    R       A
3       3       p3_sam59        4       2       p4_sam354       8386    R       A
3       3       p3_sam59        4       2       p4_sam354       17905   R       A
3       3       p3_sam59        4       3       p4_sam354       8386    R       A
3       3       p3_sam59        4       3       p4_sam354       17905   R       A
3       2       p3_sam59        4       4       p4_sam354       3427    R       A
3       2       p3_sam59        4       4       p4_sam354       10947   R       A
3       2       p3_sam59        4       4       p4_sam354       28536   R       A
1       1       p3_sam108       3       1       p4_sam477       9906    R       A
1       1       p3_sam108       3       1       p4_sam477       11261   R       A
1       1       p3_sam108       3       1       p4_sam477       17128   R       A
1       1       p3_sam108       3       1       p4_sam477       20494   R       A
1       1       p3_sam108       3       1       p4_sam477       27746   R       A
1       1       p3_sam108       3       2       p4_sam477       9906    R       A
```
### Simulation of SNVs in assembly genomes
#### method 1: randomly select one variant
```perl 2.1.select_strain.pl [outfile] > [outfile].filter1 ```  

#### method 2: mixed variants
```perl 2.2.mixed_strain.pl [outfile] > [outfile].filter2 ```  

We hypothesized that the genomic sequence is an assembled mixture of genomes from all variants in the sample. We set a window of 100 nt and slide it across the entire genomic sequence. In each window, its SNVs come from a randomly selected strain.

### Detect the edges between SNP loci
```perl 3.detect_links.pl [outfile].filter > [outfile].filter.count ```  
We labelled the major allele of the SNP locus as R and the minor allele as A. Thus, it had four possible genetic combinations for every pair of two SNP loci: RR, RA, AR, and AA. We recognized each SNP locus as a vertex and created an edge between a locus pair only if all four genetic combinations existed in at least one assembly genome.  
Columns reprent: lociA-lociB, number of combinations detected, number of sample with genotypes. Only loci pair satisfied the mentioned condition will output.
```
27-4077 4       RR:10891;AA:2;RA:2;AR:2;
27-10588        4       RR:10629;RA:264;AA:2;AR:2;
27-13968        4       RR:10844;RA:49;AA:2;AR:2;
27-24992        4       RR:10852;RA:41;AA:2;AR:2;
31-962  4       RR:10840;AR:44;RA:7;AA:6;
31-1241 4       RR:10844;AR:48;RA:3;AA:2;
31-3096 4       RR:10845;AR:48;AA:2;RA:2;
31-5988 4       RR:10843;AR:48;RA:4;AA:2;
31-28709        4       RR:10845;AR:44;AA:6;RA:2;
72-11441        4       RR:10889;AR:4;AA:2;RA:2;
```
### Detect the maximal clique
```perl 4.find_clique.pl  [outfile].filter.count |sort -k4gr > [outfile].filter.count.clique```   
Clique represents a subnetwork composed of vertices and a set of edges. We traverse all edge to detect the clique with miximal vertex (SNP loci).


