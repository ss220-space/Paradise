/datum/status_effect/magic_disguise
	id = "magic_disguise"
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/magic_disguise
	status_type = STATUS_EFFECT_REPLACE
	var/mob/living/disguise_mob
	var/datum/icon_snapshot/disguise

/datum/status_effect/magic_disguise/Destroy()
	disguise_mob = null
	QDEL_NULL(disguise)
	return ..()

/atom/movable/screen/alert/status_effect/magic_disguise
	name = "Disguised"
	desc = "You are disguised as a crewmember."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "chameleon_outfit"

/datum/status_effect/magic_disguise/on_creation(mob/living/new_owner, mob/living/_disguise_mob)
	disguise_mob = _disguise_mob
	return ..()

/datum/status_effect/magic_disguise/on_apply()
	. = ..()
	if(!ishuman(owner))
		return FALSE
	if(!disguise_mob)
		disguise_mob = select_disguise()
	if(ishuman(disguise_mob))
		create_disguise(disguise_mob)
	if(disguise)
		apply_disguise(owner)
	else
		to_chat(owner, span_warning("Your spell fails to find a disguise!"))
		return FALSE

	RegisterSignals(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_HUMAN_ATTACKED, COMSIG_SPECIES_HITBY), PROC_REF(remove_disguise))
	return TRUE

/datum/status_effect/magic_disguise/on_remove()
	owner.regenerate_icons()
	return ..()

/datum/status_effect/magic_disguise/proc/select_disguise()
	var/obj/machinery/door/airlock/airlock
	var/area/caster_area

	caster_area = get_area(owner)
	var/list/player_list = shuffle(GLOB.player_list)
	for(var/obj/machinery/door/airlock/tmp in view(owner))
		if(get_area(tmp) == caster_area && length(tmp.req_access)) //Ignore airlocks that arent in area or are public airlocks
			airlock = tmp
			break
	var/mob/living/carbon/human/selected_disguise

	for(var/mob/living/carbon/human/target as anything in player_list)
		if((ACCESS_CAPTAIN in target.get_access()) || (ACCESS_HOP in target.get_access()) || (ACCESS_CLOWN in target.get_access()))
			continue

		if(target.mind.offstation_role || target == owner)
			continue

		if(airlock && airlock.allowed(target))
			return target

		if(!selected_disguise)
			selected_disguise = target
	return selected_disguise

/datum/status_effect/magic_disguise/proc/create_disguise(mob/living/carbon/human/disguise_source)
	var/datum/icon_snapshot/temp = new
	temp.name = disguise_source.name
	temp.icon = disguise_source.icon
	temp.icon_state = disguise_source.icon_state
	temp.overlays = disguise_source.get_overlays_copy(list(HANDS_LAYER))
	disguise = temp

/datum/status_effect/magic_disguise/proc/apply_disguise(mob/living/carbon/human/human_target)
	human_target.name_override = disguise.name
	human_target.icon = disguise.icon
	human_target.icon_state = disguise.icon_state
	human_target.overlays = disguise.overlays
	human_target.update_held_items()
	human_target.sec_hud_set_ID()
	//SEND_SIGNAL(H, COMSIG_CARBON_REGENERATE_ICONS)
	to_chat(human_target, span_notice("You disguise yourself as [disguise.name]."))

/datum/status_effect/magic_disguise/proc/remove_disguise()
	SIGNAL_HANDLER  // COMSIG_MOB_APPLY_DAMAGE + COMSIG_HUMAN_ATTACKED + COMSIG_SPECIES_HITBY
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.name_override = null
	human_owner.regenerate_icons()
	human_owner.sec_hud_set_ID()
	qdel(src)
