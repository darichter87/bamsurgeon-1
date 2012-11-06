#!/bin/sh

# adds up to 100 SNPs to a ~770 kb region around the LARGE gene
# requires samtools/bcftools

if [ $# -ne 2 ]
then
    echo "usage: $0 <number of SNPs> <reference indexed with bwa index>"
    exit 65
fi

if [ ! -e ../addsnv.py ]
then
    echo "addsnv.py isn't one directory level down (../addsnv.py) as expected"
    exit 65
fi

if [ ! -e $2 ]
then
    echo "can't find reference .fasta: $2, please supply a bwa-indexed .fasta"
    exit 65
fi

if [ ! -e $2.bwt ]
then
    echo "can't find $2.bwt: is $2 indexed with bwa?"
    exit 65
fi

if ! [[ $1 =~ ^[0-9]+$ ]]
then
    echo "arg 1 must be an integer (number of SNVs to add)"
    exit 65
fi

if [ $1 -gt 100 ]
then
    echo "max number of SNVs must be <= 100"
    exit 65
fi

if [ $1 -lt 1 ]
then
    echo "min number of SNVs must be > 0"
    exit 65
fi

../addsnv.py -v ../test_data/random_snvs.txt -f ../test_data/testregion.bam -r $2 -o ../test_data/testregion_mut.bam -n $1 -c ../test_data/test_cnvlist.txt.gz
if [ $? -ne 0 ]
then
 echo "addsnv.py failed."
 exit 65
else
  samtools mpileup -ugf $2 ../test_data/testregion_mut.bam | bcftools view -bvcg - > result.raw.bcf
  bcftools view result.raw.bcf
fi