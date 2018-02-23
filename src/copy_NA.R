### This function will replace NAs by copying the closest value
### The default is to copy from the bottom
### The function is vectorized


copy_NA <- function(dat, split.gap=FALSE) {
  N <- length(dat)
  na.pos <- which(is.na(dat))
  
  # if dat is full or completely empty do nothing (return out)
  if (length(na.pos) %in% c(0, N)) {
    return(dat)
  }
  non.na.pos <- which(!is.na(dat))
  intervals  <- findInterval(na.pos, non.na.pos,
                             all.inside = TRUE)
  left.pos   <- non.na.pos[pmax(1, intervals)]
  right.pos  <- non.na.pos[pmin(N, intervals+1)]
  left.dist  <- na.pos - left.pos
  right.dist <- right.pos - na.pos
  
  
  
  
  if(split.gap){
    dat[na.pos] <- ifelse(left.dist <= right.dist,
                          dat[left.pos], dat[right.pos])  
  } else{
  
  # defaults to left (left being before)  
    dat[na.pos] <- dat[left.pos]

  }
  
  return(dat)
}
