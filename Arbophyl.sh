#!/bin/bash

if [[ "$1" == "busco" ]]; then
    conda activate busco
    for file in *fasta
    do
        busco -i $file -o ${file/_*/""}/ -l $2 -m genome -c 6
    done
fi

if [[ "$1" == "mafft" ]]; then
    cd FilterBUSCOs_output/
    conda activate mafft
    mkdir MAFFT_output
    for file in *fna
    do
        mafft --auto --inputorder --thread 20 "$file" > "MAFFT_output/${file/MS/"MSA"}"
    done
fi

if [[ "$1" == "trimal" ]]; then
    cd FilterBUSCOs_output/MAFFT_output/
    conda activate trimal
    mkdir Trimmed_MSAs
    mkdir Trimmed_MSAs/Models
    for file in *fna
    do
        mkdir Trimmed_MSAs/Models/${file/_MSA.fna/""}
        trimal -in $file -out Trimmed_MSAs/${file/MSA/"trimmed"} -strict
        cp Trimmed_MSAs/${file/MSA/"trimmed"} Trimmed_MSAs/Models/${file/_MSA.fna/""}
    done
fi

if [[ "$1" == "iqtree_models" ]]; then
    cd FilterBUSCOs_output/MAFFT_output/Trimmed_MSAs/Models
    conda activate iqtree
    for dir in *
    do
    cd $dir
    iqtree -s *.fna -m MF -nt 20
    cd ..
    done
fi

if [[ "$1" == "iqtree" ]]; then
    conda activate iqtree
    iqtree -s FilterBUSCOs_output/MAFFT_output/Trimmed_MSAs/ -p Partition.nex -bb 1000 -alrt 1000 -nt 20 
fi