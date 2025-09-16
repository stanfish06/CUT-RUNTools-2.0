#!/usr/bin/env bash
#SBATCH --job-name=cutrun
#SBATCH --output=cutrun_%j.out
#SBATCH --error=cutrun_%j.err
#SBATCH --mail-type=START,END,FAIL
#SBATCH --mail-user=zyyu@umich.edu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --time=4:00:00
module load Bioinformatics
module load samtools fastqc
idx=$SLURM_ARRAY_TASK_ID
snames=($(ls *.fastq.gz | sed -E 's/_R[12].*//g' | sort -u))

sname_process=${snames[$((idx-1))]}
echo process $sname_process
source /home/zyyu/Git/CUT-RUNTools-2.0/run_bulkModule.sh ./my-bulk-config.json $sname_process
