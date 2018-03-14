# This function calculates xy distance row-wise between 2 dataframes
# Expecting dataframes with only xy and identical dimension

pair_xy_dist <- function(dataframe1, dataframe2){
  
  
  # define the distance function we are going to use (euclidean)
  euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))
  
  if(ncol(dataframe1)>2 | !identical(dim(dataframe1), dim(dataframe2))){
    print(sprintf('dataframe1 has %d rows and %d columns', nrow(dataframe1), ncol(dataframe1)))
    print(sprintf('dataframe2 has %d rows and %d columns', nrow(dataframe2), ncol(dataframe2)))
    stop("Expecting dataframes with identical dimensions and 2 col (nx2). Check dimensions")
  }
  

  
# This runs a bit slower than using sapply     
# val <- vector(mode="numeric", length=nrow(dataframe1))
#   for(i in 1:nrow(dataframe1)){
#  
#  val[i] <- euc.dist(dataframe1[i,], dataframe2[i,])
#  
# }

 val <- sapply(1:nrow(dataframe1),
               FUN = function(q) euc.dist(dataframe1[q,], dataframe2[q,]))

 # total distance not needed, can be easily recalculated elsewhere  
 # total_dist <- sum(val)
 # li <- list(total_dist=total_dist, val=val)
  
  return(val)    
  
}


# set.seed(123)
# 
# pru_set <- data.frame(x=rnorm(n = nrow(rat_pos), mean = 620, sd=1),
#                       y=rnorm(n = nrow(rat_pos), mean = 420, sd=1))
# 
# 
# AA <- pair_xy_dist(rat_pos[,1:2], pru_set)
# 
# 
# plot(AA$val, type='b')