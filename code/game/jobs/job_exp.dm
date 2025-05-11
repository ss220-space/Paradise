// Playtime requirements for special roles (hours)

GLOBAL_LIST_INIT(role_playtime_requirements, list(
	// SPECIFIC ROLES
	ROLE_THUNDERDOME = 0,

	// NT ROLES
	ROLE_PAI = 0,
	ROLE_POSIBRAIN = 5, // Same as cyborg job.
	ROLE_SENTIENT = 40,
	ROLE_ERT = 80, // High, because they're team-based, and we want ERT to be robust
	ROLE_DEATHSQUAD = 30,
	ROLE_TRADER = 40, // Very high, because they're an admin-spawned event with powerful items
	ROLE_DRONE = 10, // High, because they're like mini engineering cyborgs that can ignore the AI, ventcrawl, and respawn themselves

	// SOLO ANTAGS
	ROLE_TRAITOR = 30,
	ROLE_MALF_AI = 30,
	ROLE_CHANGELING = 30,
	ROLE_WIZARD = 30,
	ROLE_VAMPIRE = 30,
	ROLE_BLOB = 30,
	ROLE_REVENANT = 30,
	ROLE_BORER = 30,
	ROLE_NINJA = 50,
	ROLE_MORPH = 30,
	ROLE_DEMON = 30,
	ROLE_THIEF = 30,
	ROLE_ELITE = 100,

	// DUO ANTAGS
	ROLE_GUARDIAN = 40,
	ROLE_GSPIDER = 40,

	// TEAM ANTAGS
	// Higher numbers here, because they require more experience to be played correctly
	ROLE_SHADOWLING = 50,
	ROLE_REV = 50,
	ROLE_OPERATIVE = 50,
	ROLE_CULTIST = 50,
	ROLE_CLOCKER = 50,
	ROLE_RAIDER = 50,
	ROLE_ALIEN = 50,
	ROLE_ABDUCTOR = 50,
))

// Admin Verbs

/client/proc/cmd_mentor_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin.Admin"
	set name = "Check Player Playtime"
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return
	var/msg = ""
	var/datum/job/theirjob
	var/jtext
	msg += "<table border='1'><tr><th>Player</th><th>Job</th><th>Crew</th>"
	for(var/thisdept in EXP_DEPT_TYPE_LIST)
		msg += "<th>[thisdept]</th>"
	msg += "</tr>"
	for(var/client/C in GLOB.clients)
		msg += "<tr>"
		if(check_rights(R_ADMIN, 0))
			msg += "<td>[key_name_admin(C.mob)]</td>"
		else
			msg += "<td>[key_name_mentor(C.mob)]</td>"

		jtext = "-"
		if(C.mob.mind && C.mob.mind.assigned_role)
			theirjob = SSjobs.GetJob(C.mob.mind.assigned_role)
			if(theirjob)
				jtext = theirjob.title
		msg += "<td>[jtext]</td>"

		msg += "<td><a href='byond://?_src_=holder;getplaytimewindow=[C.mob.UID()]'>" + C.get_exp_type(EXP_TYPE_CREW) + "</a></td>"
		msg += "[C.get_exp_dept_string()]"
		msg += "</tr>"

	msg += "</table>"
	var/datum/browser/popup = new(src, "player_playtime_check", "Playtime Report", 1000, 300)
	popup.set_content(msg)
	popup.open(FALSE)


/datum/admins/proc/cmd_mentor_show_exp_panel(var/client/C)
	if(!C)
		to_chat(usr, "ERROR: Client not found.")
		return
	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))
		return
	var/body = "<br>Playtime:"
	body += C.get_exp_report()
	var/datum/browser/popup = new(usr, "playerplaytime[C.ckey]", "Playtime for [C.key]", 550, 615)
	popup.set_content(body)
	popup.open(FALSE)


// Procs

/proc/role_available_in_playtime(client/C, role)
	// "role" is a special role defined in role_playtime_requirements above. e.g: ROLE_ERT. This is *not* a job title.
	if(!C)
		return 0
	if(!role)
		return 0
	if(!CONFIG_GET(flag/use_exp_restrictions))
		return 0
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/list/play_records = params2list(C.prefs.exp)
	var/isexempt = text2num(play_records[EXP_TYPE_EXEMPT])
	if(isexempt)
		return 0
	var/minimal_player_hrs = GLOB.role_playtime_requirements[role]
	if(!minimal_player_hrs)
		return 0
	var/req_mins = minimal_player_hrs * 60
	var/my_exp = text2num(play_records[EXP_TYPE_CREW])
	if(!isnum(my_exp))
		return req_mins
	return max(0, req_mins - my_exp)


