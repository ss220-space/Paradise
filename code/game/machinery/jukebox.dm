/obj/machinery/jukebox
	name = "jukebox"
	desc = "Классический музыкальный автомат."
	icon = 'icons/obj/machines/jukebox.dmi'
	icon_state = "jukebox"
	base_icon_state = "jukebox"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_BAR)
	processing_flags = START_PROCESSING_MANUALLY
	idle_power_usage = 10
	active_power_usage = 100
	integrity_failure = 100
	/// Cooldown between "Error" sound effects being played
	COOLDOWN_DECLARE(jukebox_error_cd)
	/// Cooldown between being allowed to play another song
	COOLDOWN_DECLARE(jukebox_song_cd)
	/// TimerID to when the current song ends
	var/song_timerid
	/// The actual music player datum that handles the music
	var/datum/jukebox/music_player

	/// Does Jukebox require coin?
	var/need_coin = FALSE
	/// Inserted coin for payment
	var/obj/item/coin/payment

/obj/machinery/jukebox/get_ru_names()
	return list(
		NOMINATIVE = "музыкальный автомат",
		GENITIVE = "музыкального автомата",
		DATIVE = "музыкальному автомату",
		ACCUSATIVE = "музыкальный автомат",
		INSTRUMENTAL = "музыкальным автоматом",
		PREPOSITIONAL = "музыкальном автомате",
	)

/obj/machinery/jukebox/Initialize(mapload)
	. = ..()
	music_player = new(src)
	register_context()

/obj/machinery/jukebox/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Открутить" : "Прикрутить"
		return CONTEXTUAL_SCREENTIP_SET
	context[SCREENTIP_CONTEXT_RMB] = "Переключить проигрыватель"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/jukebox/Destroy()
	stop_music()
	QDEL_NULL(music_player)
	QDEL_NULL(payment)
	return ..()

/obj/machinery/jukebox/examine(mob/user)
	. = ..()
	if(music_player.active_song_sound)
		. += "Сейчас играет: [music_player.selection.song_name]"
	if(need_coin)
		. += "Требует монету для воспроизведения."

/obj/machinery/jukebox/wrench_act(mob/living/user, obj/item/tool)
	if(!isnull(music_player.active_song_sound) || (resistance_flags & INDESTRUCTIBLE))
		return
	. = TRUE
	if(!tool.use_tool(src, user, 0, volume = tool.tool_volume))
		return
	if(!anchored && !isinspace())
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE
	else if(anchored)
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE

/obj/machinery/jukebox/update_icon_state()
	if(stat & (BROKEN))
		icon_state = "[base_icon_state]_broken"
	else
		icon_state = "[base_icon_state][music_player.active_song_sound ? "-active" : null]"

/obj/machinery/jukebox/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		return
	if(music_player.active_song_sound)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask", src)

/obj/machinery/jukebox/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !allowed(user) || !anchored)
		return .
	toggle_playing(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/jukebox/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/jukebox/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/jukebox/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!is_operational())
		return NONE

	if(is_cash(used))
		if(payment)
			balloon_alert(user, "монета уже вставлена")
			return ITEM_INTERACT_SUCCESS
		if(!user.drop_from_active_hand())
			balloon_alert(user, "монета выскользнула!")
			return ITEM_INTERACT_SUCCESS
		used.forceMove(src)
		payment = used
		balloon_alert_to_viewers("вставил[GEND_A_O_I(user)] монету", "монета вставлена")
		playsound(src, 'sound/machines/coin_accept.ogg', 50, TRUE)
		ui_interact(user)
		add_fingerprint(user)
		return ITEM_INTERACT_SUCCESS

	if(used.GetID())
		if(!allowed(user))
			balloon_alert(user, "нет доступа!")
			return ITEM_INTERACT_SUCCESS
		need_coin = !need_coin
		balloon_alert_to_viewers("[need_coin ? "вернул" : "сняли"] ограничения", "[need_coin ? "вернул" : "снял"] ограничения")
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/jukebox/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return ..()
	if(!anchored)
		balloon_alert(user, "должно быть закреплено!")
		return UI_CLOSE
	if(!allowed(user))
		balloon_alert(user, "нет доступа!")
		user.playsound_local(src, 'sound/machines/compiler/compiler-failure.ogg', 20, TRUE)
		return UI_CLOSE
	if(!length(music_player.songs))
		to_chat(user,span_warning("Ошибка: Для вашей станции не было авторизовано ни одной музыкальной композиции. Обратитесь к Центральному командованию с просьбой решить эту проблему."))
		user.playsound_local(src, 'sound/machines/compiler/compiler-failure.ogg', 25, TRUE)
		return UI_CLOSE
	return ..()

