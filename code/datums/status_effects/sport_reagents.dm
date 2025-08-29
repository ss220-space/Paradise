#define NORMAL_EFFECT 1
#define NO_EFFECT 2
#define BAD_EFFECT 3
#define VERY_BAD_EFFECT 4

// MARK: Base logic
/**
 * The effects of sports food are divided into four phases. \
 * In the first phase, sports nutrition has a normal effect. \
 * In the second, there is no effect at all. In the third, the effect becomes negative. \
 * In the fourth, it is even worse.
*/
/datum/status_effect/sport_reagents
	id = "reagent"
	alert_type = null
	/// Moment (world.time) when this status effect was applyed.
	var/start_moment
	/// Stage of status effect. (Normal effect / No effect / Negative effect / Very bad effect)
	var/cur_stage
	/// Moment when normal effect stops working.
	var/no_effect = 180 SECONDS
	/// Moment, when reagent become dangerous.
	var/bad_effect = 240 SECONDS
	/// Moment, when effects become worse.
	var/very_bad_effect = 300 SECONDS


// Add normal effects.
/datum/status_effect/sport_reagents/on_apply()
	. = ..()
	start_moment = world.time
	set_stage(NORMAL_EFFECT)


// Remove effects of current stage.
/datum/status_effect/sport_reagents/on_remove()
	set_stage(NO_EFFECT)
	. = ..()


// Try to update stage and apply tick effects of current stage.
/datum/status_effect/sport_reagents/tick(seconds_between_ticks)
	. = ..()
	var/time = get_time()
	if(time <= no_effect)
		set_stage(NORMAL_EFFECT)
		effect_tick()
		return

	if(time <= bad_effect)
		set_stage(NO_EFFECT)
		return

	if(time <= very_bad_effect)
		set_stage(BAD_EFFECT)
		bad_effect_tick()
		return

	set_stage(VERY_BAD_EFFECT)
	very_bad_effect_tick()


// If stage changed, clear effects of old stage and apply effects of new.
/datum/status_effect/sport_reagents/proc/set_stage(new_stage)
	if(cur_stage == new_stage) // Do nothing if we don't need to update stage.
		return

	// Clear old effects.
	switch(cur_stage)
		if(NORMAL_EFFECT)
			effect_off()

		if(BAD_EFFECT)
			bad_effect_off()

		if(VERY_BAD_EFFECT)
			very_bad_effect_off()

	// Change stage.
	cur_stage = new_stage

	// Apply effects of new stage.
	switch(cur_stage)
		if(NORMAL_EFFECT)
			effect_on()

		if(BAD_EFFECT)
			bad_effect_on()

		if(VERY_BAD_EFFECT)
			very_bad_effect_on()


// Get time after effect applyment.
/datum/status_effect/sport_reagents/proc/get_time()
	return world.time - start_moment


// What we do, when reagent starts working. Mostly the same as on_apply, but more beautiful.
/datum/status_effect/sport_reagents/proc/effect_on()
	return


// What we do, when reagent stops applying it's normal effect. May be after reagent removing or after moving to second (no effect) stage.
/datum/status_effect/sport_reagents/proc/effect_off()
	return


// What we do every tick of normal effect.
/datum/status_effect/sport_reagents/proc/effect_tick()
	return


// What we do when reagent too long in body, so it started to cause negetive effects.
/datum/status_effect/sport_reagents/proc/bad_effect_on()
	return


// What we do when reagent moving to the last (very bad) stage, or being removed at "bad" stage.
/datum/status_effect/sport_reagents/proc/bad_effect_off()
	return


// What we do every tick of bad effect.
/datum/status_effect/sport_reagents/proc/bad_effect_tick()
	return


// What we do when reagent too long in body, so it started to cause very negetive effects (after just negative effects).
/datum/status_effect/sport_reagents/proc/very_bad_effect_on()
	return


// What we do when reagent being removed from body.
/datum/status_effect/sport_reagents/proc/very_bad_effect_off()
	return


// What we do every tick of very bad effect.
/datum/status_effect/sport_reagents/proc/very_bad_effect_tick()
	return


///////////////////////////////////////////////////////// REAGENTS ////////////////////////////////////////////////////////////

// MARK: Protein
/datum/status_effect/sport_reagents/protein
	id = "protein"
	var/swing_effect_mod = 1.3


/datum/status_effect/sport_reagents/protein/effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src, swing_effect_mod)


/datum/status_effect/sport_reagents/protein/effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src)


/datum/status_effect/sport_reagents/protein/bad_effect_tick()
	if(prob(3))
		to_chat(owner, span_warning("Вас мутит!"))

	if(!prob(10))
		return

	owner.AdjustDisgust(10)


/datum/status_effect/sport_reagents/protein/very_bad_effect_tick()
	if(prob(3))
		to_chat(owner, span_warning("Вас сильно мутит!"))

	if(prob(5))
		owner.Confused(5 SECONDS)

	if(!prob(60))
		return

	owner.AdjustDisgust(20)


/datum/status_effect/sport_reagents/protein/water
	id = "protein_water"
	swing_effect_mod = 1.4


/datum/status_effect/sport_reagents/protein/milk
	id = "protein_milk"
	swing_effect_mod = 1.6


