
library(magrittr)
library(dplyr)
library(googlesheets4)
library(here)

ox_notes = read.csv(here("data", "collaboration", "oxcgrt", "OxCGRT_latest_withnotes.csv"), na.strings=c("","NA"))
colnames(ox_notes) = gsub('\\.', ' ', colnames(ox_notes))

ox_notes$ox_id = seq.int(nrow(ox_notes))


ox_notes = ox_notes %>% 
  mutate(ox_id = ifelse(
      is.na(RegionName), paste(CountryName, Date, sep = '_'), paste(CountryName, RegionName, Date, sep  = '_')
    )
  )

nchar('There is an app "BeAware Bahrain" which travellers must download before travelling.')


ox_notes %>% select(CountryName) %>% distinct %>% pull %>% sort
names(ox_notes)
test %>% select(ox_id) %>% distinct %>% pull %>% length
dim(test) 
ox_notes$RegionName %>% is.na %>% table
names(ox_notes)

ox_notes %>% select(CountryName, RegionName, Date)
types = c(
  'C1_School closing',
  'C2_Workplace closing',
  'C3_Cancel public events',
  'C4_Restrictions on gatherings',
  'C5_Close public transport',
  'C6_Stay at home requirements',
  'C7_Restrictions on internal movement',
  'C8_International travel controls',
  'H1_Public information campaigns',
  'H2_Testing policy',
  'H3_Contact tracing',
  'H4_Emergency investment in healthcare',
  'H5_Investment in vaccines',
  'H6_Facial Coverings',
  'H7_Vaccination policy',
  'H8_Protection of elderly people'
)

ox2coronanet = ox_notes %>%
  # remove empty rows
  mutate(dum = rowSums(across(types), na.rm = TRUE)) %>%
  filter(dum != 0)  %>%
  # convert dates
  mutate(Date = ymd(Date)) %>%
  # convert geographic names
  mutate(country = CountryName,
         ISO_A3 = case_when(
           # CountryCode == "ABW" ~ "NLD",
           # CountryCode == "BMU" ~ "GBR",
           #  CountryCode == "FRO" ~ "DNK",
           #  CountryCode == "GRL" ~ "DNK",
           CountryCode == "GUM" ~ "USA",
           CountryCode == "PRI" ~ "USA",
           CountryCode == "VIR" ~ "USA",
           CountryCode == "RKS" ~ "XKX",
           TRUE ~ CountryCode),
         province = RegionName,
         ISO_L2 = RegionCode,
         init_country_level = 
           ifelse(
             Jurisdiction == 'NAT_TOTAL', 
             'National',
             ifelse(
               Jurisdiction == 'STATE_TOTAL', 
               'Provincial', 
               NA))
  )



ox2coronanet %>% 
  filter(country == 'Brazil' & province == 'Sergipe') %>%
  head
names(ox2coronanet)
ox_coronanet_map %>% 
  filter(country == 'Brazil') %>% select(
    province
  ) %>% table



filter_w_flag = function(String) {
  temp = ox2coronanet %>% 
    filter(
      !is.na(get(paste(String))) & !is.na(get(paste(substr(String, 1, 3), "Notes", sep = "")))
    ) %>%
    select(
      ox_id,
      country,  
      ISO_A3,
      province, 
      ISO_L2, 
      init_country_level,
      Date, 
      paste(String), 
      paste(substr(String, 1, 3), "Notes", sep = ""), 
      paste(substr(String, 1, 3), "Flag", sep = ""),
    ) %>%
    group_by(country, province) %>%
    mutate(
      date_end = c(lead(as.character(Date)))
    ) %>%
    ungroup() %>%
    mutate(
      target_country = country,
      date_start = Date,
      link = str_extract(get(paste(substr(String, 1, 3), "Notes", sep = "")), url_pattern),
      description = get(paste(substr(String, 1, 3), "Notes", sep = "")),
      description = get(paste(substr(String, 1, 3), "Notes", sep = "")),
      
      description_nourl=  sub("Link:.*$", '',  description),
      description_nourl  =  sub("link:.*$", '',  description_nourl),
      description_nourl =  sub("Source:.*$", '',  description_nourl),
      description_nourl =  sub("source:.*$", '',  description_nourl),
      description_nourl = gsub(url_pattern, '', description_nourl),
      description_nourl =gsub("policy stays the same as|See previous coding review|Coding review:|lease refer to the note|please refer to the", "", description_nourl),
      count = nchar(description_nourl),
      target_geog_level =
        ifelse(
          get(paste(substr(String, 1, 3), "Flag", sep = "")) == 1, 
          "One or more countries, but not all countries", 
          "One or more provinces within a country"
        )
    ) %>%
    select(-Date, -paste(substr(String, 1, 3), "Notes", sep = ""), -paste(substr(String, 1, 3), "Flag", sep = "")) 
  
  .GlobalEnv$temp  = temp
}
 
