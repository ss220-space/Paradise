GLOBAL_LIST_EMPTY(all_cults)

/proc/is_convertable_to_cult(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(is_sacrifice_target(mind))
		return FALSE
	if(isclocker(mind.current))
		return FALSE // Go away Ratvar
	if(iscultist(mind.current))
		return TRUE //If they're already in the cult, assume they are convertable
	if(mind.isholy)
		return FALSE
	if(IS_HERETIC_OR_MONSTER(mind.current))
		return FALSE
	if(ishuman(mind.current))
		var/mob/living/carbon/human/H = mind.current
		if(ismindshielded(H)) //mindshield protects against conversions unless removed
			return FALSE
	if(mind.offstation_role)
		return FALSE
	if(issilicon(mind.current))
		return FALSE //can't convert machines, that's ratvar's thing
	if(isalien(mind.current))
		return FALSE
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!iscultist(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	if(isgolem(mind.current))
		return FALSE
	return TRUE

/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	restricted_jobs = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/static/max_cultist_to_start = 4
	var/list/datum/mind/pre_cultists = list()

/datum/game_mode/cult/announce()
	to_chat(world, "<b>The current game mode is - Cult!</b>")
	to_chat(world, "<b>Some crewmembers are attempting to start a cult!<br>\nCultists - complete your objectives. Convert crewmembers to your cause by using the offer rune. Remember - there is no you, there is only the cult.<br>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</b>")

/datum/game_mode/cult/pre_setup()
	max_cultist_to_start += floor((num_players() - required_players) / CULT_PLAYER_PER_CULTIST)
	var/list/cultists_possible = get_players_for_role(ROLE_CULTIST)
	var/datum/team/blood_cult/cult_team = create_antag_team(/datum/team/blood_cult)
	cult_team.sets_round_result = TRUE
	for(var/cultists_number = 1 to max_cultist_to_start)
		if(!length(cultists_possible))
			break
		var/datum/mind/cultist = pick(cultists_possible)
		cultists_possible -= cultist
		pre_cultists += cultist
		cultist.restricted_roles = get_restricted_roles()

		cult_team.ghost_summons = floor(num_players() / GHOST_SUMMONS_PER_READY)
	return (length(pre_cultists) > 0)

/datum/game_mode/cult/post_setup()
	var/datum/team/blood_cult/cult_team = get_blood_cult_team()
	cult_team.cult_objs.setup()

	for(var/datum/mind/cult_mind in pre_cultists)
		cult_mind.add_antag_datum(/datum/antagonist/cult)
		equip_cultist(cult_mind.current)
		cult_team.cult_objs.study(cult_mind.current)
	cult_team.cult_threshold_check()
	addtimer(CALLBACK(cult_team, TYPE_PROC_REF(/datum/team/blood_cult, cult_threshold_check)), 2 MINUTES) // Check again in 2 minutes for latejoiners
	..()

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/H, metal = TRUE)
	if(!istype(H))
		return
	. += cult_give_item(/obj/item/melee/cultblade/dagger, H)
	if(metal)
		. += cult_give_item(/obj/item/stack/sheet/runed_metal/ten, H)
	to_chat(H, span_cult("These will help you start the cult on this station. Use them well, and remember - you are not the only one."))

/datum/game_mode/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/H)
	var/list/slots = list(
		"backpack" = ITEM_SLOT_BACKPACK,
		"left pocket" = ITEM_SLOT_POCKET_LEFT,
		"right pocket" = ITEM_SLOT_POCKET_RIGHT)
	var/T = new item_path(H)
	var/item_name = initial(item_path.name)
	var/where = H.equip_in_one_of_slots(T, slots, qdel_on_fail = TRUE)
	if(!where)
		to_chat(H, span_userdanger("Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1)."))
		return FALSE
	else
		to_chat(H, span_danger("You have a [item_name] in your [where]."))
		return TRUE

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind)
	if(!istype(cult_mind))
		return FALSE

	var/datum/team/blood_cult/cult_team = create_antag_team(/datum/team/blood_cult)
	if(!cult_team.ascend_percent)
		cult_team.cult_objs.setup()
		cult_team.cult_threshold_check()

	if(!cult_mind.add_antag_datum(/datum/antagonist/cult))
		return FALSE

	if(isnull(cult_team.ghost_summons))
		cult_team.ghost_summons = floor(num_station_players() / GHOST_SUMMONS_PER_READY)

	add_conversion_logs(cult_mind.current, "converted to the blood cult")
	if(!cult_team.cult_objs.cult_status && ishuman(cult_mind.current))
		cult_team.cult_objs.setup()
	cult_team.check_cult_size()
	cult_team.cult_objs.study(cult_mind.current)
	return TRUE

/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = TRUE)
	var/datum/antagonist/cult/cultist = cult_mind?.has_antag_datum(/datum/antagonist/cult)
	if(!cultist)
		return
	cultist.silent = !show_message
	cult_mind.remove_antag_datum(/datum/antagonist/cult)
	var/datum/team/blood_cult/cult_team = get_blood_cult_team()
	cult_team?.check_cult_size()
	add_conversion_logs(cult_mind.current, "deconverted from the blood cult.")
