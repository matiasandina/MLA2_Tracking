# Here we analyze whether there are points that shouldn't be there
# Errors in tracking could be 
# 1) Not able to detect >> goes to 0 or NA
# 2) False detection



clean_track <- function(dataframe){
  
  # Zero values should go to NA before we do anything

  dataframe[dataframe == 0] <- NA
  
  # calculate distnace between rows
  # This is xy distance so we will consider big steps in 2D
  
  li <- list()
  
  for(i in 1:(nrow(dataframe)-1)){ # mind the -1 so it doesn't overflow
  
  current_row <- dataframe[i, 2:3]
  next_row <- dataframe[(i+1), 2:3]  
  
  li[i] <- euc.dist(current_row, next_row)
    
  }
  
  return(li)
  
}



euc.dist <- function(row1, row2) sqrt(sum((row1 - row2) ^ 2))