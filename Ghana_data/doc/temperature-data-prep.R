## ----setup, include=FALSE, echo=FALSE------------------------------------
#Put whatever you normally put in a setup chunk.
#I usually at least include:
#devtools::install_github("manuscriptPackage","jhollist")
#library("manuscriptPackage")
#Didn't do that here to expedite building of the example vignette
library("knitr")

opts_chunk$set(dev = 'pdf', fig.width=6, fig.height=5)

# Table Captions from @DeanK on http://stackoverflow.com/questions/15258233/using-table-caption-on-r-markdown-file-using-knitr-to-use-in-pandoc-to-convert-t
#Figure captions are handled by LaTeX

knit_hooks$set(tab.cap = function(before, options, envir) {
                  if(!before) { 
                    paste('\n\n:', options$tab.cap, sep='') 
                  }
                })
default_output_hook = knit_hooks$get("output")
knit_hooks$set(output = function(x, options) {
  if (is.null(options$tab.cap) == FALSE) {
    x
  } else
    default_output_hook(x,options)
})

## ---- eval = FALSE-------------------------------------------------------
#  library(gdalUtils)
#  library(glue)
#  library(raster)
#  
#  # read in file names of netcdfs, which come as daily temperature variables for
#  # the years 2015 and 2016, with tmin, tmax, and tmean separated for each year
#  p_dat <- "/Users/lestes/Dropbox/data/climate/temp/zambia"  # netcdf location
#  fnms <- dir(p_dat, pattern = ".nc$", full.names = TRUE)
#  
#  # create filepath/filename lookup table
#  onms <- data.frame(dirname = dirname(fnms), "ncpath" = fnms,
#                     "fnm" = basename(fnms), stringsAsFactors = FALSE)
#  onms$onm <- gsub("zambia_|_daily", "",   # create output names
#                   gsub("zambia_daily", "tmean",
#                        gsub("tas_20.*._5km_", "", onms$fnm)))
#  onms$onm <- paste0(onms$dirname, "/", gsub(".nc", "", onms$onm), "_",
#                     gsub("tas_|_5*.*", "", onms$fnm), ".tif")
#  
#  # read in one CHIRPs dataset to get resolution and extent
#  f <- "~/Dropbox/data/climate/rainfall/zambia/chirps/zam_chirps2015.tif"
#  chrp <- raster(f)
#  rres <- res(chrp)
#  
#  raster(onms$ncpath[1])
#  
#  # path to Zambia shape used as mask
#  p_zam <- "/Users/lestes/Dropbox/data/political/zambia/zambia.sqlite"
#  
#  # Process stacking and masking in batch using gdalwarp
#  for(i in 1:nrow(onms)) {  # i <- 1
#    gdalwarp(srcfile = onms$ncpath[i], dstfile = onms$onm[i], tr = rres,
#             s_srs = proj4string(chrp), cutline = p_zam, r = "bilinear",
#             crop_to_cutline = TRUE, dstnodata = -999, overwrite = TRUE)
#    print(glue("finished writing {onms$onm[i]}"))
#  }

