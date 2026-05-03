GLOBAL_DATUM_INIT(thunderdome_battle, /datum/mini_game/thunderdome_battle, new)
GLOBAL_VAR_INIT(tdome_arena, locate(/area/tdome/newtdome))
GLOBAL_VAR_INIT(tdome_arena_melee, locate(/area/tdome/newtdome/CQC))

/**
 * #thunderdome_battle
 *
 * This datum is responsible for making fun for non-admin ghosts who want to have a brawl on thunderdome.
 *
 * Constants were defined in variables of this class in case if you need to adjust parameters of a brawl through VV.
 * Be aware, that you'll have to make indestructible area if you want to use it properly.
 * /obj/minigame_anchor/thunderdome_poller object is basically a center of the arena and can be used from "mob spawn" ghost menu.
 */
/datum/mini_game/thunderdome_battle
	name = "Thunderdome Melee Challenge"
	spawn_minimum_limit = MIN_PLAYERS_COUNT
	spawn_coefficent = SPAWN_COEFFICENT
	maxplayers = MAX_PLAYERS_COUNT
	var/arena_cooldown = ARENA_COOLDOWN
	var/cqc_arena_radius = CQC_ARENA_RADIUS
	var/ranged_arena_radius = RANGED_ARENA_RADIUS
	var/voting_poll_time = VOTING_POLL_TIME
	var/melee_random_items_count = 2
	var/ranged_random_items_count = 2
	var/mixed_random_items_count = 1
	var/who_started_last_poll //storing ckey of whoever started poll last. Preventing fastest hands of Wild West from polling twice in a row
	var/when_cleansing_happened = 0 //storing (in ticks) moment of arena cleansing
	var/obj/minigame_anchor/thunderdome_poller/last_poller
	var/list/fighters //list of current players on thunderdome, used for tracking winners and stuff.
	var/is_cleansing_going = FALSE
	time_limit = 10 MINUTES
	role = ROLE_THUNDERDOME

/datum/mini_game/thunderdome_battle/New()
	..()
	fighters = list()
	active_timers = list()

/datum/mini_game/thunderdome_battle/proc/start(obj/center, datum/thunderdome_gamemode/gamemode)
	if(is_going)
		return

	if(!gamemode || !gamemode.brawler_type)
		is_going = FALSE
		return

	is_going = TRUE
	add_game_logs("Thunderdome poll voting in [gamemode.name] mode started.")

	var/image/preview_image = new('icons/mob/thunderdome_previews.dmi', gamemode.preview_icon)
	var/list/candidates = shuffle(SSghost_spawns.poll_candidates("Желаете записаться на Тандердом? (Режим — [gamemode.name])", \
		role, poll_time = voting_poll_time, ignore_respawnability = TRUE, check_antaghud = FALSE, source = preview_image))

	var/players_count = clamp(ceil(length(candidates) * spawn_coefficent), 0, maxplayers)
	if(players_count < spawn_minimum_limit)
		notify_ghosts("Not enough players to start Thunderdome Battle!")
		active_timers += addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), arena_cooldown, TIMER_STOPPABLE)
		return

	var/list/random_stuff = get_random_items(item_pool = gamemode.item_pool, item_count = gamemode.random_items_count)
	var/brawler_type = gamemode.brawler_type
	var/radius = gamemode.arena_radius

	for(var/obj/machinery/door/poddoor/pod_door in GLOB.airlocks)
		if(pod_door.id_tag != "TD_CloseCombat")
			continue
		if(!gamemode.extended_area)
			INVOKE_ASYNC(pod_door, TYPE_PROC_REF(/obj/machinery/door, do_animate), "closing")
			pod_door.set_density(TRUE)
			pod_door.set_opacity(TRUE)
			pod_door.layer = pod_door.closingLayer
			pod_door.update_icon()
		else if(pod_door.density)
			INVOKE_ASYNC(pod_door, TYPE_PROC_REF(/obj/machinery/door, do_animate), "opening")
			pod_door.set_density(FALSE)
			pod_door.set_opacity(FALSE)
			pod_door.update_icon()

	var/points = players_count
	var/delta_phi = 2 * PI / points
	var/phi = 0
	var/center_x = center.x
	var/center_y = center.y
	var/center_z = center.z

	for(var/fighter_index in 1 to points)
		var/spawn_angle = phi * 180 / PI
		var/spawn_x = center_x + radius * cos(spawn_angle)
		var/spawn_y = center_y + radius * sin(spawn_angle)

		var/obj/effect/mob_spawn/human/thunderdome/brawler = new brawler_type(locate(spawn_x, spawn_y, center_z))
		brawler.thunderdome = src
		if(length(random_stuff))
			brawler.outfit.backpack_contents += random_stuff

		var/mob/dead/observer/ghost = candidates[fighter_index]

		if(ghost.client?.persistent_client && ghost.has_enabled_antagHUD)
			ghost.client.persistent_client.thunderdome_respawn_blocked = TRUE

		brawler.attack_ghost(ghost)
		phi += delta_phi

	add_game_logs("Thunderdome battle has begun in [gamemode.name] mode.")
	active_timers += addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), time_limit, TIMER_STOPPABLE)

