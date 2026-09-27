/datum/team/revolution
	name = "Революция"
	antag_datum_type = /datum/antagonist/rev
	var/check_counter = 0
	var/obj/machinery/computer/communications/data_stream_console
	var/war_declared = FALSE
	var/syndicate_progress = 0
	var/nt_progress = 0
	var/last_progress_tick = 0
	var/victor

/proc/get_revolution_team()
	RETURN_TYPE(/datum/team/revolution)
	return GLOB.antagonist_teams[/datum/team/revolution]

/datum/team/revolution/New(list/starting_members)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/team/revolution/Destroy(force = FALSE)
	STOP_PROCESSING(SSprocessing, src)
	data_stream_console = null
	return ..()

/datum/team/revolution/process()
	check_latejoin()
	advance_war()

/datum/team/revolution/proc/get_head_revolutionaries()
	var/list/leaders = list()
	for(var/datum/mind/member as anything in members)
		if(member.has_antag_datum(/datum/antagonist/rev/head))
			leaders += member
	return leaders

/datum/team/revolution/proc/check_latejoin()
	check_counter++
	if(check_counter < 5)
		return
	check_counter = 0

	var/list/leaders = get_head_revolutionaries()
	if(length(leaders) >= MAX_HEAD_REVOLUTIONARIES)
		return
	if(length(leaders) >= round(length(SSticker.mode.get_all_heads()) - ((8 - length(SSticker.mode.get_all_sec())) / 3)))
		return

	var/list/promotable_revs = list()
	for(var/datum/mind/khrushchev as anything in members)
		if(!khrushchev.has_antag_datum(/datum/antagonist/rev/volunteer))
			continue
		if(!khrushchev.current?.client || khrushchev.current.stat == DEAD)
			continue
		if(ROLE_REV in khrushchev.current.client.prefs.be_special)
			promotable_revs += khrushchev

	if(!length(promotable_revs))
		return

	var/datum/mind/stalin = pick(promotable_revs)
	add_game_logs("has been promoted to a head rev", stalin.current)
	var/datum/antagonist/rev/volunteer/volunteer = stalin.has_antag_datum(/datum/antagonist/rev/volunteer)
	volunteer.switch_tier(/datum/antagonist/rev/head)

/datum/team/revolution/proc/living_head_revolutionaries(datum/mind/excluded)
	. = 0
	for(var/datum/mind/leader as anything in get_head_revolutionaries())
		if(leader == excluded || !leader.current || leader.current.stat == DEAD)
			continue
		.++

/datum/team/revolution/proc/declare_war()
	if(war_declared)
		return
	war_declared = TRUE
	last_progress_tick = world.time
	SSsecurity_level.set_level(SECURITY_CODE_GAMMA)
	for(var/datum/mind/rebel as anything in get_antag_minds(/datum/antagonist/rev))
		to_chat(rebel.current, span_userdanger("Поток данных пошёл. Прятаться больше незачем — экипаж знает, кто вы. Удержите консоль!"))
	GLOB.major_announcement.announce(
		message = "С одной из консолей связи [station_name()] идёт несанкционированная передача данных флоту Синдиката. \
			Обнаружившим её приказано немедленно прервать передачу. Все причастные лишаются статуса сотрудника и подлежат немедленной ликвидации. \
			Капсулы со снаряжением сброшены на станцию.",
		new_title = ANNOUNCE_CCMSG_RU,
		new_sound = SSstation.announcer.get_rand_report_sound()
	)
	launch_nanotrasen_pods()

GLOBAL_LIST_INIT(revolution_standard_pod_kits, list(
	list(/obj/item/gun/projectile/automatic/smg/wt550 = 1, /obj/item/ammo_box/magazine/wt550m9 = 3),
	list(/obj/item/gun/projectile/shotgun/riot = 1, /obj/item/ammo_box/shotgun = 2),
	list(/obj/item/gun/projectile/shotgun/winchester = 1, /obj/item/ammo_box/shotgun = 2),
	list(/obj/item/storage/backpack/duffel/security/bulletproof_armory = 1, /obj/item/storage/belt/security/sec = 1),
	list(/obj/item/storage/backpack/duffel/security/riot_armory = 1, /obj/item/storage/belt/security/sec = 1),
	list(/obj/item/mod/control/pre_equipped/security = 1),
))

