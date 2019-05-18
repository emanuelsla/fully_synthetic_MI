# fully_synthetic_MI

pseudo code for algorithm fully synthetic MI

define function synthesis with inputs: dataset, desired repetitions, condition vector, list option {
	create storage for results in list structure
	for all desired repetitions {
		start with second variable
		while variable position  <= variables in dataset {
			if numeric variable {
				run numeric regression tree
				insert buckets
				for all buckets {
					run a bootstrap
					save temporary results
				}
			} else if factor variable {
				run factor regression tree
				insert buckets
				for all buckets {
					run a bootstrap
					save temporary results
				}	
			} else return error variable coding
			save bootstrapped variable in dataset
			go to next variable
		}
		if no conditions {
			next
		} else {for all conditions {
				apply them to recent dataframe
			}
		}
	}
	if list structre {
		return synthetic data in list structure
	else return one dataframe as equal samples from all dataframes
}
