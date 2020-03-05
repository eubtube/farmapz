library(sf)
library(sp)
library(raster)
library(rgdal)
library(rgeos)
library(maps)
library(farmapz)
library(rmapaccuracy)

truth_sub <- st_read("C:/Users/euban/OneDrive - Clark University/Geospatial Analysis with R/packages/geospaarproj/farmapz/data/CSV Data/truth_sub.sqlite")

workers_sub <- st_read("C:/Users/euban/OneDrive - Clark University/Geospatial Analysis with R/packages/geospaarproj/farmapz/data/CSV Data/workers_sub.sqlite")

grids_sub <- st_read("C:/Users/euban/OneDrive - Clark University/Geospatial Analysis with R/packages/geospaarproj/farmapz/data/CSV Data/grids_sub.sqlite")

# example truth polygon
example_t_polygon <- truth_sub[truth_sub$ogc_fid0 == "420",]

# example mechanical turk worker polygon
example_worker_polygon <- workers_sub[workers_sub$ogc_fid0 == "1908",]

false_positive <- st_difference(example_worker_polygon, example_t_polygon)
true_positive <- st_intersection(example_worker_polygon, example_t_polygon)
false_negative <- st_difference(example_t_polygon,example_worker_polygon)

plot(st_geometry(example_t_polygon), col = "yellow")
plot(st_geometry(false_negative), col = "grey")  

   
plot(st_geometry(false_positive), col = "red", add = TRUE)
plot(st_geometry(true_positive), col = "blue", add = TRUE)
plot(st_geometry(false_negative), col = "grey", add = TRUE)