
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
	owner.add_traits(list(TRAIT_RESIST_HEAT, TRAIT_RESIST_COLD), TRAIT_STATUS_EFFECT(id))


/datum/status_effect/heretic_passive/ash/on_remove()
	owner.remove_traits(list(TRAIT_RESIST_HEAT, TRAIT_ASHSTORM_IMMUNE, TRAIT_LAVA_IMMUNE, TRAIT_RESIST_COLD), TRAIT_STATUS_EFFECT(id))
	return ..()


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

	source.AdjustImmobilized((-0.5 * applied_level) * delta_time)
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume = min(source.blood_volume + 2.5 * delta_time, BLOOD_VOLUME_NORMAL)

	for(var/datum/reagent/reagent as anything in source.reagents.reagent_list)
		reagent.volume = max(0, reagent.volume - delta_time)
	source.reagents.update_total()

	if(!iscarbon(source))
		return
	var/mob/living/carbon/carbon_owner = source

	if(applied_level < 2)
		return
	if(ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		for(var/obj/item/organ/external/bodypart as anything in human_owner.bodyparts)
			bodypart.mend_fracture()
			bodypart.stop_internal_bleeding()
	for(var/obj/item/organ/internal_organ as anything in carbon_owner.internal_organs)
		internal_organ.heal_internal_damage(2 * delta_time)

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

	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5
	var/heal = (0.5 * applied_level) * delta_time
	if(ishuman(carbon_owner))
		var/mob/living/carbon/human/human_owner = carbon_owner
		if(istype(human_owner.neck, /obj/item/clothing/neck/heretic_focus/moon_amulet))
			heal *= 2
	carbon_owner.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, -heal)


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


/datum/status_effect/heretic_passive/blade/proc/on_shield_reaction(mob/living/carbon/human/source, atom/movable/hitby, attack_flags)
	SIGNAL_HANDLER

	if(attack_flags & ATTACKER_SHOVING)
		return
	if(!riposte_ready)
		return

	var/mob/living/attacker = isliving(hitby) ? hitby : hitby?.loc
	if(!istype(attacker))
		return
	if(!ishuman(source) || !source.Adjacent(attacker))
		return

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
	owner.SetDisgust(0)


/datum/status_effect/heretic_passive/flesh/level_upgrade()
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_FOOD_EATEN, PROC_REF(on_eat))
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_FAT), SIGNAL_REMOVETRAIT(TRAIT_FAT)), PROC_REF(on_fat_changed))
	on_fat_changed()


/datum/status_effect/heretic_passive/flesh/level_final()
	. = ..()
	if(!.)
		return
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
	var/delta_time = DELTA_WORLD_TIME(SSmobs) * 0.5
	if(owner.adjustStaminaLoss(-15 * delta_time, updating_health = FALSE))
		owner.updatehealth()


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
