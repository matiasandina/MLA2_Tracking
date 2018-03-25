# Distance analysis

# This function provides distance analysis.
# It's a bit extensive on the computation so be patient

# Setup ####

# Packages

library(dplyr)
suppressPackageStartupMessages(library(KernSmooth))
library(ggplot2)
library(stringr)

# Sourcing functions
if(!exists("read_rat_smooth", mode="function")) source("read_rat_smooth.R")
if(!exists("pair_xy_dist", mode="function")) source("pair_xy_dist.R")

# Get animals that have been ran
ran_animals <- read.csv('MLA_Animal_Video_Key.csv', stringsAsFactors = T)

animal_list <- list.files(path='data')

# Read the data ####
xy_pos <- lapply(animal_list, function(q) read_rat_smooth(q))
names(xy_pos) <- animal_list


# Calculate rat-pup distance #####
# Get the distance to the pups

pup_dist <- function(mydata){

  data_to_dist <- lapply(mydata, function(t) t[,1:2])
  
  rat_pup_dist <- lapply(data_to_dist[2:4],
                         function(q) pair_xy_dist(data_to_dist[[1]], q))
  
  rat_pup_dist <- bind_cols(rat_pup_dist)
  rat_pup_dist <- rat_pup_dist %>% mutate(frameID = 1:nrow(rat_pup_dist))

  return(rat_pup_dist)
  
}


# Get mom-pup distance for each animal
distance_list <- lapply(xy_pos, function(qq) pup_dist(qq))
names(distance_list) <- animal_list


# Fix names ####
# Pup names are contaminated with RatID
# RatIDs were passed as the names for the list so we can get rid of them 
# Alternatively we could gsub rat IDs recursively? 

fix_pup_names <- function(names_to_fix){
  str_extract(names_to_fix, c("red_pup$|green_pup$|blue_pup$|frameID"))
} 

for(i in 1:length(distance_list)){
  fix_these_names<-names(distance_list[[i]])
  names(distance_list[[i]]) <- fix_pup_names(fix_these_names)
}


# Bind all the animals in the list

distance_df <- bind_rows(distance_list, .id='RatID') %>%
               group_by(RatID, frameID) %>%
               mutate(total_dist = sum(blue_pup, green_pup, red_pup),
                      mean_dist = mean(blue_pup, green_pup, red_pup))


# Calculate distance between pups (pup to pup distance)

between_pup_dist <- function(mydata){
  
  data_to_dist <- lapply(mydata, function(t) t[,1:2])
  
  pup_dist <- lapply(data_to_dist[3:4],
                         function(q) pair_xy_dist(data_to_dist[[2]], q))
  
  pup_dist <- bind_cols(pup_dist)
  pup_dist <- pup_dist %>% mutate(frameID = 1:nrow(pup_dist))
  
  return(pup_dist)
  
}

between_pup <- lapply(xy_pos, function(qq) between_pup_dist(qq))

# Fix the names

for(i in 1:length(between_pup)){
  fix_these_names<-names(between_pup[[i]])
  names(between_pup[[i]]) <- fix_pup_names(fix_these_names)
}

# Plot distance vs frame 

between_pup %>% bind_rows(, .id="RatID") %>%
  group_by(RatID, frameID) %>% mutate(between_pup_dist = green_pup + red_pup) %>%
  select(RatID, frameID, between_pup_dist) %>%
  left_join(distance_df) %>%
  left_join(ran_animals) %>%
  ggplot(aes(frameID, total_dist, color=Group))+
  geom_line() +
  geom_line(aes(frameID, between_pup_dist), color='black', lty=2) + facet_wrap(~RatID)
  
ggplot(distance_df, aes(frameID, mean_dist))+
  geom_line() + facet_wrap(~RatID)


# Calculate full XY position into a df 
# we don't need to plot it (custom_2d_hist is meant to plot)

XY_df <- custom_2d_hist(xy_pos)

XY_df <- XY_df %>%  group_by(animal) %>%
                    mutate(diff_x = c(0, diff(X)),
                           diff_y=c(0, diff(Y)),
                           Step= sqrt(diff_x^2 + diff_y^2),
                           total_track=cumsum(Step))

ggplot(XY_df, aes(frameID, total_track, color=animal)) +
  geom_point() +
  facet_wrap(~RatID) +
  theme(legend.position = 'none')

# Select only mothers

total_dist <- XY_df %>%
              filter(RatID==animal) %>%
              group_by(RatID) %>%
              select(RatID, animal, total_track, Step, total_track) %>%
              summarise(integrated_path = sum(total_track), 
                        mean_Step = mean(Step))

custom_2d_hist(xy_pos, TRUE)



SD99O1 <- filter(XY_df, animal=="SD99O1") %>%
          ungroup %>%
          select(RatID, X,Y, frameID) %>%
          mutate( deltaLag1 = X - lag(X, 1),
                  deltaLag2 = X - lag(X, 2)
          )

