##### Evaluate data utility of fully synthetic data 
## FIRST DRAFT: STILL SUBJECT TO CHANGE

# A plethora of metrics are available and widely used for the task of comparing datasets. BUT - 
# not all of these work properly on fully synthetic datasets which is why the following shows
# a small selection of functioning ones. 



####### Function for Comparing Datasets with lin Reg estimand CI Intervals ########
#(Interval Overlap Measure)
IOM <- function(data1, data2, model, UpperLowerCi) {
  if(missing(UpperLowerCi)){
    UpperLowerCi <- c(0.025, 0.975)
  }
  indepVars <-  unlist(strsplit(toString(model[3]), " " ))
  indepVars <-  indepVars[seq(1, length(indepVars), 2)]
  IOMscore <- vector()
  
  for(i in 1:length(indepVars)) {
    
    k <- i+1
    
    ci1 <- confint(lm(model, data1))[k,]
    ci2 <- confint(lm(model, data2))[k,]
    
    intersection <- abs(min(c(ci1[2], ci2[2]))-max(c(ci1[1], ci2[1])))
    IOMscore[i] <- round(intersection/(2*(ci1[2]-ci1[1]))+intersection/(2*(ci2[2]-ci2[1])),3)
    
  }
  names(IOMscore) <- indepVars
  return(IOMscore)
} 

IOM(data1 = data_syn_simPop_best,data2 = df_census,model =  household_inc ~ age^2+gender)



##### Function if CIs already exsist ####
CIoverlap <- function(ci1,ci2) {
  intersection <- min(c(ci1[2], ci2[2]))-max(c(ci1[1], ci2[1]))
  return(Iscore <-  intersection/(2*(ci1[2]-ci1[1]))+intersection/(2*(ci2[2]-ci2[1])))
}


### fix order of simPop Datasets (important for ILs Scores)
data_syn_simPop <- data_syn_simPop[order(data_syn_simPop$household_id)]
############## IL1s ##########

ilOneScore <- function(varOrg, varSyn) {
  sdOrg <- sd(varOrg)
  return((1/length(varOrg))* sum(abs(varOrg-varSyn)/(sqrt(2)*sdOrg)))
}

ilOneScore(df_census$household_inc, data_syn_MI_conds$household_inc)

##################### Compare Catigorical Vars #######
mosa <-  cbind(table(df_census$citizenship), table(data_syn_simPop$citizenship), table(data_syn_MI$citizenship))
colnames(mosa) <- c("TrueData", "simPop", "synMI")
mosaicplot(t(mosa), color = 23:26, main = "Comparison of Distr. of Citizenship")

#for correlations with catigorical vs. catigorical | catigorical vs. continuous see http://tiny.cc/nzf18y

#### use discriptive statistics first #####
summary(df_census);summary(data_syn_MI)

require("ggplot2")
plotCompare <- data.frame(densities =c(df_census$household_inc, data_syn_MI$household_inc, data_syn_simPop$household_inc),
                          lines = rep(c("Gold", "synMI", "simPop"), each = length(df_census$household_inc)))
ggplot(plotCompare, aes(x = densities, fill = lines)) + geom_density(alpha = 0.5)



########## sources:                       #######
##https://pdfs.semanticscholar.org/b7eb/dc80265bd9d8d1a405e40725e6a9c33663bf.pdf
#https://pdfs.semanticscholar.org/d401/fc73721e97cd22d35c0cc3becff631a0201b.pdf
#https://sdcpractice.readthedocs.io/en/latest/utility.html
#http://www.dwbproject.org/export/sites/default/events/doc/edaf2_files/dwb_edaf2_s3-parallel-b_1-sdc-synthetic-data-intro_drechsler.pdf
#https://www.census.gov/srd/papers/pdf/rrs2002-01.pdf


