*WARNING: THIS BRANCH MUST NOT BE MERGED TO MASTER
This is because it is a additional research project in order to evaluate
the fully synthetic MI algorithm in comparison to the R-package simPop.*
---


# Content:

- The file "synthesis.RData" is the saved fully synthetic MI algorithm,
which is constructed and trained like in the folder 
"algorithm_contruction".
For a pseudo code of the fully synthetic MI algorithm please see
the "README.md" in master.

- With the file "generate_census.R" a fictive census based on the
eusilc data is created. This is due to the reason that the fully
synthetic MI algorithm cannot handle weights yet. So we seeked for
a procedure to compare census data with the simPop results.
We create the fictive census "df_census.RData".

- The file "hands_on_simPop.R" is a first trial to find a workaround 
to construct population data with simPop. It results the
dataframe "data_syn_simPop.RData". This dataframe must not be used
for evaluation, since it is not the optimal result.

- Therefore we compare all available methods in simPop in order
to find the most suited combination in terms of univariate 
properties in our sample. We generate the dataframe
"data_syn_simPop_best.RData". For that we use the file
"simPop_best_method.R". The respective outputs can be found in 
the folder "output".

- We apply the function "apply_MI.R" to create the dataframes
"data_syn_MI.RData" and "data_syn_MI_conds.RData". 
This is the fully synthetic MI algortihms without and with
additional conditions.

- At least we apply the script "result_evaluation.R" to generate
the outputs, which can be found in the equally called folder.
The file "EvalDataUtility.R" generates numerical figures.

- The whole research process is stated in the presentation
"fully_synthetic_MI_vs_simPop.pdf".
