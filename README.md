# IceCover_Analysis

## Introduction

This is the summer internship work I did in University of Alberta. I mainly deal with ice cover in the Arctic Ocean. I plotted ice thickness and ice concentration map and compare the results of model output(ANHA4 and ANHA12) with data collected from satellite, aircrafts and observation stations. 

I directly upload the file in my working directory on srever knossos in EAS Lab.

## Explanation of the content in each sub-directory

### showIceMap

/shoeIceMap contains demo scripts in Matlab to plot a map near Alaska with different color to show different ice thickness. 

### IceTrack

/IceTrack contains demo Matlab scripts to show a track on map with different color representing thickness along the track. 

1. Run getIceTrack2014.m and select several points to define a track.
2. Smooth the curve and do interpolation.
3. Plot the map with the color line.

### Step1

/Step1 contains my first work. For each run in ANHA4 and ANHA12: 

- Plots of mean sea-ice concentration over 2003-2010 for each run for march and September, for the region north of 55N, as well as a difference plots
- Plots of concentration standard deviation over 2003-2010 for each run for March and September, for the same region, as as well as a difference plot
- Plots of concentration for September 2007 and 2010 for each run, as well as difference plots

Repeat of the above 3 items, for the sea ice thickness

- Histogram of sea-ice thickness distribution, in 0.2 m thick bins, for each run over 2003-2010, for each of March and September

### Step2

/Step2 contains comparations from satellite data([ICESat](http://icdc.zmaw.de/seaicethickness_satobs_arc.html?&L=1)) and model outputs.

Data from satellite is in a 25km x 25km grid and I interpolate model outputs into this grid. The calculation in ANHA12 takes a long time so I run the script in the evening and record the index and basic information which can be found in those .mat and .dat files.

### Step3

/Step3 contains comparation between model outputs and observation data([Aircrafts and Observation Stations](http://nsidc.org/data/icebridge/index.html)).

There are five versions of plots. Each has a small update of details in the plots.
