#!/usr/bin/env bash
module load Bioinformatics
module load subread

# use narrow for TF
peakType=macs2.narrow
exclude="histone|IgG|H3"

bamFiles=($(find . -name "*cpm*bw" | grep $peakType | awk -F '/' '{print $2}' | uniq | grep -vE $exclude | sort))
annotationFile=SMAD1_merged_narrowPeak.saf
len=${#bamFiles[@]}

for (( i=0; i<$len; i++ )); do
    bamFiles[i]=${bamFiles[i]}/aligned/dedup.120bp/${bamFiles[i]}.bam
done

featureCounts -T 24 -p --countReadPairs -F SAF -a $annotationFile -o SMAD1_counts_narrowPeak.txt ${bamFiles[@]}
