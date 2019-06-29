rm(list = ls())
setwd("") # enter wd here

if (!require("simPop")) install.packages("simPop")
library(simPop)

load("df_census.RData")
df_census$weight <- rep(1, nrow(df_census))

inp <- specifyInput(df_census, hhid = "household_id", 
                    hhsize = NULL, # because sizes are automatically calculated
                    strata = "region", population = F,
                    weight = "weight") 
                    # mimic a sample, but weights 1 so we treat
                    # it as population

data_sim <- simStructure(dataS = inp, method = "distribution",
                         basicHHvars = c("gender", "age"))

data_sim <- simCategorical(simPopObj = data_sim,
                           additional = c("citizenship", "employment"),
                           method = "cforest",
                           verbose = T)
                          # strata is already defined as input

data_sim <- simContinuous(simPopObj = data_sim,
                          additional = "household_inc",
                          method = "lm")

data_syn_simPop <- data_sim@sample@data[,-(c("household_size", "pid"))]

if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
data_syn_simPop <- data_syn_simPop %>%
  rename(household_size = hhsize)

save(data_syn_simPop, file = "data_syn_simPop.RData")
