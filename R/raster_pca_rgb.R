library(terra)
# read input multidimensional raster data ---------------------------------
input_raster = rast("raw-data/all_ned.tif")
plot(input_raster)

# calculate PCA -----------------------------------------------------------
input_raster_df = as.data.frame(input_raster)
pca_results = prcomp(input_raster_df)
summary(pca_results)
pca_results$rotation

# create PCA raster -------------------------------------------------------
raster_pca = predict(input_raster, pca_results)
plot(raster_pca)

# reorder, rotate and stretch the results ---------------------------------
# it ease the interpretation
raster_pca_rgb = raster_pca[[c(2, 1, 3)]]
raster_pca_rgb$PC2 = raster_pca_rgb$PC2 * -1
raster_pca_rgb$PC3 = raster_pca_rgb$PC3 * -1
raster_pca_rgb = stretch(raster_pca_rgb, maxq = 0.98)
plotRGB(raster_pca_rgb)

# save the results --------------------------------------------------------
dir.create("data")
writeRaster(raster_pca_rgb, "data/raster_pca_rgb.tif", overwrite = TRUE)
