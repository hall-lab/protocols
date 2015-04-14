# 2015-04-02

# ========================================
# Run LUMPY on a batch of GTEx samples
# ========================================

pwd
# /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02

# ----------------------------------------
# 1. Create sample map
# ----------------------------------------
cat /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/notes/batch1/batch1.txt /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/notes/batch2/batch2.txt > gtex_batch.txt

# ----------------------------------------
# 2. Set up sample directories
# ----------------------------------------
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes/gtex_batch.txt | cut -f 1`
do
    mkdir -p /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/log
done

# ----------------------------------------
# 3. Run LUMPY
# ----------------------------------------
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes/gtex_batch.txt | cut -f 1`
do
    echo $SAMPLE
    bomb \
        -g /cchiang/lumpy \
        -x hall15 \
        -m 20 \
        -t 3 \
        -J $SAMPLE.lumpy \
        -o /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/log/$SAMPLE.lumpy.log \
        -e /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/log/$SAMPLE.lumpy.log \
        "/gscmnt/gc2719/halllab/bin/speedseq sv \
            -o /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE \
            -T /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/temp \
            -R /gscmnt/gc2719/halllab/genomes/human/GRCh37/hs37_ebv/hs37_ebv.fasta \
            -B /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam \
            -S /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.splitters.bam \
            -D /gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.discordants.bam \
            -v \
            -x /gscmnt/gc2719/halllab/src/speedseq/annotations/ceph18.b37.lumpy.exclude.2014-01-15.bed \
            -d \
            -P \
            -g \
            -t 3 \
            -k"
done



