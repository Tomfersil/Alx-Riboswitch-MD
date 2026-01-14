#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do
    for rep in {1..2}
    do
        mkdir -p chain-${chain}/rep${rep}/
        ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
        scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/07_Post-eRMSD/rep${rep}_post-equil/*.mdp chain-${chain}/rep${rep}/
        scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/07_Post-eRMSD/rep${rep}_post-equil/*.gro chain-${chain}/rep${rep}/
        scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/W-Prot/chain-${chain}/07_Post-eRMSD/rep${rep}_post-equil/*.sh  chain-${chain}/rep${rep}/
        #
        
    done
done