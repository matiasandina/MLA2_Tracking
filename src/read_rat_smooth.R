# This function reads the smooth positions into R


read_rat_smooth <- function(RatID){
  
  filedir <- file.path('data', RatID)
  
  file_list <- list.files(path = filedir, pattern = "smooth", full.names = T)
  
  li <- lapply(file_list, function(x) read.csv(x, stringsAsFactors = F))
  
  names_for_list <- str_extract(file_list, "SD.+smooth")

  names_for_list <- str_split(str_extract(file_list, "SD.+smooth"), pattern = '/', simplify = T)[,2]
    
  names_for_list <- gsub(pattern = "_smooth", replacement = "", names_for_list)  
  
  names(li) <- names_for_list
  return(li)  
}
