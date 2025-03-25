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

  CONTAINER_ID=$(docker run --rm -d \
    -v $PWD:/home/gnm \
    -v "$PWD/$main_dir/$srr_val":/home/fstq \
    $bismark_container \
    bismark /home/gnm /home/fstq/$srr_val.fastq)
    # Use this to make it output where you want: -o /home/fstq
    
  docker logs -f "$CONTAINER_ID" >> main.log 2>&1 &
  # Wait for the container to finish
  docker wait "$CONTAINER_ID"

  echo "Script finished"

  # Using nohup with main.sh messing everything up with terminals. use docker wait instead of -it to keep things sequential
done



# docker run --rm -it \
#     -v "$PWD":/home/gnm \
#     -v "$PWD/GSE81541":/home/fstq \
#     quay.io/biocontainers/bismark:0.24.2--hdfd78af_0 \
#     bismark /home/gnm /home/fstq/SRR3537005.fastq
