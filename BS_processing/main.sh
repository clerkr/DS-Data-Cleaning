#!/bin/bash

bash human_reference_genome_processing.sh


# Define main directory
main_dir="GSE81541"
mkdir -p "$main_dir"  # Use -p to avoid errors if the directory already exists

# Prepare sra tools docker image to download fastq files
# fastq file source: https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA321909&o=acc_s%3Aa
# Only Down-Syndrome sequences are fetched

srr_vals=("SRR3537005")

# srr_vals=("SRR3537005" "SRR3537006" "SRR3537007" "SRR3537008")

sra_image="ncbi/sra-tools"

if ! docker images | grep -q "$sra_image"; then
  echo "Pulling docker image: $sra_image..."
  docker pull "$sra_image"
else
  echo "Docker image '$sra_image' already exists, skipping pull."
fi

# Loop through the SRR values and run the prefetch command for each one
for srr_val in "${srr_vals[@]}"; do
  # Make a directotry to hold the srr specific files inside the GSE files
  echo "Fetching .sra for $srr_val..."

  CONTAINER_ID=$(docker run --rm -d -v "$PWD/$main_dir:/home" "$sra_image" prefetch --output-directory /home "$srr_val")
  # Wait for the container to finish
  docker logs -f "$CONTAINER_ID" >> main.log 2>&1 &
  docker wait "$CONTAINER_ID"

  file="$PWD/$main_dir/$srr_val/$srr_val.fastq"

  if [ -f "$file" ]; then
      echo "$file already present."
  else
      echo "$file does not exist or is not a regular file."
      echo "Dumping $srr_val..."
      CONTAINER_ID=$(docker run --rm -d -v "$PWD/$main_dir:/home" "$sra_image" fasterq-dump "/home/$srr_val" -O "/home/$srr_val" --temp "/home/$srr_val")
      docker logs -f "$CONTAINER_ID" >> main.log 2>&1 &
      docker wait "$CONTAINER_ID"
  fi
  # The following command worked when I ran it in an interactive shell manually. Just saving it for redundacy
  #docker run --rm -it -v /Analysis/DS-Data-Cleaning/BS_processing/GSE81541:/home ncbi/sra-tools fasterq-dump SRR3537005 -O /home --temp /home


  bismark_container="quay.io/biocontainers/bismark:0.24.2--hdfd78af_0"

  if ! docker images | grep -q "$bismark_container"; then
    echo "Pulling docker image: $bismark_container..."
    docker pull "$bismark_container"
  else
    echo "Docker image '$bismark_container' already exists, skipping pull."
  fi


  BAM_FILE="BS_processing/$main_dir/$srr_val/${srr_val}_bismark_bt2.bam"
  # FASTQ_FILE="GSE81541/SRR3537005/SRR3537005.fastq"

  if [[ -f "$BAM_FILE" ]]; then
      echo "File exists: $BAM_FILE"
  else
    echo "File not found: $BAM_FILE"
    CONTAINER_ID=$(docker run --rm -d \
    -v $PWD:/home/gnm \
    -v "$PWD/$main_dir/$srr_val":/home/fstq \
    -w /home/fstq \
    $bismark_container \
    bismark /home/gnm /home/fstq/$srr_val.fastq -p 8)
    docker logs -f "$CONTAINER_ID" >> main.log 2>&1 &
    # Wait for the container to finish
    docker wait "$CONTAINER_ID"
  fi

  SORTED_BAM_FILE="BS_processing/$main_dir/$srr_val/${srr_val}_bismark_bt2_sorted.bam"
  # FASTQ_FILE="GSE81541/SRR3537005/SRR3537005.fastq"

  if [[ -f "$SORTED_BAM_FILE" ]]; then
      echo "File exists: $SORTED_BAM_FILE"
  else
    # This is for sorting .bam files so that they can be assessed with qualimap
    CONTAINER="quay.io/biocontainers/samtools:1.21--h96c455f_1"
    docker pull "$CONTAINER"
    CONTAINER_ID=$(docker run --rm -d \
        --user root \
        -v "$PWD/$main_dir/$srr_val:/home" \
        -w /home \
        "$CONTAINER" \
        samtools sort "${srr_val}_bismark_bt2.bam" \
        -o "${srr_val}_bismark_bt2_sorted.bam"
    )
    docker logs -f "$CONTAINER_ID" >> "$main_dir/$srr_val/sorting.log" 2>&1 &
    docker wait "$CONTAINER_ID"

  fi

  
  mkdir -p "$main_dir/$srr_val/quality"

  # Quality checking using qualimap. Outputs html, css, and other reports
  CONTAINER="quay.io/biocontainers/qualimap:2.2.2d--1"
  docker pull $CONTAINER
  CONTAINER_ID=$(docker run --rm -d \
      --user root \
      -v "$PWD/$main_dir/$srr_val:/home" -w /home "$CONTAINER" \
      qualimap bamqc -bam "${srr_val}_bismark_bt2_sorted.bam" \
      -outdir /home/quality -outformat HTML
  )
  docker logs -f "$CONTAINER_ID" >> "$main_dir/${srr_val}/quality/quality.log" 2>&1 &
  docker wait "$CONTAINER_ID"
done



# docker run --rm -it \
#   --user root \
#   -v "$PWD/GSE81541/SRR3537005:/home" \
#   -w /home quay.io/biocontainers/qualimap:2.2.2d--1 \
#   qualimap bamqc -bam "SRR3537005_bismark_bt2_sorted.bam" \
#   -outdir /home/quality -outformat HTML




# nohup bash main.sh 2>&1 &