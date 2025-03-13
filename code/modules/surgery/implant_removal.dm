//////////////////////////////////////////////////////////////////
//					IMPLANT REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery/implant_removal
	name = "Извлечение импланта"
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
	name = "Извлечение импланта (Плазмолюд)"
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
	name = "Извлечение импланта (Инсектоид)"
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
	name = "Извлечение импланта (Синтетик)"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/robotics/repair_limb,
		/datum/surgery_step/extract_implant/synth,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery_step/extract_implant
	name = "извлечь имплант"
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
				span_notice("[user] переста[pluralize_ru(user.gender, "ёт", "ют")] искать инородные тела в теле [target]."),
				span_notice("Вы перестаёте искать инородные тела в теле [target], там совершенно точно ничего нет."),
				chat_message_type = MESSAGE_TYPE_COMBAT
		)
		return SURGERY_BEGINSTEP_SKIP

	I = locate(/obj/item/implant) in target
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] искать инородные тела в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете искать инородные тела в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто адская!")
	return ..()

/datum/surgery_step/extract_implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] ошибочно хвата[pluralize_ru(user.gender, "ет", "ют")]ся [tool.declent_ru(INSTRUMENTAL)] за что-то в [affected.declent_ru(PREPOSITIONAL)] [target], повреждая внутренние ткани!"),
		span_warning("Вы ошибочно хватаетесь [tool.declent_ru(INSTRUMENTAL)] за что-то в [affected.declent_ru(PREPOSITIONAL)] [target], повреждая внутренние ткани!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/extract_implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	I = locate(/obj/item/implant) in target
	if(I && prob(80)) //implant removal only works on the chest.
		user.visible_message(
			span_notice("[user] вынима[pluralize_ru(user.gender, "ет", "ют")] [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы вынимаете [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
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
			user.visible_message(
				span_notice("[user] помеща[pluralize_ru(user.gender, "ет", "ют")] [I.declent_ru(ACCUSATIVE)] в [case.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы помещаете [I.declent_ru(ACCUSATIVE)] в [case.declent_ru(ACCUSATIVE)].")
			)
		else
			qdel(I)
	else
		user.visible_message(
			span_notice("[user] ничего не наход[pluralize_ru(user.gender, "ит", "ят")] в [affected.declent_ru(PREPOSITIONAL)] [target] и доста[pluralize_ru(user.gender, "ёт", "ют")] [tool.declent_ru(ACCUSATIVE)] оттуда."),
			span_notice("Вы ничего не находите в [affected.declent_ru(PREPOSITIONAL)] [target] и достаёте [tool.declent_ru(ACCUSATIVE)] оттуда."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
	return SURGERY_STEP_CONTINUE
