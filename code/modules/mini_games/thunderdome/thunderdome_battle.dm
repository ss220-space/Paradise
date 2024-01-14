#define MELEE_MODE 			"CqC"		//Spawn people with only melee things
#define RANGED_MODE		 	"Ranged"		//Spawn people with only ranged things
#define MIXED_MODE 			"Mixed"		//Spawn people with melee and ranged things
#define DEFAULT_TIME_LIMIT 	5 MINUTES //Time-to-Live of participants (default - 5 minutes)
#define ARENA_COOLDOWN		5 MINUTES //After which time thunderdome will be once again allowed to use
#define CQC_ARENA_RADIUS	6 //how much tiles away from a center players will spawn
#define RANGED_ARENA_RADIUS	10
#define VOTING_POLL_TIME	30 SECONDS
#define MAX_PLAYERS_COUNT 	16
#define MIN_PLAYERS_COUNT 	2
#define SPAWN_COEFFICENT	0.85 //how many (polled * spawn_coefficent) players will go brawling
#define PICK_PENALTY		30 SECONDS //Prevents fast handed guys from picking polls twice in a row.
// Uncomment this if you want to mess up with thunderdome alone
/*
#define THUND_TESTING
#ifdef THUND_TESTING
#define DEFAULT_TIME_LIMIT 	30 SECONDS
#define ARENA_COOLDOWN 		30 SECONDS
#define VOTING_POLL_TIME 	10 SECONDS
#define MIN_PLAYERS_COUNT 	1
#define PICK_PENALTY 		0
#endif
*/
GLOBAL_DATUM_INIT(thunderdome_battle, /datum/mini_game/thunderdome_battle, new())
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
	is_going = FALSE
	maxplayers = MAX_PLAYERS_COUNT
	time_limit = DEFAULT_TIME_LIMIT
	role = ROLE_THUNDERDOME
	var/arena_cooldown = ARENA_COOLDOWN
	var/cqc_arena_radius = CQC_ARENA_RADIUS
	var/ranged_arena_radius = RANGED_ARENA_RADIUS
	var/voting_poll_time = VOTING_POLL_TIME
	var/melee_random_items_count = 2
	var/ranged_random_items_count = 2
	var/mixed_random_items_count = 1
	var/who_started_last_poll = null //storing ckey of whoever started poll last. Preventing fastest hands of Wild West from polling twice in a row
	var/when_cleansing_happened = 0 //storing (in ticks) moment of arena cleansing
	var/obj/minigame_anchor/thunderdome_poller/last_poller = null
	var/list/fighters = list()	//list of current players on thunderdome, used for tracking winners and stuff.
	var/is_cleansing_going = FALSE

/**
  * Starts poll for candidates with a question and a preview of the mode
  *
  * Arguments:
  * * mode - Name of the tdome mode: "ranged", "cqc", "mixed"
  * * center - Object in the center of a thunderdome
  */
