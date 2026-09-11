
/**
 * # Surgery Initiator
 *
 * Allows an item to start (or prematurely stop) a surgical operation.
 */
/datum/component/surgery_initiator
	/// The currently selected target that the user is proposing a surgery on
	var/datum/weakref/surgery_target_ref

	/// The last user, as a weakref
	var/datum/weakref/last_user_ref
	/// If present, this surgery TYPE will be attempted when the item is used.
	/// Useful for things like limb reattachments that don't need a scalpel.
	var/datum/surgery/forced_surgery

	/// If true, the initial step will be cancellable by just using the tool again. Should be FALSE for any tool that actually has a first surgery step.
	var/can_cancel_before_first = FALSE

	/// If true, can be used with a cautery in the off-hand to cancel a surgery.
	var/can_cancel = TRUE

	/// If true, can start surgery anywhere.
	/// Seeing as how we really don't support this (yet), it's much nicer to selectively enable this if we want it.
	var/can_start_anywhere = FALSE

	/// Bitfield for the types of surgeries that this can start.
	/// Note that in cases where organs are missing, this will be ignored.
	/// Also, note that for anything sharp, SURGERY_INITIATOR_ORGANIC should be set as well.
	var/valid_starting_types = SURGERY_INITIATOR_ORGANIC


/**
 * Attach a new surgery initiating element.
 *
 * Arguments:
 * * forced_surgery - (optional) the surgery that will be started when the parent is used on a mob.
 */
/datum/component/surgery_initiator/Initialize(forced_surgery)
	. = ..()
	if(!isitem(parent) && !isprojectile(parent))
		return COMPONENT_INCOMPATIBLE

	src.forced_surgery = forced_surgery

/datum/component/surgery_initiator/Destroy(force, silent)
	last_user_ref = null
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(initiate_surgery_moment))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS, PROC_REF(on_parent_sharpness_change))
	ADD_TRAIT(parent, TRAIT_SURGERY_INITIATOR, UNIQUE_TRAIT_SOURCE(src))

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_SHARPNESS)
	unregister_signals()
	REMOVE_TRAIT(parent, TRAIT_SURGERY_INITIATOR, UNIQUE_TRAIT_SOURCE(src))

/datum/component/surgery_initiator/proc/unregister_signals()
	var/mob/living/last_user = last_user_ref?.resolve()
	if(!isnull(last_user_ref))
		UnregisterSignal(last_user, COMSIG_MOB_SELECTED_ZONE_SET)

	var/mob/living/surgery_target = surgery_target_ref?.resolve()
	if(!isnull(surgery_target_ref))
		UnregisterSignal(surgery_target, COMSIG_MOB_SURGERY_STARTED)