GLOBAL_LIST_INIT(revolution_reinforced_pod_kits, list(
	list(/obj/item/gun/projectile/shotgun/automatic/combat = 1, /obj/item/ammo_box/speedloader/shotgun/slug = 2),
	list(/obj/item/gun/projectile/automatic/smg/sfg = 1, /obj/item/ammo_box/magazine/sfg9mm = 2),
	list(/obj/item/gun/projectile/automatic/smg/saber = 1, /obj/item/ammo_box/magazine/smgm9mm = 2),
	list(/obj/item/gun/projectile/automatic/ik60 = 1, /obj/item/ammo_box/magazine/ik60mag = 2),
	list(/obj/item/mod/control/pre_equipped/safeguard_mk_two = 1, /obj/item/gun/projectile/automatic/pistol/sp8 = 1, /obj/item/ammo_box/magazine/sp8 = 2),
))

GLOBAL_LIST_INIT(revolution_pod_blacklist, typecacheof(list(
	/area/station/command,
	/area/station/maintenance,
	/area/station/security/brig,
)))

GLOBAL_LIST_INIT(revolution_reinforced_pod_areas, typecacheof(list(
	/area/station/command/office,
	/area/station/command/bridge,
	/area/station/security/brig,
)))

/datum/team/revolution/proc/launch_nanotrasen_pods()
	var/crew = length(GLOB.data_core.general)
	var/list/standard_areas = collect_pod_areas(reinforced = FALSE)
	var/list/reinforced_areas = collect_pod_areas(reinforced = TRUE)
	for(var/count in 1 to round(crew / CREW_PER_SUPPLY_POD))
		drop_supply_pod(pick_pod_turf(standard_areas), standard_pod_payload())
	for(var/count in 1 to round(crew / CREW_PER_REINFORCED_POD))
		drop_supply_pod(pick_pod_turf(reinforced_areas), pick(GLOB.revolution_reinforced_pod_kits) + list(/obj/item/storage/lockbox/mindshield = 1))

/datum/team/revolution/proc/standard_pod_payload()
	var/list/payload = pick(GLOB.revolution_standard_pod_kits) + list(/obj/item/implanter/mindshield = 2)
	if(payload[/obj/item/mod/control/pre_equipped/security])
		var/datum/security_voucher_kit/officer/kit = pick(subtypesof(/datum/security_voucher_kit/officer))
		payload[kit.kit_box] = 1
	return payload

/datum/team/revolution/proc/collect_pod_areas(reinforced)
	. = list()
	for(var/area/station/area as anything in GLOB.areas)
		if(!istype(area))
			continue
		if(reinforced ? !is_type_in_typecache(area, GLOB.revolution_reinforced_pod_areas) : is_type_in_typecache(area, GLOB.revolution_pod_blacklist))
			continue
		. += area

/datum/team/revolution/proc/pick_pod_turf(list/candidates)
	while(length(candidates))
		var/area/chosen = pick_n_take(candidates)
		var/list/turfs = chosen.get_turfs_from_all_zlevels()
		shuffle_inplace(turfs)
		for(var/turf/simulated/floor/candidate_turf in turfs)
			if(is_station_level(candidate_turf.z) && !candidate_turf.density)
				return candidate_turf

/datum/team/revolution/proc/drop_supply_pod(turf/landing_spot, list/payload)
	if(!landing_spot)
		return
	podspawn(list(
		"target" = landing_spot,
		"path" = /obj/structure/closet/supplypod/podspawn,
		"spawn" = payload,
	))

/datum/team/revolution/proc/advance_war()
	if(!war_declared || victor)
		return
	var/elapsed = world.time - last_progress_tick
	last_progress_tick = world.time
	if(data_stream_console?.streaming_data)
		syndicate_progress += elapsed
	else
		nt_progress += elapsed

	if(syndicate_progress >= REVOLUTION_WAR_DURATION)
		declare_victor(REVOLUTION_VICTOR_SYNDICATE)
	else if(nt_progress >= REVOLUTION_WAR_DURATION)
		declare_victor(REVOLUTION_VICTOR_NT)

