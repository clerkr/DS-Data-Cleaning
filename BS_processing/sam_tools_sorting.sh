#!/bin/bash

main_dir=$1
srr_val=$2

CONTAINER="quay.io/biocontainers/samtools:1.21--h96c455f_1"

docker pull "$CONTAINER"

CONTAINER_ID=$(docker run --rm -d \
    --user root \
    -v "$PWD/$main_dir/$srr_val:/home" \
    -w /home \
    "$CONTAINER" \
    samtools sort SRR3537005_bismark_bt2.bam \
    -o "SRR3537005_bismark_bt2_sorted.bam"
)

docker logs -f "$CONTAINER_ID" >> sorting.log 2>&1 &

docker wait "$CONTAINER_ID"


# nohup bash sam_tools_sorting.sh GSE81541 SRR3537005 > sorting_testing.log 2>&1 &

# docker run --rm -it \
#     --user root \
#     -v "$PWD/GSE81541/SRR3537005:/home" \
#     -w /home \
#     "quay.io/biocontainers/samtools:1.21--h96c455f_1" \
#     samtools sort SRR3537005_bismark_bt2.bam \
#     -o "SRR3537005_bismark_bt2_sorted.bam"

# samtools sort SRR3537005_bismark_bt2.bam -o "SRR3537005_bismark_bt2_sorted.bam" 