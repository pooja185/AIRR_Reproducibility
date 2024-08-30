#!/bin/bash
#-----------------------------------------------------------------------------
#Author		: Pooja Jaiswal
#Details 	: This script runs the entire pipeline for mixcr analyze command
#-----------------------------------------------------------------------------
module purge
#Path to the result folder

output_folder="results"
# Check if original_samples directory exists
if [[ -d original_samples ]]; then
    read_1="_1"
    read_2="_2"
    suffix2=".fastq"
    # Iterate over all files in the original_samples directory
    for i in original_samples/*.fastq; do
        r1=$(basename "$i")
        if [[ $r1 == *$read_1* ]]; then
            r2="${r1/_R1/$read_2}"
            BASE=$(basename "$i" | awk -F '_1|_2' '{print $1}')

                # Create job script for each file
                echo "#!/bin/bash" > run_${BASE}.job
                echo "#SBATCH --nodes=1" >> run_${BASE}.job
                echo "#SBATCH --ntasks=1" >> run_${BASE}.job
                echo "#SBATCH --cpus-per-task=4" >> run_${BASE}.job
                echo "#SBATCH --account=ypatel_840" >> run_${BASE}.job
				echo "#SBATCH --mem=16GB" >> run_${BASE}.job
                echo "#SBATCH --time=01:00:00" >> run_${BASE}.job
                echo "eval \"\$(conda shell.bash hook)\"" >> run_${BASE}.job
                echo "conda activate mixcr" >> run_${BASE}.job
                echo "mixcr analyze generic-amplicon --species hsa --rna\ 
				--floating-left-alignment-boundary --floating-right-alignment-boundary C \
				original_samples/${BASE}_1.fastq original_samples/${BASE}_2.fastq\
				$output_folder/${BASE}" >> run_${BASE}.job                         
                echo "Job script generated for $BASE" 
				sbatch run_${BASE}.job
    #
        fi
        
    done 
fi 


