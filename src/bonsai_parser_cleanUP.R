# The purpose of this function is to be able to track what .bonsai file produced what raw_data
# The raw_files are then copied into one folder 'data/RatID'
# We use the timestamps on the bonsai file to link everything together

library(XML)
library(xml2)

# Get the animal list

animal_list <- read.csv('MLA_Animal_Video_Key.csv', stringsAsFactors = F)


# Get the file list
file_list <- list.files(path='./raw_data', pattern = '.bonsai$', full.names = T)

# Timestamp format is yyyy-mm-ddThh-mm-ss  
# We use that timestamp to match them with the RatID 
file_timestamp <- stringr::str_extract(file_list, '[0-9]+-[0-9]+-[0-9]+T.+[0-9]')

bonsai_to_df <- function(bonsai_filepath){

  aa <- read_xml(bonsai_filepath)
  
  xml <- xmlParse(aa, useInternalNodes = TRUE)
  xL <- xmlToList(xml)
  
  my_df <- data.frame(nodeList = t(data.frame(t(xL$Workflow$Nodes))))
  
  my_df <- data.frame(my_df, Expression = row.names(my_df))
  
 return(my_df)   
}

# 
bonsai_dfList <- lapply(file_list, bonsai_to_df)

# Find the .avi inputs by timestamp
raw_video <- stringr::str_extract(bonsai_dfList, '[0-9]+-[0-9]+-[0-9]+T.+[0-9].avi')

# Remove the .avi extension
raw_video <- gsub('.avi', '', raw_video)

# paste 'raw_video' to all of them

raw_video <- paste0('Raw_video', raw_video)

# Match with the ratIDs 

RatID <- animal_list$RatID[animal_list$raw_video %in% raw_video]

# Files to match with file_timestamp

files_to_match <- list.files(path = './raw_data/raw_data', full.names = T)

# Get the .csv files that match with the file_timestamp of the .bonsai files
files_to_copy <- lapply(file_timestamp, files_to_match, FUN=grep)

# Move from raw_data to ./data/RatID from list elements

Rat_directories <- file.path('data', RatID)

my.file.copy <- function(from, to) {
  
  todir <- file.path(to)
  if (!isTRUE(file.info(todir)$isdir)) dir.create(todir, recursive=TRUE)
  file.copy(from = from,  to = to, overwrite = FALSE)
}


# Copy all files
# It is imperative that the order of the RatID column and the Raw_video column matches
# To make sure this is the case, enter rats in the order they were ran into the key .csv file

for (i in 1:length(files_to_copy)){
  
  copy_these <- files_to_match[files_to_copy[[i]]]
  
  my.file.copy(copy_these, Rat_directories[[i]])
  
  
}


