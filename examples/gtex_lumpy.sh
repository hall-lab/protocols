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

# ----------------------------------------
# 4. Get SV counts per sample
# ----------------------------------------
pwd
# /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes

for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes/gtex_batch.txt | cut -f 1`
do
    zcat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf.gz \
        | vawk -v S=$SAMPLE 'BEGIN {DEL=0; DUP=0; INV=0; BND=0} { if (I$SVTYPE=="DEL") DEL+=1; else if (I$SVTYPE=="DUP") DUP+=1; else if (I$SVTYPE=="INV") INV+=1; else if (I$SVTYPE=="BND" && ! I$SECONDARY) BND+=1 } END { print S,DEL,DUP,INV,BND }'
done > /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes/svtype_counts.txt

# ----------------------------------------
# 5. Merge SV VCFs
# ----------------------------------------
# Warning: this section is under active development
# l_merge commit: 5e211dacaafd3c9aab1a3d5e7a2373b5280de057

# l_sort cannot yet handle gzipped VCFs so let's unzip them first.
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/notes/gtex_batch.txt | cut -f 1`
do
    echo $SAMPLE
    zcat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf.gz > /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf
done

# concatenate and sort the variants
echo -n /gscmnt/gc2719/halllab/users/cchiang/src/lumpy-sv/scripts/l_sort.py > sort_cmd.sh
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/merge_sample_list.txt`
do
    echo -ne " \\\\\n\t/gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf"
done >> sort_cmd.sh
bomb -m 25 -J lsort "bash sort_cmd.sh | bgzip -c > gtex_sorted_2015-04-09.sv.vcf.gz"

# Collapse the variants into merged VCF
bomb -m 20 -J lmerge.$SLOP \
    "zcat gtex_sorted_2015-04-09.sv.vcf.gz \
        | python -u /gscmnt/gc2719/halllab/users/cchiang/src/lumpy-sv/scripts/l_merge.py -i /dev/stdin -f 20 \
        | bedtools sort -header \
        | bgzip -c \
        > gtex_merged.sv.vcf.gz"
done

# ----------------------------------------
# 6. Genotype merged VCF with SVTyper
# ----------------------------------------
# Warning: this section is under active development
# svtyper commit: d3a72d8474b5ee4cafc84c7d1989a0891d6f9d1f

# To speed things up, generate a separate VCF for each sample and
# join them afterwards.

# svtyper: e4dfd4e76a7c9bf1013aeabf0630f08ddd964201
mkdir -p gt
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt | cut -f 1`
do
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SPL=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.splitters.bam
    bomb -m 18 -J $SAMPLE.gt -g /cchiang/svtyper -o log/$SAMPLE.gt.%J.log -e log/$SAMPLE.gt.%J.log \
         "zcat gtex_merged.sv.vcf.gz \
            | sed 's/##INFO=<ID=EVENT,Number=1,Type=String,Description=\"ID of event associated to breakend\">/##INFO=<ID=EVENT,Number=1,Type=String,Description=\"ID of event associated to breakend\">\n##INFO=<ID=SNAME,Number=.,Type=String,Description=\"Source samples\">/g' \
            | vawk --header '{  \$6=\".\"; print }' \
            | /gscmnt/gc2719/halllab/users/cchiang/src/svtyper/svtyper \
                -B $BAM \
                -S $SPL \
            | vawk --header '{\$8=I\$SVTYPE; print }' \
            > gt/$SAMPLE.vcf"
done

# paste the samples into a single VCF
bomb -m 4 -J paste -o log/paste.%J.log -e log/paste.%J.log \
    "zcat gtex_merged.sv.vcf.gz \
        | /gscmnt/gc2719/halllab/users/cchiang/src/svtyper/scripts/vcf_group_multiline.py \
        | /gscmnt/gc2719/halllab/users/cchiang/src/svtyper/scripts/vcf_paste.py \
              -m - \
              -q \
              gt/GTEX-*.vcf \
        | bedtools sort -header \
        | bgzip -c \
        > gtex_merged.sv.gt.vcf.gz"

# ----------------------------------------
# 6. Annotate read-depth of VCF variants
# ----------------------------------------
# Warning: this section is under active development

# To speed things up, generate a separate VCF for each sample and
# join them afterwards.










