/datum/chem_property/positive
	abstract_type = /datum/chem_property/positive

/datum/chem_property/positive/fire
	abstract_type = /datum/chem_property/positive/fire
	var/intensitymod_per_level = 0
	var/radiusmod_per_level = 0
	var/durationmod_per_level = 0

	var/intensity_per_level = 0
	var/range_per_level = 0
	var/duration_per_level = 0

/datum/chem_property/positive/fire/reset_reagent(datum/reagent/holder)
	holder.chemfiresupp = initial(holder.chemfiresupp)
	holder.radiusmod = initial(holder.radiusmod)
	holder.durationmod = initial(holder.durationmod)
	holder.intensitymod = initial(holder.intensitymod)

	holder.rangefire = initial(holder.rangefire)
	holder.durationfire = initial(holder.durationfire)
	holder.intensityfire = initial(holder.intensityfire)

	return ..()

/datum/chem_property/positive/fire/update_reagent(datum/reagent/holder, level)
	holder.chemfiresupp = TRUE

	holder.radiusmod += radiusmod_per_level * level
	holder.durationmod += durationmod_per_level * level
	holder.intensitymod += intensitymod_per_level * level

	holder.rangefire += range_per_level * level
	holder.durationfire += duration_per_level * level
	holder.intensityfire += intensity_per_level * level

	return ..()

/datum/chem_property/positive/fire/post_update_reagent(datum/reagent/holder, level)
	holder.rangefire = max(holder.rangefire, 1)
	holder.durationfire = max(holder.durationfire, 1)
	holder.intensityfire = max(holder.intensityfire, 1)

	if(holder.intensityfire >= 50)
		holder.burncolor = "#ffffff"
	else
		holder.burncolor = holder.color

/datum/chem_property/positive/fire/fueling
	name = PROPERTY_FUELING
	intensity_per_level = -3
	duration_per_level = 7
	intensitymod_per_level = -0.1
	durationmod_per_level = 0.2
	radiusmod_per_level = 0.01

/datum/chem_property/positive/fire/oxidizing
	name = PROPERTY_OXIDIZING
	intensity_per_level = 7
	duration_per_level = -4

	intensitymod_per_level = 0.2
	durationmod_per_level = -0.1
	radiusmod_per_level = -0.01

/datum/chem_property/positive/fire/flowing
	name = PROPERTY_FLOWING
	range_per_level = 2
	intensitymod_per_level = -0.05
	radiusmod_per_level = 0.05
	durationmod_per_level = -0.05

/datum/chem_property/positive/firepenetrating
	name = PROPERTY_FIRE_PENETRATING
	max_level = 1

/datum/chem_property/positive/firepenetrating/reset_reagent(datum/reagent/holder)
	holder.fire_penetrating = initial(holder.fire_penetrating)
	..()

/datum/chem_property/positive/firepenetrating/update_reagent(datum/reagent/holder, level)
	holder.fire_penetrating = TRUE
	..()
