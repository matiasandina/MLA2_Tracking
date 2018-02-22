# This function aims to read data from Bonsai
# Be aware that it will work only if the csvWriter is
# >>savename pattern: tag_centroid_timestamp
# >>Header = TRUE


library(readr)
library(stringr)
library(dplyr)

read_centroids <- function(){

li <- list.files(path = 'data', full.names = T, pattern = "centroid")  

li_full_path <- file.path(getwd(), li)

# Throws warnings about number of columns not being a multiple...
# Still works like charm

list_of_files <- lapply(li_full_path, function(q) read_delim(q,
                                                   " ",
                                                   escape_double = FALSE,
                                                   trim_ws = TRUE))   

# Get the channels 
channel_names <- str_extract(li, "[a-z]+_")
channel_names <- gsub("_", "", channel_names)

# Change the names of the list to the channels from source
names(list_of_files) <- channel_names

# Bind into a single data.frame
out <- bind_rows(list_of_files, .id='source')

# It is easier if we keep everything into lower case
names(out) <- tolower(names(out))
  
return(out)

}