/datum/mini_game/thunderdome_battle/proc/get_random_items(list/item_pool, item_count)
	if(!length(item_pool) || item_count <= 0)
		return list()
	var/list/random_items = list()
	for(var/iteration in 1 to item_count)
		var/picked_item = pick(item_pool)
		if(item_pool[picked_item])
			random_items[picked_item] = item_pool[picked_item]
		else
			random_items += picked_item
	return random_items

/**
 * Clears thunderdome and it's specific areas, also resets thunderdome state.
 *
 */
/datum/mini_game/thunderdome_battle/proc/clear_thunderdome()
	is_cleansing_going = TRUE

	for(var/datum/timedevent/timer in active_timers)
		qdel(timer)
	active_timers.Cut()

	clear_area(GLOB.tdome_arena)
	clear_area(GLOB.tdome_arena_melee)

	is_going = FALSE
	when_cleansing_happened = world.time
	add_game_logs("Thunderdome battle has ended.")
	var/image/alert_overlay = image('icons/obj/assemblies.dmi', "thunderdome-bomb-active-wires")
	notify_players(message = "Thunderdome is ready for battle!", title="Thunderdome News", alert_overlay = alert_overlay, source = last_poller, action = NOTIFY_JUMP)
	is_cleansing_going = FALSE

/**
 * Clears area from:
 * All mobs
 * All objects except thunderdome poller and poddors (shutters included)
 * *Arguments:
 * *zone - specific area
 */
/datum/mini_game/thunderdome_battle/proc/clear_area(area/zone)
	if(!zone)
		return
	for(var/mob/living/living_mob in zone)
		living_mob.melt()
	for(var/obj/target_obj in zone)
		if(istype(target_obj, /obj/machinery/door/poddoor) || istype(target_obj, /obj/minigame_anchor/thunderdome_poller) || istype(target_obj, /obj/structure/sink/puddle) || istype(target_obj, /obj/structure/table/reinforced))
			continue
		qdel(target_obj)

/**
 * Gets location with rounded coordinates (needed for precise geometry builder)
 */
/datum/mini_game/thunderdome_battle/proc/get_rounded_location(curr_x, curr_y, z)
	return locate(round(curr_x), round(curr_y), z)

/**
 * Handles thunderdome's participants deaths. Called from /datum/component/death_timer_reset/
 */
