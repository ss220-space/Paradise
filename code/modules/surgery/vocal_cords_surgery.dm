/**
* Surgery to change the voice of TTS.
* Below are the operations for organics and IPC.
*/

//Surgery for organics
/datum/surgery/vocal_cords_surgery
	name = "Vocal Cords Tuning Surgery"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/tune_vocal_cords,
		/datum/surgery_step/generic/cauterize
	)

	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)

/datum/surgery/vocal_cords_surgery/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/H = target
	if(requires_organic_bodypart && !H.check_has_mouth())
		return FALSE

/datum/surgery_step/tune_vocal_cords
	name = "tune vocal cords"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(TOOL_SCALPEL = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)
	time = 6.4 SECONDS
	var/target_vocal = "vocal cords"

/datum/surgery_step/tune_vocal_cords/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to tune [target]'s vocals.", span_notice("You begin to tune [target]'s vocals..."))
	..()

/datum/surgery_step/tune_vocal_cords/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.change_voice(user, TRUE)
	user.visible_message("[user] tunes [target]'s vocals completely!", span_notice("You tune [target]'s vocals completely."))
	return TRUE

/datum/surgery_step/tune_vocal_cords/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message(span_warning("[user]'s hand slips, tearing [target_vocal] in [target]'s throat with [tool]!"), \
						 span_warning("Your hand slips, tearing [target_vocal] in [target]'s throat with [tool]!"))
	target.tts_seed = SStts.get_random_seed(target)
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE

//Surgery for IPC
/datum/surgery/vocal_cords_surgery/ipc
	name = "Microphone Setup Operation"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/tune_vocal_cords/ipc,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery_step/tune_vocal_cords/ipc
	name = "microphone setup"
	begin_sound = 'sound/items/taperecorder/taperecorder_open.ogg'
	end_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	allowed_tools = list(/obj/item/multitool = 100, /obj/item/screwdriver = 55, /obj/item/kitchen/knife = 20, TOOL_SCALPEL = 25)
	target_vocal = "microphone"
