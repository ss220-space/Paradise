/mob/living/simple_animal/hostile/megafauna
	name = "megafauna"
	desc = "Attack the weak point for massive damage."
	health = 1000
	maxHealth = 1000
	a_intent = INTENT_HARM
	sentience_type = SENTIENCE_BOSS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	obj_damage = 400
	light_range = 3
	faction = list("mining", "boss")
	weather_immunities = list("lava","ash")
	tts_seed = "Mannoroth"
	flying = TRUE
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	stat_attack = DEAD
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	minbodytemp = 0
	maxbodytemp = INFINITY
	vision_range = 5
	aggro_vision_range = 18
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway
	var/list/crusher_loot
	var/score_achievement_type = BOSS_SCORE
	var/crusher_achievement_type
	var/achievement_type
	var/elimination = 0
	var/anger_modifier = 0
	var/obj/item/gps/internal_gps
	var/internal_type
	var/recovery_time = 0
	var/true_spawn = TRUE // if this is a megafauna that should grant achievements, or have a gps signal
	var/nest_range = 10
	var/chosen_attack = 1 // chosen attack num
	var/list/attack_action_types = list()

/mob/living/simple_animal/hostile/megafauna/Initialize(mapload)
	. = ..()
	if(internal_type && true_spawn)
		internal = new internal_type(src)
	for(var/action_type in attack_action_types)
		var/datum/action/innate/megafauna_attack/attack_action = new action_type()
		attack_action.Grant(src)

/mob/living/simple_animal/hostile/megafauna/Destroy()
	QDEL_NULL(internal_gps)
	return ..()

/mob/living/simple_animal/hostile/megafauna/Moved()
	if(nest && nest.parent && get_dist(nest.parent, src) > nest_range)
		var/turf/closest = get_turf(nest.parent)
		for(var/i = 1 to nest_range)
			closest = get_step(closest, get_dir(closest, src))
		forceMove(closest) // someone teleported out probably and the megafauna kept chasing them
		target = null
		return
	return ..()

/mob/living/simple_animal/hostile/megafauna/can_die()
	return ..() && health <= 0

/mob/living/simple_animal/hostile/megafauna/death(gibbed, list/force_grant)
	// this happens before the parent call because `del_on_death` may be set
	var/crusher_kill = FALSE
	if(can_die() && !admin_spawned)
		var/datum/status_effect/crusher_damage/C = has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(C && crusher_loot && C.total_damage >= maxHealth * 0.6)
			spawn_crusher_loot()
			crusher_kill = TRUE
		if(!elimination)	//used so the achievment only occurs for the last legion to die.
			grant_achievement(achievement_type, score_achievement_type, crusher_kill, force_grant)
			SSblackbox.record_feedback("tally", "megafauna_kills", 1, "[initial(name)]")
	return ..()

/mob/living/simple_animal/hostile/megafauna/proc/spawn_crusher_loot()
	loot = crusher_loot

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	if(recovery_time >= world.time)
		return
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()
		else
			devour(L)

/mob/living/simple_animal/hostile/megafauna/onShuttleMove(turf/oldT, turf/T1, rotation, mob/caller)
	var/turf/oldloc = loc
	. = ..()
	if(!.)
		return
	var/turf/newloc = loc
	mob_attack_logs += "[time_stamp()] Moved via shuttle from [COORD(oldloc)] to [COORD(newloc)] caller: [caller ? "[caller]" : "unknown" ]"
	message_admins("Megafauna[stat == DEAD ? "(DEAD)" : null] [src] ([ADMIN_FLW(src,"FLW")]) moved via shuttle from [ADMIN_COORDJMP(oldloc)] to [ADMIN_COORDJMP(newloc)][caller ? " called by [ADMIN_LOOKUPFLW(caller)]" : ""]")

/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		"<span class='danger'>[src] devours [L]!</span>",
		"<span class='userdanger'>You feast on [L], restoring your health!</span>")
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		adjustBruteLoss(-L.maxHealth/2)
	if(L.mind)
		mob_attack_logs += "[time_stamp()] Devours [key_name_log(L)] at [COORD(src)]"
	L.gib()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch(severity)
		if(1)
			adjustBruteLoss(250)

		if(2)
			adjustBruteLoss(100)

		if(3)
			adjustBruteLoss(50)

