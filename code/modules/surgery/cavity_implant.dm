/datum/surgery/cavity_implant
	name = "Полостная хирургия"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	restricted_speciestypes = list(/datum/species/kidan, /datum/species/wryn, /datum/species/plasmaman)


/datum/surgery/cavity_implant/soft
	name = "Полостная хирургия"
	desc = "Имплантация объекта в полость, не защищённую костями."
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/generic/cauterize
	)

	possible_locs = list(BODY_ZONE_PRECISE_GROIN)

/datum/surgery/cavity_implant/insect
	name = "Полостная хирургия (Инсектоид)"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	target_speciestypes = list(/datum/species/kidan, /datum/species/wryn)
	restricted_speciestypes = null
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/cavity_implant/plasmaman
	name = "Полостная хирургия (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone/plasma,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/cavity_implant/plasmaman/soft
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_PRECISE_GROIN)

/datum/surgery/cavity_implant/synth
	name = "Полостная хирургия (Синтетик)"
	requires_organic_bodypart = FALSE
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/cavity_manipulation/robotic,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/cavity_implant/synth
	name = "Полостная хирургия (Синтетик)"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/cavity_manipulation/robotic,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = FALSE

/datum/surgery_step/proxy/cavity_manipulation
	name = "Полостная манипуляция – прокси"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant,
		/datum/surgery/intermediate/open_cavity/extract,
		/datum/surgery/intermediate/bleeding
	)

	insert_self_after = TRUE

/datum/surgery_step/proxy/cavity_manipulation/robotic
	name = "Полостная манипуляция (Синтетик) – прокси"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant/robotic,
		/datum/surgery/intermediate/open_cavity/extract/robotic
	)

/datum/surgery/intermediate/open_cavity
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/intermediate/open_cavity/implant
	name = "имплантировать объект"
	steps = list(
		/datum/surgery_step/cavity/place_item
	)

/datum/surgery/intermediate/open_cavity/extract
	name = "извлечь объект"
	steps = list(
		/datum/surgery_step/cavity/remove_item
	)

/datum/surgery/intermediate/open_cavity/implant/robotic
	requires_organic_bodypart = FALSE

/datum/surgery/intermediate/open_cavity/extract/robotic
	requires_organic_bodypart = FALSE

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/affected)
	switch(affected.limb_zone)
		if(BODY_ZONE_HEAD)
			return WEIGHT_CLASS_TINY
		if(BODY_ZONE_CHEST)
			return WEIGHT_CLASS_NORMAL
		if(BODY_ZONE_PRECISE_GROIN)
			return WEIGHT_CLASS_SMALL
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/affected)
	switch(affected.limb_zone)
		if(BODY_ZONE_HEAD)
			return "черепную"
		if(BODY_ZONE_CHEST)
			return "грудную"
		if(BODY_ZONE_PRECISE_GROIN)
			return "брюшную"
	return ""

/datum/surgery_step/cavity/proc/get_item_inside(obj/item/organ/external/affected)
	var/obj/item/extracting
	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	return extracting

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!")
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/cavity/make_space
	name = "создание полости"
	begin_sound = 'sound/surgery/surgicaldrill.ogg'
	allowed_tools = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 90,
		/obj/item/pen = 90,
		/obj/item/stack/rods = 60
	)

	time = 5.4 SECONDS

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] создавать [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете создавать [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	target.custom_pain("Вы чувствуете острую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] созда[pluralize_ru(user.gender, "ёт", "ют")] [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы создаёте [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/close_space
	name = "закрытие полости"
	begin_sound = 'sound/surgery/cautery2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] закрывать [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете закрывать [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)
	target.custom_pain("Вы чувствуете жгучую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] закрыва[pluralize_ru(user.gender, "ет", "ют")] [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы закрываете [get_cavity(affected)] полость в теле [target], используя [tool.declent_ru(ACCUSATIVE)].")
	)

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/cavity/remove_item
	name = "извлечение объекта"
	begin_sound = 'sound/surgery/organ2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	accept_hand = TRUE

/datum/surgery_step/cavity/remove_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	// Check even if there isn't anything inside
	user.visible_message(
		span_notice("[user] проверя[pluralize_ru(user.gender, "ет", "ют")] полость в [affected.declent_ru(GENITIVE)] [target] на наличие чужеродных объектов."),
		span_notice("Вы проверяете полость в [affected.declent_ru(GENITIVE)] [target] на наличие чужеродных объектов.")
	)
	return ..()

/datum/surgery_step/cavity/remove_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/extracting
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	if(!extracting)
		to_chat(user, span_warning("Вы ничего не находите в [affected.declent_ru(GENITIVE)] [target]."))
		return SURGERY_STEP_CONTINUE
	user.visible_message(
		span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target]!"),
		span_notice("Вы достаёте [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target]!")
	)
	user.put_in_hands(extracting, ignore_anim = FALSE)
	affected.hidden = null
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/remove_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] по ошибке хвата[pluralize_ru(user.gender, "ет", "ют")]ся рукой за что-то в [affected.declent_ru(PREPOSITIONAL)] [target], нанося серьёзные повреждения!"),
		span_warning("Вы по ошибке хватаетесь рукой за что-то в [affected.declent_ru(PREPOSITIONAL)] [target], нанося серьёзные повреждения!")
	)
	target.apply_damage(rand(3,7), def_zone = affected)

	return SURGERY_STEP_INCOMPLETE

