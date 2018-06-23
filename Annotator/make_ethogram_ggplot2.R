
# Read df

df <- read.csv('filled_behavior_df.csv', stringsAsFactors = F)

# Modify the NAs coming from MATLAB

df <- dplyr::na_if(df, "") %>% mutate(behavior = ifelse(is.na(behavior),
                                                        "Not-specific",
                                                        behavior))




df <- df %>% mutate(fake_frame = rep(1:9001, length(unique(df$RatID))))


# Individual plot, no colors
ggplot(filter(df, RatID=="SD110"), aes(frameID, behavior)) + geom_tile() 


# load the key

key <- read.csv('C:\\Users\\Matias\\Desktop\\MLA2_Tracking\\src\\MLA_Animal_Video_Key.csv', stringsAsFactors=F)

# Join with the key
df <- left_join(df, key)

# calculate summary to order by retrieving or snif
sum_df <- df %>% filter(behavior %in% c("Retrieving", "Snif")) %>%
                 group_by(RatID, behavior) %>%
                 tally %>% 
                 spread(behavior, n, fill= 0)


# join and arrange by Retrieving and sniffing
# this arranges from more to less on the graph
# Notice they will be ascending on the table

df <- left_join(df, sum_df) %>% arrange(Retrieving, Snif)

## Do the graph

df2 <- df

# Modify the factor levels before entering the plot
df2$RatID <- factor(df2$RatID, levels=unique(df2$RatID))

#myfill <- c("red", "orange", "white", "green", "steelblue",
#            "gray10", "purple")


myfill <- brewer.pal(n = 7, "Set3")

# fix some colors with "Set3"
myfill[3] <- 'gray90'

nice_red <- myfill[4]
myfill[4] <- myfill[7]

myfill[7]<- nice_red

# Try daltonic version
# myfill <- dichromat(myfill)

ggplot(df2, aes(fake_frame, y = RatID ,
               fill=behavior)) +
  geom_tile() + 
  facet_wrap(~Group, nrow = 2, scales = "free")+
  ylab("")+
  xlab("Test time (frames)")+
#  theme_void()+
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=1))+
    scale_fill_manual(values=myfill)


#### The same graph but with less groups ######

maternal_behaviors <- c('Hover-over', 'Nesting', 'Retrieving')


# calculate summary to order by retrieving or snif
sum_df2 <- df %>% mutate(new_behavior = ifelse(behavior %in% maternal_behaviors,
                                              'Maternal', behavior)) %>%
  
  filter(new_behavior %in% c("Maternal", "Snif")) %>%
  group_by(RatID, new_behavior) %>%
  tally %>% 
  spread(new_behavior, n, fill= 0)


df3 <- left_join(df, sum_df2) %>% arrange(Maternal, Snif) %>%
       mutate(new_behavior = ifelse(behavior %in% maternal_behaviors,
                        'Maternal', behavior))

df3$RatID <- factor(df3$RatID, levels=unique(df3$RatID))


# option 1 for fill
myfill_2 <- brewer.pal(n = 7, "Set3")

# fix some colors with "Set3"
nice_red <- myfill_2[4]
myfill_2[1]<- nice_red
myfill_2[2] <- 'gray90'
myfill_2[3] <- "#009E73"
myfill_2[4] <- "#F0E442"


# option 2 for fill

library(dichromat)

myfill_2 <- colorschemes$Categorical.12

myfill_2[1] <- nice_red
myfill_2[2] <- 'gray80'
myfill_2[4] <- 'white'
myfill_2[5] <- myfill_2[7]

# try daltonic version
# myfill_2 <- dichromat(myfill_2)

# Make the plot

ggplot(df3, aes(fake_frame, y = RatID ,
                fill=new_behavior)) +
  geom_tile() + 
  facet_wrap(~Group, nrow = 2, scales = "free")+
  ylab("")+
  xlab("Test time (frames)")+
  theme_void()+
  theme(legend.position = "bottom")+
  guides(fill=guide_legend(nrow=1))+
  scale_fill_manual(values=myfill_2)


