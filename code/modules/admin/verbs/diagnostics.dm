ADMIN_VERB_VISIBILITY(debug_air_status, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(debug_air_status, R_DEBUG, "Debug Air Status", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, turf/target as turf)
	if(!isturf(target))
		return

	var/datum/gas_mixture/GM = target.return_air()
	var/burning = 0
	if(issimulatedturf(target))
		var/turf/simulated/T = target
		if(T.active_hotspot)
			burning = 1

	to_chat(user, span_notice("@[target.x],[target.y]: O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] N2O: [GM.sleeping_agent] Agent B: [GM.agent_b] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning) ? span_warning("BURNING") : (null)]"))

	message_admins("[key_name_admin(user)] has checked the air status of [target]")
	log_admin("[key_name(user)] has checked the air status of [target]")
	BLACKBOX_LOG_ADMIN_VERB("Display Air Status")

ADMIN_VERB_VISIBILITY(fix_next_move, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(fix_next_move, R_DEBUG, "Fix Next Move", "Unfreezes all frozen mobs.", ADMIN_CATEGORY_DEBUG)
	message_admins("[key_name_admin(user)] has unfrozen everyone")
	log_admin("[key_name(user)] has unfrozen everyone")

	var/largest_move_time = 0
	var/largest_click_time = 0
	var/mob/largest_move_mob = null
	var/mob/largest_click_mob = null
	for(var/mob/M in world)
		if(!M.client)
			continue
		if(M.next_move >= largest_move_time)
			largest_move_mob = M
			if(M.next_move > world.time)
				largest_move_time = M.next_move - world.time
			else
				largest_move_time = 1
		if(M.next_click >= largest_click_time)
			largest_click_mob = M
			if(M.next_click > world.time)
				largest_click_time = M.next_click - world.time
			else
				largest_click_time = 0
		log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  next_click = [M.next_click]  world.time = [world.time]")
		M.next_move = 1
		M.next_click = 0

	message_admins("[ADMIN_LOOKUPFLW(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [DisplayTimeText(largest_move_time)]!")
	message_admins("[ADMIN_LOOKUPFLW(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [DisplayTimeText(largest_click_time)]!")
	message_admins("world.time = [world.time]")
	BLACKBOX_LOG_ADMIN_VERB("Unfreeze Everyone")

ADMIN_VERB_VISIBILITY(radio_report, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(radio_report, R_DEBUG, "Radio Report", "Shows a report of all radio devices and their filters.", ADMIN_CATEGORY_DEBUG)
	var/filters = list(
		"1" = "RADIO_TO_AIRALARM",
		"2" = "RADIO_FROM_AIRALARM",
		"3" = "RADIO_CHAT",
		"4" = "RADIO_ATMOSIA",
		"5" = "RADIO_NAVBEACONS",
		"6" = "RADIO_AIRLOCK",
		"7" = "RADIO_SECBOT",
		"8" = "RADIO_MULEBOT",
		"_default" = "NO_FILTER"
		)
	var/output = {"<b>Radio Report</b><hr>"}
	for(var/fq in SSradio.frequencies)
		output += "<b>Freq: [fq]</b><br>"
		var/datum/radio_frequency/fqs = SSradio.frequencies[fq]
		if(!fqs)
			output += "&nbsp;&nbsp;<b>ERROR</b><br>"
			continue
		for(var/filter in fqs.devices)
			var/list/f = fqs.devices[filter]
			if(!f)
				output += "&nbsp;&nbsp;[filters[filter]]: ERROR<br>"
				continue
			output += "&nbsp;&nbsp;[filters[filter]]: [length(f)]<br>"
			for(var/device in f)
				if(isobj(device))
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device] ([device:x],[device:y],[device:z] in area [get_area(device:loc)])<br>"
				else
					output += "&nbsp;&nbsp;&nbsp;&nbsp;[device]<br>"

	var/datum/browser/popup = new(user, "radioreport", "Radio Report")
	popup.set_content(output)
	popup.open(FALSE)

	message_admins("[key_name_admin(user)] has generated a radio report")
	log_admin("[key_name(user)] has generated a radio report")
	BLACKBOX_LOG_ADMIN_VERB("Show Radio Report")

ADMIN_VERB(reload_admins, R_SERVER, "Reload Admins", "Reloads all admins from the database.", ADMIN_CATEGORY_SERVER)
	message_admins("[key_name_admin(user)] has manually reloaded admins")
	log_admin("[key_name(user)] has manually reloaded admins")

	load_admins(run_async = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Reload All Admins")

ADMIN_VERB(print_jobban_old, R_ADMIN, "Print Jobban Log", "This spams all the active jobban entries for the current round to standard output.", ADMIN_CATEGORY_BAN)
	to_chat(user, "<b>Jobbans active in this round.</b>")
	for(var/t in GLOB.jobban_keylist)
		to_chat(user, "[t]")

	message_admins("[key_name_admin(user)] has printed the jobban log")
	log_admin("[key_name(user)] has printed the jobban log")

ADMIN_VERB(print_jobban_old_filter, R_ADMIN, "Search Jobban Log", "This searches all the active jobban entries for the current round and outputs the results to standard output.", ADMIN_CATEGORY_BAN)
	var/filter = tgui_input_text(user, "Contains what?", "Filter")
	if(!filter)
		return

	to_chat(user, "<b>Jobbans active in this round.</b>")
	for(var/t in GLOB.jobban_keylist)
		if(findtext(t, filter))
			to_chat(user, "[t]")

	message_admins("[key_name_admin(user)] has searched the jobban log for [filter]")
	log_admin("[key_name(user)] has searched the jobban log for [filter]")

ADMIN_VERB(vv_by_ref, R_DEBUG, "VV by Ref", "Give this a ref string, and you will see its corresponding VV panel if it exists.", ADMIN_CATEGORY_DEBUG)
	var/refstring = tgui_input_text(user, "Which reference?", "Ref")
	if(!refstring)
		return

	var/datum/D = locate(refstring)
	if(!D)
		to_chat(user, span_warning("That ref string does not correspond to any datum."))
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/debug_variables, D)
