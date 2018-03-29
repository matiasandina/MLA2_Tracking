# MLA2_Tracking
Here is where the code for tracking animal position in MLA2 Experiment Lives


# Workflow outline

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