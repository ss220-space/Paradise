/**
 * Swarmer ACP turret
 *
 * Slams the ground every few seconds on proximity with enemy mob,
 * dealing stamina damage, slowing with a chance, and stopping
 * reagent metabolization to all targets in specific range.
 */
/obj/structure/swarmer/acp_turret
	name = "swarmer ACP turret"
	desc = "Стационарная установка \"Свармеров\", способная оглушать и влиять на магнитное поле целей."
	swarmer_examine = "Бьёт всех по области, нанося урон стамине и останавливая метаболизацию реагентов."
	icon_state = "turret_acp"
	max_integrity = 200
	/// Overlay set on targets if we hit them
	var/static/mutable_appearance/strike_overlay
	/// Icon state for flick (when we strike)
	var/strike_icon_state = "turret_acp_strike"
	/// Cooldown of our turret
	COOLDOWN_DECLARE(cooldown)
	/// Our cooldown after turret striked
	var/cooldown_after_strike = SWARMER_ACP_COOLDOWN
	/// Range of our turret
	var/range = SWARMER_ACP_RANGE
	/// Basic damage of our turret
	var/damage = SWARMER_ACP_DAMAGE
	/// Slowed chance after hit
	var/slowed_chance = SWARMER_ACP_SLOWED_CHANCE
	/// Slowed duration after hit
	var/slowed_duration = SWARMER_ACP_SLOWED_DURATION
	/// Basic knockdown duration
	var/knockdown_duration = SWARMER_ACT_KNOCKDOWN_DURATION
	/// Targets that are currently processed by turret. Used by process()
	var/list/processing_targets = list()

/obj/structure/swarmer/acp_turret/Initialize(mapload)
	. = ..()
	if(!strike_overlay)
		strike_overlay = mutable_appearance('icons/effects/swarmer.dmi', "acp_effect", ABOVE_ALL_MOB_LAYER)
	proximity_monitor = new(src, range)

/obj/structure/swarmer/acp_turret/Destroy(force)
	QDEL_NULL(proximity_monitor)
	if(datum_flags & DF_ISPROCESSING)
		STOP_PROCESSING(SSobj, src)
	return ..()

// Restarts the cooldown. Doesn't increase the cooldown.
/obj/structure/swarmer/acp_turret/emp_act(severity)
	..()
	COOLDOWN_START(src, cooldown, cooldown_after_strike)

/obj/structure/swarmer/acp_turret/HasProximity(atom/movable/AM)
	handle_interloper(AM)

/// Updates targets on proximity
/obj/structure/swarmer/acp_turret/proc/handle_interloper(atom/movable/entity)
	if(entity.invisibility > SEE_INVISIBLE_LIVING || entity.alpha == NINJA_ALPHA_INVISIBILITY) // Let's not do typechecks and stuff on invisible things
		return
	if(!isliving(entity) || isswarmer(entity))
		return
	processing_targets[entity] = TRUE // Associative for performance
	if(!(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSobj, src)

// Handles checking if targets are in range and calls the attack
/obj/structure/swarmer/acp_turret/process(seconds_per_tick)
	if(!length(processing_targets))
		return PROCESS_KILL
	if(!anchored)
		return
	//Verify that targeted mobs are in our range. Otherwise, just remove them from processing.
	for(var/mob/mob as anything in processing_targets)
		if(!IN_GIVEN_RANGE(loc, mob, range))
			processing_targets -= mob
	if(!COOLDOWN_FINISHED(src, cooldown))
		return
	strike()
	COOLDOWN_START(src, cooldown, cooldown_after_strike)

/// Calculate effects for all targets, apply metabolize block status effect
/obj/structure/swarmer/acp_turret/proc/strike()
	flick(strike_icon_state, src)
	var/turf/our_turf = get_turf(src)
	new /obj/effect/temp_visual/acp_stomp(our_turf, range)
	for(var/mob/living/target as anything in processing_targets)
		apply_range_based_effects(target)
		target.apply_status_effect(STATUS_EFFECT_METABOLIZE_BLOCK, SWARMER_ACP_DISABLE_METABOLIZATION_DURATION, strike_overlay)
		animate_shockwave(target) // must be after range based effects proc

/// Applies stamina damage, slow duration and chance, together with effects based on distance relative to the turret
/obj/structure/swarmer/acp_turret/proc/apply_range_based_effects(mob/living/target)
	var/modifier = range - get_dist(src, target)
	var/increase_modifier = max((range - 1), 1)
	// Slow is guaranteed if target is next to the turret.
	var/slow_chance_increase_per_tile = (100 - slowed_chance) * (1 / increase_modifier)
	var/slow_duration_increase_per_tile = slowed_duration * (1 / increase_modifier)
	var/final_slowed_chance = round(slowed_chance + modifier * slow_chance_increase_per_tile)
	var/final_slowed_duration = round(slowed_duration + modifier * slow_duration_increase_per_tile)
	var/final_damage = damage + damage * modifier * SWARMER_ACP_RANGE_DAMAGE_MODIFIER
	var/final_knockdown_duration = knockdown_duration * modifier

	target.apply_damage(final_damage, STAMINA)
	target.Knockdown(final_knockdown_duration)
	if(prob(final_slowed_chance))
		target.Slowed(final_slowed_duration, SWARMER_ACP_SLOWED_MULTIPLIER)

/obj/structure/swarmer/acp_turret/get_ru_names()
	return alist(
		NOMINATIVE = "стационарная турель \"Свармеров\"",
		GENITIVE = "стационарной турели \"Свармеров\"",
		DATIVE = "стационарной турели \"Свармеров\"",
		ACCUSATIVE = "стационарную турель \"Свармеров\"",
		INSTRUMENTAL = "стационарной турелью \"Свармеров\"",
		PREPOSITIONAL = "стационарной турели \"Свармеров\""
	)

// ACP strike effect
/obj/effect/temp_visual/acp_stomp
	icon = 'icons/effects/64x64.dmi'
	icon_state = "swarmer_acp"
	duration = 0.8 SECONDS
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/acp_stomp/Initialize(mapload, range = 1)
	. = ..()
	// Reduce to 32x32
	var/matrix/M = matrix() * 0.5
	transform = M
	// Increase size based on range input + 1 (accounting for src tile)
	animate(src, transform = M * 2 * (range + 1), time = duration, alpha = 0)
	playsound(loc, 'sound/swarmer/acp_turret.ogg', 100, TRUE)
