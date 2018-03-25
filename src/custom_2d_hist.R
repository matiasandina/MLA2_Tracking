# Custom 2D histogram

library(KernSmooth)
library(ggplot2)

custom_2d_hist <- function(xy_list, plotMe= FALSE, rat_names=NULL, bin_size=40, width=640, height=480){

  data1 <- lapply(xy_list, function(qq) bind_rows(qq, .id='animal'))
  
  data_subset <- lapply(data1, function(df) select(df, animal, X, Y))
  
  # Bind rows and add frame ID 
  data_bind <- bind_rows(data_subset, .id="RatID") %>%
               group_by(animal) %>%
               mutate(frameID = 1:n())


  # filter rats in rat_names

  if(is.null(rat_names)) rat_names <- unique(data_bind$RatID)
  
  data_bind <- filter(data_bind, RatID %in% rat_names)
  
if (plotMe==TRUE){
  
#  refCol <- colorRampPalette(rev(brewer.pal(6,'Spectral')))
#  mycol <- refCol(6)
  
  xbins <- width/bin_size
  ybins <- height/bin_size
  
  for(ii in unique(data_bind$RatID)){
    
    sprintf("Plotting rat", ii)    
    
    data_to_plot <- filter(data_bind, RatID %in% ii)
    
    # track_plot <- ggplot(data_to_plot, aes(X, Y)) +
    #   #stat_density2d(geom = 'tile', aes(fill = ..density..), contour = FALSE,
    #   #               n = c(xbins, ybins)) +
    #   geom_point(aes(color=animal), alpha=0.4) + 
    #   geom_path(alpha=0.1) +
    #   scale_y_reverse() +
    #   coord_equal() +
    #   theme_minimal() +
    #   scale_color_manual(values =  c("gray50", "#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
    #   geom_vline(xintercept = c(0,width))+
    #   geom_hline(yintercept = c(0,height)) + facet_wrap(~animal)
    # theme_void()
    # 
    # print(track_plot)
    
    
    density_plot <- ggplot(data_to_plot, aes(X, Y)) +
      stat_density2d(geom="raster", aes(fill= animal, alpha=..density..), contour = FALSE,
                     n = c(xbins, ybins)) +
      #geom_point(aes(color=animal), alpha=0.4) + 
      geom_path(alpha=0.1) +
      scale_y_reverse() +
      coord_equal() +
      theme_minimal() +
      #    scale_fill_gradientn(colors =  mycol) +
      scale_fill_manual(values =  c("gray50", "#1334C1","#84F619", "#F43900")) + # Order is Rat, blue, green, red
      scale_alpha_continuous(limits=c(0,0.6e-5), breaks=1e-6*seq(0,10,by=2))+
      geom_vline(xintercept = c(0,width))+
      geom_hline(yintercept = c(0,height)) #+ facet_wrap(~animal)
    
    plot(density_plot)
    
  }
  
  
}
    return(data_bind)
  
} 

