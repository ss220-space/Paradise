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


//---- Rust Passive: "Rusted Gait" ("Ржавая Поступь")
// Level 1 - on-rust regen + baton-knockdown resist (leeching walk), granted on picking the path.
// Level 2 - you stand firm: can't be shoved or pulled around (granted on the blade upgrade).
// Level 3 - the rust is in your bones: baton-knockdown resistance everywhere, even off rust (on ascension).
/datum/status_effect/heretic_passive/rust
	id = "heretic_passive_rust"
	name = "Ржавая Поступь"
	passive_descriptions = list(
		"Стоя на ржавчине, вы исцеляетесь, восстанавливаете выносливость и сопротивляетесь оглушению дубинками.",
		"Вы стоите как влитой — вас больше нельзя оттолкнуть или утащить.",
		"Ржавчина въелась в вас навсегда — сопротивление оглушению дубинками теперь действует везде.",
	)


/datum/status_effect/heretic_passive/rust/on_apply()
	. = ..()
	if(!.)
		return
	owner.AddElement(/datum/element/leeching_walk)


/datum/status_effect/heretic_passive/rust/level_upgrade()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/rust/level_final()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/rust/on_remove()
	owner.RemoveElement(/datum/element/leeching_walk)
	owner.remove_traits(list(TRAIT_PUSHIMMUNE, TRAIT_BATON_RESISTANCE), TRAIT_STATUS_EFFECT(id))
	return ..()
