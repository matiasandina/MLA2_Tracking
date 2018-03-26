


count_quadrant <- function(dataframe, width=640, height=480){
  

  
dataframe <- dataframe %>% mutate(quadrant = if_else(X < width/2 & Y > height/2, 1,
                                         if_else(X > width/2 & Y > height/2, 2,
                                         if_else(X < width/2 & Y < height/2, 3,
                                                 4))))  

rats <- unique(dataframe$RatID)   

for (i in 1:length(rats)){

p <- ggplot(filter(dataframe, RatID==rats[i], animal!=rats[i]) ,
         aes(frameID, quadrant, color=animal)) +
    geom_jitter(alpha=0.5) +
    scale_color_manual(values =  c("#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
    theme_classic()+ 
    theme(legend.position = 'bottom')
  
print(p)    

}

return(dataframe)

}


