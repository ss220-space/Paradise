// Heretic passive ("empowerment") - a path-specific buff granted when you choose your path, which
// strengthens in two further stages as you grow in power:
//   * Level 1 - applied when the path's starting knowledge is gained.
//   * Level 2 - applied when you craft your path's robe (tg's Armorer's Ritual sends UPGRADE_FIRST there).
//   * Level 3 - applied when you ascend.
// Ported (Ash only for now) and adapted from /tg/station's heretic_passive system. master220 has no
// COMSIG_HERETIC_PASSIVE_UPGRADE signals, so the heretic antag datum drives the level changes directly
// (grant_passive / set_passive_level). The effect itself only ever applies each level's effects once.

/datum/status_effect/heretic_passive
	id = "heretic_passive"
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
// Level 3 - resistance to high and low pressure (granted on ascension), tg parity. master220 has no
//           dedicated TRAIT_RESISTHIGHPRESSURE/TRAIT_RESISTLOWPRESSURE: pressure damage is gated on
//           TRAIT_RESIST_HEAT (high pressure) and TRAIT_RESIST_COLD (low pressure) in human/life.dm,
//           so granting both of those at the final tier IS "resistance to high and low pressure".
/datum/status_effect/heretic_passive/ash
	id = "heretic_passive_ash"
	name = "Клятва Разрушения"
	passive_descriptions = list(
		"Иммунитет к жару и пепельным бурям.",
		"Иммунитет к лаве.",
		"Сопротивление высокому и низкому давлению.",
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
	// Both traits = "resistance to high and low pressure" in master220 (see comment above). HEAT was
	// already granted at level 1; re-adding it here under the same source key is harmless and keeps the
	// final tier explicitly responsible for the full pressure resistance, matching tg.
	owner.add_traits(list(TRAIT_RESIST_HEAT, TRAIT_RESIST_COLD), TRAIT_STATUS_EFFECT(id))


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


//---- Moon Passive: "Лунное Прозрение" - ported from /tg/station, adapted to master220.
// TG's moon passive makes the heretic impervious to brain traumas and slowly regenerates their brain, with
// the Moonlight Amulet doubling the regen while worn. master220 has no sanity, so there is no sanity-regen
// component - just the trauma immunity and brain healing, scaling with our power level.
// Level 1 - brain-trauma immunity + base brain regen (granted on picking the path).
// Level 2 - stronger brain regen (granted on crafting the robe).
// Level 3 - strongest brain regen (granted on ascension).
/datum/status_effect/heretic_passive/moon
	id = "heretic_passive_moon"
	name = "Лунное Прозрение"
	passive_descriptions = list(
		"Вы невосприимчивы к травмам мозга, а его здоровье медленно восстанавливается.",
		"Вы получаете иммунитет ко сну; восстановление мозга усилено.",
		"Восстановление мозга достигло предела.",
	)


/datum/status_effect/heretic_passive/moon/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_MADNESS_IMMUNE, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_CARBON_GAIN_TRAUMA, PROC_REF(block_trauma))
	RegisterSignal(owner, COMSIG_LIVING_LIFE, PROC_REF(on_life))


/// tg's moon passive grants SLEEP IMMUNITY at tier 2 (crafting the robe / reaching power), on top of the
/// stronger brain regen the higher level already gives via applied_level. The base sets applied_level here.
/datum/status_effect/heretic_passive/moon/level_upgrade()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/moon/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MADNESS_IMMUNE, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_SLEEPIMMUNE, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, list(COMSIG_CARBON_GAIN_TRAUMA, COMSIG_LIVING_LIFE))
	return ..()


/// Moon heretics are impervious to brain traumas (tg parity): block any trauma the brain tries to gain.
/datum/status_effect/heretic_passive/moon/proc/block_trauma(datum/source, datum/brain_trauma/trauma, resilience)
	SIGNAL_HANDLER
	return COMSIG_CARBON_BLOCK_TRAUMA


/// Slowly mend brain damage; the Moonlight Amulet doubles the rate, and each tier improves it.
/datum/status_effect/heretic_passive/moon/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	if(!iscarbon(source))
		return
	var/mob/living/carbon/carbon_owner = source
	if(!carbon_owner.get_organ_slot(INTERNAL_ORGAN_BRAIN))
		return

	// SSmobs.wait is 2 secs, so DELTA_WORLD_TIME is halved (matches the rest of the heretic passives).
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5
	var/heal = (0.5 * applied_level) * delta_time
	// Wearing the Moonlight Amulet doubles the regeneration (tg parity).
	if(ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		if(istype(human_owner.neck, /obj/item/clothing/neck/heretic_focus/moon_amulet))
			heal *= 2
	carbon_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, -heal)


