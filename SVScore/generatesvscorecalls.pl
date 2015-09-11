#!/usr/bin/perl -w

# Modify for your own usage of SVScore
# Be sure to leave -s flag on line 9

opendir(CWD, $ARGV[0]) || die "Could not open cwd: $!";
@files = grep {/^split\d\d\.vcf$/} readdir CWD;

print "./svscore.pl -s -g gencode.v19.genes.bed -e gencode.v19.exons.bed -n 4 split00.vcf\n";

foreach (sort @files) {
  ($prefix) = /(.*)\.vcf/;
  print "bomb -J $prefix -m 4 -e $prefix.log -o $prefix.log -q long \"./svscore.pl -g gencode.v19.genes.bed -e gencode.v19.exons.bed -n 4 $_ > $prefix.out.vcf\"\n";
}
