///Deathmatch modifiers are little options the host can choose to spice the match a bit.
/datum/deathmatch_modifier
	/// The name of the modifier
	var/name = "модификатор"
	/// A small description/tooltip shown in the UI
	var/description = "интересно, что он делает??"
	/// The color of the button shown in the UI
	var/color = "blue"
	/// A lazylist of modifier typepaths this is incompatible with.
	var/list/datum/deathmatch_modifier/blacklisted_modifiers
	/// A lazylist of map typepaths this is incomptable with.
	var/list/datum/lazy_template/deathmatch/blacklisted_maps
	/// Is this trait exempted from the "Random Modifiers" modifier.
	var/random_exempted = FALSE

///Whether or not this modifier can be selected, for both host and player-selected modifiers.
/datum/deathmatch_modifier/proc/selectable(datum/deathmatch_lobby/lobby)
	SHOULD_CALL_PARENT(TRUE)
	if(!random_exempted && (/datum/deathmatch_modifier/random in lobby.modifiers))
		return FALSE
	if(blacklisted_modifiers && length(lobby.modifiers & blacklisted_modifiers))
		return FALSE
	if(map_incompatible(lobby.map))
		return FALSE
	var/list/datum/deathmatch_modifier/our_target = GLOB.deathmatch_game.modifiers
	for(var/modpath in lobby.modifiers)
		if(src in our_target[modpath].blacklisted_modifiers)
			return FALSE
	return TRUE

/// Returns TRUE if map.type is in our blacklisted maps, FALSE otherwise.
/datum/deathmatch_modifier/proc/map_incompatible(datum/lazy_template/deathmatch/map)
	if(map?.type in blacklisted_maps)
		return TRUE

	return FALSE

///Called when selecting the deathmatch modifier.
/datum/deathmatch_modifier/proc/on_select(datum/deathmatch_lobby/lobby)
	return

///When the host changes his mind and unselects it.
/datum/deathmatch_modifier/proc/unselect(datum/deathmatch_lobby/lobby)
	return

///Called when the host chooses to change map. Returns FALSE if the new map is incompatible, TRUE otherwise.
/datum/deathmatch_modifier/proc/on_map_changed(datum/deathmatch_lobby/lobby)
	if(map_incompatible(lobby.map))
		lobby.unselect_modifier(src)
		return FALSE
	return TRUE

///Called as the game is about to start.
/datum/deathmatch_modifier/proc/on_start_game(datum/deathmatch_lobby/lobby)
	return

///Called as the game has ended, right before the reservation is deleted.
/datum/deathmatch_modifier/proc/on_end_game(datum/deathmatch_lobby/lobby)
	return

///Apply the modifier to the newly spawned player as the game is about to start
/datum/deathmatch_modifier/proc/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	return

/datum/deathmatch_modifier/random
	name = "Случайные модификаторы"
	description = "Выбор от трех до пяти случайных модификаторов битвы."
	random_exempted = TRUE

/datum/deathmatch_modifier/random/on_select(datum/deathmatch_lobby/lobby)
	///remove any other global modifier if chosen. It'll pick random ones when the time comes.
	var/list/our_modifiers = GLOB.deathmatch_game.modifiers
	for(var/modpath in lobby.modifiers)
		var/datum/deathmatch_modifier/modifier = our_modifiers[modpath]
		if(modifier.random_exempted)
			continue
		modifier.unselect(lobby)
		lobby.modifiers -= modpath

