#!/bin/bash

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
  echo "Fetching fastq for $srr_val..."
  docker run --rm -d -v "$PWD/$main_dir:/home" "$sra_image" prefetch --output-directory /home "$srr_val"
done

