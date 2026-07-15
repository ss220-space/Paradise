/// Assoc list containing all action types that are given based on type on init
/// I think this is better than doing this for each type on init separately
GLOBAL_LIST_INIT(swarmer_actions_by_type, list(
	// Starting swarmer
	/mob/living/simple_animal/hostile/swarmer/basic = list(
		/datum/action/innate/hide/swarmer, // Until someone refactors the way hide action is handled
		),
	// Generalist swarmer
	/mob/living/simple_animal/hostile/swarmer/generalist = list(
		/datum/action/cooldown/swarmer/build/barricade,
		/datum/action/cooldown/swarmer/build/trap,
		/datum/action/cooldown/swarmer/build/rapid_turret,
		),
	// Rover swarmer
	/mob/living/simple_animal/hostile/swarmer/rover = list(
		/datum/action/innate/hide/swarmer, // Until someone refactors the way hide action is handled
		/datum/action/cooldown/swarmer/build/trap,
		/datum/action/cooldown/swarmer/build/transport_hub,
		),
	// Combat swarmer
	/mob/living/simple_animal/hostile/swarmer/combat = list(
		/datum/action/cooldown/swarmer/build/barricade,
		/datum/action/cooldown/swarmer/mode_switcher,
		),
	// Builder swarmer
	/mob/living/simple_animal/hostile/swarmer/builder = list(
		/datum/action/cooldown/swarmer/build/processer,
		/datum/action/cooldown/swarmer/build/analyzer,
		/datum/action/cooldown/swarmer/build/repair_station,
		/datum/action/cooldown/swarmer/build/storage,
		/datum/action/cooldown/swarmer/build/rapid_turret,
		/datum/action/cooldown/swarmer/build/sniper_turret,
		/datum/action/cooldown/swarmer/build/acp_turret,
		/datum/action/cooldown/swarmer/move_core,
		),
	))

/**
 * Starting swarmer
 *
 * Nothing unique, exists only to provide a "casing", until
 * the player chooses a new class.
 */
/mob/living/simple_animal/hostile/swarmer/basic
	name = "Drone Swarmer"
	desc = "Хрупкий, маленький, слегка быстрый \"Свармер\"."
	icon_state = "swarmer_starter"
	icon_living = "swarmer_starter"
	melee_damage_lower = 20
	melee_damage_upper = 20
	health = 25
	maxHealth = 25
	dismantle_speed = SLOW_SWARMER_DISMANTLE_DELAY
	speed = 0.25
	pass_door_while_hidden = TRUE
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	can_swap_to = FALSE
	swarmer_class_info = "Данный класс не отличается ничем особенным, и существует для того, чтобы вы его сменили в ядре на новый.\n\
		Для смены класса, нажмите по ядру в 1 интенте \"Помощь\".\n\
		Достаточно маленький для того, чтобы проползать под столами и шлюзами."

/mob/living/simple_animal/hostile/swarmer/basic/get_ru_names()
	return alist(
		NOMINATIVE = "свармер — дрон",
		GENITIVE = "свармер — дрона",
		DATIVE = "свармер — дрону",
		ACCUSATIVE = "свармер — дрона",
		INSTRUMENTAL = "свармер — дроном",
		PREPOSITIONAL = "свармер — дроне",
	)

/**
 * Generalist swarmer
 *
 * Combat unit that is basically the "old" swarmer.
 * Increased speed, can build small turrets, traps, barricades, shoot projectiles.
 */
/mob/living/simple_animal/hostile/swarmer/generalist
	name = "Generalist Swarmer"
	desc = "Базовая боевая единица \"Свармеров\". Оснащён пушкой и базовыми строительными устройствами."
	icon_state = "swarmer_general"
	icon_living = "swarmer_general"
	melee_damage_lower = 25
	melee_damage_upper = 25
	health = 150
	maxHealth = 150
	speed = 0
	ranged = 1
	projectiletype = /obj/projectile/beam/disabler/swarmer/generalist
	ranged_cooldown_time = SWARMER_NORMAL_PROJECTILE_COOLDOWN
	projectilesound = 'sound/weapons/taser2.ogg'
	swap_resource_cost = GENERALIST_SWAP_COST
	swarmer_class_info = "Данный класс является базовой боевой единицей, оснащённой пушкой, а также способностью строить мелкие туррели, баррикады и ловушки.\n\
		Скорость равна человеческой."

