# Introduction ------------------------------------------------------------

# To compare the MI-algorithm to simPop we need to identify a best case 
# estimation procedure for SimPop and our fictive population.


# Setup -------------------------------------------------------------------

rm(list = ls())
setwd("") # enter working directory here


# Packages and dataframes -------------------------------------------------

# our fictive population
load("df_census.RData")

# As we already evaluated in a first application, the simPop-function has 
# a bug in terms of creating population values.
# Therefore we define a weight-vector of 1s 
# and apply the specified workaround.
df_census$weight <- rep(1, nrow(df_census))

# the simPop-package
if (!require("simPop")) install.packages("simPop")
library(simPop)


# Comparison of different methods -----------------------------------------

# As already stated in the introduction we try to find the best methods
# in the simPop-package. We choose the meethod in terms of univariate fits.

inp <- specifyInput(df_census, hhid = "household_id", 
                    strata = "region", population = F,
                    weight = "weight") 

data_sim <- simStructure(dataS = inp, method = "distribution",
                         basicHHvars = c("gender", "age"))


# Categorical variables ---------------------------------------------------

# vector of method-names
methods <- c("multinom", "distribution", "ctree", "cforest")
# The ranger-method is neglected because a error occured by executing it.

# create storage for optimaziton
storage <- list()

# for-loop to apply all available methods for simCategorical()
for (i in (1:length(methods))) {
  print(paste(c("start with method ", methods[i]), 
              sep = "", collapse = ""))
  data_sim_temp <- simCategorical(simPopObj = data_sim,
                                 additional = c("citizenship", "employement"),
                                 method = methods[i],
                                 verbose = T)
  storage[[methods[i]]] <- data_sim_temp@pop@data
  print(paste(c("method ", methods[i], " completed and saved"), 
              sep = "", collapse = ""))
}

# graphical evaluation
cat_vars <- list()
for (i in (1:length(storage))) {
  cat_vars[[methods[i]]] <- storage[[i]][, c("citizenship", "employement")]
  print(paste(c("cat_vars from method ", methods[i], " saved"), 
              sep = "", collapse = ""))
}

windows()
par(mfrow=c(5,2))
barplot(table(df_census$citizenship), 
        col = "dodgerblue4", main = "gold standard - citizenship")
barplot(table(df_census$employement), 
        col = "darkseagreen4", main = "gold standard - employement")
barplot(table(cat_vars$multinom$citizenship), 
        col = "lightblue", main = "multinom")
barplot(table(cat_vars$multinom$employement), 
        col = "darkseagreen1", main = "multinom")
barplot(table(cat_vars$distribution$citizenship), 
        col = "lightblue", main = "distribution")
barplot(table(cat_vars$distribution$employement), 
        col = "darkseagreen1", main = "distribution")
barplot(table(cat_vars$ctree$citizenship), 
        col = "lightblue", main = "ctree")
barplot(table(cat_vars$ctree$employement), 
        col = "darkseagreen1", main = "ctree")
barplot(table(cat_vars$cforest$citizenship), 
        col = "lightblue", main = "cforest")
barplot(table(cat_vars$cforest$employement), 
        col = "darkseagreen1", main = "cforest")
dev.off()

# The univariate analysis shows that all methods perform nearly equally good.
# There seems to be a small benefit of using the multinom-method or 
# the distribution-method. But they seem to be neglectable in our case.
# Therfore we use the s4-object created with multinom in the following.

data_sim <- simCategorical(simPopObj = data_sim,
               additional = c("citizenship", "employement"),
               method = "multinom",
               verbose = F)

# clean enviroment
rm(cat_vars, data_sim_temp, methods, i)


# Continuous variables ----------------------------------------------------

# define a vector of methods
methods <- c("multinom", "lm")
# since we do not have a real count variable
# we omitt the method poisson.

# create storage for optimaziton
storage <- list()

# for-loop to apply all available methods for simContinuous()
for (i in (1:length(methods))) {
  print(paste(c("start with method ", methods[i]), 
              sep = "", collapse = ""))
  data_sim_temp <- simContinuous(simPopObj = data_sim,
                                  additional = "household_inc",
                                  method = methods[i],
                                  verbose = T)
  storage[[methods[i]]] <- data_sim_temp@pop@data
  print(paste(c("method ", methods[i], " completed and saved"), 
              sep = "", collapse = ""))
}

# graphical evaluation
cont_vars <- list()
for (i in (1:length(storage))) {
  cont_vars[[methods[i]]] <- storage[[i]][, c("household_inc")]
  print(paste(c("cont_vars from method ", methods[i], " saved"), 
              sep = "", collapse = ""))
}

windows()
par(mfrow=c(1,3))
boxplot(df_census$household_inc, col = "tan1",
        main = "gold standard - househ. income")
boxplot(cont_vars$multinom$household_inc, col = "tan",
        main = "multinom")
boxplot(cont_vars$lm$household_inc, col = "tan",
        main = "standard linear regression")
dev.off()

# Because of this result we prefer again the method multinom
# Therefore we finally update our s4 object 
# by the multinom-procedure.

data_sim <- simContinuous(simPopObj = data_sim,
                          additional = "household_inc",
                          method = "multinom", verbose = T)
data_syn_simPop_best <- data_sim@pop@data
data_syn_simPop_best <- data_syn_simPop_best[,-c("household_incCat",
                                                 "weight", "pid")]
# simPop classifies the income additionaly but this is
# not needed here, since we want to compare it to 
# unclassified values of other procedures.

save(data_syn_simPop_best, file = "data_syn_simPop_best.RData")



# Runtime estimation ------------------------------------------------------
start_time <- Sys.time()
inp <- specifyInput(df_census, hhid = "household_id", 
                    strata = "region", population = F,
                    weight = "weight") 
data_sim <- simStructure(dataS = inp, method = "distribution",
                         basicHHvars = c("gender", "age"))
data_sim <- simCategorical(simPopObj = data_sim,
                           additional = c("citizenship", "employement"),
                           method = "multinom",
                           verbose = F)
data_sim <- simContinuous(simPopObj = data_sim,
                          additional = "household_inc",
                          method = "multinom", verbose = T)
end_time <- Sys.time()
end_time - start_time