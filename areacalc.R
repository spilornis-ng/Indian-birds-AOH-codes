library(raster)
library(rgdal)
library(rgeos)

name<-list.files("path to your shapefiles", pattern = ".shp")
name<-gsub(pattern = "\\.shp$", "", name)
p<-data.frame(species=character(0), area=numeric(0))


#loop for calculating area and adding to the data frame
for(i in 1:100) {
  m<-paste0("path to your shapefiles", name[i], ".shp")
  x<-readOGR(m)
  p[i,]$species<-name[i]
  p[i,]$area<-sum(area(x))/1000000
}
