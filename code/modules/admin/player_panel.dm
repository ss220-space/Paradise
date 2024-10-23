
/datum/admins/proc/player_panel_new()//The new one
	if(!usr.client.holder)
		return
	// This stops the panel from being invoked by mentors who press F7.
	if(!check_rights(R_ADMIN|R_MOD))
		message_admins("[key_name_admin(usr)] attempted to invoke player panel without admin rights. If this is a mentor, its a chance they accidentally hit F7. If this is NOT a mentor, there is a high chance an exploit is being used")
		return
	var/dat = {"<html><meta charset="UTF-8"><head><title>Admin Player Panel</title></head>"}

	//javascript, the part that does most of the work~
	dat += {"

		<head>
			<script type='text/javascript'>

				var locked_tabs = new Array();

				function updateSearch(){


					var filter_text = document.getElementById('filter');
					var filter = filter_text.value.toLowerCase();

					if(complete_list != null && complete_list != ""){
						var mtbl = document.getElementById("maintable_data_archive");
						mtbl.innerHTML = complete_list;
					}

					if(filter.value == ""){
						return;
					}else{

						var maintable_data = document.getElementById('maintable_data');
						var ltr = maintable_data.getElementsByTagName("tr");
						for( var i = 0; i < ltr.length; ++i )
						{
							try{
								var tr = ltr\[i\];
								if(tr.getAttribute("id").indexOf("data") != 0){
									continue;
								}
								var ltd = tr.getElementsByTagName("td");
								var td = ltd\[0\];
								var lsearch = td.getElementsByTagName("b");
								var search = lsearch\[0\];
								//var inner_span = li.getElementsByTagName("span")\[1\] //Should only ever contain one element.
								//document.write("<p>"+search.innerText+"<br>"+filter+"<br>"+search.innerText.indexOf(filter))
								if( search.innerText.toLowerCase().indexOf(filter) == -1 )
								{
									//document.write("a");
									//ltr.removeChild(tr);
									td.innerHTML = "";
									i--;
								}
							}catch(err) {   }
						}
					}

					var count = 0;
					var index = -1;
					var debug = document.getElementById("debug");

					locked_tabs = new Array();

				}

				function expand(id,job,name,real_name,image,key,ip,antagonist,mobUID,client_ckey,eyeUID){

					clearAll();

					var span = document.getElementById(id);

					body = "<table><tr><td>";

					body += "</td><td align='center'>";

					body += "<font size='2'><b>"+job+" "+name+"</b><br><b>Real name "+real_name+"</b><br><b>Played by "+key+" ("+ip+")</b></font>"

					body += "</td><td align='center'>";

					body += "<a href='byond://?src=[UID()];adminplayeropts="+mobUID+"'>PP</a> - "
					body += "<a href='byond://?src=[UID()];shownoteckey="+key+"'>N</a> - "
					body += "<a href='byond://?_src_=vars;Vars="+mobUID+"'>VV</a> - "
					body += "<a href='byond://?src=[UID()];traitor="+mobUID+"'>TP</a> - "
					body += "<a href='byond://?src=[usr.UID()];priv_msg="+client_ckey+"'>PM</a> - "
					body += "<a href='byond://?src=[UID()];subtlemessage="+mobUID+"'>SM</a> - "
					body += "<a href='byond://?src=[UID()];adminplayerobservefollow="+mobUID+"'>FLW</a> - "
					body += "<a href='byond://?src=[UID()];adminalert="+mobUID+"'>ALERT</a>"
					if(eyeUID)
						body += "|<a href='byond://?src=[UID()];adminplayerobservefollow="+eyeUID+"'>EYE</a>"
					body += "<br>"
					if(antagonist > 0)
						body += "<font size='2'><a href='byond://?src=[UID()];check_antagonist=1'><font color='red'><b>Antagonist</b></font></a></font>";

					body += "</td></tr></table>";


					span.innerHTML = body
				}

				function clearAll(){
					var spans = document.getElementsByTagName('span');
					for(var i = 0; i < spans.length; i++){
						var span = spans\[i\];

						var id = span.getAttribute("id");

						if(!(id.indexOf("item")==0))
							continue;

						var pass = 1;

						for(var j = 0; j < locked_tabs.length; j++){
							if(locked_tabs\[j\]==id){
								pass = 0;
								break;
							}
						}

						if(pass != 1)
							continue;




						span.innerHTML = "";
					}
				}

				function addToLocked(id,link_id,notice_span_id){
					var link = document.getElementById(link_id);
					var decision = link.getAttribute("name");
					if(decision == "1"){
						link.setAttribute("name","2");
					}else{
						link.setAttribute("name","1");
						removeFromLocked(id,link_id,notice_span_id);
						return;
					}

					var pass = 1;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 0;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs.push(id);
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "<font color='red'>Locked</font> ";
					//link.setAttribute("onClick","attempt('"+id+"','"+link_id+"','"+notice_span_id+"');");
					//document.write("removeFromLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
					//document.write("aa - "+link.getAttribute("onClick"));
				}

				function attempt(ab){
					return ab;
				}

				function removeFromLocked(id,link_id,notice_span_id){
					//document.write("a");
					var index = 0;
					var pass = 0;
					for(var j = 0; j < locked_tabs.length; j++){
						if(locked_tabs\[j\]==id){
							pass = 1;
							index = j;
							break;
						}
					}
					if(!pass)
						return;
					locked_tabs\[index\] = "";
					var notice_span = document.getElementById(notice_span_id);
					notice_span.innerHTML = "";
					//var link = document.getElementById(link_id);
					//link.setAttribute("onClick","addToLocked('"+id+"','"+link_id+"','"+notice_span_id+"')");
				}

				function selectTextField(){
					var filter_text = document.getElementById('filter');
					filter_text.focus();
					filter_text.select();
				}

			</script>
		</head>


	"}

	//body tag start + onload and onkeypress (onkeyup) javascript event calls
	dat += "<body onload='selectTextField(); updateSearch();' onkeyup='updateSearch();'>"

	//title + search bar
	dat += {"

		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable'>
			<tr id='title_tr'>
				<td align='center'>
					<font size='5'><b>Player panel</b></font><br>
					Hover over a line to see more information | [check_rights(R_ADMIN,0) ? "<a href='byond://?src=[UID()];check_antagonist=1'>Check antagonists</a> | Kick <a href='byond://?_src_=holder;kick_all_from_lobby=1;afkonly=0'>everyone</a>/<a href='byond://?_src_=holder;kick_all_from_lobby=1;afkonly=1'>AFKers</a> in lobby" : "" ]
					<p>
				</td>
			</tr>
			<tr id='search_tr'>
				<td align='center'>
					<b>Search:</b> <input type='text' id='filter' value='' style='width:300px;'>
				</td>
			</tr>
	</table>

	"}

	//player table header
	dat += {"
		<span id='maintable_data_archive'>
		<table width='560' align='center' cellspacing='0' cellpadding='5' id='maintable_data'>"}

	var/list/mobs = sortmobs()
	var/i = 1
	for(var/mob/M in mobs)
		if(M.ckey)

			var/color = "#e6e6e6"
			if(i%2 == 0)
				color = "#f2f2f2"
			var/antagonist_string = get_antag_type_truncated_plaintext_string(M)

			var/M_job = ""

			if(isliving(M))

				if(iscarbon(M)) //Carbon stuff
					if(is_monkeybasic(M))
						M_job = "Monkey"
					else if(ishuman(M))
						M_job = M.job
					else if(isslime(M))
						M_job = "slime"

					else if(isalien(M)) //aliens
						if(islarva(M))
							M_job = "Alien larva"
						else
							M_job = "Alien"
					else
						M_job = "Carbon-based"

				else if(issilicon(M)) //silicon
					if(isAI(M))
						M_job = "AI"
					else if(ispAI(M))
						M_job = "pAI"
					else if(iscogscarab(M))
						M_job = "Cogscarab"
					else if(isrobot(M))
						M_job = "Cyborg"
					else
						M_job = "Silicon-based"

				else if(isanimal(M)) //simple animals
					if(iscorgi(M))
						M_job = "Corgi"
					else
						M_job = "Animal"

				else
					M_job = "Living"

			else if(isnewplayer(M))
				M_job = "New player"

			else if(isobserver(M))
				M_job = "Ghost"

			M_job = replacetext(M_job, "'", "")
			M_job = replacetext(M_job, "\"", "")
			M_job = replacetext(M_job, "\\", "")

			var/M_name = M.name
			M_name = replacetext(M_name, "'", "")
			M_name = replacetext(M_name, "\"", "")
			M_name = replacetext(M_name, "\\", "")
			var/M_rname = M.real_name
			M_rname = replacetext(M_rname, "'", "")
			M_rname = replacetext(M_rname, "\"", "")
			M_rname = replacetext(M_rname, "\\", "")

			var/M_key = M.key
			M_key = replacetext(M_key, "'", "")
			M_key = replacetext(M_key, "\"", "")
			M_key = replacetext(M_key, "\\", "")

			var/M_eyeUID = ""
			if(isAI(M))
				var/mob/living/silicon/ai/A = M
				if(A.client && A.eyeobj) // No point following clientless AI eyes
					M_eyeUID = "[A.eyeobj.UID()]"
			var/client_ckey = M.client ? M.client.ckey : null
			//output for each mob
			dat += {"

				<tr id='data[i]' name='[i]' onClick="addToLocked('item[i]','data[i]','notice_span[i]')">
					<td align='center' bgcolor='[color]'>
						<span id='notice_span[i]'></span>
						<a id='link[i]'
						onmouseover='expand("item[i]","[M_job]","[M_name]","[M_rname]","--unused--","[M_key]","[M.lastKnownIP]","[antagonist_string]","[M.UID()]","[client_ckey]","[M_eyeUID]")'
						>
						<b id='search[i]'>[M_name] - [M_rname] - [M_key] ([M_job])</b>
						</a>
						<br><span id='item[i]'></span>
					</td>
				</tr>

			"}

			i++


	//player table ending
	dat += {"
		</table>
		</span>

		<script type='text/javascript'>
			var maintable = document.getElementById("maintable_data_archive");
			var complete_list = maintable.innerHTML;
		</script>
	</body></html>
	"}

	usr << browse(dat, "window=players;size=600x480")


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
		var/dat = {"<html><meta charset="UTF-8"><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"}
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
			if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
				dat += span_danger("<B>Emergency shuttle stranded</B>")
				dat += "<BR><a href='byond://?src=[UID()];stop_lockdown=1'>Stop lockdown and De-Strandise</a><br>"
			else
				dat += span_danger("<B>Emergency shuttle lockdowned</B>")
				dat += "<BR><a href='byond://?src=[UID()];stop_lockdown=1'>Stop lockdown</a><br>"
		dat += "<a href='byond://?src=[UID()];delay_round_end=1'>[SSticker.delay_end ? "End Round Normally" : "Delay Round End"]</a><br>"
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
			dat += "<tr><td><i>Progress: [GLOB.blobs.len]/[mode.blob_win_count]</i></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];edit_blob_win_count=1'>Edit Win Count</a><br></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];send_warning=1'>Send warning to all living blobs</a><br></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];burst_all_blobs=1'>Burst all blobs</a><br></td></tr>"
			if(check_rights(R_EVENT))
				dat += "<tr><td><a href='byond://?src=[UID()];delay_blob_end=1'>Delay blob end</a> Now: [mode.delay_blob_end? "ON" : "OFF"]<br></td></tr>"
				dat += "<tr><td><a href='byond://?src=[UID()];toggle_auto_gamma=1'>Toggle auto GAMMA</a> Now: [mode.off_auto_gamma? "OFF" : "ON"]<br></td></tr>"
			dat += "<tr><td><a href='byond://?src=[UID()];toggle_auto_nuke_codes=1'>Toggle auto nuke codes</a> Now: [mode.off_auto_nuke_codes? "OFF" : "ON"]<br></td></tr>"
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

			dat += "<br><table cellspacing=5><tr><td><B>Blobernauts</B></td><td></td></tr>"
			for(var/datum/mind/blob in mode.blobs["blobernauts"])
				var/mob/M = blob.current
				if(M)
					dat += "<tr><td>[ADMIN_PP(M,"[M.real_name]")][M.client ? "" : " <i>(ghost)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
					dat += "<td><a href='byond://?priv_msg=[M.client?.ckey]'>PM</A></td>"
				else
					dat += "<tr><td><i>Blobernauts not found!</i></td></tr>"

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

		if(SSticker.mode.xenos.len)
			dat += check_role_table("Xenos", SSticker.mode.xenos)

		if(SSticker.mode.superheroes.len)
			dat += check_role_table("Superheroes", SSticker.mode.superheroes)

		if(SSticker.mode.supervillains.len)
			dat += check_role_table("Supervillains", SSticker.mode.supervillains)

		if(SSticker.mode.greyshirts.len)
			dat += check_role_table("Greyshirts", SSticker.mode.greyshirts)

		if(SSticker.mode.eventmiscs.len)
			dat += check_role_table("Event Roles", SSticker.mode.eventmiscs)

		if(GLOB.ts_spiderlist.len)
			var/list/spider_minds = list()
			for(var/mob/living/simple_animal/hostile/poison/terror_spider/S in GLOB.ts_spiderlist)
				if(S.ckey)
					spider_minds += S.mind
			if(spider_minds.len)
				dat += check_role_table("Terror Spiders", spider_minds)

				var/count_eggs = 0
				var/count_spiderlings = 0
				for(var/obj/structure/spider/eggcluster/terror_eggcluster/E in GLOB.ts_egg_list)
					if(is_station_level(E.z))
						count_eggs += E.spiderling_number
				for(var/obj/structure/spider/spiderling/terror_spiderling/L in GLOB.ts_spiderling_list)
					if(!L.stillborn && is_station_level(L.z))
						count_spiderlings += 1
				dat += "<table cellspacing=5><TR><TD>Growing TS on-station: [count_eggs] egg[count_eggs != 1 ? "s" : ""], [count_spiderlings] spiderling[count_spiderlings != 1 ? "s" : ""]. </TD></TR></TABLE>"

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

		dat += "</body></html>"
		usr << browse(dat, "window=roundstatus;size=400x500")
	else
		alert("The game hasn't started yet!")

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
