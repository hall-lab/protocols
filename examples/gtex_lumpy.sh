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
        -m 20 \
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
echo -n /gscmnt/gc2719/halllab/src/lumpy-sv/scripts/l_sort.py > sort_cmd.sh
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/merge_sample_list.txt`
do
    echo -ne " \\\\\n\t/gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf"
done >> sort_cmd.sh
bomb -m 25 -J lsort "bash sort_cmd.sh | bgzip -c > gtex_sorted_2015-04-09.sv.vcf.gz"

# Collapse the variants into merged VCF
bomb -m 20 -J lmerge.$SLOP \
    "zcat gtex_sorted_2015-04-09.sv.vcf.gz \
        | python -u /gscmnt/gc2719/halllab/src/lumpy-sv/scripts/l_merge.py -i /dev/stdin -f 20 \
        | bedtools sort -header \
        | bgzip -c \
        > gtex_merged.sv.vcf.gz"
done

# ----------------------------------------
# 6. Genotype merged VCF with SVTyper
# ----------------------------------------
# Warning: this section is under active development

# To speed things up, generate a separate VCF for each sample and
# join them afterwards.

# svtyper commit:73d1ef574637445bfa24c5c1c9adf26be3ab9ce6
mkdir -p gt
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt | cut -f 1`
do
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SPL=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.splitters.bam
    bomb -m 18 -J $SAMPLE.gt -g /cchiang/svtyper -o log/$SAMPLE.gt.%J.log -e log/$SAMPLE.gt.%J.log \
         "zcat gtex_merged.sv.vcf.gz \
            | vawk --header '{  \$6=\".\"; print }' \
            | /gscmnt/gc2719/halllab/src/svtyper/svtyper \
                -B $BAM \
                -S $SPL \
            | sed 's/PR...=[0-9\.e,-]*\(;\)\{0,1\}\(\t\)\{0,1\}/\2/g' - \
            > gt/$SAMPLE.vcf"
done

# paste the samples into a single VCF
bomb -m 20 -J paste.gt -o log/paste.gt.%J.log -e log/paste.gt.%J.log \
    "zcat gtex_merged.sv.vcf.gz \
        | /gscmnt/gc2719/halllab/src/svtyper/scripts/vcf_group_multiline.py \
        | /gscmnt/gc2719/halllab/src/svtyper/scripts/vcf_paste.py \
            -m - \
            -q \
            gt/*.vcf \
        | bedtools sort -header \
        > gtex_merged.sv.gt.vcf"

# ----------------------------------------
# 6. Annotate read-depth of VCF variants
# ----------------------------------------
# Warning: this section is under active development

# To speed things up, generate a separate VCF for each sample and
# join them afterwards.

# add copy number information to the VCF
mkdir -p cn
source /gsc/pkg/root/root/bin/thisroot.sh
VCF=gtex_merged.sv.gt.vcf
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt`
do
    ROOT=/gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/$SAMPLE/temp/cnvnator-temp/$SAMPLE.bam.hist.root
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SM=`sambamba view -H $BAM | grep -m 1 "^@RG" | awk '{ for (i=1;i<=NF;++i) { if ($i~"^SM:") SM=$i; gsub("^SM:","",SM); } print SM }'`
    bomb -q hall-lab -g /cchiang/svtyper -m 6 -J $SAMPLE.cn -o log/$SAMPLE.cn.%J.log -e log/$SAMPLE.cn.%J.log \
         "/gscmnt/gc2719/halllab/bin/gemini_python /gscmnt/gc2719/halllab/src/speedseq/bin/annotate_rd.py \
             --cnvnator /gscmnt/gc2719/halllab/src/speedseq/bin/cnvnator-multi \
             -s $SM \
             -w 100 \
             -r $ROOT \
             -v $VCF \
         | vawk --header '{ print \$1,\$2,\$3,\$4,\$5,\$6,\$7,\"NULL\",\$9,S\$$SM }' \
         | sed \"s/#CHROM.*/#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t$SM/g\" \
         > cn/$SAMPLE.vcf"
    done

# paste the samples into a single VCF
bomb -m 4 -J paste.cn -o log/paste.cn.%J.log -e log/paste.cn.%J.log \
    "/gscmnt/gc2719/halllab/src/svtyper/scripts/vcf_paste.py \
        -m gtex_merged.sv.gt.vcf \
        cn/*.vcf \
        | bgzip -c \
        > gtex_merged.sv.gt.cn.vcf.gz"

# ----------------------------------------
# 7. Genotype pre-merged SVs to compare counts
# ----------------------------------------
mkdir -p pre-merged_gt
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt`
do
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SPL=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.splitters.bam
    VCF=/gscmnt/gc2719/halllab/users/cchiang/projects/gtex//lumpy_2015-04-02/$SAMPLE/$SAMPLE.sv.vcf.gz
    bomb -m 18 -J $SAMPLE.orig -g /cchiang/svtyper \
        -o log/$SAMPLE.pre-merged_gt.%J.log \
        -e log/$SAMPLE.pre-merged_gt.%J.log \
        "zcat $VCF \
            | vawk --header '{  \$6=\".\"; print }' \
            | /gscmnt/gc2719/halllab/src/svtyper/svtyper \
                -B $BAM \
                -S $SPL \
            | sed 's/PR...=[0-9\.e,-]*\(;\)\{0,1\}\(\t\)\{0,1\}/\2/g' \
            | bgzip -c \
            > pre-merged_gt/$SAMPLE.sv.gt.vcf.gz"
