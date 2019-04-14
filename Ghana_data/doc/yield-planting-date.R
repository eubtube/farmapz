## ---- message = FALSE----------------------------------------------------
library(geospaarproj)
library(geospaar)
library(rgdal)

# Household survey data 2015/2016
f <- system.file("extdata/yield_planting.csv", package = "geospaarproj")
hh <- read.csv(f, stringsAsFactors = FALSE)

# SMS survey 
f <- system.file("extdata/sms-data.csv", package = "geospaarproj")
sms <- read.csv(f, stringsAsFactors = FALSE)

## ------------------------------------------------------------------------
hh[1, ]

## ---- fig.height=4, fig.width=7, fig.align='center'----------------------
# remove all observations having unharvested crops, plus one suspiciously 
# large planted area value
hh2 <- hh[hh$plot < 100 & hh$unharv == 0, ]
plarea1 <- hh2$plot
plarea2 <- hh2$seed / 20  # convert seed estimate to ha
yield1 <- hh2$harv / plarea1  # type 1 yield
yield2 <- hh2$harv / plarea2  # type 2 yield


par(mfrow = c(1, 2))
plot(plarea1, plarea2, xlab = "Planted area (ha)", ylab = "kg seed / 20", 
     pch = 20, xlim = c(0, 20), ylim = c(0, 20), cex.axis = 0.8,
     main = "Planted area: Farmer ha vs seed ha", cex.main = 0.8)
# abline(lm(plarea2 ~ plarea1), lty = 2)
a <- c(0, 20)
b <- c(0, 20)
abline(lm(a ~ b))
estr <- paste("mean abs. error =", round(mean(abs(plarea1 - plarea2)), 2), 
              "ha")
mtext(text = estr, side = 3, line = -2, cex = 0.8)
estr <- paste("mean planted area =", round(mean(plarea1), 2), "ha")
mtext(text = estr, side = 3, line = -1, cex = 0.8)

plot(yield1, yield2, xlim = c(0, 25000), ylim = c(0, 25000), pch = 20, 
     main = "Yields: Farmer ha vs seed ha", cex.main = 0.8, cex.axis = 0.8)
a <- c(0, 25000)
b <- c(0, 25000)
abline(lm(a ~ b))

# statistics, after first removing NA and infinite values from yields
badylds <- c(which(is.na(yield1) | is.infinite(yield1)), 
             which(is.na(yield2) | is.infinite(yield2)))
mae <- round(mean(abs(yield1[-badylds] - yield2[-badylds])), 1)
muyld <- round(mean(yield1[-badylds]), 1)
estr <- paste("mean abs error =", mae, "kg/ha")
mtext(text = estr, side = 3, line = -2, cex = 0.8)
estr <- paste("mean yield =", muyld, "kg/ha")
mtext(text = estr, side = 3, line = -1, cex = 0.8)

## ------------------------------------------------------------------------
for(i in grep("pd", names(hh))) {
  hh[, i] <- as.Date(hh[, i], "%Y-%m-%d")
}
apply(hh[, grep("pd", names(hh))], 2, function(x) {
  length(which(!is.na(x))) / length(x) * 100
})


## ------------------------------------------------------------------------
sms[1, ]

## ---- fig.align="center", fig.height=4, fig.width = 4--------------------
sms_ss <- sms[sms$season == 2, ]  # select just season 2
pls <- sapply(unique(sms_ss$uuid), function(x) {  # x <- unique(sms_ss$uuid)[3]
  pl <- sms_ss[sms_ss$uuid == x, "pl"]
  sum(pl, na.rm = TRUE)
})
hist(pls, xlab = "N plantings", main = "N plantings reported by farmer", 
     col = "blue")

## ---- fig.align="center", fig.height=4, fig.width = 7--------------------
rasl <- lapply(1:2, function(x) {
  sms_ss <- sms[sms$season == x, ]  # select just season 2
  ras <- sapply(unique(sms_ss$uuid), function(y) {  
    ra <- sms_ss[sms_ss$uuid == y, "ra"]
    sum(ra, na.rm = TRUE)
  })
})
par(mfrow = c(1, 2))
cols <- c("green4", "blue")
yr <- c("2015/2016", "2016/2017")
for(i in 1:2) { 
  hist(rasl[[i]], xlab = "N rain weeks", 
       main = paste("N rain weeks in", yr[i]), col = cols[i])
}

## ---- fig.align="center", fig.height=4, fig.width = 4--------------------
coordinates(hh) <- ~lon + lat
dat <- sms[sms$season == 1, ]
sms2015 <- do.call(rbind, lapply(unique(dat$uuid), function(x) {
  dat[dat$uuid == x, ][1, ]
}))
dat <- sms[sms$season == 2, ]
sms2016 <- do.call(rbind, lapply(unique(dat$uuid), function(x) {
  dat[dat$uuid == x, ][1, ]
}))
coordinates(sms2015) <- ~lon + lat
coordinates(sms2016) <- ~lon + lat

data("districts", package = "geospaar")
par(mar = c(0, 0, 0, 0))
plot(districts, col = "grey")
points(hh, pch = 20, col = "green4", cex = 1.5)
points(sms2015, pch = 20, col = "red")
points(sms2016, pch = "+", col = "blue", cex = 0.5)

