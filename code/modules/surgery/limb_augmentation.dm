/datum/surgery/limb_augmentation
	name = "Augment Limb"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/augment
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/limb_augmentation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(HAS_TRAIT(target, TRAIT_NO_ROBOPARTS))
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.has_fracture()) //The arm has to be in prime condition to augment it.
		return FALSE

/datum/surgery_step/augment
	name = "augment limb with robotic part"
	allowed_tools = list(/obj/item/robot_parts = 100)
	time = 3.2 SECONDS

/datum/surgery_step/augment/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/p = tool
	if(p.part)
		if(!(target_zone in p.part))
			to_chat(user, span_warning("[tool] cannot be used to augment this limb!"))
			return SURGERY_BEGINSTEP_ABORT

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts augmenting [affected] with [tool].",
		"You start augmenting [affected] with [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/augment/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/robot_parts/L = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] has finished augmenting [affected] with [tool]."),
		span_notice("You augment [affected] with [tool]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	if(L.part)
		for(var/part_name in L.part)
			if(!target.get_organ(part_name))
				continue
			affected.robotize(make_tough = TRUE, company = L.model_info, convert_all = FALSE)
			if(L.sabotaged)
				affected.sabotaged = 1
			break
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()

	qdel(tool)

	affected.open = ORGAN_CLOSED
	affected.germ_level = 0
	return SURGERY_STEP_CONTINUE
