#!/usr/bin/env bash

# The URL to the tar file
DATAURL="https://ftp.ncbi.nlm.nih.gov/geo/series/GSE144nnn/GSE144469/suppl/GSE144469_RAW.tar"
ABTCRURL="https://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE144469&format=file&file=GSE144469%5FTCR%5Ffiltered%5Fcontig%5Fannotations%5Fall%2Ecsv%2Egz"
# DATASHA="8aebf418433603d710df0c3652c616719f8d21c0"
DATAFILE="prepared-data/GSE144469.tar"
ABTCRFILE="prepared-data/abTCR.csv.gz"
CD3_DIR="prepared-data/CD3"
CD45_DIR="prepared-data/CD45"

echo "- Make the directory for prepared data ..."
mkdir -p prepared-data

echo "- Download the data if needed ..."
# if [ ! -e $DATAFILE ] || [ "$(shasum $DATAFILE | cut -d' ' -f1)" != "$DATASHA" ]; then
if [ ! -e $DATAFILE ]; then
    wget -O $DATAFILE $DATAURL
fi

echo "- Extract the data ..."
tar -xvf $DATAFILE --directory=./prepared-data

echo "- Prepare CD45 data ..."
for file in $(ls -1b prepared-data/GSM*CD45-*.tar.gz); do
    sample=$(basename "$file" | cut -d- -f1 | cut -d_ -f2)
    mkdir -p $CD45_DIR/"$sample"
    tar -zxf "$file" -C $CD45_DIR/"$sample" --strip-components=2
done

echo "- Prepare CD3 data ..."
for file in $(ls -1b prepared-data/GSM*CD3-*.tar.gz); do
    sample=$(basename "$file" | cut -d- -f1 | cut -d_ -f2)
    mkdir -p $CD3_DIR/"$sample"
    tar -zxf "$file" -C $CD3_DIR/"$sample" --strip-components=2
done
# for file in $(ls -1b prepared-data/GSM*-gdTCR_*.csv.gz); do
#     sample=$(basename "$file" | cut -d- -f1 | cut -d_ -f2)
#     mkdir -p $CD3_DIR/"$sample"
#     mv "$file" $CD3_DIR/"$sample"/filtered_contig_annotations.csv.gz
# done

echo "- Download alpha-beta TCR data ..."
wget -O $ABTCRFILE "$ABTCRURL"
for sample in $(zcat $ABTCRFILE  | grep -v barcode | cut -d, -f2 | cut -d- -f2 | sort -u); do
    zcat $ABTCRFILE | head -n1 > $CD3_DIR/"$sample"/filtered_contig_annotations.csv
    zcat $ABTCRFILE | grep "\-$sample," | sed "s/-$sample,/-1,/" >> $CD3_DIR/"$sample"/filtered_contig_annotations.csv
done

echo "- Remove unnecessary files ..."
rm -rf prepared-data/*.gz

echo "- Done!"