/// Keep tabs on the attached item's sharpness.
/// This component gets added in atoms when they're made sharp as well.
/datum/component/surgery_initiator/proc/on_parent_sharpness_change(datum/source)
	SIGNAL_HANDLER  // COMSIG_ATOM_UPDATE_SHARPNESS
	var/obj/item/tool = source
	if(!tool.sharp)
		tool.RemoveElement(/datum/component/surgery_initiator)

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER	// COMSIG_ITEM_ATTACK
	if(!isliving(target))
		return
	var/mob/living/L = target
	if(!user.Adjacent(target))
		return
	if(user.a_intent != INTENT_HELP)
		return
	if(!can_start_anywhere && !on_operable_surface(L))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/organ/external/affected = C.get_organ(user.zone_selected)
		if(affected)
			if((affected.status & ORGAN_ROBOT) && !(valid_starting_types & SURGERY_INITIATOR_ROBOTIC))
				return
			if(!(affected.status & ORGAN_ROBOT) && !(valid_starting_types & SURGERY_INITIATOR_ORGANIC))
				return

	if(L.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		user.balloon_alert(user, "неподходящая цель!")
		return //no cult ghost surgery please
	INVOKE_ASYNC(src, PROC_REF(do_initiate_surgery_moment), target, user)
	// This signal is actually part of the attack chain, so it needs to return COMPONENT_CANCEL_ATTACK_CHAIN to stop it
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Meat and potatoes of starting surgery.
/datum/component/surgery_initiator/proc/do_initiate_surgery_moment(mob/living/target, mob/user)
	var/datum/surgery/current_surgery

	// Check if we've already got a surgery on our target zone
	for(var/i_one in target.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == user.zone_selected)
			current_surgery = surgeryloop
			break

	if(!isnull(current_surgery) && !current_surgery.step_in_progress)
		var/datum/surgery_step/current_step = current_surgery.get_surgery_step()
		if(current_step.try_op(user, target, user.zone_selected, parent, current_surgery) == SURGERY_INITIATE_SUCCESS)
			return
		if(istype(parent, /obj/item/scalpel/laser/manager/debug))
			return
		if(attempt_cancel_surgery(current_surgery, target, user))
			return

	if(!isnull(current_surgery) && current_surgery.step_in_progress)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	var/datum/surgery/procedure

	if(!length(available_surgeries))
		if(target.body_position == LYING_DOWN)
			user.balloon_alert(user, "нет доступных операций!")
		else
			user.balloon_alert(user, "цель не лежит!")
		return

	// if we have a surgery that should be performed regardless with this item,
	// make sure it's available to be done
	if(forced_surgery)
		for(var/datum/surgery/S in available_surgeries)
			if(istype(S, forced_surgery))
				procedure = S
				break
		try_choose_surgery(user, target, procedure)
		return

	unregister_signals()

	last_user_ref = WEAKREF(user)
	surgery_target_ref = WEAKREF(target)

	RegisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET, PROC_REF(on_set_selected_zone))
	RegisterSignal(target, COMSIG_MOB_SURGERY_STARTED, PROC_REF(on_mob_surgery_started))

	ui_interact(user)

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()
	for(var/datum/surgery/surgery in GLOB.surgeries_list)
		if(surgery.abstract && !istype(surgery, forced_surgery))  // no choosing abstract surgeries, though they can be forced
			continue
		if(!is_type_in_list(target, surgery.target_mobtypes))
			continue
		if(length(surgery.target_speciestypes) && !is_type_in_list(target.dna.species, surgery.target_speciestypes))
			continue
		if(length(surgery.restricted_speciestypes) && is_type_in_list(target.dna.species, surgery.restricted_speciestypes))
			continue
		if(!target.can_run_surgery(surgery, user))
			continue

		available_surgeries |= surgery

	return available_surgeries

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected
	var/obj/item/organ/external/affected_organ = patient.get_organ(user.zone_selected)
	var/obj/item/tool = parent

	/// We haven't even started yet. Any surgery can be cancelled at this point.
	if(the_surgery.step_number == 1)
		patient.surgeries -= the_surgery
		if(affected_organ)
			user.visible_message(
				span_notice("[user] прерыва[PLUR_ET_YUT(user)] операцию на [affected_organ.declent_ru(PREPOSITIONAL)] [patient], используя [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы прерываете операцию на [affected_organ.declent_ru(PREPOSITIONAL)] [patient], используя [tool.declent_ru(ACCUSATIVE)].")
			)
		else
			user.visible_message(
				span_notice("[user] прерыва[PLUR_ET_YUT(user)] операцию на [parse_zone(selected_zone)] [patient], используя [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы прерываете операцию на [parse_zone(selected_zone)] [patient], используя [tool.declent_ru(ACCUSATIVE)].")
			)

		qdel(the_surgery)
		return TRUE

	if(!the_surgery.can_cancel)
		return

	// Don't make a forced surgery implement cancel a surgery.
	if(istype(the_surgery, forced_surgery))
		return

	var/obj/item/close_tool
	var/obj/item/other_hand = user.get_inactive_hand()

	var/is_robotic = !the_surgery.requires_organic_bodypart
	var/datum/surgery_step/chosen_close_step
	var/skip_surgery = FALSE  // if true, don't even run an operation, just end the surgery.

	if(!the_surgery.requires_bodypart)
		// special behavior here; if it doesn't require a bodypart just check if there's a limb there or not.
		// this is a little bit gross and I do apologize
		if(iscarbon(patient))
			var/mob/living/carbon/C = patient
			var/obj/item/organ/external/affected = C.get_organ(user.zone_selected)
			if(!affected)
				skip_surgery = TRUE

		else
			// uh there's no reason this should be hit but let's be safe LOL
			skip_surgery = TRUE

	if(!skip_surgery)
		if(is_robotic)
			chosen_close_step = new /datum/surgery_step/robotics/external/close_hatch/premature()
		else
			chosen_close_step = new /datum/surgery_step/generic/cauterize/premature()

	if(skip_surgery)
		close_tool = user.get_active_hand()  // sure, just something so that it isn't null
	else if(isrobot(user))
		if(!is_robotic)
			// borgs need to be able to finish surgeries with just the laser scalpel, no special checks here.
			close_tool = parent
		else
			close_tool = locate(/obj/item/crowbar) in user.get_all_slots()
			if(!close_tool)
				user.balloon_alert(user, "операция не завершена!")
				to_chat(user, span_warning("Для завершения операции нужно держать поддевающий инструмент в неактивной руке!"))
				return TRUE

	else if(other_hand)
		for(var/key in chosen_close_step.allowed_tools)
			if(ispath(key) && istype(other_hand, key) || other_hand.tool_behaviour == key)
				close_tool = other_hand
				break

	if(!close_tool)
		user.balloon_alert(user, "операция не завершена!")
		to_chat(user, span_warning("Для завершения операции нужно держать [is_robotic ? "поддевающий": "прижигающий"] инструмент в неактивной руке!"))
		return TRUE

	if(skip_surgery || chosen_close_step.try_op(user, patient, selected_zone, close_tool, the_surgery) == SURGERY_INITIATE_SUCCESS)
		// logging in case people wonder why they're cut up inside
		log_attack(user, patient, "Prematurely finished \a [the_surgery] surgery.")
		qdel(chosen_close_step)
		patient.surgeries -= the_surgery
		qdel(the_surgery)

	// always return TRUE here so we don't continue the surgery chain and try to start a new surgery with our tool.
	return TRUE

