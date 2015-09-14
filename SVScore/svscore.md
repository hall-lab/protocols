## Run SVScore
```
bomb -m 8 \
"/gscmnt/gc2719/halllab/users/lganel/SVScore/svscore.pl \
    -g /gscmnt/gc2719/halllab/users/lganel/SVScore/gencode.v19.genes.bed \
    -e /gscmnt/gc2719/halllab/users/lganel/SVScore/gencode.v19.exons.bed \
    -n 4 \
    -c /gscmnt/gc2719/halllab/users/lganel/sharedfiles/whole_genome_SNVs.tsv.gz \
    -o max \
    input.vcf \
    | bgzip -c \
    > out.vcf.gz"
```

## With parallelization
`sh runsvscore.sh input.vcf`

After all jobs finish, combine into one:
```
grep '^#' split00.out.vcf > header
cat *.out.vcf | grep –v '^#' | sort –k1,1 –k2,2n | cat header - > final.vcf
rm –f header
```
