#!/bin/bash

cd /project/cr_055_883/pjaiswal/TRUST4/TRUST4/samples

output_folder="/scratch1/pjaiswal/TRUST4_results/dataset2/shuffle10"

# Check if original_samples directory exists
if [[ -d dataset2_shuffle10 ]]; then
    read_1="_R1"
    read_2="_R2"
    suffix2=".fastq"
    # Iterate over all files in the original_samples directory
    for i in dataset2_shuffle10/*.fastq; do
        r1=$(basename "$i")
        if [[ $r1 == *$read_1* ]]; then
            r2="${r1/_1/$read_2}"
            BASE=$(basename "$i" | awk -F '_R1|_R2' '{print $1}')
            echo $BASE
                # Create job script for each file
               echo "#!/bin/bash" > run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --nodes=1" >> run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --ntasks=1" >> run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --cpus-per-task=8" >> run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --account=fmohebbi_1178" >> run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --mem=32GB" >> run_${BASE}_dataset2_shuffle10.job
               echo "#SBATCH --time=12:00:00" >> run_${BASE}_dataset2_shuffle10.job
               echo "./../run-trust4 -f ../hg38_bcrtcr.fa -t 8 --ref ../human_IMGT+C.fa -1 dataset2_shuffle10/${BASE}_R1_001_shuffled_v10.fastq -2 dataset2_shuffle10/${BASE}_R2_001_shuffled_v10.fastq -o $output_folder/${BASE}_shuffle10 --clean 1" >> run_${BASE}_dataset2_shuffle10.job


               echo "Job script generated for ${BASE}_dataset2_shuffle10.job"
               sbatch run_${BASE}_dataset2_shuffle10.job

        fi

    done
fi