/datum/component/surgery_initiator/proc/on_mob_surgery_started(mob/source, datum/surgery/surgery, surgery_location)
	SIGNAL_HANDLER

	var/mob/living/last_user = last_user_ref.resolve()

	if(surgery_location != last_user.zone_selected)
		return

	if(!isnull(last_user) && source != last_user)
		source.balloon_alert(last_user, "someone else started a surgery!")
	SStgui.close_uis(src)

/datum/component/surgery_initiator/proc/can_start_surgery(mob/user, mob/living/target)
	if(!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if(!(parent in user))
		user.balloon_alert(user, "инструмент не в активной руке!")
		return FALSE

	// While we were choosing, another surgery was started at the same location
	for(var/datum/surgery/surgery in target.surgeries)
		if(surgery.location == user.zone_selected)
			user.balloon_alert(user, "выполняется другая операция!")
			return FALSE

	return TRUE

/datum/component/surgery_initiator/proc/try_choose_surgery(mob/user, mob/living/target, datum/surgery/surgery)
	if(!can_start_surgery(user, target))
		return

	var/obj/item/organ/affecting_limb

	var/selected_zone = user.zone_selected

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		affecting_limb = carbon_target.get_organ(check_zone(selected_zone))

	if(surgery.requires_bodypart == isnull(affecting_limb))
		if(surgery.requires_bodypart)
			user.balloon_alert(user, "часть тела отсутствует!")
		else
			user.balloon_alert(user, "часть тела присутствует!")

		return

	if(!isnull(affecting_limb) && (surgery.is_organ_noncompatible(affecting_limb)))
		user.balloon_alert(user, "неподходящая часть тела!")
		return

	if(surgery.lying_required && !on_operable_surface(target))
		user.balloon_alert(user, "цель не лежит!")
		return

	if(target == user && !surgery.self_operable)
		user.balloon_alert(user, "самооперация невозможна!")
		return

	if(!surgery.can_start(user, target))
		user.balloon_alert(user, "невозможно начать операцию!")
		return

	if(surgery_needs_exposure(surgery, target, selected_zone))
		user.balloon_alert(user, "часть тела закрыта одеждой!")
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)

	show_starting_message(user, target, procedure)

	log_attack(user, target, "operated on (OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target, selected_zone)
	return !surgery.ignore_clothes && !get_location_accessible(target, selected_zone)

/// Handle to allow for easily overriding the message shown
/datum/component/surgery_initiator/proc/show_starting_message(mob/user, mob/living/target, datum/surgery/procedure)
	var/selected_zone = user.zone_selected
	var/obj/item/organ/external/affected_organ = target.get_organ(user.zone_selected)
	var/obj/item/tool = parent

	if(affected_organ)
		user.visible_message(
			span_notice("[user] готов[PLUR_IT_YAT(user)]ся начать операцию на [affected_organ.declent_ru(PREPOSITIONAL)] [target], удерживая [tool.declent_ru(ACCUSATIVE)] в руке."),
			span_notice("Вы готовитесь начать операцию на [affected_organ.declent_ru(PREPOSITIONAL)] [target], удерживая [tool.declent_ru(ACCUSATIVE)] в руке."),
		)
	else
		user.visible_message(
			span_notice("[user] готов[PLUR_IT_YAT(user)]ся начать операцию на [parse_zone(selected_zone)] [target], удерживая [tool.declent_ru(ACCUSATIVE)] в руке."),
			span_notice("Вы готовитесь начать операцию на [parse_zone(selected_zone)] [target], удерживая [tool.declent_ru(ACCUSATIVE)] в руке."),
		)

/datum/component/surgery_initiator/proc/on_set_selected_zone(mob/source, new_zone)
	ui_interact(source)

/datum/component/surgery_initiator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SurgeryInitiator")
		ui.open()

/datum/component/surgery_initiator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return .

	var/mob/user = usr
	var/mob/living/surgery_target = surgery_target_ref.resolve()

	if(isnull(surgery_target))
		return TRUE

	switch(action)
		if("change_zone")
			var/zone = params["new_zone"]
			if(!(zone in list(
				BODY_ZONE_HEAD,
				BODY_ZONE_CHEST,
				BODY_ZONE_L_ARM,
				BODY_ZONE_PRECISE_L_HAND,
				BODY_ZONE_R_ARM,
				BODY_ZONE_PRECISE_R_HAND,
				BODY_ZONE_L_LEG,
				BODY_ZONE_PRECISE_L_FOOT,
				BODY_ZONE_R_LEG,
				BODY_ZONE_PRECISE_R_FOOT,
				BODY_ZONE_PRECISE_EYES,
				BODY_ZONE_PRECISE_MOUTH,
				BODY_ZONE_PRECISE_GROIN,
				BODY_ZONE_WING,
				BODY_ZONE_TAIL,
			)))
				return TRUE

			var/atom/movable/screen/zone_sel/zone_selector = user.hud_used?.zone_select
			zone_selector?.set_selected_zone(zone, user)

			return TRUE
		if("start_surgery")
			for(var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
				if(surgery.name == params["surgery_name"])
					try_choose_surgery(user, surgery_target, surgery)
					return TRUE

/datum/component/surgery_initiator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/body_zones),
	)

