# This function gets the median MajorAxis of the animal
# We have false detection/NAs that normally go to 0 and get smoothed to 0 in this column
# Thus, we subset them out

MajorAxis_median <- function(xy_list){
  
  data1 <- lapply(xy_list, function(qq) bind_rows(qq, .id='animal'))
  
  data_subset <- lapply(data1, function(df) select(df, animal, MajorAxis))
  
  # Bind rows, filter only the rats, mutate and summarise median major axis
  data_bind <- bind_rows(data_subset, .id="RatID") %>%
               filter(RatID == animal) %>%
               mutate(MajorAxis = ifelse(MajorAxis>0, MajorAxis, NA)) %>%
               group_by(RatID) %>%
               summarise(medianMajorAxis = median(MajorAxis, na.rm=T))
   
  return(data_bind)
  
}
