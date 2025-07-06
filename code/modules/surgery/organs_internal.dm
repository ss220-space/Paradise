/// Amount of units to transfer from the container to the organs during disinfection step.
#define GHETTO_DISINFECT_AMOUNT 5
/// Amount of mito necessary to revive an organ
#define MITO_REVIVAL_COST 5



/datum/surgery/organ_manipulation
	name = "Манипуляция с внутренними органами"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/internal/manipulate_organs/finish,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	requires_organic_bodypart = TRUE
	requires_bodypart = TRUE
	restricted_speciestypes = list(/datum/species/kidan, /datum/species/wryn, /datum/species/plasmaman)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)

/datum/surgery/organ_manipulation_boneless
	name = "Манипуляция с внутренними органами"
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_TAIL,
	)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)
	requires_organic_bodypart = TRUE

/datum/surgery/organ_manipulation/plasmaman
	name = "Манипуляция с внутренними органами (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ/plasma,
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/internal/manipulate_organs/finish,
		/datum/surgery_step/glue_bone/plasma,
		/datum/surgery_step/proxy/open_organ/plasma,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	requires_organic_bodypart = TRUE
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/organ_manipulation/plasmaman/soft
	possible_locs = list(
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
	)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)

/datum/surgery/organ_manipulation/insect
	name = "Манипуляция с внутренними органами (Инсектоид)"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/internal/manipulate_organs/finish,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	requires_organic_bodypart = TRUE
	target_speciestypes = list(/datum/species/kidan, /datum/species/wryn)
	restricted_speciestypes = null

/datum/surgery/organ_manipulation/insect/soft
	possible_locs = list(
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
	)
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/manipulate_organs,
		/datum/surgery_step/generic/cauterize
	)
	requires_organic_bodypart = TRUE

/datum/surgery/organ_manipulation/alien
	name = "Манипуляция с внутренними органами (Ксеноморф)"
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
	)
	requires_bodypart = FALSE  // xenos just don't have "bodyparts"
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	restricted_speciestypes = null

	steps = list(
		/datum/surgery_step/saw_carapace,
		/datum/surgery_step/cut_carapace,
		/datum/surgery_step/retract_carapace,
		/datum/surgery_step/proxy/manipulate_organs/alien,
		/datum/surgery_step/generic/seal_carapace
	)


/datum/surgery/organ_manipulation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	if(ishuman(target)) //aliens pass it
		var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
		if(!affected.encased) //no bone, problem.
			return FALSE

/datum/surgery/organ_manipulation_boneless/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected && affected.encased) //no bones no problem.
		return FALSE

/datum/surgery/translator_manipulations
	name = "Манипуляция с имплантом-переводчиком"
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	restricted_speciestypes = null

	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/screwdriver_use,
		/datum/surgery_step/proxy/manipulate_translator,
		/datum/surgery_step/screwdriver_use,
		/datum/surgery_step/generic/cauterize
	)

/datum/surgery/translator_manipulations/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE

	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = target.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	if(!translator) // nothing to maniplate with..
		return FALSE

	return TRUE


/datum/surgery_step/screwdriver_use
	name = "откручивание/закручивание импланта-переводчика"
	allowed_tools = list(TOOL_SCREWDRIVER = 100)
	time = 1 SECONDS

/datum/surgery_step/screwdriver_use/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = target.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] [translator.open ? "за" : "от"]кручиать механизм блокировки на корпусе импланта-переводчика [target]."),
		span_notice("Вы начинаете [translator.open ? "за" : "от"]кручиать механизм блокировки на корпусе импланта-переводчика [target]."),
	)
	tool.play_tool_sound(target, 30)

	return ..()

/datum/surgery_step/screwdriver_use/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = target.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	user.visible_message(
		span_notice("[user] [translator.open ? "за" : "от"]кручива[pluralize_ru(user.gender, "ет", "ют")] механизм блокировки на корпусе импланта-переводчика [target]."),
		span_notice("Вы [translator.open ? "за" : "от"]кручиваете механизм блокировки на корпусе импланта-переводчика [target]."),
	)
	translator.open = !translator.open

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/proxy/manipulate_translator
	name = "манипуляция с имплантом-переводчиком – прокси"
	branches = list(
		/datum/surgery/intermediate/manipulate_translator/install,
		/datum/surgery/intermediate/manipulate_translator/uninstall,
	)


/datum/surgery/intermediate/manipulate_translator
	requires_bodypart = TRUE
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)