/datum/deathmatch_modifier/random/on_start_game(datum/deathmatch_lobby/lobby)
	lobby.modifiers -= type //remove it before attempting to select other modifiers, or they'll fail.

	var/static/list/static_pool
	if(isnull(static_pool))
		static_pool = subtypesof(/datum/deathmatch_modifier)
		for(var/datum/deathmatch_modifier/modpath as anything in static_pool)
			if(initial(modpath.random_exempted))
				static_pool -= modpath
	var/list/modifiers_pool = static_pool.Copy()
	var/list/our_modifiers = GLOB.deathmatch_game.modifiers
	for(var/modpath in modifiers_pool)
		var/datum/deathmatch_modifier/modifier = our_modifiers[modpath]
		if(!modifier.selectable(lobby))
			modifiers_pool -= modpath

	///Pick global modifiers at random.
	for(var/iteration in 1 to rand(3, 5))
		var/datum/deathmatch_modifier/modifier = our_modifiers[pick_n_take(modifiers_pool)]
		modifier.on_select(lobby)
		modifier.on_start_game(lobby)
		lobby.modifiers += modifier.type
		modifiers_pool -= modifier.blacklisted_modifiers
		if(!length(modifiers_pool))
			return

/datum/deathmatch_modifier/health
	name = "Удвоенное здоровье"
	description = "Увеличивает ваше здоровье в два раза."
	blacklisted_modifiers = list(/datum/deathmatch_modifier/health/half, /datum/deathmatch_modifier/health/triple)
	var/multiplier = 2

/datum/deathmatch_modifier/health/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	player.maxHealth *= multiplier
	player.health *= multiplier

/datum/deathmatch_modifier/health/half
	name = "Уменьшенное здоровье"
	description = "Уменьшает ваше здоровье наполовину."
	blacklisted_modifiers = list(/datum/deathmatch_modifier/health, /datum/deathmatch_modifier/health/triple)
	multiplier = 0.5

/datum/deathmatch_modifier/health/triple
	name = "Утроенное здоровье"
	description = "Когда удвоенного здоровья недостаточно.."
	multiplier = 3
	blacklisted_modifiers = list(/datum/deathmatch_modifier/health, /datum/deathmatch_modifier/health/half)

/datum/deathmatch_modifier/no_knockdown
	name = "Без станов"
	description = "Куклы никогда не упадут и не заснут во время боя."

/datum/deathmatch_modifier/no_knockdown/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	player.add_traits(list(TRAIT_SLEEPIMMUNE), DEATHMATCH_TRAIT)
	player.add_status_effect_absorption(source = src, effect_type = list(STUN, WEAKEN, STAMCRIT, PARALYZE, KNOCKDOWN))

/datum/deathmatch_modifier/no_slowdown
	name = "Без замедления"
	description = "Куклы не замедляются от полученного урона."

/datum/deathmatch_modifier/no_slowdown/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	ADD_TRAIT(player, TRAIT_IGNORESLOWDOWN, DEATHMATCH_TRAIT)

/datum/deathmatch_modifier/xray
	name = "Иксрей зрение"
	description = "Позволяет вам видеть всю карту и всё, что происходит на ней."
	blacklisted_modifiers = list(/datum/deathmatch_modifier/thermal)

/datum/deathmatch_modifier/xray/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	ADD_TRAIT(player, TRAIT_XRAY_VISION, DEATHMATCH_TRAIT)
	player.update_sight()

/datum/deathmatch_modifier/thermal
	name = "Термальное зрение"
	description = "Позволяет видеть других кукл через стены."
	blacklisted_modifiers = list(/datum/deathmatch_modifier/xray)

/datum/deathmatch_modifier/thermal/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	ADD_TRAIT(player, TRAIT_THERMAL_VISION, DEATHMATCH_TRAIT)
	player.update_sight()

/datum/deathmatch_modifier/no_gravity
	name = "Без гравитации"
	description = "Проверьте ваши навыки робаста при нулевой гравитации."
	//blacklisted_modifiers = list(/datum/deathmatch_modifier/mounts, /datum/deathmatch_modifier/paraplegic, /datum/deathmatch_modifier/minefield)

/datum/deathmatch_modifier/no_gravity/on_start_game(datum/deathmatch_lobby/lobby)
	for(var/turf/turf as anything in lobby.location.reserved_turfs)
		INVOKE_ASYNC(turf, PROC_REF(make_less_gravity))

/datum/deathmatch_modifier/no_gravity/proc/make_less_gravity(turf/our_turf)
	our_turf.AddElement(/datum/element/forced_gravity, 0)

