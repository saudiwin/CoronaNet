library(tidyverse)
library(jsonlite)

ra <- read_csv("/Users/aiart/CoronaNetDataScience/corona_private/RCode/dataProcessing/contribution2.csv")
view(ra[,"Name"])

ra_json <- toJSON(ra[,"Name"], null="null", encoding="UTF-8")

con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/contribution.json",encoding="UTF-8")
write(ra_json, con)

