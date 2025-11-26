//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/open_encased
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

/datum/surgery_step/open_encased/saw
	name = "распиливание кости"
	begin_sound = list(
		TOOL_SAW = 'sound/surgery/saw1.ogg',
		/obj/item/primitive_saw = 'sound/surgery/scalpel1.ogg',
		/obj/item/circular_saw_blade = 'sound/surgery/scalpel1.ogg',
		TOOL_WIRECUTTER = 'sound/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/surgery/scalpel1.ogg',
	)
	end_sound = 'sound/surgery/amputation.ogg'
	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/primitive_saw = 100,
		/obj/item/hatchet = 90,
		/obj/item/circular_saw_blade = 80,
		TOOL_WIRECUTTER = 70,
	)

	time = 5.4 SECONDS

/datum/surgery_step/open_encased/saw/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] распиливать [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете распиливать [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
	)
	target.custom_pain("Вы чувствуете невыносимую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/open_encased/saw/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] распилива[PLUR_ET_YUT(user)] [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы распиливаете [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	affected.fracture(silent = TRUE)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/saw/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, ломая [tool.declent_ru(INSTRUMENTAL)] [affected.encased] [target]!"),
		span_warning("Вы дёргаете рукой, ломая [tool.declent_ru(INSTRUMENTAL)] [affected.encased] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	target.apply_damage(20, def_zone = affected)
	affected.fracture()

	return SURGERY_STEP_RETRY

/datum/surgery_step/open_encased/retract
	name = "смещение кости"
	begin_sound = 'sound/surgery/organ2.ogg'
	end_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90,
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/retract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] расширять [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинает расширять [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете ужасную боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/open_encased/retract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] расширя[PLUR_ET_YUT(user)] [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы расширяете [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	affected.open = ORGAN_ORGANIC_ENCASED_OPEN

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/retract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, ломая [affected.encased] [target] [tool.declent_ru(INSTRUMENTAL)]!"),
		span_warning("Вы дёргаете рукой, ломая [affected.encased] [target] [tool.declent_ru(INSTRUMENTAL)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	target.apply_damage(20, def_zone = affected)
	affected.fracture()

	return SURGERY_STEP_RETRY

/datum/surgery_step/open_encased/close
	name = "установка кости на место"
	begin_sound = 'sound/surgery/organ2.ogg'
	end_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90,
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/close/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] вставлять кость в [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинает вставлять кость в [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете ужасную боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/open_encased/close/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] вставля[PLUR_ET_YUT(user)] кость в [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы вставляете кость в [affected.encased] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/open_encased/close/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[PLUR_ET_YUT(user)] рукой, неправильно вставляя кость в [affected.encased] [target]!"),
		span_warning("Вы дёргаете рукой, неправильно вставляя кость в [affected.encased] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	target.apply_damage(20, def_zone = affected)
	affected.fracture()

	return SURGERY_STEP_RETRY

/datum/surgery_step/open_encased/mend
	name = "сращивание костей"
	begin_sound = 'sound/surgery/bonegel.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_BONEGEL = 100,
		TOOL_SCREWDRIVER = 90,
	)

	time = 2.4 SECONDS

/datum/surgery_step/open_encased/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] начина[PLUR_ET_YUT(user)] сращивать повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете сращивать повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете ужасную боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/open_encased/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] сращива[PLUR_ET_YUT(user)] повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы сращиваете повреждённые кости в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	affected.mend_fracture()
	affected.open = ORGAN_ORGANIC_OPEN

	return SURGERY_STEP_CONTINUE
