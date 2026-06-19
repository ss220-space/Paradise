// Heretic passive ("empowerment") - a path-specific buff granted when you choose your path, which
// strengthens in two further stages as you grow in power:
//   * Level 1 - applied when the path's starting knowledge is gained.
//   * Level 2 - applied when you upgrade your blade (a mid/late-game milestone).
//   * Level 3 - applied when you ascend.
// Ported (Ash only for now) and adapted from /tg/station's heretic_passive system. master220 has no
// COMSIG_HERETIC_PASSIVE_UPGRADE signals, so the heretic antag datum drives the level changes directly
// (grant_passive / set_passive_level). The effect itself only ever applies each level's effects once.

/datum/status_effect/heretic_passive
	id = "heretic_passive"
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// The heretic antag datum that owns us.
	var/datum/antagonist/heretic/heretic_datum
	/// The level we have actually applied effects up to (1-3). Kept separate from the datum's level so
	/// we never apply the same stage's effects twice (e.g. on a body transfer re-apply).
	var/applied_level = 1
	/// Display name, shown in the research UI.
	var/name = "Сила Еретика"
	/// Per-level description lines shown in the research UI (index = level).
	var/list/passive_descriptions = list(
		"Дарует пассивную способность, зависящую от вашего пути. Она усиливается по мере роста вашей силы.",
		"Ваша пассивная способность усилилась.",
		"Ваша пассивная способность достигла окончательной формы.",
	)


/datum/status_effect/heretic_passive/on_apply()
	. = ..()
	if(!.)
		return
	heretic_datum = owner.mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return FALSE
	// Catch up to the heretic's current power level (e.g. re-applied after a body transfer).
	if(heretic_datum.passive_level >= 2)
		level_upgrade()
	if(heretic_datum.passive_level >= 3)
		level_final()


/datum/status_effect/heretic_passive/on_remove()
	heretic_datum = null
	return ..()


/// Applies the level-2 ("upgrade") effects. Idempotent - returns TRUE only on the call that first applies it.
/datum/status_effect/heretic_passive/proc/level_upgrade()
	SHOULD_CALL_PARENT(TRUE)
	if(applied_level >= 2)
		return FALSE
	applied_level = 2
	// Hitting tier 2 (crafting the robe) is also when the heretic's eldritch aura ignites (tg parity).
	if(heretic_datum && !heretic_datum.unlimited_blades)
		heretic_datum.disable_blade_breaking()
	return TRUE


/// Applies the level-3 ("final") effects. Ensures the upgrade level is applied first. Idempotent.
/datum/status_effect/heretic_passive/proc/level_final()
	SHOULD_CALL_PARENT(TRUE)
	level_upgrade()
	if(applied_level >= 3)
		return FALSE
	applied_level = 3
	return TRUE


//---- Ash Passive: "Vow of Destruction"
// Level 1 - heat and ash-storm immunity (granted on picking the path).
// Level 2 - lava immunity (granted on the blade upgrade).
// Level 3 - resistance to extreme cold (granted on ascension). master220 has no high/low-pressure
//           traits like TG, so we substitute cold resistance for the final tier.
/datum/status_effect/heretic_passive/ash
	id = "heretic_passive_ash"
	name = "Клятва Разрушения"
	passive_descriptions = list(
		"Иммунитет к жару и пепельным бурям.",
		"Иммунитет к лаве.",
		"Сопротивление экстремальному холоду.",
	)


/datum/status_effect/heretic_passive/ash/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_RESIST_HEAT, TRAIT_ASHSTORM_IMMUNE), TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/ash/level_upgrade()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_LAVA_IMMUNE, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/ash/level_final()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_RESIST_COLD, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/ash/on_remove()
	owner.remove_traits(list(TRAIT_RESIST_HEAT, TRAIT_ASHSTORM_IMMUNE, TRAIT_LAVA_IMMUNE, TRAIT_RESIST_COLD), TRAIT_STATUS_EFFECT(id))
	return ..()


