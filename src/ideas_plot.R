# Options for plotting

library(stringr)
library(ggplot2)
library(ggExtra)

mydata <- read_rat_smooth('SD74O2Q2')
mydata <- read_rat_smooth('SD76N3Q1')
mydata <- read_rat_smooth('SD85S1N1')

data_to_dist <- lapply(mydata, function(t) t[,1:2])

rat_pup_dist <- lapply(data_to_dist[2:4], function(q) pair_xy_dist(data_to_dist[[1]], q))

rat_pup_dist <- bind_cols(rat_pup_dist)
rat_pup_dist <- rat_pup_dist %>% mutate(frameID = 1:nrow(rat_pup_dist))

molten_pup_dist <- reshape2::melt(rat_pup_dist, id='frameID')

ggplot(molten_pup_dist, aes(frameID, value, color=variable)) +
  ylab("Distance to adult (px)")+
  geom_point() 


# https://daattali.com/shiny/ggExtra-ggMarginal-demo/
# only works correctly if installing from gitHub
  
  pp <- ggplot(mydata$SD74O2Q2, aes(X, Y)) +
  geom_point(alpha=0.1) +
  theme_classic()
ggMarginal(pp,
           type = 'density',
           margins = 'both',
           size = 5,
           colour = 'black',
           fill = '#E69F00')

g <- ggplotGrob(ggplot(mydata$SD74O2Q2, aes(X))) + geom_density()
pp + annotation_custom(grob = g, xmin = 0, xmax = 640, ymin = 30, ymax = 50)

df <- dplyr::bind_rows(mydata, .id="id")

ggplot(df, aes(X, Y)) +
  #stat_density2d(geom = 'tile', aes(fill = ..density..), contour = FALSE,
  #               n = c(xbins, ybins)) +
  geom_point(aes(color=id), alpha=0.4) + 
  geom_path(alpha=0.1) +
  scale_y_reverse() +
  coord_equal() +
  theme_minimal() +
  scale_color_manual(values =  c("gray50", "#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
  geom_vline(xintercept = c(0,640))+
  geom_hline(yintercept = c(0,480)) + facet_wrap(~id)
#  theme_void()


refCol <- colorRampPalette(rev(brewer.pal(6,'Spectral')))
mycol <- refCol(6)

# define bin sizes
bin_size <- 40

xbins <- 640/bin_size
ybins <- 480/bin_size

ggplot(df, aes(X, Y, fill=id)) +
  stat_density2d(geom = 'tile', aes(fill = ..density..), contour = FALSE,
                 n = c(xbins, ybins)) +
  #geom_point(aes(color=id), alpha=0.4) + 
  #geom_path(alpha=0.1) +
  scale_y_reverse() +
  coord_equal() +
  theme_minimal() +
  scale_fill_gradientn(colors =  mycol) +
  geom_vline(xintercept = c(0,640))+
  geom_hline(yintercept = c(0,480)) + facet_wrap(~id)
#  theme_void()

# Fill by id 
# Remove fill=id if you want grayscale
# change breaks in scale_alpha_continuous for tunning

ggplot(df, aes(X, Y)) +
  stat_density2d(geom = 'tile', aes(fill=id, alpha = ..density..), contour = FALSE,
                 n = c(xbins, ybins)) +
  #geom_point(aes(color=id), alpha=0.4) + 
  geom_path(alpha=0.1) +
  scale_y_reverse() +
  coord_equal() +
  theme_minimal() +
#  scale_fill_gradientn(colors =  mycol) +
  scale_alpha_continuous(limits=c(0,0.6e-4), breaks=1e-5*seq(0,10,by=2))+
  geom_vline(xintercept = c(0,640))+
  geom_hline(yintercept = c(0,480)) + facet_wrap(~id)
#  theme_void()



# time-wise 2D histogram

df_timewise <- df %>% group_by(id) %>% mutate(rowID = row_number())

from_subset <- 1
n_partitions <- 3

for(i in 1:n_partitions){

  my_title <- sprintf("Histogram 2d partition %d of %d", i, n_partitions)
  
  to_subset <- i/3 * nrow(df_timewise) / length(unique(df_timewise$id))
  
  qq <- filter(df_timewise, between(rowID, from_subset, to_subset)) %>%
  ggplot(aes(X, Y)) +
    stat_density2d(geom = 'tile', aes(fill=id, alpha = ..density..), contour = FALSE,
                   n = c(xbins, ybins)) +
    #geom_point(aes(color=id), alpha=0.4) + 
    geom_path(alpha=0.5) +
    scale_y_reverse() +
    coord_equal() +
    theme_minimal() +
    ggtitle(my_title)+
    #  scale_fill_gradientn(colors =  mycol) +
    scale_alpha_continuous(limits=c(0,0.6e-4), breaks=1e-5*seq(0,10,by=2))+
    geom_vline(xintercept = c(0,640))+
    geom_hline(yintercept = c(0,480)) + facet_wrap(~id)
  #  theme_void()
    
  print(qq)
  
  from_subset <- to_subset
      
}



# using threshold of 100 to mean "close"

# TODO: Add several 'channels' for all the distances that need to be calculated
# Try within the same plot or as facets

# We can add a floor instead of it being 0
# close_binary <- data.frame(frameID = 1:length(AA$val),
#                            close=ifelse(AA$val<100, 4, 1))

close_binary <- molten_pup_dist %>% mutate(close=if_else(value < 100, 1, 0))

ggplot(close_binary, aes(frameID, close, fill=variable)) +
  geom_area(alpha=0.5) +
  #geom_point(size=1.2, alpha=0.3)+
  #geom_line()+
  theme_minimal() + facet_wrap(~variable, nrow=3)

# Plot directly the distance
# high values mean far away

val <- data.frame(frameID = 1:length(rat_pup_dist$SD74O2Q2blue_pup$val),
                  val = rat_pup_dist$SD74O2Q2blue_pup$val)

# Max distance as hypotenuse of a 640x480 rectangle
# (we know that distance is impossibly high, but...)
ggplot(val, aes(frameID, val)) +
  geom_area(fill='magenta', alpha=0.3)+
  theme_minimal()+
  geom_hline(yintercept = 800, lty=2)+
  annotate("text", label = "Max Distance",
           x = 7000, y = 780, size = 4)
