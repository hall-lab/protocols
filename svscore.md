## Set up SVScore
```
wget https://github.com/lganel/SVScore/archive/v0.5.1.tar.gz
tar -xzvf v0.5.1.tar.gz
rm -f v0.5.1.tar.gz
cd SVScore-0.5.1/
```

#### refGene annotations
`./generateannotations.pl`

#### Other annotations
To use other annotations, you have two options as described in the README:

1. Use `generateannotations.pl`
   * Generate a single annotation track with columns for chromosome, traanscript start, transcript stop, transcript strand, transcript name, exon start positions (comma-delimited), and exon stop positions (comma-delimited).
   * Run `generateannotations.pl`, specifying each column number using the command line options (run `generateannotations.pl --help` to see options)
   * When running SVScore, provide the names of the annotation files generated using -e (for the exon file) and -f (for the intron file)

2. Create annotation files manually
   * If you do this, make sure each line represents a transcript with a unique name
   * Exon file should have the following columns, in order:
     * 1 - Exon chromosome
     * 2 - Exon start
     * 3 - Exon stop
     * 4 - Transcript name
     * 5 - Transcript start
     * 6 - Transcript stop
     * 7 - Transcript strand
   * Intron file should have the following columns, in order:
     * 1 - Intron chromosome
     * 2 - Intron start
     * 3 - Intron stop
     * 4 - Transcript name
     * 5 - Intron number (arbitrary, but must be unique. Line number works well)

## Running SVScore
`./svscore.pl -c /gscmnt/gc2719/halllab/lganel/sharedfiles/whole_genome_SNVs.tsv.gz [-e filename.exons.bed -f filename.introns.bed] -i /path/to/file.vcf | bgzip -c > outputfile.vcf`

If running SVScore from outside the installation directory, use `/path/to/installation/svscore.pl -h /path/to/installation ...` or SVScore will throw an error
