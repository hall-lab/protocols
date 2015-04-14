## GTEx WGS BAM realignment
2015-03-18

```
pwd
# /gscmnt/gc2802/halllab/gtex_realign_2015-03-16

# batch 1: 80 samples
# make the batch
for BAMPATH in `ls /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/*.bam | head -n 80`
do
    BAM=`echo $BAMPATH | xargs -I{} basename {} .bam`
    echo -e "$BAM\t$BAMPATH"
done > batch1.txt

BATCH=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/notes/batch1/batch1.txt
head $BATCH
# GTEX-N7MS-0009-SM-5JK3E   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-N7MS-0009-SM-5JK3E.bam
# GTEX-N7MT-0009-SM-5JK4X   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-N7MT-0009-SM-5JK4X.bam
# GTEX-NFK9-0004-SM-5JK4Y   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-NFK9-0004-SM-5JK4Y.bam
# GTEX-NL3H-0009-SM-5JK37   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-NL3H-0009-SM-5JK37.bam
# GTEX-NL4W-0009-SM-5JK3O   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-NL4W-0009-SM-5JK3O.bam
# GTEX-NPJ7-0009-SM-5JK4M   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-NPJ7-0009-SM-5JK4M.bam
# GTEX-NPJ8-0004-SM-5JK3D   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-NPJ8-0004-SM-5JK3D.bam
# GTEX-O5YT-0010-SM-5JK31   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-O5YT-0010-SM-5JK31.bam
# GTEX-O5YV-0004-SM-5JK2N   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-O5YV-0004-SM-5JK2N.bam
# GTEX-O5YW-0003-SM-5JK2Y   /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/original/GTEX-O5YW-0003-SM-5JK2Y.bam

# make some directory paths
for SAMPLE in `cat $BATCH | cut -f 1`
do
    BAMPATH=`cat $BATCH | grep -m 1 $SAMPLE | cut -f 2`
    mkdir -p /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE
    mkdir -p /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc
    mkdir -p /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log
done

# symlink the original BAM files
for SAMPLE in `cat $BATCH | cut -f 1`
do
    BAMPATH=`cat $BATCH | grep -m 1 $SAMPLE | cut -f 2`
    cd /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc
    ln -s $BAMPATH original.bam
    cd -
done

# flagstat the original BAM files
for SAMPLE in `cat $BATCH | cut -f 1`
do
    echo $SAMPLE
    bomb \
        -m 1 \
        -J $SAMPLE.flag \
        -g /cchiang/flagstat \
        -o /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.original.flagstat.%J.log \
        -e /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.original.flagstat.%J.log \
        "samtools-1.1 flagstat /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc/original.bam > /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc/original.bam.flagstat"
done

# realign the files
# speedseq commit: a076a6201d9966ccc176a1118927891c197e491d
for SAMPLE in `cat $BATCH | cut -f 1`
do
    echo $SAMPLE
    bomb \
        -x hall14,hall15 \
        -g /cchiang/gtex_realign \
        -m 48 \
        -t 8 \
        -J $SAMPLE.align \
        -o /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.align.%J.log \
        -e /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.align.%J.log \
        "/gscmnt/gc2719/halllab/bin/speedseq realign \
            -o /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE \
            -T /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/temp \
            -M 8 -n -t 8 \
            -v \
            /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
            /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc/original.bam"
done

# flagstat the realignments
for SAMPLE in `cat $BATCH | cut -f 1`
do
    echo $SAMPLE
    bomb \
        -m 1 \
        -J $SAMPLE.flag \
        -g /cchiang/flagstat \
        -o /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.realign.flagstat.%J.log \
        -e /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/log/$SAMPLE.realign.flagstat.%J.log \
        "samtools-1.1 flagstat /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam > /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam.flagstat"
done

# check the flagstats
for SAMPLE in `cat $BATCH | cut -f 1`
do
    REALIGN_PAIRED=`cat /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam.flagstat | grep -m 1 "paired in sequencing" | awk '{ print $1+$3 }'`    
    ORIG_PAIRED=`cat /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/qc/original.bam.flagstat | grep -m 1 "paired in sequencing" | awk '{ print $1+$3 }'`
    DIFF=$(( $REALIGN_PAIRED - $ORIG_PAIRED ))
    
    READ_LENGTH=`sambamba view /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam | head -n 10000 | awk 'BEGIN { MAX_LEN=0 } { LEN=length($10); if (LEN>MAX_LEN) MAX_LEN=LEN } END { print MAX_LEN }'`
    
    NONGAPGENOME=2867459933
    
    COV=`calc "$REALIGN_PAIRED*$READ_LENGTH/$NONGAPGENOME"`
    echo -e "$SAMPLE\t$REALIGN_PAIRED\t$ORIG_PAIRED\t$DIFF\t$READ_LENGTH\t$COV"
done > /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/notes/batch1/flagstat_qc.txt

FLAGSTAT_QC=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/notes/batch1/flagstat_qc.txt
# remove the completed
for SAMPLE in `cat $FLAGSTAT_QC | awk '{ if ($2==$3) print $1 }'`
do
    BAMPATH=`cat $BATCH | grep -m 1 $SAMPLE | cut -f 2`
    echo $SAMPLE
    
    rm $BAMPATH
done
```