//Procedures in this file: Generic surgery steps
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/surgery_step/generic
	can_infect = TRUE

/datum/surgery_step/generic/cut_open
	name = "осуществление надреза"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60,
		/obj/item/scissors = 12,
		/obj/item/twohanded/chainsaw = 1,
		/obj/item/melee/claymore = 6,
		/obj/item/melee/energy = 6,
		/obj/item/pen/edagger = 6,
	)

	time = 1.6 SECONDS

/datum/surgery_step/generic/cut_open/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] делать надрез на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете делать надрез на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете острую боль, будто бы кто-то вонзает нож в ваш[genderize_ru(affected.gender, "", "у", "е", "и")] [affected.declent_ru(ACCUSATIVE)]!")
	return ..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] дела[pluralize_ru(user.gender, "ет", "ют")] надрез на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы делаете надрез на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_ORGANIC_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, проводя лезвием [tool.declent_ru(GENITIVE)] по [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, проводя лезвием [tool.declent_ru(GENITIVE)] по [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/clamp_bleeders
	name = "пережатие сосудов"
	begin_sound = 'sound/surgery/hemostat1.ogg'
	end_sound = 'sound/surgery/hemostat2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/scalpel/laser = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 90,
		/obj/item/assembly/mousetrap = 25
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] пережимать кровоточащие сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете пережимать кровоточащие сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] пережима[pluralize_ru(user.gender, "ет", "ют")] кровоточащие сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы пережимаете кровоточащие сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	spread_germs_to_organ(affected, user, tool)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] сосуды в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] сосуды в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/retract_skin
	name = "расширение краёв раны"
	begin_sound = 'sound/surgery/retractor1.ogg'
	end_sound = 'sound/surgery/retractor2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		/obj/item/scalpel/laser/manager = 100,
		/obj/item/retractor = 100,
		/obj/item/crowbar = 90,
		/obj/item/kitchen/utensil/fork = 60
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/retract_skin/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	var/self_msg = "Вы начинаете раздвигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете раздвигать органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете раздвигать органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
	user.visible_message(span_notice(msg), span_notice(self_msg), chat_message_type = MESSAGE_TYPE_COMBAT)
	target.custom_pain("Вы чувствуете, что кожа на ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] горит!")
	return ..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	var/self_msg = "Вы раздвигаете края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы раздвигаете органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы раздвигаете органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
	user.visible_message(span_notice(msg), span_notice(self_msg), chat_message_type = MESSAGE_TYPE_COMBAT)
	affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] края раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"
	var/self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] края раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в грудной клетке [target]!"
		self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в грудной клетке [target]!"
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в брюшной полости [target]!"
		self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в брюшной полости [target]!"
	user.visible_message(span_warning(msg), span_warning(self_msg), chat_message_type = MESSAGE_TYPE_COMBAT)
	target.apply_damage(12, BRUTE, affected, sharp = TRUE)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/cauterize
	name = "прижигание раны"
	begin_sound = 'sound/surgery/cautery1.ogg'
	end_sound = 'sound/surgery/cautery2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30,
		/obj/item/flashlight/flare/torch = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/cauterize/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] прижигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете прижигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете сильное жжение в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] прижига[pluralize_ru(user.gender, "ет", "ют")] края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы прижигаете края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_CLOSED
	affected.germ_level = 0
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, оставляя [tool.declent_ru(INSTRUMENTAL)] небольшой ожог на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, оставляя [tool.declent_ru(INSTRUMENTAL)] небольшой ожог на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(3, BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/generic/cauterize/premature
	name = "прижигание раны (прерывание операции)"

/datum/surgery_step/generic/cauterize/premature/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] прижигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		// give a little heads up to the surgeon that they're stopping the surgery prematurely in case that wasn't the intention.
		span_warning("Вы завершаете текущую операцию, начиная прижигать края раны на [affected.declent_ru(PREPOSITIONAL)] [target] с помощью [tool.declent_ru(GENITIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете сильное жжение в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()


//drill bone
/datum/surgery_step/generic/drill
	name = "сверление кости"
	begin_sound = 'sound/surgery/surgicaldrill.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 80,
		/obj/item/pickaxe/drill = 60,
		/obj/item/mecha_parts/mecha_equipment/drill = 60,
		/obj/item/screwdriver = 20
	)
	time = 3 SECONDS

/datum/surgery_step/generic/drill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] сверлить кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете сверлить кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/generic/drill/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] сверл[pluralize_ru(user.gender, "ит", "ят")] кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы сверлите кость в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/drill/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] кость в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] кость в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	target.apply_damage(15, def_zone = affected)
	return SURGERY_STEP_RETRY


/datum/surgery_step/generic/amputate
	name = "ампутация конечности"
	begin_sound = list(
		TOOL_SAW = 'sound/surgery/saw1.ogg',
		/obj/item/hatchet = 'sound/surgery/scalpel1.ogg',
		/obj/item/primitive_saw = 'sound/surgery/scalpel1.ogg',
		/obj/item/circular_saw_blade = 'sound/surgery/scalpel1.ogg',
		/obj/item/melee/arm_blade = 'sound/surgery/scalpel1.ogg',
	)
	end_sound = 'sound/surgery/amputation.ogg'
	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/primitive_saw = 100,
		/obj/item/hatchet = 90,
		/obj/item/circular_saw_blade = 80,
		/obj/item/melee/arm_blade = 75
	)

	time = 10 SECONDS

/datum/surgery_step/generic/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] распиливать [affected.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете распиливать [affected.amputation_point] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете, как [affected.amputation_point] буквально разрывает на части!")
	return ..()

/datum/surgery_step/generic/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] распилива[pluralize_ru(user.gender, "ет", "ют")] [affected.amputation_point] [target] с помощью [tool.declent_ru(GENITIVE)], ампутируя [affected.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы распиливаете [affected.amputation_point] [target] с помощью [tool.declent_ru(GENITIVE)], ампутируя [affected.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	add_attack_logs(user, target, "Surgically removed [affected.name]. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1, DROPLIMB_SHARP)

	if(istype(target) && target.has_pain())
		// okay if you can feel your arm getting chopped off you aren't gonna be singing
		to_chat(target, span_userdanger("Ваш[genderize_ru(affected.gender, "", "а", "е", "и")] [affected.declent_ru(NOMINATIVE)] неме[pluralize_ru(affected.gender, "ет", "ют")], боль застилает ваше сознание!"))
		target.emote("scream")
	if(isitem(thing))
		thing.forceMove(get_turf(target))
		user.put_in_hands(thing, ignore_anim = FALSE)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, проводя [tool.declent_ru(INSTRUMENTAL)] прямо по кости в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, проводя [tool.declent_ru(INSTRUMENTAL)] прямо по кости в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(30, def_zone = affected)
	affected.fracture()
	return SURGERY_STEP_RETRY
