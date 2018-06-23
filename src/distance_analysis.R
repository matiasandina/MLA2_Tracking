# Distance analysis

# This function provides distance analysis.
# It's a bit extensive on the computation so be patient

# Setup ####

# Packages

library(dplyr)
suppressPackageStartupMessages(library(KernSmooth))
library(ggplot2)
library(stringr)

# Sourcing functions
if(!exists("read_rat_smooth", mode="function")) source("read_rat_smooth.R")
if(!exists("pair_xy_dist", mode="function")) source("pair_xy_dist.R")
if(!exists("MajorAxis_median", mode="function")) source("MajorAxis_median.R")
if(!exists("custom_2d_hist", mode="function")) source("custom_2d_hist.R")
if(!exists("count_quadrant", mode="function")) source("count_quadrant.R")


# Get animals that have been ran
ran_animals <- read.csv('MLA_Animal_Video_Key.csv', stringsAsFactors = T)

animal_list <- list.files(path='data')

# Read the data ####
xy_pos <- lapply(animal_list, function(q) read_rat_smooth(q))
names(xy_pos) <- animal_list


# Calculate rat-pup distance #####
# Get the distance to the pups

pup_dist <- function(mydata){

  data_to_dist <- lapply(mydata, function(t) t[,1:2])
  
  rat_pup_dist <- lapply(data_to_dist[2:4],
                         function(q) pair_xy_dist(data_to_dist[[1]], q))
  
  rat_pup_dist <- bind_cols(rat_pup_dist)
  rat_pup_dist <- rat_pup_dist %>% mutate(frameID = 1:nrow(rat_pup_dist))

  return(rat_pup_dist)
  
}


# Get mom-pup distance for each animal
distance_list <- lapply(xy_pos, function(qq) pup_dist(qq))
names(distance_list) <- animal_list


# Fix names ####
# Pup names are contaminated with RatID
# RatIDs were passed as the names for the list so we can get rid of them 
# Alternatively we could gsub rat IDs recursively? 

fix_pup_names <- function(names_to_fix){
  str_extract(names_to_fix, c("red_pup$|green_pup$|blue_pup$|frameID"))
} 

for(i in 1:length(distance_list)){
  fix_these_names<-names(distance_list[[i]])
  names(distance_list[[i]]) <- fix_pup_names(fix_these_names)
}


# Bind all the animals in the list

distance_df <- bind_rows(distance_list, .id='RatID') %>%
               group_by(RatID, frameID) %>%
               mutate(total_dist = sum(blue_pup, green_pup, red_pup),
                      mean_dist = mean(blue_pup, green_pup, red_pup))


# Add the median major axis for each rat

mma <- MajorAxis_median(xy_pos)

# join mma with distance_df and calculate binary distnace ("close", "away")
# based on median/2

distance_df <- left_join(distance_df, mma) %>%
               mutate(blue_close = ifelse(blue_pup < medianMajorAxis/2, "close", "away"),
                      green_close = ifelse(green_pup < medianMajorAxis/2, "close", "away"),
                      red_close = ifelse(red_pup < medianMajorAxis/2, "close", 'away'))


# Get the mean axis
mean_axis <- left_join(distance_df, ran_animals) %>%
                 group_by(Group) %>%
                 summarise(mean_axis = mean(medianMajorAxis),
                           sd_axis = sd(medianMajorAxis))

# Density plot of mean_distance
ggplot(left_join(distance_df,ran_animals), aes(mean_dist, fill=Group)) +
  geom_vline(xintercept = mean_axis$mean_axis, lty=2)+
  geom_density(alpha=0.4, lwd=0.5) + scale_fill_brewer(palette = "Set2") 

ggplot(left_join(distance_df,ran_animals), aes(Group, mean_dist, fill=Group)) +
  geom_violin() + scale_fill_brewer(palette = "Set2") + 
  geom_boxplot(fill='black', width=0.1, color = "white", lwd=1.2)


# Close-Far: Binary position summary ####

binary_pos_summary <- distance_df %>%
                      group_by(RatID) %>%
                      summarise_at(.vars = c("blue_close", "green_close", "red_close"),
                                   .funs = function(x) sum(x=="close")/length(x)) %>%
                      mutate(mean_close = rowMeans(data.frame(blue_close, green_close, red_close))) %>%
                      left_join(ran_animals)


# Plot fraction of time close to pups

close_fraction_plot <-  ggplot(binary_pos_summary,
                         aes(Group, mean_close, color=Group)) +
                    stat_summary(fun.y = median, fun.ymin = median,
                                 fun.ymax = median, geom = "crossbar",
                                 color = "gray50", size = 0.5, width=0.5) +
                    geom_point(size=2, alpha=0.8) + 
                    geom_point(shape=1, size=2, color='black')+
                    scale_color_manual(values=c('white', 'black')) + 
                    xlab('') + ylab('Fraction of test in proximity to pups') +
                    theme(text = element_text(size=20)) +
                    theme(legend.position = 'none')+
                    theme(axis.line.x = element_line(color="black", size = 1))



# t-tests
t.test(mean_close ~ Group, data=binary_pos_summary)
wilcox.test(mean_close ~ Group, data=binary_pos_summary)

# Levene-test
car::leveneTest(binary_pos_summary$mean_close, binary_pos_summary$Group)



# Calculate full XY position into a df 
# we don't need to plot it (custom_2d_hist is meant to plot)

XY_df <- custom_2d_hist(xy_pos)

XY_df <- XY_df %>%  group_by(animal) %>%
  mutate(diff_x = c(0, diff(X)),
         diff_y=c(0, diff(Y)),
         Step= sqrt(diff_x^2 + diff_y^2),
         total_track=cumsum(Step))

ggplot(XY_df, aes(frameID, total_track, color=animal)) +
  geom_point() +
  facet_wrap(~RatID) +
  theme(legend.position = 'none')

# Select only mothers

total_dist <- XY_df %>%
  filter(RatID==animal) %>%
  group_by(RatID) %>%
  select(RatID, animal, total_track, Step, total_track) %>%
  summarise(integrated_path = sum(total_track), 
            mean_Step = mean(Step))

# If in need to plot traces for each animal
# custom_2d_hist(xy_pos, TRUE)

# Calculate if the time pups are in the same quadrant ####

# This is a list, first element has quadrant vs frameID
# Second element has whether together/separate vs frameID

same_quadrant <- count_quadrant(XY_df)

# Take the second element and do further summary
quadrant_df <- same_quadrant[[2]] %>%
                group_by(RatID) %>%
                mutate(n_frames = length(together),
                       are_separated = together=="separated") %>%
                summarise(together_percent = 1 - (sum(are_separated)/unique(n_frames))) %>%
                left_join(ran_animals)


# Plot the fraction of the test pups are grouped

together_fraction_plot <-  ggplot(quadrant_df,
                               aes(Group, together_percent, color=Group)) +
  stat_summary(fun.y = median, fun.ymin = median,
               fun.ymax = median, geom = "crossbar",
               color = "gray50", size = 0.5, width=0.5) +
  geom_point(size=2, alpha=0.8) + 
  geom_point(shape=1, size=2, color='black')+
  scale_color_manual(values=c('white', 'black')) + 
  xlab('') + ylab('Fraction of test pups are grouped') +
  theme(text = element_text(size=20)) +
  theme(legend.position = 'none')+
  theme(axis.line.x = element_line(color="black", size = 1))


# parametric test gives difference, non-parametric is almost significant
t.test(together_percent ~ Group, data=quadrant_df)
wilcox.test(together_percent ~ Group, data=quadrant_df)

# This is significant but by very little
car::leveneTest(quadrant_df$together_percent, quadrant_df$Group)

### PUP-PUP DISTANCE OLD -- SKIP ALL BELOW #####

# Calculate distance between pups (pup to pup distance)
# We take the blue pup as reference
# This is old, partially wrong (pup distance is not doing perimeter) and slow.
# Commented and kept for record keeping. 
# If you want to run, read carefully