/datum/surgery/intermediate/manipulate_translator/install
	steps = list(/datum/surgery_step/internal/manipulate_translator/install)


/datum/surgery_step/internal/manipulate_translator/install
	name = "установка чипа/улучшения"
	allowed_tools = list(
		/obj/item/translator_chip = 100,
		/obj/item/translator_upgrade = 100,
		)
	time = 5 SECONDS


/datum/surgery_step/internal/manipulate_translator/install/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] устанавливать [tool.declent_ru(ACCUSATIVE)] в слот импланта-переводчика [target]."),
		span_notice("Вы начинаете устанавливать [tool.declent_ru(ACCUSATIVE)] в слот импланта-переводчика [target]."),
	)

	return ..()


/datum/surgery_step/internal/manipulate_translator/install/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = target.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)

	if(istype(tool, /obj/item/translator_chip))
		var/obj/item/translator_chip/chip = tool

		if(!chip.stored_language_rus)
			user.balloon_alert(user, "чип не активирован!")
			return SURGERY_STEP_INCOMPLETE

		if(LAZYLEN(translator.stored_chips) >= translator.maximum_slots)
			user.balloon_alert(user, "нет места под чип!")
			return SURGERY_STEP_INCOMPLETE

		if(chip.stored_language_rus in translator.given_languages_rus)
			user.balloon_alert(user, "чип уже установлен!")
			return SURGERY_STEP_INCOMPLETE

		translator.install_chip(user, chip)

	else if(istype(tool, /obj/item/translator_upgrade))
		if(translator.stored_upgrade)
			user.balloon_alert(user, "переводчик уже улучшен!")
			return SURGERY_STEP_INCOMPLETE

		translator.install_upgrade(user, tool)

	user.visible_message(
		span_notice("[user] устанавлива[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в слот импланта-переводчика [target]."),
		span_notice("Вы устанавливаете [tool.declent_ru(ACCUSATIVE)] в слот импланта-переводчика [target]."),
	)

	return SURGERY_STEP_CONTINUE


/datum/surgery/intermediate/manipulate_translator/uninstall
	steps = list(/datum/surgery_step/internal/manipulate_translator/uninstall)


/datum/surgery_step/internal/manipulate_translator/uninstall
	name = "извлечение чипа/улучшения"
	allowed_tools = list(TOOL_MULTITOOL = 100)
	time = 0


/datum/surgery_step/internal/manipulate_translator/uninstall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/cyberimp/mouth/translator/translator = target.get_organ_slot(INTERNAL_ORGAN_SPEECH_TRANSLATOR)
	var/list/choises = list()

	if(translator.stored_upgrade)
		choises["Улучшение"] = image(icon = translator.stored_upgrade.icon, icon_state = translator.stored_upgrade.icon_state)

	for(var/obj/item/translator_chip/chip in translator.stored_chips)
		choises[chip.stored_language_rus] = image(icon = chip.icon, icon_state = chip.icon_state)

	if(!choises)
		user.balloon_alert(user, "нечего извлекать!")
		return SURGERY_STEP_INCOMPLETE

	var/choise
	if(LAZYLEN(choises) == 1)
		choise = choises[1]
	else
		choise = show_radial_menu(user, target, choises, require_near = TRUE)

	if(!choise) //closed
		return SURGERY_STEP_INCOMPLETE

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] отключать проводку импланта-переводчика [target]."),
		span_notice("Вы начинаете отключать проводку импланта-переводчика [target]."),
	)

	if(!do_after(user, 4 SECONDS, target))
		return SURGERY_STEP_INCOMPLETE

	var/add_msg = ""
	if(choise == "Улучшение")
		if(LAZYLEN(translator.stored_chips) > initial(translator.maximum_slots))
			user.balloon_alert(user, "сначала извлеките чипы!")
			return SURGERY_STEP_INCOMPLETE

		translator.uninstall_upgrade(user)
		add_msg = "улучшение"

	else
		var/obj/item/translator_chip/chip
		for(chip in translator.stored_chips)
			if(chip.stored_language_rus == choise)
				break

		add_msg = "чип"
		translator.remove_chip(user, chip)

	user.visible_message(
		span_notice("[user] извлека[pluralize_ru(user.gender, "ет", "ют")] [add_msg] из слота импланта-переводчика [target]."),
		span_notice("Вы извлекаете [add_msg] из слота импланта-переводчика [target]."),
	)

	return ..()


