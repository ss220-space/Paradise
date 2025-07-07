//Procedures in this file: Robotic limbs attachment, meat limbs attachment
//////////////////////////////////////////////////////////////////
//						LIMB SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery/amputation
	name = "Ампутация"
	steps = list(/datum/surgery_step/generic/amputate)
	possible_locs = list(
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
	requires_organic_bodypart = TRUE
	cancel_on_organ_change = FALSE


/datum/surgery/amputation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.cannot_amputate)
		return FALSE
	return TRUE


/datum/surgery/reattach
	name = "Присоединение конечности"
	steps = list(/datum/surgery_step/limb/attach, /datum/surgery_step/limb/connect)
	requires_bodypart = FALSE
	possible_locs = list(
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
	cancel_on_organ_change = FALSE

/datum/surgery/reattach/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/affected = H.get_organ(user.zone_selected)
		if(ismachineperson(target) && user.zone_selected != BODY_ZONE_TAIL)
			// RIP bi-centennial man
			return FALSE
		if(ismachineperson(target) && user.zone_selected != BODY_ZONE_WING)
			// RIP bi-centennial man
			return FALSE
		if(!affected)
			return TRUE
		// make sure they can actually have this limb
		var/list/organ_data = target.dna.species.has_limbs["[user.zone_selected]"]
		return !isnull(organ_data)

	return FALSE

/datum/surgery/reattach_synth
	name = "Присоединение конечности (Синтетик)"
	requires_bodypart = FALSE
	steps = list(/datum/surgery_step/limb/attach/robo)
	abstract = TRUE  // these shouldn't show in the list; they'll be replaced by attach_robotic_limb
	possible_locs = list(
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

/datum/surgery/robo_attach
	name = "Установка робо-протеза"
	requires_bodypart = FALSE
	steps = list(/datum/surgery_step/limb/mechanize)
	abstract = TRUE
	possible_locs = list(
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

/datum/surgery_step/proxy/robo_limb_attach
	name = "установка робо-конечности – прокси"
	branches = list(
		/datum/surgery/robo_attach,
		/datum/surgery/reattach_synth
	)
	insert_self_after = FALSE

/datum/surgery/attach_robotic_limb
	name = "Установка кибернетической конечности"
	requires_bodypart = FALSE
	steps = list(
		/datum/surgery_step/proxy/robo_limb_attach
	)
	cancel_on_organ_change = FALSE
	possible_locs = list(
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

/datum/surgery/attach_robotic_limb/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_NO_ROBOPARTS))
		return FALSE

/datum/surgery_step/limb
	can_infect = FALSE

/datum/surgery_step/limb/attach
	name = "присоединить конечность"
	begin_sound = 'sound/surgery/organ2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(/obj/item/organ/external = 100)

	time = 3.2 SECONDS

/datum/surgery_step/limb/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = tool
	if(target.get_organ(bodypart.limb_zone))
		// This catches attaching an arm to a missing hand while the arm is still there
		user.balloon_alert(user, "конечность уже установлена!")
		return SURGERY_BEGINSTEP_ABORT
	if(bodypart.limb_zone != target_zone)
		// This ensures you must be aiming at the appropriate location to attach
		// this limb. (Can't aim at a missing foot to re-attach a missing arm)
		user.balloon_alert(user, "несовместимо!")
		return SURGERY_BEGINSTEP_ABORT
	if(!target.get_organ(bodypart.parent_organ_zone))
		user.balloon_alert(user, "некуда присоединять!")
		return SURGERY_BEGINSTEP_ABORT
	if(!is_correct_limb(bodypart, target))
		user.balloon_alert(user, "несовместимо!")
		return SURGERY_BEGINSTEP_ABORT
	var/list/organ_data = target.dna.species.has_limbs["[user.zone_selected]"]
	if(isnull(organ_data))
		user.balloon_alert(user, "несовместимо с организмом!")
		return SURGERY_BEGINSTEP_ABORT
	if(!istype(bodypart, organ_data["path"]) && HAS_TRAIT(target, TRAIT_SPECIES_LIMBS))
		user.balloon_alert(user, "неподходящая раса!")
		return SURGERY_BEGINSTEP_ABORT
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] присоединять [bodypart.declent_ru(ACCUSATIVE)] к [bodypart.amputation_point] [target]."),
		span_notice("Вы начинаете присоединять [bodypart.declent_ru(ACCUSATIVE)] к [bodypart.amputation_point] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/limb/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = tool
	user.visible_message(
		span_notice("[user] присоединя[pluralize_ru(user.gender, "ет", "ют")] присоединять [bodypart.declent_ru(ACCUSATIVE)] к [bodypart.amputation_point] [target]."),
		span_notice("Вы присоединяете [bodypart.declent_ru(ACCUSATIVE)] к [bodypart.amputation_point] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	attach_limb(user, target, bodypart)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/limb/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = tool
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [bodypart.amputation_point] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [bodypart.amputation_point] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY


/datum/surgery_step/limb/attach/proc/is_correct_limb(obj/item/organ/external/bodypart, mob/living/carbon/human/target)
	if(bodypart.is_robotic())
		return FALSE
	if(target.dna.species.type == /datum/species/kidan && istype(bodypart, /obj/item/organ/external/head) && !istype(bodypart, /obj/item/organ/external/head/kidan))
		return FALSE
	return TRUE

/datum/surgery_step/limb/attach/proc/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/bodypart)
	user.drop_item_ground(bodypart)
	bodypart.replaced(target)
	if(!bodypart.is_robotic())
		bodypart.properly_attached = FALSE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()


// This is a step that handles robotic limb attachment while skipping the "connect" step
// THIS IS DISTINCT FROM USING A CYBORG LIMB TO CREATE A NEW LIMB ORGAN
/datum/surgery_step/limb/attach/robo
	name = "присоединить робо-конечность"

/datum/surgery_step/limb/attach/robo/is_correct_limb(obj/item/organ/external/bodypart)
	if(!bodypart.is_robotic())
		return 0
	return 1

/datum/surgery_step/limb/attach/robo/attach_limb(mob/living/user, mob/living/carbon/human/target, obj/item/organ/external/bodypart)
	..()
	if(bodypart.limb_zone == BODY_ZONE_HEAD)
		var/obj/item/organ/external/head/H = target.get_organ(BODY_ZONE_HEAD)
		var/datum/robolimb/robohead = GLOB.all_robolimbs[H.model]
		if(robohead.is_monitor) //Ensures that if an IPC gets a head that's got a human hair wig attached to their body, the hair won't wipe.
			H.h_style = "Bald"
			H.f_style = "Shaved"
			target.m_styles["head"] = "None"


/datum/surgery_step/limb/connect
	name = "соединение тканей конечности"
	begin_sound = 'sound/surgery/hemostat1.ogg'
	end_sound = 'sound/surgery/hemostat2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 90,
		/obj/item/assembly/mousetrap = 25
	)
	can_infect = TRUE

	time = 3.2 SECONDS

/datum/surgery_step/limb/connect/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] соединять связки и мышцы в [bodypart.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете соединять связки и мышцы в [bodypart.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/limb/connect/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] соединя[pluralize_ru(user.gender, "ет", "ют")] связки и мышцы в [bodypart.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы соединяете связки и мышцы в [bodypart.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	bodypart.properly_attached = TRUE
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/limb/connect/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/bodypart = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [bodypart.amputation_point] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [bodypart.amputation_point] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY

/datum/surgery_step/limb/mechanize
	name = "установка робо-протеза"
	allowed_tools = list(/obj/item/robot_parts = 100)

	time = 3.2 SECONDS

/datum/surgery_step/limb/mechanize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/robopart = tool
	if(robopart.part)
		if(!(target_zone in robopart.part))
			user.balloon_alert(user, "несовместимо!")
			return SURGERY_BEGINSTEP_ABORT

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] присоединять [tool.declent_ru(ACCUSATIVE)] к [GLOB.body_zone[target_zone][DATIVE]] [target]."),
		span_notice("Вы начинаете присоединять [tool.declent_ru(ACCUSATIVE)] к [GLOB.body_zone[target_zone][DATIVE]] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()


/datum/surgery_step/limb/mechanize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/limb = tool
	user.visible_message(
		span_notice("[user] присоединя[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] к [GLOB.body_zone[target_zone][DATIVE]] [target]."),
		span_notice("Вы присоединяете [tool.declent_ru(ACCUSATIVE)] к [GLOB.body_zone[target_zone][DATIVE]] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	if(limb.part)
		for(var/part_name in limb.part)
			if(!isnull(target.get_organ(part_name)))
				continue

			var/list/organ_data = target.dna.species.has_limbs[part_name]
			if(!organ_data)
				continue

			var/new_limb_type = organ_data["path"]
			var/obj/item/organ/external/new_limb = new new_limb_type(target, ORGAN_MANIPULATION_DEFAULT)
			new_limb.robotize(company = limb.model_info)

			if(limb.sabotaged)
				new_limb.sabotaged = TRUE

	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/limb/mechanize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [GLOB.body_zone[target_zone][ACCUSATIVE]] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [GLOB.body_zone[target_zone][ACCUSATIVE]] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, BRUTE, null, sharp = TRUE)
	return SURGERY_STEP_RETRY
