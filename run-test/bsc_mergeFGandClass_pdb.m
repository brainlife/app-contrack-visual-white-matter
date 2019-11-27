function [mergedFG, mergedClassification]=bsc_mergeFGandClass(inputFGs,inputClassifications)
%% [mergedFG, mergedClassification]=bsc_mergeFGandClass(inputFGs,inputClassifications)
%
% Takes in some number of fg structures (and classification structures) and
% merges them together into one omnibus fg structure (and classification
% structure) wherein the streamiline ordering (and this classification
% indexing) is preserved.
%
%% Inputs/Outputs
% Inputs:
% -inputFGs: either a series of paths to fg structures or an array of fg
% structures. Can be interspersed, and adapt to whatever input type (i.e.
% random assortment of strings, tck, objects etc).
% -inputClassifications: same as above, except for classification
% structures.  Might be slightly more brittle.
%
% Outputs:
% mergedFG: a fibergroup (fg) structure who streamines correspond to all input
% fibergroups (fg)s
% mergedClassification:  a classification structure which
%
%%   IMPORTANT NOTES:
%
%  >THIS FUNCTION REQUIRES VISTASOFT
%
%  >You do not have to put in a classification structure.  In such cases it
%  will basically behave like fgMerge, except it keeps track of the source
%  fibergroups (fg)s in the cassification structure.  Without the
%  classification structure there is no "provenance" on where the source
%  fibergroups came from (which may be fine, given your goals).
%
%  >Input FG structures and classificaiton structures are presumed to be
%  paired.  In other words, in the event that ANYTHING is passed in through
%  the inputClassifications variable (see above), it is presumed that the
%  ii entry in inputFGs corresponds to the ii entry in inputClassifications
%
%  >Even if two classification structures come from the same fg structure it
%  is still necessary to input the appropriate fg + classification pairing.
%  In other words, no orphan classification structures.
%
%
%% Example Uses:
%
%  1.  Merging a tracking parameter sweep:  If you have several different
%  fgs generated by different tractography parameter settings, this will
%  provide a merged fg structure along with a classification structure
%  telling you which streamlines came from which source tractography
%
%  2.  Merging multiple segmentations:  By inputting multiple source whole
%  brain fiber groups (from the same subject), along with the classification structure from each
%  corresponding segmentation, you can create a "merged replication
%  segmentation" which presumably has more streamlines representing each
%  particular tract.
%  NOTE:  Distinct whole brain fiber groups and segmentations can be used.
%  For example...
%
%  wbfg1 & classification method 1 + wbfg2 & classification method 1
%                           or
%  wbfg1 & classification method 1 + wbfg1 & classification method 2
%                           or
%  wbfg1 & classification method 1 + wbfg2 & classification method 2
%                           or
%  etc
%
%  3.  Incorporating tracts generated from other methods into an exsting
%  whole brain fiber group and segmentation:  if one already has a whole
%  brain tractography (and corresponding tractography)  it is possible to
%  "append" more tracts to the source wbfg and classification structure.
%  The tracts to be appended do not need corresponding classification
%  structures and will be added to the existing classification structure
%  (the one that corresponds to the whole brain tractography, should it
%  exist).  Their names will be derived from the name in the fg.name field.
%
% (C) Daniel Bullock, 2018, Indiana University
%
%  Requires vistasoft
%% Begin function
% create a blank classification object if one isn't passed
%doesnt really matter what's in it right now
if ~exist('inputClassifications') ==1
    for iInputs=1:length(inputFGs)
        inputClassifications{iInputs}=[];
    end
end

sourceClassification=[];
sourceClassification.names=[];
sourceClassification.index=[];

mergedClassification.names=[];
mergedClassification.index=[];

