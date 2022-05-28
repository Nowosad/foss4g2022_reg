# A Method for Universal Supercells-Based Regionalization (Preliminary Results)

This repository contains the code for case studies presented in Nowosad J., Stepinski T.F., Iwicki M. *A Method for Universal Supercells-Based Regionalization (Preliminary Results)*.
The International Archives of the Photogrammetry, Remote Sensing and Spatial Information Sciences (2022).

## Requirements

You need to install several R packages to reproduce the following code examples.
You can find the packages' installation code in [`R/package-installation.R`](R/package-installation.R).

## Data

The code examples are based on the Copernicus Global Land Service: Land Cover 100m data for the year 2019.
The study area is about 4200 km<sup>2</sup> located in the eastern Netherlands.
The input data is located in [raw-data/all_ned.tif](raw-data/all_ned.tif).
The data can also be found on [https://lcviewer.vito.be/2015](https://lcviewer.vito.be/2015).

## Code examples

1. PCA base map - [`R/raster_pca_rgb.R`](R/raster_pca_rgb.R)
2. Superpixels combined with the kmeans algorithm - [`R/superpixels_and_kmeans.R`](R/superpixel_and_kmeans.R)
3. Superpixels combined with the SKATER algorithm - [`R/superpixels_and_skater.R`](R/superpixels_and_skater.R)
4. Comparison on the two presented workflow - [`R/multi_calculation.R`](R/multi_calculation.R)