// Intermediate steps for branching organ manipulation.
/datum/surgery/intermediate/manipulate
	requires_bodypart = TRUE
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_TAIL,
	)

// All these surgeries are necessary for slotting into proxy steps

/datum/surgery/intermediate/manipulate/extract
	steps = list(/datum/surgery_step/internal/manipulate_organs/extract)

/datum/surgery/intermediate/manipulate/implant
	steps = list(/datum/surgery_step/internal/manipulate_organs/implant)

/datum/surgery/intermediate/manipulate/mend
	steps = list(/datum/surgery_step/internal/manipulate_organs/mend)

/datum/surgery/intermediate/manipulate/clean
	steps = list(/datum/surgery_step/internal/manipulate_organs/clean)

/// The surgery step to trigger this whole situation
/datum/surgery_step/proxy/manipulate_organs
	name = "манипуляция с внутренними органами – прокси"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract,
		/datum/surgery/intermediate/manipulate/implant,
		/datum/surgery/intermediate/manipulate/mend,
		/datum/surgery/intermediate/manipulate/clean,
		/datum/surgery/intermediate/bleeding
	)

/datum/surgery_step/proxy/manipulate_organs/soft
	name = "манипуляция с внутренними органами (Мягкая) – прокси"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract,
		/datum/surgery/intermediate/manipulate/implant,
		/datum/surgery/intermediate/manipulate/mend,
		/datum/surgery/intermediate/manipulate/clean,
		/datum/surgery/intermediate/bleeding
	)

// have to redefine all of these because xenos don't technically have bodyparts.
/datum/surgery/intermediate/manipulate/extract/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/implant/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/mend/xeno
	requires_bodypart = FALSE

/datum/surgery/intermediate/manipulate/clean/xeno
	requires_bodypart = FALSE

/datum/surgery_step/proxy/manipulate_organs/alien
	name = "манипуляция с внутренними органами (Ксеноморф) – прокси"
	branches = list(
		/datum/surgery/intermediate/manipulate/extract/xeno,
		/datum/surgery/intermediate/manipulate/implant/xeno,
		/datum/surgery/intermediate/manipulate/mend/xeno,
		/datum/surgery/intermediate/manipulate/clean/xeno
	)


// Internal surgeries.
/datum/surgery_step/internal
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

/**
 * Get an internal list of organs for a zone (or an external organ).
 *
 * Helper function since we end up calling this a ton to work with carbons
 */
/datum/surgery_step/internal/proc/get_organ_list(target_zone, mob/living/carbon/target, obj/item/organ/external/affected)
	var/list/organs

	if(istype(affected))
		organs = affected.internal_organs
	else
		organs = target.get_organs_zone(target_zone)

	return organs

/datum/surgery_step/internal/manipulate_organs
	time = 6.4 SECONDS

/datum/surgery_step/internal/manipulate_organs/mend
	name = "заживление органов"
	begin_sound = 'sound/surgery/bonegel.ogg'
	end_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/stack/medical/bruise_pack/advanced = 100,
		/obj/item/stack/medical/bruise_pack/extended = 100,
		/obj/item/stack/medical/bruise_pack = 20,
		/obj/item/stack/nanopaste = 100
	)

/datum/surgery_step/internal/manipulate_organs/mend/proc/get_tool_name(obj/item/tool)
	var/tool_name = "[tool.declent_ru(ACCUSATIVE)]"
	if(istype(tool, /obj/item/stack/medical/bruise_pack))
		tool_name = "лечебный пластырь"
	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced) || istype(tool, /obj/item/stack/medical/bruise_pack/extended))
		tool_name = "заживляющую мембрану"

	return tool_name

