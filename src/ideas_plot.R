# Options for plotting the distance

# Assuming AA is
# AA <- pair_xy_dist(rat_pos[,1:2], pru_set)

# using threshold of 300 to mean "close"

# TODO: Add several 'channels' for all the distances that need to be calculated
# Try within the same plot or as facets

close_binary <- data.frame(frameID = 1:length(AA$val),
                           close=ifelse(AA$val<300, 1, 0))

ggplot(close_binary, aes(frameID, close)) +
  geom_area(alpha=0.5) +
  geom_point(size=1.2, alpha=0.3)+
  geom_line()+
  theme_minimal()


