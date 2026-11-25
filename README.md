[![Abcdspec-compliant](https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg)](https://github.com/brain-life/abcd-spec)
[![Run on Brainlife.io](https://img.shields.io/badge/Brainlife-brainlife.app.647-blue.svg)](https://doi.org/https://doi.org/10.25663/brainlife.app.647)

# Track Visual White Matter Tracks by Visual Field Eccentricty: Contrack

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

**Tracks visual white matter between user-chosen pairs of ROIs (such as eccentricity-binned V1 or LGN ROIs) with ConTrack probabilistic tractography.**

For each start/termination ROI pair, resamples the ROIs to the T1, removes them from the CSF and exclusion masks, runs ConTrack, keeps the top-scoring streamlines with contrack_score, and cleans them. Eccentricity binning comes from the ROI names you pass (for example ROIs from a pRF eccentricity App). Needs a dtiinit, a T1, ROIs, pRF, a 5TT mask and FreeSurfer; expect up to 32 hours.

Run it on brainlife.io: [https://doi.org/10.25663/brainlife.app.647](https://doi.org/10.25663/brainlife.app.647)

| Input | Datatype | Required | Description |
|---|---|---|---|
| `dtiinit` | `neuro/dtiinit` | yes | dtiinit output (vistasoft) providing the diffusion data and tensor fit used by ConTrack. |
| `t1` | `neuro/anat/t1w` | yes | T1-weighted image that defines the working space; ROIs, eccentricity, ribbons and CSF are resampled to it. |
| `rois` | `neuro/rois` | yes | ROIs to track between; files are found by the names given in start_roi, term_roi and exclusion_roi. |
| `prf` | `neuro/prf` | yes | Population receptive field (pRF) maps; the eccentricity map is used to split visual cortex into eccentricity bins. |
| `mask` | `neuro/mask` (5tt_masks) | no | MRtrix3 five-tissue-type (5TT) mask; its CSF volume is used as an exclusion region. |
| `freesurfer` | `neuro/freesurfer` | yes | FreeSurfer subject directory; the cortical ribbon (ribbon.mgz, lh/rh.ribbon.mgz) restricts eccentricity to cortex and defines hemisphere exclusions. |

| Output | Datatype | Description |
|---|---|---|
| `track` | `neuro/track/tck` | Tractogram (.tck) of the cleaned ConTrack streamlines for all ROI pairs. |
| `wmc` | `neuro/wmc` | White matter classification assigning streamlines to one tract per ROI pair, with tract JSONs for visualisation and fiber counts. |

| Parameter | Type | Default | Description |
|---|---|---|---|
| `nSamples` | number | `50000` | Number of streamlines desired. NOTE: This may not be final total as tracking is performed without anatomical constraints (i.e. csf exclusion) |
| `maxNodes` | number | `240` | Maximum number of nodes (points) per ConTrack streamline. |
| `minNodes` | number | `100` | Minimum number of nodes (points) per ConTrack streamline. |
| `stepSize` | number | `1` | ConTrack step size. |
| `contrackThreshold` | number | `5000` | Number of top-scoring streamlines kept per tract (passed to contrack_score --thresh). |
| `start_roi` | string |  | names of seed ROIs for each tract (separated by spaces) you want to track. To use this to track by eccentricity, make sure to include the appropriate naming for that specific eccentricity-binned ROI. For example, if you wanted to track lh v1 to rh v1 binned by eccentricity values 7 to 15, and the name of the lh roi is "ROI.lh.v1.Ecc7to15.nii.gz", start_roi == "lh.v1.Ecc7to15" |
| `term_roi` | string |  | names of termination ROIs for each tract (separated by spaces) you want to track. To use this to track by eccentricity, make sure to include the appropriate naming for that specific eccentricity-binned ROI. For example, if you wanted to track lh v1 to rh v1 binned by eccentricity values 7 to 15, and the name of the rh roi is "ROI.rh.v1.Ecc7to15.nii.gz", term_roi == "rh.v1.Ecc7to15" |
| `inflate_start_roi` | number | `1` | Inflation applied to the start ROIs before tracking (1 = no inflation). |
| `inflate_term_roi` | number | `1` | Inflation applied to the termination ROIs before tracking (1 = no inflation). |
| `minDistanceClean` | number | `0.87` | Distance threshold for an ROI-exclusion cleaning step; that step is commented out in this branch, so the value is not used. |
| `exclusion_roi` | string |  | names of exclusion ROIs for each tract (separated by spaces) you want to track. |

Runtime: container `brainlife/mrtrix3:3.0_RC3`; 1 CPUs; 20 GB memory; 32 h walltime; needs `FREESURFER_LICENSE`.

Please cite:
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)
- Sherbondy AJ, Dougherty RF, Ben-Shachar M, Napel S, Wandell BA. ConTrack: finding the most likely pathways between brain regions using diffusion tractography. J Vis 8(9):15 (2008). [doi:10.1167/8.9.15](https://doi.org/10.1167/8.9.15)
- Ogawa S, Takemura H, Horiguchi H, et al. White Matter Consequences of Retinal Receptor and Ganglion Cell Damage. Invest Ophthalmol Vis Sci 55(10):6976-6986 (2014). [doi:10.1167/iovs.14-14737](https://doi.org/10.1167/iovs.14-14737)
- Yoshimine S, Ogawa S, Horiguchi H, et al. Age-related macular degeneration affects the optic radiation white matter projecting to locations of retinal damage. Brain Struct Funct 223(8):3889-3900 (2018). [doi:10.1007/s00429-018-1702-5](https://doi.org/10.1007/s00429-018-1702-5)

<!-- brainlife-app:end -->

This app will track Visual White Matter Tracks by Visual Field Eccentricty using Contrack (Sherbondy et al, 2009). Specifically, this app will track between two rois provided by the user and then segment it into multiple bundles based on the visual property of eccentricity derived from population receptive field (prf) mapping. This app takes a dtiinit, anat/t1w, rois, prf, mask (tissue type), and freesurfer datatypes and outputs a track/tck and wmc datatype.

### Authors

- Brad Caron (bacaron@utexas.edu)

### Contributors

- Soichi Hayashi (shayashi@iu.edu)

### Funding Acknowledgement

brainlife.io is publicly funded and for the sustainability of the project it is helpful to Acknowledge the use of the platform. We kindly ask that you acknowledge the funding below in your publications and code reusing this code.

[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-1636893](https://img.shields.io/badge/NSF_BCS-1636893-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-ACI-1916518](https://img.shields.io/badge/NSF_ACI-1916518-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1916518)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://grantome.com/grant/NIH/R01-EB029272-01)

### Citations

We kindly ask that you cite the following articles when publishing papers and code using this code.

1. Avesani, P., McPherson, B., Hayashi, S. et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). https://doi.org/10.1038/s41597-019-0073-y

2. Sherbondy AJ, Dougherty RF, Ben-Shachar M, Napel S, Wandell BA. ConTrack: finding the most likely pathways between brain regions using diffusion tractography. J Vis. 2008;8(9):1-16. Published 2008 Jul 29. doi:10.1167/8.9.15

3. Shumpei Ogawa, Hiromasa Takemura, Hiroshi Horiguchi, Masahiko Terao, Tomoki Haji, Franco Pestilli, Jason D. Yeatman, Hiroshi Tsuneoka, Brian A. Wandell, Yoichiro Masuda; White Matter Consequences of Retinal Receptor and Ganglion Cell Damage. Invest. Ophthalmol. Vis. Sci. 2014;55(10):6976-6986. doi: https://doi.org/10.1167/iovs.14-14737.

4. Yoshimine S, Ogawa S, Horiguchi H, Terao M, Miyazaki A, Matsumoto K, Tsuneoka H, Nakano T, Masuda Y, Pestilli F. Age-related macular degeneration affects the optic radiation white matter projecting to locations of retinal damage. Brain Struct Funct. 2018 Nov;223(8):3889-3900. doi: 10.1007/s00429-018-1702-5. Epub 2018 Jun 27. PMID: 29951918.

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University

## Running the App

### On Brainlife.io

You can submit this App online at [https://doi.org/https://doi.org/10.25663/brainlife.app.647](https://doi.org/https://doi.org/10.25663/brainlife.app.647) via the 'Execute' tab.

### Running Locally (on your machine)

1. git clone this repo

2. Inside the cloned directory, create `config.json` with something like the following content with paths to your input files.

```json
{
	"dtiinit": "/input/dtiinit",
	"t1": "/input/t1/t1.nii.gz",
	"rois": "/input/rois/rois",
	"eccentricity": "/input/prf/eccentricity.nii.gz",
	"varea": "/input/prf/varea.nii.gz",
	"mask": "/input/5tt/mask.nii.gz",
	"freesurfer": "/input/freesurfer/output",
	"count": 200,
	"minnodes": 10,
	"stepsize": 1,
	"seed_roi": "008109",
	"term_roi": "v1",
	"MinDegree": "0 15 30",
	"MaxDegree": "3 30 90"
}
```

### Sample Datasets

You can download sample datasets from Brainlife using [Brainlife CLI](https://github.com/brain-life/cli).

```
npm install -g brainlife
bl login
mkdir input
bl dataset download
```

3. Launch the App by executing 'main'

```bash
./main
```

## Output

The main output of this App is a track/tck datatype containing the tractogram of the optic radiations and a wmc datatype containing the streamline classification information.

#### Product.json

The secondary output of this app is `product.json`. This file allows web interfaces, DB and API calls on the results of the processing.

### Dependencies

This App only requires [singularity](https://www.sylabs.io/singularity/) to run. If you don't have singularity, you will need to install following dependencies.   

- matlab: https://www.mathworks.com/products/matlab.html
- vistasoft: https://github.com/vistalab/vistasoft
- encode: https://github.com/francopestilli/encode
- jsonlab: https://github.com/fangq/jsonlab
- AFQ: https://github.com/yeatmanlab/AFQ
- wma_tools: https://github.com/DanNBullock/wma_tools

#### MIT Copyright (c) 2020 brainlife.io The University of Texas at Austin and Indiana University
