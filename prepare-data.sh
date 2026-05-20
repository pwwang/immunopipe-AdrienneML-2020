#!/usr/bin/env bash

# get the output directory from $1, if not given, defaults to ./prepared-data
OUTPUT_DIR=${1:-prepared-data}

# get a flag from $2 if we also need to prepare CD45 data
PREPARE_CD45=${2:-true}

# The URL to the tar file
DATAURL="https://ftp.ncbi.nlm.nih.gov/geo/series/GSE144nnn/GSE144469/suppl/GSE144469_RAW.tar"
ABTCRURL="https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE144469&format=file&file=GSE144469%5FTCR%5Ffiltered%5Fcontig%5Fannotations%5Fall%2Ecsv%2Egz"
# DATASHA="8aebf418433603d710df0c3652c616719f8d21c0"
DATAFILE="$OUTPUT_DIR/GSE144469.tar"
ABTCRFILE="$OUTPUT_DIR/abTCR.csv.gz"
CD3_DIR="$OUTPUT_DIR/CD3"
CD45_DIR="$OUTPUT_DIR/CD45"

echo "- Make the directory for prepared data ..."
mkdir -p "$OUTPUT_DIR"

echo "- Download the data if needed ..."
# if [ ! -e $DATAFILE ] || [ "$(shasum $DATAFILE | cut -d' ' -f1)" != "$DATASHA" ]; then
if [ ! -e "$DATAFILE" ]; then
    wget -O "$DATAFILE" $DATAURL
fi

echo "- Extract the data ..."
tar -xvf "$DATAFILE" --directory="$OUTPUT_DIR"

# Prepare CD45 data only if PREPARE_CD45 is set to true
if [ "$PREPARE_CD45" != false ]; then
    echo "- Prepare CD45 data ..."
    for file in $(ls -1b $OUTPUT_DIR/GSM*CD45-*.tar.gz); do
        sample=$(basename "$file" | cut -d- -f1 | cut -d_ -f2)
        mkdir -p "$CD45_DIR"/"$sample"
        tar -zxf "$file" -C "$CD45_DIR"/"$sample" --strip-components=2
    done
fi

echo "- Prepare CD3 data ..."
for file in $(ls -1b $OUTPUT_DIR/GSM*CD3-*.tar.gz); do
    sample=$(basename "$file" | cut -d- -f1 | cut -d_ -f2)
    mkdir -p "$CD3_DIR"/"$sample"
    tar -zxf "$file" -C "$CD3_DIR"/"$sample" --strip-components=2
done

echo "- Download alpha-beta TCR data ..."
wget -O "$ABTCRFILE" "$ABTCRURL"
for sample in $(zcat "$ABTCRFILE"  | grep -v barcode | cut -d, -f2 | cut -d- -f2 | sort -u); do
    zcat "$ABTCRFILE" | head -n1 > "$CD3_DIR"/"$sample"/filtered_contig_annotations.csv
    zcat "$ABTCRFILE" | grep "\-$sample," | sed "s/-$sample,/-1,/" >> "$CD3_DIR"/"$sample"/filtered_contig_annotations.csv
done

echo "- Remove unnecessary files ..."
rm -rf "$OUTPUT_DIR"/*.gz

echo "- Done!"
