/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	to_chat(owner, span_boldwarning("Вы чувствуете, как вас переполняет неконтролируемая ярость!"))
	return TRUE

/datum/status_effect/amok/tick(seconds_between_ticks)
	var/old_intent = owner.a_intent
	owner.a_intent_change(INTENT_HARM)

	var/search_radius = isgun(owner.get_active_hand()) ? 3 : 1

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, search_radius))
		if(IS_HERETIC_OR_MONSTER(potential_target))
			continue

		targets += potential_target

	if(LAZYLEN(targets))
		log_attack("[key_name_log(owner)] attacked someone due to the amok debuff.") //the following attack will log itself
		owner.ClickOn(pick(targets))

	owner.a_intent_change(old_intent)

/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/static/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	if(!mob_overlay)
		mob_overlay = mutable_appearance('icons/effects/eldritch.dmi', "cloud_swirl", ABOVE_MOB_LAYER)

	return ..()

/datum/status_effect/cloudstruck/on_apply()
	owner.add_overlay(mob_overlay)
	ADD_TRAIT(owner, TRAIT_BLIND, id)
	owner.update_blind_effects()
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	REMOVE_TRAIT(owner, TRAIT_BLIND, id)
	owner.update_blind_effects()
	owner.cut_overlay(mob_overlay)

/datum/status_effect/corrosion_curse
	id = "corrosion_curse"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/corrosion_curse/on_apply()
	to_chat(owner, span_userdanger("Ваше тело начинает разрушаться!"))
	return TRUE

/datum/status_effect/corrosion_curse/tick(seconds_between_ticks)
	. = ..()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/human_owner = owner
	var/chance = rand(0, 100)
	switch(chance)
		if(0 to 10)
			human_owner.vomit()

		if(20 to 30)
			human_owner.Dizzy(100 SECONDS)
			human_owner.Jitter(100 SECONDS)

		if(30 to 40)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_LIVER, 10, 90)

		if(40 to 50)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_HEART, 10, 90)

		if(50 to 60)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_STOMACH, 10)

		if(60 to 70)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_EYES, 5)

		if(70 to 80)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_EARS, 10)

		if(80 to 90)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_LUNGS, 10, 90)

		if(90 to 95)
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 20, 190)

		if(95 to 100)
			human_owner.Confused(12 SECONDS)

/datum/status_effect/star_mark
	id = "star_mark"
	alert_type = /atom/movable/screen/alert/status_effect/star_mark
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	///overlay used to indicate that someone is marked
	var/mutable_appearance/cosmic_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "cosmic_ring"
	/// Storage for the spell caster
	var/datum/weakref/spell_caster

/atom/movable/screen/alert/status_effect/star_mark
	name = "Звёздная Метка"
	desc = "Кольцо над головой не позволяет вам входить в космические поля или телепортироваться через звёздные руны..."
	icon_state = "star_mark"

/datum/status_effect/star_mark/on_creation(mob/living/new_owner, mob/living/new_spell_caster)
	cosmic_overlay = mutable_appearance(effect_icon, effect_icon_state, BELOW_MOB_LAYER)
	if(new_spell_caster)
		spell_caster = WEAKREF(new_spell_caster)

	return ..()

/datum/status_effect/star_mark/Destroy()
	QDEL_NULL(cosmic_overlay)
	return ..()

