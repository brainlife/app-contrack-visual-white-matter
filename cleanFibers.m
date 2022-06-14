function [classification,mergedFG] = cleanFibers(topDir,threshold,config)

% variables
rois = fullfile('tmpSubj','dtiinit','ROIs/');
vwmFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','OR','fg_*.pdb'));
% 
%% Generate AND & NOT ROIs for fiber cleaning and selection
% hemisphere
hemi = {'left','right'};

for hh = 1:length(hemi)
	if strcmp(hemi{hh},'left')
		hemisphereROI.(hemi{hh}) = bsc_loadAndParseROI('ribbon_right.nii.gz');
        exclusionROI.(hemi{hh}) = bsc_loadAndParseROI('ROIlh.exclusion.nii.gz');
        referenceNifti.(hemi{hh}) = niftiRead([rois,sprintf('lgn_left_%s.nii.gz',num2str(config.inflate_lgn))]);
	else
		hemisphereROI.(hemi{hh}) = bsc_loadAndParseROI('ribbon_left.nii.gz');
        exclusionROI.(hemi{hh}) = bsc_loadAndParseROI('ROIrh.exclusion.nii.gz');
        referenceNifti.(hemi{hh}) = niftiRead([rois,sprintf('%s_right_%s.nii.gz',config.start_roi,num2str(config.inflate_lgn))]);
	end
end

% CSF ROI
csfROI = bsc_loadAndParseROI('csf_bin.nii.gz');

% % NOT ROIs
for hh = 1:length(hemi)
	Not.(hemi{hh}) = bsc_mergeROIs(exclusionROI.(hemi{hh}),csfROI);
    Not.(hemi{hh}) = bsc_mergeROIs(Not.(hemi{hh}),hemisphereROI.(hemi{hh}));
end

%% Score fibers to get best streamlines possible
textPaths = dir(fullfile(topDir,'/tmpSubj/dtiinit/dti/fibers/conTrack/visual-white-matter/ctrSampler_visual-white-matter*.txt'));
for i = 1:length(textPaths)
    % set up names and variables for score
    textPath = fullfile(sprintf('%s/%s',textPaths(i).folder,textPaths(i).name));
    track_pdb_name = extractBetween(textPaths(i).name,'visual-white-matter_','.txt');
    pdbPath = fullfile(sprintf('%s/fg_OR_%s.pdb',textPaths(i).folder,track_pdb_name{1}));
    pdbOutPath = fullfile(sprintf('%s/contrack_pruned_fg_visual-white-matter_%s.pdb',textPaths(i).folder,track_pdb_name{1}));

    % write command
    scoreCmd = sprintf('%s/contrack_score.glxa64 -i %s -p %s --thresh %s --sort %s',topDir,textPath,pdbOutPath,num2str(threshold),pdbPath)
    
    % run command
    system(scoreCmd)
end

%% grab fibers that cross specific boundaries
vwmFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','visual-white-matter','contrack_pruned_*.pdb'));

for ifg = 1:length(vwmFibersDir)
    fg = fgRead(sprintf('%s/%s',vwmFibersDir(ifg).folder,vwmFibersDir(ifg).name));
    
    % no idea as to why need to do this, or why 180, or why it works, but it seems to work so idk. figure out later
    for dfg = 1:length(fg.fibers)
        fg.fibers{dfg}(1,:) = -(fg.fibers{dfg}(1,:)) + 180;
    end

    hem = extractBetween(vwmFibersDir(ifg).name,sprintf('%s_',config.start_roi),sprintf('_%s',num2str(config.inflate_start_roi)));
    
    outname = sprintf('%s/%s_planes_pruned_contrack_pruned_%s',config.start_roivwmFibersDir(ifg).folder,vwmFibersDir(ifg).name)
    [fgOut,keepFG] = wma_SegmentFascicleFromConnectome_Bl(fg,referenceNifti.(hemi{hh}).pixdim(1),Not.(hem{1})},{'and','not'},outname);
    mtrExportFibers(fgOut,outname,[],[],[],3)
end

%% Load tracts and clip for cleaning
% load and clip optic radiations
vwmFibersDir = dir(fullfile('tmpSubj','dtiinit','dti','fibers','conTrack','visual-white-matter',sprintf('%s_',config.start_roi),'_planes_pruned_contrack_pruned_*.pdb'));
counter=1;
for ifg = 1:length(vwmFibersDir)
	tmp = fgRead(fullfile(vwmFibersDir(ifg).folder,vwmFibersDir(ifg).name));
    if length(tmp.fibers) > 0
        fgPath{counter} = tmp;
        counter=counter+1;
    end
    clear tmp
end

% need specific modification to how pdb fgs are loaded
[mergedFG,classification] = bsc_mergeFGandClass([fgPath]);

for ifg = 1:length(fgPath)
    classification.names(ifg) = extractBetween(fgPath{ifg}.name,'fg_visual-white-matter_','_20');
end

mergedFG.name = sprintf('%s_%s',config.start_roi,config.term_roi;

% find better way to index this
mergedFG.params = {};
mergedFG.params{1} = 'mrtrix_header';
mergedFG.params{2}{1} = 'mrtrix tracks    ';
mergedFG.params{2}{2} = 'mrtrix_version: 3.0_RC3';
mergedFG.params{2}{3} = 'timestamp: 1573277529.4060957432';
mergedFG.params{2}{4} = 'datatype: Float32LE';
mergedFG.params{2}{5} = 'file: . 160';
mergedFG.params{2}{6} = sprintf('count: %s',num2str(length(mergedFG.fibers)));
mergedFG.params{2}{7} = sprintf('total_count: %s',num2str(length(mergedFG.fibers)));

% save tck
dtiExportFibersMrtrix_tracks(mergedFG,'track.tck');