#!/bin/bash 
#Author		: Pooja Jaiswal
#Details 	: This script runs the entire pipeline for mixcr analyze command
#-----------------------------------------------------------------------------
#SBATCH --account=ypatel_840
#SBATCH --partition=main
#SBATCH --nodes=4
#SBATCH --ntasks=8
#SBATCH --cpus-per-task=4
#SBATCH --mem=32gb
#SBATCH --time=24:00:00
#SBATCH -o mixcr_analyze.out
#SBATCH -e mixcr_analyze.err
module purge
module load gcc/11.3.0
module load parallel
#Activate conda environment 
eval "$(conda shell.bash hook)"
conda activate mixcr

#parameters
thread_num=8
job_num=4

#making output directory
top_dir=results
original_results=$top_dir/mixcr_output
for dyr in $top_dir $original_results; do
	mkdir -p $dyr
done
#--------------------------------------------------------------------------------
#Creating log files
que=$top_dir/mixcr_que.txt

if [ ! -f "$que" ]; then
	touch "$que"
elif [ -f "$que" ]; then
	> "$que"
fi
#--------------------------------------------------------------------------------
#Preset used: takara-human-rna-tcr-umi-smarter-v2

if [[ -d all_samples ]]; then
		read_1="_R1"
		read_2="_R2"
		suffix2=".fastq"
		for i in all_samples/*.fastq; do
				r1=$(basename "$i".fastq)
				if [[ $r1 == *$read_1* ]]; then
				r2="${r1/_R1/$read_2}"
				BASE=$(basename "$i" | awk -F '_R1|_R2' '{print $1}')
				echo $BASE
				cmd="mixcr analyze takara-human-rna-tcr-umi-smarter-v2 -s hsa --rna -t ${thread_num}\
				all_samples/${BASE}_R1.fastq all_samples/${BASE}_R2.fastq ${original_results}/${BASE}"
				echo $cmd | tr -s '\t' >> ${top_dir}/mixcr_que.txt
				fi
				
		done
fi
parallel --jobs ${job_num} --joblog ${top_dir}/log.txt < ${top_dir}/mixcr_que.txt
