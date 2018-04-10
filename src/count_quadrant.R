# Count quadrant will take a xy df and calculate what quadrant animals are
# To calculate the quadrants, we use the width and height defined by video resolution
# Keep defaults unless you change resolution

# Additionally we return a summary of the time in quadrant

count_quadrant <- function(dataframe, PlotMe=FALSE, width=640, height=480){
  

  
dataframe <- dataframe %>% mutate(quadrant = if_else(X < width/2 & Y > height/2, 1,
                                         if_else(X > width/2 & Y > height/2, 2,
                                         if_else(X < width/2 & Y < height/2, 3,
                                                 4))))  

pup_together <- dataframe %>% group_by(RatID, frameID) %>%
                summarise(together = ifelse(length(unique(quadrant)) == 1, "3-together",
                          ifelse(length(unique(quadrant)) == 2, "2-together",
                                     "separated"))) %>%
        mutate(together = factor(together,
                           levels=c("separated", '2-together', '3-together')))




rats <- unique(dataframe$RatID)   

# If we wanted to have all animals together we should use facets...

for (i in 1:length(rats)){


  pup_data <- filter(dataframe, RatID==rats[i], animal!=rats[i])

# Make first plot 
  
  if(PlotMe){
    p <- ggplot(pup_data,
                aes(frameID, quadrant, color=animal)) +
      geom_jitter(alpha=0.5) +
      scale_color_manual(values =  c("#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
      theme_classic()+ 
      theme(legend.position = 'bottom')
    
    print(p)    
    
  }
  

together_data <- pup_data %>% group_by(frameID) %>%
                 summarise(together = ifelse(length(unique(quadrant)) == 1, "3-together",
                                      ifelse(length(unique(quadrant)) == 2, "2-together",
                                      "separated"))) %>%
                 mutate(together = factor(together,
                       levels=c("separated", '2-together', '3-together')))

 if(PlotMe){
   p2 <- ggplot(together_data, aes(frameID, together)) +
     geom_jitter(size=3, alpha=0.5) +
     theme_classic()+ 
     ylab("")+
     scale_y_discrete(drop=FALSE)
   
   
   print(p2)
   
 }

}

return(list(xy_df = dataframe, pup_together=pup_together))

}


