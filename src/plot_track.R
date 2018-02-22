# This function grabs centroids and plots them correctly

library(ggplot2)


plot_track <- function(dataframe){
  
plot1 <- ggplot(dataframe,
                aes(x, y, group=source, color=source)) +
  geom_path()  
  
return(plot1) 

}