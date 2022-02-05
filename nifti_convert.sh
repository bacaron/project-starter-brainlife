#!/bin/bash

# this script uses dcm2niix to convert raw dicoms to nifti images

# top variables
topDir=$1 # this is where the raw dicoms live
outputDir=${topDir}/$2 # this is folder inside topDir where you want the niftis to live

# if outputdir doesnt exist, make it
[ ! -f ${outputDir} ] && mkdir -p ${outputDir}

# convert data to nifti
echo "converting ${topDir}"
dcm2niix -o ${outputDir} ${topDir}
echo "conversion complete"
