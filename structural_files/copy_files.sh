#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do
    for rep in {1..2}
    do
        mkdir -p chain-${chain}/
        ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
        scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Prot/chain-${chain}/06_eRMSD/rep${rep}/equil/run_equil_ermsd.pdb chain-${chain}/wobble_prot_rep${rep}.pdb
        scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/01_box-min/min3.gro chain-${chain}/native_deprot.gro
    done
done