/datum/surgery_step/internal/manipulate_organs/mend/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!hasorgans(target))
		user.balloon_alert(user, "органы отсутствуют!")
		// note that we want to return skip here so we can go "back" to the proxy step
		return SURGERY_BEGINSTEP_SKIP

	var/any_organs_damaged = FALSE

	for(var/obj/item/organ/internal/organ as anything in get_organ_list(target_zone, target, affected))
		if(!organ.has_damage())
			continue
		any_organs_damaged = TRUE
		var/can_treat_robotic = organ.is_robotic() && istype(tool, /obj/item/stack/nanopaste)
		var/can_treat_organic = !organ.is_robotic() && !istype(tool, /obj/item/stack/nanopaste)
		if(can_treat_robotic || can_treat_organic)
			if(organ.is_dead())
				to_chat(user, span_warning("[capitalize(organ.declent_ru(NOMINATIVE))] [genderize_ru(organ.gender, "мёртв", "мертва", "мертво", "мертвы")]! Использование [tool.declent_ru(GENITIVE)] бессмысленно!"))
				continue
			user.visible_message(
				span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] восстаналивать [organ.declent_ru(ACCUSATIVE)] [target], используя [tool_name]."),
				span_notice("Вы начинаете восстаналивать [organ.declent_ru(ACCUSATIVE)] [target], используя [tool_name]."),
			)
			if(can_treat_organic && !organ.sterile)
				spread_germs_to_organ(organ, user, tool)
		else
			to_chat(user, span_warning("Использование [tool.declent_ru(GENITIVE)] на [organ.declent_ru(PREPOSITIONAL)] бессмысленно!"))

	if(!any_organs_damaged)
		user.balloon_alert(user, "органы в норме!")
		return SURGERY_BEGINSTEP_SKIP

	if(affected)
		var/mob/living/carbon/patient = target
		patient.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_name = get_tool_name(tool)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE

	for(var/obj/item/organ/internal/organ as anything in get_organ_list(target_zone, target, affected))
		var/treated_robotic = organ.is_robotic() && istype(tool, /obj/item/stack/nanopaste)
		var/treated_organic = !organ.is_robotic() && !istype(tool, /obj/item/stack/nanopaste)
		if(treated_robotic || treated_organic)
			if(organ.is_dead())
				continue
			user.visible_message(
				span_notice("[user] восстанавлива[pluralize_ru(user.gender, "ет", "ют")] [organ.declent_ru(ACCUSATIVE)] [target], используя [tool_name]."),
				span_notice("Вы восстаналиваете [organ.declent_ru(ACCUSATIVE)] [target], используя [tool_name]."),
			)
			organ.damage = 0
			organ.surgeryize()

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] внутренности в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] внутренности в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
	)

	var/dam_amt = 2

	if(istype(tool, /obj/item/stack/medical/bruise_pack/advanced) || istype(tool, /obj/item/stack/medical/bruise_pack/extended))
		target.adjustToxLoss(5)

	else if(istype(tool, /obj/item/stack/medical/bruise_pack) || istype(tool, /obj/item/stack/nanopaste))
		dam_amt = 5
		target.apply_damages(brute = 5, tox = 10, def_zone = affected)

	for(var/obj/item/organ/internal/organ as anything in get_organ_list(target_zone, target, affected))
		if(organ.damage && !(organ.tough))
			organ.internal_receive_damage(dam_amt)

	return SURGERY_STEP_RETRY

/datum/surgery_step/internal/manipulate_organs/extract
	name = "извлечение органа"
	begin_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_HEMOSTAT = 100,
		/obj/item/kitchen/utensil/fork = 70
	)

	var/obj/item/organ/internal/extracting = null

