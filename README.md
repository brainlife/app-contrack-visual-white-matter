<h1 align="center">Track the Human Optic RAdiation (THORA): ConTrack - Eccentricity</h1>

<p align="center">
  Optic radiation streamlines between the LGN and V1, tracked with ConTrack and split into bundles by visual field eccentricity from pRF mapping.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.647"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.647-blue.svg" alt="Run on brainlife.io"></a>
  <a href="https://github.com/brainlife/app-contrack-visual-white-matter/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="MIT license"></a>
</p>

> 📍 **This branch, `tracking-eccentricity-v1.1`, is the brainlife.io App Track Visual White Matter Tracks by Visual Field Eccentricty: Contrack** ([doi:10.25663/brainlife.app.647](https://doi.org/10.25663/brainlife.app.647)).

## 🧠 At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Tracks visual white matter between user-chosen pairs of ROIs (such as eccentricity-binned V1 or LGN ROIs) with ConTrack probabilistic tractography.**

For each start/termination ROI pair, resamples the ROIs to the T1, removes them from the CSF and exclusion masks, runs ConTrack, keeps the top-scoring streamlines with contrack_score, and cleans them. Eccentricity binning comes from the ROI names you pass (for example ROIs from a pRF eccentricity App). Needs a dtiinit, a T1, ROIs, pRF, a 5TT mask and FreeSurfer; expect up to 32 hours.

| | |
|---|---|
| 📥 **Inputs** | `neuro/dtiinit` · `neuro/anat/t1w` · `neuro/rois` · `neuro/prf` · `neuro/mask` (optional) · `neuro/freesurfer` |
| 📤 **Outputs** | `neuro/track/tck` · `neuro/wmc` |
| 🐳 **Container** | `brainlife/mrtrix3:3.0_RC3` |
| ⚙️ **Resources** | 1 CPUs · 20 GB memory · 32 h walltime |
| 🔑 **Requires** | `FREESURFER_LICENSE` |
| 🔗 **Run it** | [doi.org/10.25663/brainlife.app.647](https://doi.org/10.25663/brainlife.app.647) |

#### 📥 Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `dtiinit` | `neuro/dtiinit` | yes | dtiinit output (vistasoft) providing the diffusion data and tensor fit used by ConTrack. |
| `t1` | `neuro/anat/t1w` | yes | T1-weighted image that defines the working space; ROIs, eccentricity, ribbons and CSF are resampled to it. |
| `rois` | `neuro/rois` | yes | ROIs to track between; files are found by the names given in start_roi, term_roi and exclusion_roi. |
| `prf` | `neuro/prf` | yes | Population receptive field (pRF) maps; the eccentricity map is used to split visual cortex into eccentricity bins. |
| `mask` | `neuro/mask` (5tt_masks) | no | MRtrix3 five-tissue-type (5TT) mask; its CSF volume is used as an exclusion region. |
| `freesurfer` | `neuro/freesurfer` | yes | FreeSurfer subject directory; the cortical ribbon (ribbon.mgz, lh/rh.ribbon.mgz) restricts eccentricity to cortex and defines hemisphere exclusions. |

#### 📤 Outputs

| Output | Datatype | Description |
|---|---|---|
| `track` | `neuro/track/tck` | Tractogram (.tck) of the cleaned ConTrack streamlines for all ROI pairs. |
| `wmc` | `neuro/wmc` | White matter classification assigning streamlines to one tract per ROI pair, with tract JSONs for visualisation and fiber counts. |

<details>
<summary><b>⚙️ Parameters</b> (11)</summary>

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

</details>

<!-- brainlife-app:end -->

## 🔬 How it works

The App tracks the optic radiation with ConTrack (Sherbondy et al., 2008) between a lateral geniculate nucleus (LGN) ROI and a V1 ROI in each hemisphere, then segments the streamlines into bundles by the eccentricity of their V1 endpoints, using population receptive field (pRF) eccentricity maps.

1. **CSF exclusion mask.** The CSF volume is taken from the 5-tissue-type mask if you provide one; otherwise MRtrix3 `5ttgen fsl` computes it from the T1 (`brainlife/mrtrix3:3.0_RC3`).
2. **Anatomy in T1 space.** The FreeSurfer cortical ribbons, the ROIs and the pRF eccentricity map are converted and resliced to the T1 (FreeSurfer 6.0.0, FSL).
3. **Tracking.** The LGN and V1 ROIs are inflated (`inflate_lgn`, `inflate_v1`) and ConTrack (vistasoft, compiled MATLAB) samples `nSamples` streamlines per hemisphere from the dtiInit output, with the node limits and step size you set.
4. **Eccentricity classification.** V1 is masked by the cortical ribbon and split into eccentricity ranges defined by `minDegree` and `maxDegree` (by default 0–3°, 15–30° and 30–90°); each streamline is assigned to the range its V1 endpoint falls in.

## 🚀 Running the App

### ☁️ On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.252](https://doi.org/10.25663/brainlife.app.252) and choose, for one subject:

- a dtiInit output (`neuro/dtiinit`);
- a T1-weighted image (`neuro/anat/t1w`), which defines the space of all ROIs and maps;
- an ROI directory (`neuro/rois`) with per-hemisphere LGN and V1 ROIs named `*lh.<lgn>.nii.gz`, `*rh.<lgn>.nii.gz`, `*lh.<v1>.nii.gz` and `*rh.<v1>.nii.gz`, where `<lgn>` and `<v1>` are the values of the `lgn` and `v1` parameters;
- a pRF mapping output (`neuro/prf`) with an eccentricity map;
- a FreeSurfer output (`neuro/freesurfer`);
- optionally, a 5-tissue-type mask (`neuro/mask`, tag `5tt_masks`).

Set the tracking parameters and press **Execute**. The App writes an optic radiation tractogram (`neuro/track/tck`) and a white matter classification of the eccentricity bundles (`neuro/wmc`), both tagged `optic_radiation`. A run can take up to 32 hours.

### 💻 Locally

You need [Singularity/Apptainer](https://apptainer.org/), [`jq`](https://jqlang.github.io/jq/) and a [FreeSurfer license](https://surfer.nmr.mgh.harvard.edu/registration.html). The tracking and classification steps are compiled MATLAB and run in the `brainlife/mcr:neurodebian1604-r2017a` container, so MATLAB is not needed.

1. Clone this repository and check out the App's branch: `git checkout v1.1`.
2. Create `config.json` with the paths to your inputs and the tracking options:

   ```json
   {
       "dtiinit": "/input/dtiinit",
       "t1": "/input/t1/t1.nii.gz",
       "rois": "/input/rois/rois",
       "eccentricity": "/input/prf/eccentricity.nii.gz",
       "mask": "/input/5tt/mask.nii.gz",
       "freesurfer": "/input/freesurfer/output",
       "lgn": "lgn",
       "v1": "v1",
       "nSamples": 50000,
       "maxNodes": 240,
       "minNodes": 100,
       "stepSize": 1,
       "inflate_lgn": 1,
       "inflate_v1": 1,
       "minDegree": "0 15 30",
       "maxDegree": "3 30 90"
   }
   ```

   Set `"mask": null` to have the App compute the 5-tissue-type mask from the T1. `nSamples` is the number of streamlines requested, not necessarily the final count, because tracking runs without the CSF exclusion.

3. Export your FreeSurfer license and run the App:

   ```bash
   export FREESURFER_LICENSE="$(cat ~/freesurfer/license.txt)"
   ./main
   ```

### 🧪 Sample data

Download sample datasets from brainlife.io with the [brainlife CLI](https://github.com/brainlife/cli):

```bash
npm install -g brainlife
bl login
mkdir input
bl dataset download <dataset id>
```

## 📦 Outputs

```text
track/
└── track.tck                 optic radiation streamlines
wmc/
├── classification.mat        streamline-to-bundle assignment, per hemisphere and eccentricity range
├── tracts/                   per-bundle files
└── output_fibercounts.txt    number of streamlines in each bundle
```

## 🩺 Troubleshooting

- **`tracking failed`**: ConTrack did not produce `track.tck`. Check the logs, and check that the ROI file names in the `rois` directory match the `lgn` and `v1` parameters.
- **`Please set FREESURFER_LICENSE in .bashrc`**: export your FreeSurfer license as `FREESURFER_LICENSE` before running `./main`.

## 📚 Citing

> [!TIP]
> If you use this App in your work, please cite the App, the software it builds on and brainlife.io (below). GitHub's **Cite this repository** button gives the App citation in APA and BibTeX.

- Sherbondy AJ, Dougherty RF, Ben-Shachar M, Napel S, Wandell BA. ConTrack: finding the most likely pathways between brain regions using diffusion tractography. *Journal of Vision* 8(9):1–16 (2008). [doi:10.1167/8.9.15](https://doi.org/10.1167/8.9.15)
- Ogawa S, Takemura H, Horiguchi H, Terao M, Haji T, Pestilli F, Yeatman JD, Tsuneoka H, Wandell BA, Masuda Y. White matter consequences of retinal receptor and ganglion cell damage. *Investigative Ophthalmology & Visual Science* 55(10):6976–6986 (2014). [doi:10.1167/iovs.14-14737](https://doi.org/10.1167/iovs.14-14737)
- Yoshimine S, Ogawa S, Horiguchi H, Terao M, Miyazaki A, Matsumoto K, Tsuneoka H, Nakano T, Masuda Y, Pestilli F. Age-related macular degeneration affects the optic radiation white matter projecting to locations of retinal damage. *Brain Structure and Function* 223(8):3889–3900 (2018). [doi:10.1007/s00429-018-1702-5](https://doi.org/10.1007/s00429-018-1702-5)
- Track Visual White Matter Tracks by Visual Field Eccentricty: Contrack. brainlife.io App. [doi:10.25663/brainlife.app.647](https://doi.org/10.25663/brainlife.app.647)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. Sci Data 6, 69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)
- Fischl. FreeSurfer. *NeuroImage* 62:774-781 (2012). [doi:10.1016/j.neuroimage.2012.01.021](https://doi.org/10.1016/j.neuroimage.2012.01.021)
- Jenkinson et al. FSL. *NeuroImage* 62:782-790 (2012). [doi:10.1016/j.neuroimage.2011.09.015](https://doi.org/10.1016/j.neuroimage.2011.09.015)
- Tournier et al. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. *NeuroImage* 202:116137 (2019). [doi:10.1016/j.neuroimage.2019.116137](https://doi.org/10.1016/j.neuroimage.2019.116137)
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)

## 👥 Authors

- Brad Caron

**Contributors:** Soichi Hayashi

## 💰 Funding

[![Wellcome-226486/Z/22/Z](https://img.shields.io/badge/Wellcome-226486%2FZ%2F22%2FZ-purple.svg)](https://wellcome.org/)
[![NIH-NINDS-U24NS140384](https://img.shields.io/badge/NIH_NINDS-U24NS140384-green.svg)](https://reporter.nih.gov/project-details/11261037)
[![NIH-NINDS-UM1NS132207](https://img.shields.io/badge/NIH_NINDS-UM1NS132207-green.svg)](https://reporter.nih.gov/project-details/11411328)
[![NIH-NIBIB-R01EB029272](https://img.shields.io/badge/NIH_NIBIB-R01EB029272-green.svg)](https://reporter.nih.gov/project-details/10262925)
[![NIH-NIBIB-R01EB030896](https://img.shields.io/badge/NIH_NIBIB-R01EB030896-green.svg)](https://reporter.nih.gov/project-details/10428625)
[![NIH-NIMH-R01MH126699](https://img.shields.io/badge/NIH_NIMH-R01MH126699-green.svg)](https://reporter.nih.gov/project-details/10460628)
[![NIH-NIDCD-R01DC020088](https://img.shields.io/badge/NIH_NIDCD-R01DC020088-green.svg)](https://reporter.nih.gov/project-details/11140284)
[![NSF-BCS-1734853](https://img.shields.io/badge/NSF_BCS-1734853-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1734853)
[![NSF-BCS-2203524](https://img.shields.io/badge/NSF_BCS-2203524-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2203524)
[![NSF-IIS-1636893](https://img.shields.io/badge/NSF_IIS-1636893-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1636893)
[![NSF-OAC-2148729](https://img.shields.io/badge/NSF_OAC-2148729-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148729)
[![NSF-IIS-1912270](https://img.shields.io/badge/NSF_IIS-1912270-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1912270)
[![NSF-IIS-2148700](https://img.shields.io/badge/NSF_IIS-2148700-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2148700)
[![NSF-OAC-1916518](https://img.shields.io/badge/NSF_OAC-1916518-blue.svg)](https://www.nsf.gov/awardsearch/showAward?AWD_ID=1916518)

<sub>brainlife.io is publicly funded, and acknowledging that support helps keep it running. This App was developed with support from Wellcome, the U.S. National Institutes of Health (including the BRAIN Initiative BRAIN CONNECTS program: The Axonal Projectome EXchange, U24NS140384, and the Center for Mesoscale Connectomics, UM1NS132207) and the U.S. National Science Foundation.</sub>

## ⚖️ License

[MIT](https://github.com/brainlife/app-contrack-visual-white-matter/blob/master/LICENSE), Copyright (c) 2020 brainlife.io, The University of Texas at Austin and Indiana University. The App also uses [vistasoft](https://github.com/vistalab/vistasoft), [encode](https://github.com/francopestilli/encode), [jsonlab](https://github.com/fangq/jsonlab), [AFQ](https://github.com/yeatmanlab/AFQ) and [wma_tools](https://github.com/DanNBullock/wma_tools), each under its own license; FreeSurfer and FSL are distributed under their own licenses.