filt_patterns= function(data){

  no_change_patt =   data %>%
    arrange(count) %>%
    filter(count < 100)%>%
    mutate(description_nourl = str_trim(description_nourl))%>% 
    mutate(description_nourl = str_replace_all(description_nourl, "[[:punct:]]", ""))%>% 
    mutate(description_nourl = str_trim(description_nourl))%>% 
    filter((count < 35 & grepl("No explicit new measures found|No Evidence of Policy|no such measure|Same directives as earlier|Same as before|The previous note is still valid|Still active|No new restriction|The same as|No policies found|No information was found|No New Policy identified|No available data|no policy change|No details found|No new information|No new policy|no new policy|No policy|no policy|announce|no new|update|Update|Change|change|No guidance|no guidance|Nothing|No info available|Nothing to suggest any policy in place|No Policy|Still current|No policy update|No new measure|No measures|No evidence of a policy change|No evidence of policy change|No data|No specific policy mentioned|still in place|No evidence of a policy change|No evidence of policy change|No major changes noted|No concrete restriction|no data available|No information found|No change|No restriction|NO POLICY CHANGE|Remains as per the previous note|No improvment found|remains the same|remain the same|Same as above|Same policy|No policies in place|No new guidance|No new policies|Same as last|no data|No  new policy|No new polic|no measure|No measure|Previous policy continues|Previous policy is continued", description_nourl))|
            
            (count < 41 & grepl("No further evidence of|No new changes in the policy post|No specific measures could be found|No major changes noted since|Previous policies are still in force", description_nourl))|
             description_nourl %in% c(
              "I did not find additional information",
              "No additional policy information found",
              "No new policy or change in policy identified",
              "No improvement found",
              "I wasn't able to find any measure in place",
              "No specific protection measures could be found",
              "There is no mention of measures concerning this",
              "No detected change in this indicator"
            ) 
             ) %>% 
    select(description_nourl) %>%
    distinct %>% 
    mutate(
      change_pattern =
        paste(description_nourl, collapse = '|')) %>%
    select(change_pattern) %>% distinct %>% pull 
  
  .GlobalEnv$no_change_patt = no_change_patt
}
 

filter_no_changes = function(data){
  data =  do.call(rbind, lapply(unique(data$country), function(c){
    slice = data %>% filter(country == c) %>% data.frame
    
    
    slice = slice %>% 
              mutate(description_nourl_raw = str_trim(description_nourl),
              description_nourl_raw = str_replace_all(description_nourl_raw, "[[:punct:]]", ""),
              count_raw = nchar(description_nourl_raw)) 
    
    
    last_row = slice %>% slice(n())
    
    slice = slice %>%
      slice(1:c(n()-1))
    
    slice  = slice [!(grepl(no_change_patt, slice$description_nourl_raw)  & slice$count_raw < 80 ),]
    
    
    slice = rbind(slice, last_row)
    
  }))
  
 
}

filter_same_description = function(data){
  
  data =  do.call(rbind, lapply(unique(data$country), function(c){
    slice = data %>% filter(country == c) %>% data.frame
    
    
    
    slice = slice %>% 
      mutate(description_nourl_raw = str_trim(description_nourl),
             description_nourl_raw = str_replace_all(description_nourl_raw, "[[:punct:]]", ""),
             count_raw = nchar(description_nourl_raw),
             short_desc_dum = ifelse(count_raw < 20, 1, 0),
             only_url_dum = ifelse(description_nourl_raw == '', 1, 0)
      ) 
    
    slice_save = slice %>% filter(short_desc_dum == 1  )
    
    
    slice_filt = slice %>%
      filter(short_desc_dum==0 ) %>%
      group_by(description_nourl_raw ) %>%
      slice(c(1,n())) %>%
      ungroup() %>% distinct
    
    slice = rbind(slice_filt,slice_save) %>%
      arrange(date_start)
    return(slice )
  }))
}

