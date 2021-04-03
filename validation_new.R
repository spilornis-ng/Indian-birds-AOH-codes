library(rgdal)
library(raster)
library(rgeos)
library(sf)
library(sp)
library(dplyr)

df<-data.frame(Species=character(0), Total_eBird_points=numeric(0), Points_inside_poly=numeric(0), Percent_overlap=numeric(0))
name<-list.files("path to folder containing shapefiles", pattern=".shp$")
name1<-sub(".shp$", "", name)

for (i in 1:95){
  x<-paste0("path to folder containing range shapefiles", name[i])
  x<-st_read(x)
  y<-paste0("path to folder containing eBird observation shapefiles", name[i])
  y<-st_read(y)
  x<-st_buffer(x, dist=5000)
  x<-as_Spatial(x)
  y<-as_Spatial(y)
  yx<-over(y,x)
  m<-sum(table(yx$DN))
  df[i,]$Species<-name1[i]
  df[i,]$Total_eBird_points<-length(y)
  df[i,]$Points_inside_poly<-m
  df[i,]$Percent_overlap<-(m/(length(y)))*100
}
write.csv(df,"path to save destination")