/datum/job/proc/available_in_playtime(client/C)
	if(!C)
		return 0
	if(!exp_requirements || !exp_type)
		return 0
	if(!CONFIG_GET(flag/use_exp_restrictions))
		return 0
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights(R_ADMIN, 0, C.mob))
		return 0
	var/list/play_records = params2list(C.prefs.exp)
	var/isexempt = text2num(play_records[EXP_TYPE_EXEMPT])
	if(isexempt)
		return 0
	var/my_exp = text2num(play_records[get_exp_req_type()])
	var/job_requirement = text2num(get_exp_req_amount())
	if(my_exp >= job_requirement)
		return 0
	else
		return (job_requirement - my_exp)

/datum/job/proc/get_exp_req_amount()
	return exp_requirements

/datum/job/proc/get_exp_req_type()
	return exp_type

/mob/proc/get_exp_report()
	if(client)
		return client.get_exp_report()
	else
		return "[src] has no client."

/client/proc/get_exp_report()
	if(!CONFIG_GET(flag/use_exp_tracking))
		return "Tracking is disabled in the server configuration file."
	var/list/play_records = params2list(prefs.exp)
	if(!play_records.len)
		return "[key] has no records."
	var/return_text = "<ul>"
	var/list/exp_data = list()
	for(var/category in GLOB.exp_jobsmap)
		if(text2num(play_records[category]))
			exp_data[category] = text2num(play_records[category])
		else
			exp_data[category] = 0
	for(var/dep in exp_data)
		if(exp_data[dep] > 0)
			if(dep == EXP_TYPE_EXEMPT)
				return_text += "<li>Exempt (all jobs auto-unlocked)</li>"
			else if(exp_data[EXP_TYPE_LIVING] > 0)
				return_text += "<li>[dep]: [get_exp_format(exp_data[dep])]</li>"
	if(CONFIG_GET(flag/use_exp_restrictions_admin_bypass) && check_rights(R_ADMIN, 0, mob))
		return_text += "<li>Admin</li>"
	return_text += "</ul>"
	if(CONFIG_GET(flag/use_exp_restrictions))
		var/list/jobs_locked = list()
		var/list/jobs_unlocked = list()
		for(var/datum/job/job in SSjobs.occupations)
			if(job.exp_requirements && job.exp_type)
				if(!job.available_in_playtime(mob.client))
					jobs_unlocked += job.title
				else
					var/xp_req = job.get_exp_req_amount()
					jobs_locked += "[job.title] ([get_exp_format(text2num(play_records[job.get_exp_req_type()]))] / [get_exp_format(xp_req)] as [job.get_exp_req_type()])"
		if(jobs_unlocked.len)
			return_text += "<br><br>Jobs Unlocked:<ul><li>"
			return_text += jobs_unlocked.Join("</li><li>")
			return_text += "</li></ul>"
		if(jobs_locked.len)
			return_text += "<br><br>Jobs Not Unlocked:<ul><li>"
			return_text += jobs_locked.Join("</li><li>")
			return_text += "</li></ul>"
	return return_text

/client/proc/get_exp_type(var/etype)
	return get_exp_format(get_exp_type_num(etype))

/client/proc/get_exp_type_num(var/etype)
	var/list/play_records = params2list(prefs.exp)
	return text2num(play_records[etype])

/client/proc/get_exp_dept_string()
	var/list/play_records = params2list(prefs.exp)
	var/list/result_text = list()
	for(var/thistype in EXP_DEPT_TYPE_LIST)
		var/thisvalue = text2num(play_records[thistype])
		if(thisvalue)
			result_text.Add("<td>[get_exp_format(thisvalue)]</td>")
		else
			result_text.Add("<td>-</td>")
	return result_text.Join("")


/proc/get_exp_format(var/expnum)
	if(expnum > 60)
		return num2text(round(expnum / 60)) + "h"
	else if(expnum > 0)
		return num2text(expnum) + "m"
	else
		return "none"

