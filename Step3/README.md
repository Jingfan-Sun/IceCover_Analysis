#Step3

##Folders

###/unified-sea-ice-thickness-cdr-1947-2012

Raw data available here. 

###/track_Demo

There are 15 recode there and I plotted the observation location in each individual data, there are mainly two types. (on server knossos)

1. The first type contains different tracks, including:
	1. /home/jingfan/Step3/track_Demo/AIR-EM_summaries_2001_2009_v1.png
	from satellite:
	2. /home/jingfan/Step3/track_Demo/IceBridge_summaries_2009_2011_v1.png
	3. /home/jingfan/Step3/track_Demo/ICESAT1-G_summaries_2005_2007_v1.png
	from submarine:
	4. /home/jingfan/Step3/track_Demo/UKSUB-AN_summaries_1987_and_1991_v1.png
	5. /home/jingfan/Step3/track_Demo/UKSUB-DG_summaries_1987_and_1991_v1.png
	6. /home/jingfan/Step3/track_Demo/USSUB-AN_summaries_1975_2005_v1_1.png
	7. /home/jingfan/Step3/track_Demo/USSUB-AN_summaries_1975_2005_v1_2.png
	8. /home/jingfan/Step3/track_Demo/USSUB-DG_summaries_1986_1999_v1.png
2. The second type contains several independent sites, including:
	9. /home/jingfan/Step3/track_Demo/AWI-GS_summaries_1991_2002_v1.png
	10. /home/jingfan/Step3/track_Demo/BGEP_summaries_2003_2012_v1.png
	11. /home/jingfan/Step3/track_Demo/BIO_LS_summaries_2003_2007_v1.png
	12. /home/jingfan/Step3/track_Demo/Davis_St_summaries_2006_2008_v1.png
	13. /home/jingfan/Step3/track_Demo/IOS-CHK_summaries_2003_2005_v1.png
	14. /home/jingfan/Step3/track_Demo/IOS-EBS_summaries_1990_2003_v1.png
	15. /home/jingfan/Step3/track_Demo/NPEO_summaries_2001_2010_v1.png
	
###/track_Compare_v1, /track_Compare_v2, /track_Compare_v3, /track_Compare_v4, /track_Compare_v5, /track_Compare_v6

I forget to add these files into GitHub repository when I first create them. So, there are 6 versions in /Step3 folder. I gradually changed the units of X-Axis, the font size of the labels, the type the lines and interpolation methods. Besides, I added the upper and lower limit of each line. 

##Files

###show_Track_*.m

These scripts are used to plot demo tracks. The results are saved in folder /track_Demo. 

###track_Compare_*.m

These scripts made a 1 x 2 subplots and plots comparation line in the upper subplot and tracj map in the lower subplot. There are also information about each different track points at the other sides of the map. The results are saved in folder /track_Compare_v1-6
