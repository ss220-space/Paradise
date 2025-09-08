#define AIRDROP_TIME 10 MINUTES
#define GAMMA_TIME 1 MINUTES
#define ROCKET_TIME 30 MINUTES
#define AIRDROP_COUNT 5
#define AIRDROP_GUARD_COUND 7

/datum/game_mode/de_kerberos_2
	name = "de_kerberos_2"
	config_tag = "de_kerberos_2"
	required_players = 3
	var/list/players
	var/list/teams = list()

/datum/game_mode/de_kerberos_2/pre_setup()
	var/list/temp_players = list()
	for(var/mob/new_player/player in GLOB.player_list)
		if(!player.client || !player.ready || !player.has_valid_preferences())
			continue
		temp_players |= player.mind

	shuffle(temp_players)
	var/team_size = floor(LAZYLEN(temp_players) / 3)
	var/start = 1
	var/team_list = list(JOB_TITLE_TEAM1, JOB_TITLE_TEAM2, JOB_TITLE_TEAM3)

	if(team_size != 0)
		for(var/team in team_list)
			for(var/i in start to start + team_size)
				var/datum/mind/mind = temp_players[i]
				mind.assigned_role = team
				mind.special_role = team
			start += team_size

	for(var/i in start to LAZYLEN(temp_players))
		var/datum/mind/mind = temp_players[i]
		var/team = pick(team_list)
		mind.assigned_role = team
		mind.special_role = team
	players = temp_players
	return TRUE


/datum/game_mode/de_kerberos_2/post_setup()
	for(var/datum/team/battle_team/team as anything in list(/datum/team/battle_team/green, /datum/team/battle_team/blue, /datum/team/battle_team/red))\
		teams[team.team_role] = new team
	
	for(var/datum/mind/mind as anything in players)
		var/datum/team/team = teams[mind.special_role]
		team.add_member(mind)

	GLOB.full_lockdown = TRUE
	SSevents.can_fire = FALSE
	GLOB.off_mob_spawns = TRUE
	GLOB.captain_auth_access = ACCESS_CAPTAIN_REAL
	spawn_corpses()
	addtimer(CALLBACK(src, PROC_REF(set_gamma_code)), GAMMA_TIME)
	addtimer(CALLBACK(src, PROC_REF(spawn_airdrop)), AIRDROP_TIME)
	addtimer(CALLBACK(src, PROC_REF(start_missle)), ROCKET_TIME)
	return ..()

/datum/game_mode/de_kerberos_2/proc/set_gamma_code()
	SSsecurity_level.set_level(SECURITY_CODE_GAMMA)

/datum/game_mode/de_kerberos_2/proc/spawn_airdrop()
	send_to_playing_players(span_boldwarning("Капсулы со снаряжением кода ЭПСИЛОН в пути"))
	for(var/i in 1 to AIRDROP_COUNT + 1)
		var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/bluespacepod/airdrop()
		new /obj/structure/closet/loot_crate/epsilon(pod)
		new /obj/effect/pod_landingzone(pick(GLOB.airdrops_points), pod)
	
	for(var/i in 1 to AIRDROP_GUARD_COUND + 1)
		var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/bluespacepod/airdrop_guard()
		new /mob/living/simple_animal/hostile/syndicate/ranged/space/autogib/spacebattle(pod)
		new /obj/effect/pod_landingzone(pick(GLOB.airdrops_points), pod)

	var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/bluespacepod/airdrop_guard()
	new /mob/living/simple_animal/hostile/syndicate/melee/autogib/depot/armory(pod)
	new /obj/effect/pod_landingzone(pick(GLOB.airdrops_points), pod)

/datum/game_mode/de_kerberos_2/proc/start_missle()
	send_to_playing_players(span_boldwarning("Крылатая ракета с ядерной боевой частью запущена на станцию [station_name()]"))
	SSsecurity_level.set_level(SECURITY_CODE_DELTA)
	new /obj/effect/pod_landingzone(pick(GLOB.airdrops_points), new /obj/structure/closet/supplypod/deadmatch_missile/endgame())

/datum/game_mode/de_kerberos_2/proc/spawn_corpses()
	new /obj/effect/mob_spawn/human/corpse/warden(pick(GLOB.armory_body_spawns))
	new /obj/effect/mob_spawn/human/corpse/captain(pick(GLOB.captain_body_spawns))

/datum/game_mode/de_kerberos_2/late_join(mob/new_player/player)
	var/min_count = INFINITY
	var/datum/team/team = null
	for(var/possible_team_name as anything in teams)
		var/datum/team/possible_team = teams[possible_team_name]
		var/team_len = LAZYLEN(possible_team.members)
		if(team_len >= min_count)
			continue
		min_count = team_len
		team = possible_team
	if(!team)
		return FALSE
	SStitle.hide_title_screen_from(player.client)
	team.add_member(player.mind)
	qdel(player)
	return TRUE

#undef AIRDROP_TIME
#undef GAMMA_TIME
#undef ROCKET_TIME
#undef AIRDROP_COUNT
#undef AIRDROP_GUARD_COUND
