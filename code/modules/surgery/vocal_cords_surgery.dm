/**
* Surgery to change the voice of TTS.
* Below are the operations for organics and IPC.
*/

//Surgery for organics
/datum/surgery/vocal_cords_surgery
	name = "Изменение голоса"
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
	name = "изменение голосовых связок"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(TOOL_SCALPEL = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)
	time = 6.4 SECONDS

/datum/surgery_step/tune_vocal_cords/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] изменять голосовые связки [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете изменять голосовые связки [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	..()

/datum/surgery_step/tune_vocal_cords/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.change_voice(user, TRUE)
	user.visible_message(
		span_notice("[user] изменя[pluralize_ru(user.gender, "ет", "ют")] голосовые связки [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы изменяете голосовые связки [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	return TRUE

/datum/surgery_step/tune_vocal_cords/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] голосовые связки [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] голосовые связки [target]!")
	)
	target.tts_seed = SStts.get_random_seed(target)
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE

//Surgery for IPC
/datum/surgery/vocal_cords_surgery/ipc
	name = "Изменение конфигурации микрофона"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/tune_vocal_cords/ipc,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery_step/tune_vocal_cords/ipc
	name = "калибровка микрофона"
	begin_sound = 'sound/items/taperecorder/taperecorder_open.ogg'
	end_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	allowed_tools = list(/obj/item/multitool = 100, /obj/item/screwdriver = 55, /obj/item/kitchen/knife = 20, TOOL_SCALPEL = 25)

/datum/surgery_step/tune_vocal_cords/ipc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] настраивать микрофон [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете настраивать микрофон [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	..()

/datum/surgery_step/tune_vocal_cords/ipc/end_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.change_voice(user, TRUE)
	user.visible_message(
		span_notice("[user] настраива[pluralize_ru(user.gender, "ет", "ют")] микрофон [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы настраиваете микрофон [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	return TRUE

/datum/surgery_step/tune_vocal_cords/ipc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/head/head = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] микрофон [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] микрофон [target]!")
	)
	target.tts_seed = SStts.get_random_seed(target)
	target.apply_damage(10, BRUTE, head, sharp = TRUE)
	return FALSE
