#!/usr/bin/env perl

# This file is used to summarize the GFF output from SMRT Link into a CSV file, so the methylation information can be used.


my $file=@ARGV[0]; # firt argument of the script the .gff that we whant to summarize
my %motifs; # save all the unique motif found in the gff
my %contig; # count the motif in contigs
my %bycont; # count the motif in individual contigs

# Oppen the gff file and for ech line we store the name of the contig and start countig the number of motif each contig has.
open(GFF, $file) || die"cannot open file $file";
while(<GFF>) {
	$line=$_;
	chomp;
	@info=split(/\t/,$line);
	$name=$info[0];
	# we don't take into account the modified base we just one to take into accout the methylated motif like m6A, m4C
	if (($info[8] =~ m/.*motif=(\w+).*/) && ($info[2] !~ /^modified.*base$/)) {  
		$motifs{$1}=1;
		$name=$info[0]."_".$1;
		$contig{$name}++;
	}
	else {}
}

# prints the name of the colums, which are the name of the motif
foreach $j (sort keys %motifs) {
	print "\t".$j;
	$bycont{$j}=1;
}

#print "\n";

# know it start countig and printing
my $kept='';
my $line='';
foreach $i (sort keys %contig) {
	@k = split(/_/, $i);
	if ($kept ne $k[0]) { 
		foreach $m (sort keys %motifs) {
			$line = $line."\t".$bycont{$m};
		}
		unless ($kept eq '') {
			print $line."\n".$k[0];
		}
		else { print "\n".$k[0]; }
		$kept = $k[0]; 
		$line=''; 
		%bycont='';
	} 
	foreach $j (sort keys %motifs) { 
		if ($k[1] eq $j) {  $bycont{$j}=$contig{$i}; }
	}

}
exit 0;	