# between_pup_dist <- function(mydata){
#   
#   data_to_dist <- lapply(mydata, function(t) t[,1:2])
#   
#   
#   # Here data_to_dist[[2]] means blue pup as reference!
#   pup_dist <- lapply(data_to_dist[3:4],
#                          function(q) pair_xy_dist(data_to_dist[[2]], q))
#   
#   pup_dist <- bind_cols(pup_dist)
#   pup_dist <- pup_dist %>% mutate(frameID = 1:nrow(pup_dist))
#   
#   return(pup_dist)
#   
# }
# 
# between_pup <- lapply(xy_pos, function(qq) between_pup_dist(qq))
# 
# # Fix the names
# 
# for(i in 1:length(between_pup)){
#   fix_these_names<-names(between_pup[[i]])
#   names(between_pup[[i]]) <- fix_pup_names(fix_these_names)
# }
# 
# # Plot distance vs frame 
# 
# between_pup %>% bind_rows(.id="RatID") %>%
#   group_by(RatID, frameID) %>% mutate(between_pup_dist = green_pup + red_pup) %>%
#   select(RatID, frameID, between_pup_dist) %>%
#   left_join(distance_df) %>%
#   left_join(ran_animals) %>%
#   ggplot(aes(frameID, total_dist, color=Group))+
#   geom_line() +
#   geom_line(aes(frameID, between_pup_dist), color='black', lty=2) + facet_wrap(~RatID)
#   
# ggplot(distance_df, aes(frameID, mean_dist))+
#   geom_line() + facet_wrap(~RatID)
# 
# ## Difference in pup distance from first to last frame
# 
# first_to_last <- between_pup %>% bind_rows(.id="RatID") %>%
#   group_by(RatID, frameID) %>% mutate(between_pup_dist = green_pup + red_pup) %>%
#   filter(frameID %in% c(1, 9001)) %>%
#   ungroup() %>% group_by(RatID) %>%
#   summarise(diff_dist = diff(between_pup_dist)) %>%
#   left_join(ran_animals)


# # Plot the change in pup-pup distance
# 
# pup_pup_plot <-  ggplot(first_to_last,
#                                aes(Group, diff_dist, color=Group)) +
#   stat_summary(fun.y = median, fun.ymin = median,
#                fun.ymax = median, geom = "crossbar",
#                color = "gray50", size = 0.5, width=0.5) +
#   geom_point(size=2, alpha=0.8) + 
#   geom_point(shape=1, size=2, color='black')+
#   scale_color_manual(values=c('white', 'black')) + 
#   xlab('') + ylab('Total Change in pup-pup distance') +
#   theme(text = element_text(size=20)) +
#   theme(legend.position = 'none')+
#   geom_hline(yintercept=0, lty=2)+
#   theme(axis.line.x = element_line(color="black", size = 1))
# 
# 
# t.test(diff_dist~Group, data=first_to_last)
# 
# # SD112 was particularly not responsive to pups (even when tested twice)
# # p value makes more sense here
# t.test(diff_dist~Group, data=filter(first_to_last, RatID!="SD112"))


### Pup-pup distance as coded above is wrong!
### Having the blue pup fixed is problematic, 
### we are not calculating the perimeter of the triangle, just 2 sides!


### Perimeter and Area calculations #####

library(pracma)

xy_perimeter <- function(x, y) {
  
  # We assume numeric. 
  # (we could also check, likely going to increase time for nothing)
  
  # We Check for length
  lx <- length(x) ; ly <- length(y)
  if(lx!=ly) stop("x and y vectors must have same length")
  
  
  # Check if it's closed 
  # >> this is a nasty way of checking if hull is closed!
  
  x1 <- x[1] ; xend <- x[lx]
  y1 <- y[1] ; yend <- y[ly]
  
  if (x1 - xend == 0 & y1 - yend == 0) { 
    # meaning it's closed
    d <- sqrt((x[1:(lx - 1)] - x[2:lx]) ^ 2 + (y[1:(lx - 1)] - y[2:lx]) ^ 2)
    
  } else{
    
    # close it
    new_length <- lx + 1
    x[new_length] <- x1 ; y[new_length] <- y1
    
    # Calculate distance
    
    d <- sqrt((x[1:(new_length - 1)] - x[2:new_length]) ^ 2 +
                (y[1:(new_length - 1)] - y[2:new_length]) ^ 2)
  }
  
  # Calculate perimeter of closed polygon
  sum(d)
  
}


## THIS PLOT CAN BE INTERESTING!
XY_df %>%
  filter(animal!=RatID, frameID %in% c(1, 9001)) %>% 
  left_join(ran_animals) %>% 
  ggplot(aes(X,Y, color = Group, Group=RatID)) +
  geom_point() +
  geom_polygon(fill=NA) +
  facet_wrap(Group~frameID)+
  geom_vline(xintercept = c(0,640)) +
  geom_hline(yintercept = c(0,480)) +
  theme_void()


### Paired perimeter and area plots #####