/datum/team/revolution/proc/declare_victor(new_victor)
	if(victor)
		return
	victor = new_victor
	data_stream_console?.stop_data_stream()

	if(victor == REVOLUTION_VICTOR_SYNDICATE)
		GLOB.major_announcement.announce(
			message = "Флот Синдиката вышел из блюспейса раньше сил \"Нанотрейзен\" и берёт [station_name()] под свой контроль. \
				Связь с Трурлем оборвана. Абордажные группы уже на борту.",
			new_title = ANNOUNCE_DECLAREWAR_RU,
			new_sound = 'sound/effects/siren.ogg'
		)
		spawn_on_beacons(/mob/living/simple_animal/hostile/syndicate/ranged/space)
		addtimer(CALLBACK(src, PROC_REF(finish_round)), REVOLUTION_SYNDICATE_ENDING_DELAY)
		return

	GLOB.major_announcement.announce(
		message = "Флот \"Нанотрейзен\" успел занять сектор и закрыл [station_name()] от кораблей Синдиката. \
			Плацдарм потерян, революция обезглавлена. Эвакуационный шаттл вызван.",
		new_title = ANNOUNCE_CCMSG_RU,
		new_sound = SSstation.announcer.get_rand_report_sound()
	)
	spawn_on_beacons(/mob/living/simple_animal/bot/ed209)
	for(var/datum/mind/rebel as anything in get_antag_minds(/datum/antagonist/rev))
		if(rebel.has_antag_datum(/datum/antagonist/rev/slave))
			continue
		var/datum/antagonist/rev/revolutionary = rebel.has_antag_datum(/datum/antagonist/rev)
		revolutionary.add_objective(/datum/objective/survive)
		to_chat(rebel.current, span_userdanger("Синдикат не придёт. Выживите любой ценой."))
	SSshuttle.emergency.canRecall = FALSE
	SSshuttle.emergency.request(null, REVOLUTION_EVAC_TIME / max(SSshuttle.emergencyCallTime, 1))

/datum/team/revolution/proc/spawn_on_beacons(mob_type)
	var/spawned = 0
	for(var/obj/item/beacon/beacon as anything in GLOB.beacons)
		var/turf/landing_spot = get_turf(beacon)
		if(!landing_spot || !is_station_level(landing_spot.z))
			continue
		for(var/count in 1 to REVOLUTION_ENDING_SPAWNS_PER_BEACON)
			new mob_type(landing_spot)
			spawned++
			if(spawned >= REVOLUTION_ENDING_MAX_SPAWNS)
				return

/datum/team/revolution/proc/finish_round()
	SSticker.force_ending = TRUE

/datum/team/revolution/declare_completion()
	if(!length(members))
		return

	var/list/leaders = get_head_revolutionaries()
	var/num_revs = 0
	var/num_survivors = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(!survivor.ckey)
			continue
		num_survivors++
		if(survivor.mind in members)
			num_revs++

	var/list/text = list()
	if(victor)
		if(victor == REVOLUTION_VICTOR_SYNDICATE)
			text += span_bold(span_fontsize3("<br>Революция победила: флот Синдиката занял станцию."))
		else
			text += span_bold(span_fontsize3("<br>Революция подавлена: флот \"Нанотрейзен\" успел первым."))
	else if(war_declared)
		text += span_bold(span_fontsize3("<br>Война за консоль связи не была доиграна до конца."))

	if(war_declared)
		text += "<br>[TAB]Поток данных Синдиката: [span_bold("[round(syndicate_progress / (1 MINUTES), 0.1)] мин")] из [round(REVOLUTION_WAR_DURATION / (1 MINUTES))]"
		text += "<br>[TAB]Контроль \"Нанотрейзен\": [span_bold("[round(nt_progress / (1 MINUTES), 0.1)] мин")] из [round(REVOLUTION_WAR_DURATION / (1 MINUTES))]"

	if(num_survivors)
		text += "<br>[TAB]Command's Approval Rating: [span_bold("[100 - round((num_revs / num_survivors) * 100, 0.1)]%")]"

	text += span_bold(span_fontsize3("<br>The head revolutionaries were:</font>"))
	for(var/datum/mind/headrev as anything in leaders)
		text += printplayer(headrev, 1)

	var/volunteers = 0
	var/slaves = 0
	for(var/datum/mind/member as anything in members)
		if(member.has_antag_datum(/datum/antagonist/rev/volunteer))
			volunteers++
		else if(member.has_antag_datum(/datum/antagonist/rev/slave))
			slaves++
	text += "<br>Добровольцев революции: [span_bold("[volunteers]")], рабов революции: [span_bold("[slaves]")]"

	text += span_bold(span_fontsize3("<br>The heads of staff were:"))
	for(var/datum/mind/head as anything in SSticker.mode.get_all_heads())
		text += printplayer(head, 1)
	text += "<br>"
	return text.Join("")