/obj/machinery/jukebox/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Jukebox", name)
		ui.open()

/obj/machinery/jukebox/ui_data(mob/user)
	var/list/data = ..()
	music_player.get_ui_data(data)

	data["need_coin"] = need_coin
	data["payment"] = payment
	data["advanced_admin"] = user.can_advanced_admin_interact()
	return data

/obj/machinery/jukebox/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user
	switch(action)
		if("toggle")
			toggle_playing(user)
			return TRUE

		if("select_track")
			if(!isnull(music_player.active_song_sound))
				to_chat(user, span_warning("Ошибка: Вы не можете сменить трек, пока не закончится текущий."))
				return TRUE

			var/datum/track/new_song = music_player.songs[params["track"]]
			if(QDELETED(src) || !istype(new_song, /datum/track))
				return TRUE

			music_player.selection = new_song
			return TRUE

		if("set_volume")
			var/new_volume = params["volume"]
			if(new_volume == "reset" || new_volume == "max")
				music_player.set_volume_to_max()
			else if(new_volume == "min")
				music_player.set_new_volume(0)
			else if(isnum(text2num(new_volume)))
				music_player.set_new_volume(text2num(new_volume))
			return TRUE

		if("loop")
			music_player.sound_loops = !!params["looping"]
			return TRUE

///If a song is playing, cut it. If none is playing, and the cooldown is up, start the queued track.
/obj/machinery/jukebox/proc/toggle_playing(mob/user)
	if(!isnull(music_player.active_song_sound))
		stop_music()
		return
	if(COOLDOWN_FINISHED(src, jukebox_song_cd))
		activate_music()
		return
	balloon_alert(user, "на перезарядке ещё [DisplayTimeText(COOLDOWN_TIMELEFT(src, jukebox_song_cd))]!")
	if(COOLDOWN_FINISHED(src, jukebox_error_cd))
		playsound(src, 'sound/machines/compiler/compiler-failure.ogg', 25, TRUE)
		COOLDOWN_START(src, jukebox_error_cd, 15 SECONDS)

/obj/machinery/jukebox/proc/activate_music()
	if(!isnull(music_player.active_song_sound))
		return FALSE

	music_player.start_music()
	update_use_power(ACTIVE_POWER_USE)
	update_appearance(UPDATE_ICON_STATE)
	if(!music_player.sound_loops)
		song_timerid = addtimer(CALLBACK(src, PROC_REF(stop_music)), music_player.selection.song_length, TIMER_UNIQUE|TIMER_STOPPABLE|TIMER_DELETE_ME)
	return TRUE

/obj/machinery/jukebox/proc/stop_music()
	if(!isnull(song_timerid))
		deltimer(song_timerid)

	music_player.unlisten_all()
	music_player.end_time = 0
	music_player.start_time = 0
	QDEL_NULL(payment)

	if(!QDELING(src))
		COOLDOWN_START(src, jukebox_song_cd, 10 SECONDS)
		playsound(src,'sound/machines/terminal_off.ogg', 50, TRUE)
		update_use_power(IDLE_POWER_USE)
		update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/machinery/jukebox/obj_break()
	if(stat & BROKEN)
		return
	stat |= BROKEN
	idle_power_usage = 0
	active_power_usage = 0
	stop_music()
	update_appearance()

/obj/machinery/jukebox/no_access
	req_access = null

/obj/machinery/jukebox/bar
	req_access = null
	need_coin = TRUE

