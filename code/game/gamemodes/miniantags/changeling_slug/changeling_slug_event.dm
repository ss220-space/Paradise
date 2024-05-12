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
	if(eventcheck())
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + (60 * 10)
		return


	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Хедслага?", ROLE_CHANGELING, TRUE, source = /mob/living/simple_animal/hostile/headslug/evented)
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C.client
			var/mob/living/simple_animal/hostile/headslug/evented/new_slug = new(vent.loc)
			new_slug.key = C.key
			new_slug.make_slug_antag() //give objective and plays coolsound
			spawncount--
			successSpawn = TRUE
			log_game("[new_slug.key] has become Changeling Headslug.")

/datum/event/headslug_infestation/proc/eventcheck()
	if((num_station_players() <= HI_MINPLAYERS_TRIGGER) ||GAMEMODE_IS_CULTS || GAMEMODE_IS_NUCLEAR || GAMEMODE_IS_SHADOWLING)
		return TRUE


#undef GAMEMODE_IS_CULTS
#undef GAMEMODE_IS_SHADOWLING
#undef HI_MINPLAYERS_TRIGGER