/mob/living/simple_animal/hostile/megafauna/GiveTarget(atom/new_target)
	var/mob/living/L = new_target
	if(istype(L) && L.mind)
		add_attack_logs(src, L, "Spotted a new target")
		mob_attack_logs += "[time_stamp()] Spotted a new target [L][COORD(L)] at [COORD(src)]"
	..()

/mob/living/simple_animal/hostile/megafauna/Aggro()
	var/mob/living/L = target
	if(istype(L) && L.mind)
		add_attack_logs(src, L, "Aggrod on")
		mob_attack_logs += "[time_stamp()] Aggrod on [L][COORD(L)] at [COORD(src)]"
	..()

/mob/living/simple_animal/hostile/megafauna/LoseTarget()
	var/mob/living/L = target
	if(istype(L) && L.mind)
		add_attack_logs(src, L, "Lost")
		mob_attack_logs += "[time_stamp()] Lost [L][COORD(L)] at [COORD(src)]"
	..()

/mob/living/simple_animal/hostile/megafauna/proc/SetRecoveryTime(buffer_time)
	recovery_time = world.time + buffer_time
	ranged_cooldown = world.time + buffer_time

/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement(achievement_type, score_achievement_type, crusher_kill, list/grant_achievement = list())
	if(!achievement_type || admin_spawned || !SSmedals.hub_enabled) //Don't award medals if the medal type isn't set
		return FALSE
	if(!grant_achievement.len)
		for(var/mob/living/L in view(7,src))
			grant_achievement += L
	for(var/mob/living/L in grant_achievement)
		if(L.stat || !L.client)
			continue
		L.client.give_award(/datum/award/achievement/boss/boss_killer, L)
		L.client.give_award(achievement_type, L)
		if(crusher_kill && istype(L.get_active_hand(), /obj/item/twohanded/kinetic_crusher))
			L.client.give_award(crusher_achievement_type, L)
		L.client.give_award(/datum/award/score/boss_score, L) //Score progression for bosses killed in general
		L.client.give_award(score_achievement_type, L) //Score progression for specific boss killed
	return TRUE

/datum/action/innate/megafauna_attack
	name = "Megafauna Attack"
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = ""
	var/mob/living/simple_animal/hostile/megafauna/M
	var/chosen_message
	var/chosen_attack_num = 0

/datum/action/innate/megafauna_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/megafauna))
		M = L
		return ..()
	return FALSE

/datum/action/innate/megafauna_attack/Activate()
	M.chosen_attack = chosen_attack_num
	to_chat(M, chosen_message)

