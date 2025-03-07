//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////
///Surgery Datums

/datum/surgery/bone_repair
	name = "Восстановление повреждённых костей"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)
	restricted_speciestypes = list(/datum/species/plasmaman)

/datum/surgery/bone_repair/non_hitin
	name = "Восстановление повреждённых костей"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)
	restricted_speciestypes = list(/datum/species/plasmaman, /datum/species/wryn, /datum/species/kidan)

/datum/surgery/bone_repair/plasmaman
	name = "Восстановление повреждённых костей (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone/plasma,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
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
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/bone_repair/insect
	name = "Восстановление повреждённых костей (Инсектоид)"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)
	target_speciestypes = list(/datum/species/wryn, /datum/species/kidan)
	restricted_speciestypes = null

/datum/surgery/bone_repair/skull
	name = "Восстановление повреждённых костей черепа"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone/mend_skull,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_HEAD)
	restricted_speciestypes = list(/datum/species/plasmaman)

/datum/surgery/bone_repair/plasmaman/skull
	name = "Восстановление повреждённых костей черепа (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // Only proxy IB here
		/datum/surgery_step/glue_bone/plasma,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_HEAD)
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.cannot_break)
		return FALSE
	if(!affected.has_fracture())
		return FALSE

//surgery steps
/datum/surgery_step/glue_bone
	name = "сращивание костей"
	begin_sound = 'sound/surgery/bonegel.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 2.4 SECONDS

/datum/surgery_step/glue_bone/plasma
	name = "сращивание костей (Плазмолюд)"

	allowed_tools = list(
	/obj/item/stack/sheet/mineral/plasma = 100
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 1 SECONDS

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] сращивать повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете сращивать повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете острую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] сращива[pluralize_ru(user.gender, "ет", "ют")] повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы сращиваете повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/glue_bone/plasma/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] сращива[pluralize_ru(user.gender, "ет", "ют")] повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя кусок твёрдой плазмы."), \
		span_notice("Вы сращиваете повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя кусок твёрдой плазмы."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.mend_fracture()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(3, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/set_bone
	name = "закрепление костей"
	begin_sound = 'sound/surgery/bonesetter.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_BONESET = 100,
		TOOL_WRENCH = 90
	)

	time = 3.2 SECONDS

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] закреплять кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете закреплять кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы едва не теряете сознание от невыносимой боли в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] закрепля[pluralize_ru(user.gender, "ет", "ют")] кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы закрепляете кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] кость в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] кость в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(5, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/set_bone/mend_skull
	name = "закрепление костей черепа"

/datum/surgery_step/set_bone/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] закреплять кости черепа [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете закреплять кости черепа [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/set_bone/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] закрепля[pluralize_ru(user.gender, "ет", "ют")] кости черепа [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы закрепляете кости черепа [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/set_bone/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/head/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] череп [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] череп [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, def_zone = affected)
	affected.disfigure()
	return SURGERY_STEP_RETRY

/datum/surgery_step/finish_bone
	name = "заживление костей"
	begin_sound = 'sound/surgery/bonegel.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 2.4 SECONDS

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] заживлять кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете заживлять кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	return ..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] восстанавлива[pluralize_ru(user.gender, "ет", "ют")] кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы восстанавливаете кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	affected.mend_fracture()
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
	)
	target.apply_damage(3, def_zone = affected)
	return SURGERY_STEP_RETRY
