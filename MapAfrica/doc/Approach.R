## ---- echo = FALSE, fig.height = 7, fig.width = 5, message = FALSE, eval = FALSE----
#  library(sp)
#  library(raster)
#  library(rgdal)
#  library(rgeos)
#  library(maps)
#  library(geospaarproj)
#  library(MapAfrica)
#  
#  # maps made by Mechanical Turk workers
#  f <- system.file("extdata/worker_fmaps.sqlite", package = "geospaarproj")
#  workers <- readOGR(dsn = f, layer = "worker_fmaps", verbose = FALSE)
#  
#  # ground-truth fields
#  f <- system.file("extdata/truth_fmatch.sqlite", package = "geospaarproj")
#  truth <- readOGR(dsn = f, layer = "truth_fmatch", verbose = FALSE)
#  
#  # sample grids
#  f <- system.file("extdata/fgrids_alb.sqlite", package = "geospaarproj")
#  fgrids <- readOGR(dsn = f, layer = "fgrids_alb", verbose = FALSE)
#  
#  a <- truth[truth$name == "ZM0726808", ]
#  c <- fgrids[a, ]
#  b <- workers[workers$name == c$name, ]
#  
#  ab_intersect_id <- which(gIntersects(spgeom1 = a, spgeom2 = b, byid = TRUE))
#  ab_intersect <- b[ab_intersect_id, ]
#  
#  par(mar = c(0, 0, 1, 1))
#  plot(c, col = "grey")
#  plot(ab_intersect, col = "darkseagreen2", add = TRUE)
#  plot(a, col = "blue", add = TRUE)