ox2coronanet_tracing %>%
  filter(unique_id %in% a & count_raw<80 & count_raw>20)%>%
  select(description_nourl_raw)

test = filter_same_description(ox2coronanet_tracing)

dim(test)/dim(ox2coronanet_tracing)
filter_w_flag("C1_School closing")
ox2coronanet_schools = temp %>%
  mutate(
    compliance = 
      ifelse(
        `C1_School closing` %in% c(2, 3), 
        "Mandatory (Unspecified)", 
        NA
      ),
    type = 'Closure and Regulation of Schools',
    unique_id = paste(ox_id, "school", sep = "_"),
    type_sub_cat = 
      ifelse(
        `C1_School closing` == 3, 
        'Preschool or childcare facilities (generally for children ages 5 and below),Primary Schools (generally for children ages 10 and below),Secondary Schools (generally for children ages 10 to 18),Higher education institutions (i.e. degree granting institutions)', 
        NA
      ),
    institution_status = 
      ifelse(
        `C1_School closing` == 0,
        paste0(type_sub_cat, " allowed to open with no conditions"),
        ifelse(
          `C1_School closing` %in% c(1, 2, 3),
          #`C1_School closing` == 3,
          paste0(type_sub_cat, " closed/locked down"), 
          NA
        )
      )
  ) %>%
  select(-"C1_School closing")


filt_patterns(ox2coronanet_schools)
ox2coronanet_schools = filter_no_changes(ox2coronanet_schools)
dim(ox2coronanet_schools)
dim(test)
table(ox2coronanet_schools$country)
table(test$country)
dim(test)
table(test$short_desc_dum)
table(test$only_url_dum)
setdiff(ox2coronanet_schools$unique_id, test$unique_id)
table(test$count_raw) %>% head

ox2coronanet_schools%>%
  filter(unique_id %in%
           setdiff(ox2coronanet_schools$unique_id, test$unique_id)[1:100]
           ) %>%
  select(description_nourl_raw)


filter_wo_flag = function(String) {
  temp = ox2coronanet %>% 
    filter(
      !is.na(get(paste(String))) & !is.na(get(paste(substr(String, 1, 3), "Notes", sep = "")))
    ) %>%
    select(
      ox_id,
     # ox_id_num,
      country,  
      ISO_A3,
      province, 
      ISO_L2, 
      init_country_level,
      Date, 
      paste(String), 
      paste(substr(String, 1, 3), "Notes", sep = ""), 
    ) %>%
    group_by(country, province) %>%
    mutate(
      date_end = c(lead(as.character(Date)))
    ) %>%
    ungroup() %>%
    mutate(
      target_country = country,
      date_start = Date,
      description = get(paste(substr(String, 1, 3), "Notes", sep = "")),
      link = str_extract(get(paste(substr(String, 1, 3), "Notes", sep = "")), url_pattern),
      description_nourl=  sub("Link:.*$", '',  description),
      description_nourl  =  sub("link:.*$", '',  description_nourl),
      description_nourl =  sub("Source:.*$", '',  description_nourl),
      description_nourl =  sub("source:.*$", '',  description_nourl),
      description_nourl = gsub(url_pattern, '', description_nourl),
      description_nourl = ifelse(is.na(link), gsub("See previous coding review|Coding review:|lease refer to the note|please refer to the", "", description_nourl), description_nourl),
      count = nchar(description_nourl),
    ) %>%
    select(-Date, -paste(substr(String, 1, 3), "Notes", sep = "")) 
  
  .GlobalEnv$temp  = temp
}

filter_wo_flag("H3_Contact tracing")

ox2coronanet_tracing = temp %>%
  mutate(
    type = "Contact Tracing",
    unique_id = paste(ox_id, "tracing", sep = "_"),
    #ox_id = paste(ox_id_num, "tracing", sep = "_"),
  ) %>%
  select(-"H3_Contact tracing")

filt_patterns(ox2coronanet_tracing )
ox2coronanet_tracing= filter_no_changes(ox2coronanet_tracing)

test = filt_same_description(ox2coronanet_tracing)

a = setdiff(ox2coronanet_tracing$unique_id, test$unique_id)