/datum/mini_game/thunderdome_battle/proc/handle_participant_death(mob/living/dead_fighter)
	if(dead_fighter in fighters)
		fighters -= dead_fighter

	var/datum/persistent_client/per_client = GLOB.persistent_clients_by_ckey[dead_fighter.ckey]
	if(per_client)
		per_client.thunderdome_respawn_blocked = TRUE
		// Запускаем таймер на 3 секунды, чтобы игрок успел стать гостом
		addtimer(CALLBACK(src, PROC_REF(apply_respawn_restriction), dead_fighter.ckey), 3 SECONDS)

	if(!length(fighters) && !is_cleansing_going)
		for(var/datum/timedevent/timer in active_timers)
			qdel(timer)
		active_timers.Cut()
		is_cleansing_going = TRUE
		active_timers += addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), 5 SECONDS, TIMER_STOPPABLE)
		if(last_poller)
			last_poller.visible_message(span_danger("Thunderdome has ended with death of all participants! Cleansing in 5 seconds..."))
	return

/datum/mini_game/thunderdome_battle/proc/apply_respawn_restriction(player_ckey)
	if(!player_ckey)
		return

	var/mob/dead/observer/ghost_obs = get_mob_by_ckey(player_ckey)

	if(ghost_obs && isobserver(ghost_obs))
		ghost_obs.has_enabled_antagHUD = TRUE
		ghost_obs.can_reenter_corpse = FALSE
		GLOB.respawnable_list -= ghost_obs
	else
		addtimer(CALLBACK(src, PROC_REF(apply_respawn_restriction), player_ckey), 5 SECONDS)

/**
 * Invisible object which is responsible for rolling brawlers for fighting on thunderdome.
 */
/obj/minigame_anchor/thunderdome_poller
	name = "Thunderdome Poller"
	desc = "Желаете стать лучшим бойцом? Опробуйте себя на Тандердоме в роли мастера ближнего боя!"
	var/gamemode_type = /datum/thunderdome_gamemode
	var/datum/mini_game/thunderdome_battle/thunderdome
	var/datum/thunderdome_gamemode/mode

/obj/minigame_anchor/thunderdome_poller/is_mob_spawnable()
	return TRUE

/obj/minigame_anchor/thunderdome_poller/melee
	name = "Thunderdome Poller (Melee)"
	gamemode_type = /datum/thunderdome_gamemode/melee

/obj/minigame_anchor/thunderdome_poller/ranged
	name = "Thunderdome Poller (Ranged)"
	desc = "Желаете стать лучшим стрелком? Опробуйте себя на Тандердоме в роли мастера со смертельным дальнобойным арсеналом!"
	gamemode_type = /datum/thunderdome_gamemode/ranged

/obj/minigame_anchor/thunderdome_poller/mixed
	name = "Thunderdome Poller (Mixed)"
	desc = "Желаете стать лучшим воином? Опробуйте себя на Тандердоме в роли мастера стрелковых искусств и техник ближнего боя!"
	gamemode_type = /datum/thunderdome_gamemode/mixed

/obj/minigame_anchor/thunderdome_poller/Initialize(mapload)
	. = ..()
	mode = new gamemode_type(src)
	LAZYADD(GLOB.mini_games[mode.name], src)
	GLOB.poi_list |= src

/obj/minigame_anchor/thunderdome_poller/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(!thunderdome)
		thunderdome = GLOB.thunderdome_battle
	var/can_we_roll = thunderdome.when_cleansing_happened + PICK_PENALTY
	if(SSticker.current_state != GAME_STATE_PLAYING)
		return
	if((thunderdome.who_started_last_poll == user.ckey) && (can_we_roll > world.time) && !thunderdome.is_going)
		to_chat(user, "Вы сможете начать набор только спустя [PICK_PENALTY / 10] секунд после очистки Тандердома.")
		return
	if(!SSghost_spawns.is_eligible(user, ROLE_THUNDERDOME))
		to_chat(user, "Вы не можете использовать Тандердом. Включите эту возможность, отметив роль Thunderdome в Game Preferences!")
		return
	if(thunderdome.is_going)
		to_chat(user, "Битва все ещё идёт или прошло недостаточно времени с момента последнего голосования!")
		return
	thunderdome.who_started_last_poll = user.ckey
	thunderdome.last_poller = src
	thunderdome.start(src, mode)
