/datum/antagonist/blob_infected
	name = "Blob"
	roundend_category = "blobs"
	job_rank = ROLE_BLOB
	special_role = SPECIAL_ROLE_BLOB
	antag_hud_name = BLOB_AHUD_NAME
	antag_hud_type = ANTAG_HUD_BLOB
	wiki_page_name = "Blob"
	russian_wiki_name = "Блоб"
	clown_gain_text = "Вы были заражены и подчинены блобу, что помогло вам преодолеть свою клоунскую натуру, позволяя вам владеть оружием, не нанося себе вреда."
	clown_removal_text = "Избавившись от заражения блобом ты возвращаешься к своему неуклюжему, клоунскому \"я\"."
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	var/add_to_mode = TRUE
	var/start_process = TRUE
	var/start_messages = FALSE
	var/need_new_blob = FALSE
	var/is_processing = FALSE
	var/stop_process = FALSE
	var/warn_blob = TRUE
	var/burst_waited_time = 0
	var/message_time = 0
	var/is_tranformed = FALSE
	var/time_to_burst_hight = TIME_TO_BURST_ADDED_HIGHT
	var/time_to_burst_low = TIME_TO_BURST_ADDED_LOW
	var/atom/movable/screen/time_to_burst_display
	var/datum/action/innate/blob/comm/blob_talk_action
	var/burst_wait_time
	var/player_message

/datum/antagonist/blob_infected/on_gain()
	add_game_logs("has been blobized", owner)
	var/return_value = ..()
	burst_wait_time = rand(time_to_burst_low, time_to_burst_hight)
	burst_waited_time = 0
	if(start_process)
		process_blob_player()
	return return_value


/datum/antagonist/blob_infected/Destroy(force, ...)
	add_game_logs("has been deblobized", owner.current)
	stop_process = TRUE
	return ..()


/datum/antagonist/blob_infected/add_owner_to_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(add_to_mode && mode && !(owner in mode.blobs["infected"]))
		mode.blob_win_count += BLOB_TARGET_POINT_PER_CORE
		mode.blobs["infected"] += owner
		mode.update_blob_objective()


/datum/antagonist/blob_infected/remove_owner_from_gamemode()
	var/datum/game_mode/mode = SSticker.mode
	if(add_to_mode && mode && (owner in mode.blobs["infected"]))
		if(!is_tranformed)
			mode.blob_win_count -= BLOB_TARGET_POINT_PER_CORE
		mode.blobs["infected"] -= owner
		mode.update_blob_objective()


/datum/antagonist/blob_infected/give_objectives()
	add_objective(/datum/objective/blob_find_place_to_burst)
	if(SSticker)
		add_objective(SSticker.mode.get_blob_objective())


/datum/antagonist/blob_infected/apply_innate_effects(mob/living/mob_override)
	var/user = ..(mob_override)
	add_blob_talk(user)
	add_burst_display(user)
	is_processing = TRUE
	return user


/datum/antagonist/blob_infected/remove_innate_effects(mob/living/mob_override)
	var/user = ..(mob_override)
	remove_blob_talk(user)
	remove_burst_display(user)
	is_processing = FALSE
	return user


/datum/antagonist/blob_infected/roundend_report_header()
	return

/datum/antagonist/blob_infected/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы превратились в робота! Споры блоба внутри вас были уничтожены…"))
	else
		to_chat(owner.current, span_userdanger("Вы очищены! Вы больше не заражены блобом."))

/datum/antagonist/blob_infected/greet()
	var/list/messages = list()
	messages.Add(span_danger("Вы заражены блобом!"))
	messages.Add("<b>Ваше тело готово породить новое ядро блоба, которое поглотит эту станцию.</b>")
	messages.Add("<b>Найдите подходящее место для создания ядра, а затем возьмите станцию под свой контроль и сокрушите ее!</b>")
	messages.Add("<b>Когда вы найдете нужное место, подождите, пока не превратитесь; это произойдет автоматически. Ваша смерть вызовет преждевременное превращение.</b>")
	messages.Add("<b>Если вы выйдете за пределы уровня станции или окажетесь в космосе во время превращения, то умрете; убедитесь, что в вашем местоположении есть достаточно просторно для вашего будущего ядра.</b>")
	SEND_SOUND(owner.current, 'sound/magic/mutate.ogg')
	return messages


