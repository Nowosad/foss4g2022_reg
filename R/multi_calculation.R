library(supercells)
library(terra)
library(sf)
library(regional)
library(purrr)
source("R/funs.R")
set.seed(2022-05-13)
# read input multidimensional raster data ---------------------------------
input_raster = rast("raw-data/all_ned.tif")
plot(input_raster)

# create superpixels ------------------------------------------------------
superpixels = supercells(x = input_raster, step = 15, compactness = 0.1,
                         dist_fun = "jensen-shannon", minarea = 12)

# kmeans ------------------------------------------------------------------
kmeans_reg = map(c(2, 3, 4, 15, 100), create_regions_kmeans, superpixels, input_raster)

# skater jsd --------------------------------------------------------------
skaterjsd_reg = map(c(468, 690, 1034, 1947, 2986), create_regions_rgeoda,
                    superpixels, input_raster, distmethod = "jensen-shannon")

# combine -----------------------------------------------------------------
df = map_dfr(c(kmeans_reg, skaterjsd_reg), extract_info)
df$reg = c(kmeans_reg, skaterjsd_reg)

# add quality metrics ----------------------------------------------------
# this steps can take several minutes
df$reg = map(df$reg, add_quality_metrics, input_raster, 
             distmethod = "jensen-shannon", sample_size = 200)

# add overall quality metrics --------------------------------------------
df$weigh_inh = map_dbl(df$reg, get_weighted_inh)
df$unweigh_iso = map_dbl(df$reg, get_unweighted_iso)

# save results ------------------------------------------------------------
dir.create("data")
saveRDS(df, "data/multi_calculation_results.rds")

