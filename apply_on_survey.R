# Basics ------------------------------------------------------------------
rm(list = ls())
setwd("~/fully_synthetic_MI")


# Recode the survey -------------------------------------------------------

# load the data
if(!require("simPop")) install.packages("simPop")
library(simPop)
data("eusilcS")

# specify variables
used_var <- c("db030", "db040", "hsize", "netIncome",
              "age", "rb090", "pb220a", "pl030", "db090")
eusilcS <- eusilcS[, used_var]

# rename variables
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
eusilcS <- eusilcS %>% 
  rename(
    household_id = db030,
    region = db040,
    household_size = hsize,
    pers_inc = netIncome,
    gender = rb090,
    citizenship = pb220a,
    employment = pl030,
    weight = db090
  )

# clean the enviroment
df_survey <- eusilcS
rm(eusilcS, used_var)

# recode levels of employement
levels(df_survey$employment) <- c("full_time", "part_time",
                                  "unemployed", "schooling", 
                                  "retired", "disabled", "domestic")

# Apply simPop ------------------------------------------------------------

# without further survey-specific evaluation of the available methods
# we use the method "multinom" in both stages.

start_time <- Sys.time() 
inp <- specifyInput(df_survey, hhid = "household_id", 
                    strata = "region", population = F,
                    weight = "weight") 
data_sim <- simStructure(dataS = inp, method = "distribution",
                         basicHHvars = c("gender", "age"))
data_sim <- simCategorical(simPopObj = data_sim,
                           additional = c("citizenship", "employment"),
                           method = "multinom",
                           verbose = F)
data_sim <- simContinuous(simPopObj = data_sim,
                          additional = "pers_inc",
                          method = "multinom", verbose = F)
end_time <- Sys.time() 
(time_simPop <- end_time - start_time)

# We keep the population data, which result by this method
data_simPop_by_survey <- data_sim@pop@data[,-c("pid", "pers_incCat")]
rm(start_time, end_time, data_sim, inp)

# Apply fully synthetic MI ------------------------------------------------

# load the repsective function and apply it.
# we try to generate weights by multiple imputation and we will not use
# conditions, since we seek for the "best" MI result in terms
# of general properties.
# this will generate unplausible results.
# a drawback, which arised is that synthesis() cannot handle missing
# values (although it should!). 
# this needs to be improved, but is less important for a 
# numerical comparison.
load("synthesis.RData")

start_time <- Sys.time()
data_sim_MI_survey <- synthesis(na.omit(df_survey), 5, data_options = "first_df")
end_time <- Sys.time()
(time_MI <- end_time - start_time)
rm(start_time, end_time)


# Evaluation with Interval Overlap Measure (IOM) --------------------------

 # we decide to use the log income
data_simPop_by_survey$log_pers_inc <- log(data_simPop_by_survey$pers_inc)
data_simPop_by_survey_log <- data_simPop_by_survey[data_simPop_by_survey$log_pers_inc >= 0,]

df_survey$log_pers_inc <- log(df_survey$pers_inc)
df_survey_log <- df_survey[df_survey$log_pers_inc >= 0,]

data_sim_MI_survey$log_pers_inc <- log(data_sim_MI_survey$pers_inc)
data_sim_MI_survey_log <- data_sim_MI_survey[data_sim_MI_survey$log_pers_inc >= 0,]

# calculating the CIs from regression
CI_survey <- confint(lm(log_pers_inc ~ age^2 + gender + region, data = df_survey_log, weights = weight))
CI_simPop <- confint(lm(log_pers_inc ~ age^2 + gender + region, data = data_simPop_by_survey_log, weights = weight))
CI_MI <- confint(lm(log_pers_inc ~ age^2 + gender + region, data = data_sim_MI_survey_log, weights = weight))

# calculate the overlap
CIoverlap <- function(ci1,ci2) {
  intersection <- min(c(ci1[2], ci2[2]))-max(c(ci1[1], ci2[1]))
  return(Iscore <-  intersection/(2*(ci1[2]-ci1[1]))+intersection/(2*(ci2[2]-ci2[1])))
}

# first compare survey with simPop
survey_simPop <- vector()
for (i in 1:nrow(CI_survey)) {
  survey_simPop[i] <- CIoverlap(CI_survey[i,], CI_simPop[i,])
}

# then compare survey with MI
survey_MI <- vector()
for (i in 1:nrow(CI_survey)) {
  survey_MI[i] <- CIoverlap(CI_survey[i,], CI_MI[i,])
}

# create a evaluation matrix
eval_mat <- cbind(survey_simPop, survey_MI)
colnames(eval_mat) <- c("simPop", "MI")
eval_mat[4,1] <- median(eval_mat[4:10, 1])
eval_mat[4,2] <- median(eval_mat[4:10, 2])
eval_mat <- eval_mat[2:4,]
rownames(eval_mat) <- c("age", "gender","region (median coverage)")
(eval_mat <- round(eval_mat, digits = 2))