/datum/surgery_step/cavity/place_item
	name = "имплантация объекта"
	begin_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	accept_any_item = TRUE

	time = 3.2 SECONDS


/datum/surgery_step/cavity/place_item/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/disk/nuclear))
		to_chat(user, span_danger("Центральное Командование убьёт вас, если узнает, что вы имплантировали ядерный диск в чьё-то тело!"))
		return FALSE

	var/obj/item/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, span_danger("Центральное Командование убьёт вас, если узнает, что вы имплантировали ядерный диск в чьё-то тело. Особенно, если оно внутри [tool.declent_ru(GENITIVE)]!"))
		return FALSE

	if(istype(tool, /obj/item/organ))
		to_chat(user, span_warning("Неподходящий тип операции для трансплантации органов."))
		return FALSE

	if(!user.can_unEquip(tool))
		to_chat(user, span_warning("Вы не можете выпустить [tool.declent_ru(ACCUSATIVE)] из своей руки!"))
		return FALSE

	if(istype(tool, /obj/item/cautery))
		// Pass it to the next step
		return FALSE

	return TRUE


/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/can_fit = !affected.hidden && tool.w_class <= get_max_wclass(affected)
	if(!can_fit)
		to_chat(user, span_warning("[capitalize(tool.declent_ru(NOMINATIVE))] не помест[pluralize_ru(tool.gender, "ит", "ят")]ся внутри [affected.declent_ru(GENITIVE)]!"))
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] помещать [tool.declent_ru(ACCUSATIVE)] в [get_cavity(affected)] полость [target]."),
		span_notice("Вы начинаете помещать [tool.declent_ru(ACCUSATIVE)] в [get_cavity(affected)] полость [target].")
	)
	target.custom_pain("Вы чувствуете сильную боль в [affected.declent_ru(GENITIVE)]!")
	return ..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	if(get_item_inside(affected))
		user.balloon_alert(user, "в полости что-то есть!")
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		span_notice("[user] помеща[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в [get_cavity(affected)] полость [target]."),
		span_notice("Вы помещаете [tool.declent_ru(ACCUSATIVE)] в [get_cavity(affected)] полость [target].")
	)
	if((tool.w_class > get_max_wclass(affected) / 2 && prob(50) && !affected.is_robotic()))
		user.visible_message(
			span_warning("[user] разрыва[pluralize_ru(user.gender, "ет", "ют")] кровеносные сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], пытаясь засунуть [tool.declent_ru(ACCUSATIVE)] в полость!"),
			span_danger("Вы разрываете кровеносные сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], пытаясь засунуть [tool.declent_ru(ACCUSATIVE)] в полость!"),
			span_warning("Вы слышите тихий звук, напоминающий разрыв чего-то."))
		affected.internal_bleeding()
	user.drop_transfer_item_to_loc(tool, target)
	affected.hidden = tool
	return SURGERY_STEP_CONTINUE