//---- Blade Passive: "Танец Клинка" (riposte) - ported 1:1 from /tg/station, adapted to master220.
// When attacked in melee while holding a heretic blade, you instantly strike back at the attacker, once per
// cooldown. tg makes this riposte the blade path's PASSIVE (it folded the old standalone blade_dance node
// into the passive), so it's granted on picking the path and strengthens as you grow. Cooldown scales with
// power: tg uses base_cooldown - cooldown_reduction * (level - 1) -> 20s / 15s / 10s.
// Level 1 - riposte, 20s cooldown (granted on picking the path).
// Level 2 - immunity to fall damage (granted on crafting the robe), cooldown drops to 15s.
// Level 3 - cooldown of the riposte reduced to 10s (granted on ascension).
// NB: tg also makes the level-2+ riposte count as a SUCCESSFUL_BLOCK (nullifying the hit). master220 has no
// COMSIG_LIVING_CHECK_BLOCK / block-reaction system, so we drive the riposte off COMSIG_ATOM_WAS_ATTACKED
// (the relay_attackers element) instead - the counter-attack still lands, it just can't cancel the incoming
// hit. The player-facing levels (riposte / fall immunity / cooldown) are otherwise identical to tg.
/datum/status_effect/heretic_passive/blade
	id = "heretic_passive_blade"
	name = "Танец Клинка"
	passive_descriptions = list(
		"Будучи атакованным в ближнем бою с клинком Еретика в любой руке, вы наносите мгновенный ответный удар атакующему. Срабатывает не чаще, чем раз в 20 секунд.",
		"Иммунитет к урону от падения.",
		"Интервал срабатывания контратаки сокращён до 10 секунд.",
	)
	/// Whether the counter-attack is ready (used instead of a raw cooldown so we can announce when it returns).
	var/riposte_ready = TRUE
	/// Base cooldown between ripostes at level 1.
	var/base_cooldown = 20 SECONDS
	/// How much the cooldown shortens per level gained (20s -> 15s -> 10s).
	var/cooldown_reduction = 5 SECONDS
	/// Stoppable timer that re-arms the riposte.
	var/riposte_timer


/datum/status_effect/heretic_passive/blade/on_apply()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_shield_reaction))
	if(!HAS_TRAIT(owner, TRAIT_RELAYING_ATTACKER))
		owner.AddElement(/datum/element/relay_attackers)


/// Level 2 grants immunity to fall damage (tg parity), landing safely and stylishly instead.
/datum/status_effect/heretic_passive/blade/level_upgrade()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_LIVING_Z_IMPACT, PROC_REF(z_impact_react))


/datum/status_effect/heretic_passive/blade/on_remove()
	UnregisterSignal(owner, list(COMSIG_ATOM_WAS_ATTACKED, COMSIG_LIVING_Z_IMPACT))
	if(riposte_timer)
		deltimer(riposte_timer)
		riposte_timer = null
	return ..()


/// Blocks the effects of falling, landing on our feet with a stylish flip (tg parity).
/datum/status_effect/heretic_passive/blade/proc/z_impact_react(datum/source, levels, turf/fell_on)
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/mook_dust(fell_on)
	owner.visible_message(span_notice("[owner.declent_ru(NOMINATIVE)] приземляется безопасно и весьма эффектно — точно на ноги!"))
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom, SpinAnimation), 0.5 SECONDS, 0)
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "flip")
	return ZIMPACT_CANCEL_DAMAGE | ZIMPACT_NO_MESSAGE | ZIMPACT_NO_SPIN


// Signal handler for COMSIG_ATOM_WAS_ATTACKED (relay_attackers): args are (source, attacker, attack_flags).
/datum/status_effect/heretic_passive/blade/proc/on_shield_reaction(mob/living/carbon/human/source, atom/movable/hitby, attack_flags)
	SIGNAL_HANDLER

	// Shoves aren't a real "melee strike" - they don't provoke a riposte (tg only ripostes melee attacks).
	if(attack_flags & ATTACKER_SHOVING)
		return
	if(!riposte_ready)
		return

	var/mob/living/attacker = isliving(hitby) ? hitby : hitby?.loc
	if(!istype(attacker))
		return
	// Adjacency gates out ranged attacks - the riposte is a melee counter (tg parity).
	if(!ishuman(source) || !source.Adjacent(attacker))
		return

	// We can only riposte with a heretic blade in either hand (mainhand prioritised).
	var/obj/item/main_hand = source.get_active_hand()
	var/obj/item/off_hand = source.get_inactive_hand()
	var/obj/item/striking_with
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand
	if(!striking_with)
		return

	riposte_ready = FALSE
	riposte_timer = addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), (base_cooldown - cooldown_reduction * (applied_level - 1)), TIMER_STOPPABLE)
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, "атакует")


