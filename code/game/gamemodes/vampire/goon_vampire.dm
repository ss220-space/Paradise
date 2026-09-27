/**
 * This is the gamemode file for the ported goon gamemode vampires.
 * They get a traitor objective and a blood sucking objective.
 */
/datum/game_mode/goon_vampire
	name = "goonvampire"
	config_tag = "goonvampire"
	protected_jobs = list(JOB_TITLE_CHAPLAIN)
	protected_species = SPECIES_BLOCKED_FOR_VAMPIRE
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4

/datum/game_mode/goon_vampire/announce()
	to_chat(world, "<b>The current game mode is - Vampires!</b>")
	to_chat(world, "<b>There are Bluespace Vampires infesting your fellow crewmates, keep your blood close and neck safe!</b>")

/datum/game_mode/goon_vampire/pre_setup()

	var/list/datum/mind/possible_vampires = get_players_for_role(ROLE_VAMPIRE)

	var/vampire_scale = 10
	if(CONFIG_GET(number/traitor_scaling))
		vampire_scale = CONFIG_GET(number/traitor_scaling)
	var/vampire_amount = 1 + round(num_players() / vampire_scale)
	add_game_logs("Number of vampires chosen: [vampire_amount]")

	if(length(possible_vampires))
		for(var/i in 1 to vampire_amount)
			if(!length(possible_vampires))
				break
			var/datum/mind/vampire = pick_n_take(possible_vampires)
			pre_vampires += vampire
			vampire.special_role = SPECIAL_ROLE_VAMPIRE
			vampire.restricted_roles = get_restricted_roles()

		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/goon_vampire/post_setup()
	for(var/datum/mind/vampire in pre_vampires)
		vampire.add_antag_datum(/datum/antagonist/vampire/goon_vampire)
	..()
