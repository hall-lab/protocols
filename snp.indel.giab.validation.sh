# 2015-03-03
# Evaluate the GATK performance without indel realignment, base
# recalibration, or VQSR against GIAB and Omni array truth sets

# ============================================================
# 1. Unified genotyper
# ============================================================
pwd
# /gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/NA12878_gatk_2014-08-20/ug_norecal/senspec.2015-03-03

# --------------------------------------------------
# 1a. Normalize the variant representation

# set variables
INPUT_VCF=../NA12878_S1.norecal.ug.vcf.gz
OUTROOT=gatk.ug_norecal
REF=/gscmnt/gc2719/halllab/genomes/human/GRCh37/1kg_phase1/human_g1k_v37.fasta
GATK=/gscmnt/gc2719/halllab/src/GenomeAnalysisTK-3.2-2-gec30cee/GenomeAnalysisTK.jar

# convert to allelic primitives
tabix -p vcf $INPUT_VCF
time vcfallelicprimitives -t complex $INPUT_VCF \
    | bgzip -c > $OUTROOT.prim.vcf.gz
tabix -p vcf $OUTROOT.prim.vcf.gz

# Left align and trim variants
time java -Xmx4g -jar $GATK \
    -R $REF \
    -T LeftAlignAndTrimVariants \
    --trimAlleles \
    --variant $OUTROOT.prim.vcf.gz \
    | bgzip -c > $OUTROOT.prim.leftalign.vcf.gz

# Split into SNVs and indels
echo "
    vcftools --gzvcf $OUTROOT.prim.leftalign.vcf.gz --remove-indels --recode --recode-INFO-all --out $OUTROOT.snv
    vcftools --gzvcf $OUTROOT.prim.leftalign.vcf.gz --keep-only-indels --recode --recode-INFO-all --out $OUTROOT.indel
    " | parallel -j 2

bgzip $OUTROOT.snv.recode.vcf
tabix -p vcf $OUTROOT.snv.recode.vcf.gz
bgzip $OUTROOT.indel.recode.vcf
tabix -p vcf $OUTROOT.indel.recode.vcf.gz

# --------------------------------------------------
# 1b. Unified genotyper compared to GIAB 2.17 truthset
VCFCOMP=/gscmnt/gc2719/halllab/src/USeq_8.8.2/Apps/VCFComparator
CANDIDATE_ROOT=gatk.ug_norecal
TRUTH_ROOT=giab.2.17
SNV_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.2.17/giab.2.17.snv.recode.vcf.gz
INDEL_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.2.17/giab.2.17.indel.recode.vcf.gz
TARGET_REGIONS=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.speedseq.intersect.bed.gz
# compare snvs
java -Xmx22g \
    -jar $VCFCOMP \
    -a $SNV_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.snv.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -s \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.snv

# compare indels
java -Xmx22g \
    -jar $VCFCOMP \
    -a $INDEL_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.indel.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -n \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.indel

# --------------------------------------------------
# 1c. Unified genotyper compared to OMNI microarray
VCFCOMP=/gscmnt/gc2719/halllab/src/USeq_8.8.2/Apps/VCFComparator
CANDIDATE_ROOT=gatk.ug_norecal
TRUTH_ROOT=omni
SNV_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/omni.microarray/NA12878.omni.nonref.vcf.gz
TARGET_REGIONS=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/omni.microarray/omni.speedseq.regions.bed.gz
java -Xmx22g \
    -jar $VCFCOMP \
    -a $SNV_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.snv.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -s \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.snv

# =========================================================
# 2. Haplotype caller
# =========================================================
pwd
# /gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/NA12878_gatk_2014-08-20/hc_norecal/senspec.2015-03-03

# --------------------------------------------------
# 2a. Normalize the variant representation

# set variables
INPUT_VCF=../NA12878_S1.norecal.hc.vcf.gz
OUTROOT=gatk.hc_norecal
REF=/gscmnt/gc2719/halllab/genomes/human/GRCh37/1kg_phase1/human_g1k_v37.fasta
GATK=/gscmnt/gc2719/halllab/src/GenomeAnalysisTK-3.2-2-gec30cee/GenomeAnalysisTK.jar

# convert to allelic primitives
tabix -p vcf -f $INPUT_VCF
time vcfallelicprimitives -t complex --keep-info --keep-geno $INPUT_VCF \
    | bgzip -c > $OUTROOT.prim.vcf.gz
tabix -p vcf -f $OUTROOT.prim.vcf.gz

# Left align and trim variants
time java -Xmx4g -jar $GATK \
    -R $REF \
    -T LeftAlignAndTrimVariants \
    --trimAlleles \
    --variant $OUTROOT.prim.vcf.gz \
    | bgzip -c > $OUTROOT.prim.leftalign.vcf.gz

# Split into SNVs and indels
echo "
    vcftools --gzvcf $OUTROOT.prim.leftalign.vcf.gz --remove-indels --recode --recode-INFO-all --out $OUTROOT.snv
    vcftools --gzvcf $OUTROOT.prim.leftalign.vcf.gz --keep-only-indels --recode --recode-INFO-all --out $OUTROOT.indel
    " | parallel -j 2

bgzip $OUTROOT.snv.recode.vcf
tabix -p vcf -f $OUTROOT.snv.recode.vcf.gz
bgzip $OUTROOT.indel.recode.vcf
tabix -p vcf -f $OUTROOT.indel.recode.vcf.gz

# --------------------------------------------------
# 2b. Haplotype caller compared to GIAB 2.17 truthset
VCFCOMP=/gscmnt/gc2719/halllab/src/USeq_8.8.2/Apps/VCFComparator
CANDIDATE_ROOT=gatk.hc_norecal
TRUTH_ROOT=giab.2.17
SNV_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.2.17/giab.2.17.snv.recode.vcf.gz
INDEL_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.2.17/giab.2.17.indel.recode.vcf.gz
TARGET_REGIONS=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/giab.speedseq.intersect.bed.gz
# compare snvs
java -Xmx22g \
    -jar $VCFCOMP \
    -a $SNV_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.snv.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -s \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.snv
# compare indels
java -Xmx22g \
    -jar $VCFCOMP \
    -a $INDEL_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.indel.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -n \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.indel

# --------------------------------------------------
# 2c. Haplotype caller compared to OMNI microarray
VCFCOMP=/gscmnt/gc2719/halllab/src/USeq_8.8.2/Apps/VCFComparator
CANDIDATE_ROOT=gatk.hc_norecal
TRUTH_ROOT=omni
SNV_TRUTH=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/omni.microarray/NA12878.omni.nonref.vcf.gz
TARGET_REGIONS=/gscmnt/gc5003/halllab/hall14/local/cc2qe/speedseq/truth/omni.microarray/omni.speedseq.regions.bed.gz
java -Xmx22g \
    -jar $VCFCOMP \
    -a $SNV_TRUTH \
    -b $TARGET_REGIONS \
    -c $CANDIDATE_ROOT.snv.recode.vcf.gz \
    -d $TARGET_REGIONS \
    -s \
    -p $CANDIDATE_ROOT.$TRUTH_ROOT.snv













