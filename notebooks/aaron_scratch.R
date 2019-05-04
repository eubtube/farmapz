
install.packages("C:/Users/euban/Desktop/rmapaccuracy.zip", repos = NULL)

library(sf)
library(sp)
library(raster)
library(rgdal)
library(rgeos)
library(maps)
library(farmapz)
library(rmapaccuracy)

# maps made by Mechanical Turk workers
zamworkers <- readOGR("data/CSV Data/worker_fmaps.sqlite", layer = "worker_fmaps", verbose = FALSE)

uniq_workers <- zamworkers[which(!duplicated(zamworkers$gid)), ]

# ground-truth fields
zamtruth <- readOGR("data/CSV Data/truth_fmatch.sqlite", layer = "truth_fmatch", verbose = FALSE)

# sample grids
zamfgrids <- readOGR("data/CSV Data/fgrids_alb.sqlite", layer = "fgrids_alb", verbose = FALSE)

#List of Worker Assignments
assn <- read.csv("data/CSV Data/fassignments.csv")


#Zhenhua Code
# maps made by Mechanical Turk workers
# features:14
#zamworkers_sub <- readOGR("data/CSV Data/workers_sub.sqlite", verbose = FALSE)
zamworkers_sub <- st_read("data/CSV Data/workers_sub.sqlite", layer = "workers_sub")

# ground-truth fields
# features:17
#zamtruth_sub<- readOGR("data/CSV Data/Truth_sub.sqlite", verbose = FALSE)
zamtruth_sub<- st_read("data/CSV Data/Truth_sub.sqlite", layer = "Truth_sub")

# sample grids
# features:14
#zamfgrids_sub <- readOGR("data/CSV Data/grids_sub.sqlite", verbose = FALSE)
zamfgrids_sub <- st_read("data/CSV Data/grids_sub.sqlite", "grids_sub")


lapply(1:length(zamtruth_sub), function(x){
  lapply(1:length(zamfgrids_sub), function(y){
    if(zamfgrids_sub$name[y] == zamtruth_sub$name[x]){
      tempfgrid_id <- zamfgrids_sub$name[y]
      tempint <- which(
        gIntersects(
          spgeom1 = zamfgrids_sub[zamfgrids_sub$name == tempfgrid_id,],
          spgeom2 = zamworkers_sub, byid = T))
    }
  })
  
})

#Looping

#Who Knows
for (i in zamtruth_sub$ogc_fid0)
  if(i == zamworkers_sub$name[i])
    for (j in zamworkers_sub$name)
      if (j == i){
        print(zamworkers_sub$fieldname[j])
    }

#Starting Loop for Subset
for (i in 1:nrow(zamtruth_sub)){ 
  if(zamtruth_sub$name[i] %in% zamworkers_sub$name)
    print(zamworkers_sub[zamworkers_sub$name == zamtruth_sub$name[i], "ogc_fid0"])
}

#Starting Loop for Full Set
for (i in 1:nrow(zamtruth)){ 
  if(as.character(zamtruth$name[i]) %in% as.character(zamworkers$name))
    print(zamworkers[as.character(zamworkers$name) == as.character(zamtruth$name[i]), "gid"])
}

for (i in 1:nrow(zamtruth_sub)){ 
  if(zamtruth_sub$name[i] %in% zamworkers_sub$name){
    # print(i)
    templength <-
      length(zamworkers_sub[zamworkers_sub$name == zamtruth_sub$name[i], "gid"])
    print(templength)
    # 
    temp <- zamworkers_sub[zamworkers_sub$name == zamtruth_sub$name[i], "gid"]
    print("11111111111111111111111111111111111111")
    # truth polygon that temp intersected with
    temptruth <- zamtruth_sub[zamtruth_sub$name[i],]
    tempgidlist <- list()
    for (poly in 1:templength) {
      if(gIntersects(spgeom1 = temp[poly,],
                     spgeom2 = temptruth,
                     byid = T)==TRUE){
        # temp[poly,] %>% plot()
        # temptruth %>% plot(col="red",add=TRUE)
        # print("haha")
        tempgidlist <- tempgidlist %>%
          append(polygons(temp[poly,]))
        if(area(st_intersection(temptruth, temp[poly, ]) < 0.5(area(temptruth)))){
          message("no intersection")
        }
      }
      else{
        message("no intersection")
      }
      
      # print("2222222222222222222222222222222222222")
      print(tempgidlist)
    }
    
  }
}


