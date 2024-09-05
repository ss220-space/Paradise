/**
 * Internal air supply component
 */
/datum/component/internal_air_supply
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/gas_mixture/air_supply

/datum/component/internal_air_supply/Initialize()
	if(!isclothing(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/clothing/cl = parent
	var/mob/living/carbon/human/H = cl?.loc
	var/turf/T = H?.loc
	if(!T)
		return COMPONENT_INCOMPATIBLE

/datum/component/internal_air_supply/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AIR_SUPPLY_CREATE, PROC_REF(on_create))
	RegisterSignal(parent, COMSIG_AIR_SUPPLY_GET_BREATH, PROC_REF(on_get_breath))
	RegisterSignal(parent, COMSIG_AIR_SUPPLY_MIX, PROC_REF(on_mix))
	RegisterSignal(parent, COMSIG_AIR_SUPPLY_DELETE, PROC_REF(on_delete))



/datum/component/internal_air_supply/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_AIR_SUPPLY_CREATE, COMSIG_AIR_SUPPLY_GET_BREATH, COMSIG_AIR_SUPPLY_MIX, COMSIG_AIR_SUPPLY_DELETE))

/datum/component/internal_air_supply/proc/on_create()

/datum/component/internal_air_supply/proc/on_get_breath()
	return air_supply

/datum/component/internal_air_supply/proc/on_mix()

/datum/component/internal_air_supply/proc/on_delete()
