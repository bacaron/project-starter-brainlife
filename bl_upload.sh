#!/bin/bash

# This script will upload t1, t2, and dwi data to brainlife.io
# assumes data has been nifti converted using dcm2niix with -o option used
# also requires having brainlife cli installed and being logged into the cli (see cli documentation: https://brainlife.io/docs/cli/install/)

# top variables (user input)
topPath=$1 # this is the top directory of where the data lives
subjectID=$2 # this is the subject ID you want to use on brainlife.io
session_id=$3 # this is the session ID you want to use on brainlife.io
t1_name_id=$4 # this is an identifyer that can be used to select the t1w data
t2_name_id=$5 # this is an identifyer that can be used to select the t2w data
dwi_one_id=$6 # this is an identifyer that can be used to select the first phase encoding direction dwi data
dwi_two_id=$7 # this is an identifyer that can be used to select the second phase encoding direction dwi data (can be b0)
dwi_one_phase=$8 # this is a tag for the phase encoding direction for the first dwi (ex. AP, PA)
dwi_two_phase=$9 # this is a tag for the phase encoding direction for the second dwi (ex. AP, PA)
projectID=${10} # this is the project id on brainlife where the data will be uploaded

## grab data
# t1
t1s=(`ls ${topPath}/*${t1_name_id}*.nii`)
t1s_json=(`ls ${topPath}/*${t1_name_id}*.json`)

# t2
t2s=(`ls ${topPath}/*${t2_name_id}*.nii`)
t2s_json=(`ls ${topPath}/*${t2_name_id}*.json`)

# dwi: first phase encoding direction
dwis_ap=(`ls ${topPath}/*${dwi_one_id}*.nii`)
dwis_ap_bvals=(`ls ${topPath}/*${dwi_one_id}*.bval`)
dwis_ap_bvecs=(`ls ${topPath}/*${dwi_one_id}*.bvec`)
dwis_ap_json=(`ls ${topPath}/*${dwi_one_id}*.json`)

# dwi: second phase encoding direction (could also be b0)
dwis_pa=(`ls ${topPath}/*${dwi_two_id}*.nii`)
dwis_pa_bvals=(`ls ${topPath}/*${dwi_two_id}*.bval`)
dwis_pa_bvecs=(`ls ${topPath}/*${dwi_two_id}*.bvec`)
dwis_pa_json=(`ls ${topPath}/*${dwi_two_id}*.json`)

#upload t1s
for i in ${!t1s[@]}
do
	if [[ ! ${t1s[${i}]:(-3)} == '.gz' ]]; then 
		if [ ! -f ${t1s[${i}]}.gz ]; then
			gzip -c ${t1s[${i}]} > ${t1s[${i}]}.gz
		fi
		imgsess_id=`echo ${t1s[${i}]##*_}` # grabs everything after last underscore
		imgsess_tag="image_${imgsess_id%.nii}" # grabs the session number before the .nii extension
		echo "$imgsess_tag"

		# check if data has been uploaded to bl already
		bl_check=(`bl dataset query --project ${projectID} --subject ${subjectID} --session ""${session_id}"" --datatype neuro/anat/t1w --datatype_tag ""${imgsess_tag}"" --datatype_tag ""${session_id}"" --json`)
		echo ${bl_check}
		if [[ "${bl_check}" == '[]' ]]; then
			echo "uploading ${t1s[${i}]}"
			bl data upload --project ${projectID} \
				--subject ${subjectID} \
				--session ""${session_id}"" \
				--datatype neuro/anat/t1w \
				--t1 ${t1s[$i]}.gz \
				--meta ${t1s_json[$i]} \
				--datatype_tag ""${imgsess_tag}"" \
				--datatype_tag ""${session_id}"" \
				--tag ""${imgsess_tag}"" \
				--tag ""${session_id}""
			echo "uploading complete"
		fi
	fi
done

