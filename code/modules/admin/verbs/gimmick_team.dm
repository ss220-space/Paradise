// Gimmick Team
// Spawns a group of player-controlled mobs with an outfit specified by the admin, at their location.

/client/proc/gimmick_team()
	set category = "Event"
	set name = "Отправить Гиммик тим"
	set desc = "Спавнит команду игроков в выбранной экипировке."
	if(!check_rights(R_EVENT))
		return

	if(!SSticker)
		alert("Игра еще не началась!")
		return

	if(alert("Вы хотите заспавнить Гиммик тим в ВАШЕЙ ТЕКУЩЕЙ ЛОКАЦИИ?",,"Да","Нет")=="Нет")
		return

	var/turf/T = get_turf(mob)

	var/force_species = FALSE
	var/selected_species = null
	if(alert("Вы хотите выбрать какую-то расу для отряда? Нет - будут обычные люди.",,"Да","Нет")=="Да")
		force_species = TRUE
		selected_species = tgui_input_list(src, "Выберете расу", "Выбор расы", GLOB.all_species)
		if(!selected_species)
			alert("Спавн остановлен.")
			return	// You didn't pick, abort

	var/list/teamsizeoptions = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/teamsize = tgui_input_list(src, "Укажите количество игроков.", "Количество игроков", teamsizeoptions)
	if(!(teamsize in teamsizeoptions))
		alert("Недопустимый размер отряда. Отмена.")
		return

	var/team_name = null
	while(!team_name)
		team_name = sanitize(copytext_char(input(src, "Укажите название команды. По умолчанию \"Гиммик тим\".", "Укажите название", ""),1,MAX_MESSAGE_LEN))
		if(!team_name)
			team_name = "Гиммик тим"

	var/themission = null
	while(!themission)
		themission = sanitize(copytext_char(input(src, "Укажите миссию отряда.", "Укажите миссию", ""),1,MAX_MESSAGE_LEN))
		if(!themission)
			alert("Миссия не указана. Отмена.")
			return

	var/minhours = input(usr, "Укажите минимальное количество часов для [team_name]?", "Минимальное число часов", 60) as null|num

	var/dresscode = robust_dress_shop()
	if(!dresscode)
		return

	var/is_syndicate = 0
	if(alert("Вы хотите, чтобы члены отряда автоматически классифицировались как антагонисты?",,"Да","Нет")=="Да")
		is_syndicate = 1

	var/list/players_to_spawn = list()
	players_to_spawn = pick_candidates_all_types(src, teamsize, "Вы хотите сыграть за \a [team_name]?", min_hours = minhours, role_cleanname = team_name, reason = themission)

	if(!players_to_spawn.len)
		to_chat(src, "Никто не согласился.")
		return 0

	var/players_spawned = 0
	for(var/mob/thisplayer in players_to_spawn)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(T)
		H.name = random_name(pick(MALE,FEMALE))
		var/datum/preferences/A = new() //Randomize appearance
		A.real_name = H.name
		A.copy_to(H)
		H.dna.ready_dna(H)

		if(force_species)
			var/datum/species/selected_species_datum = GLOB.all_species[selected_species]
			H.set_species(selected_species_datum.type)
			H.regenerate_icons()

		H.mind_initialize()
		H.mind.assigned_role = SPECIAL_ROLE_EVENTMISC
		H.mind.special_role = SPECIAL_ROLE_EVENTMISC
		SSticker.mode.eventmiscs += H.mind
		SSticker.mode.update_eventmisc_icons_added(H.mind)
		H.mind.offstation_role = TRUE
		H.key = thisplayer.key
		H.change_voice()
		if(dresscode != "Naked")
			H.equipOutfit(dresscode, FALSE)

		to_chat(H, "<BR><span class='danger'><B>[themission]</B></span>")
		H.mind.store_memory("<B>[themission]</B><BR><BR>")

		if(is_syndicate)
			SSticker.mode.traitors |= H.mind //Adds them to extra antag list

		players_spawned++
		if(players_spawned >= teamsize)
			break


	log_and_message_admins("used Spawn Gimmick Team.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Gimmick Team") //If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!

// ---------------------------------------------------------------------------------------------------------
