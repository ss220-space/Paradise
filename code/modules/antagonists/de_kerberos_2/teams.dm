/datum/team/battle_team
	var/team_role
	var/team_color
	var/landmark
	var/static/list/evacuations = list()


/datum/team/battle_team/add_member(datum/mind/new_member, add_objectives)
	var/mob/living/character
	if(isnewplayer(new_member.current))
		var/mob/new_player/player = new_member.current
		character = player.create_character()
	else
		character = new_member.current
	SSjobs.AssignRole(character, team_role, TRUE)
	character = SSjobs.AssignRank(character, team_role, TRUE)
	SSjobs.EquipRank(character, team_role, TRUE)
	GLOB.data_core.manifest_inject(character)
	var/spawnpoint = pick(GLOB.battle_teams_spawns[landmark])
	character.forceMove(spawnpoint)
	greet_member(new_member)
	. = ..()

/datum/team/battle_team/proc/greet_member(datum/mind/member)
	var/list/messages = list()
	messages.Add(span_danger("<center>Вы член команды [name]!</center>"))
	messages.Add("<center>Ваша задача: заполучить доступ к консоли связи, вызвать шаттл и эвакуироваться, не дав эвакуироваться остальным командам.</center>")
	messages.Add("<center>В скором времени на станцию будет отправлены охраняемые капсулы с особо ценным снаряжением, которое может очень сильно вам помочь в вашей миссии.</center>")
	messages.Add("<center>Спустя еще некоторое время станция будет уничтожена ядерной ракетой. Поторопитесь, если не хотите стать горстью пепла.</center>")
	to_chat(member.current, chat_box_red(messages.Join("<br>")))

/datum/team/battle_team/declare_completion()
	var/list/text = list()
	var/enemy_team_evacuated = FALSE
	for(var/team in evacuations)
		if(team == team_role)
			continue
		if(!LAZYLEN(evacuations[team]))
			continue
		enemy_team_evacuated = TRUE
		break

	if(!LAZYLEN(evacuations[team_role]))
		text += span_fontsize3("<br><b>Поражение команды <span style='color:[team_color];'>[name]</span></b>")
		text += "<br><b>Команда <span style='color:[team_color];'>[name]</span> не смогла эвакуироваться</b>"
		return text
	if(enemy_team_evacuated)
		text += span_fontsize3("<br><b>Частичная победа команды <span style='color:[team_color];'>[name]</span></b>")
		text += "<br><b>Команда <span style='color:[team_color];'>[name]</span> смогла эвакуироваться, но не смогла помешать эвакуироваться другой команде.</b>"
	else
		text += span_fontsize3("<br><b>Полная победа команды <span style='color:[team_color];'>[name]</span></b>")
		text += "<br><b>Команда <span style='color:[team_color];'>[name]</span> смогла эвакуироваться, помешав это сделать другим командам.</b>"

	text += span_fontsize4("<b>Успешно эакуировались:</b>")
	for(var/mob/living/evacuated as anything in evacuations[team_role])
		text += "<br>[evacuated.name]([evacuated.key])"

	return text


/datum/team/battle_team/pre_declare_completion()
	if(!evacuations[team_role])
		evacuations[team_role] = list()
	for(var/datum/mind/mind as anything in members)
		var/mob/living/living_member = mind.current
		if(!istype(living_member))
			continue

		if(living_member.stat == DEAD)
			continue

		if(!living_member.onCentcom() && !living_member.onSyndieBase())
			continue

		evacuations[team_role] += living_member

/datum/team/battle_team/green
	name = "Зеленые"
	team_color = "#09ff00"
	team_role = JOB_TITLE_TEAM1
	landmark = /obj/effect/landmark/team1

/datum/team/battle_team/blue
	name = "Синие"
	team_color = "#1100ff"
	team_role = JOB_TITLE_TEAM2
	landmark = /obj/effect/landmark/team2

/datum/team/battle_team/red
	name = "Красные"
	team_color = "#ff0000"
	team_role = JOB_TITLE_TEAM3
	landmark = /obj/effect/landmark/team3