/datum/surgery_step/internal/manipulate_organs/extract/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/list/organs = target.get_organs_zone(target_zone)
	if(!length(organs))
		user.balloon_alert(user, "нечего извлекать!")
		return SURGERY_BEGINSTEP_SKIP

	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(target_zone == BODY_ZONE_HEAD && B && B.host == target)
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] извлекать [B.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы начинаете извлекать [B.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		)
		return ..()

	for(var/obj/item/organ/internal/organ as anything in organs)
		if(organ.unremovable)
			continue
		organ.on_find(user)
		organs -= organ
		organs[capitalize(organ.declent_ru(NOMINATIVE))] = organ

	var/obj/item/organ/internal/I = tgui_input_list(user, "Выберите орган для извлечения", "Извлечение органа", organs)
	if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
		extracting = organs[I]
		if(!extracting)
			return SURGERY_BEGINSTEP_SKIP
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] извлекать [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы начинаете извлекать [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		)
		if(target && affected)
			target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	else
		return SURGERY_BEGINSTEP_SKIP

	return ..()

/datum/surgery_step/internal/manipulate_organs/extract/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/mob/living/simple_animal/borer/B = target.has_brain_worms()
	if(target_zone == BODY_ZONE_HEAD && B && B.host == target)
		user.visible_message(
			span_notice("[user] извлека[pluralize_ru(user.gender, "ет", "ют")] [B.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
			span_notice("Вы извлекаете [B.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		)
		add_attack_logs(user, target, "Surgically removed [B]. INTENT: [uppertext(user.a_intent)]")
		B.leave_host()
		return SURGERY_STEP_CONTINUE

	if(!extracting || extracting.owner != target)
		user.visible_message(
			span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [tool.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], ничего не извлекая."),
			span_notice("Вы достаёте [tool.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], ничего не извлекая."),
		)
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		span_notice("[user] извлека[pluralize_ru(user.gender, "ет", "ют")] [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы извлекаете [extracting.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
	)

	add_attack_logs(user, target, "Surgically removed [extracting.name]. INTENT: [uppertext(user.a_intent)]")
	spread_germs_to_organ(extracting, user, tool)
	var/obj/item/thing = extracting.remove(target)
	if(!QDELETED(thing)) // some "organs", like egg infections, can have I.remove(target) return null, and so we can't use "thing" in that case
		if(istype(thing))
			thing.forceMove(get_turf(target))
			user.put_in_hands(thing, ignore_anim = FALSE)
		else
			thing.forceMove(get_turf(target))

	target.update_icons()

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/extract/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/body_zone = target.get_organ(target_zone)
	var/obj/item/organ/internal/affected = target.get_organ(user.zone_selected)
	if(extracting && extracting.owner == target)
		if(affected)
			user.visible_message(
				span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] [affected.declent_ru(ACCUSATIVE)] [target]!"),
				span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] [affected.declent_ru(ACCUSATIVE)] [target]!"),
			)
			target.apply_damage(20, def_zone = affected)
		else
			user.visible_message(
				span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] [body_zone.declent_ru(ACCUSATIVE)] [target]!"),
				span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] [body_zone.declent_ru(ACCUSATIVE)] [target]!"),
			)
		return SURGERY_STEP_RETRY
	else
		user.visible_message(
			span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [tool.declent_ru(ACCUSATIVE)] из [body_zone.declent_ru(GENITIVE)] [target], ничего не извлекая."),
			span_notice("Вы достаёте [tool.declent_ru(ACCUSATIVE)] из [body_zone.declent_ru(GENITIVE)] [target], ничего не извлекая."),
		)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/implant
	name = "трансплантация органа"
	begin_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/organ/internal = 100,
		/obj/item/reagent_containers/food/snacks/organ = 0  // there for the flavor text
	)

/datum/surgery_step/internal/manipulate_organs/implant/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/reagent_containers/food/snacks/organ))
		user.balloon_alert(user, "орган укушен!")
		return SURGERY_BEGINSTEP_SKIP

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/organ/internal/organ = tool
	if(!istype(organ))
		// dunno how you got here but okay
		return SURGERY_BEGINSTEP_SKIP

	if(!organ.can_insert(user, target)) // checks species whitelist and special organ restrictions
		return SURGERY_BEGINSTEP_SKIP

	if(target_zone != organ.parent_organ_zone || target.get_organ_slot(organ.slot))
		user.balloon_alert(user, "нет места под орган!")
		return SURGERY_BEGINSTEP_SKIP

	if(isskeleton(target) && istype(organ, /obj/item/organ/internal/brain) && !istype(organ, /obj/item/organ/internal/brain/golem))
		user.balloon_alert(user, "нет места под орган!")
		return SURGERY_BEGINSTEP_SKIP

	if(organ.damage > (organ.max_damage * 0.75))
		user.balloon_alert(user, "орган слишком повреждён!")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(organ) && !affected)
		user.balloon_alert(user, "цель уже имеет этот орган!")
		return SURGERY_BEGINSTEP_SKIP

	if((istype(organ, /obj/item/organ/internal/cyberimp)) && HAS_TRAIT(target, TRAIT_NO_CYBERIMPLANTS))
		user.balloon_alert(user, "несовместимо с организмом!")
		return SURGERY_BEGINSTEP_SKIP

	if((organ.status == ORGAN_ROBOT) && HAS_TRAIT(target, TRAIT_NO_ROBOPARTS))
		user.balloon_alert(user, "несовместимо с организмом!")
		return SURGERY_BEGINSTEP_SKIP

	if(affected)
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] трансплантировать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
			span_notice("Вы начинаете трансплантировать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		)
		target.custom_pain("Кто-то копается в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)]!")
	else
		user.visible_message(
			span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] трансплантировать [tool.declent_ru(ACCUSATIVE)] в [parse_zone(target_zone)] [target]."),
			span_notice("Вы начинаете трансплантировать [tool.declent_ru(ACCUSATIVE)] в [parse_zone(target_zone)] [target]."),
		)
	return ..()

