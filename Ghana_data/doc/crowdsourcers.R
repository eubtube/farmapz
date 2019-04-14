## ---- message = FALSE----------------------------------------------------
library(geospaarproj)
library(geospaar)
library(rgdal)

# maps made by Mechanical Turk workers
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

## ---- fig.height=4, fig.width=7------------------------------------------
par(mfrow = c(1, 3), mar = c(0, 0, 1, 0))
plot(fgrids[fgrids$name %in% c("ZM0726808", "ZM0727304"), ], lty = 0, 
     main = "Worker Maps Vs Truth...")
plot(fgrids, col = "grey", add = TRUE)
plot(workers[workers$name %in% c("ZM0726808", "ZM0727304"), ], 
     add = TRUE, col = "pink")
raster::text(fgrids, labels = "name", col = "green4")
plot(truth, add = TRUE, col = "blue")

plot(fgrids[fgrids$name %in% c("ZM0726808", "ZM0727304"), ], lty = 0, 
     main = "...in Grid ZM0726808...")
plot(fgrids, col = "grey", add = TRUE)
plot(workers[workers$name == "ZM0726808", ], add = TRUE, col = "tan")
plot(truth[truth$name == "ZM0726808", ], add = TRUE, col = "blue")
raster::text(fgrids, labels = "name", col = "green4")

plot(fgrids[fgrids$name %in% c("ZM0726808", "ZM0727304"), ], lty = 0, 
     main = "..and Grid ZM0727304")
plot(fgrids, col = "grey", add = TRUE)
plot(workers[workers$name == "ZM0727304", ], add = TRUE, col = "orange")
plot(truth[truth$name == "ZM0727304", ], add = TRUE, col = "blue")
raster::text(fgrids, labels = "name", col = "green4")


