#!/usr/bin/env bash
module load Bioinformatics
module load bedtools2

# use narrow for TF
peakType=macs2.narrow
exclude="histone|IgG|H3"

bedFiles=($(find . -name "*cpm*bw" | grep $peakType | awk -F '/' '{print $2}' | uniq | grep -vE $exclude | sort))
len=${#bedFiles[@]}

for (( i=0; i<$len; i++ )); do
    bedFiles[i]=${bedFiles[i]}/peakcalling/$peakType/${bedFiles[i]}_peaks.narrowPeak
done

bedtools multiinter -header -i "${bedFiles[@]}" > SMAD1_merged_narrowPeak.bed