paired_perimeter <- XY_df %>%
  filter(animal!=RatID, frameID %in% c(1, 9001)) %>%
  group_by(RatID, frameID) %>%
  summarise(area = abs(polyarea(X,Y)), 
            perimeter = xy_perimeter(X,Y)) %>%
  left_join(ran_animals) %>%
  ggplot(aes(factor(frameID), perimeter, color=Group, group=RatID)) +
  geom_line(lwd=0.75) +
  geom_point() +
  geom_point(shape=1, size=2, color='black')+
  facet_wrap(~Group) +
  scale_color_manual(values=c('white', 'black'))+
  theme(legend.position = 'none')


paired_area <- XY_df %>%
  filter(animal!=RatID, frameID %in% c(1, 9001)) %>%
  group_by(RatID, frameID) %>%
  summarise(area = abs(polyarea(X,Y)), 
            perimeter = xy_perimeter(X,Y)) %>%
  left_join(ran_animals) %>%
  ggplot(aes(factor(frameID), area, color=Group, group=RatID)) +
  geom_line(lwd=0.75) +
  geom_point() +
  geom_point(shape=1, size=2, color='black')+
  facet_wrap(~Group) +
  scale_color_manual(values=c('white', 'black'))+
  theme(legend.position = 'none')

### Get the pup_triangle data frame for further plotting

pup_triangle <- XY_df %>%
  filter(animal!=RatID, frameID %in% c(1, 9001)) %>%
  group_by(RatID, frameID) %>%
  summarise(area = abs(polyarea(X,Y)), 
            perimeter = xy_perimeter(X,Y)) %>%
  ungroup() %>% group_by(RatID) %>%
  summarise(diff_area = diff(area),
            diff_perim = diff(perimeter)) %>%
  left_join(ran_animals)

perimeter_difference_plot <- ggplot(pup_triangle, aes(Group, diff_perim, color=Group)) +
                             geom_point() +
    stat_summary(fun.y = median, fun.ymin = median,
                 fun.ymax = median, geom = "crossbar",
                 color = "gray50", size = 0.5, width=0.5) +
    geom_point(size=2, alpha=0.8) +
    geom_point(shape=1, size=2, color='black')+
    scale_color_manual(values=c('white', 'black')) +
    xlab('') + ylab('Total Change in pup-pup distance') +
    theme(text = element_text(size=20)) +
    theme(legend.position = 'none')+
    geom_hline(yintercept=0, lty=2)+
    theme(axis.line.x = element_line(color="black", size = 1))


area_difference_plot <- ggplot(pup_triangle, aes(Group, diff_area, color=Group)) +
                        geom_point() +
                        stat_summary(fun.y = median, fun.ymin = median,
                                     fun.ymax = median, geom = "crossbar",
                                     color = "gray50", size = 0.5, width=0.5) +
                        geom_point(size=2, alpha=0.8) +
                        geom_point(shape=1, size=2, color='black')+
                        scale_color_manual(values=c('white', 'black')) +
                        xlab('') + ylab('Total Change in area') +
                        theme(text = element_text(size=20)) +
                        theme(legend.position = 'none')+
                        geom_hline(yintercept=0, lty=2)+
                        theme(axis.line.x = element_line(color="black", size = 1))


t.test(diff_perim~Group, data=pup_triangle)
wilcox.test(diff_perim~Group, data=pup_triangle)

t.test(diff_area~Group, data=pup_triangle)
wilcox.test(diff_area~Group, data=pup_triangle)


### We can think about it in a repeated measures set-up
### Let's do some lineplots
### Selecting 9 time points in the test


all_frames <- XY_df %>%
  filter(animal!=RatID) %>%
  group_by(RatID, frameID) %>%
  summarise(area = abs(polyarea(X,Y)), 
            perimeter = xy_perimeter(X,Y))

### Perimeter vs frameID line plot ####


sem <- function(x){
  n <- length(x)
  
  out <- sd(x)/sqrt(n)
}

perimeter_large_plot <- ggplot(filter(left_join(all_frames,ran_animals),
              frameID %in% seq(1,9001,1000)),
       aes(frameID, perimeter, color= Group, fill=Group)) +
    stat_summary(fun.y = mean,
               fun.ymin = function(x) mean(x) - sem(x),
               fun.ymax = function(x) mean(x) + sem(x),
               geom = "ribbon", alpha=0.1, color=NA) + 
  stat_summary(fun.y = mean, geom='line', lwd=1.2) +
  stat_summary(fun.y = mean, geom='point', size=3)+
  scale_color_manual(values=c('white', 'black'))+
  scale_fill_manual(values=c('gray20', 'gray20'))+
  theme(legend.position = 'none')