/datum/surgery_step/internal/manipulate_organs/implant/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!istype(tool))
		return SURGERY_STEP_INCOMPLETE
	if(!user.drop_item_ground(I))
		user.balloon_alert(user, "не получается выпустить!")
		return SURGERY_STEP_INCOMPLETE
	I.insert(target)
	if(istype(I, /obj/item/organ/internal/cyberimp))
		add_attack_logs(user, target, "Surgically inserted [I]([I.type])", ATKLOG_ALMOSTALL)
	spread_germs_to_organ(I, user, tool)

	if(affected)
		user.visible_message(
			span_notice("[user] трансплантиру[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
			span_notice("Вы трансплантируете [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		)
	else
		user.visible_message(
			span_notice("[user] трансплантиру[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в [parse_zone(target_zone)] [target]."),
			span_notice("Вы трансплантируете [tool.declent_ru(ACCUSATIVE)] в [parse_zone(target_zone)] [target]."),
		)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/implant/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(ACCUSATIVE)]!"),
	)
	var/obj/item/organ/internal/I = tool
	if(istype(I) && !I.tough)
		I.internal_receive_damage(rand(3,5))

	return SURGERY_STEP_RETRY


/datum/surgery_step/internal/manipulate_organs/clean
	name = "дезинфекция"
	begin_sound = 'sound/surgery/bonegel.ogg'
	end_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/syringe = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

/datum/surgery_step/internal/manipulate_organs/clean/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/reagent_containers/container = tool

	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)

	for(var/obj/item/organ/internal/organ as anything in get_organ_list(target_zone, target, affected))
		if(container.reagents.total_volume <= 0) //end_step handles if there is not enough reagent
			user.balloon_alert(user, "пусто!")
			return SURGERY_BEGINSTEP_SKIP

		var/msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] выливать содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target]."
		var/self_msg = "Вы начинаете выливать содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target]."
		if(istype(container, /obj/item/reagent_containers/syringe))
			msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] вкалывать содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target]."
			self_msg = "Вы начинаете вкалывать содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target]."
		user.visible_message(span_notice(msg), span_notice(self_msg))
		target.custom_pain("Вы чувствуете жгучую боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)]!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/clean/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return SURGERY_STEP_INCOMPLETE
	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents

	var/ethanol = 0 //how much alcohol is in the thing
	var/spaceacillin = 0 //how much actual antibiotic is in the thing
	var/mito_tot = 0 // same for mito, thanks farie


	if(length(R.reagent_list))
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= length(R.reagent_list)

		mito_tot = R.get_reagent_amount("mitocholide")
		spaceacillin = R.get_reagent_amount("spaceacillin")


	for(var/obj/item/organ/internal/organ as anything in get_organ_list(target_zone, target, affected))
		if(organ.germ_level < INFECTION_LEVEL_ONE / 2 && !(organ.is_dead()))  // not dead, don't need to inject mito either
			user.balloon_alert(user, "обработка не требуется!")
			continue
		if(!spaceacillin && !ethanol && !mito_tot)
			user.balloon_alert(user, "нечем обрабатывать!")
			break
		var/success = FALSE
		if(organ.germ_level >= INFECTION_LEVEL_ONE / 2)
			// spacecillin completely cures infections if there is enough, ethanol just reduces the infection strength by the amount used.
			if(spaceacillin || ethanol)
				if(spaceacillin >= GHETTO_DISINFECT_AMOUNT)
					organ.germ_level = 0
				else
					organ.germ_level = max(organ.germ_level-ethanol, 0)
				success = TRUE // we actually injected some chemicals

			else if(!(organ.is_dead())) // Not dead and got nothing to disinfect the organ with. Don't waste the other chems
				user.balloon_alert(user, "нечем обрабатывать!")
				continue

		var/mito_trans
		if(mito_tot && (organ.is_dead()) && !organ.is_robotic())
			mito_trans = min(mito_tot, C.amount_per_transfer_from_this / length(R.reagent_list)) // How much mito is actually transfered
			success = TRUE
		if(!success)
			user.balloon_alert(user, "нечем обрабатывать!")
			continue

		// now try actually injecting.

		if(istype(C, /obj/item/reagent_containers/syringe))
			user.visible_message(
				span_notice("[user] вкалыва[pluralize_ru(user.gender, "ет", "ют")] содержимое [tool.declent_ru(GENITIVE)] в [organ.declent_ru(ACCUSATIVE)] [target]."),
				span_notice("Вы вкалываете содержимое [tool.declent_ru(GENITIVE)] в [organ.declent_ru(ACCUSATIVE)] [target].")
			)
		else
			user.visible_message(
				span_notice("[user] вылива[pluralize_ru(user.gender, "ет", "ют")] содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target]."),
				span_notice("Вы выливаете содержимое [tool.declent_ru(GENITIVE)] на [organ.declent_ru(ACCUSATIVE)] [target].")
			)

		R.reaction(target, REAGENT_INGEST, R.total_volume / C.amount_per_transfer_from_this)
		R.trans_to(target, C.amount_per_transfer_from_this)

		if(mito_trans)
			mito_tot -= mito_trans
			if(organ.is_robotic()) // Get out cyborg people
				continue
			if(mito_trans >= MITO_REVIVAL_COST)
				organ.rejuvenate() // Just like splashing it onto it
				user.visible_message(span_warning("[capitalize(organ.declent_ru(NOMINATIVE))] восстанавлива[pluralize_ru(organ.gender, "ет", "ют")]ся прямо на глазах под воздействием митоколида!"))
			else
				user.balloon_alert(user, "недостаточно митоколида!")

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/internal/manipulate_organs/clean/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/reagent_containers/C = tool
	var/datum/reagents/R = C.reagents
	var/ethanol = 0 //how much alcohol is in the thing

	if(length(R.reagent_list))
		for(var/datum/reagent/consumable/ethanol/alcohol in R.reagent_list)
			ethanol += alcohol.alcohol_perc * 300
		ethanol /= length(C.reagents.reagent_list)

	for(var/obj/item/organ/internal/organ as anything in target.get_organs_zone(target_zone))
		organ.germ_level = max(organ.germ_level-ethanol, 0)
		organ.internal_receive_damage(rand(4, 8))

	R.trans_to(target, GHETTO_DISINFECT_AMOUNT * 10)
	R.reaction(target, REAGENT_INGEST)

	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, разливая содержимое [tool.declent_ru(GENITIVE)] на [affected ? "[affected.declent_ru(ACCUSATIVE)] " : ""][target]!"),
		span_warning("Вы дёргаете рукой, разливая содержимое [tool.declent_ru(GENITIVE)] на [affected ? "[affected.declent_ru(ACCUSATIVE)] " : ""][target]!"),
	)
	// continue here since we want to keep moving in the surgery
	return SURGERY_STEP_CONTINUE