/datum/status_effect/star_mark/on_apply()
	if(istype(owner, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return FALSE

	var/mob/living/spell_caster_resolved = spell_caster?.resolve()
	var/datum/antagonist/heretic_monster/monster = owner.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(spell_caster_resolved && monster && monster.master?.current == spell_caster_resolved)
		return FALSE

	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Updates the overlay of the owner
/datum/status_effect/star_mark/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	overlays += cosmic_overlay

/datum/status_effect/star_mark/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_appearance(UPDATE_OVERLAYS)
	return ..()

/datum/status_effect/star_mark/extended
	duration = 3 MINUTES

/// Used by moon heretics to make people mad
/datum/status_effect/moon_converted
	id = "moon converted"
	alert_type = /atom/movable/screen/alert/status_effect/moon_converted
	status_type = STATUS_EFFECT_REPLACE
	duration = 60 SECONDS
	///used to track damage
	var/damage_sustained = 0
	///overlay used to indicate that someone is marked
	var/mutable_appearance/moon_insanity_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "moon_insanity_overlay"
	/// The "kill everyone" objective handed out on conversion. Tracked so it's revoked when the effect ends.
	var/datum/objective/moon_objective

/atom/movable/screen/alert/status_effect/moon_converted
	name = "Подчинённый Луне"
	desc = "ОНИ ЛГУТ, ОНИ ВСЕ ЛГУТ!!! УБЕЙТЕ ИХ!!! СОЖГИТЕ ИХ!!! ЗАСТАВЬТЕ ИХ УВИДЕТЬ ПРАВДУ!!!"
	icon_state = "lastresort"


/datum/status_effect/moon_converted/on_creation()
	. = ..()
	moon_insanity_overlay = mutable_appearance(effect_icon, effect_icon_state, ABOVE_MOB_LAYER)


/datum/status_effect/moon_converted/Destroy()
	QDEL_NULL(moon_insanity_overlay)
	return ..()


/datum/status_effect/moon_converted/on_apply()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.adjustBruteLoss( -150)
	owner.adjustFireLoss(-150)

	moon_objective = new("Луна нашептала вам истину: всё вокруг — ложь, и лишь смех очистит её. \
						Убейте каждого, до кого дотянетесь, и пляшите под лунный смех. \
						И ни при каких обстоятельствах не снимайте Амулет — он есть ваша единственная правда.")

	if(owner.mind)
		moon_objective.needs_target = FALSE
		moon_objective.owner = owner.mind
		owner.mind.objectives += moon_objective
		var/list/messages = owner.mind.prepare_announce_objectives()
		to_chat(owner, custom_boxed_message("red_box center", messages.Join("<br>")))

	to_chat(owner, span_purple(("ЛУНА ПОКАЗЫВАЕТ ВАМ ПРАВДУ, А ЛЖЕЦЫ ХОТЯТ ЕЁ СКРЫТЬ, УБЕЙТЕ ИХ ВСЕХ!!!")))
	owner.balloon_alert(owner, "они. все. ЛГАЛИ!")
	owner.Sleeping(7 SECONDS)
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/moon, "[id] status effect", duration = duration, affects_us = FALSE, affects_others = TRUE)
	return TRUE

/datum/status_effect/moon_converted/proc/on_damaged(datum/source, damage, damagetype)
	SIGNAL_HANDLER

	if(damagetype == STAMINA)
		return

	damage_sustained += damage

	if(damage_sustained < 75)
		return

	qdel(src)

/datum/status_effect/moon_converted/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += moon_insanity_overlay

/datum/status_effect/moon_converted/on_remove()
	to_chat(owner, span_warning("Ваш разум очищен от влияния Обители."))
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	owner.Sleeping(5 SECONDS)
	log_game("[key_name_log(owner)] is no longer insane.")
	if(moon_objective)
		owner.mind?.objectives -= moon_objective
		QDEL_NULL(moon_objective)
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.update_appearance(UPDATE_OVERLAYS)
	return ..()


/datum/status_effect/moon_converted/permanent
	duration = -1

/datum/status_effect/moon_converted/permanent/on_damaged(datum/source, damage, damagetype)
	return


/datum/status_effect/eldritch_painting
	id = "eldritch_painting"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting
	duration = 10 MINUTES

/datum/status_effect/eldritch_painting/on_apply()
	if(IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	if(!ishuman(owner))
		return FALSE
	if(owner.reagents?.has_reagent(/datum/reagent/holywater))
		return FALSE
	return TRUE

/datum/status_effect/eldritch_painting/tick(seconds_between_ticks)
	if(owner.reagents?.has_reagent(/datum/reagent/holywater))
		remove_duration(3 SECONDS * seconds_between_ticks)
		return
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return
	on_tick(seconds_between_ticks)

/// Overridden per painting to apply that painting's recurring curse.
/datum/status_effect/eldritch_painting/proc/on_tick(seconds_between_ticks)
	return

/atom/movable/screen/alert/status_effect/eldritch_painting
	name = "Древняя Картина"
	desc = "Нечто оставило отпечаток в вашем разуме."
	icon = 'icons/obj/decals.dmi'
	icon_state = "eldritch_painting_debug"

/datum/status_effect/eldritch_painting/weeping
	id = "painting_weeping"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/weeping
	tick_interval = 10 SECONDS

/datum/status_effect/eldritch_painting/weeping/on_tick(seconds_between_ticks)
	if(owner.stat != CONSCIOUS)
		return
	owner.hallucinate_living("delusion")

/atom/movable/screen/alert/status_effect/eldritch_painting/weeping
	name = "Сестра и Плачущий"
	desc = "Плач эхом отдаётся в вашем разуме, разрушая рассудок! Быть может, если снова взглянуть на картину, станет легче..."
	icon_state = "eldritch_painting_weeping"

/datum/status_effect/eldritch_painting/desire
	id = "painting_desire"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/desire
	/// How much faster we lose nutrition each tick.
	var/hunger_rate = 15

/datum/status_effect/eldritch_painting/desire/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/eldritch_painting/desire/on_tick(seconds_between_ticks)
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(SPT_PROB(10, seconds_between_ticks))
		to_chat(owner, span_notice(pick(
			"Вы не можете перестать думать о сыром мясе...",
			"Вам **НУЖНО** кого-нибудь съесть.",
			"Голодные спазмы вернулись...",
			"Вы жаждете плоти.",
			"Вы умираете с голоду!",
		)))
	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

/datum/status_effect/eldritch_painting/desire/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAIT_STATUS_EFFECT(id))
	return ..()

/atom/movable/screen/alert/status_effect/eldritch_painting/desire
	name = "Фестиваль Желаний"
	desc = "Вас терзает ненасытный голод! Утолите его любой ценой! Или просто взгляните на картину и тоскуйте по обещанному ею пиршеству..."
	icon_state = "eldritch_painting_desire"

/datum/status_effect/eldritch_painting/desire/permanent
	duration = STATUS_EFFECT_PERMANENT

/datum/status_effect/eldritch_painting/beauty
	id = "painting_beauty"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/beauty
	tick_interval = 3 SECONDS
	/// Damage dealt per scratch.
	var/scratch_damage = 3

/datum/status_effect/eldritch_painting/beauty/on_tick(seconds_between_ticks)
	if(owner.incapacitated())
		return

	var/obj/item/organ/external/bodypart = owner.get_bodypart(owner.get_random_valid_zone(even_weights = TRUE))
	if(!bodypart || bodypart.is_robotic())
		return
	var/mob/living/carbon/human/scratcher = owner
	if(!length(scratcher.get_clothing_on_part(bodypart)))
		return

	owner.apply_damage(scratch_damage, BRUTE, bodypart)
	to_chat(owner, span_notice("Вы яростно расцарапываете [bodypart.declent_ru(ACCUSATIVE)] прямо сквозь одежду!"))

/atom/movable/screen/alert/status_effect/eldritch_painting/beauty
	name = "Леди за Вратами"
	desc = "Одежда скрывает истинную красоту. Сбросьте её и достигните совершенства. Или вновь узрите совершенство в той картине."
	icon_state = "eldritch_painting_beauty"

/datum/status_effect/eldritch_painting/rusting
	id = "painting_rusting"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/rusting
	tick_interval = 3 SECONDS

/datum/status_effect/eldritch_painting/rusting/on_tick(seconds_between_ticks)
	var/atom/tile = get_turf(owner)
	if(isnull(tile))
		return
	to_chat(owner, span_notice("Вы чувствуете разложение..."))
	tile.rust_heretic_act()

/atom/movable/screen/alert/status_effect/eldritch_painting/rusting
	name = "Хозяйка Ржавой Горы"
	desc = "Каждый ваш шаг разъедает землю под ногами! Всё рассыпается в прах! Быть может, вглядевшись в гору на картине, вы найдёте путь..."
	icon_state = "eldritch_painting_rust"

/datum/status_effect/rust_corruption
	id = "rust_turf_effects"
	alert_type = null
	tick_interval = 2 SECONDS

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner))
		owner.adjustBruteLoss(10 * seconds_between_ticks)
		return
	owner.Disgust(5 * seconds_between_ticks)
	owner.reagents?.remove_all(0.75 * seconds_between_ticks)