/mob/living/simple_animal/hostile/swarmer/generalist/get_ru_names()
	return alist(
		NOMINATIVE = "свармер — генералист",
		GENITIVE = "свармер — генералиста",
		DATIVE = "свармер — генералисту",
		ACCUSATIVE = "свармер — генералиста",
		INSTRUMENTAL = "свармер — генералистом",
		PREPOSITIONAL = "свармер — генералисте",
	)

/**
 * Rover Swarmer
 *
 * Scout unit, which means low health, very high speed and high melee damage.
 * Can build "hubs", which are used by swarmers for transportation between them.
 */
/mob/living/simple_animal/hostile/swarmer/rover
	name = "Rover Swarmer"
	desc = "Маленький \"Свармер\" на колёсиках вместо ног. Оснащён тараном, способным опрокидывать с ног целей."
	icon_state = "swarmer_rover"
	icon_living = "swarmer_rover"
	melee_damage_lower = 30
	melee_damage_upper = 30
	health = 55
	maxHealth = 55
	speed = -1
	swap_resource_cost = ROVER_SWAP_COST
	pass_door_while_hidden = TRUE
	pass_flags = PASSTABLE | PASSMOB
	swarmer_class_info = "Данный класс является разведовательной единицей, оснащённой колёсами вместо ног, а также мощным тараном, способным сбивать целей с ног.\n\
		Способен строить ловушки и \"хабы\", между которыми смогут перемещаться все \"Свармеры\".\n\
		Достаточно маленький для того, чтобы проползать под столами и шлюзами."
	/// For how long do we knockdown on hit
	var/knockdown_time = 3 SECONDS

/mob/living/simple_animal/hostile/swarmer/rover/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attack))

/mob/living/simple_animal/hostile/swarmer/rover/Destroy(force)
	UnregisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	return ..()

/// Signal proc, additional knockdown on attack
/mob/living/simple_animal/hostile/swarmer/rover/proc/on_attack(datum/source, mob/living/target, result)
	SIGNAL_HANDLER
	if(!result)
		return
	if(!istype(target))
		return
	target.Knockdown(knockdown_time)

/mob/living/simple_animal/hostile/swarmer/rover/get_ru_names()
	return alist(
		NOMINATIVE = "свармер — ровер",
		GENITIVE = "свармер — ровера",
		DATIVE = "свармер — роверу",
		ACCUSATIVE = "свармер — ровера",
		INSTRUMENTAL = "свармер — ровером",
		PREPOSITIONAL = "свармер — ровере",
	)

/**
 * Combat Swarmer
 *
 * Auto-repairs nears the core, has increased speed around swarmer structures.
 * Has 4 different projectile modes, and can build barricades.
 */
/mob/living/simple_animal/hostile/swarmer/combat
	name = "Combat Swarmer"
	desc = "Защитная единица \"Свармеров\". Оснащён пушкой и базовыми строительными устройствами."
	icon_state = "swarmer_combat"
	icon_living = "swarmer_combat"
	melee_damage_lower = 30
	melee_damage_upper = 30
	health = 220
	maxHealth = 220
	dismantle_speed = SLOW_SWARMER_DISMANTLE_DELAY
	speed = 1.5
	ranged = 1
	swap_resource_cost = COMBAT_SWAP_COST
	swarmer_class_info = "Данный класс является защитной единицей, оснащённой более сильной защитой и пушками.\n\
		Оснащён следующими типами выстрелов: Обычный выстрел, двойной выстрел, сильный выстрел, саботажный выстрел.\n\
		Способен строить баррикады.\n\
		Чинится автоматически у ядра, становится быстрее у ядра."
	/// What speed do we have if there is any swarmer structure nearby
	var/increased_speed = 0

