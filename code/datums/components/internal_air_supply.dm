/**
 * Internal air supply component
 */
/datum/component/internal_air_supply
	var/mob/living/carbon/human/owner
	var/datum/gas_mixture/air_supply
	var/max_volume


/datum/component/internal_air_supply/Initialize(max_volume = 100)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	src.max_volume = max_volume
	owner = parent
	air_supply = get_air_from_loc()
	air_supply.volume = max_volume


/datum/component/internal_air_supply/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HUMAN_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_CARBON_BREATH, PROC_REF(on_breath))
	RegisterSignal(parent, COMSIG_HUMAN_HANDLE_ENVIROMENT, PROC_REF(on_handle_enviroment))


/datum/component/internal_air_supply/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_HUMAN_ITEM_DROPPED, COMSIG_CARBON_BREATH))


/datum/component/internal_air_supply/proc/on_drop(mob/user, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_CLOTH_OUTER && slot != ITEM_SLOT_HEAD)
		return

	return_air_to_loc()
	qdel(src)

/datum/component/internal_air_supply/proc/check_integrity()

	if(!isclothing(owner.wear_suit) || !isclothing(owner.head))
		return FALSE

	var/obj/item/clothing/suit = owner.wear_suit
	var/obj/item/clothing/helmet = owner.head

	if((suit.clothing_flags & BLOCK_GASES) && (helmet.clothing_flags & BLOCK_GASES))
		return TRUE
	return FALSE


/datum/component/internal_air_supply/proc/get_air_from_loc()
	var/datum/gas_mixture/environment = owner.loc?.return_air()
	if(environment)
		return owner.loc?.remove_air(environment.total_moles()*max_volume/CELL_VOLUME)
	else
		return new /datum/gas_mixture


/datum/component/internal_air_supply/proc/return_air_to_loc()
	if(owner.loc)
		owner.loc.assume_air(air_supply)


/datum/component/internal_air_supply/proc/on_breath()
	SIGNAL_HANDLER

	var/datum/gas_mixture/breath = new
	var/percentage_from_internal = 0
	var/percentage_from_loc = 1

	if(owner.internal)
		if(owner.internal.loc != owner || !owner.has_airtight_items())
			owner.internal = null
			owner.update_action_buttons_icon()
			return

		percentage_from_internal = owner.has_airtight_items()
		percentage_from_loc = 1 - percentage_from_internal
		breath.merge(owner.internal.remove_air_volume(BREATH_VOLUME * percentage_from_internal))

	var/moles_needed = air_supply.return_pressure() * BREATH_VOLUME * percentage_from_loc / (R_IDEAL_GAS_EQUATION * air_supply.temperature)	//please kill me
	breath.merge(air_supply.remove(moles_needed))
	owner.check_breath(breath)
	air_supply.merge(breath)

	return COMPONENT_BLOCK_BREATH_FROM_INTERNAL_SUPPLY

/datum/component/internal_air_supply/proc/on_handle_enviroment()
	SIGNAL_HANDLER

	owner.handle_environment(air_supply, send_signal = FALSE, ignore_protection = TRUE)

	return COMPONENT_BLOCK_HANLE_INTERNAL_ENVIROMENT
