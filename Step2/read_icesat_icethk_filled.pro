pro read_icesat_icethk_filled, season,npoints,lat,lon,x,y,thick
;
; This routine reads the filled ice thickness (cm) fields on the Icesat data webpage.
;
; The filled fields include entries for cells with: no ice (-1.) and land (9999.)
;
; Input: season = 4-character string describing Icesat campaign time period
;                 (e.g. 'on03','fm06','ma07')
;
; Output:  npoints = number of valid ice thickness grid points
;          lat = latitude
;          lon = longitude
;          x = SSMI x-location (km)
;          y = SSMI y-location (km)
;          thick = ice thickness (cm)
;

npoints=0 & llat=0. & llon=0. & xx=0. & yy=0. & tt=0.

openr,unitr,'icesat_icethk_'+season+'_filled.dat',/get_lun
readf,unitr,npoints
lat = fltarr(npoints)
lon = fltarr(npoints)
x = fltarr(npoints)
y = fltarr(npoints)
thick = fltarr(npoints)
for i=0,npoints-1 do begin
  readf,unitr,llat,llon,xx,yy,tt
  lat(i) = llat
  lon(i) = llon
  x(i) = xx
  y(i) = yy
  thick(i) = tt
endfor
free_lun,unitr

end