/obj/machinery/jukebox/disco
	name = "radiant dance machine mark IV"
	desc = "Производство первых трех прототипов было прекращено после массовых несчастных случаев."
	icon_state = "disco"
	base_icon_state = "disco"
	req_access = list(ACCESS_ENGINE)

	/// Spotlight effects being played
	VAR_PRIVATE/list/obj/item/flashlight/spotlight/spotlights = list()
	/// Sparkle effects being played
	VAR_PRIVATE/list/obj/effect/overlay/sparkles/sparkles = list()

/obj/machinery/jukebox/disco/get_ru_names()
	return list(
		NOMINATIVE = "блестящая танцевальная машина \"Mark IV\"",
		GENITIVE = "блестящей танцевальной машины \"Mark IV\"",
		DATIVE = "блестящей танцевальной машине \"Mark IV\"",
		ACCUSATIVE = "блестящую танцевальную машину \"Mark IV\"",
		INSTRUMENTAL = "блестящей танцевальной машиной \"Mark IV\"",
		PREPOSITIONAL = "блестящей танцевальной машине \"Mark IV\"",
	)

/obj/machinery/jukebox/disco/indestructible
	name = "radiant dance machine mark V"
	desc = "Дизайн переработан с учетом данных, полученных в ходе обширных исследований в области танцев и плазменных накопителей."
	req_access = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/jukebox/disco/indestructible/get_ru_names()
	return list(
		NOMINATIVE = "блестящая танцевальная машина \"Mark V\"",
		GENITIVE = "блестящей танцевальной машины \"Mark V\"",
		DATIVE = "блестящей танцевальной машине \"Mark V\"",
		ACCUSATIVE = "блестящую танцевальную машину \"Mark V\"",
		INSTRUMENTAL = "блестящей танцевальной машиной \"Mark V\"",
		PREPOSITIONAL = "блестящей танцевальной машине \"Mark V\"",
	)

/obj/machinery/jukebox/disco/activate_music()
	. = ..()
	if(!.)
		return
	dance_setup()
	lights_spin()
	begin_processing()

/obj/machinery/jukebox/disco/stop_music()
	. = ..()
	if(!.)
		return
	QDEL_LIST(spotlights)
	QDEL_LIST(sparkles)
	end_processing()

/obj/machinery/jukebox/disco/process()
	var/dance_num = rand(1, 4) //all will do the same dance
	for(var/mob/living/dancer in music_player.get_active_listeners())
		if(!(dancer.mobility_flags & MOBILITY_MOVE))
			continue
		if(HAS_TRAIT(dancer, TRAIT_DISCO_DANCER))
			continue
		dance(dancer, dance_num)

/obj/machinery/jukebox/disco/proc/dance_setup()
	var/turf/center = get_turf(src)
	FOR_DVIEW(var/turf/tile, 3, get_turf(src), INVISIBILITY_LIGHTING)
		if(tile.x == center.x && tile.y > center.y)
			spotlights += new /obj/item/flashlight/spotlight(tile, 1 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), COLOR_SOFT_RED)
			continue
		if(tile.x == center.x && tile.y < center.y)
			spotlights += new /obj/item/flashlight/spotlight(tile, 1 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_PURPLE)
			continue
		if(tile.x > center.x && tile.y == center.y)
			spotlights += new /obj/item/flashlight/spotlight(tile, 1 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_DIM_YELLOW)
			continue
		if(tile.x < center.x && tile.y == center.y)
			spotlights += new /obj/item/flashlight/spotlight(tile, 1 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_GREEN)
			continue
		if((tile.x+1 == center.x && tile.y+1 == center.y) || (tile.x+2 == center.x && tile.y+2 == center.y))
			spotlights += new /obj/item/flashlight/spotlight(tile, 1.4 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_ORANGE)
			continue
		if((tile.x-1 == center.x && tile.y-1 == center.y) || (tile.x-2 == center.x && tile.y-2 == center.y))
			spotlights += new /obj/item/flashlight/spotlight(tile, 1.4 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_CYAN)
			continue
		if((tile.x-1 == center.x && tile.y+1 == center.y) || (tile.x-2 == center.x && tile.y+2 == center.y))
			spotlights += new /obj/item/flashlight/spotlight(tile, 1.4 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_BLUEGREEN)
			continue
		if((tile.x+1 == center.x && tile.y-1 == center.y) || (tile.x+2 == center.x && tile.y-2 == center.y))
			spotlights += new /obj/item/flashlight/spotlight(tile, 1.4 + get_dist(src, tile), 30 - (get_dist(src, tile) * 8), LIGHT_COLOR_BLUE)
			continue
		continue
	FOR_DVIEW_END

