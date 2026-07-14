//Returns MINDS of the assigned antags of given type/subtypes
/proc/get_antag_minds(antag_type, specific = FALSE)
	. = list()
	for(var/datum/antagonist/antagonist in GLOB.antagonists)
		if(!antagonist.owner)
			continue
		if(!antag_type || !specific && istype(antagonist, antag_type) || specific && antagonist.type == antag_type)
			. += antagonist.owner

//Get all teams [of type team_type]
/proc/get_all_teams(team_type)
	. = list()
	for(var/V in GLOB.antagonists)
		var/datum/antagonist/antagonist = V
		if(!antagonist.owner)
			continue
		var/datum/team/team = antagonist.get_team()
		if(!team_type || istype(team, team_type))
			. |= team
