#!/usr/bin/env bash
# trimmed2 will result in fewer mapped reads
module load Bioinformatics
module load samtools
module load bowtie2

fastq_folder=trimmed
fastq_ext=".paired.fastq.gz"
exclude="histone|IgG|H3"
n_process=30
spike_genome=~/Git/CUT-RUNTools-2.0/install/assemblies/ecoli/bowtie2/genome
run_align=false

sample_names=$(find . -name "*\.paired.fastq*" | grep trimmed/ | awk -F '/' '{print $2}' | uniq | grep -vE $exclude | sort)
log_file="log_$(date +%Y%m%d_%H%M%S).bowtie2"
output_tab="spike_table_$(date +%Y%m%d_%H%M%S).txt"
echo [CREATE] log: $log_file
echo [CREATE] output table: $output_tab
echo "sample,n_mapped,total" > $output_tab
exec > >(tee -i $log_file) 2>&1
for sname in $sample_names; do
    cwd=$sname/$fastq_folder
    echo [START] $cwd
    read1="${sname}_1${fastq_ext}"
    read2="${sname}_2${fastq_ext}"
    echo [READ1] $read1
    echo [READ2] $read2
    # --no-overlap and --no-dovetail are recommended by Steven
    cmd="bowtie2 -p $n_process --no-overlap --no-dovetail --local --phred33 -N 1 -L 15 -D 25 -R 5 -i S,1,0.50 -X 1000 --score-min G,15,6 -x $spike_genome -1 $cwd/$read1 -2 $cwd/$read2 2> $cwd/spike.bowtie2.log | samtools view -bS - > $cwd/spike.bam"
    echo [EXEC] $cmd
    if [ "$run_align" = true ]; then
        eval $cmd
    fi
    log="$cwd/spike.bowtie2.log"
    total_pairs=$(awk '/were paired/ {print $1}' "$log")
    aligned_once=$(awk '/aligned concordantly exactly 1 time/ {print $1}' "$log")
    aligned_many=$(awk '/aligned concordantly >1 times/ {print $1}' "$log")
    aligned=$(($aligned_once + $aligned_many))
    echo [SUMMARY] mapped/total=$aligned_once/$total_pairs
    echo "$sname,$aligned_once,$total_pairs" >> $output_tab
    echo [DONE] $sname
done
