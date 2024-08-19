/datum/game_mode
	/// A list of all minds which have the traitor antag datum.
	var/list/datum/mind/traitors = list()
	/// An associative list with mindslave minds as keys and their master's minds as values.
	var/list/datum/mind/implanted = list()
	/// The Contractor Support Units
	var/list/datum/mind/support = list()

	var/datum/mind/exchange_red
	var/datum/mind/exchange_blue
	/// The number of contractors who accepted the offer.
	var/contractor_accepted = 0


/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	restricted_jobs = list(JOB_TITLE_CYBORG, JOB_TITLE_AI)
	protected_jobs = list(JOB_TITLE_OFFICER, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_HOS, JOB_TITLE_CAPTAIN, JOB_TITLE_BLUESHIELD, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE, JOB_TITLE_LAWYER, JOB_TITLE_BRIGDOC, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD, JOB_TITLE_CCSPECOPS, JOB_TITLE_CCSUPREME, JOB_TITLE_SYNDICATE)
	/// Basically all jobs, except AI.
	var/list/protected_jobs_AI = list(JOB_TITLE_CIVILIAN, JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_ATMOSTECH, JOB_TITLE_MECHANIC, JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_CORONER, JOB_TITLE_CHEMIST, JOB_TITLE_GENETICIST, JOB_TITLE_VIROLOGIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_HOP, JOB_TITLE_CHAPLAIN, JOB_TITLE_BARTENDER, JOB_TITLE_CHEF, JOB_TITLE_BOTANIST, JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH, JOB_TITLE_MINER, JOB_TITLE_CLOWN, JOB_TITLE_MIME, JOB_TITLE_JANITOR, JOB_TITLE_LIBRARIAN, JOB_TITLE_BARBER, JOB_TITLE_EXPLORER)
	required_players = 0
	required_enemies = 1
	recommended_enemies = 4
	/// A list containing references to the minds of soon-to-be traitors. This is seperate to avoid duplicate entries in the `traitors` list.
	var/list/datum/mind/pre_traitors = list()
	/// Same as above for malf AI.
	var/datum/mind/pre_malf_AI
	/// Hard limit on traitors if scaling is turned off.
	var/traitors_possible = 4


/datum/game_mode/traitor/announce()
	to_chat(world, "<B>The current game mode is - Traitor!</B>")
	to_chat(world, "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!</B>")


/datum/game_mode/traitor/pre_setup()
	. = FALSE

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)
	var/list/possible_malfs = get_players_for_role(ROLE_MALF_AI, req_job_rank = JOB_TITLE_AI)

	var/malf_AI_candidate
	if(length(possible_malfs))
		malf_AI_candidate = pick(possible_malfs)
		possible_traitors |= malf_AI_candidate

	if(!length(possible_traitors))
		return

	. = TRUE

	var/num_traitors = 1
	var/num_players = num_players()

	if(CONFIG_GET(number/traitor_scaling))
		num_traitors = max(1, round(num_players / CONFIG_GET(number/traitor_scaling)) + 1)
	else
		num_traitors = max(1, min(num_players, traitors_possible))

	add_game_logs("Number of traitors chosen: [num_traitors]")

	for(var/i in 1 to num_traitors)
		if(!length(possible_traitors))
			break
		var/datum/mind/traitor = pick_n_take(possible_traitors)
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		if(traitor == malf_AI_candidate)
			if((ROLE_TRAITOR in traitor.current.client.prefs.be_special) && prob(50))	// If traitor is also enabled its 50/50 chance.
				pre_traitors += traitor
				traitor.restricted_roles = restricted_jobs
			else
				pre_malf_AI = traitor
				pre_malf_AI.restricted_roles = (restricted_jobs|protected_jobs|protected_jobs_AI)	// All jobs are restricted for malf AI despite the config.
				pre_malf_AI.restricted_roles -= JOB_TITLE_AI
				SSjobs.new_malf = traitor.current
		else
			pre_traitors += traitor
			traitor.restricted_roles = restricted_jobs


