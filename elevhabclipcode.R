library(raster)
library(sf)
library(tidyverse)
library(maptools)
library(rgeos)
library(sp)
library(rgdal)
library(spex)
library(stars)

setwd("working directory")
raster= "path to your DEM raster"
vector="path to your species range shapefiles"
raster2="path to your habitat raster"
attributesfile<-read.csv("path to your species attributes file", header = TRUE)

#elev clip
clipbyelevation=function(raster,vector,species, attributesfile){
  start=Sys.time()
  dem=raster(raster) ### define raster
  range=st_read(vector)
  range=range%>%
    filter(SCINAME==species)
  range=st_transform(range,crs(dem))
  dem.new=crop(dem,range)
  plot(range)
  dem.new2=mask(dem.new,range)
  dem.range=dem.new2
  attributes=attributesfile%>%
    filter(species==species)
  minelev=minelev
  maxelev=maxelev
  dem.range[dem.new2>minelev & dem.new2<maxelev] <- 20000
  range_dem = calc(dem.range, function(x) x==20000)
  range_dem[range_dem==0]<-NA
  return(range_dem)
}

#hab clip
clipbyhabitat=function(raster, attributesfile){
  start=Sys.time()
  hab=raster(raster2) ### define raster
  hab.new=crop(hab, x)
  hab.new2=mask(hab.new, x)
  rm(hab.new)
  sphab1<-hab1
  sphab2<-hab2
  sphab3<-hab3
  sphab4<-hab4
  hab.range = hab.new2
  hab.range[hab.range==sphab1|hab.range==sphab2|hab.range==sphab3|hab.range==sphab4]<-5
  range_hab<-calc(hab.range, function(x) x==5)
  range_hab[range_hab==0]<-NA
  return(range_hab)
}


#loop command
for (i in 1:95) {
  species<-attributesfile$species[i]
  minelev<-attributesfile$minelev[i]
  maxelev<-attributesfile$maxelev[i]
  hab1<-attributesfile$hab1[i]
  hab2<-attributesfile$hab2[i]
  hab3<-attributesfile$hab3[i]
  hab4<-attributesfile$hab4[i]
  x<-clipbyelevation(raster, vector, species, attributesfile)
  z<-clipbyhabitat(raster2, attributesfile)
  writeRaster(z, filename = paste0(species, ".tif"), "GTiff")
}

