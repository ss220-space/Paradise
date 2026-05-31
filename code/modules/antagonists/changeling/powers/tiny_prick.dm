/datum/action/changeling/sting
	name = "Маленький хоботок"
	desc = "Уколоть"
	req_human = TRUE
	var/sting_icon = null
	/// A middle click override used to intercept changeling stings performed on a target.
	var/datum/middleClickOverride/callback_invoker/click_override

/datum/action/changeling/sting/New(Target)
	. = ..()
	click_override = new(CALLBACK(src, PROC_REF(try_to_sting)))

/datum/action/changeling/sting/Destroy(force)
	if(cling.owner.current && cling.owner.current.middleClickOverride == click_override) // this is a very scuffed way of doing this honestly
		cling.owner.current.middleClickOverride = null
	QDEL_NULL(click_override)
	if(cling.chosen_sting == src)
		cling.chosen_sting = null
	return ..()

/datum/action/changeling/sting/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return

	if(!ischangeling(owner) || !ishuman(owner))
		owner.balloon_alert(owner, "неподходящая форма")
		return

	if(!cling.chosen_sting)
		set_sting()
	else
		unset_sting()

/datum/action/changeling/sting/proc/set_sting()
	var/mob/living/user = owner
	to_chat(user, span_notice("Мы готовы уколоть жертву, используйте <b>Alt+Click</b> или среднию кнопку мыши на жертве для укола."))
	user.middleClickOverride = click_override
	cling.chosen_sting = src
	user.hud_used.lingstingdisplay.icon_state = sting_icon
	user.hud_used.lingstingdisplay.invisibility = 0

/datum/action/changeling/sting/proc/unset_sting()
	var/mob/living/user = owner
	to_chat(user, span_warning("Мы спрятали наш хоботок, теперь мы не можем им уколоть."))
	user.middleClickOverride = null
	cling.chosen_sting = null
	user.hud_used.lingstingdisplay.icon_state = null
	user.hud_used.lingstingdisplay.invisibility = INVISIBILITY_ABSTRACT

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..() || !iscarbon(target) || !isturf(user.loc))
		return FALSE

	if(user == target)
		user.balloon_alert(user, "нельзя уколоть себя")
		return FALSE

	if(!cling.chosen_sting)
		user.balloon_alert(user, "хоботок не готов")
		return FALSE

	var/target_distance = get_dist(user, target)
	if(target_distance > cling.sting_range) // Too far, don't bother pathfinding
		user.balloon_alert(user, "жертва слишком далеко!")
		return FALSE

	if(target_distance && !length(get_path_to(user, target, max_distance = cling.sting_range, simulated_only = FALSE, skip_first = FALSE))) // If they're not on the same turf, check if it can even reach them.
		user.balloon_alert(user, "что-то мешает хоботку!")
		return FALSE

	if(ismachineperson(target))
		user.balloon_alert(user, "невозможно уколоть")
		return FALSE

	if(ischangeling(target))
		sting_feedback(user, target)
		take_chemical_cost()
		return FALSE

	return TRUE

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return FALSE

	user.balloon_alert(user, "скрытно укололи [target.name]")
	if(ischangeling(target))
		target.balloon_alert(target, "вас легонько укололи")
		add_attack_logs(user, target, "Unsuccessful sting (changeling)")
	return TRUE

/**
 * Extract DNA Sting
 */

/datum/action/changeling/sting/extract_dna
	name = "Хоботок извлечения"
	desc = "Мы скрытно уколем  жертву и украдём её ДНК."
	helptext = "Украдёт ДНК жертвы, позволяя трансформироваться в неё."
	button_icon_state = "sting_extract"
	sting_icon = "sting_extract"
	power_type = CHANGELING_INNATE_POWER

/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		return cling.can_absorb_dna(target)

/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	add_attack_logs(user, target, "Extraction sting (changeling)")
	if(!cling.get_dna(target.dna))
		cling.absorb_dna(target)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/**
 * Transformation Sting
 */

/datum/action/changeling/sting/transformation
	name = "Хоботок трансформации"
	desc = "Мы скрытно уколем  гуманоида и введём ретровирус, который заставит жертву трансформироваться. Требует 50 химикатов."
	helptext = "Жертва трансформируется подобно нам. Последствия будут очевидны для жертвы."
	button_icon_state = "sting_transform"
	sting_icon = "sting_transform"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 2
	chemical_cost = 50
	/// Currently selected DNA
	var/datum/dna/selected_dna = null
	/// Typecache of the blacklisted species
	var/static/list/blacklisted_species = list(
		SPECIES_MACNINEPERSON = TRUE,
		SPECIES_PLASMAMAN = TRUE,
		SPECIES_VOX = TRUE,
	)

/datum/action/changeling/sting/transformation/Destroy(force)
	selected_dna = null
	return ..()

