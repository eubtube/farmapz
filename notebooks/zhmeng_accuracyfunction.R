
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



map_accuracy <- function(maps, truth) {
    tp <- st_intersection(truth, maps)
    fp <- st_difference(maps, truth)
    fn <- st_difference(truth, maps)
  tflist <- c("tp", "fp", "fn")
  areas <- sapply(tflist, function(x) {
    xo <- get(x)  # fix to deal with non-null sf objects
    ifelse(!is.null(xo) & is.object(xo) & length(xo) > 0, st_area(xo), 0)
  })
  names(areas) <- tflist
  # acc_stats <- accStatsSum(tp = areas["tp"], fp = areas["fp"],
  acc_stats <- acc_stats_sum(tp = areas["tp"], fp = areas["fp"],
                             fn = areas["fn"])
  return(list("stats" = acc_stats, "tp" = tp, "fp" = fp, "fn" = fn))
}


##Test with sample polygons
worker <- st_as_sf(zamworkers_sub[zamworkers_sub$gid == 214698, ])
truth <- st_as_sf(zamtruth_sub[zamtruth_sub$id == 778, ])

acc_list <- map_accuracy(worker, truth)

plot(st_geometry(acc_list$tp))