//---- Rust Passive: "Leeching Walk" ("Ржавая Поступь") - ported 1:1 from /tg/station, adapted to master220.
// All tiers do their work directly in on_life (scaling with our level), exactly like tg - we do NOT lean on
// /datum/element/leeching_walk (that element is still used by the Rusty Walker mob, just not by us).
// Level 1 - standing on rust heals brute/burn/tox/oxy/stamina, cuts stun duration, restores blood, purges
//           chems, and gives baton-knockdown resistance while on rust. Granted on picking the path.
// Level 2 - additionally mends fractures/internal bleeding and heals organs; healing scales up. The rust
//           strength gained alongside this tier lets you rust reinforced floors/walls.
// Level 3 - additionally regrows missing limbs; healing scales up again. Lets you rust titanium/plastitanium.
// NB: master220 has no tg wound datums or regenerate_limbs()/get_missing_limbs() - we substitute the
// engine's fracture/bleed mend and the species create_organs() limb-regrow idiom (see buffs.dm "marshal").
/datum/status_effect/heretic_passive/rust
	id = "heretic_passive_rust"
	name = "Ржавая Поступь"
	passive_descriptions = list(
		"Стоя на ржавых плитах, вы исцеляетесь и очищаете тело от химикатов.",
		"Стоя на ржавых плитах, вы затягиваете раны и исцеляете органы; теперь вы можете ржаветь укреплённые полы и стены, а лечение усилено.",
		"Стоя на ржавых плитах, вы восстанавливаете утраченные конечности; теперь вы можете ржаветь титановые и пласттитановые стены, а лечение усилено.",
	)


/datum/status_effect/heretic_passive/rust/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))


/datum/status_effect/heretic_passive/rust/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))
	REMOVE_TRAIT(owner, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))
	return ..()


/// Baton-knockdown resistance toggles with whether we're standing on rust (tg's on_move).
/datum/status_effect/heretic_passive/rust/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	var/turf/our_turf = get_turf(source)
	if(HAS_TRAIT(our_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))
	else
		REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))


/// Gradually heals us on rust, scaling with our level; tg's on_life adapted to master220's APIs.
/datum/status_effect/heretic_passive/rust/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// SSmobs.wait is 2 secs, so DELTA_WORLD_TIME is halved (matches the rest of the rust path's healing).
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5
	var/main_healing = 1 + 1 * applied_level * delta_time
	var/stam_healing = 5 + 5 * applied_level * delta_time

	var/need_mob_update = FALSE
	need_mob_update += source.adjustBruteLoss(-main_healing, updating_health = FALSE)
	need_mob_update += source.adjustFireLoss(-main_healing, updating_health = FALSE)
	need_mob_update += source.adjustToxLoss(-main_healing, updating_health = FALSE, forced = TRUE) // Slimes are people too
	need_mob_update += source.adjustOxyLoss(-main_healing, updating_health = FALSE)
	need_mob_update += source.adjustStaminaLoss(-stam_healing, updating_health = FALSE)
	if(need_mob_update)
		source.updatehealth()

	// Reduces duration of stuns/knockdowns and tops up lost blood.
	source.AdjustImmobilized((-0.5 * applied_level) * delta_time)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume = min(source.blood_volume + 2.5 * delta_time, BLOOD_VOLUME_NORMAL)

	// Purge chems off the body (tg uses purge_multiplier, which master220 reagents don't have - flat is fine).
	for(var/datum/reagent/reagent as anything in source.reagents.reagent_list)
		reagent.volume = max(0, reagent.volume - delta_time)
	source.reagents.update_total()

	if(!iscarbon(source))
		return
	var/mob/living/carbon/carbon_owner = source

	// Level 2+: mend fractures / internal bleeding (master220's "wounds") and heal organs.
	if(applied_level < 2)
		return
	if(ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		for(var/obj/item/organ/external/bodypart as anything in human_owner.bodyparts)
			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
	for(var/obj/item/organ/internal_organ as anything in carbon_owner.internal_organs)
		internal_organ.heal_internal_damage(2 * delta_time)

	// Level 3: regrow any missing limbs.
	if(applied_level < 3)
		return
	if(!ishuman(carbon_owner))
		return
	var/mob/living/carbon/human/human_owner = carbon_owner
	var/list/missing_bodyparts = list()
	for(var/limb_zone in human_owner.dna.species.has_limbs)
		if(isnull(human_owner.bodyparts_by_name[limb_zone]))
			missing_bodyparts += limb_zone
	if(length(missing_bodyparts))
		human_owner.dna.species.create_organs(human_owner, missing_bodyparts)
