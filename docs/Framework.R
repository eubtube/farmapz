#Framework 

#Use intersect to determine true postive area of each polygon

#USe Differencing for to determine error outside of truth polygon (false Postive)

#area that is within the truth polygon that does not intersect with the mechanical turks polygon
#compare intersected area with area of truth (false negative)

#somehow eliminate all mechanical Turks polygons that do not have centroid or significantly intersect with truth polygon

#rmap_accuracy package



##looping framework

# For each ground truth polygon (i)  {for i in truth}
# Find the grids it intersects with (j)  {return j that i intersects with}
# For each grid j, select the corresponding assignments mapped there (k) {for j in fgrids}
# From each selected assignment k, find:  
#   if there is a field in k that intersects truth polygon i:
#   then calculate the accuracy statistics for that intersecting field:
#   true positive area
# false positive area
# false negative area
# if there is no intersecting field,
# then record:
#   false negative area