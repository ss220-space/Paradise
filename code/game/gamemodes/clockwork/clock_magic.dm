/datum/action/innate/clockwork/clock_magic //Clockwork magic. Ain't powerful but still magic!
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. This magic isn't so powerful as clockwork slab."
	var/list/spells = list()
	var/channeling = FALSE

/datum/action/innate/clockwork/clock_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()