/*mob/living/simple_animal/hostile/megafauna/death(gibbed, list/force_grant)
	if(health > 0)
		return
	var/datum/status_effect/crusher_damage/crusher_dmg = has_status_effect(/datum/status_effect/crusher_damage)
	///Whether we killed the megafauna with primarily crusher damage or not
	var/crusher_kill = FALSE
	if(crusher_dmg && crusher_dmg.total_damage >= maxHealth * 0.6)
		crusher_kill = TRUE
		if(crusher_loot) // spawn crusher loot, if any
			spawn_crusher_loot()
	//SKYRAT ADDITION START - ASHWALKER TROPHIES
	var/datum/status_effect/ashwalker_damage/ashie_damage = has_status_effect(/datum/status_effect/ashwalker_damage)
	if(!crusher_kill && ashie_damage && crusher_loot && ashie_damage.total_damage >= maxHealth * 0.6)
		spawn_crusher_loot()
	//SKYRAT ADDITION END
	if(true_spawn && !(flags_1 & ADMIN_SPAWNED_1))
		var/tab = "megafauna_kills"
		if(crusher_kill)
			tab = "megafauna_kills_crusher"
		if(!elimination) //used so the achievment only occurs for the last legion to die.
			grant_achievement(achievement_type, score_achievement_type, crusher_kill, force_grant)
			SSblackbox.record_feedback("tally", tab, 1, "[initial(name)]")
	return ..()

/// Spawns crusher loot instead of normal loot
/mob/living/simple_animal/hostile/megafauna/proc/spawn_crusher_loot()
	loot = crusher_loot

/mob/living/simple_animal/hostile/megafauna/gib()
	if(health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/dust(just_ash, drop_items, force)
	if(!force && health > 0)
		return
	else
		..()

/mob/living/simple_animal/hostile/megafauna/AttackingTarget()
	if(recovery_time >= world.time)
		return
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()

			if(L.health <= HEALTH_THRESHOLD_DEAD && HAS_TRAIT(L, TRAIT_NODEATH)) //Nope, it still gibs yall
				devour(L)
		else
			devour(L)

/// Devours a target and restores health to the megafauna
/mob/living/simple_animal/hostile/megafauna/proc/devour(mob/living/L)
	if(!L)
		return FALSE
	visible_message(
		span_danger("[src] devours [L]!"),
		span_userdanger("You feast on [L], restoring your health!"))
	if(!is_station_level(z) || client) //NPC monsters won't heal while on station
		adjustBruteLoss(-L.maxHealth/2)
	L.investigate_log("has been devoured by [src].", INVESTIGATE_DEATHS)
	L.gib()
	return TRUE

/mob/living/simple_animal/hostile/megafauna/ex_act(severity, target)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			adjustBruteLoss(250)

		if (EXPLODE_HEAVY)
			adjustBruteLoss(100)

		if (EXPLODE_LIGHT)
			adjustBruteLoss(50)

/// Sets/adds the next time the megafauna can use a melee or ranged attack, in deciseconds. It is a list to allow using named args. Use the ignore_staggered var if youre setting the cooldown to ranged_cooldown_time.
/mob/living/simple_animal/hostile/megafauna/proc/update_cooldowns(list/cooldown_updates, ignore_staggered = FALSE)
	if(!ignore_staggered && has_status_effect(/datum/status_effect/stagger))
		for(var/update in cooldown_updates)
			cooldown_updates[update] *= 2
	if(cooldown_updates[COOLDOWN_UPDATE_SET_MELEE])
		recovery_time = world.time + cooldown_updates[COOLDOWN_UPDATE_SET_MELEE]
	if(cooldown_updates[COOLDOWN_UPDATE_ADD_MELEE])
		recovery_time += cooldown_updates[COOLDOWN_UPDATE_ADD_MELEE]
	if(cooldown_updates[COOLDOWN_UPDATE_SET_RANGED])
		ranged_cooldown = world.time + cooldown_updates[COOLDOWN_UPDATE_SET_RANGED]
	if(cooldown_updates[COOLDOWN_UPDATE_ADD_RANGED])
		ranged_cooldown += cooldown_updates[COOLDOWN_UPDATE_ADD_RANGED]

/// Grants medals and achievements to surrounding players
/mob/living/simple_animal/hostile/megafauna/proc/grant_achievement(medaltype, scoretype, crusher_kill, list/grant_achievement = list())
	if(!achievement_type || (flags_1 & ADMIN_SPAWNED_1) || !SSachievements.achievements_enabled) //Don't award medals if the medal type isn't set
		return FALSE
	if(!grant_achievement.len)
		for(var/mob/living/L in view(7,src))
			grant_achievement += L
	for(var/mob/living/L in grant_achievement)
		if(L.stat || !L.client)
			continue
		L.add_mob_memory(/datum/memory/megafauna_slayer, antagonist = src)
		L.client.give_award(/datum/award/achievement/boss/boss_killer, L)
		L.client.give_award(achievement_type, L)
		if(crusher_kill && istype(L.get_active_held_item(), /obj/item/kinetic_crusher))
			L.client.give_award(crusher_achievement_type, L)
		L.client.give_award(/datum/award/score/boss_score, L) //Score progression for bosses killed in general
		L.client.give
_award(score_achievement_type, L) //Score progression for specific boss killed
	return TRUE */
