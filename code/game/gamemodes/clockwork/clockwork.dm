GLOBAL_LIST_EMPTY(all_clockers)

/proc/is_convertable_to_clocker(datum/mind/mind)
	if(!mind)
		return FALSE
	if(!mind.current)
		return FALSE
	if(iscultist(mind.current))
		return FALSE // Damn Narsie and his servants
	if(isclocker(mind.current))
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
		return FALSE //Can't be converted by platform. Have to use a clock slab as an emag.
	if(isalien(mind.current))
		return FALSE
	if(isguardian(mind.current))
		var/mob/living/simple_animal/hostile/guardian/G = mind.current
		if(!isclocker(G.summoner))
			return FALSE //can't convert it unless the owner is converted
	return TRUE

/proc/adjust_clockwork_power(amount)
	GLOB.clockwork_power += amount
	var/datum/team/clockwork_cult/clock_team = get_clockwork_cult_team()
	if(!clock_team)
		return
	clock_team.check_power_reveal()
	clock_team.clocker_objs.power_check()

/datum/game_mode/clockwork
	name = "Clockwork Cult"
	config_tag = "clockwork"
	restricted_jobs = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	required_players = 30
	required_enemies = 3
	recommended_enemies = 4

	var/static/max_clockers_to_start = 4
	var/list/datum/mind/pre_clockers = list()

/datum/game_mode/clockwork/announce()
	to_chat(world, "<b>The current game mode is - Clockwork Cult!</b>")
	to_chat(world, "<b>Some crewmembers are attempting to start a clockwork cult!<br>\nClockers - complete your objectives. Convert crewmembers to your cause by using the credence structure. Remember - there is no you, there is only the cult.<br>\nPersonnel - Do not let the cult succeed in its mission. Brainwashing them with holy water reverts them to whatever CentComm-allowed faith they had.</b>")

/datum/game_mode/clockwork/pre_setup()
	max_clockers_to_start += floor((num_players() - required_players) / RATVAR_PLAYER_PER_CULTIST)
	var/list/clockers_possible = get_players_for_role(ROLE_CLOCKER)
	var/datum/team/clockwork_cult/clock_team = create_antag_team(/datum/team/clockwork_cult)
	clock_team.sets_round_result = TRUE
	for(var/clockers_number in 1 to max_clockers_to_start)
		if(!length(clockers_possible))
			break
		var/datum/mind/clocker = pick(clockers_possible)
		clockers_possible -= clocker
		pre_clockers += clocker
		clocker.restricted_roles = get_restricted_roles()
	return (length(pre_clockers) > 0)

/datum/game_mode/clockwork/post_setup()
	var/datum/team/clockwork_cult/clock_team = get_clockwork_cult_team()
	clock_team.clocker_objs.setup()

	for(var/datum/mind/clockwork_mind in pre_clockers)
		clockwork_mind.add_antag_datum(/datum/antagonist/clockwork)
		equip_clocker(clockwork_mind.current)
		clock_team.clocker_objs.study(clockwork_mind.current)
	clock_team.clockwork_threshold_check()
	addtimer(CALLBACK(clock_team, TYPE_PROC_REF(/datum/team/clockwork_cult, clockwork_threshold_check)), 2 MINUTES) // Check again in 2 minutes for latejoiners
	. = ..()

/datum/game_mode/proc/equip_clocker(mob/living/carbon/human/H, metal = TRUE)
	if(!istype(H))
		return
	. += clock_give_item(/obj/item/clockwork/clockslab, H)
	if(metal)
		. += clock_give_item(/obj/item/stack/sheet/brass/ten, H)
	to_chat(H, span_clock("These will help you start the cult on this station. Use them well, and remember - you are not the only one."))

/datum/game_mode/proc/clock_give_item(obj/item/item_path, mob/living/carbon/human/H)
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

/datum/game_mode/proc/add_clocker(datum/mind/clock_mind)
	if(!istype(clock_mind))
		return FALSE

	var/datum/team/clockwork_cult/clock_team = create_antag_team(/datum/team/clockwork_cult)
	if(!clock_team.reveal_percent)
		clock_team.clocker_objs.setup()
		clock_team.clockwork_threshold_check()

	if(!clock_mind.add_antag_datum(/datum/antagonist/clockwork))
		return FALSE

	add_conversion_logs(clock_mind.current, "converted to the clockwork cult")
	if(!clock_team.clocker_objs.clock_status && ishuman(clock_mind.current))
		clock_team.clocker_objs.setup()

	adjust_clockwork_power(CLOCK_POWER_CONVERT)
	clock_team.check_clock_reveal()
	if(!clock_team.clocker_objs.obj_demand.clockers_get)
		clock_team.clocker_objs.clockers_check()
	clock_team.clocker_objs.study(clock_mind.current)
	return TRUE

/datum/game_mode/proc/remove_clocker(datum/mind/clock_mind, show_message = TRUE)
	var/datum/antagonist/clockwork/clocker = clock_mind?.has_antag_datum(/datum/antagonist/clockwork)
	if(!clocker || !clock_mind.current)
		return

	clocker.silent = !show_message
	clock_mind.remove_antag_datum(/datum/antagonist/clockwork)
	add_conversion_logs(clock_mind.current, "deconverted from the clockwork cult.")