ox2coronanet_tracing%>%
  filter(unique_id %in% c(
    "Bahrain_20210323_tracing",
    "Bahrain_20210407_tracing",
    "Bahrain_20210424_tracing",
    "Bahrain_20210504_tracing",
    "Bahrain_20210511_tracing",
    "Bahrain_20210518_tracing",
    "Bahrain_20210525_tracing",
    "Bahrain_20210407_tracing",
    "Bahrain_20210323_tracing",
    "Bahrain_20210323_tracing",
    "Bahrain_20210323_tracing",
    
    
  ))



dim(test)/dim(ox2coronanet_schools)
.96*96
a = test %>%
  filter(country == 'Zimbabwe') %>%
  filter(short_desc_dum == 0) %>%
  group_by(description_nourl_raw) %>%
  slice(1, n()) %>%
  ungroup() %>%
  distinct
 
b = test %>%
  filter(country == 'Zimbabwe') %>%
  filter(short_desc_dum == 0)
 
 

?slice
no_change_patt

ox2coronanet_schools%>%
  slice(c(1,5))

ox2coronanet_schools %>%
  filter(
    grepl(no_change_patt, description_nourl_raw)
  ) %>% select(
    description
  ) %>% slice(1:20)
















filt_patterns(ox_coronanet_map)
 
test = filter_no_changes(ox_coronanet_map)
nchar("No information found")
dim(test)

# remove observations that haveno link and very short description
test %>% filter(is.na(link)) %>% select(description_nourl) %>% filter(nchar(description_nourl)<50) %>% dim

test %>% filter(is.na(link)) %>% select(description_nourl) %>% filter(nchar(description_nourl)<50) %>% select(description_nourl) %>% tail
slice(1:100)

nchar("No evidence of additional restrictions")
ox_coronanet_map %>% filter(description_nourl == '' )  

ox_coronanet_map %>% filter(grepl("Coding review|Coding review", description) & is.na(link)) %>% dim

ox_coronanet_map %>% filter(grepl("Coding review|Coding review", description)) %>% select(description)


test = ox_coronanet_map %>% filter(!(is.na(link) & grepl("C1|C2|C3|C4|C5|C6|C7|C8|H1|H2|H3|H4|H5|H6|H7|H8", description))) 



ox_notes %>% filter(CountryCode %in% c("VIR", "PRI", "GUM", "GRL", "FRO", "BMU", "ABW")) %>% select(CountryName, CountryCode) %>% distinct

ox_coronanet_map%>% filter(is.na(link) ) %>% select(description_nourl) %>%  dim

filt_patterns(ox_coronanet_map)
test = filter_no_changes(ox_coronanet_map)
dim(test) 
dim(ox_coronanet_map)
ox_coronanet_map %>% filter(!is.na(link) & nchar(description_nourl)<50) %>% select(description_nourl_raw, description_nourl) %>% distinct %>% 
slice(2100:2110)


nchar("Policy is still in effect")

ox_coronanet_map<- readRDS( file ="./data/collaboration/oxcgrt/ox_coronanet_map.rds" )
dim(ox_coronanet_map)

nchar("I was unable to find anything protecting elderly people")


nchar("No specific policy mentioned")
test%>% 
  filter( nchar(description_nourl) < 50) %>%
  select(description_nourl) %>% 
  slice(101:200)


ox_coronanet_map<- readRDS( file ="./data/collaboration/oxcgrt/ox_coronanet_map.rds" )   %>%
  filter(type != "Other Policy Not Listed Above" ) %>%
  arrange(country, province, type, date_start) %>% 
  mutate( overlap_assessment= as.character(NA),
          matched_record_id = "",
          Notes = "" ,
          integrate_assessment = as.character(NA),
          date_start = as.Date( date_start, "%Y-%m-%d"),
          date_end = as.Date( date_end, "%Y-%m-%d"),
          
  )%>%
  select( overlap_assessment, matched_record_id, Notes, integrate_assessment, everything() )


# countries = c("Bulgaria", "Luxembourg")
#  
# for ( c in countries){
#   ox_coronanet_map %>%
#     filter(
#       country == c
#     ) %>%
#     select(overlap_assessment,matched_record_id, Notes, integrate_assessment, unique_id, description = description_nourl ,date_start, date_end, country, province, type, type_sub_cat,   link  ) %>%
#     write_sheet(
#       ss = gs4_get(
#         "https://docs.google.com/spreadsheets/d/1B2HrbJvDZN1th1tFcv7na8yveF5htjFpgNhtejLi8_I/edit#gid=0"
#       ),
#       sheet =  c
#     )
#   
# }