%% Merge input FGs, determine homology, and create classification structure
for iInputs=1:length(inputFGs)
    %loads the fg
    [toMergeFG] = fgRead(inputFGs{iInputs});
    
    %checks to see if the .fibers field is empty, or if the thing in the
    %.fibers field is of 0 length (apparently this happens when converting
    %from empty trk files.
    if ~or(length(toMergeFG.fibers)==0,length(toMergeFG.fibers{1})==0);
        
        %if the mergedFG structure doesn't exist yet, take the input fg structure
        %and set that as the mergedFG structure, along with a
        %blank merged classification structure
        
        %initialize structure if this is the first fg
        if ~exist('mergedFG') ==1
            mergedFG=toMergeFG;
            mergedFG.fibers=[];
        end
        
        inputMergedFgLength=length(mergedFG.fibers);
        
        %if the fg is non empty, store the first streamline for fg
        %identification purposes, per Soichi's recommendation.
        streamlineIdentity{iInputs}=toMergeFG.fibers{1};
        
        %now check to see if this streamline is equal to any others that
        %have been added to the amalgum
        for iFgsDone=1:iInputs
            isEqualBool(iFgsDone)=isequal(streamlineIdentity{iInputs},streamlineIdentity{iFgsDone});
        end
        %In theory, this bool vector is empty in all cases except for the
        %current fg structure (i.e. identity) and any other previous fg's
        %that are identical to the fg
        
        %in the event that this is a unique fg, then only one index will be
        %returned and fg merging can continue normally
        if length(find(isEqualBool))==1
            %if this fg is unique, its identity maps to itself
            nameMapping(iInputs)=iInputs;
            
            mergedFG.fibers=vertcat(mergedFG.fibers,toMergeFG.fibers);
            %pointless as the names mean nothing from brain-life.  There's
            %no provenance information in the names
            % mergedFG.name=strcat(mergedFG.name,toMergeFG.name);
            sourceClassification.names=horzcat(sourceClassification.names,strcat('fg',num2str(iInputs)));
            sourceClassification.index(length(sourceClassification.index)+1:length(sourceClassification.index)+length(toMergeFG.fibers),1)=iInputs;
        else
            %under the assumption that length(find(isEqualBool))>2, and
            %thus indicative of this streamline being found in a
            %previous fg
            
            %if this tract is non unique, its identity maps to
            %the first instance of the fg
            nameMapping(iInputs)=min(find(isEqualBool));
            
            %we don't adjust the sourceClassification structure because
            %nothing has changed
            
            %sourceClassification.names=horzcat(sourceClassification.names,strcat('fg',num2str(iInputs)));
            %sourceClassification.index(end+1:end+length(toMergeFG.fibers))=iInputs;
            
        end
        
        fprintf('\n Merge of fg %i, with %i novel streamlines added to amalgum fg for total of %i streamlines',...
            iInputs,length(mergedFG.fibers)-inputMergedFgLength,length(mergedFG.fibers))
    else
        warning('\n fg input number %i contained no streamlines',iInputs)
    end
end



%if the length of the input vectors are not equivalent, append empty
%entries to the classification input such that you don't get indexing
%errors later.
if length(inputClassifications)<length(inputFGs)
    inputClassifications{length(inputClassifications)+1:length(inputFGs)}=[];
end


%iterates for the number of tracts input, now for the purposes of creating
%an amalgum classification structure
for iInputs=1:length(inputFGs)
    
    if ~isempty(inputClassifications{iInputs})
        %probably breaks because of this?
        
        if ischar(inputClassifications{iInputs})
            toMergeclassification=load(inputClassifications{iInputs});
        elseif isfield(inputClassifications{iInputs},'names')
            toMergeclassification=inputClassifications{iInputs};
        else
            warning('\n Input classification type not recognized for input %i',iInputs)
            %completely uninformative name, but it is the best we can
            %do with brainlife .tck input.
            toMergeclassification.names{1}=strcat('fg',num2str(iInputs));
            toMergeclassification.index(1:length(toMergeFG.fibers),1)=1;
        end
        
        
    else
        %if the [iInputs]th entry in inputClassifications is empty,
        %just go ahead and make a single tract classification structure
        %for this fg.
        
        %completely uninformative name, but it is the best we can
        %do with brainlife .tck input.
        toMergeclassification.names{1}=strcat('fg',num2str(iInputs));
        toMergeclassification.index(1:length(toMergeFG.fibers),1)=1;
        
    end
    if nameMapping(iInputs)==iInputs
        %% SPLICE the classification structures, as they correspond to unique fg structures
        
        mergedClassification= bsc_spliceClassifications(mergedClassification,toMergeclassification);
    else
        %% RECONCILE the classification structures, as the current fg corresponds to a previous fg structure
        
        %create a blank vector that is as long as the amalgum fg's fiber
        %field
        bufferedMergeIndexVec=zeros(length(sourceClassification.index),1);
        
        %in the amalgum fg structure, these streamlines correspond to the
        %current fg group, under the first streamline identity presumption
        fgStreamsIndexes=find (sourceClassification.index==nameMapping(iInputs));
        
        %set the entries in the bufferedMergeIndexVec to the appropriate
        %dictionary values
        %dimension mismatch will cause error here.  If classification
        %structure doesn't correspond, likely fail here.
        bufferedMergeIndexVec(fgStreamsIndexes)= toMergeclassification.index;
        
        %set the to merge index to this now modified and buffered
        %dictionary index vector, bufferedMergeIndexVec
        toMergeclassification.index=bufferedMergeIndexVec;
        
        %name should be set, so now we merge
        mergedClassification = bsc_reconcileClassifications(mergedClassification,toMergeclassification);
        
        
        
        
    end
end

end
