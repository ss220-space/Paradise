/datum/surgery/organ_extraction
	name = "Experimental Dissection"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/internal/extract_organ,
		/datum/surgery_step/internal/gland_insert,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_organic_bodypart = TRUE
	requires_bodypart = TRUE

/datum/surgery/organ_extraction/can_start(mob/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = user
	// You must either: Be of the abductor species, or contain an abductor implant
	if(!(isabductor(H) || (locate(/obj/item/implant/abductor) in H)))
		return FALSE

/datum/surgery_step/internal/extract_organ
	name = "remove heart"
	accept_hand = 1
	time = 32
	var/obj/item/organ/internal/IC = null

/datum/surgery_step/internal/extract_organ/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/organ/internal/organ as anything in target.internal_organs)
		// Allows for multiple subtypes of heart.
		if(istype(organ, /obj/item/organ/internal/heart))
			IC = organ
			break
	user.visible_message("[user] starts to remove [target]'s organs.",
		span_notice("You start to remove [target]'s organs..."),
		chat_message_type = MESSAGE_TYPE_COMBAT)
	..()

/datum/surgery_step/internal/extract_organ/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/carbon/human/AB = target
	if(IC)
		user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
		IC.remove(target, ORGAN_MANIPULATION_NOEFFECT)
		IC.forceMove(get_turf(target))
		user.put_in_hands(IC, ignore_anim = FALSE)
		return SURGERY_STEP_CONTINUE
	if(HAS_TRAIT(AB, TRAIT_NO_INTORGANS))
		user.visible_message(
			"[user] prepares [target]'s [target_zone] for further dissection!",
			span_notice("You prepare [target]'s [target_zone] for further dissection."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
		return SURGERY_STEP_CONTINUE
	else
		to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone]!</span>")
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/extract_organ/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user]'s hand slips, failing to extract anything!"),
		span_warning("Your hand slips, failing to extract anything!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
		)
	return SURGERY_STEP_RETRY

/datum/surgery_step/internal/gland_insert
	name = "insert gland"
	allowed_tools = list(/obj/item/organ/internal/heart/gland = 100)
	time = 32

/datum/surgery_step/internal/gland_insert/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"[user] starts to insert [tool] into [target].",
		span_notice("You start to insert [tool] into [target]..."),
		chat_message_type = MESSAGE_TYPE_COMBAT)
	..()

/datum/surgery_step/internal/gland_insert/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		"[user] inserts [tool] into [target].",
		span_notice("You insert [tool] into [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT)
	user.drop_from_active_hand()
	var/obj/item/organ/internal/heart/gland/gland = tool
	gland.insert(target, ORGAN_MANIPULATION_ABDUCTOR)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/gland_insert/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user]'s hand slips, failing to insert the gland!"),
		span_warning("Your hand slips, failing to insert the gland!"),
		chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_RETRY

//IPC Gland Surgery//

/datum/surgery/organ_extraction/synth
	name = "Experimental Robotic Dissection"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/internal/extract_organ/synth,
		/datum/surgery_step/internal/gland_insert,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_organic_bodypart = FALSE
	requires_bodypart = TRUE

/datum/surgery_step/internal/extract_organ/synth
	name = "remove cell"
