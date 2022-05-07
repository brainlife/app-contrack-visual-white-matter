#!/bin/bash

rois=`jq -r '.rois' config.json`
lgn=`jq -r '.lgn' config.json`
eccentricity=`jq -r '.eccentricity' config.json`
v1=`jq -r '.v1' config.json`
freesurfer=`jq -r '.freesurfer' config.json`
dtiinit=`jq -r '.dtiinit' config.json`
anat=`jq -r '.t1' config.json`
hemis="left right"

mkdir tmpSubj tmpSubj/dtiinit
cp -R ${dtiinit}/* ./tmpSubj/dtiinit && chmod -R +w tmpSubj/*
cp -R ${eccentricity} ./tmp.eccentricity.nii.gz && mri_vol2vol --mov ./tmp.eccentricity.nii.gz --targ ${anat} --regheader --interp nearest --o ./eccentricity.nii.gz

# convert hemispheric ribbons
for hemi in ${hemis}
do
  if [[ ${hemi} == 'left' ]]; then
    hem="lh"
  else
    hem="rh"
  fi
  mri_convert $freesurfer/mri/${hem}.ribbon.mgz ./tmp.${hem}.ribbon.nii.gz && mri_vol2vol --mov ./tmp.${hem}.ribbon.nii.gz --targ ${anat} --regheader --interp nearest --o ./${hem}.ribbon.nii.gz

  # copy over lgn and v1
  cp -R ${rois}/*${hem}.${lgn}.nii.gz ./tmp.ROI${hem}.lgn.nii.gz && mri_vol2vol --mov ./tmp.ROI${hem}.lgn.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.lgn.nii.gz
  cp -R ${rois}/*${hem}.${v1}.nii.gz ./tmp.ROI${hem}.v1.nii.gz && mri_vol2vol --mov ./tmp.ROI${hem}.v1.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.v1.nii.gz
  [ -f ${rois}/*${hem}.exclusion.nii.gz ] && cp -R ${rois}/*${hem}.exclusion.nii.gz ./tmp.ROI${hem}.exclusion.nii.gz  && mri_vol2vol --mov ./tmp.ROI${hem}.exclusion.nii.gz --targ ${anat} --regheader --interp nearest --o ./ROI${hem}.exclusion.nii.gz
done

# convert ribbon
mri_convert $freesurfer/mri/ribbon.mgz tmp.ribbon.nii.gz && mri_vol2vol --mov ./tmp.ribbon.nii.gz --targ ${anat} --regheader --interp nearest --o ./ribbon.nii.gz

mri_vol2vol --mov ./tmp.csf.nii.gz --targ ${anat} --regheader --interp neareast --o ./csf.nii.gz