// Gimmick Team
// Spawns a group of player-controlled mobs with an outfit specified by the admin, at their location.

ADMIN_VERB(gimmick_team, R_EVENT, "Отправить \"Гиммик комманду\"", "Спавнит команду игроков в выбранной экипировке.", ADMIN_CATEGORY_EVENTS)
	user.gimmick_team()

/client/proc/gimmick_team()
	if(!SSticker)
		tgui_alert(src, "Игра ещё не началась!")
		return

	if(tgui_alert(src, "Вы хотите заспавнить Гиммик тим в ВАШЕЙ ТЕКУЩЕЙ ЛОКАЦИИ?", "Подтверждение", list("Да","Нет")) != "Да")
		return

	var/turf/turf = get_turf(mob)

	var/force_species = FALSE
	var/selected_species = null
	if(tgui_alert(src, "Вы хотите выбрать какую-то расу для отряда? Нет — будут обычные люди.", "Подтверждение", list("Да","Нет")) == "Да")
		force_species = TRUE
		selected_species = tgui_input_list(src, "Выберете расу", "Выбор расы", GLOB.all_species)
		if(!selected_species)
			tgui_alert(src, "Спавн остановлен.")
			return	// You didn't pick, abort

	var/list/teamsizeoptions = list(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
	var/teamsize = tgui_input_list(src, "Укажите количество игроков.", "Количество игроков", teamsizeoptions)
	if(!(teamsize in teamsizeoptions))
		tgui_alert(src, "Недопустимый размер отряда. Отмена.")
		return

	var/team_name = null
	while(!team_name)
		team_name = tgui_input_text(src, "Укажите название команды. По умолчанию \"Гиммик тим\".", "Укажите название", "",encode = FALSE)
		if(!team_name)
			team_name = "Гиммик тим"

	var/themission = null
	while(!themission)
		themission = tgui_input_text(src, "Укажите миссию отряда.", "Укажите миссию", "", encode = FALSE)
		if(!themission)
			tgui_alert(src, "Миссия не указана. Отмена.")
			return

	var/minhours = tgui_input_number(src, "Укажите минимальное количество часов для [team_name]?", "Минимальное число часов", 60)

	var/dresscode = robust_dress_shop()
	if(!dresscode)
		return

	var/is_syndicate = tgui_alert(src, "Вы хотите, чтобы члены отряда автоматически классифицировались как антагонисты?", "Подтверждение", list("Да","Нет")) == "Да"

	var/list/players_to_spawn = list()
	players_to_spawn = pick_candidates_all_types(src, teamsize, "Вы хотите сыграть за \a [team_name]?", min_hours=minhours, role_cleanname=team_name, reason=themission)

	if(!length(players_to_spawn))
		to_chat(src, "Никто не согласился.")
		return 0

	var/players_spawned = 0
	for(var/mob/thisplayer in players_to_spawn)
		var/mob/living/carbon/human/human = new /mob/living/carbon/human(turf)
		human.name = random_name(pick(MALE,FEMALE))
		var/datum/preferences/preferences = new() //Randomize appearance
		preferences.real_name = human.name
		preferences.copy_to(human)
		human.dna.ready_dna(human)

		if(force_species)
			var/datum/species/selected_species_datum = GLOB.all_species[selected_species]
			human.set_species(selected_species_datum.type)
			human.regenerate_icons()

		human.mind_initialize()
		human.mind.assigned_role = SPECIAL_ROLE_EVENTMISC
		human.mind.special_role = SPECIAL_ROLE_EVENTMISC
		SSticker.mode.eventmiscs += human.mind
		SSticker.mode.update_eventmisc_icons_added(human.mind)
		human.mind.offstation_role = TRUE
		human.possess_by_player(thisplayer.key)
		human.change_voice()
		if(dresscode != "Naked")
			human.equipOutfit(dresscode, FALSE)

		to_chat(human, "<br>[span_danger("<b>[themission]</b>")]")
		human.mind.store_memory("<b>[themission]</b><br><br>")

		if(is_syndicate)
			SSticker.mode.traitors |= human.mind //Adds them to extra antag list

		players_spawned++
		if(players_spawned >= teamsize)
			break

	log_and_message_admins("used Spawn Gimmick Team.")
	BLACKBOX_LOG_ADMIN_VERB("Spawn Gimmick Team")

// ---------------------------------------------------------------------------------------------------------