/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new
		new_antag.is_contractor = TRUE
		addtimer(CALLBACK(traitor, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(1 SECONDS, 10 SECONDS))
	if(pre_malf_AI)
		addtimer(CALLBACK(pre_malf_AI, TYPE_PROC_REF(/datum/mind, add_antag_datum), /datum/antagonist/malf_ai), rand(1 SECONDS, 10 SECONDS))
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()


/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.


/datum/game_mode/traitor/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	for(var/datum/mind/traitor_mind in traitors)
		for(var/datum/objective/objective in traitor_mind.get_all_objectives())
			objective.check_completion()
	return FALSE


/datum/game_mode/proc/auto_declare_completion_traitor()
	if(length(traitors))
		var/text = "<FONT size = 2><B>The traitors were:</B></FONT><br>"
		for(var/datum/mind/traitor in traitors)
			var/traitorwin = TRUE
			text += printplayer(traitor) + "<br>"

			var/TC_uses = 0
			var/used_uplink = FALSE
			var/purchases = ""
			for(var/obj/item/uplink/uplink in GLOB.world_uplinks)
				if(uplink?.uplink_owner && uplink.uplink_owner == traitor.key)
					TC_uses += uplink.used_TC
					purchases += uplink.purchase_log
					used_uplink = TRUE

			if(used_uplink)
				text += " (used [TC_uses] TC) [purchases]"

			var/all_objectives = traitor.get_all_objectives()

			if(length(all_objectives))//If the traitor had no objectives, don't need to process this.
				var/count = 1
				for(var/datum/objective/objective in all_objectives)
					if(objective.check_completion())
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/steal_objective = objective
							SSblackbox.record_feedback("nested tally", "traitor_steal_objective", 1, list("Steal [steal_objective.steal_target]", "SUCCESS"))
						else
							SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "SUCCESS"))
					else
						text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
						if(istype(objective, /datum/objective/steal))
							var/datum/objective/steal/steal_objective = objective
							SSblackbox.record_feedback("nested tally", "traitor_steal_objective", 1, list("Steal [steal_objective.steal_target]", "FAIL"))
						else
							SSblackbox.record_feedback("nested tally", "traitor_objective", 1, list("[objective.type]", "FAIL"))
						traitorwin = FALSE
					count++

			var/special_role_text
			if(traitor.special_role)
				special_role_text = lowertext(traitor.special_role)
			else
				special_role_text = "antagonist"

			var/datum/antagonist/contractor/contractor = traitor?.has_antag_datum(/datum/antagonist/contractor)
			if(istype(contractor) && contractor.contractor_uplink)
				var/count = 1
				var/earned_tc = contractor.contractor_uplink.hub.reward_tc_paid_out
				for(var/datum/syndicate_contract/s_contract in contractor.contractor_uplink.hub.contracts)
					// Locations
					var/locations = list()
					for(var/area/c_area in s_contract.contract.candidate_zones)
						locations += (c_area == s_contract.contract.extraction_zone ? "<b><u>[c_area.map_name]</u></b>" : c_area.map_name)
					var/display_locations = english_list(locations, and_text = " or ")
					// Result
					var/result = ""
					if(s_contract.status == CONTRACT_STATUS_COMPLETED)
						result = "<font color='green'><B>Success!</B></font>"
					else if(s_contract.status != CONTRACT_STATUS_INACTIVE)
						result = "<font color='red'>Fail.</font>"
					text += "<br><font color='orange'><B>Contract #[count]</B></font>: Kidnap and extract [s_contract.target_name] at [display_locations]. [result]"
					count++
				text += "<br><font color='orange'><B>[earned_tc] TC were earned from the contracts.</B></font>"

			if(traitorwin)
				text += "<br><font color='green'><B>The [special_role_text] was successful!</B></font><br>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "SUCCESS")
			else
				text += "<br><font color='red'><B>The [special_role_text] has failed!</B></font><br>"
				SSblackbox.record_feedback("tally", "traitor_success", 1, "FAIL")

		if(length(SSticker.mode.implanted))
			text += "<br><br><FONT size = 2><B>The mindslaves were:</B></FONT><br>"
			for(var/datum/mind/mindslave in SSticker.mode.implanted)
				text += printplayer(mindslave)
				var/datum/mind/master_mind = SSticker.mode.implanted[mindslave]
				text += " (slaved by: <b>[master_mind.current]</b>)<br>"

		if(length(SSticker.mode.support))
			text += "<br><br><FONT size = 2><B>The Contractor Support Units were:</B></FONT><br>"
			for(var/datum/mind/csu in SSticker.mode.support)
				text += "[printplayer(csu)]<br>"

		var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
		var/responses = jointext(GLOB.syndicate_code_response, ", ")

		text += "<br><br><b>The code phrases were:</b> <span class='danger'>[phrases]</span><br>\
					<b>The code responses were:</b> <span class='danger'>[responses]</span><br><br>"

		to_chat(world, text)
	return TRUE
