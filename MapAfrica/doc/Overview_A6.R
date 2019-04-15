## ----echo = FALSE--------------------------------------------------------
library(sp)
library(rgdal)
library(rgeos)
library(geospaarproj)

f <- system.file("extdata/worker_fmaps.sqlite", package = "geospaarproj")
workers <- readOGR(dsn = f, layer = "worker_fmaps", verbose = FALSE)

# ground-truth
f <- system.file("extdata/truth_fmatch.sqlite", package = "geospaarproj")
truth <- readOGR(dsn = f, layer = "truth_fmatch", verbose = FALSE)

# assignment data
f <- system.file("extdata/fassignments.csv", package = "geospaarproj")
assn <- read.csv(f)

# sample grids
f <- system.file("extdata/fgrids_alb.sqlite", package = "geospaarproj")
fgrids <- readOGR(dsn = f, layer = "fgrids_alb", verbose = FALSE)

## ---- echo = FALSE, fig.height = 5, fig.width = 7------------------------
a <- truth[truth$name == "ZM0726808", ]
c <- fgrids[a, ]
b <- workers[workers$name == c$name, ]

ab_intersect_id <- which(gIntersects(spgeom1 = a, spgeom2 = b, byid = TRUE))
ab_intersect <- b[ab_intersect_id, ]

par(mar = c(0, 0, 1, 1))
plot(c, col = "grey")
plot(b, col = "pink", add = TRUE)
plot(ab_intersect, col = "green4", add = TRUE)
raster::text(c, labels = "name", col = "black")
plot(a, col = "blue", add = TRUE)

