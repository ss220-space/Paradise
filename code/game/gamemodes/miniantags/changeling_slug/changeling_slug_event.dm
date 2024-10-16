#define HI_MINPLAYERS_TRIGGER 59
#define GAMEMODE_IS_SHADOWLING (SSticker && istype(SSticker.mode, /datum/game_mode/shadowling))
#define GAMEMODE_IS_CULTS (SSticker && (istype(SSticker.mode, /datum/game_mode/cult) || istype(SSticker.mode, /datum/game_mode/clockwork)))

/datum/event/headslug_infestation
	announceWhen = 400
	var/spawncount = 1
	var/successSpawn = FALSE

/datum/event/headslug_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50) //announce just like borers
	spawncount = round(length(GLOB.data_core.general)/30)

/datum/event/headslug_infestation/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.command_announcement.Announce("Обнаружены неопознанные формы жизни на борту [station_name()]. Обезопасьте все наружные входы и выходы, включая вентиляцию и вытяжки.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.", new_sound = 'sound/AI/aliens.ogg')
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Headslug Infestation")

/datum/event/headslug_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))
	// It is necessary to wrap this to avoid the event triggering repeatedly.

/datum/event/headslug_infestation/proc/wrappedstart()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE) //check for amount of people
	if(!can_start())
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + (60 * 10)
		return


	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Хедслага?", ROLE_CHANGELING, TRUE, source = /mob/living/simple_animal/hostile/headslug/evented)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C
			var/mob/living/simple_animal/hostile/headslug/evented/new_slug = new(vent.loc)
			new_slug.key = C.key
			new_slug.make_slug_antag() //give objective and plays coolsound
			spawncount--
			successSpawn = TRUE
			log_game("[new_slug.key] has become Changeling Headslug.")

/datum/event/headslug_infestation/can_start()
	var/list/adm_message
	var/min_player_passed = (num_station_players() > HI_MINPLAYERS_TRIGGER)
	var/gamemode_passed = !(GAMEMODE_IS_CULTS || GAMEMODE_IS_NUCLEAR || GAMEMODE_IS_SHADOWLING)

	. = ..() // true == forced by admins

	if(min_player_passed && gamemode_passed) // all checks passed
		return TRUE

	if(. && !min_player_passed) // forced, bypassing player limits
		LAZYADD(adm_message, "Minimum players")

	if(. && !gamemode_passed) // forced, bypassing gamemode limits
		LAZYADD(adm_message, "Gamemode(not Nuclear, Shadowling or Cults)")

	if(LAZYLEN(adm_message))
		adm_message = english_list(adm_message)
		log_and_message_admins("Event \"[type]\" launched bypassing the limits: [adm_message]!")
		return TRUE

	// not forced, not passed
	var/list/fail_messsage
	if(!min_player_passed) // not enough players to start
		LAZYADD(fail_messsage, "Minimum players")

	if(!gamemode_passed) // not allowed in this gamemode
		LAZYADD(fail_messsage, "Gamemode(not Nuclear, Shadowling or Cults)")

	fail_messsage = english_list(fail_messsage)
	log_and_message_admins("Random event attempted to spawn a headslug, but failed this checks: [fail_messsage]!")

	return FALSE


#undef GAMEMODE_IS_CULTS
#undef GAMEMODE_IS_SHADOWLING
#undef HI_MINPLAYERS_TRIGGER
