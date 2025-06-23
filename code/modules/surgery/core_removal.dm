/datum/surgery/core_removal
	name = "Извлечение ядра слайма"
	steps = list(/datum/surgery_step/slime/cut_flesh, /datum/surgery_step/slime/extract_core)
	target_mobtypes = list(/mob/living/simple_animal/slime)
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

/datum/surgery/core_removal/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	return . && target.stat == DEAD


/datum/surgery_step/slime

/datum/surgery_step/slime/cut_flesh
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/melee/energy/sword = 75,
		/obj/item/kitchen/knife = 65,
		/obj/item/shard = 45
	)
	time = 1.6 SECONDS

/datum/surgery_step/slime/cut_flesh/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] прорезать слизь [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете прорезать слизь [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/slime/cut_flesh/end_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] прореза[pluralize_ru(user.gender, "ет", "ют")] слизь [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы прорезаете слизь [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/slime/cut_flesh/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, нанося серьёзные повреждения [target.declent_ru(DATIVE)] [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, нанося серьёзные повреждения [target.declent_ru(DATIVE)] [tool.declent_ru(ACCUSATIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/slime/extract_core
	name = "извлечение ядра"
	allowed_tools = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100)
	time = 1.6 SECONDS

/datum/surgery_step/slime/extract_core/begin_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] извлекать ядро [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете извлекать ядро [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	return ..()


/datum/surgery_step/slime/extract_core/end_step(mob/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	if(target.cores > 0)
		target.cores--
		user.visible_message(
			span_notice("[user] извлека[pluralize_ru(user.gender, "ет", "ют")] ядро [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы извлекаете ядро [target.declent_ru(GENITIVE)], используя [tool.declent_ru(ACCUSATIVE)]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		new target.coretype(target.loc)

		if(target.cores <= 0)
			target.icon_state = "[target.colour] baby slime dead-nocore"
			return SURGERY_STEP_CONTINUE
		else
			return SURGERY_STEP_INCOMPLETE
	else
		user.balloon_alert(user, "ядра отсутствуют!")
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/slime/extract_core/fail_step(mob/living/user, mob/living/simple_animal/slime/target, target_zone, obj/item/tool)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, нанося серьёзные повреждения [target.declent_ru(DATIVE)] [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, нанося серьёзные повреждения [target.declent_ru(DATIVE)] [tool.declent_ru(ACCUSATIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY
