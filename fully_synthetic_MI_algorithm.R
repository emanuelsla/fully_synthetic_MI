# Introduction ------------------------------------------------------------

# It is coded such, that partial AND fully synthetic MI is possible.
# The trees are chosen such like Drechsler and Reiter propose it in JASA. 
# The pruning parameters are sometimes different. 
# In the categorial case rpart instead of tree is applied.
# The sequence is not discussed. 
# The first variable is always the reference.
# Sequencing is like occurance in the data frame.
# The algorithm is programmed as general function, so application is universal.
# Variable should be coded as factor or numeric (ordered factor suits, too).


# Define enviroment -------------------------------------------------------
rm(list = ls())
setwd("")



# Algorithm as function ---------------------------------------------------

# a dataframe (df) and number of repetitions (repetitions) as input
# additionally: conditions can be imbedded,
# must be a vector of the following manner:
# e.g. conditions <- c("synthetic_data[[i]]$age <- round(synthetic_data[[i]]$age)")
# and data_options ("list": all MI repetitions as list, 
# "first_df": first MI repetiton as df, "sample": sample of all MI repetitons with inital length)
# further: pruning for tree and rpart can be specified with minsplit, minbucket, mindev and mincut
synthesis <- function(df, repetitions, conditions = NULL, data_options = "list",
                      minsplit = 5, minbucket = 10, mindev = 0.0001, mincut = 5){
  
  # define dependencies
  if(!require("tree")) install.packages("tree")
  library(tree)
  if(!require("bayesboot")) install.packages("bayesboot")
  library(bayesboot)
  if(!require("rpart")) install.packages("rpart")
  library(rpart)
  
  # a priori specification
  R <- repetitions
  
  # storage
  excluded_var <- factor()
  my_sample <- factor()
  
  synthetic_data <- list()
  for (i in 1:R) {
    synthetic_data[[i]] <- data.frame()
  }
  
  # loop starts
  for (i in 1:R) {
    
    # we start in every round with fitting the second parameter in the dataset
    var <- 2
    
    # counts if we reached end of dataframe or not
    while (var <= ncol(df)) {
      
      # check if it is a numeric variable
      if (is.numeric(df[,var])){
        
        # fitting tree for numeric variables
        mytree <- tree(df[,var] ~ . , data = df[,-((var + 1) : ncol(df))], 
                       split = "deviance" , mindev = mindev, 
                       control = tree.control(nobs = nrow(df), mincut = mincut),
                       model = T, x = T)
        
        # we grep the different buckets
        where <- as.factor(mytree[["where"]])
        df$where <- where
        where <- levels(where)
        
        # we apply a bootstap for every bucket
        # and assign the values to the dataframe
        for (j in 1:length(where)) {
          df[,var][df$where == where[j]] <- unlist(bayesboot(df[,var][df$where == where[j]], 
                                          statistic = mean, 
                                          R = sum(df$where == where[j])))
        }
        
        # check if the variable is a factor or not
      } else if (is.factor(df[,var])) {
        
        # fit a tree for factors (different pruning as in JASA!)
        mytree <- rpart(df[,var] ~ . , 
                        data = df[,-((var + 1) : ncol(df))],
                        method = "class",
                        control = rpart.control(minsplit = minsplit, minbucket = minbucket))
        
        # grap the buckets
        where <- as.factor(mytree[["where"]])
        df$where <- where
        where <- levels(where)
        
        # we apply a bootstap for every bucket
        # and assign the values to the dataframe
        for (j in 1:length(where)) {
          prob <- as.vector(table(
            df[,var][df$where == where[j]])/length(
              df[,var][df$where == where[j]]))
          
          my_sample <- unlist(sample(levels(df[,var][df$where == where[j]]),
                                     sum(df$where == where[j]), replace = T, prob = prob))
          
          df[,var][df$where == where[j]] <- my_sample
        }
        
        # control string, when variable is not numeric and no factor
      } else stop(print("Don't know what to do with your information"))
      
      # continue with the next variable
      var <- var + 1
      
      # save the repetition in the list
      synthetic_data[[i]] <- df[,-(ncol(df))]
      
    }
    
    # !!! here the restrictions are imbedded as optional parameter !!!
    if (is.null(conditions)) {
      next
    } else {
      for (n in (1:length(conditions))) {
        eval(parse(text = conditions[n]))
      }
    }
    # !!! above the restrictions are imbedded as optional parameter !!!
    
  }
  
  # list: all synthetic dataframe are returne as list
  # fist_df: the first MI dataframe is returned
  # sample: a random sample of all MI dataframe with inital nrow is returned
  if (data_options == "list") {
    return(synthetic_data)
  } else if (data_options == "first_df") {
    return(synthetic_data[[1]])
  } else  if (data_options == "sample"){
    whole_data <- data.frame()
    for (m in (1:length(synthetic_data))) {
      whole_data <- rbind(whole_data, synthetic_data[[m]])
    }
    index <- sample(nrow(whole_data), 
                    nrow(synthetic_data[[1]]),
                    replace = F)
    synthetic_data_frame <- whole_data[index,]
  }
  
}







