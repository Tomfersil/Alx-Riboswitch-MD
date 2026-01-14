#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do

    mkdir -p chain-${chain}/
    ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
    #scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/01_box-min/*.mdp chain-${chain}
    #scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/01_box-min/*.gro chain-${chain}
    #scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/01_box-min/*.sh  chain-${chain}
    scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/01_box-min/*.{top,itp}  chain-${chain}
done