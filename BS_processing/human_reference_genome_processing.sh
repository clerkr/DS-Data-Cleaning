#!/bin/bash

# Define the filename and URL
FILE="hg38.fa.gz"
URL="ftp://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz"
CONTAINER_IMAGE="quay.io/biocontainers/bismark:0.24.2--hdfd78af_0"
MOUNT_PATH="$PWD"
INPUT_FILE="$MOUNT_PATH/hg38.fa"

# Check if the file already exists
if [ -f "$INPUT_FILE" ]; then
    echo "$INPUT_FILE already exists. Skipping download and extraction."
else
    if [ -f "$FILE" ]; then
        echo "$FILE already exists. Skipping download."
    else
        echo "Downloading $FILE..."
        wget "$URL"
        if [ $? -ne 0 ]; then
            echo "Download failed." >&2
            exit 1
        fi
    fi
    
    echo "Extracting $FILE..."
    gunzip -f "$FILE"
    if [ $? -eq 0 ]; then
        echo "Extraction completed successfully."
    else
        echo "Extraction failed." >&2
        exit 1
    fi
fi

# Check if the container image is already pulled
docker image inspect "$CONTAINER_IMAGE" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Pulling Docker container $CONTAINER_IMAGE..."
    docker pull "$CONTAINER_IMAGE"
fi

# Run Bismark genome preparation in the container
echo "Running Bismark genome preparation..."
docker run -it -v "$MOUNT_PATH:/home" "$CONTAINER_IMAGE" bismark_genome_preparation "/home" "/home/hg38.fa"
