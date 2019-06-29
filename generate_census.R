rm(list = ls())
setwd("") # enter wd here

if (!require("simPop")) install.packages("simPop")
library(simPop)

data("eusilcP")
eusilcP <- na.omit(eusilcP)

used_var <- c("hid", "region", "hsize", "eqIncome",
              "age", "gender", "citizenship", "ecoStat")
eusilcP <- eusilcP[, used_var]

if (!require("dplyr")) install.packages("dplyr")
library(dplyr)

eusilcP <- eusilcP %>% 
  rename(
    household_id = hid,
    household_size = hsize,
    household_inc = eqIncome,
    employment = ecoStat
  )

df_census <- eusilcP
rm(eusilcP, used_var)

df_census$region <- factor(df_census$region, ordered = F)
df_census$household_size <- as.integer(df_census$household_size)
df_census$age <- as.integer(df_census$age)
df_census$household_inc <- as.vector(df_census$household_inc)
levels(df_census$employment) <- c("full_time", "part_time",
                                   "unemployed", "schooling", 
                                   "retired", "disabled", "domestic")

df_census <- df_census[df_census$household_id <= 1500,]
for (id in (1:max(df_census$household_id))) {
  num <- nrow(df_census[df_census$household_id == id,])
  df_census$household_size[df_census$household_id == id] <- num
  df_census$household_inc[df_census$household_id == id] <- (sum(df_census$household_inc[df_census$household_id == id]))/num
}



save(df_census, file = "df_census.RData")