/datum/action/changeling/sting/transformation/Trigger(mob/clicker, trigger_flags)
	if(!ishuman(owner))
		owner.balloon_alert(owner, "неподходящая форма")
		return

	if(cling?.chosen_sting)
		unset_sting()
		return

	selected_dna = cling.select_dna("Выбрать ДНК для жертвы: ", "ДНК для жертвы")
	if(!selected_dna)
		return

	if(blacklisted_species[selected_dna.species.name] || selected_dna.species.is_monkeybasic)
		owner.balloon_alert(owner, "неподходящая ДНК")
		return

	..()

/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/target)
	if(!..())
		return FALSE

	if(!ishuman(target) || HAS_TRAIT(target, TRAIT_HUSK))
		user.balloon_alert(user, "неподходящая жертва")
		return FALSE

	if(HAS_TRAIT(target, TRAIT_NO_DNA))
		user.balloon_alert(user, "жертва без ДНК")
		return FALSE

	return TRUE

/datum/action/changeling/sting/transformation/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Transformation sting (changeling) (new identity is [selected_dna.real_name])")
	if(iscarbon(target) && (target.status_flags & CANWEAKEN))
		var/mob/living/carbon/carbon = target
		carbon.do_jitter_animation(500)

	target.visible_message(
		span_danger("[target] начинает биться в конвульсиях!"),
		span_userdanger("Вы чувствуете укол и начинаете биться в конвульсиях!"),
	)

	addtimer(CALLBACK(src, PROC_REF(victim_transformation), target, selected_dna), 10 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/transformation/proc/victim_transformation(mob/target, datum/dna/DNA)
	if(QDELETED(target) || QDELETED(DNA))
		return

	transform_dna(target, DNA)

/**
 * Mute Sting
 */

/datum/action/changeling/sting/mute
	name = "Хоботок безмолвия"
	desc = "Мы скрытно уколем  жертву и она полностью лишится возможности говорить на короткое время. Требует 20 химикатов."
	helptext = "Не даёт понять жертве о том, что она не может говорить, пока она не попытается сделать это."
	dna_cost = 1
	chemical_cost = 20
	button_icon_state = "sting_mute"
	sting_icon = "sting_mute"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	add_attack_logs(user, target, "Mute sting (changeling)")
	target.AdjustSilence(60 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/**
 * Blind Sting
 */

/datum/action/changeling/sting/blind
	name = "Хоботок слепоты"
	desc = "Мы скрытно уколем  жертву и она временно ослепнет. Требует 20 химикатов."
	helptext = "На 60 секунд полностью ослепит жертву и на 120 секунд оставит размытое зрение."
	dna_cost = 1
	chemical_cost = 20
	button_icon_state = "sting_blind"
	sting_icon = "sting_blind"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/blind/sting_action(mob/living/user, mob/living/target)
	add_attack_logs(user, target, "Blind sting (changeling)")
	to_chat(target, span_danger("Ваши глаза ужасно щиплет!"))
	if(!HAS_TRAIT_NOT_FROM(target, TRAIT_NEARSIGHTED, CHANGELING_TRAIT))
		ADD_TRAIT(target, TRAIT_NEARSIGHTED, CHANGELING_TRAIT)
		if(!HAS_TRAIT_NOT_FROM(target, TRAIT_NEARSIGHTED, CHANGELING_TRAIT))
			target.update_nearsighted_effects()
	target.EyeBlind(60 SECONDS)
	target.EyeBlurry(120 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/**
 * Hallucination Sting
 */

/datum/action/changeling/sting/LSD
	name = "Хоботок галлюцинаций"
	desc = "Мы скрытно уколем  жертву и посеем ужас в ней. Требует 20 химикатов."
	helptext = "Через 10 секунд у жертвы начнутся галлюцинации на 300 секунд."
	dna_cost = 1
	chemical_cost = 20
	button_icon_state = "sting_lsd"
	sting_icon = "sting_lsd"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/LSD/sting_action(mob/user, mob/living/carbon/target)
	add_attack_logs(user, target, "LSD sting (changeling)")
	addtimer(CALLBACK(src, PROC_REF(start_hallucinations), target, 300 SECONDS), 10 SECONDS)
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/sting/LSD/proc/start_hallucinations(mob/living/carbon/target, amount)
	if(!QDELETED(target))
		target.Hallucinate(amount)

/**
 * Cryogenic Sting
 */

/datum/action/changeling/sting/cryo //Enable when mob cooling is fixed so that frostoil actually makes you cold, instead of mostly just hungry.
	name = "Криогенный хоботок"
	desc = "Мы скрытно уколем  жертву химическим коктейлем, который будет замораживать её изнутри. Требует 20 химикатов."
	helptext = "Укол незаметный, но жертва начнёт быстро замерзать, что будет заметно."
	dna_cost = 1
	chemical_cost = 20
	button_icon_state = "sting_cryo"
	sting_icon = "sting_cryo"
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	add_attack_logs(user, target, "Cryo sting (changeling)")
	if(target.reagents)
		target.reagents.add_reagent("frostoil", 30)
		target.adjust_bodytemperature(-(100 * TEMPERATURE_DAMAGE_COEFFICIENT))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
