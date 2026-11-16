/datum/chem_property/special
	abstract_type = /datum/chem_property/special

/datum/chem_property/special/radius
	name = PROPERTY_RADIUS

/datum/chem_property/special/radius/reset_reagent(datum/reagent/holder)
	holder.chemfiresupp = initial(holder.chemfiresupp)

	holder.rangefire = initial(holder.rangefire)
	holder.radiusmod = initial(holder.radiusmod)
	..()

/datum/chem_property/special/radius/update_reagent(datum/reagent/holder, level)
	holder.chemfiresupp = TRUE

	holder.rangefire = max(holder.rangefire, 0) // Initial starts at -1 for some (aka infinite range), need to reset that to 0 so that calc doesn't fuck up

	holder.rangefire += 1 * level
	holder.radiusmod += 0.1 * level
	..()

/datum/chem_property/special/intensity
	name = PROPERTY_INTENSITY

/datum/chem_property/special/intensity/reset_reagent(datum/reagent/holder)
	holder.chemfiresupp = initial(holder.chemfiresupp)

	holder.intensityfire = initial(holder.intensityfire)
	holder.intensitymod = initial(holder.intensitymod)
	..()

/datum/chem_property/special/intensity/update_reagent(datum/reagent/holder, level)
	holder.chemfiresupp = TRUE

	holder.intensityfire += 1 * level
	holder.intensitymod += 0.1 * level
	..()

/datum/chem_property/special/duration
	name = PROPERTY_DURATION

/datum/chem_property/special/duration/reset_reagent(datum/reagent/holder)
	holder.chemfiresupp = initial(holder.chemfiresupp)

	holder.durationfire = initial(holder.durationfire)
	holder.durationmod = initial(holder.durationmod)
	..()

/datum/chem_property/special/duration/update_reagent(datum/reagent/holder, level)
	holder.chemfiresupp = TRUE

	holder.durationfire += 1 * level
	holder.durationmod += 0.1 * level
	..()
