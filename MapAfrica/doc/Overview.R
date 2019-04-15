## ---- fig.height=5, fig.width=8, message=FALSE, echo=FALSE, eval=FALSE----
#  library(sp)
#  library(raster)
#  library(rgdal)
#  library(rgeos)
#  library(maps)
#  library(geospaarproj)
#  library(MapAfrica)
#  
#  # ground-truth for spatial reference
#  f <- system.file("extdata/truth_fmatch.sqlite", package = "geospaarproj")
#  truth <- readOGR(dsn = f, layer = "truth_fmatch", verbose = FALSE)
#  
#  # reference map of Africa
#  f <- system.file("data/Africa.shp", package = "MapAfrica")
#  Africa <- readOGR(dsn = f, layer = "Africa", verbose = FALSE)
#  
#  # Africa reprojected to data
#  Afr_proj <- spTransform(Africa, CRSobj = proj4string(truth))
#  
#  # reference map of study area
#  f <- system.file("data/Study_Area.shp", package = "MapAfrica")
#  stu_ar <- readOGR(dsn = f, layer = "Study_Area", verbose = FALSE)
#  
#  # study area reprojected
#  stu_ar_proj <- spTransform(stu_ar, CRSobj = proj4string(truth))
#  
#  par(mar = c(0, 0, 1, 1), mfrow = c(1, 2))
#  plot(Afr_proj, col = "grey90", main = "Africa", border = "grey50")
#  plot(stu_ar_proj, col = "darkslategray4", add = TRUE)
#  scalebar(d = 2000000, type = "bar", divs = 2, below = "km",
#           label = c("0","","2000"))
#  plot(stu_ar_proj, col = "darkslategray4", main = "Countries with Worker Fields")
#  text(stu_ar_proj, labels = stu_ar_proj$NAME_ENGLI)
#  scalebar(d = 700000, type = "bar", divs = 2, below = "km",
#           col = "darkslateblue", label = c("0","","700"))