for (i in 1:nrow(zamfgrids_sub)){
  if(zamtruth_sub$name[i] )
}

# plot(zamfgrids)
# plot(zamworkers)
# plot(zamtruth)


'''
#Looping

for (i in zamfgrids_sub$name)
  for (j in zamworkers_sub$name)
    if (j == i){
      print(zamworkers_sub$fieldname[j])
  }

zamworkers_sub$fieldname[1]


# subset truth fields using truth$id to remove duplicates
truth_un <- truth[which(!duplicated(truth$id)),]

# find which truth(s) intersect(s) with workers
int <- lapply(1:length(workers), function(x){
  which(gIntersects(spgeom1 = workers[x, ], spgeom2 = truth_un, byid = T))
})

# get intersection polygons
int$polys <- lapply(1:length(workers), function(x){
  if(length(int[[x]]) > 0){
    gIntersection(spgeom1 = workers[x,], spgeom2 = truth_un, byid = T)
  }
})

# calculate areas
int$areas <- lapply(1:length(int$polys), function(x){
  if(length(int[[x]]) > 0){
    gArea(int$polys[[x]], byid = T)
  }else{
    0
  }
})

# calculate area of truth_un
truth_un$area <- gArea(truth_un, byid = T)

# calculate tp
workers$tp <- lapply(1:length(int$areas), function(x){
  if(length(int[[x]]) == 1){
    int$areas[[x]] / truth_un$area[[int[[x]][which.max(int$areas[[x]])]]]
  }else if(length(int[[x]]) > 1){
    sum(int$areas[[int[[x]][which.max(int$areas[[x]])]]] /
          truth_un$area[[int[[x]][which.max(int$areas[[x]])]]])
  }else{
    0
  }
})

# calculate fp using gDifference
dif_polys <- lapply(1:length(workers), function(x){
  if(length(int[[x]]) == 1){
    gDifference(spgeom1 = workers[x,], spgeom2 = truth_un)
  } else if(length(int[[x]]) > 1){
    gDifference(spgeom1 = workers[x,],
                spgeom2 = truth_un[int[[x]][which.max(int$areas[[x]])],],
                byid = T)
  }
})

dif_polys$area <- lapply(1:length(workers), function(x){
  if(length(dif_polys[[x]]) > 0){
    gArea(dif_polys[[x]])
  } else{
    0
  }
})

workers$fp <- lapply(1:length(dif_polys$area), function(x){
  if(length(int[[x]]) == 1){
    dif_polys$area[[x]] / truth_un$area[[int[[x]][which.max(int$areas[[x]])]]]
  }else if(length(int[[x]]) > 1){
    sum(dif_polys$area[[int[[x]][which.max(int$areas[[x]])]]] /
          truth_un$area[[int[[x]][which.max(int$areas[[x]])]]])
  }else{
    0
  }
})


# calculate fn using erase
erase_polys <- lapply(1:length(workers), function(x){
  if(length(int[[x]]) == 1){
    erase(x = truth_un[int[[x]],], y = workers[x,])
  } else if(length(int[[x]]) > 1){
    erase(x = truth_un[int[[x]][which.max(int$areas[[x]])],], y = workers[x,])
  }
})

erase_polys$area <- lapply(1:length(workers), function(x){
  if(length(erase_polys[[x]]) > 0){
    gArea(erase_polys[[x]], byid = T)
  } else{
    0
  }
})

workers$fn <- lapply(1:length(erase_polys$area), function(x){
  if(length(int[[x]]) == 1){
    erase_polys$area[[x]] / truth_un$area[[int[[x]][which.max(int$areas[[x]])]]]
  }else if(length(int[[x]]) > 1){
    sum(erase_polys$area[[int[[x]][which.max(int$areas[[x]])]]] /
          truth_un$area[[int[[x]][which.max(int$areas[[x]])]]])
  }else{
    0
  }
})
'''
