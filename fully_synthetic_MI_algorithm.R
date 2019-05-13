# Introduction ------------------------------------------------------------

# It is coded such, that partial AND fully synthetic MI is possible.
# The trees are chosen such like in JASA. The pruning parameters
# are sometimes different. In the categorial case rpart instead of tree
# is applied.
# The sequence is not discussed. The first variable is always the reference.
# Sequencing is like occurance in the data frame.
# The algorithm is programmed as general function, so application is universal.
# Variable should be coded as factor or numeric (ordered factor suits, too).


# Define enviroment -------------------------------------------------------
rm(list = ls())
setwd("")



# Algorithm as function ---------------------------------------------------

# a dataframe (df) and number of repetitions (repetitions) as input
syntheis <- function(df, repetitions){
  
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
                       split = "deviance" , mindev = 0.0001, 
                       control = tree.control(nobs = nrow(df), mincut = 5),
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
                        control = rpart.control(minsplit = 5, minbucket = 10))
        
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
  }
  
  # only the list of the R dataframes which are sampled with synthesis
  # should be returned
  return(synthetic_data)
  
}