// MARK: Steroids
/datum/status_effect/sport_reagents/steroids
	id = "steroids"
	no_effect = 120 SECONDS
	bad_effect = 150 SECONDS
	very_bad_effect = 180 SECONDS
	var/swing_effect_mod = 2
	var/bad_effect_stamina_mod = 1.4


/datum/status_effect/sport_reagents/steroids/effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src, swing_effect_mod)


/datum/status_effect/sport_reagents/steroids/effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src)


/datum/status_effect/sport_reagents/steroids/bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src, bad_effect_stamina_mod)


/datum/status_effect/sport_reagents/steroids/bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src)


/datum/status_effect/sport_reagents/steroids/bad_effect_tick()
	if(!prob(5))
		return

	to_chat(owner, span_warning("Вы чувствуете усталость!"))


/datum/status_effect/sport_reagents/steroids/very_bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src, bad_effect_stamina_mod)
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src, 1 / swing_effect_mod)
	owner.apply_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src, -1)


/datum/status_effect/sport_reagents/steroids/very_bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src)
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src)
	owner.remove_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src)


/datum/status_effect/sport_reagents/steroids/very_bad_effect_tick()
	if(!prob(5))
		return

	to_chat(owner, span_warning("Вы чувствуете усталость!"))


// MARK: Creatine
/datum/status_effect/sport_reagents/creatine
	id = "creatine"
	bad_effect = 210 SECONDS
	var/effect_stamina_mod = 0.8
	var/bad_swing_effect_mod = 0.7


/datum/status_effect/sport_reagents/creatine/effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src, effect_stamina_mod)


/datum/status_effect/sport_reagents/creatine/effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src)


/datum/status_effect/sport_reagents/creatine/bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src, 1 / effect_stamina_mod)


/datum/status_effect/sport_reagents/creatine/bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_stamina_mod, src)


/datum/status_effect/sport_reagents/creatine/bad_effect_tick()
	if(!prob(5))
		return

	to_chat(owner, "Вы чувствуете усталость!")


/datum/status_effect/sport_reagents/creatine/very_bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src, bad_swing_effect_mod)


/datum/status_effect/sport_reagents/creatine/very_bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/swing_effect_mod, src)


/datum/status_effect/sport_reagents/creatine/very_bad_effect_tick()
	bad_effect_tick()


/datum/status_effect/sport_reagents/creatine/liquid
	id = "creatine_liquid"
	effect_stamina_mod = 0.6
	bad_swing_effect_mod = 0.5


// MARK: Guarana
/datum/status_effect/sport_reagents/guarana
	id = "guarana"


/datum/status_effect/sport_reagents/guarana/effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src, 1)


/datum/status_effect/sport_reagents/guarana/effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src)


/datum/status_effect/sport_reagents/guarana/bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src, -1)


/datum/status_effect/sport_reagents/guarana/very_bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src)


/datum/status_effect/sport_reagents/guarana/very_bad_effect_on()
	owner.apply_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src, -2)


/datum/status_effect/sport_reagents/guarana/very_bad_effect_off()
	owner.remove_status_effect(/datum/status_effect/sport_grouped/strength_level_delta, src)


///////////////////////////////////////////////////////// Auxiliary status effects ////////////////////////////////////////////////////////////

// MARK: Auxiliary status effects
/// Mostly the same as /datum/status_effect/grouped, but with saved modifiers.
/datum/status_effect/sport_grouped
	status_type = STATUS_EFFECT_MULTIPLE //! Adds itself to sources and destroys itself if one exists already, there are never multiple
	alert_type = null
	/// Pairs {key, modifier} from different effect sources.
	var/list/sources = list()


/datum/status_effect/sport_grouped/on_creation(mob/living/new_owner, source, modifier)
	var/datum/status_effect/grouped/existing = new_owner.has_status_effect(type)
	if(!existing) // If new effect, create.
		sources[source] = modifier
		return ..()

	// Else change existing and stop creating new.
	existing.sources[source] = modifier
	qdel(src)
	return FALSE


// Remove key of source that finished applying this effect.
/datum/status_effect/sport_grouped/before_remove(source)
	sources -= source
	return !length(sources)


// Get the multiplication of all modifiers.
/datum/status_effect/sport_grouped/proc/get_mult()
	var/result = 1
	for(var/source as anything in sources)
		result *= sources[source]

	return result


// Get summ of all modifiers.
/datum/status_effect/sport_grouped/proc/get_sum()
	var/result = 0
	for(var/source as anything in sources)
		result += sources[source]

	return result


/// How effective exercising is. If multiplication of all modifiers is X, they will get X times more strength points.
/datum/status_effect/sport_grouped/swing_effect_mod
	id = "swing_effect_mod"


/// How stamina do we use when exercising. If multiplication of all modifiers is X, they will get X times more stamina damage after exercising.
/datum/status_effect/sport_grouped/swing_stamina_mod
	id = "swing_stamina_mod"


/// How our strength level changed by different sources. If multiplication of all modifiers is X, they will get X times more stamina damage after exercising.
/datum/status_effect/sport_grouped/strength_level_delta
	id = "strength_level_delta"


#undef NORMAL_EFFECT
#undef NO_EFFECT
#undef BAD_EFFECT
#undef VERY_BAD_EFFECT
