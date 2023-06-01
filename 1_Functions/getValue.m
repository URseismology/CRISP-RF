function [ data ] = getValue(lat, lon, LAT, LON, DATA)

epsLat=(max(LAT)-min(LAT))/size(LAT,1);
epsLon=(max(LON)-min(LON))/size(LON,1);

idxLat=round((lat/epsLat)-(min(LAT)/epsLat)+1)
idxLon=round((lon/epsLon)-(min(LON)/epsLon)+1)

data=DATA(idxLon, idxLat);


end

