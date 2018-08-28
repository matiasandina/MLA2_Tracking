# MLA2_Tracking

This is the code used to record, track and analyze animal position for MLA2 experiment.
To use this code in a **new** experiment, fork or download from the Github repository and start over with new data there.

## Workflow outline

1. Bonsai: `Video_Acquisition.bonsai`. Record behavior. Videos are saved on `src/video` folder.
1. Update animal list in `MLA_Animal_Video_Key.csv` with the new video title. **It is imperative that the order in which animals were run matches the rows**. To make sure this is the case, the timestamps on the `raw_videos` column must be ascending.
1. Bonsai: Go to the workflow for tracking, e.g, `Bonsai_Workflow_MLA_2018-03-13T23_06_11`
1. Adjust parameters for HSV transform, areas, ...
1. Run the tracking. Data will be saved on `./raw_data/raw_data` folder. 

> Be careful! If you want to re-run already analyzed files, make sure you change the saving directory on Bonsai. This will prevent overwritting files. You are advised to make a back-up copy of the video folder.

1. Save a **new** copy of the .bonsai with specific HSV parameters for record keeping.
1. Create a duplicate of the data to further process. The script `bonsai_parser_cleanUP.R` will move raw data to `./data` folder and create animal folders. **This script needs the working directory to be** `./src`
1. Move to MATLAB. Run the script `workflow_track.m`. **This script needs the working directory to be:** `./src`
1. Double check in MATLAB/R the plots for the traces. Many options here. You can do this directly in matlab using `plot` and the `rloess_smooth` object or in R using the `ideas_plot.R` script, which allows to run a single animal through the heatmap graphs. You can also use `custom_2d_hist.R` and filter by `RatID`.
1. If correct, move on, else proceed to further `smoothdata()` or do manual corrections.
1. Make a `manual fix for rat.txt` note of further smoothing in the folder that contains the final output (`.src/data/RatID`). Avoid using RatID or other information in the name of the manual note to prevent problems with the functions that match filenames to these values in the analysis code. 
1. Data analysis is done in R with `distance_analysis.R` and others.


## Annotator

This repository also contains a video annotator. It uses code in `Annotator` folder and a GUI to interphase MATLAB with VLC via ActiveX. 

1. Run `AnnotateVideo.m`
1. You are requested to select an animal/video from the data in `src/data` and `src/video` and begin with the manual annotation of behavior.  
1. After annotation and closing the GUI you will be prompted to save the data.
1. The annotator labels 1 every ~8 frames. Thus we have to fill the gaps using `fill_annotator_gaps.m`. This function is only suited for 1 video at a time. In order to make it work for all videos at the same time (quite better) we use `calculate_behavior.m`, which also gives us the latencies and durations.
1. Behavior can be later analyzed in R with `behaviors_from_ethogram.R`

Optional >> Making a Raster Plot (Ethogram).  
**Watch out!** Plotting the data with `make_ethogram_plot.m` needs `gramm` to be added to path.