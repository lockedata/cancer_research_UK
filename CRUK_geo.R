library(ggplot2)
library(rgdal)   # This package runs readOGR
library(broom)   # This package runs tidy()
library(dplyr)   # Needed to run grepl, even thought that is in base r, also needed for left_join
library(openxlsx)  # this one is needed to open the excel file

library(maps)
library(mapdata)
library(tmap)

#library(tidyr)
#library(devtools)
#library(stringr)

# http://geoportal.statistics.gov.uk/datasets/clinical-commissioning-groups-april-2017-super-generalised-clipped-boundaries-in-england-v4
# The kml file is there and the worksheet used in the script is the ‘spreadsheet’ at that link with fake quintiles 1,2,3,4,5, entered by hand in an extra column.

# ===========================================================================
# PART 2:  Set Directories, upload files and prepare the data
# ===========================================================================

# Note, code below specifies 'ccg17cd'. This will need to be updated if another source is used.

## I have made a change here - if you download the github repo you will be able to open "CRUK_geo.proj" 
## which will save time with setting paths throughout the document as it is all referenced in one place 
## and is generally good practise as it makes your code immediately reproductible from any machine.

# Set directory
#setwd("G:\\R mapping\\")

# Using the full stop here makes your code more readable - it essentially means "use the working directory" but there are variations :)
ccgsgcl <- readOGR("./Clinical_Commissioning_Groups_April_2017_Super_Generalised_Clipped_Boundaries_in_England_V4/Clinical_Commissioning_Groups_April_2017_Super_Generalised_Clipped_Boundaries_in_England_V4.shp")
# this just has two empty seeming columns, but it works for maps to evidently all the coordinates are tucked in one cell

ccgsgcl@data$quintile <-  sample(5, size = nrow(ccgsgcl@data), replace = TRUE) # this generates the same column you were doing by hand

#ccgsgcl_df <- as.data.frame(ccgsgcl) **you don't need to do this - you can access shapefile data using the @ symbol**


#Now pull out the CCG codes from the same KLM file and bolt it onto the mapping file, ccgsgcl. Then the data can be looked up.

#This reads the KLM file as one column of data, each line is a new row
#ccgCodes <- readLines("./Clinical_Commissioning_Groups_April_2017_Super_Generalised_Clipped_Boundaries_in_England_V4/Clinical_Commissioning_Groups_April_2017_Super_Generalised_Clipped_Boundaries_in_England_V4.kml")

# This converts the whole thing into a single column of data with several rows for the overall text and then about 10 rows per CCG
#ccgCodes <- as.data.frame(ccgCodes)
# Cut away the extranous text
#ccgCodes$ccgCodes <- gsub("<SimpleData name=\"ccg17cd\">", "", ccgCodes$ccgCodes)
#ccgCodes$ccgCodes <- gsub("</SimpleData>", "", ccgCodes$ccgCodes)
#ccgCodes$ccgCodes <- as.character(ccgCodes$ccgCodes)

# We know that all ccg codes begin with E so we can use regular expression to say 'only keep rows beginning with E followed by a number'
#ccgCodes %>%  filter(grep(pattern = "^E[0-9]", x = ccgCodes, value = TRUE)) -> ccg

## Am I right in thinking that this generates the same data as ccgsgcl@data$ccg17cd ? 

# Now bolt the list of ccg codes onto the shapefiles
# TODO to do. Assume this is reliable enough??

#ccgmapdata <- bind_cols(ccgsgcl_df, ccgCodes) - You also shouldn't need to do this as you can access it using @data$ccg17cd

# NOW I can vlookup, i.e. merge, the values I want to map with in a more reliable way.

# ccgtotaldata <- left_join(ccgmapdata, mapcolourdata, by = "ccg17cd") ## I can't see where you are generating `mapcolourdata`

#To DO todo. NOt working yet but just shove it together for now, as data is fake anyway.

# ccgtotaldatawrong <- bind_cols(ccgmapdata, mapcolourdata)

#What if I tidy the joined up data?
# ccg2 <-tidy(ccgtotaldatawrong)

# ===========================================================================
# PART 2:  Create the maps
# ===========================================================================

CRUK_map <- tm_shape(ccgsgcl) +
  tm_polygons(col="quintile", style='fixed', breaks = c(1,2,3,4,5,6), n =5, border.col = "grey50",  border.alpha = 0.1, title="Cancer Research UK ", showNA=FALSE)

CRUK_map

ccgmap <- ggplot(data = ccgsgcl) +
  geom_polygon(aes(x = long, y = lat, fill = ), color = "black") +
  coord_fixed(1.7)+
  guides(fill=FALSE)  # do this to leave off the color legend, which will be huge with 207 CCGs
ccgmap
