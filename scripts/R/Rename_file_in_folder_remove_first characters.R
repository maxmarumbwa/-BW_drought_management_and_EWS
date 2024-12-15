
#Rename file - remove the autonumber and # "30_Soilm1mDavgP_smap_201807"

#folder_path <- here("data", "input", "Remote sensing","Extracted_multiband","Soilm1mDavgP_smap","torename")
folder_path <- "C:/data/"

# List all files in the folder
files <- list.files(folder_path, full.names = TRUE)

# Loop through each file, rename it by removing the first underscore and anything preceding it
for (file in files) {
  # Extract the file name from the full path
  file_name <- basename(file)
  
  # Remove the first underscore and anything preceding it
  new_file_name <- sub("^[^_]*_", "", file_name)
  
  # Construct the full path for the new file name
  new_file_path <- file.path(folder_path, new_file_name)
  
  # Rename the file
  file.rename(file, new_file_path)
}

# Print a confirmation message
cat("Files have been renamed successfully.\n")
