//////////////////////////////////////////////////////////////////
//					IMPLANT REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/implant_removal
	name = "Implant Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_organic_bodypart = TRUE
	restricted_speciestypes = list(/datum/species/kidan, /datum/species/wryn, /datum/species/plasmaman)

/datum/surgery/implant_removal/plasmamans
	name = "Implant Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ/plasma,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/generic/cauterize
	)
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null


/datum/surgery/implant_removal/insect
	name = "Insectoid Implant Removal"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	target_speciestypes = list(/datum/species/kidan, /datum/species/wryn)
	restricted_speciestypes = null

/datum/surgery/implant_removal/synth
	name = "Implant Removal"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/robotics/repair_limb,
		/datum/surgery_step/extract_implant/synth,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery_step/extract_implant
	name = "extract implant"
	begin_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 65)
	time = 6.4 SECONDS
	repeatable = TRUE
	var/obj/item/implant/I = null
	var/max_times_to_check = 5

/datum/surgery_step/extract_implant/synth
	allowed_tools = list(/obj/item/multitool = 100, TOOL_HEMOSTAT = 65, TOOL_CROWBAR = 50)

/datum/surgery_step/extract_implant/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)


	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(times_repeated >= max_times_to_check)
		user.visible_message(
				span_notice("[user] seems to have had enough and stops checking inside [target]."),
				span_notice("There doesn't seem to be anything inside, you've checked enough times."),
				chat_message_type = MESSAGE_TYPE_COMBAT
		)
		return SURGERY_BEGINSTEP_SKIP

	I = locate(/obj/item/implant) in target
	user.visible_message(
		"[user] starts poking around inside [target]'s [affected.name] with \the [tool].",
		"You start poking around inside [target]'s [affected.name] with \the [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("The pain in your [affected.name] is living hell!")
	return ..()

/datum/surgery_step/extract_implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] grips onto [target]'s [affected.name] by mistake, tearing it!"),
		span_warning("You think you've found something, but you've grabbed onto [target]'s [affected.name] instead, damaging it!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/extract_implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/implant) in target
	if(I && prob(80)) //implant removal only works on the chest.
		user.visible_message(
			span_notice("[user] takes something out of [target]'s [affected.name] with \the [tool]."),
			span_notice("You take \an [I] out of [target]'s [affected.name]s with \the [tool]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		I.removed(target)

		var/obj/item/implantcase/case

		if(istype(user.get_item_by_slot(ITEM_SLOT_HAND_LEFT), /obj/item/implantcase))
			case = user.get_item_by_slot(ITEM_SLOT_HAND_LEFT)
		else if(istype(user.get_item_by_slot(ITEM_SLOT_HAND_RIGHT), /obj/item/implantcase))
			case = user.get_item_by_slot(ITEM_SLOT_HAND_RIGHT)
		else
			case = locate(/obj/item/implantcase) in get_turf(target)

		if(case && !case.imp)
			case.imp = I
			I.forceMove(case)
			case.update_icon()
			user.visible_message("[user] places [I] into [case]!", span_notice("You place [I] into [case]."))
		else
			qdel(I)
	else
		user.visible_message(
			span_notice("[user] could not find anything inside [target]'s [affected.name], and pulls \the [tool] out."),
			span_notice("You could not find anything inside [target]'s [affected.name]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	return SURGERY_STEP_CONTINUE
