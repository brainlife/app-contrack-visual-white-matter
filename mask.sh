#!/bin/bash

rois=`jq -r '.rois' config.json`
roi1=`jq -r '.seed_roi' config.json`
eccentricity=`jq -r '.eccentricity' config.json`

# make left hemisphere eccentricity
fslmaths $eccentricity -mul lh.ribbon.nii.gz eccentricity_left.nii.gz
# make right hemisphere eccentricity
fslmaths $eccentricity -mul rh.ribbon.nii.gz eccentricity_right.nii.gz

fslmaths csf.nii.gz csf_bin.nii.gz
