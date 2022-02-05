#!/bin/bash

grabDir=$1 # input the directory where your pulling your data from (i.e IRF at IU)
transferDir=$2 # input the directory where you want to copy your data to
data_keys=$3 # this is a keyword that is present in all of your study files (ex ACUTE_SPORTS)

data=(`ls -d ${grabDir}/*${data_keys}*`)

for i in ${data[*]}
do
	# this checks to see if the folder name from grabDir already exists in transferDir. if yes, proceed to next check. 
	# if not, copies data immediately
	if [ -d ${transferDir}/${i#${grabDir}/} ]; then
		mydirfil=`ls ${transferDir}/${i#${grabDir}/} | wc -l`
		irfdirfil=`ls ${i} | wc -l`
		# next check: see if the data is actually present. if yes, skips. if not, copies
		if [[ ${mydirfil} -eq ${irfdirfil} ]]; then
			echo "${i} already exists and all files are accounted for. skipping"
		else
			echo "transfering ${i}"
			rsync -r -c --info=progress2 ${i} ${transferDir}/
		fi
	else	
		echo "transfering ${i}"
		rsync -r -c --info=progress2 ${i} ${transferDir}/
		echo "transfering complete"
	fi
done
