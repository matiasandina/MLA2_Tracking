# Here we analyze whether there are points that shouldn't be there
# Errors in tracking could be 
# 1) Not able to detect >> goes to 0 or NA
# 2) False detection



clean_track <- function(dataframe){
  
  
  plot(dataframe$x, dataframe$y, pch=19)
  
  # Zero values should go to NA before we do anything

  dataframe[dataframe == 0] <- NA
  
  
  # Source helper function
  if(!exists("copy_NA", mode="function")) source("src/copy_NA.R")
  
  # We use the copy_NA function to roll over the gaps, we copy the last position
  
  dataframe$x.fill <- copy_NA(dataframe$x)
  dataframe$y.fill <- copy_NA(dataframe$y)
  
  
  
  points(dataframe$x.fill, dataframe$y.fill, col=alpha("red", 0.3), pch=19)
  
  
  # calculate distnace between rows
  # This is xy distance so we will consider big steps in 2D
  
  li <- list()
  
  for(i in 1:(nrow(dataframe)-1)){ # mind the -1 so it doesn't overflow
  
  current_row <- dataframe[i, 2:3]
  next_row <- dataframe[(i+1), 2:3]  
  
  li[i] <- euc.dist(current_row, next_row)
    
  }
  
  return(dataframe)
  
}



euc.dist <- function(row1, row2) sqrt(sum((row1 - row2) ^ 2))