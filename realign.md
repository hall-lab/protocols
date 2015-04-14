
## Realign with SpeedSeq

```
bsub -n 8 -M 48000000 -R "select[mem>48000] rusage[mem=48000] span[hosts=1]" \
"/gscmnt/gc2719/halllab/bin/speedseq realign \
    -o $SAMPLE \
    -M 8 \
    -n \
    -t 8 \
    -v \
    /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
    original.bam"
```