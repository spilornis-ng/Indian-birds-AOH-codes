library(raster)
library(leaflet)
library(leaflet.esri)
library(leaflet.providers)
library(leaflet.extras)
library(leafem)
library(leafpm)
library(leafpop)
library(leafsync)
library(mapview)
library(webshot)
webshot::install_phantomjs()

#bird raster map
ANR=raster("species.tif")

#bird shapefile IUCN
ANS=st_read("path to IUCN range map shapefile")

#provides the extent in the viewer for the basemap imagery
n= leaflet(data=ANS)

#adding esri world imagery
x= n %>% addTiles('http://server.arcgisonline.com/arcgis/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  options = providerTileOptions(noWrap = TRUE), group="World Imagery") 

#adding raster and polygon layers on the basemap
z= x %>% addPolygons(data=ANS,stroke=TRUE,color="#03F",weight=2,opacity=1,fill=FALSE) %>% addRasterImage(ANR,colors = "#f5ff00" ,opacity=1)

#writing the map to jpeg
mapshot(z, file = "A_nil1.jpeg",remove_controls = "zoomControl")