/obj/machinery/jukebox/disco/proc/hierofunk()
	for(var/i in 1 to 10)
		spawn_atom_to_turf(/obj/effect/temp_visual/hierophant/telegraph/edge, src, 1, FALSE)
		sleep(0.5 SECONDS)

#define DISCO_INFENO_RANGE (rand(85, 115) * 0.01)

/obj/machinery/jukebox/disco/proc/lights_spin()
	set waitfor = FALSE
	for(var/i in 1 to 25)
		if(QDELETED(src) || isnull(music_player.active_song_sound))
			return
		var/obj/effect/overlay/sparkles/sparkle = new /obj/effect/overlay/sparkles(src)
		sparkle.alpha = 0
		sparkles += sparkle
		switch(i)
			if(1 to 8)
				spawn(0)
					sparkle.orbit(src, 30, TRUE, 60, 36, TRUE, FALSE)
			if(9 to 16)
				spawn(0)
					sparkle.orbit(src, 62, TRUE, 60, 36, TRUE, FALSE)
			if(17 to 24)
				spawn(0)
					sparkle.orbit(src, 95, TRUE, 60, 36, TRUE, FALSE)
			if(25)
				sparkle.pixel_y = 7
				sparkle.forceMove(get_turf(src))
		sleep(0.7 SECONDS)
	for(var/obj/effect/overlay/sparkles/reveal as anything in sparkles)
		reveal.alpha = 255
	while(!isnull(music_player.active_song_sound))
		for(var/obj/item/flashlight/spotlight/glow as anything in spotlights) // The multiples reflects custom adjustments to each colors after dozens of tests
			if(QDELETED(glow))
				stack_trace("[glow?.gc_destroyed ? "Qdeleting glow" : "null entry"] found in [src].[gc_destroyed ? " Source qdeleting at the time." : ""]")
				return
			switch(glow.light_color)
				if(COLOR_SOFT_RED)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_BLUE)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 1.48, LIGHT_COLOR_BLUE)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_BLUE)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 2, LIGHT_COLOR_GREEN)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_GREEN)
				if(LIGHT_COLOR_GREEN)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_ORANGE)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.5, LIGHT_COLOR_ORANGE)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_ORANGE)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 2.27, LIGHT_COLOR_PURPLE)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_PURPLE)
				if(LIGHT_COLOR_PURPLE)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_BLUEGREEN)
					else
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.44, LIGHT_COLOR_BLUEGREEN)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_BLUEGREEN)
					if(glow.even_cycle)
						glow.set_light_range(glow.base_light_range * DISCO_INFENO_RANGE)
						glow.set_light_color(LIGHT_COLOR_DIM_YELLOW)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_DIM_YELLOW)
				if(LIGHT_COLOR_DIM_YELLOW)
					if(glow.even_cycle)
						glow.set_light_on(FALSE)
						glow.set_light_color(LIGHT_COLOR_CYAN)
					else
						glow.set_light_range(glow.base_light_range * DISCO_INFENO_RANGE)
						glow.set_light_color(LIGHT_COLOR_CYAN)
						glow.set_light_on(TRUE)
				if(LIGHT_COLOR_CYAN)
					if(glow.even_cycle)
						glow.set_light_range_power_color(glow.base_light_range * DISCO_INFENO_RANGE, glow.light_power * 0.68, COLOR_SOFT_RED)
						glow.set_light_on(TRUE)
					else
						glow.set_light_on(FALSE)
						glow.set_light_color(COLOR_SOFT_RED)
					glow.even_cycle = !glow.even_cycle
		if(prob(2))  // Unique effects for the dance floor that show up randomly to mix things up
			INVOKE_ASYNC(src, PROC_REF(hierofunk))
		sleep(music_player.selection.song_beat_deciseconds || 1 SECONDS)
		if(QDELETED(src))
			return

#undef DISCO_INFENO_RANGE

