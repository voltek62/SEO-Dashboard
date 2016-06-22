 #autoinstall packages
packages <- c("readxl", "dplyr", "stringi", "stringr", "urltools")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}

library(readxl)
library(dplyr)
library(stringi)
library(stringr)

#conf
siteconf <- "./websites/dataseo/segments.csv"
pathxlsx <- "./websites/dataseo/internal_html.xlsx"

## use xlsx format to prevent read errors with csv and xls
print("open xlsx....")

if (!exists("urls")) {
  ptm <- proc.time()
  urls <-  read_excel(pathxlsx, 
                      sheet = 1, 
                      col_names = TRUE, 
                      na = "",
                      skip=1)
  
  # last line is always NA
  urls <- head(urls,-1)
  
  # crawler generate NA columns
  urls <- urls[colSums(!is.na(urls)) > 0]  
  
  print("urls")
  print(proc.time() - ptm)
  
  sitename <- domain(urls[1,]$Address)
}

print("urls loaded")
print("-------------------")

###############################################################

ptm <- proc.time()

print("classify urls ")

schemas <- read.csv(siteconf,
                    header = FALSE,
                    col.names = "schema",
                    stringsAsFactors = FALSE
)

schemas <- as.character(schemas[,1])


urls$Category <- "no match"
  
for (j in 1:length(schemas))
{
   #print(schemas[j])
   urls$Category[which(stri_detect_fixed(urls$Address,schemas[j],case_insensitive=TRUE))] <- schemas[j]
}

# Detect HomePage
urls$`Category`[1] <- 'Home'

urls$Category <- as.factor(urls$Category)

print("urls classified")
print("-------------------")
print(proc.time() - ptm)

##########################################################################

# Compliant Pages
# Canonical Not Equal
# Meta No-index
# Bad HTTP Status Code
# Not Equal

urls$Compliant <- TRUE

urls$Compliant[which(urls$`Status Code` != 200
                            | urls$`Canonical Link Element 1` != urls$Address
                            | urls$Status != "OK"
                            | grepl("noindex",urls$`Meta Robots 1`)
                            )] <- FALSE

urls$Compliant <- as.factor(urls$Compliant)

print("Compliant OK")

# Classify by inlinks
urls$`Group Inlinks` <- "URLs with No Follow Inlinks" 

urls$`Group Inlinks`[which(urls$`Inlinks` < 1  )] <- "URLs with No Follow Inlinks"
urls$`Group Inlinks`[which(urls$`Inlinks` == 1 )] <- "URLs with 1 Follow Inlink"
urls$`Group Inlinks`[which(urls$`Inlinks` > 1 & urls$`Inlinks` < 6)] <- "URLs with  2 to 5 Follow Inlinks"
urls$`Group Inlinks`[which(urls$`Inlinks` >= 6 & urls$`Inlinks` < 11 )] <- "URLs with 5 to 10 Follow Inlinks"
urls$`Group Inlinks`[which(urls$`Inlinks` >= 11)] <- "URLs with more than 10 Follow Inlinks"

urls$`Group Inlinks` <- as.factor(urls$`Group Inlinks`)

print("Group Inlinks OK")

# Classify Speed
urls$Speed <- NA

urls$Speed[which(urls$`Response Time` < 0.501  )] <- "Fast"
urls$Speed[which(urls$`Response Time` >= 0.501 & urls$`Response Time` < 1.001)] <- "Medium"
urls$Speed[which(urls$`Response Time` >= 1.001 & urls$`Response Time` < 2.001)] <- "Slow"
urls$Speed[which(urls$`Response Time` >= 2.001)] <- "Slowest"

urls$Speed <- as.factor(urls$Speed)

print("Speed OK")

# Detect Active Pages
urls$Active <- FALSE
urls$`GA Sessions`[is.na(urls$`GA Sessions`)] <- "0"
urls$`GA Sessions` <- as.numeric(urls$`GA Sessions`)
urls$Active[which(urls$`GA Sessions` > 0)] <- TRUE

urls$Active <- as.factor(urls$Active)

print("Active OK")

# Detect DupliCategorye Meta
urls$`Status Title` <- 'Unique'
urls$`Status Title`[which(urls$`Title 1 Length` == 0)] <- "No Set"

urls$`Status Description` <- 'Unique'
urls$`Status Description`[which(urls$`Meta Description 1 Length` == 0)] <- "No Set"

urls$`Status H1` <- 'Unique'
urls$`Status H1`[which(urls$`H1-1 Length` == 0)] <- "No Set"

urls$`Status Title`[which(duplicated(urls$`Title 1`))] <- 'Duplicate'
urls$`Status Description`[which(duplicated(urls$`Meta Description 1`))] <- 'Duplicate'
urls$`Status H1`[which(duplicated(urls$`H1-1`))] <- 'Duplicate'

urls$`Status Title` <- as.factor(urls$`Status Title`)
urls$`Status Description` <- as.factor(urls$`Status Description`)
urls$`Status H1` <- as.factor(urls$`Status H1`)

print("DC OK")


urls$`Group WordCount` <- "0 - 150"
urls$`Group WordCount`[which(urls$`Word Count` >=150 & urls$`Word Count` < 250 )] <- "150 - 250"
urls$`Group WordCount`[which(urls$`Word Count` >= 250 & urls$`Word Count` < 500)] <- "250 - 500"
urls$`Group WordCount`[which(urls$`Word Count` >= 500 & urls$`Word Count` < 1000 )] <- "500 - 1000"
urls$`Group WordCount`[which(urls$`Word Count` >= 1000 & urls$`Word Count` < 3000)] <- "1000 - 3000"
urls$`Group WordCount`[which(urls$`Word Count` >= 3000 )] <- "3000 +"

urls$`Group WordCount` <- as.factor(urls$`Group WordCount`)

print("Group WordCount OK")

urls$`Group Visits` <- "0 visit"
urls$`Group Visits`[which(urls$`GA Sessions`==1)] <- "1 visit"
urls$`Group Visits`[which(urls$`GA Sessions`>1)] <- "2 to 10 visits"
urls$`Group Visits`[which(urls$`GA Sessions`>10)] <- "11 to 100 visits"
urls$`Group Visits`[which(urls$`GA Sessions`>100)] <- "100+ visit"

urls$`Group Visits` <- as.factor(urls$`Group Visits`)

print("Group Visits OK")

#Numeric
urls$`Status Code` <- as.factor(as.character(urls$`Status Code`))

# Stop the clock
print(proc.time() - ptm)

print("-------------------")

#####################################################################

#Generate CSV

print("Generate CSV")

# prepare csv for elasticsearch
# TODO : add response_time : double
urls_csv <- select(urls, Address,Category,Active,Speed,Compliant,Level,
                         Inlinks,Outlinks,
                        `Status Title`,`Status Description`,`Status H1`,
                        `Group Inlinks`,`Group WordCount`) %>%
            mutate(Address=gsub(sitename,"",Address))

colnames(urls_csv) <- NULL
write.csv2(urls_csv,paste("filebeat-csv/crawled-urls-filebeat-",format(Sys.time(), "%Y%m%d"),".csv",sep=""), row.names = FALSE)
