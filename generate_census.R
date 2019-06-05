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
    employement = ecoStat
  )

df_census <- eusilcP
rm(eusilcP, used_var)

df_census$region <- factor(df_census$region, ordered = F)
df_census$household_size <- as.integer(df_census$household_size)
df_census$age <- as.integer(df_census$age)
df_census$household_inc <- as.vector(df_census$household_inc)
levels(df_census$employement) <- c("full_time", "part_time",
                                   "unemployed", "schooling", 
                                   "retired", "disabled", "domestic")

df_census <- df_census[df_census$household_id <= 1500,]


save(df_census, file = "df_census.RData")