/datum/status_effect/heretic_passive/blade/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "контратака")
	source.visible_message(
		span_warning("[source.declent_ru(NOMINATIVE)] наклоняется к [target.declent_ru(DATIVE)] и наносит внезапный ответный удар!"),
		span_warning("Вы наклоняетесь и наносите внезапный ответный удар!"),
		span_hear("Вы слышите звон, и тяжёлый удар."),
	)
	weapon.melee_attack_chain(source, target)


/datum/status_effect/heretic_passive/blade/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	riposte_timer = null
	source.balloon_alert(source, "контратака готова")


//---- Flesh Passive: "Ненасытный голод" ("Ravenous Hunger") - ported from /tg/station, adapted to master220.
// Level 1 - immunity to diseases and disgust (granted on picking the path). Nulling disgust (tg parity)
//           is essential here: the path revolves around eating organs/meat, which are GROSS food and would
//           otherwise pile on revulsion. tg also grants space-ant immunity, but master220 has no space ants.
// Level 2 - eating meat or organs heals you, and being fat no longer slows you down. tg's voracious/glutton
//           food-preference traits don't exist in master220, so we keep the heal-on-meat + no-fat-slowdown.
// Level 3 - while fat, gain a flat 25% damage resistance and baton-knockdown resistance (tg parity).
/datum/status_effect/heretic_passive/flesh
	id = "heretic_passive_flesh"
	name = "Ненасытный Голод"
	passive_descriptions = list(
		"Иммунитет к болезням и отвращению — никакая еда не вызывает у вас тошноты.",
		"Поедание мяса или органов исцеляет вас, а полнота больше вас не замедляет.",
		"Будучи толстым, вы получаете 25% сопротивления урону и устойчивость к электродубинкам.",
	)


/datum/status_effect/heretic_passive/flesh/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_NODISGUST), TRAIT_STATUS_EFFECT(id))
	// Clear any revulsion already built up (e.g. from eating organs before picking the path).
	owner.SetDisgust(0)


/datum/status_effect/heretic_passive/flesh/level_upgrade()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_FOOD_EATEN, PROC_REF(on_eat))
	// Being fat no longer slows us down, and (at level 3) makes us tougher: react to fatness changes.
	// The native human on_fat (init_signals.dm) is registered at init, so it runs first and adds the
	// obesity movespeed modifiers - our later-registered handler then strips them right back off.
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat_changed))
	on_fat_changed()


/datum/status_effect/heretic_passive/flesh/level_final()
	. = ..()
	if(!.)
		return
	// Re-evaluate now that level 3 grants the fat damage-resistance bonus.
	on_fat_changed()


/datum/status_effect/heretic_passive/flesh/on_remove()
	if(ishuman(owner) && HAS_TRAIT_FROM(owner, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id)))
		var/mob/living/carbon/human/heretic = owner
		heretic.physiology.damage_resistance -= 25
	owner.remove_traits(list(TRAIT_VIRUSIMMUNE, TRAIT_NODISGUST, TRAIT_BATON_RESISTANCE), TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, list(COMSIG_FOOD_EATEN, SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)))
	return ..()


/// Any time we eat meat or an organ, heal some damage (tg's glutton heal).
/datum/status_effect/heretic_passive/flesh/proc/on_eat(mob/living/eater, obj/item/reagent_containers/food/snacks/food, mob/feeder)
	SIGNAL_HANDLER
	if(istype(food, /obj/item/reagent_containers/food/snacks/meat) || istype(food, /obj/item/reagent_containers/food/snacks/organ))
		heal_glutton()


/datum/status_effect/heretic_passive/flesh/proc/heal_glutton()
	owner.heal_overall_damage(2, 2, updating_health = FALSE)
	owner.adjustOxyLoss(-2, updating_health = FALSE)
	owner.adjustToxLoss(-2, updating_health = FALSE)
	owner.AdjustBlood(2)
	owner.updatehealth("flesh glutton heal")
	new /obj/effect/temp_visual/heal(get_turf(owner), COLOR_RED)


/// Strips the obesity slowdown (so fat costs no speed) and toggles the level-3 fat resistance bonus.
/datum/status_effect/heretic_passive/flesh/proc/on_fat_changed(datum/source)
	SIGNAL_HANDLER
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/heretic = owner
	if(HAS_TRAIT(heretic, TRAIT_FAT))
		// tg's TRAIT_FAT_IGNORE_SLOWDOWN: undo the obesity movespeed the native on_fat just applied.
		heretic.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
		heretic.remove_movespeed_modifier(/datum/movespeed_modifier/obesity_flying)
	var/has_bonus = HAS_TRAIT_FROM(heretic, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))
	if(applied_level >= 3 && HAS_TRAIT(heretic, TRAIT_FAT))
		if(!has_bonus)
			heretic.physiology.damage_resistance += 25
			ADD_TRAIT(heretic, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))
	else if(has_bonus)
		heretic.physiology.damage_resistance -= 25
		REMOVE_TRAIT(heretic, TRAIT_BATON_RESISTANCE, TRAIT_STATUS_EFFECT(id))


