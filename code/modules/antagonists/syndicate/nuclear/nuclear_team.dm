#define CHALLENGE_TELECRYSTALS 1400
#define CHALLENGE_SCALE_PLAYER 1 // How many player per scaling bonus
#define CHALLENGE_SCALE_BONUS 10 // How many TC per scaling bonus
#define CHALLENGE_MIN_PLAYERS 50

/datum/team/nuclear_team
	name = "Ядерные оперативники"
	antag_datum_type = /datum/antagonist/nuclear_operative
	need_antag_hud = FALSE
	var/datum/objective/nuclear/team_objective
	var/total_tc = 0
	var/list/nuclear_uplink_list
	var/nuke_code
	var/datum/mind/leader
	var/leader_prefix
	var/syndicate_name


/datum/team/nuclear_team/New(list/starting_members)
	. = ..()
	leader_prefix = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	team_objective = new
	team_objective.owner = src
	team_objective.team = src
	objectives += team_objective
	syndicate_name = create_syndicate_name()
	var/obj/effect/landmark/nuke_spawn = locate(/obj/effect/landmark/nuclear_bomb)
	nuke_code = GLOB.nuke_codes[/obj/machinery/nuclearbomb/syndicate]
	if(!nuke_spawn)
		return
	new /obj/machinery/nuclearbomb/syndicate(nuke_spawn.loc)


/datum/team/nuclear_team/proc/scale_telecrystals()
	var/danger = GLOB.player_list.len
	var/temp_danger = (danger + 9)
	danger = temp_danger - temp_danger % 10
	total_tc += danger * NUKESCALINGMODIFIER

/datum/team/nuclear_team/proc/scale_challange()
	total_tc = CHALLENGE_TELECRYSTALS + round((((GLOB.player_list.len - CHALLENGE_MIN_PLAYERS) / CHALLENGE_SCALE_PLAYER) * CHALLENGE_SCALE_BONUS))

/datum/team/nuclear_team/add_member(datum/mind/new_member, add_objectives)
	if(!leader)
		leader = new_member
		new_member.remove_antag_datum(antag_datum_type)
		new_member.add_antag_datum(/datum/antagonist/nuclear_operative/leader, src)
	. = ..()

/datum/team/nuclear_team/remove_member(datum/mind/member)
	. = ..()
	if(leader != member)
		return .
	leader = null

/datum/team/nuclear_team/proc/create_syndicate_name()

	var/name = ""

	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	if(!prob(80))
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")
		return name

	name += " "

	// Full
	if(prob(60))
		name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		return name

	name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
	name += pick("", "-")
	name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	return name

/datum/team/nuclear_team/proc/get_uplinks()
	var/results = list()
	for(var/datum/mind/mind as anything in members)
		var/datum/antagonist/nuclear_operative/datum = mind.has_antag_datum(/datum/antagonist/nuclear_operative)
		if(!datum.uplink)
			continue
		results |= datum.uplink
	return results

/datum/team/nuclear_team/proc/share_telecrystals()
	var/player_tc
	var/remainder

	var/list/uplinks = get_uplinks()

	player_tc = round(total_tc / uplinks.len)
	remainder = total_tc % uplinks.len

	for(var/obj/item/uplink/uplink as anything in uplinks)
		uplink.uses += player_tc

	while(remainder > 0)
		for(var/obj/item/uplink/uplink as anything in uplinks)
			if(remainder <= 0)
				break
			uplink.uses++
			remainder--
	total_tc = 0

/proc/disk_on_centcom()
	for(var/obj/item/disk/nuclear/disk in GLOB.poi_list)
		if(disk.onCentcom())
			continue
		return FALSE
	return TRUE

