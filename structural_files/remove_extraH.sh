#/bin/bash -e

for chain in A B C D
do
    for rep in {1..2}
    do 
        for frame in {1..2}
        do
            #sed '/H11    A/d' chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}.pdb > tmp
            #sed -i  '/H3     C/d' tmp
            #mv chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}.pdb chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}_prev.pdb
            #mv tmp chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}.pdb
            #gmx editconf -f chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}.pdb -o chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}.pdb
            rm chain-${chain}/Wobble_Prot_${chain}_rep${rep}_${frame}_prev.pdb
        done
    done
done