/datum/deathmatch_modifier/no_gravity/on_end_game(datum/deathmatch_lobby/lobby)
	for(var/turf/turf as anything in lobby.location.reserved_turfs)
		turf.RemoveElement(/datum/element/forced_gravity, 0)

/datum/deathmatch_modifier/explode_on_death
	name = "Взрыв после смерти"
	description = "Каждая кукла получает имплант подрыва."

/datum/deathmatch_modifier/explode_on_death/on_start_game(datum/deathmatch_lobby/lobby)
	ADD_TRAIT(lobby, TRAIT_DEATHMATCH_EXPLOSIVE_IMPLANTS, DEATHMATCH_TRAIT)

/datum/deathmatch_modifier/explode_on_death/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	var/obj/item/implant/explosive/implant = new()
	implant.implant(player, force = TRUE)

/datum/deathmatch_modifier/monkeys
	name = "Манкификация"
	description = "Вернись к своим корням."

/datum/deathmatch_modifier/monkeys/apply(mob/living/carbon/player, datum/deathmatch_lobby/lobby)
	var/mob/living/carbon/human/our_human = player
	if(!our_human)
		return
	our_human.set_species(/datum/species/monkey)

/datum/deathmatch_modifier/minefield
	name = "Минное поле"
	description = "Все игровое поле усеяно минами. Смотри под ноги!"

/datum/deathmatch_modifier/minefield/on_start_game(datum/deathmatch_lobby/lobby)
	var/list/mines = subtypesof(/obj/effect/mine)
	mines -= list(
		/obj/effect/mine/pickup,
		/obj/effect/mine/pickup/bloodbath,
		/obj/effect/mine/pickup/healing,
		/obj/effect/mine/pickup/speed,
		/obj/effect/mine/gas, //Just spawns oxygen.
		/obj/effect/mine/gas/n2o, //no sleeping please.
	)

	///1 every 11 turfs, but it will actually spawn fewer mines since groundless and closed turfs are skipped.
	var/our_turfs = lobby.location.reserved_turfs
	var/mines_to_spawn = length(our_turfs) * 0.09
	for(var/iteration in 1 to mines_to_spawn)
		var/turf/target_turf = pick(our_turfs)
		if(!issimulatedturf(target_turf) || isgroundlessturf(target_turf) || iswallturf(target_turf))
			continue
		///don't spawn mine next to player spawns.
		if(locate(/obj/effect/landmark/deathmatch_player_spawn) in range(1, target_turf))
			continue
		///skip belt loops or they'll explode right away.
		if(locate(/obj/machinery) in target_turf.contents)
			continue
		///skip all taken turfs, like crates or tables
		if(locate(/obj/structure) in target_turf.contents)
			continue
		var/mine_path = pick(mines)
		new mine_path (target_turf)

/datum/deathmatch_modifier/any_loadout
	name = "Свободный выбор снаряжения"
	description = "Наблюдайте, как все берут инстагиб пушку."
	random_exempted = TRUE

/datum/deathmatch_modifier/any_loadout/selectable(datum/deathmatch_lobby/lobby)
	. = ..()
	if(!.)
		return
	return lobby.map.allowed_loadouts

/datum/deathmatch_modifier/any_loadout/on_select(datum/deathmatch_lobby/lobby)
	lobby.loadouts = GLOB.deathmatch_game.loadouts

/datum/deathmatch_modifier/any_loadout/unselect(datum/deathmatch_lobby/lobby)
	lobby.loadouts = lobby.map.allowed_loadouts

/datum/deathmatch_modifier/any_loadout/on_map_changed(datum/deathmatch_lobby/lobby)
	if(lobby.loadouts == GLOB.deathmatch_game.loadouts) //This arena already allows any loadout for some reason.
		lobby.unselect_modifier(src)
	else
		lobby.loadouts = GLOB.deathmatch_game.loadouts

// TODO:
// DROP POD MODIFIERS
// MOUNTS
// AIM MODIFIERS
// MISC MODIFIERS (teleport, snail crawl, blinking, forcefield)