/mob/living/simple_animal/hostile/swarmer/combat/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_SWARMER_CORES, INNATE_TRAIT)

/mob/living/simple_animal/hostile/swarmer/combat/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	REMOVE_TRAIT(src, TRAIT_HEALS_FROM_SWARMER_CORES, INNATE_TRAIT)
	return ..()

/// Increases speed if any swarmer structure is nearby
/mob/living/simple_animal/hostile/swarmer/combat/process(seconds_per_tick)
	if(locate(/obj/structure/swarmer) in range(7, src))
		set_varspeed(increased_speed)
		return
	set_varspeed(initial(speed))

/mob/living/simple_animal/hostile/swarmer/combat/get_ru_names()
	return alist(
		NOMINATIVE = "свармер — боец",
		GENITIVE = "свармер — бойца",
		DATIVE = "свармер — бойцу",
		ACCUSATIVE = "свармер — бойца",
		INSTRUMENTAL = "свармер — бойцом",
		PREPOSITIONAL = "свармер — бойце",
	)

/**
 * Builder Swarmer
 *
 * The most important class of all. Builds most of swarmer structures,
 * can move them, and repairs twice more and twice faster.
 */
/mob/living/simple_animal/hostile/swarmer/builder
	name = "Builder Swarmer"
	desc = "Строительная единица \"Свармеров\". Оснащён мощными нанитами, способными как строить, так и чинить, за крайне малое время."
	icon_state = "swarmer_builder"
	icon_living = "swarmer_builder"
	melee_damage_lower = 40
	melee_damage_upper = 40
	health = 120
	maxHealth = 120
	dismantle_speed = FAST_SWARMER_DISMANTLE_DELAY
	swap_resource_cost = BUILDER_SWAP_COST
	mob_size = MOB_SIZE_HUMAN
	swarmer_class_info = "Данный класс является строительной единицей, способной строить множество различных конструкций.\n\
		Является самым важным классом среди \"Свармеров\", без которого выполнение цели является невозможным.\n\
		Чинит в два раза быстрее и больше остальных, а также способен перемещать структуры, включая ядро.\n\
		Медленно чинится сам по себе, и обладает наибольшим уроном вблизи."
	/// Builder swarmers heal passively by a little bit
	var/auto_repair_amount = 1

/mob/living/simple_animal/hostile/swarmer/builder/Life(seconds, times_fired)
	. = ..()
	adjustHealth(-auto_repair_amount)

/mob/living/simple_animal/hostile/swarmer/builder/get_ru_names()
	return alist(
		NOMINATIVE = "свармер — строитель",
		GENITIVE = "свармер — строителя",
		DATIVE = "свармер — строителю",
		ACCUSATIVE = "свармер — строителя",
		INSTRUMENTAL = "свармер — строителем",
		PREPOSITIONAL = "свармер — строителе",
	)

/**
 * Finishing goal of swarmers.
 *
 * Tanky, reflects projectiles, has a built-in
 * minigun and ACP.
 */
/mob/living/simple_animal/hostile/swarmer/mega
	name = "Mega Swarmer"
	desc = "Лучшая боевая единица \"Свармеров\", оснащённая рефлекторными пластинами, миниганом, и встроенной турелью ACP."
	icon_state = "swarmer_mega"
	icon_living = "swarmer_mega"
	melee_damage_lower = 60
	melee_damage_upper = 60
	ranged = 1
	projectiletype = /obj/projectile/beam/disabler/swarmer/minigun
	ranged_cooldown_time = SWARMER_MINIGUN_PROJECTILE_COOLDOWN
	projectilesound = 'sound/weapons/taser2.ogg'
	rapid = SWARMER_MEGA_RAPID
	rapid_fire_delay = 1
	health = 650
	maxHealth = 650
	can_swap_to = FALSE
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	dismantle_speed = FAST_SWARMER_DISMANTLE_DELAY
	swarmer_class_info = "Вы — финальная боевая единица \"Свармеров\", оснащённая миниганом, встроенной ACP турелью, а также защитными пластинами.\n\
		Ваша цель — окончательно захватить станцию под ваш контроль."
	/// For how long we apply knockdown on attack
	var/knockdown_time = 5 SECONDS
	/// Reflection chance of projectiles
	var/reflection_chance = SWARMER_MEGA_REFLECT_CHANCE
	/// Built-in ACP turret
	var/obj/structure/swarmer/acp_turret/acp