## Area vs frameID line plot ##### 

area_large_plot <- ggplot(filter(left_join(all_frames,ran_animals),
              frameID %in% seq(1,9001,1000)),
       aes(frameID, area, color= Group, fill=Group)) +
  stat_summary(fun.y = mean,
               fun.ymin = function(x) mean(x) - sem(x),
               fun.ymax = function(x) mean(x) + sem(x),
               geom = "ribbon", alpha=0.1, color=NA) + 
  stat_summary(fun.y = mean, geom='line', lwd=1.2) +
  stat_summary(fun.y = mean, geom='point', size=3)+
  scale_color_manual(values=c('white', 'black'))+
  scale_fill_manual(values=c('gray20', 'gray20'))+
  theme(legend.position = 'none')
  

#### Animate changes ---- Not very clear ####

# library(gganimate)
# library(magick)
# 
# data_to_animate <- filter(left_join(all_frames,ran_animals),
#                           frameID %in% seq(1,9001,1000))
# 
# frame_list <- split(data_to_animate, data_to_animate$frameID) 
# 
# img <- image_graph(res = 96)
# 
# out <- lapply(frame_list, function(data){
# animated_plot <- ggplot(data,
#                  aes(area, perimeter, color= Group)) +
#                 geom_point() + ggtitle(data$frameID) +
#                 scale_x_continuous(limits=range(data_to_animate$area))+
#                 scale_y_continuous(limits=range(data_to_animate$perimeter))
# print(animated_plot)
# })
# dev.off()
# animation <- image_animate(img, fps = 2)
# image_write(animation, "animation.gif")


## Show a facet version of the development  

data_to_animate <- filter(left_join(all_frames,ran_animals),
                          frameID %in% seq(1,9001,1000))

data_two <- filter(left_join(all_frames,ran_animals),
                   frameID %in% c(1,9001)) %>%
                   ungroup()

# Transform frameID into factor
data_two$frameID <- factor(data_two$frameID)
# Make an interaction that we will use for the model later
data_two$interaction <- interaction(data_two$Group, data_two$frameID)


### Do some stats


library(nlme)

model = lme(perimeter ~ frameID + Group + frameID*Group, 
            random = ~1|RatID,
            correlation = corAR1(form = ~ frameID | RatID),
            data=data_to_animate,
            method="REML")

library(car)

Anova(model)


library(multcompView)

library(lsmeans)

marginal = lsmeans(model, 
                   ~ Group:frameID)

cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey")     ###  Tukey-adjusted comparisons


model2 = lme(perimeter ~ frameID + Group + frameID*Group, 
            random = ~1|RatID,
            data=data_two,
            method="REML")


# Also check this lmer 



model2 <- lme4::lmer(perimeter ~ interaction + (1|RatID), data=data_two)


marginal <- glht(model2, linfct=mcp(interaction = "Tukey"))

cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey")     ###  Tukey-adjusted comparisons


# This plot has all the data and animates by frame
# Might be confusing/hard to read

ggplot(data_to_animate, aes(sqrt(area), perimeter, fill=Group)) +
  geom_point(data=select(data_to_animate,-frameID), alpha=0.5) +
  geom_point(aes(color=Group)) +
  facet_wrap(~frameID)+
  theme_bw() 

# Same as above but with a cubic trendline
# ggplot(data_to_animate, aes(area, perimeter, fill=Group, group=Group)) +
#      geom_point(data=select(data_to_animate,-frameID), alpha=0.5) +
#      geom_point(aes(color=Group)) +
#      facet_wrap(~frameID)+
#      theme_bw() + 
#      geom_smooth(method="lm", se=TRUE, fill=NA,
#                  formula=y ~ poly(x, 3, raw=TRUE), aes(color=Group))

# This plot is more clear...still difficult to read

ggplot(data_to_animate, aes(sqrt(area), perimeter, fill=Group, group=Group)) +
#  geom_point(data=select(data_to_animate,-frameID), alpha=0.5) +
  geom_point(aes(color=Group)) +
  facet_wrap(~frameID)+
  theme_dark() + 
