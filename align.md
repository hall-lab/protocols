## Align from FASTQ

```
bomb -t 8 -m 48 \
    "/gscmnt/gc2719/halllab/bin/speedseq align \
        -o sample \
        -t 8 \
        -M 8 \
        -v \
        -R "@RG\tID:rg.id\tSM:rg.sample\tLB:rg.lib" \
        /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
        s1.fastq.gz \
        s2.fastq.gz"
```

## Align from FASTQ (interleaved paired-end reads)

```
bomb -t 8 -m 48 \
    "/gscmnt/gc2719/halllab/bin/speedseq align \
        -o sample \
        -t 8 \
        -M 8 \
        -p \
        -v \
        -R "@RG\tID:rg.id\tSM:rg.sample\tLB:rg.lib" \
        /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
        interleaved.fastq.gz"
```

## Align from BAM
Protocol applies to unaligned BAMs produced by Illumina X10. Note that
the `-n` flag can be added to rename the reads for reduced file size.

```
bomb -t 8 -m 48 \
    "/gscmnt/gc2719/halllab/bin/speedseq realign \
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
        lane8.bam"
```

## Realign from BAM

```
bomb -t 8 -m 48 \
    "/gscmnt/gc2719/halllab/bin/speedseq realign \
        -o sample \
        -t 8 \
        -M 8 \
        -n \
        -v \
        /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
        original.bam"
```
