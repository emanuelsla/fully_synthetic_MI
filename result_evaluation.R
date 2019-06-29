# Specify settings and load data ------------------------------------------

# settings
rm(list = ls())
setwd("") # enter working directory here

# dataframes
load("df_census.RData")
load("data_syn_MI.RData")
load("data_syn_MI_conds.RData")
load("data_syn_simPop_best.RData")

# The first thing to mention is that the dataframe, which was constructed
# by simPop differ from the census in terms of dimensions.
# Where as the others do not.


# Disclosure risk ---------------------------------------------------------

# For simulated synthetic data the calculation of the disclosure risk
# is hard. At this point only a logic argumentation is given:
# If the dataframe is fully synthetic, no real person can be detected.
# So the disclosure risk goes towards 0.
# This can be extended by a mathematical reasoning.


# Data utility ------------------------------------------------------------


# univariate properties

# categorial data
jpeg(filename = "univariate_categorical_comp.jpeg", quality = 100)
par(mfrow=c(4,1))
barplot(table(df_census$employment), 
        main = "employment status \n \ngold standard - census",
        col = "goldenrod1")
barplot(table(data_syn_simPop_best$employment), main = "simPop",
        col = "darkolivegreen3")
barplot(table(data_syn_MI$employment), main = "MI",
        col = "dodgerblue4")
barplot(table(data_syn_MI_conds$employment), main = "MI with conditions",
        col = "dodgerblue3")
dev.off()

# numerical data
jpeg(filename = "univariate_continuous_comp.jpeg", quality = 100)
par(mfrow=c(2,2))
boxplot(df_census$household_inc,
        main = "gold standard - census",
        col = "goldenrod1", ylim = c(0,30000))
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_simPop_best$household_inc, main = "simPop",
        col = "darkolivegreen3", ylim = c(0,30000))
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_MI$household_inc, main = "MI",
        col = "dodgerblue4", ylim = c(0,30000))
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_MI_conds$household_inc, main = "MI with conditions",
        col = "dodgerblue3", ylim = c(0,30000))
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
mtext("household income \nred: overall mean of household income", 
      side = 3, line = -21, outer = TRUE)
dev.off()


# bivariate correlation
jpeg(filename = "multivariate_comp.jpeg", quality = 100)
par(mfrow=c(2,2))
boxplot(df_census$household_inc ~ df_census$citizenship,
        main = "gold standard \ncensus",
        col = "goldenrod1", ylim = c(0,30000), xlab = "", ylab = "")
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_simPop_best$household_inc ~ data_syn_simPop_best$citizenship,
        main = "simPop",
        col = "darkolivegreen3", ylim = c(0,30000), xlab = "", ylab = "")
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_MI$household_inc ~ data_syn_MI$citizenship,
        main = "MI",
        col = "dodgerblue4", ylim = c(0,30000), xlab = "", ylab = "")
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
boxplot(data_syn_MI_conds$household_inc ~ data_syn_MI_conds$citizenship,
        main = "MI with conditions",
        col = "dodgerblue3", ylim = c(0,30000), xlab = "", ylab = "")
abline(h = mean(df_census$household_inc), col = "red")
abline(h = quantile(df_census$household_inc, 0.25), col = "red", lty = 2)
abline(h = quantile(df_census$household_inc, 0.75), col = "red", lty = 2)
mtext("household income cond. on citizenship \nred: overall mean of household income", 
      side = 3, line = -21, outer = TRUE)
dev.off()


# classical error sources

# household structure
max_hs <- which(df_census$household_size == max(df_census$household_size))
hhindex <- df_census$household_id[2270]
temp_data <- df_census[df_census$household_id == hhindex,]
write.csv(temp_data, file = "household_census.csv")
rm(hhindex, temp_data, max_hs)

max_hs <- which(data_syn_simPop_best$hhsize == max(data_syn_simPop_best$hhsize))
hhindex <- data_syn_simPop_best$household_id[2495]
temp_data <- data_syn_simPop_best[data_syn_simPop_best$household_id == hhindex,]
write.csv(temp_data, file = "household_simPop.csv")
rm(hhindex, temp_data, max_hs)

max_hs <- which(data_syn_MI$household_size == max(data_syn_MI$household_size))
hhindex <- data_syn_MI$household_id[49]
temp_data <- data_syn_MI[data_syn_MI$household_id == hhindex,]
write.csv(temp_data, file = "household_MI.csv")
rm(hhindex, temp_data, max_hs)

max_hs <- which(data_syn_MI_conds$household_size == max(data_syn_MI_conds$household_size))
hhindex <- data_syn_MI_conds$household_id[2270]
temp_data <- data_syn_MI_conds[data_syn_MI_conds$household_id == hhindex,]
write.csv(temp_data, file = "household_MI_conds.csv")
rm(hhindex, temp_data, max_hs)

# Addditonally household income region and age rounding can be compared with above output.
