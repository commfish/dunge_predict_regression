# Southeast Alaska Dungeness predictive regression
# Exploration of the currently used model with new variables

# K.Palof   ADF&G
# katie.palof@alaska.gov
# 2018-4-09

# Data is updated twice annually 1) during the first 7 days 
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
library(MASS)
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

data2 %>% #filter out current year since it's the one we're going to predict
  filter(year > 1984 & year < 2018) %>%   # not sure why but current model doesn't use data prior to 1985
  dplyr::select(-comments) -> data.explore

# Should season length be included?  NO
# Evaluate model choice --- NEEDS TO BE DONE

# Hierachicial models -----------
fit_all <- lm(remaining.catch ~ catch.7day + permits.7day + pct.previous.yr + season.length, 
              data = data.explore)
summary(fit_all)
## NOTE: permits.7day and season.length are NOT significant


## Stepwise Regression -----
step.all <- stepAIC(fit_all, direction = "both")
# NOTE: final model chosen is: Final Model: remaining.catch ~ catch.7day + pct.previous.yr

## simplified model -----
fit2 <- lm(remaining.catch ~ catch.7day + pct.previous.yr, 
           data = data.explore)
summary(fit2)

data.explore %>% 
  mutate(pred.catch2 = fitted(fit2) + catch.7day) -> data.explore

ggplot(data.explore, aes(year, catch.total)) +
  geom_point(color = "blue") +
  geom_line(color = "blue") +
  scale_y_continuous(limits = c(0, 8000000)) +
  geom_line(aes(year, pred.catch2), color = "red")

## Alternative simple model --------
fit3 <- lm(remaining.catch ~ catch.7day + permits.7day, 
           data = data.explore)
summary(fit3)

data.explore %>% 
  mutate(pred.catch3 = fitted(fit3) + catch.7day) -> data.explore

ggplot(data.explore, aes(year, catch.total)) +
  geom_point(color = "blue") +
  geom_line(color = "blue") +
  scale_y_continuous(limits = c(0, 8000000)) +
  geom_line(aes(year, pred.catch3), color = "red")
