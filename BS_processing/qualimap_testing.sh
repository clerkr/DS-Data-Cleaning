docker pull quay.io/biocontainers/qualimap:2.2.2d--1

docker run --rm -it \
    --user root \
    -v "$PWD/GSE81541/SRR3537005:/home" \
    quay.io/biocontainers/qualimap:2.2.2d--1

qualimap bamqc -bam SRR3537005_bismark_bt2_sorted -outdir /home/quality -outformat HTML