/datum/component/surgery_initiator/ui_data(mob/user)
	var/mob/living/surgery_target = surgery_target_ref.resolve()

	var/list/surgeries = list()
	if(!isnull(surgery_target))
		for(var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
			var/list/surgery_info = list(
				"name" = surgery.name,
			)

			if(surgery_needs_exposure(surgery, surgery_target))
				surgery_info["blocked"] = TRUE

			surgeries += list(surgery_info)

	return list(
		"selected_zone" = user.zone_selected,
		"target_name" = surgery_target?.name,
		"surgeries" = surgeries,
	)

/datum/component/surgery_initiator/ui_close(mob/user)
	unregister_signals()
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/ui_status(mob/user, datum/ui_state/state)
	var/obj/item/item_parent = parent
	if(user != item_parent.loc)
		return UI_CLOSE

	var/mob/living/surgery_target = surgery_target_ref?.resolve()
	if(isnull(surgery_target))
		return UI_CLOSE

	if(!can_start_surgery(user, surgery_target))
		return UI_CLOSE

	return ..()

/datum/component/surgery_initiator/limb
	can_cancel = FALSE  // don't let a leg cancel a surgery

/datum/component/surgery_initiator/limb/initiate_surgery_moment(datum/source, atom/target, mob/user)
	var/old_forced = forced_surgery
	var/old_anywhere = can_start_anywhere
	if(target == user && ismachineperson(user) && isexternalorgan(source))
		forced_surgery = /datum/surgery/attach_robotic_limb/self_attach_ipc
		can_start_anywhere = TRUE
	. = ..()
	forced_surgery = old_forced
	can_start_anywhere = old_anywhere

/datum/component/surgery_initiator/robo
	valid_starting_types = SURGERY_INITIATOR_ROBOTIC

/datum/component/surgery_initiator/robo/sharp
	valid_starting_types = SURGERY_INITIATOR_ORGANIC | SURGERY_INITIATOR_ROBOTIC
