#!/bin/bash

#SBATCH --mail-type=fail
#SBATCH --job-name="methyl"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --mem=90G
#SBATCH --partition=pibu_el8
#SBATCH -x binfservas18

# This code uses SMRTlink data and tools to detect the methylated motif.

export SMRT_ROOT=$3
export TMPDIR="smrttempdir1"

ret=$(pwd)
cd ../SMRTlink
KNOW=$(pwd)
cd $ret
export PATH=$KNOW:$PATH


THREADS=$SLURM_CPUS_PER_TASK

#the NAME corresponds to the sample name given on command-line
NAME=$1

#the directory containing the 3 starting files:
DIRECT=$2

mkdir METH_${NAME}
cd METH_${NAME}

ln -s ${DIRECT}/${NAME}.bam .
ln -s ${DIRECT}/${NAME}.bam.pbi .
ln -s ${DIRECT}/${NAME}.fasta .
samtools faidx ${NAME}.fasta 

#build reference from contigs
$SMRT_ROOT/smrtcmds/bin/dataset create --type ReferenceSet --name ${NAME} ${NAME}.xml ${NAME}.fasta --force

#build subreadset
$SMRT_ROOT/smrtcmds/bin/dataset create --type SubreadSet --name ${NAME} ${NAME}.subreadset.xml ${NAME}.bam

#convert raw reads by strand 
$SMRT_ROOT/smrtcmds/bin/ccs-kinetics-bystrandify ${NAME}.bam ${NAME}_ccs.bam

#build subreadset
$SMRT_ROOT/smrtcmds/bin/dataset create --type SubreadSet --name ${NAME} ${NAME}.subreadsetccs.xml ${NAME}_ccs.bam

#align
$SMRT_ROOT/smrtcmds/bin/pbmm2 align --preset HIFI -j ${THREADS} -J ${THREADS} --sort -m 5G ${NAME}.xml ${NAME}.subreadsetccs.xml ${NAME}_aligned.bam

#get modifications
$SMRT_ROOT/smrtcmds/bin/pbindex ${NAME}_aligned.bam
$SMRT_ROOT/smrtcmds/bin/ipdSummary ${NAME}_aligned.bam -j ${THREADS} --reference ${NAME}.fasta --identify m6A,m4C --gff basemods.gff --useChemistry SP3-C3

#get motifs
$SMRT_ROOT/smrtcmds/bin/pbmotifmaker find -j ${THREADS} --min-score 30.0 ${NAME}.fasta basemods.gff motifs.csv
$SMRT_ROOT/smrtcmds/bin/pbmotifmaker reprocess -j ${THREADS} ${NAME}.fasta basemods.gff motifs.csv motifs.gff