/// Show your moves
/obj/machinery/jukebox/disco/proc/dance(mob/living/dancer, dance_num)
	ADD_TRAIT(dancer, TRAIT_DISCO_DANCER, UNIQUE_TRAIT_SOURCE(src))
	switch(dance_num)
		if(1)
			dance1(dancer)
		if(2)
			dance2(dancer)
		if(3)
			start_dance3(dancer)
		if(4)
			dance4(dancer)

/mob/proc/dance_flip()
	if(dir == WEST)
		emote("flip")

/obj/machinery/jukebox/disco/proc/dance1(mob/living/dancer)
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, UNIQUE_TRAIT_SOURCE(src)), 6.5 SECONDS, TIMER_CLIENT_TIME)
	for(var/i in 0 to (6 SECONDS) step (1.5 SECONDS))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dance_rotate), dancer, CALLBACK(dancer, TYPE_PROC_REF(/mob, dance_flip))), i, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/dance2(mob/living/dancer, dance_length = 2.5 SECONDS)
	var/matrix/initial_matrix = matrix(dancer.transform)
	var/list/transforms = list(
		"[NORTH]" = matrix(dancer.transform).Translate(0, 3),
		"[EAST]" = matrix(dancer.transform).Translate(3, 0),
		"[SOUTH]" = matrix(dancer.transform).Translate(0, -3),
		"[WEST]" = matrix(dancer.transform).Translate(-1, -1),
	)
	addtimer(VARSET_CALLBACK(dancer, transform, initial_matrix), dance_length + 0.5 SECONDS, TIMER_CLIENT_TIME)
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, UNIQUE_TRAIT_SOURCE(src)), dance_length + 0.5 SECONDS)
	for(var/i in 1 to dance_length)
		addtimer(CALLBACK(src, PROC_REF(animate_dance2), dancer, transforms, initial_matrix), i, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/animate_dance2(mob/living/dancer, list/transforms, matrix/initial_matrix)
	dancer.setDir(turn(dancer.dir, 90))
	animate(dancer, transform = transforms[num2text(dancer.dir)], time = 1, loop = 0)
	animate(transform = initial_matrix, time = 2, loop = 0)

/obj/machinery/jukebox/disco/proc/start_dance3(mob/living/dancer, dance_length = 3 SECONDS)
	var/initially_resting = dancer.resting
	var/direction_index = 1 //this should allow everyone to dance in the same direction
	addtimer(TRAIT_CALLBACK_REMOVE(dancer, TRAIT_DISCO_DANCER, UNIQUE_TRAIT_SOURCE(src)), dance_length + 0.2 SECONDS)
	addtimer(CALLBACK(dancer, TYPE_PROC_REF(/mob/living, set_resting), initially_resting, TRUE, TRUE), dance_length + 0.2 SECONDS, TIMER_CLIENT_TIME)
	for(var/i in 1 to dance_length step 2) // 1 = 0.1 seconds
		addtimer(CALLBACK(src, PROC_REF(dance3), dancer, GLOB.cardinal[direction_index]), i, TIMER_CLIENT_TIME)
		direction_index++
		if(direction_index > length(GLOB.cardinal))
			direction_index = 1

/obj/machinery/jukebox/disco/proc/dance3(mob/living/dancer, dir)
	dancer.setDir(dir)
	dancer.set_resting(!dancer.resting, silent = TRUE, instant = TRUE)

/obj/machinery/jukebox/disco/proc/dance4(mob/living/dancer, dance_length = 1.5 SECONDS)
	var/matrix/initial_matrix = matrix(dancer.transform)
	animate(dancer, transform = matrix(dancer.transform).Turn(180), time = 2, loop = 0)
	dancer.emote("spin")
	addtimer(CALLBACK(src, PROC_REF(dance4_revert), dancer, initial_matrix), dance_length, TIMER_CLIENT_TIME)

/obj/machinery/jukebox/disco/proc/dance4_revert(mob/living/dancer, matrix/starting_matrix)
	animate(dancer, transform = starting_matrix, time = 5, loop = 0)
	REMOVE_TRAIT(dancer, TRAIT_DISCO_DANCER, UNIQUE_TRAIT_SOURCE(src))