#  geom_rug(aes(color=Group), size=1)+ 
  scale_color_manual(values=c('white', 'gray10'))


# With density plots on the side...
# Quite a lot of overlap... not very useful

# p <- ggplot(filter(data_to_animate, frameID==9001),
#        aes(sqrt(area), perimeter, fill=Group, group=Group)) +
#   geom_point(aes(color=Group)) +
#   theme_dark() + 
#   scale_color_manual(values=c('white', 'gray10'))+
#   geom_rug(aes(color=Group), size=1) +
#   scale_x_continuous(limits=range(sqrt(data_to_animate$area)))+
#   scale_y_continuous(limits=range(data_to_animate$perimeter)) +
#   theme(legend.position = "bottom")
# 
# 
# ggExtra::ggMarginal(p, groupFill =  TRUE)

### 2d_histogram_plots 

# Biased search for 2 examples
custom_2d_hist(xy_pos, plotMe= FALSE, rat_names = c('SD74O2Q3', 'SDWK23')) %>%
  filter(animal==RatID) %>%
  ggplot(aes(X,Y)) +
  stat_density2d(geom="raster",
                 aes(alpha=..density..),
                 contour = FALSE,
                 n = c(640/40, 480/40)) +
  #geom_point(aes(color=animal), alpha=0.4) + 
  geom_path(color='yellow', alpha=0.5) +
  scale_y_reverse() +
  coord_equal() +
  theme_void() +
  #    scale_fill_gradientn(colors =  mycol) +
  # scale_fill_manual(values =  c("gray50", "#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
  scale_alpha_continuous(limits=c(0,0.6e-5), breaks=1e-6*seq(0,10,by=2))+
  geom_vline(xintercept = c(0,640)) +
  geom_hline(yintercept = c(0,480)) + facet_wrap(~animal)



data_to_heatmap <- custom_2d_hist(xy_pos, plotMe= FALSE, rat_names = c('SD74O2Q3', 'SDWK23')) %>%
  filter(animal==RatID)
  

suppressPackageStartupMessages(library(KernSmooth))


bins_1 <- bkde2D(as.matrix(filter(data_to_heatmap, RatID=="SDWK23") %>% ungroup() %>% select(X,Y)),
                 bandwidth = c(640/20, 480/20),
               gridsize = c(640L, 480L))

bins_2 <- bkde2D(as.matrix(filter(data_to_heatmap, RatID=="SD74O2Q3") %>% ungroup() %>% select(X,Y)),
                 bandwidth = c(640/20, 480/20),
                 gridsize = c(640L, 480L))

rat_1 <- reshape2::melt(bins_1$fhat)
rat_1$RatID <- 'SDWK23'

rat_2 <- reshape2::melt(bins_2$fhat)
rat_2$RatID <- 'SD74O2Q3'

bins_to_plot <- bind_rows(rat_1, rat_2)

library(RColorBrewer)
refCol <- colorRampPalette(rev(brewer.pal(6,'Spectral')))
mycol <- refCol(6)

my_density_plot <- ggplot(bins_to_plot, aes(Var1, Var2, fill = value)) +
                    geom_raster()+
                    coord_equal() +
                    theme_minimal() +
                    scale_fill_gradientn(colors =  mycol) +
                    geom_vline(xintercept = c(0,640))+
                    geom_hline(yintercept = c(0,480))+
                    scale_y_reverse() + 
                    facet_wrap(~RatID)+
                    theme_void() + theme(legend.position = 'none')

#### Cowplot all together #####



first_row <- cowplot::plot_grid(my_density_plot, labels = "B")
second_row <- cowplot::plot_grid(close_fraction_plot,
                                 together_fraction_plot,
                                 labels= c("C", "D"), axis='B' , align='h', 
                        nrow=1)

third_row <- cowplot::plot_grid(area_large_plot,
                                paired_area,
                                area_difference_plot,
                                labels= c("E", "F", "G"), axis='B' , align='h', 
                                nrow=1,
                                rel_widths = c(2,2,1))
fourth_row <- cowplot::plot_grid(perimeter_large_plot,
                                 paired_perimeter,
                                 perimeter_difference_plot,
                                 labels=c("H", "I", "J"), axis="B", align = "h",
                                 nrow=1,
                                 rel_widths = c(2,2,1))


cowplot::plot_grid(third_row, fourth_row, ncol=1)

