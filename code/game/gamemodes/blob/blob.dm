//Few global vars to track the blob
GLOBAL_LIST_EMPTY(blobs)
GLOBAL_LIST_EMPTY(blob_cores)
GLOBAL_LIST_EMPTY(blob_nodes)

/datum/game_mode
	var/list/blob_overminds = list()

/datum/game_mode/blob
	name = "Блоб"
	config_tag = "blob"

	required_players = 30
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = list("Cyborg", "AI")

	var/declared = 0
	var/burst = 0

	var/cores_to_spawn = 1
	var/players_per_core = 30
	var/blob_point_rate = 3

	var/blobwincount = 350

	var/list/infected_crew = list()

/datum/game_mode/blob/pre_setup()

	var/list/possible_blobs = get_players_for_role(ROLE_BLOB)

	// stop setup if no possible traitors
	if(!possible_blobs.len)
		return 0

	cores_to_spawn = max(round(num_players()/players_per_core, 1), 1)

	blobwincount = initial(blobwincount) * cores_to_spawn


	for(var/j = 0, j < cores_to_spawn, j++)
		if(!possible_blobs.len)
			break

		var/datum/mind/blob = pick(possible_blobs)
		infected_crew += blob
		blob.special_role = SPECIAL_ROLE_BLOB
		blob.restricted_roles = restricted_jobs
		log_game("[key_name(blob)] был выбран Блобом")
		possible_blobs -= blob

	if(!infected_crew.len)
		return 0
	..()
	return 1

/datum/game_mode/blob/proc/get_blob_candidates()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.stat && player.mind && !player.client.skip_antag && !player.mind.special_role && !jobban_isbanned(player, "Syndicate") && (ROLE_BLOB in player.client.prefs.be_special))
			candidates += player
	return candidates


/datum/game_mode/blob/proc/blobize(var/mob/living/carbon/human/blob)
	var/datum/mind/blobmind = blob.mind
	if(!istype(blobmind))
		return 0

	infected_crew += blobmind
	blobmind.special_role = SPECIAL_ROLE_BLOB
	update_blob_icons_added(blobmind)

	log_game("[key_name(blob)] был выбран Блобом")
	greet_blob(blobmind)
	to_chat(blob, "<span class='userdanger'>Ты чувствуешь себя вялым и вздутым! Скоро ты лопнешь!</span>")
	spawn(600)
		burst_blob(blobmind)
	return 1

/datum/game_mode/blob/proc/make_blobs(var/count)
	var/list/candidates = get_blob_candidates()
	var/mob/living/carbon/human/blob = null
	count=min(count, candidates.len)
	for(var/i = 0, i < count, i++)
		blob = pick(candidates)
		candidates -= blob
		blobize(blob)
	return count



/datum/game_mode/blob/announce()
	to_chat(world, "<B>Текущий режим игры - <font color='green'>Блоб</font>!</B>")
	to_chat(world, "<B>Опасный инопланетный организм стремительно распространяется по станции!</B>")
	to_chat(world, "Вам необходимо уничтожить его, минимизируя ущерб станции.")


/datum/game_mode/blob/proc/greet_blob(var/datum/mind/blob)
	to_chat(blob.current, "<span class='userdanger'>Вы заражены Блобом!</span>")
	to_chat(blob.current, "<b>Ваше тело готово стать новым ядром Блоба, чтобы поглотить станцию.</b>")
	to_chat(blob.current, "<b>Найдите хорошее место для создания ядра и сокрушите станцию!</b>")
	to_chat(blob.current, "<b>Когда вы нашли место, подождите момента вылупления ядра. Это произойдет автоматически и вы не можете ускорить процесс.</b>")
	to_chat(blob.current, "<b>Если вы выйдете за пределы станции или в космос - вы погибнете. Убедитесь что ваше место имеет достаточную площадь для покрытия.</b>")
	SEND_SOUND(blob.current, 'sound/magic/mutate.ogg')
	return

/datum/game_mode/blob/proc/show_message(var/message)
	for(var/datum/mind/blob in infected_crew)
		to_chat(blob.current, message)

/datum/game_mode/blob/proc/burst_blobs()
	for(var/datum/mind/blob in infected_crew)
		burst_blob(blob)

/datum/game_mode/blob/proc/burst_blob(var/datum/mind/blob, var/warned=0)
	var/client/blob_client = null
	var/turf/location = null

	if(iscarbon(blob.current))
		var/mob/living/carbon/C = blob.current
		if(GLOB.directory[ckey(blob.key)])
			blob_client = GLOB.directory[ckey(blob.key)]
			location = get_turf(C)
			if(!is_station_level(location.z) || istype(location, /turf/space))
				if(!warned)
					to_chat(C, "<span class='userdanger'>Вы чувствуете что готовы взорваться, но выбрали неподходящее место. Нужно вернуться на станцию!</span>")
					message_admins("[key_name_admin(C)] был в космосе когда носитель блоба взорвался, и умрет если [C.p_they()] [C.p_do()] не вернется на станцию.")
					spawn(300)
						burst_blob(blob, 1)
				else
					burst++
					log_admin("[key_name(C)] находился в космосе при попытке стать блобом.")
					message_admins("[key_name_admin(C)] находился в космосе при попытке стать блобом.")
					C.gib()
					make_blobs(1)
					check_finished() //Still needed in case we can't make any blobs

			else if(blob_client && location)
				burst++
				C.gib()
				var/obj/structure/blob/core/core = new(location, 200, blob_client, blob_point_rate)
				if(core.overmind && core.overmind.mind)
					core.overmind.mind.name = blob.name
					infected_crew -= blob
					infected_crew += core.overmind.mind
					core.overmind.mind.special_role = SPECIAL_ROLE_BLOB_OVERMIND

/datum/game_mode/blob/post_setup()

	for(var/datum/mind/blob in infected_crew)
		greet_blob(blob)
		update_blob_icons_added(blob)

	if(SSshuttle)
		SSshuttle.emergencyNoEscape = 1

	spawn(0)

		var/wait_time = rand(waittime_l, waittime_h)

		sleep(wait_time)

		send_intercept(0)

		sleep(100)

		show_message("<span class='userdanger'>Вы чувствуете вялость и вздутие.</span>")

		sleep(wait_time)

		show_message("<span class='userdanger'>Вы чувствуете, что вот-вот лопнете.</span>")

		sleep(wait_time / 2)

		burst_blobs()

		// Stage 0
		sleep(wait_time)
		stage(0)

		// Stage 1
		sleep(wait_time)
		stage(1)

		// Stage 2
		sleep(30000)
		stage(2)

	return ..()

/datum/game_mode/blob/proc/stage(var/stage)
	switch(stage)
		if(0)
			send_intercept(1)
			declared = 1
		if(1)
			GLOB.event_announcement.Announce("Подтверждена вспышка биологической угрозы 5 уровня на борту [station_name()]. Весь персонал должен сдерживать вспышку.", "Biohazard Alert", 'sound/AI/outbreak5.ogg')
		if(2)
			send_intercept(2)

/datum/game_mode/proc/update_blob_icons_added(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_BLOB]
	antaghud.join_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, "hudblob")

/datum/game_mode/proc/update_blob_icons_removed(datum/mind/mob_mind)
	var/datum/atom_hud/antag/antaghud = GLOB.huds[ANTAG_HUD_BLOB]
	antaghud.leave_hud(mob_mind.current)
	set_antag_hud(mob_mind.current, null)