/mob/living/simple_animal/hostile/swarmer/mega/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(on_attack))
	acp = new(src)
	configure_acp()

/mob/living/simple_animal/hostile/swarmer/mega/Destroy(force)
	UnregisterSignal(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET)
	qdel(acp)
	return ..()

/// Signal proc, additional knockdown on attack
/mob/living/simple_animal/hostile/swarmer/mega/proc/on_attack(datum/source, mob/living/target, result)
	SIGNAL_HANDLER
	if(!result)
		return
	if(!istype(target))
		return
	target.Knockdown(knockdown_time)

// Reflects projectiles with a set chance
/mob/living/simple_animal/hostile/swarmer/mega/bullet_act(obj/projectile/proj)
	if(!proj.is_reflectable(REFLECTABILITY_ENERGY))
		return ..()
	if(!prob(reflection_chance))
		return ..()

	if(proj.damage_type == BRUTE || proj.damage_type == BURN)
		adjustHealth(proj.damage * 0.5)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] отражает [proj.declent_ru(ACCUSATIVE)]!"),
		span_userdanger("[capitalize(declent_ru(NOMINATIVE))] отражает [proj.declent_ru(ACCUSATIVE)]!"),
		projectile_message = TRUE,
	)
	add_attack_logs(proj.firer, src, "hit by [proj.type] but got reflected")
	proj.reflect_back(src)
	return -1

/// Configures ACP to work within src
/mob/living/simple_animal/hostile/swarmer/mega/proc/configure_acp()
	QDEL_NULL(acp.proximity_monitor)
	acp.proximity_monitor = new(src, SWARMER_MEGA_ACP_RANGE)
	acp.range = SWARMER_MEGA_ACP_RANGE

/// Connects proximity monitor of us with acp's
/mob/living/simple_animal/hostile/swarmer/mega/HasProximity(atom/movable/AM)
	acp.handle_interloper(AM)

// Stronger deconstructing
/mob/living/simple_animal/hostile/swarmer/mega/damage_object(atom/movable/target)
	var/obj/effect/temp_visual/swarmer/disintegration/disintegrate_effect = new(get_turf(target))
	disintegrate_effect.adjust_size(target)
	target.ex_act(EXPLODE_HEAVY) // This is what actually damages structures on swarmer_act
	do_attack_animation(target)
	changeNext_move(CLICK_CD_MELEE)

// Grants achievement for, somehow, killing the mega swarmer with bare hands.
/mob/living/simple_animal/hostile/swarmer/mega/attack_hand(mob/living/carbon/human/attacker)
	. = ..()
	if(. && is_dead() && attacker.client)
		// nuSanya -> after swarmer pr
		//attacker.client.give_award(/datum/award/achievement/misc/mega_swarmer_punch)
		attacker.balloon_alert(attacker, "жесть вы крутой!!!") // to remove after

/mob/living/simple_animal/hostile/swarmer/mega/get_ru_names()
	return alist(
		NOMINATIVE = "мега — свармер",
		GENITIVE = "мега — свармера",
		DATIVE = "мега — свармеру",
		ACCUSATIVE = "мега — свармера",
		INSTRUMENTAL = "мега — свармером",
		PREPOSITIONAL = "мега — свармере",
	)
