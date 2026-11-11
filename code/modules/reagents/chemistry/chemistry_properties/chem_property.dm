/datum/chem_property
	abstract_type = /datum/chem_property
	var/name
	var/max_level = 999

/datum/chem_property/proc/reset_reagent(datum/reagent/holder)
	return

/datum/chem_property/proc/update_reagent(datum/reagent/holder, level)
	return

/datum/chem_property/proc/post_update_reagent(datum/reagent/holder, level)
	return
