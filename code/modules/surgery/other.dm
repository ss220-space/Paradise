//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "Санация"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
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

/datum/surgery/bleeding
	name = "Восстановление повреждённых сосудов"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
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

/datum/surgery/bleeding/special
	name = "Восстановление повреждённых сосудов"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	restricted_speciestypes = list(/datum/species/wryn, /datum/species/kidan, /datum/species/plasmaman)

/datum/surgery/bleeding/plasmaman
	name = "Восстановление повреждённых сосудов (Плазмолюд)"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ/plasma,
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
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/bleeding/insect
	name = "Восстановление повреждённых сосудов (Инсектоид)"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	target_speciestypes = list(/datum/species/wryn, /datum/species/kidan)
	restricted_speciestypes = null

/datum/surgery/debridement
	name = "Восстановление мёртвых тканей"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/fix_dead_tissue,
		/datum/surgery_step/treat_necrosis,
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
	requires_organic_bodypart = TRUE

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.has_internal_bleeding())
		return TRUE
	return FALSE


/datum/surgery/debridement/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected.is_dead())
		return FALSE
	return TRUE


/datum/surgery_step/fix_vein
	name = "заживление кровеносных сосудов"
	begin_sound = 'sound/surgery/fixovein1.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_FIXOVEIN = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 3.2 SECONDS

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.has_internal_bleeding())
		user.balloon_alert(user, "сосуды в норме!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] заживлять повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете заживлять повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()


/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] заживля[pluralize_ru(user.gender, "ет", "ют")] повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы заживляете повреждённые сосуды в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	affected.stop_internal_bleeding()
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, со всей силы засовывая [tool.declent_ru(ACCUSATIVE)] глубоко в рану на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(5, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "удаление мёртвой плоти"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60
	)

	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 1.6 SECONDS

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] срезать и удалять мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете срезать и удалять мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] среза[pluralize_ru(user.gender, "ет", "ют")] и удаля[pluralize_ru(user.gender, "ет", "ют")] мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы срезаете и удаляете мёртвую плоть в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_ORGANIC_OPEN

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прорезая [tool.declent_ru(INSTRUMENTAL)] ткань в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, прорезая [tool.declent_ru(INSTRUMENTAL)] ткань в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/treat_necrosis
	name = "обработка омертвелых тканей"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

	can_infect = FALSE
	blood_level = SURGERY_BLOODSPREAD_NONE

	time = 2.4 SECONDS


/datum/surgery_step/treat_necrosis/tool_check(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message(
			span_notice("[user] нерешительно смотр[pluralize_ru(user.gender, "ит", "ят")] на [tool.declent_ru(ACCUSATIVE)], ничего не предпринимая."),
			span_notice("Вы нерешительно смотрите на [tool.declent_ru(ACCUSATIVE)]. Кажется, что [genderize_ru(tool.gender, "он", "она", "оно", "они")] не содержат митоколида."),
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
		return FALSE

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!(affected.is_dead()))
		user.balloon_alert("обработка не требуется!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] обрабатывать митоколидом омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете обрабатывать митоколидом омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Вы чувствуете острую боль в [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/reagent_containers/container = tool
	var/mitocholide = FALSE

	if(container.reagents.has_reagent("mitocholide"))
		mitocholide = TRUE

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(mitocholide)
			affected.unnecrotize()

		user.visible_message(
			span_notice("[user] вылива[pluralize_ru(user.gender, "ет", "ют")] [trans] единиц[declension_ru(trans, "у", "ы", "")] вещества из [tool.declent_ru(GENITIVE)] на омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			span_notice("Вы выливаете [trans] единиц[declension_ru(trans, "у", "ы", "")] вещества из [tool.declent_ru(GENITIVE)] на омертвелые ткани в [affected.declent_ru(PREPOSITIONAL)] [target]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, проливая [trans] единиц[declension_ru(trans, "у", "ы", "")] вещества из [tool.declent_ru(GENITIVE)] мимо раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, проливая [trans] единиц[declension_ru(trans, "у", "ы", "")] вещества из [tool.declent_ru(GENITIVE)] мимо раны на [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	//no damage or anything, just wastes medicine
	return SURGERY_STEP_RETRY

//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling						//
//////////////////////////////////////////////////////////////////
/datum/surgery/remove_thrall
	name = "Удаление теневой опухоли"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/internal/dethrall,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)
	requires_organic_bodypart = TRUE

/datum/surgery/remove_thrall/synth
	name = "Отладка теневой опухоли"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/internal/dethrall,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE
	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/remove_thrall/can_start(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_thrall(target))
		return FALSE
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!B)
		// No brain to remove the tumor from
		return FALSE
	if(!LAZYIN(affected.internal_organs, B))
		return FALSE
	return TRUE


/datum/surgery_step/internal/dethrall
	name = "удаление опухоли"
	begin_sound = 'sound/items/lighter/light.ogg'
	allowed_tools = list(/obj/item/flash = 100, /obj/item/flashlight/pen = 80, /obj/item/flashlight = 40)
	blood_level = SURGERY_BLOODSPREAD_NONE
	time = 3 SECONDS

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] подносить [tool.declent_ru(ACCUSATIVE)] к ране на [affected.declent_ru(PREPOSITIONAL)] [target]."),
		span_notice("Вы начинаете подносить [tool.declent_ru(ACCUSATIVE)] к ране на [affected.declent_ru(PREPOSITIONAL)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	to_chat(target, span_boldannounceic("Ваше сознание заливает волна агонизирующей боли от обжигающего света, направленного прямо на ваш[genderize_ru(affected.gender, "", "у", "е", "и")] [affected.declent_ru(ACCUSATIVE)]!"))
	return ..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(isshadowlinglesser(target)) //Empowered thralls cannot be deconverted
		to_chat(target, span_shadowling("<b><i>ВОТ ТАК ПРОСТО?! НУ УЖ НЕТ!</i></b>"))

		user.visible_message(
			span_warning("[target] резко выгиба[pluralize_ru(target.gender, "ет", "ют")]ся, сбивая с ног [user]!"), \
			span_userdanger("[target] резко выгиба[pluralize_ru(target.gender, "ет", "ют")]ся, сбивая вас с ног!"),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

		user.SetSleeping(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.SetKnockdown(0)
		user.SetParalysis(0)
		user.set_resting(FALSE, instant = TRUE)
		user.get_up(instant = TRUE)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Weaken(12 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
		else if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Weaken(16 SECONDS)
			S.apply_damage(20, BRUTE)
			playsound(S, 'sound/effects/bang.ogg', 50, TRUE)
		return SURGERY_STEP_INCOMPLETE

	user.visible_message(
		span_warning("[user] свет[pluralize_ru(user.gender, "ит", "ят")] [tool.declent_ru(INSTRUMENTAL)] прямо на опухоль в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		span_warning("Вы светите [tool.declent_ru(INSTRUMENTAL)] прямо на опухоль в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	if(target.vision_type) //Turns off their darksight if it's still active.
		to_chat(target, span_boldannounceic("Ваши глаза заливает пелена боли, вы теряете возможность видеть в темноте!"))
		target.set_vision_override(null)
	SSticker.mode.remove_thrall(target.mind, 0)
	target.visible_message(span_warning("Кусок чёрной сочащейся плоти выпадает из [affected.declent_ru(GENITIVE)] [target]!"))
	var/obj/item/organ/thing = new /obj/item/organ/internal/shadowtumor(get_turf(target))
	thing.update_DNA(target.dna)
	user.put_in_hands(thing, ignore_anim = FALSE)
	return SURGERY_STEP_CONTINUE

