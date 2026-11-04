//Lobotomy: permanently wipes the patient's skills.
/datum/surgery/lobotomy
	name = "Лоботомия"
	desc = "Хирургическое вмешательство, полностью лишающее пациента навыков."
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/lobotomy,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone/mend_skull,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize,
	)
	possible_locs = list(BODY_ZONE_HEAD)
	restricted_speciestypes = list(/datum/species/plasmaman)

/datum/surgery/lobotomy/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/human/human_target = target
	if(!human_target.mind || human_target.mind.lobotomized)
		return FALSE
	if(!human_target.get_int_organ(/obj/item/organ/internal/brain))
		return FALSE
	var/obj/item/organ/external/head/head = human_target.get_organ(BODY_ZONE_HEAD)
	if(!head || !head.encased || head.cannot_break)
		return FALSE
	return TRUE

/datum/surgery_step/lobotomy
	name = "проведение лоботомии"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 75,
		/obj/item/shard = 40,
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 6.4 SECONDS

/datum/surgery_step/lobotomy/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] проводить лоботомию [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете проводить лоботомию [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете, как что-то проникает глубоко в ваш мозг!")
	return ..()

/datum/surgery_step/lobotomy/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/mind/target_mind = target.mind
	if(target_mind)
		target_mind.lobotomize()
	to_chat(target, span_userdanger("Вы чувствуете, как ваши мысли и знания угасают..."))
	user.visible_message(
		span_notice("[user] заверша[PLUR_ET_YUT(user)] лоботомию [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы завершаете лоботомию [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/lobotomy/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, повреждая мозг [target] [tool.declent_ru(INSTRUMENTAL)]!"),
		span_warning("Вы дёргаете рукой, повреждая мозг [target] [tool.declent_ru(INSTRUMENTAL)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, def_zone = affected, sharp = TRUE)
	return SURGERY_STEP_RETRY
