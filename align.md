## Align from FASTQ

```

```

## Align from BAM
Protocol applies to unaligned BAMs produced by Illumina X10. Note that
the `-n` flag can be added to rename the reads for reduced file size.

```
/gscmnt/gc2719/halllab/users/cchiang/bin/speedseq realign \
    -o sample \
    -t 8 \
    -M 8 \
    -v \
    /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
    lane1.bam \
    lane2.bam \
    lane3.bam \
    lane4.bam \
    lane5.bam \
    lane6.bam \
    lane7.bam \
    lane8.bam
```

## Realign from BAM

```
bsub -n 8 -M 48000000 -R "select[mem>48000] rusage[mem=48000] span[hosts=1]" \
"/gscmnt/gc2719/halllab/bin/speedseq realign \
    -o sample \
    -t 8 \
    -M 8 \
    -n \
    -v \
    /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
    original.bam"
```
