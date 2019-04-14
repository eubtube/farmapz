## ---- message = FALSE----------------------------------------------------
library(geospaarproj)
library(geospaar)
library(rgdal)

# SMS survey 
f <- system.file("extdata/sms-data.csv", package = "geospaarproj")
sms <- read.csv(f, stringsAsFactors = FALSE)

# Rainfall collected at sensor pods
f <- system.file("extdata/pod-rainfall.csv", package = "geospaarproj")
podrf <- read.csv(f)

## ---- fig.height=5, fig.width=5, fig.align='center'----------------------
coordinates(podrf) <- ~lon + lat
podrf$date <- as.Date(podrf$date, "%Y-%m-%d")
data("districts")

par(mfrow = c(2, 2), mar = c(0, 0, 1, 0))
plot(districts, col = "grey")
points(podrf, col = "blue", pch = 20)
plot(podrf, pch = "")
plot(districts, col = "grey", add = TRUE)
points(podrf, col = "blue", pch = "+")

# rainfall values
pods <- unique(podrf$podid)
cols <- rainbow(length(pods))
par(mar = c(3, 3, 3, 0), mgp = c(1.5, 0.25, 0), tcl = -0.2)
plot(rain ~ date, podrf[podrf$podid == pods[1], ], type = "l", ylab = "mm",
     col = cols[1], ylim = c(0, 100), main = "Daily rainfall", cex.axis = 0.8)
for(i in 2:length(pods)) {
  lines(rain ~ date, podrf[podrf$podid == pods[i], ], col = cols[i])
}
plot(cumsum(rain) ~ date, podrf[podrf$podid == pods[1], ], type = "l", 
     col = cols[1], ylim = c(0, 1000), main = "Cumulative daily rainfall", 
     cex.axis = 0.8, ylab = "mm")
for(i in 2:length(pods)) {
  lines(cumsum(rain) ~ date, podrf[podrf$podid == pods[i], ], col = cols[i])
}

## ---- eval = FALSE-------------------------------------------------------
#  library(lubridate)
#  library(raster)
#  
#  # path to CHIRPS, assuming they are all downloaded
#  p_chrp <- "~/Dropbox/data/climate/rainfall/zambia/chirps/"
#  
#  # contruct vector of file names
#  fnms <- paste0(p_chrp, paste0("/zam_chirps", 2008:2017, ".tif"))
#  
#  
#  # read in 2015 and 2016 CHIRPs data into a stack
#  chrp1516 <- stack(lapply(2015:2016, function(x) {  # x <- 2015
#    b <- brick(fnms[grep(x, fnms)])
#    b
#  }))
#  names(chrp1516) <- paste0("d", 1:nlayers(chrp1516))
#  
#  # construct date look-up table that gives you date of each layer
#  dts <- seq(ymd("2015-01-01"), ymd("2016-12-31"), by = "day")
#  dts <- data.frame("yr" = year(dts), "date" = dts)
#  
#  # index of October 1 - April 30 dates
#  ind <- which(dts$date >= "2015-10-01" & dts$date <= "2016-04-30")
#  chrp1516_gs <- chrp1516[[ind]]
#  
#  png("vignettes/chrpfig.png", height = 300, width = 700)
#  plot_noaxes(chrp1516_gs[[1:3]], nr = 1, nc = 3, zlim = c(0, 30))
#  dev.off()

## ---- message = FALSE, echo = FALSE--------------------------------------
library(lubridate)
dts <- seq(ymd("2015-01-01"), ymd("2016-12-31"), by = "day") 
dts <- data.frame("yr" = year(dts), "date" = dts)

## ---- eval=FALSE---------------------------------------------------------
#  chrp_start <- lapply(2008:2016, function(x) {  # x <- 2008
#    print(x)
#    dts <- seq(ymd(paste0(x, "-01-01")), ymd(paste0(x, "-12-31")), by = "day")
#    dts <- data.frame("yr" = year(dts), "date" = dts)
#    ind <- which(dts$date >= paste0(x, "-10-01") &
#      dts$date <= paste0(x, "-12-31"))
#    b <- brick(fnms[grep(x, fnms)])
#    b <- b[[ind]]
#    names(b) <- paste0("d", ind)
#    b
#  })

## ---- eval = FALSE-------------------------------------------------------
#  library(doMC)
#  library(foreach)
#  
#  # set up
#  dts <- seq(ymd("2015-01-01"), ymd("2016-12-31"), by = "day")
#  dts <- data.frame("yr" = year(dts), "mo" = month(dts), "date" = dts)
#  unimos <- unique(dts[, c("yr", "mo")])
#  unimos$moind <- 1:nrow(unimos)
#  dts <- merge(dts, unimos, by = c("yr", "mo"))
#  dts <- dts[order(dts$date), ]
#  # dts[342:500, ]
#  
#  # path to PGF temp
#  p_temp <- "~/Dropbox/data/climate/temp/zambia/"
#  
#  # contruct vector of file names
#  fnms <- paste0(p_temp, paste0("tmean_", 2015:2016, ".tif"))
#  
#  # Read in TMean for 2015 and 2016
#  tmu1516 <- stack(lapply(fnms, function(x) {  # x <- 2015
#    b <- brick(x)
#  }))
#  names(tmu1516) <- paste0("d", 1:nlayers(tmu1516))
#  
#  # prepare indices for October 1 - April 30 dates
#  dyind <- which(dts$date >= "2015-10-01" & dts$date <= "2016-04-30")
#  dts_ss <- dts[dyind, ]  # subset data.frame of dates
#  
#  # subset temp stack
#  tmu1516_gs <- tmu1516[[dyind]]
#  
#  # calculate monthly means, the normal serial way - slow
#  tmu_mo_ser <- stack(lapply(unique(dts_ss$moind), function(x) {  # x <- 10
#    moind <- which(dts_ss$moind == x)
#    calc(tmu1516_gs[[moind]], mean)
#  }))
#  names(tmu_mo_ser) <- paste0("mo", c(10:12, 1:4))
#  
#  # calculate monthly means in parallel, using doMC and foreach
#  # foreach behaves very much like lapply
#  registerDoMC(7)  # dedicate 7 of my 8 cores, one per month to calculate
#  tmu_mo_par <- foreach(x = unique(dts_ss$moind), .combine = stack) %dopar% {
#    moind <- which(dts_ss$moind == x)
#    calc(tmu1516_gs[[moind]], mean)
#  }
#  names(tmu_mo_par) <- paste0("mo", c(10:12, 1:4))
#  
#  # run this to make sure parallel and serial versions are identical
#  # (in case you don't trust that parallel version ordered months correctly)
#  for(i in 1:nlayers(tmu_mo_par)) {
#    print(identical(tmu_mo_par[[i]], tmu_mo_ser[[i]]))
#  }  # you will see that TRUE for each layer
#  
#  tmu_mo_par <- tmu_mo_par - 273.15  # data are in Kelvin, so convert to celsius
#  
#  png("vignettes/tmu.png", height = 300, width = 700)
#  plot_noaxes(tmu_mo_par, nr = 2, nc = 3, zlim = c(15, 35))
#  dev.off()

