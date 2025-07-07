/datum/surgery/embedded_removal
	name = "Извлечение инородных объектов"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/embedded_removal/synth
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/remove_object,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE

/datum/surgery/embedded_removal/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!length(affected.embedded_objects))
		return FALSE

/datum/surgery_step/remove_object
	name = "извлечение объекта из тела"
	begin_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'

	time = 3.2 SECONDS
	accept_hand = TRUE
	var/obj/item/organ/external/L = null
	repeatable = TRUE


/datum/surgery_step/remove_object/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	L = surgery.organ_to_manipulate
	if(L)
		user.visible_message(
			span_notice("[user] ищ[pluralize_ru(user.gender, "ет", "ут")] инородные объекты в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			span_notice("Вы ищете инородные объекты в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
	else
		user.visible_message(
			span_notice("[user] ищ[pluralize_ru(user.gender, "ет", "ут")] [affected.declent_ru(ACCUSATIVE)] у [target]."),
			span_notice("Вы ищете [affected.declent_ru(ACCUSATIVE)] у [target]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
	return ..()


/datum/surgery_step/remove_object/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(L)
		var/objects_removed = L.remove_all_embedded_objects()
		if(objects_removed)
			user.visible_message(
				span_notice("[user] извлека[pluralize_ru(user.gender, "ет", "ют")] [objects_removed] [declension_ru(objects_removed, "инородный объект", "инородных объекта", "инородных объектов")] из [affected.declent_ru(GENITIVE)] [target]."),
				span_notice("Вы извлекаете [objects_removed] [declension_ru(objects_removed, "инородный объект", "инородных объекта", "инородных объектов")] из [affected.declent_ru(GENITIVE)] [target]."),
				chat_message_type = MESSAGE_TYPE_COMBAT)
		else
			user.visible_message(
				span_notice("[user] не наход[pluralize_ru(user.gender, "ит", "ят")] никаких инородных объектов в [affected.declent_ru(PREPOSITIONAL)] [target]."),
				span_notice("Вы не находите никаких инородных объектов в [affected.declent_ru(PREPOSITIONAL)] [target]."),
				chat_message_type = MESSAGE_TYPE_COMBAT
			)
	else
		user.visible_message(
			span_notice("[user] не наход[pluralize_ru(user.gender, "ит", "ят")] [affected.declent_ru(ACCUSATIVE)] у [target]."),
			span_notice("Вы не находите [affected.declent_ru(ACCUSATIVE)] у [target]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

	return SURGERY_STEP_CONTINUE

// this could use a fail_step...
