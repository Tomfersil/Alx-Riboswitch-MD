#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do
    for rep in {1..2}
    do
        for pH in 7.00 7.50 8.00 8.50 9.00 10.00 11.00 12.00
        do
            mkdir -p chain-${chain}/rep${rep}/pH${pH}/
            ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
            scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/09_CpH-restr/wobble/rep${rep}/pH${pH}/*.mdp chain-${chain}/rep${rep}/pH${pH}/
            scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/09_CpH-restr/wobble/rep${rep}/pH${pH}/*.{gro,occ,mocc,settings} chain-${chain}/rep${rep}/pH${pH}/
            scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/09_CpH-restr/wobble/rep${rep}/pH${pH}/*.sh  chain-${chain}/rep${rep}/pH${pH}/
            #
        done
    done
done