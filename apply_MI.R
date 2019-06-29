rm(list = ls())
setwd("") # enter wd here

load("df_census.RData")


# fully snythetic MI ------------------------------------------------------
load("synthesis.RData")

# without conditions
start_time <- Sys.time()
data_syn_MI <- synthesis(df_census, 5, data_options = "first_df")
end_time <- Sys.time()
end_time - start_time
rm(start_time, end_time)

save(data_syn_MI, file = "data_syn_MI.RData")

# with conditions
conds <- c("synthetic_data[[i]]$age <- round(synthetic_data[[i]]$age)",
           "synthetic_data[[i]]$household_inc[synthetic_data[[i]]$age < 16] <- 0",
           "synthetic_data[[i]]$household_inc[synthetic_data[[i]]$employment == 'unemployed'] <- 0",
           "for (id in (1:max(synthetic_data[[i]]$household_id))) {
             num <- nrow(synthetic_data[[i]][synthetic_data[[i]]$household_id == id,])
             synthetic_data[[i]]$household_size[synthetic_data[[i]]$household_id == id] <- num
             synthetic_data[[i]]$household_inc[synthetic_data[[i]]$household_id == id] <- (sum(synthetic_data[[i]]$household_inc[synthetic_data[[i]]$household_id == id]))/num
           }")

start_time <- Sys.time()
data_syn_MI_conds <- synthesis(df_census, 5, data_options = "first_df", 
                               conditions = conds)
end_time <- Sys.time()
end_time - start_time
rm(start_time, end_time)

save(data_syn_MI_conds, file = "data_syn_MI_conds.RData")

# help function for eventual bug fixing
# can be removed after evaluation

# data_syn_MI$household_inc[data_syn_MI$age < 16] <- 0
# data_syn_MI$household_inc[data_syn_MI$employment == "unemployed"] <- 0
# 
# for (id in (1:max(data_syn_MI$household_id))) {
#   num <- nrow(data_syn_MI[data_syn_MI$household_id == id,])
#   data_syn_MI$household_size[data_syn_MI$household_id == id] <- num
#   data_syn_MI$household_inc[data_syn_MI$household_id == id] <- (sum(data_syn_MI$household_inc[data_syn_MI$household_id == id]))/num
# }

