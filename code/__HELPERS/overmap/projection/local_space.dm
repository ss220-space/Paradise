/proc/regions_overlap(list/first, list/second)
	if(!first || !second)
		return FALSE
	return first[1] <= second[3] && second[1] <= first[3] && first[2] <= second[4] && second[2] <= first[4]