done

# ----------------------------------------
# 8. Compare SV counts for pre- and post-merged VCFs
# ----------------------------------------

# count up the pre-merged
mkdir -p pre-merged_sv_count
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt`
do
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SM=`sambamba view -H $BAM | grep -m 1 "^@RG" | awk '{ for (i=1;i<=NF;++i) { if ($i~"^SM:") SM=$i; gsub("^SM:","",SM); } print SM }'`
    bomb -g /cchiang/batch2 -m 2 -J $SAMPLE.svcount \
        "/gscmnt/gc2719/halllab/users/cchiang/src/svtyper-dev/scripts/sv_counts.sh \
            pre-merged_gt/$SAMPLE.sv.gt.vcf.gz $SM \
            > pre-merged_sv_count/$SAMPLE.count.txt"
done

# consolidate into a single file
cat pre-merged_sv_count/*.count.txt \
    | awk '{ print $1,$2,$4+$5 }' OFS="\t" \
    | groupBy -g 1 -c 3 -o collapse \
    | tr ',' '\t' \
    > pre-merged.sv_counts.txt

# count up the post-merged
mkdir -p sv_count
for SAMPLE in `cat /gscmnt/gc2719/halllab/users/cchiang/projects/gtex/lumpy_2015-04-02/merged_2015-04-09/full01_samples.txt`
do
    BAM=/gscmnt/gc2802/halllab/gtex_realign_2015-03-16/$SAMPLE/$SAMPLE.bam
    SM=`sambamba view -H $BAM | grep -m 1 "^@RG" | awk '{ for (i=1;i<=NF;++i) { if ($i~"^SM:") SM=$i; gsub("^SM:","",SM); } print SM }'`
    bomb -g /cchiang/batch2 -m 2 -J $SAMPLE.svcount \
        "/gscmnt/gc2719/halllab/src/svtyper/scripts/sv_counts.sh \
            gt/$SAMPLE.sv.gt.vcf.gz $SM \
            > sv_count/$SAMPLE.count.txt"
done

# consolidate into a single file
cat sv_count/*.count.txt \
    | awk '{ print $1,$2,$4+$5 }' OFS="\t" \
    | groupBy -g 1 -c 3 -o collapse \
    | tr ',' '\t' \
    > post-merged.sv_counts.txt

# ----------------------------------------
# 9. Plot the SV counts in R before and after merging
# ----------------------------------------
# R code:
col.list <- c('indianred3', 'dodgerblue3', 'goldenrod1', 'gray')
before <- read.table('../data/merged_2015-04-23/pre-merged.sv_counts.txt')
after <- read.table('../data/merged_2015-04-23/post-merged.sv_counts.txt')

# before
pdf('../plots/pre-merged_sv_count.pdf', height=5, width=14)
barplot(t(data.matrix(before[,2:ncol(before)])), col=col.list, las=3, cex.names=0.6, main="Before merging\nnumber of SVs per sample by type", ylab='Number of SVs', ylim=c(0,9000), xlab='Samples')
legend('topleft', c('Deletions', 'Tandem duplications', 'Inversions', 'Unknown'), fill=col.list, bty='n')
dev.off()

# after
pdf('../plots/post-merged_sv_count.pdf', height=5, width=14)
barplot(t(data.matrix(after[,2:ncol(after)])), col=col.list, las=3, cex.names=0.6, main="After merging\nnumber of SVs per sample by type", ylab='Number of SVs', ylim=c(0,9000), xlab='Samples')
legend('topleft', c('Deletions', 'Tandem duplications', 'Inversions', 'Unknown'), fill=col.list, bty='n')
dev.off()
# end R code