// FINISH
/datum/surgery_step/internal/manipulate_organs/finish
	name = "закрытие краёв раны"
	begin_sound = 'sound/surgery/retractor1.ogg'
	end_sound = 'sound/surgery/retractor2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 90
	)

/datum/surgery_step/internal/manipulate_organs/finish/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg
	var/self_msg
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] вставлять кости грудной клетки [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете вставлять кости грудной клетки [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_HEAD)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] вставлять кости черепа [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете вставлять кости черепа [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
	else
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] закрывать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете закрывать края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."

	user.visible_message(span_notice(msg), span_notice(self_msg))

	if(target && affected)
		target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")

	return ..()

/datum/surgery_step/internal/manipulate_organs/finish/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg
	var/self_msg
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] вставля[pluralize_ru(user.gender, "ет", "ют")] кости грудной клетки [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы вставляете кости грудной клетки [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	if(target_zone == BODY_ZONE_HEAD)
		msg = "[user] вставля[pluralize_ru(user.gender, "ет", "ют")] кости черепа [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы вставляете кости черепа [target] обратно, используя [tool.declent_ru(ACCUSATIVE)]."
		affected.open = ORGAN_ORGANIC_ENCASED_OPEN
	else
		msg = "[user] закрыва[pluralize_ru(user.gender, "ет", "ют")] края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы закрываете края раны на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."

	user.visible_message(span_notice(msg), span_notice(self_msg))
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/internal/manipulate_organs/finish/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg
	var/self_msg
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, ломая [tool.declent_ru(INSTRUMENTAL)] кости грудной клетки [target]!"
		self_msg = "Вы дёргаете рукой, ломая [tool.declent_ru(INSTRUMENTAL)] кости грудной клетки [target]!"
		affected.fracture()
	if(target_zone == BODY_ZONE_HEAD)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, ломая [tool.declent_ru(INSTRUMENTAL)] кости черепа [target]!"
		self_msg = "Вы дёргаете рукой, ломая [tool.declent_ru(INSTRUMENTAL)] кости черепа [target]!"
		affected.fracture()
	else
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, разрывая [tool.declent_ru(INSTRUMENTAL)] кожу на [affected.declent_ru(PREPOSITIONAL)] [target]!"
		self_msg = "Вы дёргаете рукой, разрывая [tool.declent_ru(INSTRUMENTAL)] кожу на [affected.declent_ru(PREPOSITIONAL)] [target]!"
	target.apply_damage(20, def_zone = affected)
	user.visible_message(span_warning(msg), span_warning(self_msg))
	return SURGERY_STEP_RETRY

//////////////////////////////////////////////////////////////////
//						SPESHUL AYLIUM STUPS					//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/saw_carapace
	name = "распиливание панциря"
	begin_sound = 'sound/surgery/saw1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SAW = 100,
		/obj/item/melee/energy/sword/cyborg/saw = 100,
		/obj/item/primitive_saw = 100,
		/obj/item/hatchet = 90,
		/obj/item/circular_saw_blade = 80,
		/obj/item/wirecutters = 70
	)

	time = 5.4 SECONDS

/datum/surgery_step/saw_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] распиливать панцирь на [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете распиливать панцирь на [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
	)
	return ..()

/datum/surgery_step/saw_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] распилива[pluralize_ru(user.gender, "ет", "ют")] панцирь на [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы распиливаете панцирь на [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/saw_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] панцирь на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] панцирь на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
	)

	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/cut_carapace
	name = "разрезание панциря"
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
		/obj/item/pen/edagger = 6
	)

	time = 1.6 SECONDS

