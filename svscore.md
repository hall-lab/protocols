## Run SVScore
bomb -m 8 \
"/gscmnt/gc2719/halllab/users/lganel/SVScore/svscore.pl \
    -g /gscmnt/gc2719/halllab/users/lganel/SVScore/gencode.v19.genes.bed \
    -e /gscmnt/gc2719/halllab/users/lganel/SVScore/gencode.v19.exons.bed \
    -n 4 \
    -c /gscmnt/gc2719/halllab/users/lganel/SVScore/whole_genome_SNVs.tsv.gz \
    -o max \
    input.vcf \
    | bgzip -c \
    > out.vcf.gz"