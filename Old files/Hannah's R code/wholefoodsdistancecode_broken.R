
library(evaluate)
library(geosphere)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)

centroids <- read.csv("/Users/Xiang/OneDrive/Desktop/Math 199/Hannah's R code/census_centroids.csv") # store lat and long of census centroids
wholefoods <- read.csv("/Users/Xiang/OneDrive/Desktop/Math 199/Hannah's R code/AllWholeFoods.csv") # store locations of all store in LA

### compute nearest whole foods distance for all census tracks
# create vector for each centroid's distance to closest library,and save locations points of the nearest library
dist_vec<-rep(NA,2160)
min_lat_vec <-rep(NA,2160)
min_long_vec <-rep(NA,2160)

# loop through each centorid and calculate the distance to the nearest whole foods
for (i in 1:2160){
  
  current_lat <- centroids$lats[i]
  current_long <- centroids$lngs[i]
  min_dist <- 100000
  min_lat <- current_lat
  min_long <- current_long
  wholefoods$z<-as.numeric(wholefoods$z)
  wholefoods$y<-as.numeric(wholefoods$y)
  current_lat<-as.numeric(current_lat)
  current_long<-as.numeric(current_long)
  
  for (j in 1:length(wholefoods$y)){ # loop through all of ralphs locations
    temp_dist <- distm(c(wholefoods$z[j], wholefoods$y[j]), c(current_long, current_lat), fun = distHaversine)
    
    
    curFoodsLat <- wholefoods$y[j]
    curFoodsLong <-wholefoods$z[j]
    
    if (temp_dist < min_dist){ # find the location of the nearest store to the centroid
      min_dist <- temp_dist
      min_lat <- curFoodsLat
      min_long <- curFoodsLat
    }
    
  }
  dist_vec[i]=min_dist
  min_lat_vec[i]=min_lat
  min_long_vec[i] = min_long
}

# update centroids data with info about each tracks closest store
#CentroidsToStoresAndLibraries <-CentroidsToStores %>% mutate(nearest_wholefoods=dist_vec,nearest_wholefoods_lat=min_lat_vec, nearest_wholefoods_long_long=min_long_vec)

