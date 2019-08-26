# Fully synthetic Multiple Imputation

This method goes back to Drechsler and Reiter 2010 "Sampling with Synthesis: A New Approach for Releasing Public Use Census Microdata".

It originally covers partially synthetic Multiple Imputation, but was developed to an fully synthetic approach. 

It iterates over the whole dataset and uses the concept of Multiple Imputation to generate values, which match the properties of the original data but do not contain sensitive information.

This branch includes
* the algorithm "fully_synthetic_MI_algorithm.R",
* a pseudo code "pseudo_code_fully_synthetic_MI.txt" and
* the self-constructed, ALLBUS based training data "data_census.RData"

It is implemented with R.