/datum/team/revolution/set_scoreboard_vars()
	var/datum/scoreboard/scoreboard = SSticker.score
	if(victor == REVOLUTION_VICTOR_SYNDICATE)
		scoreboard.score_greentext = TRUE
	var/list/leaders = get_head_revolutionaries()

	for(var/datum/mind/leader as anything in leaders)
		if(!leader.current || leader.current.stat == DEAD)
			scoreboard.score_ops_killed++
		else if(HAS_TRAIT(leader, TRAIT_RESTRAINED))
			scoreboard.score_arrested++

	if(length(leaders) == scoreboard.score_arrested)
		scoreboard.all_arrested = TRUE

	for(var/datum/mind/head as anything in SSticker.mode.get_all_heads())
		if(head.current?.stat == DEAD)
			scoreboard.score_dead_command++

	if(scoreboard.score_greentext)
		scoreboard.crewscore -= 10000

	scoreboard.crewscore += scoreboard.score_arrested * 1000
	scoreboard.crewscore += scoreboard.score_ops_killed * 500
	scoreboard.crewscore -= scoreboard.score_dead_command * 500

/datum/team/revolution/get_scoreboard_stats()
	var/datum/scoreboard/scoreboard = SSticker.score
	var/list/leaders = get_head_revolutionaries()
	var/foecount = 0
	var/comcount = 0
	var/revcount = 0
	var/loycount = 0

	for(var/datum/mind/leader as anything in leaders)
		if(leader.current && leader.current.stat != DEAD)
			foecount++

	for(var/datum/mind/rebel as anything in (members - leaders))
		if(rebel.current && rebel.current.stat != DEAD)
			revcount++

	var/list/heads = SSticker.mode.get_all_heads()
	for(var/datum/mind/head as anything in heads)
		if(head.current && head.current.stat != DEAD)
			comcount++

	for(var/mob/living/carbon/human/player as anything in GLOB.human_list)
		if(!player.mind || (player.mind in heads) || (player.mind in members))
			continue
		loycount++

	for(var/mob/living/silicon/robot as anything in GLOB.silicon_mob_list)
		if(robot.stat != DEAD)
			loycount++

	var/list/dat = list("<b><u>Mode Statistics</u></b><br>")
	dat += "<b>Number of Surviving Revolution Heads:</b> [foecount]<br>"
	dat += "<b>Number of Surviving Command Staff:</b> [comcount]<br>"
	dat += "<b>Number of Surviving Revolutionaries:</b> [revcount]<br>"
	dat += "<b>Number of Surviving Loyal Crew:</b> [loycount]<br>"
	dat += "<br>"
	dat += "<b>Revolution Heads Arrested:</b> [scoreboard.score_arrested] ([scoreboard.score_arrested * 1000] Points)<br>"
	dat += "<b>All Revolution Heads Arrested:</b> [scoreboard.all_arrested ? "Yes" : "No"] (Score tripled)<br>"
	dat += "<b>Revolution Heads Slain:</b> [scoreboard.score_ops_killed] ([scoreboard.score_ops_killed * 500] Points)<br>"
	dat += "<b>Command Staff Slain:</b> [scoreboard.score_dead_command] (-[scoreboard.score_dead_command * 500] Points)<br>"
	dat += "<b>Revolution Successful:</b> [scoreboard.score_greentext ? "Yes" : "No"] (-[scoreboard.score_greentext * 10000] Points)<br>"
	dat += "<hr>"
	return dat.Join("")
