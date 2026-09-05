/datum/aoe_targeting/all_players/get_targets(atom/center, aoe_radius)
	var/all_players = list()
	for(var/mob/player_mob in GLOB.player_list)
		if(isnewplayer(player_mob) || !player_mob.client)
			continue
		all_players += player_mob
	return all_players
