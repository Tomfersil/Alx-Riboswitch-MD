#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do

    mkdir -p chain-${chain}/
    ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
    scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/02_initial/*.mdp chain-${chain}
    scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/02_initial/*.gro chain-${chain}
    scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/02_initial/*.sh  chain-${chain}
done