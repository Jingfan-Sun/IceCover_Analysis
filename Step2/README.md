#Step2

##DATA DESCRIPTION:
   
   [Gridded sea ice thickness data](http://icdc.zmaw.de/seaicethickness_satobs_arc.html?&L=1) from 10 ICESat campaigns are available here. The estimate at each grid point is the average thickness of all observations within that grid cell over the duration of each campaign.
   
   Data products are created from data release 531: the latest and best releases available in terms of the quality of precision orbit and attitude determination at the time of this analysis. These 10 campaigns span a period of 5 years between __2003 and 2008__. The thickness fields are shown on the right side of this page. 
   
  The data sets use the following campaign designations: ON03, FM04, ON04, FM05, ON05, FM06, ON06, MA07, ON07, and FM08.

UPDATE: As of 11/18/10, new thickness files include line entries with: no ice (-1.0) and land (9999.0). 

##Folders

###/maps

Results of subplots __3 x 1__ in each PNG file. Each subplot contains map representaion from ANHA4, ANHA12 and Satellite Data. 

###/histograms

Results of subplots __1 x 3__ in each PNG file. Each subplot contains histogram of ice thickness distribution from ANHA4, ANHA12 and Satellite Data. 

##Files

###*.dat

These files are satellite raw data.

###*.mat

It spends a long time to calculate the interpolation results from each ANHA12 input. So I ran relative scripts in weekends and save the nearst several index and date in these .mat files to save time when I use them later.

####P.S. The grid used in satellite date is a 25km x 25km one in a square area. I choose to interpolate the model outputs which are divided into an irregular grid into the regular satellite grid.
