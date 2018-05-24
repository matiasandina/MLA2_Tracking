# MLA2_Tracking
Here is where the code for tracking animal position in MLA2 Experiment Lives


## Workflow outline

1. Bonsai: `Video_Acquisition.bonsai`
1. Bonsai: Go to the workflow for tracking, e.g, `Bonsai_Workflow_MLA_2018-03-13T23_06_11`
1. Adjust parameters for HSV transform, areas, ...
1. Run the tracking. Data will be saved on `raw_data/raw_data` folder. 
1. Save a **new** copy of the .bonsai with specific HSV parameters for record keeping.
1. Update animal list in `MLA_Animal_Video_Key.csv`
1. `bonsai_parser_cleanUP.R` will move raw data to `./data` folder and create animal folders
1. Move to MATLAB. Run the script workflow_track.m
1. Double check in MATLAB/R the plots for the traces.
1. If correct, move on, else further smoothdata or do manual corrections.
1. Data analysis is done in R with `distance_analysis.R` and others.


## Annotator

This repository contains a video annotator. It uses code in `Annotator` folder and a GUI to interphase MATLAB with VLC via ActiveX. 

1. You are requested to select an animal/video from the data in `src/data` and `src/video` and begin with the manual annotation of behavior.  
1. After annotation and closing the GUI you will be prompted to save the data.
1. The annotator labels 1 every ~8 frames. Thus we have to fill the gaps using `fill_annotator_gaps.m`. This function is only suited for 1 video at a time. In order to make it work for all videos at the same time (quite better) we use `calculate_behavior.m`, which also gives us the latencies and durations.

Optional >> Making a Raster Plot (Ethogram).  
**Watch out!** Plotting the data with `make_ethogram_plot.m` needs `gramm` to be added to path.