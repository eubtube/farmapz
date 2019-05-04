library(sf)
library(dplyr)

# DATA MANAGEMENT
# maps made by Mechanical Turk workers
zamworkers_st  <- st_read("data/CSV Data/worker_fmaps.sqlite")

# ground-truth fields
zamtruth_st  <- st_read("data/CSV Data/truth_fmatch.sqlite")

# Worker ids and assignments assignments
zamassn <- read.csv("data/CSV Data/fassignments.csv")

# joining
zamworkers_st <- inner_join(x = zamworkers_st, y = zamassn, by = "assignment_id")

# Accuracy Function for use in the final loop
acc_stats_sum <- function(tp, fp, fn) {
  agree <- tp / sum(tp, fn)  # Simple agreement class 1
  if(is.na(agree)) agree <- 0  # Set to 0 if NA
  accuracy <- sum(tp) / sum(tp, fp, fn)
  #TSS <- agree + (tn / (fp + tn)) - 1  # Sens + specificity - 1
  r1 <- round(accuracy, 2)
  out <- c(r1)
  names(out) <- c("accuracy")
  return(out)
}

# Core

##wmap_stat <- tibble()

finaldataset <- do.call(rbind,lapply(1:nrow(zamtruth_st), function(x) {
  #x <- 1 (for testing)
  # Initializing
  p <- zamtruth_st[x, ]
  wdat <- zamassn %>% filter(zamassn$name == as.character(p$name))
  wmaps <- zamworkers_st %>% filter(name.x == as.character(p$name)) %>%
    filter(.$worker_id %in% wdat$worker_id)
  wnomaps <- wdat %>% filter(!worker_id %in% wmaps$worker_id)

# accuracy statistics info for all assignments corresponding with each truth poly
  #first tibble for case of worker assigned to grid, but no polygons mapped
  wnomap_stat <- tibble(truthid = p$id, gridid = p$name,
                        worker_id = wnomaps$worker_id, polyid = NA, tp = 0,
                        fp = 0, fn = p %>% st_area(), accuracy = 0)
  #New Lapply to iterate through polygons mapped by workers in a given grid
  temp_wmap_stat <- do.call(rbind, lapply(unique(wdat$worker_id), function(y) {
    # y <- unique(wdat$worker_id)[1] (for testing)
    ipoly <- st_intersects(p, wmaps %>% filter(worker_id == y)) %>% unlist
    wmaps_sub <- wmaps %>% filter(worker_id == y) %>% st_buffer(., 0)
    #first condition for cases of no intersecting polygons with truth polygon
    if(length(ipoly) == 0){
      tp <- 0
      fp <- 0
      fn <- p %>% st_area()
      acc <- 0
      #first
      wmap_stat <- tibble(truthid = p$id, gridid = p$name, worker_id = y,
                          polyid = NA, tp = tp, fp = round(fp, 4),
                          fn = round(fn, 4), accuracy = round(acc, 5))
    } else if(length(ipoly) == 1) {
      # second condition for cases of a single intersection
      tempwmaps <- st_buffer(wmaps %>% filter(worker_id == y), 0)
      iarea <- st_intersection(p, st_buffer(tempwmaps, 0)) %>% st_area()
      if((iarea %>% as.numeric())/(p %>% st_area() %>% as.numeric()) >= 0.05){
        tp <- st_intersection(p, wmaps_sub) %>% st_area() %>% sum(.)
        fp <- st_difference(wmaps_sub, p) %>% st_area() %>% sum(.)
        fn <- st_difference(p, wmaps_sub) %>% st_area() %>% sum(.)
        acc <- sum(tp) / sum(tp, fp, fn)
        wmap_stat <- tibble(truthid = p$id, gridid = p$name, worker_id = y,
                            polyid = tempwmaps[ipoly[1],]$gid, tp = tp,
                            fp = round(fp, 4), fn = round(fn, 4),
                            accuracy = round(acc, 5))
      }
      else{
        wmap_stat <- tibble(truthid = p$id, gridid = p$name, worker_id = y,
                            polyid = tempwmaps[ipoly[1],]$gid, tp = NA,
                            fp = NA, fn = NA,
                            accuracy = NA)
      }
    } else { #if(length(ipoly) > 1){ (for testing)
      # third condition for cases where there are two or more polygons in the same grid
      iterlength <- length(ipoly)
      maxarea <- 0
      tempwmaps <- st_buffer(wmaps %>% filter(worker_id == y), 0)
      wmap_stat <- tibble()
      for (i in 1:iterlength) {
        iarea <- st_intersection(p, st_buffer(tempwmaps[ipoly[i],], 0)) %>%
          st_area()
        if((iarea %>% as.numeric())/(p %>% st_area() %>% as.numeric()) >= 0.05){
          # excludes worker polygons that share less than 5% of the truth polygon's area
          tp <- iarea %>% sum(.)
          fp <- st_difference(st_buffer(tempwmaps[ipoly[i],], 0), p) %>%
            st_area() %>% sum(.)
          fn <- st_difference(p, st_buffer(tempwmaps[ipoly[i],], 0)) %>%
            st_area() %>% sum(.)
          acc <- sum(tp) / sum(tp, fp, fn)
          wmap_stat <- rbind(wmap_stat, tibble(truthid = p$id, gridid = p$name,
                                               worker_id = y,
                                               polyid = tempwmaps[ipoly[i],]$gid,
                                               tp = tp, fp = round(fp, 4),
                                               fn = round(fn, 4),
                                               accuracy = round(acc, 5)))

        } else {
          # worker polygons that share less than 5% of the truth polygon's area
          wmap_stat <- rbind(wmap_stat, tibble(truthid = p$id, gridid = p$name,
                                               worker_id = y,
                                               polyid = tempwmaps[ipoly[i],]$gid,
                                               tp = NA, fp = NA,
                                               fn = NA,
                                               accuracy = NA))
        }
      }
      wmap_stat <- wmap_stat
    }
  }))
  wmap_stat <- rbind(temp_wmap_stat, wnomap_stat)
}))

View(finaldataset)
