# fully_synthetic_MI

pseudo code for algorithm fully synthetic MI

define function synthesis with inputs dataset and desired repetitions {
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
	}
	return synthetic data in list structure
}

apply function synthesis on selected dataset with desired repetitions
draw equally sized samples from all repetitions until original length of dataset is reached
	and assign result to new synthesized dataset
