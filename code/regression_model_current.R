# Southeast Alaska Dungeness predictive regression
# Currently used for the Dungeness managmenet plan  5 AAC 32.146.

# K.Palof   ADF&G
# katie.palof@alaska.gov
# 2018-4-09

# This code has just the currently used regression.  Data is updated twice annually 1) during the first 7 days 
#   of the season (June 15th - June 21st) and 2) after the season is complete (fall)

# All catch values are in pounds unless otherwise noted.

# Current regression uses the following to predict remaining season catch (total season catch - first 7days): 
#     1. Catch in the first 7 days of the current season
#     2. Number of permits fished in the first 7 days of the current season
#     3. The percentage - in the previous year (year-1) - of the first 7 days catch to the total season catch
#

# load ----
library(tidyverse)
library(xlsx)
library(extrafont)
options(scipen=9999) # remove scientific notation

loadfonts(device="win")
windowsFonts(Times=windowsFont("TT Times New Roman"))
theme_set(theme_bw(base_size=12,base_family='Times New Roman')+ 
            theme(panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank()))

# data -----
# data is summarized from ALEX or OceanAK by managers and stored in an excel workbook.  
# current data is taken from this workbook.  In the future hoepfully data can be pulled and summarized here *BABYSTEPS*
data <- read.xlsx('data/Dungeness PROJECTED  harvest update_18-19_kjp.xls', sheetName = "Rinput")

# data manipulation -----
data %>% 
  mutate(remaining.catch = catch.total - catch.7day, 
         pct.previous.yr = lag(catch.7day, k = 1)/ lag(catch.total, k =1)) -> data2

data2 %>% 
  select(remaining.catch, catch.7day, permits.7day, pct.previous.yr) -> data.reg


# linear regression ----
