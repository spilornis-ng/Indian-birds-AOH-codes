library(rgbif)
library(maptools)
library(raster)
library(rgdal)
library(tidyverse)
library(sf)
library(sp)
library(lubridate)

list=read.csv("list of species names")
ebirddata=read.csv("eBird_output.csv")
ebirddata$observation_date=as_date(ebirddata$observation_date,"%y%m%d")
indiamap=st_read("fwd/India_Boundary.shp")

list_NM=list%>%
  filter(Remarks2=="Non-migratory")
list_NM=list_NM$Scientific.Name

ebirddata_NM=ebirddata
ebirddata_NM=ebirddata_NM%>%
  filter(scientific_name%in%list_NM==TRUE)


list_M=finallist%>%
  filter(Remarks2!="Non-migratory")
list_M=list_M$Scientific.Name
breedingseason_M=data.frame(scientific_name=finallist_M$Scientific.Name,start=finallist_M$Breeding.start.month,end=finallist_M$Breeding.end.month)
ebirddata_M=ebirddata
ebirddata_M=ebirddata_M%>%
  filter(scientific_name%in%list_M==TRUE)
ebirddata_M=merge(breedingseason_M,ebirddata_M,all.y=T)
ebirddata_M=ebirddata_M%>%
  filter(month(observation_date)>start & month(observation_date)<end)


### Run

gisfile ="path to range shapefiles"  
bufferdist=10000

bird=st_read(gisfile)
bird=bird%>%
  filter(SCINAME%in%list_M==TRUE)
list=bird$SCINAME
final=st_sf(SCINAME="species",gbifrec=NA,areadiff=NA,geom=st_sfc(st_point(c(0,1),c(1,2))))

for (i in 1:length(list)) {
  target=bird%>%
    filter(bird$SCINAME==list[i])%>%
    st_union()
  target_area=st_area(target)
  target_gbif=ebirddata_M%>%
    filter(scientific_name==list[12])
  if(is.null(target_gbif)==TRUE){
    target_combined=target
    print(paste("No gbif records found for",as.character(list[i])))
    gbifrec=0
    combined_area=st_area(target_combined)
  } 
  else {
    target_sf=st_as_sf(target_gbif,coords = c("longitude","latitude"),crs="WGS84")
    target_sf=st_transform(target_sf,crs(target))
    target_sf_buffer=st_buffer(target_sf,dist = bufferdist)%>%
      st_union()
    target_combined=st_union(target,target_sf_buffer)
    gbifrec=as.numeric(nrow(target_gbif))
    combined_area=st_area(target_combined)
  }
  final[i,]=st_sf(SCINAME=as.character(list[i]),gbifrec=gbifrec,areadiff=(combined_area-target_area)/1000000,geom=target_combined,crs=crs(bird))
  print(paste("Range of",as.character(list[i]), "extended"))
}

final=st_set_crs(final,crs(target))
st_write(final,dsn="final_M_lcc.shp")
