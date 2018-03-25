# Generate a 2D random Walk
# This code is from 
# https://assemblingnetwork.wordpress.com/2014/03/24/random-walks-in-r/

random_walk <- function(n.org, steps, left.p = .5, up.p = .5, plot = TRUE){
  
  require(ggplot2)
  
  whereto <- matrix(ncol = 2)
  
  for(x in 1:n.org){
    walker <- matrix(c(0,0), nrow = steps+1, ncol = 2, byrow = T)
    
    for(i in 1:steps){
      # left/right = 1/0
      horizontal <- rbinom(1, 1, left.p)
      
      # distance 2
      h.dist <- abs(rnorm(1, 0, 1))
      
      # Horizontal Movement
      if(horizontal == 0){
        walker[i+1,1] <- walker[i,1] + h.dist
      }
      if(horizontal == 1){
        walker[i+1,1] <- walker[i,1] - h.dist
      }
      
      # up/down = 1/0
      vertical <- rbinom(1, 1, up.p)
      
      #distance 2
      v.dist <- abs(rnorm(1, 0, 1))
      
      # Vertical Movement
      if(vertical == 1){
        walker[i+1,2] <- walker[i,2] + v.dist
      }
      if(vertical == 0){
        walker[i+1,2] <- walker[i,2] - v.dist
      }
    }
    
    whereto <- rbind(whereto, walker)
  }
  
  id <- rep(1:n.org, each = 1001)
  colnames(whereto) <- c("x" , "y")
  whereto <- as.data.frame(whereto)
  whereto <- cbind(whereto[2:nrow(whereto),], org = factor(id))
  
  if(plot){
    require(ggplot2)
    p <- ggplot(whereto, aes(x = x, y = y, colour = org))
    p <- p + geom_path()
    print(p)
  }
  
  return(whereto)
}
