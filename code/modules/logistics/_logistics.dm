GLOBAL_LIST_EMPTY(logistics_nets)

/datum/element/logistics_compatible
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/logistics_compatible/Attach(datum/target)
	. = ..()
	if(!ismachinery(target))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_LOGISTICS_COMPATIBLE, ELEMENT_TRAIT(type))

/datum/element/logistics_compatible/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_LOGISTICS_COMPATIBLE, ELEMENT_TRAIT(type))
	return ..()
