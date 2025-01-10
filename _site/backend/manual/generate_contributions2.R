library(tidyverse)
library(jsonlite)

df <- read_csv("/Users/aiart/CoronaNetDataScience/corona_private/data/people/contribution.csv")
senior_ra <- df %>%
  filter(Special_Role_2 == "Prefect" | Special_Role == "Prefect")
managers <- df %>%
  filter(Special_Role_2 == "Country Manager" | Special_Role == "Country Manager" | Special_Role_2 == "Regional Manager" | Special_Role == "Regional Manager")
validation <- df %>%
  filter(Validating == 1)
cleaning <- df %>%
  filter(Cleaning == 1)
ds <- df %>%
  filter(`Data Science` == 1 | Special_Role_2 == "Data Science Team" | Special_Role == "Data Science Team")
ra <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/contribution.csv")

survey <- read_csv("../data/survey.csv")
survey <- survey %>%
  select(Name = Q51, Vita = Q61, Affiliation = Q60, "Social Media" = Q62)
survey <- survey %>%
  filter(Name != "Luca Messerschmidt")
survey <- survey[3:nrow(survey),]
# remove duplicate entries per person, leave the ones with the most info
survey$na <- rowSums(is.na(survey))
survey <- survey %>%
  arrange(na) %>%
  distinct(Name, .keep_all = T) %>%
  select(-na)

survey2 <- readxl::read_xlsx("../data/survey_v2.xlsx")
survey2 <- survey2 %>%
  select(Name = name, Vita = bioupdate_vita, Affiliation = bioupdate_affiliation, "Social Media" = bioupdate_linkedintwitter)
survey2 <- survey2[3:nrow(survey2),]
survey2$na <- rowSums(is.na(survey2))
survey2 <- survey2 %>%
  arrange(na) %>%
  distinct(Name, .keep_all = T) %>%
  select(-na)

survey <- rbind(survey, survey2)
survey$na <- rowSums(is.na(survey))
survey <- survey %>%
  arrange(na) %>%
  distinct(Name, .keep_all = T) %>%
  select(-na)

senior_ra <- senior_ra %>%
  select(Name, Vita, start) %>%
  left_join(survey, by = c("Name")) %>%
  rename("Start Date" = start)
senior_ra$Vita2 <- apply(senior_ra, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
senior_ra <- senior_ra %>%
  select(-Vita.y, -Vita.x) %>%
  rename(Vita = Vita2)
senior_ra <- senior_ra %>%
  select(Name, Vita, Affiliation, `Social Media`, `Start Date`)
write_csv(senior_ra, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/senior_ra.csv")
senior_ra <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/senior_ra.csv")
print(senior_ra$Name[duplicated(senior_ra$Name)])
senior_ra <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/senior_ra.csv")
print(senior_ra$Name[duplicated(senior_ra$Name)])
senior_json <- toJSON(senior_ra, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/senior_ra.json",encoding="UTF-8")
write(senior_json, con)

managers <- managers %>%
  select(Name, Vita, start) %>%
  left_join(survey, by = c("Name")) %>%
  rename("Start Date" = start)
managers$Vita2 <- apply(managers, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
managers <- managers %>%
  select(-Vita.y, -Vita.x) %>%
  rename(Vita = Vita2)
managers <- managers %>%
  select(Name, Vita, Affiliation, `Social Media`, `Start Date`) %>%
  unique()
write_csv(managers, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/managers.csv")
managers <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/managers.csv")
print(managers$Name[duplicated(managers$Name)])
managers <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/managers.csv")
print(managers$Name[duplicated(managers$Name)])
managers_json <- toJSON(managers, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/managers.json",encoding="UTF-8")
write(managers_json, con)

validation <- validation %>%
  select(Name, Vita, start) %>%
  left_join(survey, by = c("Name")) %>%
  rename("Start Date" = start)
validation$Vita2 <- apply(validation, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
validation <- validation %>%
  select(-Vita.y, -Vita.x) %>%
  rename(Vita = Vita2)
validation <- validation %>%
  select(Name, Vita, Affiliation, `Social Media`, `Start Date`) %>%
  unique()
write_csv(validation, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/validation.csv")
validation <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/validation.csv")
print(validation$Name[duplicated(validation$Name)])
validation <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/validation.csv")
print(validation$Name[duplicated(validation$Name)])
validation_json <- toJSON(validation, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/validation.json",encoding="UTF-8")
write(validation_json, con)

cleaning <- cleaning %>%
  select(Name, Vita, start) %>%
  left_join(survey, by = c("Name")) %>%
  rename("Start Date" = start)
cleaning$Vita2 <- apply(cleaning, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
cleaning <- cleaning %>%
  select(-Vita.y, -Vita.x) %>%
  rename(Vita = Vita2)
cleaning <- cleaning %>%
  select(Name, Vita, Affiliation, `Social Media`, `Start Date`) %>%
  unique()
write_csv(cleaning, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/cleaning.csv")
cleaning <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/cleaning.csv")
print(cleaning$Name[duplicated(cleaning$Name)])
cleaning <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/cleaning.csv")
print(cleaning$Name[duplicated(cleaning$Name)])
cleaning_json <- toJSON(cleaning, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/cleaning.json",encoding="UTF-8")
write(cleaning_json, con)

ds <- ds %>%
  select(Name, Vita, start) %>%
  left_join(survey, by = c("Name")) %>%
  rename("Start Date" = start)
ds$Vita2 <- apply(ds, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
ds <- ds %>%
  select(-Vita.y, -Vita.x) %>%
  rename(Vita = Vita2)
ds <- ds %>%
  select(Name, Vita, Affiliation, `Social Media`, `Start Date`) %>%
  unique()
write_csv(ds, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/datascience.csv")
ds <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/datascience.csv")
print(ds$Name[duplicated(ds$Name)])
ds <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/datascience.csv")
print(ds$Name[duplicated(ds$Name)])
ds_json <- toJSON(ds, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/datascience.json",encoding="UTF-8")
write(ds_json, con)

ra <- ra %>%
  select(Name, Vita, Country, "Start Date") %>%
  left_join(survey, by = c("Name"))
ra$Vita <- apply(ra, 1, function(x) {if (is.na(x["Vita.y"])) {x["Vita.x"]} else {x["Vita.y"]}})
ra <- ra %>%
  select(-Vita.x, -Vita.y)
ra <- ra %>%
  select(Name, Country, Vita, Affiliation, `Social Media`, `Start Date`) %>%
  unique()
write_csv(ra, "/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/contribution.csv")
ra <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/contribution.csv")
print(ra$Name[duplicated(ra$Name)])
ra <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/contribution.csv")
print(ra$Name[duplicated(ra$Name)])
ra_json <- toJSON(ra, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/contribution.json",encoding="UTF-8")
write(ra_json, con)

website <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/website.csv")
website_json <- toJSON(website, null="null", encoding="UTF-8")
con <- file("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/website.json",encoding="UTF-8")
write(website_json, con)

project_managers <- read_csv("/Users/aiart/CoronaNetDataScience/CoronaNet_V2/data/roles/project_managers.csv")
project_manager_json <- toJSON(project_managers, null="null", encoding="UTF-8")
con <- file("../data/roles/project_managers.json",encoding="UTF-8")
write(project_manager_json, con)
