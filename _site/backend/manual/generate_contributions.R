# The "Our People" table accepts data in JSON format
# This snippet generates a JSON from a CSV file
# Note that the encoding must be explicitly set to avoid odd font artifacts

library(readr)
library(tidyverse)
library(readxl)
library(jsonlite)

contribution <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/contribution.csv")
contribution <- contribution %>%
  select(-Country) %>%
  rename(Country = country) %>%
  select(Name, Vita, Country, "Start Date" = start)
contribution_old <- read_csv("../data/contribution_old.csv") %>%
  select(Name, Country, Vita, "Start Date")
old_ras <- contribution_old %>%
  filter(Name %in% setdiff(contribution_old$Name, contribution$Name))
contribution <- rbind(contribution, old_ras) %>%
  arrange(Name)
contribution[which(contribution$Name=="Aysina Maria"),"Country"] = "Greece"
contribution[which(contribution$Name=="Dominik Obeth"),"Country"] = "Guinea-Bissau"
contribution[which(contribution$Name=="Ewan Lewis"),"Country"] = "Somalia"
contribution[which(contribution$Name=="Vlado Vasile"),"Country"] = "Kosovo"
contribution[which(contribution$Name=="Riko Morisawa"),"Country"] = "Japan"
contribution %>%
    filter(is.na(Country) | is.na(Name) | is.na("Start Date"))
write_csv(contribution, "../data/contribution.csv")
contribution_json <- toJSON(contribution, null="null", encoding="UTF-8")
con <- file("../data/contribution.json",encoding="UTF-8")
write(contribution_json, con)