/datum/mini_game/thunderdome_battle/proc/start(obj/center, datum/thunderdome_gamemode/gamemode)
	if(is_going)
		return

	if(!gamemode)
		return

	//Should not happen
	if(!gamemode.brawler_type)
		is_going = FALSE
		stack_trace("There was an attempt to start thunderdome without brawler type defines. Mode: [gamemode.name]")
		return

	is_going = TRUE
	add_game_logs("Thunderdome poll voting in [gamemode.name] mode started.")
	var/image/I = new('icons/mob/thunderdome_previews.dmi', gamemode.preview_icon)
	var/list/candidates = shuffle(SSghost_spawns.poll_candidates("Желаете записаться на Тандердом? (Режим - [gamemode.name])", \
		role, poll_time = voting_poll_time, ignore_respawnability = TRUE, check_antaghud = FALSE, source = I))
	var/players_count = clamp(CEILING(length(candidates)*spawn_coefficent, 1), 0, maxplayers)
	if(players_count < spawn_minimum_limit)
		notify_ghosts("Not enough players to start Thunderdome Battle!")
		addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), arena_cooldown) //making sure there will be no spam
		return

	//vars below are responsible for making spawns at the edge of circle with certain radius
	var/points = players_count
	var/delta_phi = 2 * PI / points
	var/currpoint = 1
	var/curr_x = center.x
	var/curr_y = center.y
	var/phi = 0
	//circle-builder vars ended

	var/list/random_stuff = list()
	var/list/item_pool_ref = gamemode.item_pool
	var/brawler_type = gamemode.brawler_type
	var/radius = gamemode.arena_radius

	random_stuff += get_random_items(item_pool_ref, gamemode.random_items_count)

	if(!gamemode.extended_area)
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(M.id_tag != "TD_CloseCombat")
				continue
			M.do_animate("closing")
			M.density = TRUE
			M.set_opacity(1)
			M.layer = M.closingLayer
			M.update_icon()

	else
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(M.id_tag != "TD_CloseCombat")
				continue
			if(M.density)
				M.do_animate("opening")
				M.density = FALSE
				M.set_opacity(0)
				M.update_icon()


	while(currpoint <= points)
		if(phi > (2 * PI))
			break;
		var/ang = phi * 180 / PI
		curr_x = center.x + radius * cos(ang)
		curr_y = center.y + radius * sin(ang)
		var/obj/effect/mob_spawn/human/thunderdome/brawler = new brawler_type(locate(curr_x, curr_y, center.z))
		brawler.thunderdome = src
		brawler.outfit.backpack_contents += random_stuff
		var/mob/dead/observer/ghost = candidates[currpoint]
		brawler.attack_ghost(ghost)
		phi += delta_phi
		currpoint += 1

	add_game_logs("Thunderdome battle has begun in [gamemode.name] mode.")
	addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), time_limit)

/**
  * Rolls items from a list and returns associative list with keys and values.
  *	Does not check if it's not associative list or some values don't have them.
  *
  * Arguments:
  * * from - list we are collecting items from
  * * count - how many items we will roll from a list
  */

/datum/mini_game/thunderdome_battle/proc/get_random_items(list/from, count)
	if(!length(from))
		return
	var/list/random_items = list()
	if(count <= 0)
		return
	for(var/i in 1 to count)
		random_items += pick(from)

	for(var/i in random_items)
		random_items[i] = from[i]

	return random_items

/**
 * Clears thunderdome and it's specific areas, also resets thunderdome state.
 *
*/
/datum/mini_game/thunderdome_battle/proc/clear_thunderdome()
	is_cleansing_going = TRUE

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
	for(var/mob/living/mob in zone)
		mob.melt()

	for(var/obj/A in zone)
		if(istype(A, /obj/machinery/door/poddoor) || istype(A, /obj/minigame_anchor/thunderdome_poller))
			continue
		qdel(A)

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
	if(!length(fighters) && !is_cleansing_going)
		for(var/datum/timedevent/timer in active_timers)
			qdel(timer)
		is_cleansing_going = TRUE
		addtimer(CALLBACK(src, PROC_REF(clear_thunderdome)), 5 SECONDS) //Everyone died. Time to reset.
		//Also avoiding all issues with death handling of thunderdome participants by letting fighters' components do their stuff.
		if(last_poller)
			last_poller.visible_message(span_danger("Thunderdome has ended with death of all participants! Cleansing in 5 seconds..."))
	return

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
	desc = "Желаете стать лучшим бойцом? Опробуйте себя на Тандердоме в роли мастера ближнего боя!"
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



#undef MELEE_MODE
#undef RANGED_MODE
#undef MIXED_MODE
#undef DEFAULT_TIME_LIMIT
#undef ARENA_COOLDOWN
#undef VOTING_POLL_TIME
#undef MAX_PLAYERS_COUNT
#undef MIN_PLAYERS_COUNT
#undef SPAWN_COEFFICENT
#undef PICK_PENALTY
#undef CQC_ARENA_RADIUS
#undef RANGED_ARENA_RADIUS
