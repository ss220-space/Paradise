/datum/admins/proc/check_antagonists_line(mob/M, caption = "", close = 1)
	var/logout_status
	logout_status = M.client ? "" : " <i>(logged out)</i>"
	var/dname = M.real_name
	var/area/A = get_area(M)
	if(!dname)
		dname = M

	return {"<tr><td><a href='byond://?src=[UID()];adminplayeropts=[M.UID()]'>[dname]</a><b>[caption]</b>[logout_status][istype(A, /area/security/permabrig) ? "<b><font color=red> (PERMA) </b></font>" : ""][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>
		<td><a href='byond://?src=[usr.UID()];priv_msg=[M.client?.ckey]'>PM</A> [ADMIN_FLW(M, "FLW")] </td>[close ? "</tr>" : ""]"}

/datum/admins/proc/check_antagonists()
	if(!check_rights(R_ADMIN))
		return
	if(SSticker && SSticker.current_state >= GAME_STATE_PLAYING)
		var/dat = {"<body><h1><B>Round Status</B></h1>"}
		dat += "Current Game Mode: <B>[SSticker.mode.name]</B><BR>"
		dat += "Round Duration: <B>[ROUND_TIME_TEXT()]</B><BR>"
		dat += "<B>Emergency shuttle</B><BR>"
		if(SSshuttle.emergency.mode == SHUTTLE_IDLE)
			dat += "<a href='byond://?src=[UID()];call_shuttle=1'>Call Shuttle</a><br>"
		else
			var/timeleft = SSshuttle.emergency.timeLeft()
			if(SSshuttle.emergency.mode == SHUTTLE_CALL)
				dat += "ETA: <a href='byond://?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
				dat += "<a href='byond://?_src_=holder;call_shuttle=2'>Send Back</a><br>"
			else
				dat += "ETA: <a href='byond://?_src_=holder;edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
		if(!SSshuttle.emergencyNoEscape)
			dat += "<a href='byond://?src=[UID()];lockdown_shuttle=1'>Lockdown Shuttle</a><br>"
		else
			dat += span_danger("<B>Emergency shuttle lockdowned</B>")
			dat += "<BR><a href='byond://?src=[UID()];stop_lockdown=1'>Stop lockdown</a><br>"
		if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
			dat += span_danger("<B>Emergency shuttle stranded</B>")
			dat += "<BR><a href='byond://?src=[UID()];reload_shuttle=1'>Reload Shuttle</a><br>"
		dat += "<a href='byond://?src=[UID()];full_lockdown=1'>Full Lockdown</a>Now: [GLOB.full_lockdown? "ON" : "OFF"]<br>"
		dat += "<a href='byond://?src=[UID()];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
		var/connected_players = GLOB.clients.len
		var/lobby_players = 0
		var/observers = 0
		var/observers_connected = 0
		var/living_players = 0
		var/living_players_connected = 0
		var/living_players_antagonist = 0
		var/other_players = 0
		for(var/mob/M in GLOB.mob_list)
			if(M.ckey)
				if(isnewplayer(M))
					lobby_players++
					continue
				else if(M.stat != DEAD && M.mind && !isbrain(M))
					living_players++
					if(M.mind.special_role)
						living_players_antagonist++
					if(M.client)
						living_players_connected++
				else if((M.stat == DEAD )||(isobserver(M)))
					observers++
					if(M.client)
						observers_connected++
				else
					other_players++
		dat += "<BR><b><font color='#9A67EA'>Players:|[connected_players - lobby_players] ingame|[connected_players] connected|[lobby_players] lobby|</font></b>"
		dat += "<BR><b><font color='green'>Living Players:|[living_players_connected] active|[living_players - living_players_connected] disconnected|[living_players_antagonist] antagonists|</font></b>"
		dat += "<BR><b><font color='red'>Dead/Observing players:|[observers_connected] active|[observers - observers_connected] disconnected|</font></b>"
		if(other_players)
			dat += "<BR><span class='userdanger'>[other_players] players in invalid state or the statistics code is bugged!</span>"
		dat += "<BR>"
		dat +="<br><b>Code Phrases:</b> <span class='codephrases'>[GLOB.syndicate_code_phrase]</span>"
		dat +="<br><b>Code Responses:</b> <span class='coderesponses'>[GLOB.syndicate_code_response]</span>"
		dat += "<br><b>Antagonist Teams</b><br>"
		dat += "<a href='byond://?src=[UID()];check_teams=1'>View Teams</a><br>"
		if(SSticker.mode.syndicates.len)
			dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.syndicates)
				var/mob/M = N.current
				if(M)
					dat += check_antagonists_line(M)
				else
					dat += "<tr><td><i>Nuclear Operative not found!</i></td></tr>"
			dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
			for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
				dat += "<tr><td>[N.name], "
				var/atom/disk_loc = N.loc
				while(!istype(disk_loc, /turf))
					if(istype(disk_loc, /mob))
						var/mob/M = disk_loc
						dat += "carried by <a href='byond://?src=[UID()];adminplayeropts=[M.UID()]'>[M.real_name]</a> "
					if(isobj(disk_loc))
						var/obj/O = disk_loc
						dat += "in \a [O.name] "
					disk_loc = disk_loc.loc
				dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
			dat += "</table>"

		if(SSticker.mode.head_revolutionaries.len || SSticker.mode.revolutionaries.len)
			dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
			for(var/datum/mind/N in SSticker.mode.head_revolutionaries)
				var/mob/M = N.current
				if(!M)
					dat += "<tr><td><i>Head Revolutionary not found!</i></td></tr>"
				else
					dat += check_antagonists_line(M, "(leader)")
			for(var/datum/mind/N in SSticker.mode.revolutionaries)
				var/mob/M = N.current
				if(M)
					dat += check_antagonists_line(M)
			dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
			for(var/datum/mind/N in SSticker.mode.get_living_heads())
				var/mob/M = N.current
				if(M)
					dat += check_antagonists_line(M)
					var/turf/mob_loc = get_turf(M)
					dat += "<td>[mob_loc.loc]</td></tr>"
				else
					dat += "<tr><td><i>Head not found!</i></td></tr>"
			dat += "</table>"
		var/list/blob_infected = SSticker?.mode?.blobs["infected"]
		if(blob_infected && blob_infected.len)
			var/datum/game_mode/mode = SSticker.mode
			dat += "<br><table cellspacing=5><tr><td><B>Blob</B></td><td></td><td></td></tr>"
			dat += "<tr><td><i>Progress: [mode.legit_blobs.len]/[mode.blob_win_count]</i></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];edit_blob_win_count=1'>Edit Win Count</a><br></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];send_warning=1'>Send warning to all living blobs</a><br></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];burst_all_blobs=1'>Burst all blobs</a><br></td></tr>"
			if(check_rights(R_EVENT))
				dat += "<tr><td><a href='byond://?src=[UID()];delay_blob_end=1'>Delay blob end</a> Now: [mode.delay_blob_end? "ON" : "OFF"]<br></td></tr>"
				dat += "<tr><td><a href='byond://?src=[UID()];toggle_auto_gamma=1'>Toggle auto GAMMA</a> Now: [mode.off_auto_gamma? "OFF" : "ON"]<br></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];toggle_auto_nuke_codes=1'>Toggle auto nuke codes</a> Now: [mode.off_auto_nuke_codes? "OFF" : "ON"]<br></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];toggle_blob_infinity_points=1'>Toggle blob infinity points</a> Now: [mode.is_blob_infinity_points? "ON" : "OFF"]<br></td></tr>"
			dat += "</table>"
			dat += "<br><table cellspacing=5><tr><td><B>Blobs</B></td><td></td></tr>"
			for(var/datum/mind/blob in mode.blobs["infected"])
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td>[ADMIN_PP(M,"[M.real_name]")][M.client ? "" : " <i>(ghost)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><a href='byond://?priv_msg=[M.client?.ckey]'>PM</A></td>"
				else
					dat += "<tr><td><i>Blob not found!</i></td></tr>"
			dat += "</table>"
			dat += "<br><table cellspacing=5><tr><td><B>Offsprings</B></td><td></td></tr>"
			for(var/datum/mind/blob in mode.blobs["offsprings"])
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td>[ADMIN_PP(M,"[M.real_name]")][M.client ? "" : " <i>(ghost)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><a href='byond://?priv_msg=[M.client?.ckey]'>PM</A></td>"
				else
					dat += "<tr><td><i>Offspring not found!</i></td></tr>"

			dat += "</table>"

			dat += "<br><table cellspacing=5><tr><td><B>Minions</B></td><td></td></tr>"
			for(var/datum/mind/blob in mode.blobs["minions"])
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td>[ADMIN_PP(M,"[M.real_name]")][M.client ? "" : " <i>(ghost)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><a href='byond://?priv_msg=[M.client?.ckey]'>PM</A></td>"
				else
					dat += "<tr><td><i>Minions not found!</i></td></tr>"

			dat += "</table>"

		if(SSticker.mode.changelings.len)
			dat += check_role_table("Changelings", SSticker.mode.changelings)

		if(SSticker.mode.wizards.len)
			dat += check_role_table("Wizards", SSticker.mode.wizards)

		if(SSticker.mode.apprentices.len)
			dat += check_role_table("Apprentices", SSticker.mode.apprentices)

		if(SSticker.mode.raiders.len)
			dat += check_role_table("Raiders", SSticker.mode.raiders)

		if(SSticker.mode.space_ninjas.len)
			dat += check_role_table("Ninjas", SSticker.mode.space_ninjas)

		if(SSticker.mode.cult.len)
			var/datum/game_mode/gamemode = SSticker.mode
			var/datum/objective/current_sac_obj = gamemode.cult_objs.current_sac_objective()
			dat += check_role_table("Cultists", SSticker.mode.cult)
			if(current_sac_obj)
				dat += "<br>Current cult objective: <br>[current_sac_obj.explanation_text]"
			else if(gamemode.cult_objs.cult_status == NARSIE_NEEDS_SUMMONING)
				dat += "<br>Current cult objective: Summon [SSticker.cultdat ? SSticker.cultdat.entity_name : "Nar'Sie"]"
			else if(gamemode.cult_objs.cult_status == NARSIE_HAS_RISEN)
				dat += "<br>Current cult objective: Feed [SSticker.cultdat ? SSticker.cultdat.entity_name : "Nar'Sie"]"
			else if(gamemode.cult_objs.cult_status == NARSIE_HAS_FALLEN)
				dat += "<br>Current cult objective: Kill all non-cultists"
			else
				dat += "<br>Current cult objective: None! (This is most likely a bug, or var editing gone wrong.)"
			dat += "<br>Sacrifice objectives completed: [gamemode.cult_objs.sacrifices_done]"
			dat += "<br>Sacrifice objectives needed for summoning: [gamemode.cult_objs.sacrifices_required]"
			dat += "<br>Summoning locations: [english_list(gamemode.cult_objs.obj_summon.summon_spots)]"
			dat += "<br><a href='byond://?src=[UID()];cult_mindspeak=[UID()]'>Cult Mindspeak</a>"

			if(gamemode.cult_objs.cult_status == NARSIE_DEMANDS_SACRIFICE)
				dat += "<br><a href='byond://?src=[UID()];cult_adjustsacnumber=[UID()]'>Modify amount of sacrifices required</a>"
				dat += "<br><a href='byond://?src=[UID()];cult_newtarget=[UID()]'>Reroll sacrifice target</a>"
			else
				dat += "<br>Modify amount of sacrifices required (Summon available!)</a>"
				dat += "<br>Reroll sacrifice target (Summon available!)</a>"

			dat += "<br><a href='byond://?src=[UID()];cult_newsummonlocations=[UID()]'>Reroll summoning locations</a>"
			dat += "<br><a href='byond://?src=[UID()];cult_unlocknarsie=[UID()]'>Unlock Nar'Sie summoning</a>"

		if(length(SSticker.mode.clockwork_cult))
			var/datum/game_mode/gamemode = SSticker.mode
			var/datum/objective/cur_demand_obj = gamemode.clocker_objs.obj_demand
			dat += check_role_table("Clockers", SSticker.mode.clockwork_cult)
			if(cur_demand_obj)
				dat += "<br>Current clock cult objective: <br>[cur_demand_obj.explanation_text]"
			else if(gamemode.clocker_objs.clock_status == RATVAR_NEEDS_SUMMONING)
				dat += "<br>Current clock cult objective: Summon Ratvar"
			else if(gamemode.clocker_objs.clock_status == RATVAR_HAS_RISEN)
				dat += "<br>Current clock cult objective: Bring to Ratvar"
			else if(gamemode.clocker_objs.clock_status == RATVAR_HAS_FALLEN)
				dat += "<br>Current clock cult objective: Kill all non-clockers"
			else
				dat += "<br>Current clock cult objective: None! (This is most likely a bug, or var editing gone wrong.)"
			dat += "<br>Power needed: [GLOB.clockwork_power]/[gamemode.clocker_objs.power_goal]"
			dat += "<br>Beacons needed: [length(GLOB.clockwork_beacons)]/[gamemode.clocker_objs.beacon_goal]"
			dat += "<br>Clockers needed: [SSticker.mode.get_clockers()]/[gamemode.clocker_objs.clocker_goal] Reveal:[SSticker.mode.crew_reveal_number]"
			dat += "<br>Summoning locations: [english_list(gamemode.clocker_objs.obj_summon.ritual_spots)]"
			dat += "<br><a href='byond://?src=[UID()];clock_mindspeak=[UID()]'>Clock Cult Mindspeak</a>"

			if(gamemode.clocker_objs.clock_status == RATVAR_DEMANDS_POWER)
				dat += "<br><a href='byond://?src=[UID()];clock_adjustpower=[UID()]'>POWER CHANGE</a>"
				dat += "<br><a href='byond://?src=[UID()];clock_adjustbeacon=[UID()]'>BEACON CHANGE</a>"
				dat += "<br><a href='byond://?src=[UID()];clock_adjustclocker=[UID()]'>CLOCKER CHANGE</a>"
			else
				dat += "<br>The cult reached power demand! Summon available!</a>"

			dat += "<br><a href='byond://?src=[UID()];clock_newsummonlocations=[UID()]'>Reroll summoning locations</a>"
			dat += "<br><a href='byond://?src=[UID()];clock_unlockratvar=[UID()]'>Unlock Ratvar summoning</a>"

		if(SSticker.mode.traitors.len)
			dat += check_role_table("Traitors", SSticker.mode.traitors)

		if(SSticker.mode.implanted.len)
			dat += check_role_table("Mindslaves", SSticker.mode.implanted)

		if(SSticker.mode.thieves.len)
			dat += check_role_table("Thieves", SSticker.mode.thieves)

		if(SSticker.mode.shadows.len)
			dat += check_role_table("Shadowlings", SSticker.mode.shadows)

		if(SSticker.mode.shadowling_thralls.len)
			dat += check_role_table("Shadowling Thralls", SSticker.mode.shadowling_thralls)

		if(SSticker.mode.abductors.len)
			dat += check_role_table("Abductors", SSticker.mode.abductors)

		if(SSticker.mode.abductees.len)
			dat += check_role_table("Abductees", SSticker.mode.abductees)

		if(SSticker.mode.goon_vampires.len)
			dat += check_role_table("Goon Vampires", SSticker.mode.goon_vampires)

		if(SSticker.mode.goon_vampire_enthralled.len)
			dat += check_role_table("Goon Vampire Thralls", SSticker.mode.goon_vampire_enthralled)

		if(SSticker.mode.vampires.len)
			dat += check_role_table("Vampires", SSticker.mode.vampires)

		if(SSticker.mode.vampire_enthralled.len)
			dat += check_role_table("Vampire Thralls", SSticker.mode.vampire_enthralled)

		if(length(SSticker.mode.demons))
			dat += check_role_table("Demons", SSticker.mode.demons)

		if(SSticker.mode.devils.len)
			dat += check_role_table("Devils", SSticker.mode.devils)

		if(SSticker.mode.superheroes.len)
			dat += check_role_table("Superheroes", SSticker.mode.superheroes)

		if(SSticker.mode.supervillains.len)
			dat += check_role_table("Supervillains", SSticker.mode.supervillains)

		if(SSticker.mode.greyshirts.len)
			dat += check_role_table("Greyshirts", SSticker.mode.greyshirts)

		if(SSticker.mode.eventmiscs.len)
			dat += check_role_table("Event Roles", SSticker.mode.eventmiscs)

		if(SSticker.mode.ert.len)
			dat += check_role_table("ERT", SSticker.mode.ert)

		//list active security force count, so admins know how bad things are
		var/list/sec_list = check_active_security_force()
		dat += "<br><table cellspacing=5><tr><td><b>Security</b></td><td></td></tr>"
		dat += "<tr><td>Total: </td><td>[sec_list[1]]</td>"
		dat += "<tr><td>Active: </td><td>[sec_list[2]]</td>"
		dat += "<tr><td>Dead: </td><td>[sec_list[3]]</td>"
		dat += "<tr><td>Antag: </td><td>[sec_list[4]]</td>"
		dat += "</table>"

		dat += "</body>"
		var/datum/browser/popup = new(usr, "roundstatus", "<div align='center'>Round Status</div>", 400, 500)
		popup.set_content(dat)
		popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
		popup.open()
		onclose(usr, "roundstatus")
	else
		tgui_alert(usr, "The game hasn't started yet!")

/datum/admins/proc/check_role_table(name, list/members, show_objectives=1)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/M in members)
		txt += check_role_table_row(M.current, show_objectives)
	txt += "</table>"
	return txt

/datum/admins/proc/check_role_table_row(mob/M, show_objectives)
	if(!istype(M))
		return "<tr><td><i>Not found!</i></td></tr>"

	var/txt = check_antagonists_line(M, close = 0)

	if(show_objectives)
		txt += {"
			<td>
				<a href='byond://?src=[UID()];traitor=[M.UID()]'>Show Objective</a>
			</td>
		"}

	txt += "</tr>"
	return txt

/datum/admins/proc/check_security_line(mob/living/human, close = 1)
	var/logout_status = human.client ? "" : " <i>(logged out)</i>"
	var/list/coords = ATOM_COORDS(human)
	var/job = issilicon(human) ? "Cyborg" : human.job // || need because maybe ert robots with null in job
	return {"<tr><td><a href='byond://?src=[UID()];adminplayeropts=[human.UID()]'>[human.real_name]</a>[logout_status]</td><td>[job][human.stat == DEAD ? " <b><font color=red>(Dead)</font></b>" : "<font color=green> [human.health]%</font>"] <b>[get_area_name(human)]</b> [coords[1]],[coords[2]],[coords[3]]</td><td><a href='byond://?src=[usr.UID()];priv_msg=[human.client?.ckey]'>PM</A> [ADMIN_FLW(human, "FLW")]</td>[close ? "</tr>" : ""]"}

/datum/admins/proc/check_security()
	if(!check_rights(R_ADMIN))
		return
	if(!SSticker || SSticker.current_state < GAME_STATE_PLAYING)
		return

	var/dat = {"<body><h1><B>Round Status</B></h1>"}
	var/list/sec_list = check_active_security_force()
	dat += "<br><table cellspacing=5><tr><td><b>Security</b></td><td></td></tr>"
	dat += "<tr><td>Total: </td><td>[sec_list[1]]</td>"
	dat += "<tr><td>Active: </td><td>[sec_list[2]]</td>"
	dat += "<tr><td>Dead: </td><td>[sec_list[3]]</td>"
	dat += "<tr><td>Antag: </td><td>[sec_list[4]]</td>"
	dat += "</table>"
	dat += "</body>"

	dat += "<br><table cellspacing=5><tr><td><B>Security</B></td><td></td></tr>"
	for(var/datum/mind/mind in SSticker.mode.get_all_sec())
		if(mind.current)
			dat += check_security_line(mind.current)
	dat += "</table>"

	if(SSticker.mode.ert.len)
		dat += check_role_table_sec("ERT", SSticker.mode.ert)

	var/datum/browser/popup = new(usr, "secstatus", "<div align='center'>Security Status</div>", 600, 800)
	popup.set_content(dat)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=0;titlebar=1;")
	popup.open()
	onclose(usr, "secstatus")

/datum/admins/proc/check_role_table_sec(name, list/members, show_objectives=0)
	var/txt = "<br><table cellspacing=5><tr><td><b>[name]</b></td><td></td></tr>"
	for(var/datum/mind/mind in members)
		txt += check_role_table_row_sec(mind.current, show_objectives)
	txt += "</table>"
	return txt

/datum/admins/proc/check_role_table_row_sec(mob/mob, show_objectives)
	var/txt = check_security_line(mob, close = 0)
	if(show_objectives)
		txt += {"
			<td>
				<a href='byond://?src=[UID()];traitor=[mob.UID()]'>Show Objective</a>
			</td>
		"}
	txt += "</tr>"
	return txt