/datum/surgery_step/cut_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] делать надрез на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете делать надрез на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
		)
	return ..()

/datum/surgery_step/cut_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] дела[pluralize_ru(user.gender, "ет", "ют")] надрез на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы делаете надрез на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cut_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, проводя лезвием [tool.declent_ru(GENITIVE)] по панцирю на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, проводя лезвием [tool.declent_ru(GENITIVE)] по панцирю на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(10, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/retract_carapace
	name = "расширение краёв раны на панцире"
	begin_sound = 'sound/surgery/retractor1.ogg'
	end_sound = 'sound/surgery/retractor2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser/manager = 100,
		TOOL_RETRACTOR = 100,
		/obj/item/crowbar = 90,
		/obj/item/kitchen/utensil/fork = 60
	)

	time = 2.4 SECONDS

/datum/surgery_step/retract_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	var/self_msg = "Вы начинаете раздвигать края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете раздвигать органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] начина[pluralize_ru(user.gender, "ет", "ют")] раздвигать органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы начинаете раздвигать органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	return ..()

/datum/surgery_step/retract_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	var/self_msg = "Вы раздвигаете края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы раздвигаете органы в грудной клетке [target], используя [tool.declent_ru(ACCUSATIVE)]."
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] раздвига[pluralize_ru(user.gender, "ет", "ют")] органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
		self_msg = "Вы раздвигаете органы в брюшной полости [target], используя [tool.declent_ru(ACCUSATIVE)]."
	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/retract_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target]!"
	var/self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target]!"
	if(target_zone == BODY_ZONE_CHEST)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в грудной клетке [target]!"
		self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в грудной клетке [target]!"
	if(target_zone == BODY_ZONE_PRECISE_GROIN)
		msg = "[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в брюшной полости [target]!"
		self_msg = "Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] органы в брюшной полости [target]!"
	user.visible_message(msg, self_msg, chat_message_type = MESSAGE_TYPE_COMBAT)
	return SURGERY_STEP_RETRY

// redefine cauterize for every step because of course it relies on get_organ()
/datum/surgery_step/generic/seal_carapace
	name = "прижигание краёв раны на панцире"
	begin_sound = 'sound/surgery/cautery1.ogg'
	end_sound = 'sound/surgery/cautery2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/generic/seal_carapace/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] прижигать края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете прижигать края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете сильное жжение в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/generic/seal_carapace/end_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] прижига[pluralize_ru(user.gender, "ет", "ют")] края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы прижигаете края раны на панцире на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/generic/seal_carapace/fail_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, оставляя [tool.declent_ru(INSTRUMENTAL)] небольшой ожог на панцире на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, оставляя [tool.declent_ru(INSTRUMENTAL)] небольшой ожог на панцире на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(3, BURN, target_zone)
	return SURGERY_STEP_RETRY

#undef MITO_REVIVAL_COST