/datum/antagonist/blob_infected/proc/process_blob_player()
	if(stop_process)
		return
	addtimer(CALLBACK(src, PROC_REF(process_blob_player)), BURST_BLOB_TICK)
	if(!is_processing)
		return
	burst_waited_time += BURST_BLOB_TICK
	var/time = (burst_wait_time - burst_waited_time) / (1 SECONDS)
	time_to_burst_display?.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#cb0d0d'>[round(time)]</font></div>"
	if(message_time > BURST_MESSAGE_TICK && start_messages)
		to_chat(owner.current, player_message)
		message_time = 0
	message_time += BURST_BLOB_TICK
	if(burst_waited_time >= burst_wait_time)
		burst_blob(owner, FALSE)
		return
	if(burst_waited_time >= burst_wait_time * BURST_SECOND_STAGE_COEF)
		player_message = SECOND_STAGE_WARN
		return
	if(burst_waited_time >= burst_wait_time * BURST_FIRST_STAGE_COEF)
		player_message = FIRST_STAGE_WARN
		start_messages = TRUE
		return


/datum/antagonist/blob_infected/proc/add_blob_talk(mob/living/antag_mob)
	if(!antag_mob)
		return
	if(!blob_talk_action)
		blob_talk_action = new
	blob_talk_action.Grant(antag_mob)
	antag_mob.update_action_buttons(TRUE)


/datum/antagonist/blob_infected/proc/remove_blob_talk(mob/living/antag_mob)
	if(!antag_mob)
		return
	if(!blob_talk_action)
		return
	blob_talk_action.Remove(antag_mob)
	antag_mob.update_action_buttons(TRUE)

/datum/antagonist/blob_infected/proc/add_burst_display(mob/living/antag_mob)
	if(!antag_mob)
		return
	if(!time_to_burst_display)
		time_to_burst_display = new /atom/movable/screen()
		time_to_burst_display.name = "time to burst"
		time_to_burst_display.icon_state = "block"
		time_to_burst_display.screen_loc = ui_internal
	var/datum/hud/hud = antag_mob.hud_used
	if(!hud)
		addtimer(CALLBACK(src, PROC_REF(add_burst_display), antag_mob), 1 SECONDS)
		return
	hud.static_inventory += time_to_burst_display
	hud.show_hud(hud.hud_version)


/datum/antagonist/blob_infected/proc/remove_burst_display(mob/living/antag_mob)
	if(!antag_mob)
		return
	if(!time_to_burst_display)
		return
	var/datum/hud/hud = antag_mob.hud_used
	hud.static_inventory -= time_to_burst_display
	hud.show_hud(hud.hud_version)


/datum/antagonist/blob_infected/proc/burst_blob_in_space(warned=FALSE)
	if(!owner || !owner.current)
		return
	var/mob/living/C = owner.current
	if(!warned || warn_blob)
		to_chat(C, AWAY_STATION_WARN)
		message_admins("[key_name_admin(C)] was in space when the blobs burst, and will die if [C.p_they()] [C.p_do()] not return to the station.")
		addtimer(CALLBACK(src, PROC_REF(burst_blob_in_space), TRUE), AWAY_AFTER_WARN_TIME)
	else
		SSticker?.mode?.bursted_blobs_count++
		log_admin("[key_name(C)] was in space when attempting to burst as a blob.")
		message_admins("[key_name_admin(C)] was in space when attempting to burst as a blob.")
		C.was_bursted = TRUE
		C.gib()
		if(need_new_blob)
			SSticker?.mode?.make_blobs(1, TRUE)

/datum/antagonist/blob_infected/proc/burst_blob()
	var/client/blob_client = null
	var/turf/location = null
	var/mob/living/C = owner.current
	if(!C || !istype(C))
		return
	if(!GLOB.directory[ckey(owner.key)] || C.was_bursted)
		return
	blob_client = GLOB.directory[ckey(owner.key)]
	location = get_turf(C)
	var/datum/game_mode/mode= SSticker.mode
	if (ismob(C.loc))
		var/mob/M = C.loc
		M.gib()
	if(!is_station_level(location.z) || isspaceturf(location))
		burst_blob_in_space(FALSE)
		return
	if(blob_client && location)
		mode.bursted_blobs_count++
		C.was_bursted = TRUE

		var/datum/antagonist/blob_overmind/overmind = transform_to_overmind()
		owner.remove_antag_datum(/datum/antagonist/blob_infected)
		C.gib()
		var/obj/structure/blob/core/core = new(location, 200, blob_client, SSticker.mode.blob_point_rate)
		if(!(core.overmind && core.overmind.mind))
			return
		core.overmind.mind.add_antag_datum(overmind)
		core.lateblobtimer()
		SSticker?.mode?.process_blob_stages()
		mode.update_blob_objective()


/datum/antagonist/blob_infected/proc/transform_to_overmind()
	var/datum/antagonist/blob_overmind/overmind = new
	overmind.add_to_mode = add_to_mode
	is_tranformed = TRUE
	overmind.is_tranformed = TRUE
	return overmind


/**
 * Takes any datum `source` and checks it for traitor datum.
 */
/proc/isblobinfected(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/blob_infected)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/blob_infected)