/datum/team/nuclear_team/proc/is_operatives_are_dead()
	for(var/datum/mind/operative_mind in members)
		if(ishuman(operative_mind.current))
			continue
		if(!operative_mind.current)
			continue
		if(operative_mind.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/team/nuclear_team/declare_completion()
	var/disk_rescued = disk_on_centcom()
	var/crew_evacuated = EMERGENCY_ESCAPED_OR_ENDGAMED
	var/station_was_nuked = SSticker.mode.station_was_nuked
	var/syndies_didnt_escape = SSticker.mode.syndies_didnt_escape
	var/nuke_off_station = SSticker.mode.nuke_off_station
	var/list/text = list()

	if(!LAZYLEN(members))
		return text

	if(!disk_rescued && station_was_nuked && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear win - syndicate nuke"
		text += span_fontsize3("<br><br><b>Полная победа Синдиката!</b>")
		text += "<br><b>Отряд оперативников [syndicate_name] уничтожил [station_name()]!</b>"

	else if(!disk_rescued && station_was_nuked && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - syndicate nuke - did not evacuate in time"
		text += span_fontsize3("<br><br><b>Полное уничтожение</b>")
		text += "<br><b>Отряд оперативников [syndicate_name] уничтожил [station_name()], но не успел покинуть сектор станции и попал под взрыв.</b> В следующий раз не теряйте диск!"

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && !syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station"
		text += span_fontsize3("<br><br><b>Частичная победа экипажа</b>")
		text += "<br><b>Отряд оперативников [syndicate_name] захватил диск ядерной аутентификации, но взорвал что-то, что не было [station_name()].</b> В следующий раз не теряйте диск!"

	else if(!disk_rescued && !station_was_nuked && nuke_off_station && syndies_didnt_escape)
		SSticker.mode_result = "nuclear halfwin - blew wrong station - did not evacuate in time"
		text += span_fontsize3("<br><br><b>Отряд оперативников [syndicate_name] получил Премию Дарвина!</b>")
		text += "<br><b>Отряд оперативников [syndicate_name] взорвал что-то, что не было [station_name()] и попал под взрыв.</b> В следующий раз не теряйте диск!"

	else if(disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk secured - syndi team dead"
		text += span_fontsize3("<br><br><b>Полная победа экипажа!</b>")
		text += "<br><b>Персонал станции сохранил диск и уничтожил отряд оперативников [syndicate_name]</b>"

	else if(disk_rescued)
		SSticker.mode_result = "nuclear loss - evacuation - disk secured"
		text += span_fontsize3("<br><br><b>Полная победа экипажа</b>")
		text += "<br><b>Персонал станции сохранил диск и остановил отряд оперативников [syndicate_name]!</b>"

	else if(!disk_rescued && is_operatives_are_dead())
		SSticker.mode_result = "nuclear loss - evacuation - disk not secured"
		text += span_fontsize3("<br><br><b>Частичная победа Синдиката!</b>")
		text += "<br><b>Персонал станции не смог сохранить диск ядерной аутентификации, но уничтожил весь отряд оперативников [syndicate_name]!</b>"

	else if(!disk_rescued && crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - detonation averted"
		text += span_fontsize3("<br><br><b>Частичная победа Синдиката!</b>")
		text += "<br><b>Отряд оперативников [syndicate_name] заполучил диск ядерной аутентификации, но взрыва [station_name()] не произошло.</b> В следующий раз не теряйте диск!"

	else if(!disk_rescued && !crew_evacuated)
		SSticker.mode_result = "nuclear halfwin - interrupted"
		text += span_fontsize3("<br><br><b>Ничья</b>")
		text += "<br><b>Раунд был прерван по неизвестной причине!</b>"

	text += span_fontsize3("<br><b>Ядерными Оперативниками Синдиката были:</b>")

	var/TC_uses = 0

	for(var/datum/mind/syndicate in members)

		text += "<br><b>[syndicate.get_display_key()]</b> был <b>[syndicate.name]</b> ("
		if(syndicate.current)
			if(syndicate.current.stat == DEAD)
				text += "мёртв"
			else
				text += "жив"
			if(syndicate.current.real_name != syndicate.name)
				text += " как <b>[syndicate.current.real_name]</b>"
		else
			text += "тело уничтожено"
		text += ")"
		var/datum/antagonist/nuclear_operative/datum = syndicate.has_antag_datum(/datum/antagonist/nuclear_operative)
		if(datum?.uplink)
			text += "(Оперативник использовал [datum.uplink.used_TC] ТК) [datum.uplink.purchase_log]"
			TC_uses += datum.uplink.used_TC

	text += "<br>"

	if(TC_uses == 0 && station_was_nuked && !is_operatives_are_dead())
		text += span_fontsize4(bicon(icon('icons/misc/badass.dmi', "badass")))

	return text.Join("")

/proc/create_syndicate(datum/mind/synd_mind) // So we don't have inferior species as ops - randomize a human
	var/mob/living/carbon/human/human = synd_mind.current

	human.set_species(/datum/species/human, TRUE)
	human.dna.ready_dna(human) // Quadriplegic Nuke Ops won't be participating in the paralympics
	human.dna.species.create_organs(human)
	human.cleanSE() //No fat/blind/colourblind/epileptic/whatever ops.
	human.overeatduration = 0
	human.flavor_text = null

	var/obj/item/organ/external/head/head_organ = human.get_organ(BODY_ZONE_HEAD)
	var/hair_c = pick("#8B4513", "#000000", "#FF4500", "#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000", "#8B4513", "1E90FF") // Black, brown, blue
	var/skin_tone = pick(-50, -30, -10, 0, 0, 0, 10) // Caucasian/black
	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	human.change_eye_color(eye_c)
	human.s_tone = skin_tone
	head_organ.h_style = random_hair_style(human.gender, head_organ.dna.species)
	head_organ.f_style = random_facial_hair_style(human.gender, head_organ.dna.species.name)
	human.body_accessory = null
	human.regenerate_icons()
	human.update_body()


/datum/team/nuclear_team/get_admin_texts()
	. = ..()
	if(!check_rights(R_ADMIN))
		return .
	. += "<br/><br/><a href='byond://?_src_=holder;team_command=set_tk;team=[UID()]'>Установить общее количество ТК</a><br>"
	. += "<br/><a href='byond://?_src_=holder;team_command=set_tk_nuke;team=[UID()]'>Расчитать общее количество ТК как на старте</a><br>"
	. += "<br/><a href='byond://?_src_=holder;team_command=set_tk_war;team=[UID()]'>Расчитать общее количество ТК как при объявлении войны</a><br>"
	. += "<br/><a href='byond://?_src_=holder;team_command=scale_tk;team=[UID()]'>Разделить ТК между оперативниками</a><br>"


/datum/team/nuclear_team/admin_topic(comand)
	if(comand == "set_tk")
		total_tc = tgui_input_number(usr, "Выберите количество ТК", "Количество ТК", total_tc) || total_tc
		log_and_message_admins("set team TC")

	if(comand == "set_tk_nuke")
		scale_telecrystals()
		log_and_message_admins("scaled team TC as nuke mode")

	if(comand == "set_tk_war")
		scale_challange()
		log_and_message_admins("scaled team TC as war")

	if(comand == "scale_tk")
		share_telecrystals()
		log_and_message_admins("shared team TC")


/datum/team/nuclear_team/set_scoreboard_vars()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0

	for(var/datum/mind/mind in members)
		foecount++
		if(!mind || !mind.current)
			scoreboard.score_ops_killed++
			continue

		if(mind.current.stat == DEAD)
			scoreboard.score_ops_killed++

		else if(HAS_TRAIT(mind, TRAIT_RESTRAINED))
			scoreboard.score_arrested++

	if(foecount == scoreboard.score_arrested)
		scoreboard.all_arrested = TRUE // how the hell did they manage that

	var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.poi_list
	if(GLOB.nuke_codes[/obj/machinery/nuclearbomb/syndicate] != "Nope")
		var/area/A = get_area(nuke)

		var/list/thousand_penalty = list(/area/wizard_station, /area/solar)
		var/list/fiftythousand_penalty = list(/area/security/main, /area/security/brig, /area/security/armory, /area/security/checkpoint/south)

		if(is_type_in_list(A, thousand_penalty))
			scoreboard.nuked_penalty = 1000

		else if(is_type_in_list(A, fiftythousand_penalty))
			scoreboard.nuked_penalty = 50000

		else if(istype(A, /area/engineering))
			scoreboard.nuked_penalty = 100000

		else
			scoreboard.nuked_penalty = 10000

	var/killpoints = scoreboard.score_ops_killed * 250
	var/arrestpoints = scoreboard.score_arrested * 1000
	scoreboard.crewscore += killpoints
	scoreboard.crewscore += arrestpoints
	if(scoreboard.nuked)
		scoreboard.crewscore -= scoreboard.nuked_penalty


/datum/team/nuclear_team/get_scoreboard_stats()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/foecount = 0
	var/crewcount = 0

	var/diskdat = ""
	var/bombdat = null

	for(var/datum/mind/M in members)
		foecount++

	for(var/mob in GLOB.mob_living_list)
		var/mob/living/C = mob
		if(ishuman(C) || isAI(C) || isrobot(C))
			if(C.stat == DEAD)
				continue
			if(!C.client)
				continue
			crewcount++

	var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
	if(istype(N))
		var/atom/disk_loc = N.loc
		while(!isturf(disk_loc))
			if(ismob(disk_loc))
				var/mob/M = disk_loc
				diskdat += " у [M.real_name]"
			if(isobj(disk_loc))
				var/obj/O = disk_loc
				diskdat += " в [O.declent_ru(DATIVE)]"
			disk_loc = disk_loc.loc
		diskdat += " в [disk_loc.loc?.declent_ru(DATIVE)]"


	if(!diskdat)
		diskdat = "ПРЕДУПРЕЖДЕНИЕ: Nuked_penalty не может быть найдено, подробнее в [__FILE__], [__LINE__]."

	var/dat = ""
	dat += "<b><u>Статистика режима</b></u><br>"

	dat += "<b>Число оперативников:</b> [foecount]<br>"
	dat += "<b>Число выжившего экипажа:</b> [crewcount]<br>"

	dat += "<b>Местоположение ядерной боеголовки:</b> [bombdat]<br>"
	dat += "<b>Местоположение диска ядерной аутентификации:</b> [diskdat]<br>"

	dat += "<br>"
	var/score_arrested_points = scoreboard.score_arrested * 1000
	dat += "<b>Оператикников арестовано:</b> [scoreboard.score_arrested] ([score_arrested_points] [declension_ru(score_arrested_points, "очко", "очка", "очков")])<br>"
	dat += "<b>Все оперативники арестованы:</b> [scoreboard.all_arrested ? "Да" : "Нет"] (Очки утроены)<br>"
	var/score_killed_points = scoreboard.score_ops_killed * 1000
	dat += "<b>Оперативников убито:</b> [scoreboard.score_ops_killed] ([score_killed_points] [declension_ru(score_arrested_points, "очко", "очка", "очков")])<br>"
	dat += "<b>Станция уничтожена:</b> [scoreboard.nuked ? "Да" : "Нет"] (-[scoreboard.nuked_penalty] [declension_ru(scoreboard.nuked_penalty, "очко", "очка", "очков")])<br>"
	dat += "<hr>"

	return dat

#undef CHALLENGE_MIN_PLAYERS
#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_SCALE_PLAYER
#undef CHALLENGE_SCALE_BONUS