#upload t2s
for i in ${!t2s[@]}
do
	if [[ ! ${t2s[${i}]:(-3)} == '.gz' ]]; then
		echo "uploading ${t2s[${i}]}"
		if [ ! -f ${t2s[${i}]}.gz ]; then
			gzip -c ${t2s[${i}]} > ${t2s[${i}]}.gz
		fi
		imgsess_id=`echo ${t2s[${i}]##*_}` # grabs everything after last underscore
		imgsess_tag="image_${imgsess_id%.nii}" # grabs the session number before the .nii extension
		
		# check if data has been uploaded to bl already
		bl_check=(`bl dataset query --project ${projectID} --subject ${subjectID} --session ""${session_id}"" --datatype neuro/anat/t2w --datatype_tag ""${imgsess_tag}"" --datatype_tag ""${session_id}"" --json`)
		if [[ ${bl_check} == '[]' ]]; then			
			echo "uploading ${t2s[${i}]}"
			bl data upload --project ${projectID} \
				--subject ${subjectID} \
				--session ""${session_id}"" \
				--datatype neuro/anat/t2w \
				--t2 ${t2s[$i]}.gz \
				--meta ${t2s_json[$i]} \
				--datatype_tag ""${imgsess_tag}"" \
				--datatype_tag ""${session_id}"" \
				--tag ""${imgsess_tag}"" \
				--tag ""${session_id}""
			echo "uploading complete"
		fi
	fi
done

#upload dwi ap
for i in ${!dwis_ap[@]}
do
	if [[ ! ${dwis_ap[${i}]:(-3)} == '.gz' ]]; then
		if [ ! -f ${dwis_ap[${i}]}.gz ]; then
			gzip -c ${dwis_ap[${i}]} > ${dwis_ap[${i}]}.gz
		fi
		imgsess_id=`echo ${dwis_ap[${i}]##*_}` # grabs everything after last underscore
		imgsess_tag="image_${imgsess_id%.nii}" # grabs the session number before the .nii extension

		# check if data has been uploaded to bl already
		bl_check=(`bl dataset query --project ${projectID} --subject ${subjectID} --session ""${session_id}"" --datatype neuro/dwi --datatype_tag ""${imgsess_tag}"" --datatype_tag ""${session_id}"" --tag "AP" --json`)
		if [[ ${bl_check} == '[]' ]]; then
			echo "uploading ${dwis_ap[${i}]}"
			bl data upload --project ${projectID} \
				--subject ${subjectID} \
				--session ""${session_id}"" \
				--datatype neuro/dwi \
				--dwi ${dwis_ap[$i]}.gz \
				--bvals ${dwis_ap_bvals[$i]} \
				--bvecs ${dwis_ap_bvecs[$i]} \
				--meta ${dwis_ap_json[$i]} \
				--datatype_tag ""${imgsess_tag}"" \
				--datatype_tag ""${session_id}"" \
				--tag ""${imgsess_tag}"" \
				--tag ""${session_id}"" \
				--tag ""${dwi_one_phase}"" \
			echo "uploading complete"
		fi
	fi
done

#upload dwi pa
for i in ${!dwis_pa[@]}
do
	if [[ ! ${dwis_pa[${i}]:(-3)} == '.gz' ]]; then
		if [ ! -f ${dwis_pa[${i}]}.gz ]; then 
			gzip -c ${dwis_pa[${i}]} > ${dwis_pa[${i}]}.gz
		fi
		imgsess_id=`echo ${dwis_pa[${i}]##*_}` # grabs everything after last underscore
		imgsess_tag="image_${imgsess_id%.nii}" # grabs the session number before the .nii extension

		# check if data has been uploaded to bl already
		bl_check=(`bl dataset query --project ${projectID} --subject ${subjectID} --session ""${session_id}"" --datatype neuro/dwi --datatype_tag ""${imgsess_tag}"" --datatype_tag ""${session_id}"" --tag "PA" --json`)
		if [[ ${bl_check} == '[]' ]]; then
			echo "uploading ${dwis_pa[${i}]}"
			bl data upload --project ${projectID} \
				--subject ${subjectID} \
				--session ""${session_id}"" \
				--datatype neuro/dwi \
				--dwi ${dwis_pa[$i]}.gz \
				--bvals ${dwis_pa_bvals[$i]} \
				--bvecs ${dwis_pa_bvecs[$i]} \
				--meta ${dwis_pa_json[$i]} \
				--datatype_tag ${imgsess_tag} \
				--datatype_tag ""${session_id}"" \
				--tag ""${imgsess_tag}"" \
				--tag ""${session_id}"" \
				--tag ""${dwi_one_phase}"" \
			echo "uploading complete"
		fi
	fi
done
