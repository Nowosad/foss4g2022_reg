create_regions_rgeoda = function(k, vect_obj, rast_obj, regmethod = rgeoda::skater, distmethod, ...){
  weight = sf::st_drop_geometry(vect_obj[, !colnames(vect_obj) %in% c("supercells", "x", "y")])
  if (!missing(distmethod)){
    weight_dist = philentropy::distance(weight, method = distmethod, as.dist.obj = TRUE)
    weight_dist_vec = as.vector(weight_dist)
  } else {
    weight_dist_vec = numeric()
    distmethod = "euclidean"
  }
  
  rook_w = rgeoda::rook_weights(vect_obj)
  res = regmethod(k, rook_w, weight, random_seed = 1, cpu_threads = 1, rdist = weight_dist_vec)
  
  vect_obj$cluster = res$Clusters
  
  regions = aggregate(vect_obj, by = list(vect_obj$cluster), mean)
  regions = st_cast(regions, "POLYGON")
  
  regions_vals = extract(rast_obj, vect(regions))
  regions_vals = aggregate(regions_vals, by = list(regions_vals$ID), mean)
  
  regions_reg = cbind(regions["cluster"], regions_vals)
  regions_reg$n = nrow(regions_reg)
  regions_reg = regions_reg[-c(1:3)]
  regmethodname = as.character(substitute(regmethod))[[3]]
  distmethodname = ifelse(distmethod == "jensen-shannon", "jsd", distmethod)
  regions_reg$type = paste0(regmethodname, distmethodname)
  regions_reg$area_km2 = as.numeric(st_area(regions_reg)) / 1000000
  return(regions_reg)
}

create_regions_kmeans = function(k, vect_obj, rast_obj, ...){
  # vect_df = sf::st_drop_geometry(vect_obj)
  vect_df = sf::st_drop_geometry(vect_obj[, !colnames(vect_obj) %in% c("supercells", "x", "y")])
  
  km = kmeans(vect_df, k, ...)
  vect_obj$cluster = unname(km$cluster)
  
  regions = aggregate(vect_obj, by = list(vect_obj$cluster), mean)
  suppressWarnings({regions = sf::st_cast(regions, "POLYGON")})
  
  regions_vals = terra::extract(rast_obj, vect(regions))
  regions_vals = aggregate(regions_vals, by = list(regions_vals$ID), mean)
  
  regions_kmeans = cbind(regions["cluster"], regions_vals)
  regions_kmeans$n = nrow(regions_kmeans)
  regions_kmeans = regions_kmeans[-c(1:3)]
  regions_kmeans$type = "kmeans"
  regions_kmeans$area_km2 = as.numeric(st_area(regions_kmeans)) / 1000000
  return(regions_kmeans)
}

add_quality_metrics = function(regs, rast_obj, distmethod = "euclidean", outnames = c("inh", "iso") , ...){
  regs_vals = regs[c("Forest", "Shrubland", "Grassland", "Bare.Sparse.vegatation", 
                     "Cropland", "Built.up", "Seasonal.inland.water", "Permanent.inland.water")]
  regs[outnames[1]] = regional::reg_inhomogeneity(regs_vals, rast_obj, dist_fun = distmethod, ...)
  regs[outnames[2]] = regional::reg_isolation(regs_vals, rast_obj, dist_fun = distmethod, ...)
  return(regs)
}

extract_info = function(x){
  tibble::tibble(type = unique(x$type), n = unique(x$n))
}

get_weighted_inh = function(x){
  inh = x[["inh"]] 
  area = x[["area_km2"]]
  weighted.mean(inh, area)
}

get_unweighted_iso = function(x){
  mean(x[["iso"]])
}