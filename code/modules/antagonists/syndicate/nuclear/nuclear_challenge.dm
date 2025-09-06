#define CHALLENGE_TIME_LIMIT 6000
#define CHALLENGE_SHUTTLE_DELAY 18000 //30 minutes, so the ops have at least 10 minutes before the shuttle is callable. Gives the nuke ops at least 15 minutes before shuttle arrive.
#define CHALLENGE_MIN_PLAYERS 50
/obj/item/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
	Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
	Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE
	var/total_tc = 0 //Total amount of telecrystals shared between nuke ops
	var/creation_time

/obj/item/nuclear_challenge/Initialize(mapload)
	. = ..()
	creation_time = world.time

/obj/item/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = tgui_alert(user, "Consult your team carefully before you declare war on [station_name()]. Are you sure you want to alert the enemy crew? You have [-round((world.time-SSticker.round_start_time - CHALLENGE_TIME_LIMIT)/10)] seconds to decide.", "Declare war?", list("Yes", "No"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure != "Yes")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		return

	var/war_declaration = "[user.real_name] has declared [user.p_their()] intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."

	declaring_war = TRUE
	var/custom_threat = tgui_alert(user, "Do you want to customize your declaration?", "Customize?", list("Yes", "No"))
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = tgui_input_text(user, "Insert your custom declaration", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	GLOB.major_announcement.announce(war_declaration,
									ANNOUNCE_DECLAREWAR_RU,
									'sound/effects/siren.ogg',
									msg_sanitized = TRUE
	)
	addtimer(CALLBACK(SSsecurity_level, TYPE_PROC_REF(/datum/controller/subsystem/security_level, set_level), SEC_LEVEL_GAMMA), 30 SECONDS)

	to_chat(user, "You've attracted the attention of powerful forces within the syndicate. A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")
	to_chat(user, "<b>Your bonus telecrystals have been split between your team's uplinks.</b>")

	for(var/obj/machinery/computer/shuttle/syndicate/S in SSmachines.get_by_type(/obj/machinery/computer/shuttle/syndicate))
		S.challenge = TRUE
		S.challenge_start_time = creation_time

	// No. of player - Min. Player to dec, divided by player per bonus, then multipled by TC per bonus. Rounded.
	var/datum/team/nuclear_team/team = GLOB.antagonist_teams[/datum/team/nuclear_team]
	team.scale_challange()
	team.share_telecrystals()
	CONFIG_SET(number/shuttle_refuel_delay, CHALLENGE_SHUTTLE_DELAY)
	qdel(src)

/obj/item/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "You are already in the process of declaring war! Make your mind up.")
		return FALSE
	if(GLOB.player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, "The enemy crew is too small to be worth declaring war on.")
		return FALSE
	if(!is_admin_level(user.z))
		to_chat(user, "You have to be at your base to use this.")
		return FALSE
	if((world.time - creation_time) > CHALLENGE_TIME_LIMIT) // Only count after the round started
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make do with what you have on hand.")
		return FALSE
	for(var/obj/machinery/computer/shuttle/syndicate/S in SSmachines.get_by_type(/obj/machinery/computer/shuttle/syndicate))
		if(S.moved)
			to_chat(user, "The shuttle has already been moved! You have forfeit the right to declare war.")
			return FALSE
	return TRUE

#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_SHUTTLE_DELAY
#undef CHALLENGE_MIN_PLAYERS
