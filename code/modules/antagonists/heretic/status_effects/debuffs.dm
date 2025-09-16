// AMOK
/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	to_chat(owner, span_boldwarning("Вы чувствуете, как вас переполняет неконтролируемая ярость!"))
	return TRUE

/datum/status_effect/amok/tick(seconds_between_ticks)
	var/old_intent = owner.a_intent
	owner.a_intent_change(INTENT_HARM)

	// If we're holding a gun, expand the range a bit.
	// Otherwise, just look for adjacent targets
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
	tick_interval = 1 SECONDS

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
			// Don't fully kill liver that's important
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_LIVER, 10, 90)

		if(40 to 50)
			// Don't fully kill heart that's important
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_HEART, 10, 90)

		if(50 to 60)
			// You can fully kill the stomach that's not crucial
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_STOMACH, 10)

		if(60 to 70)
			// Same with eyes
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_EYES, 5)

		if(70 to 80)
			// And same with ears
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_EARS, 10)

		if(80 to 90)
			// But don't fully kill lungs that's usually important
			human_owner.adjustOrganLoss(INTERNAL_ORGAN_LUNGS, 10, 90)

		if(90 to 95)
			// And definitely don't fully kil brains
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

// Last Resort
/datum/status_effect/heretic_lastresort
	id = "heretic_lastresort"
	alert_type = /atom/movable/screen/alert/status_effect/heretic_lastresort
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = -1

/atom/movable/screen/alert/status_effect/heretic_lastresort
	name = "Последний Шанс"
	desc = "Голова кружится, сердце бьется на пределе своих возможностей, готовое отказать в любой момент! Бегите в безопасное место!"
	icon_state = "lastresort"

/datum/status_effect/heretic_lastresort/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_userdanger("Вы на грани потери сознания, бегите!"))
	return TRUE

/datum/status_effect/heretic_lastresort/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.Sleeping(20 SECONDS)



/// Used by moon heretics to make people mad
/datum/status_effect/moon_converted
	id = "moon converted"
	alert_type = /atom/movable/screen/alert/status_effect/moon_converted
	duration = -1
	status_type = STATUS_EFFECT_REPLACE
	///used to track damage
	var/damage_sustained = 0
	///overlay used to indicate that someone is marked
	var/mutable_appearance/moon_insanity_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "moon_insanity_overlay"

/atom/movable/screen/alert/status_effect/moon_converted
	name = "Подчиненный Луне"
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
	// Heals them so people who are in crit can have this affect applied on them and still be of some use for the heretic
	owner.adjustBruteLoss( -150)
	owner.adjustFireLoss(-150)

	var/datum/objective/custom_objective = new("Вы познали правду! Убейте всех кого сможете! \
												Ведите себя при этом как можно более ненормально!")

	if(owner.mind)
		custom_objective.needs_target = FALSE
		custom_objective.owner = owner.mind
		owner.mind.objectives += custom_objective
		var/list/messages = owner.mind.prepare_announce_objectives()
		to_chat(owner, chat_box_red(messages.Join("<br>")))

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

	// Stamina damage is funky so we will ignore it
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
	// Span warning and unconscious so they realize they aren't evil anymore
	to_chat(owner, span_warning("Ваш разум очищен от влияния Мансуса."))
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	owner.Sleeping(5 SECONDS)
	log_game("[key_name_log(owner)] is no longer insane.")
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.update_appearance(UPDATE_OVERLAYS)
	return ..()


/atom/movable/screen/alert/status_effect/moon_converted
	name = "Подчиненный луне"
	desc = "Они ЛГУТ, УБЕЙТЕ ИХ ВСЕХ!!! ЛЖЕЦЫ СОЛНЦА ДОЛЖНЫ СТРАДАТЬ!!!"
	icon_state = "moon_insanity"
