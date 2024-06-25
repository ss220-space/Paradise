/**
 * Internal air supply component
 */
/datum/component/internal_air_supply
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/gas_mixture/air_supply

/datum/component/internal_air_supply/Initialize(damage_increase = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.damage_increase = damage_increase

/datum/component/internal_air_supply/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AIR_SUPPLY_CREATE, PROC_REF(on_create))

/datum/component/internal_air_supply/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_AIR_SUPPLY_CREATE))