//---- Lock Passive: "Open Invitation" ("Открытое Приглашение") - ported 1:1 from /tg/station.
// Level 1 - shock insulation (granted on picking the path). tg also makes the Knowledge Shop cheaper at this
//           tier; in master220 that discount is the always-on column shop_cost_discount (see lock_lore.dm),
//           so we only grant the shock immunity here to avoid double-applying it.
// Level 2 - x-ray vision (granted on crafting the robe), letting you see through walls and objects.
// Level 3 - TRAIT_LOCK_GRASP_UPGRADED (granted on ascension): opening a lock no longer puts the grasp on
//           cooldown (handled in base_knock's secondary grasp).
/datum/status_effect/heretic_passive/lock
	id = "heretic_passive_lock"
	name = "Открытое Приглашение"
	passive_descriptions = list(
		"Изоляция от тока; все знания из магазина знаний дешевле.",
		"Рентген-зрение: вы видите сквозь стены и предметы.",
		"Хватка Обители больше не уходит на перезарядку, когда ей открывают дверь или шкаф.",
	)


/datum/status_effect/heretic_passive/lock/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/lock/level_upgrade()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_XRAY_VISION, TRAIT_STATUS_EFFECT(id))
	owner.update_sight()


/datum/status_effect/heretic_passive/lock/level_final()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_LOCK_GRASP_UPGRADED, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/lock/on_remove()
	owner.remove_traits(list(TRAIT_SHOCKIMMUNE, TRAIT_XRAY_VISION, TRAIT_LOCK_GRASP_UPGRADED), TRAIT_STATUS_EFFECT(id))
	owner.update_sight()
	return ..()


//---- Cosmic Passive: "Избранник Звёзд" ("Chosen of the Stars") - ported 1:1 from /tg/station.
// Unlike the other passives this one grants no traits on the mob: its power lives in the cosmic FIELDS the
// heretic creates, which create_cosmic_field/cosmic_trail_based_on_passive upgrade by reading our level.
// Level 1 - standing on a cosmic field speeds you up (movespeed modifier, applied by the field) and regenerates
//           stamina (the tick below). Granted on picking the path.
// Level 2 - the fields you create disrupt/disable nearby grenades & bombs (granted on crafting the robe).
// Level 3 - the fields you create slow down projectiles passing through them (granted on ascension).
/datum/status_effect/heretic_passive/cosmic
	id = "heretic_passive_cosmic"
	name = "Избранник Звёзд"
	passive_descriptions = list(
		"Космические поля ускоряют вас и восстанавливают выносливость.",
		"Создаваемые вами космические поля выводят из строя гранаты и бомбы поблизости.",
		"Создаваемые вами космические поля замедляют пролетающие сквозь них снаряды.",
	)


/datum/status_effect/heretic_passive/cosmic/tick(seconds_between_ticks)
	. = ..()
	if(!(locate(/obj/effect/forcefield/cosmic_field) in get_turf(owner)))
		return
	// SSmobs.wait is 2 secs, so DELTA_WORLD_TIME is halved (matches the rest of the heretic passives).
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5
	if(owner.adjustStaminaLoss(-15 * delta_time, updating_health = FALSE))
		owner.updatehealth()


//---- Void Passive: "Aristocrat's Way" ("Путь Аристократа") - ported 1:1 from /tg/station.
// Level 1 - cold and low-pressure immunity (granted on picking the path). master220 has no dedicated
//           TRAIT_RESISTLOWPRESSURE: low-pressure damage is gated on TRAIT_RESIST_COLD (human/life.dm),
//           so that one trait IS "cold and low pressure immunity" (same substitution the ash passive uses).
// Level 2 - you no longer need to breathe (granted on crafting the robe).
// Level 3 - water, ice and slippery surfaces no longer slip you (granted on ascension).
// (This replaces the legacy "Путь аристократа" cold_snap knowledge node, which granted all of it at once.)
/datum/status_effect/heretic_passive/void
	id = "heretic_passive_void"
	name = "Путь Аристократа"
	passive_descriptions = list(
		"Иммунитет к холоду и низкому давлению.",
		"Вам больше не нужно дышать.",
		"Вода, лёд и скользкие поверхности вам не страшны.",
	)


/datum/status_effect/heretic_passive/void/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_RESIST_COLD, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/void/level_upgrade()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_NO_BREATH, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/void/level_final()
	. = ..()
	if(!.)
		return
	owner.add_traits(list(TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE), TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/void/on_remove()
	owner.remove_traits(list(TRAIT_RESIST_COLD, TRAIT_NO_BREATH, TRAIT_NO_SLIP_WATER, TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE), TRAIT_STATUS_EFFECT(id))
	return ..()
