#!/bin/bash -e
Dir=`pwd`


for chain in A B C D
do
    for rep in {1..2}
    do
        for pH in 3.00 4.00 5.00 7.00 7.50 8.00 8.50
        do
            mkdir -p chain-${chain}/rep${rep}/pH${pH}/
            if [ -z "$(ls -A 'chain-${chain}/rep${rep}/pH${pH}/')" ]
            then
                ssh-keygen -f /home/tsilva/.ssh/known_hosts -R login.leonardo.cineca.it ; eval $(ssh-agent) ;step ssh login tfernand@sissa.it --provisioner cineca-hpc
                scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/09_CpH-restr/native/rep${rep}/pH${pH}/*.mdp chain-${chain}/rep${rep}/pH${pH}/
                scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/09_CpH-restr/native/rep${rep}/pH${pH}/*_010.{gro,occ,mocc,settings} chain-${chain}/rep${rep}/pH${pH}/
                scp -o StrictHostKeyChecking=no -r tfernand@login.leonardo.cineca.it:/leonardo_scratch/large/userexternal/tfernand/Projects/Alx-ribo/A-Deprot/chain-${chain}/09_CpH-restr/native/rep${rep}/pH${pH}/*.sh  chain-${chain}/rep${rep}/pH${pH}/
            fi
        done
    done
done