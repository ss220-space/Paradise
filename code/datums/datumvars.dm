#define VV_MSG_MARKED "<br><font size='1' color='red'><b>Marked Object</b></font>"
#define VV_MSG_EDITED "<br><font size='1' color='red'><b>Var Edited</b></font>"
#define VV_MSG_ADMIN_SPAWNED "<br><font size='1' color='red'><b>Admin Spawned</b></font>"
#define VV_MSG_DELETED "<br><font size='1' color='red'><b>Deleted</b></font>"
// reference: /client/proc/modify_variables(var/atom/O, var/param_var_name = null, var/autodetect_class = 0)

/**
  * Proc to check if a datum allows proc calls on it
  *
  * Returns TRUE if you can call a proc on the datum, FALSE if you cant
  *
  */
/datum/proc/CanProcCall(procname)
	return TRUE

/datum/proc/can_vv_get(var_name)
	return TRUE

/mob/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"lastKnownIP", "computer_id", "attack_log_old"
	)
	if(!check_rights(R_ADMIN, FALSE, src) && (var_name in protected_vars))
		return FALSE
	return TRUE

/client/can_vv_get(var_name)
	var/static/list/protected_vars = list(
		"address", "chatOutput", "computer_id", "connection", "jbh", "pm_tracker", "related_accounts_cid", "related_accounts_ip", "watchlisted"
	)
	if(!check_rights(R_ADMIN, FALSE, mob) && (var_name in protected_vars))
		return FALSE
	return TRUE

/// Called when a var is edited with the new value to change to
/datum/proc/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, vars))
		return FALSE
	vars[var_name] = var_value
	datum_flags |= DF_VAR_EDITED
	return TRUE


/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if(NAMEOF(src, vars))
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)


/datum/proc/can_vv_delete()
	return TRUE

//please call . = ..() first and append to the result, that way parent items are always at the top and child items are further down
//add seperaters by doing . += "---"
/datum/proc/vv_get_dropdown()
	. = list()
	. += "---"
	.["Call Proc"] = "byond://?_src_=vars;proc_call=[UID()]"
	.["Mark Object"] = "byond://?_src_=vars;mark_object=[UID()]"
	.["Jump to Object"] = "byond://?_src_=vars;jump_to=[UID()]"
	.["Delete"] = "byond://?_src_=vars;delete=[UID()]"
	.["Modify Traits"] = "byond://?_src_=vars;traitmod=[UID()]"
	.["Add Component/Element"] = "byond://?_src_=vars;addcomponent=[UID()]"
	.["Remove Component/Element"] = "byond://?_src_=vars;removecomponent=[UID()]"
	.["Mass Remove Component/Element"] = "byond://?_src_=vars;removecomponent_mass=[UID()]"
	. += "---"

/client/vv_get_dropdown()
	. = list()
	. += "---"
	.["Call Proc"] = "byond://?_src_=vars;proc_call=[UID()]"
	.["Mark Object"] = "byond://?_src_=vars;mark_object=[UID()]"
	.["Delete"] = "byond://?_src_=vars;delete=[UID()]"
	.["Modify Traits"] = "byond://?_src_=vars;traitmod=[UID()]"
	. += "---"

/client/proc/debug_variables(datum/D in world)
	set name = "\[Admin\] View Variables"

	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!check_rights(R_ADMIN|R_VIEWRUNTIMES))
		to_chat(usr, "<span class='warning'>You need to be an administrator to access this.</span>", confidential=TRUE)
		return

	if(!D)
		return


	var/islist = islist(D)
	var/isclient = isclient(D)
	if(!islist && !isclient && !istype(D))
		return

	var/title = ""
	var/icon/sprite
	var/hash
	var/refid

	if(!islist)
		refid = "[D.UID()]"
	else
		refid = "\ref[D]"

	var/type = /list
	if(!islist)
		type = D.type

	if(isatom(D))
		var/atom/A = D
		if(A.icon && A.icon_state)
			sprite = new /icon(A.icon, A.icon_state)
			hash = md5(A.icon)
			hash = md5(hash + A.icon_state)
			usr << browse_rsc(sprite, "vv[hash].png")
	title = "[D]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'></td><td>"


	var/list/atomsnowflake = list()
	if(isatom(D))
		var/atom/A = D
		if(isliving(A))
			var/mob/living/L = A
			atomsnowflake += "<a href='byond://?_src_=vars;rename=[refid]'><b id='name'>[D]</b></a>"
			atomsnowflake += "<br><font size='1'><a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='byond://?_src_=vars;datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(A.dir) || A.dir]</a> <a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"
			atomsnowflake += {"
				<br><font size='1'><a href='byond://?_src_=vars;datumedit=[refid];varnameedit=ckey' id='ckey'>[L.ckey || "No ckey"]</a> / <a href='byond://?_src_=vars;datumedit=[refid];varnameedit=real_name' id='real_name'>[L.real_name || "No real name"]</a></font>
				<br><font size='1'>
					BRUTE:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=brute' id='brute'>[L.getBruteLoss()]</a>
					FIRE:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=fire' id='fire'>[L.getFireLoss()]</a>
					TOXIN:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=toxin' id='toxin'>[L.getToxLoss()]</a>
					OXY:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=oxygen' id='oxygen'>[L.getOxyLoss()]</a>
					CLONE:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=clone' id='clone'>[L.getCloneLoss()]</a>
					BRAIN:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=brain' id='brain'>[L.getBrainLoss()]</a>
					STAMINA:<font size='1'><a href='byond://?_src_=vars;mobToDamage=[refid];adjustDamage=stamina' id='stamina'>[L.getStaminaLoss()]</a>
				</font>
			"}
		else
			atomsnowflake += "<a href='byond://?_src_=vars;datumedit=[refid];varnameedit=name'><b id='name'>[D]</b></a>"
			atomsnowflake += "<br><font size='1'><a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='byond://?_src_=vars;datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(A.dir) || A.dir]</a> <a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"

	else if("name" in D.vars)
		atomsnowflake += "<a href='byond://?_src_=vars;datumedit=[refid];varnameedit=name'><b id='name'>[D]</b></a>"
	else
		atomsnowflake += "<b>[formatted_type]</b>"
		formatted_type = null


	if(length(formatted_type) > 25)
		var/middle_point = length(formatted_type) / 2
		var/splitpoint = findtext(formatted_type, "/", middle_point)
		if(splitpoint)
			formatted_type = "[copytext(formatted_type, 1, splitpoint)]<br>[copytext(formatted_type, splitpoint)]"
		else
			formatted_type = "Type too long" //No suitable splitpoint (/) found.


	var/marked
	if(holder.marked_datum && holder.marked_datum == D)
		marked = VV_MSG_MARKED


	var/varedited_line = ""
	if(isatom(D))
		var/atom/A = D
		if(A.flags & ADMIN_SPAWNED)
			varedited_line += VV_MSG_ADMIN_SPAWNED


	if(!islist && (D.datum_flags & DF_VAR_EDITED))
		varedited_line = VV_MSG_EDITED
	var/deleted_line
	if(!islist && D.gc_destroyed)
		deleted_line = VV_MSG_DELETED


	var/dropdownoptions = list()
	if(islist)
		dropdownoptions = list(
			"---",
			"Add Item" = "byond://?_src_=vars;listadd=[refid]",
			"Remove Nulls" = "byond://?_src_=vars;listnulls=[refid]",
			"Remove Dupes" = "byond://?_src_=vars;listdupes=[refid]",
			"Set len" = "byond://?_src_=vars;listlen=[refid]",
			"Shuffle" = "byond://?_src_=vars;listshuffle=[refid]"
		)
	else
		dropdownoptions = D.vv_get_dropdown()


	var/list/dropdownoptions_html = list()
	for(var/name in dropdownoptions)
		var/link = dropdownoptions[name]
		if(link)
			dropdownoptions_html += "<option value='[link]'>[name]</option>"
		else
			dropdownoptions_html += "<option value>[name]</option>"


	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V


	sleep(1) // Without a sleep here, VV sometimes disconnects clients


	var/list/variable_html = list()
	if(islist)
		var/list/L = D
		for(var/i in 1 to L.len)
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else
		names = sortList(names)
		for(var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<meta charset="UTF-8">
	<head>
		<title>[title]</title>
		<style>
			body {
				font-family: Verdana, sans-serif;
				font-size: 9pt;
			}
			.value {
				font-family: "Courier New", monospace;
				font-size: 8pt;
			}
		</style>
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if (lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if (c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			var last_filter = "";
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var vars_ol = document.getElementById("vars");

				if (filter === last_filter) {
					// An event triggered an update but nothing has changed.
					return;
				} else if (filter.indexOf(last_filter) === 0) {
					// The new filter starts with the old filter, fast path by removing only.
					var children = vars_ol.childNodes;
					for (var i = children.length - 1; i >= 0; --i) {
						try {
							var li = children\[i];
							if (li.innerText.toLowerCase().indexOf(filter) == -1) {
								vars_ol.removeChild(li);
							}
						} catch(err) {}
					}
				} else {
					// Remove everything and put back what matches.
					while (vars_ol.hasChildNodes()) {
						vars_ol.removeChild(vars_ol.lastChild);
					}

					for (var i = 0; i < complete_list.length; ++i) {
						try {
							var li = complete_list\[i];
							if (!filter || li.innerText.toLowerCase().indexOf(filter) != -1) {
								vars_ol.appendChild(li);
							}
						} catch(err) {}
					}
				}

				last_filter = filter;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);

				var lis_new = vars_ol.getElementsByTagName("li");
				for (var j = 0; j < lis_new.length; ++j) {
					lis_new\[j].style.backgroundColor = (j == 0) ? "#ffee88" : "white";
				}
			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				if (event.keyCode == 13) {  //Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								alist = lis\[i].getElementsByTagName("a");
								if(alist.length > 0) {
									location.href=alist\[0].href;
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 38){  //Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								if (i > 0) {
									var li_new = lis\[i-1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 40) {  //Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if (li.style.backgroundColor == "#ffee88") {
								if ((i+1) < lis.length) {
									var li_new = lis\[i+1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else {
					updateSearch();
				}
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if (value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[atomsnowflake.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<span id='marked'>[marked]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='byond://?_src_=vars;[islist ? "listrefresh=\ref[D]" : "datumrefresh=[D.UID()]"]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									target="_parent._top"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions_html.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
	"}

	usr << browse(html, "window=variables[refid];size=475x650")

/client/proc/vv_update_display(datum/D, span, content)
	src << output("[span]:[content]", "variables[D.UID()].browser:replace_span")

#define VV_HTML_ENCODE(thing) ( sanitize ? html_encode(thing) : thing )
/proc/debug_variable(name, value, level, var/datum/DA = null, sanitize = TRUE, display_flags)
	var/header
	if(DA)
		if(islist(DA))
			var/index = name
			if(!isnull(value))
				name = DA[name] // name is really the index until this line
			else
				value = DA[name]
			header = "<li style='backgroundColor:white'>(<a href='byond://?_src_=vars;listedit=\ref[DA];index=[index]'>E</a>) (<a href='byond://?_src_=vars;listchange=\ref[DA];index=[index]'>C</a>) (<a href='byond://?_src_=vars;listremove=\ref[DA];index=[index]'>-</a>) "
		else
			header = "<li style='backgroundColor:white'>(<a href='byond://?_src_=vars;datumedit=[DA.UID()];varnameedit=[name]'>E</a>) (<a href='byond://?_src_=vars;datumchange=[DA.UID()];varnamechange=[name]'>C</a>) (<a href='byond://?_src_=vars;datummass=[DA.UID()];varnamemass=[name]'>M</a>) "
	else
		header = "<li>"

	var/item
	if(isnull(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>null</span>"

	else if(istext(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>\"[VV_HTML_ENCODE(value)]\"</span>"

	else if(isicon(value))
		#ifdef VARSICON
		item = "[name] = /icon (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		item = "[name] = /icon (<span class='value'>[value]</span>)"
		#endif

	else if(istype(value, /image))
		var/image/I = value
		#ifdef VARSICON
		item = "<a href='byond://?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>) [bicon(value, use_class=0)]"
		#else
		item = "<a href='byond://?_src_=vars;Vars=[I.UID()]'>[name] \ref[value]</a> = /image (<span class='value'>[value]</span>)"
		#endif

	else if(isfile(value))
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>'[value]'</span>"

	else if(isdatum(value))
		var/datum/D = value
		item = "<a href='byond://?_src_=vars;Vars=[D.UID()]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [D.type]"

	else if(isclient(value))
		var/client/C = value
		item = "<a href='byond://?_src_=vars;Vars=[C.UID()]'>[VV_HTML_ENCODE(name)] \ref[value]</a> = [C] [C.type]"
//
	else if(islist(value))
		var/list/L = value
		var/list/items = list()

		if(!(display_flags & VV_ALWAYS_CONTRACT_LIST) && L.len && !(name == "underlays" || name == "overlays" || name == "vars" || L.len > (IS_NORMAL_LIST(L) ? 250 : 300)))
			for(var/i in 1 to L.len)
				var/key = L[i]
				var/val
				if(IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if(isnull(val))
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			if(isdatum(name))
				item = "<a href='byond://?_src_=vars;VarsList=\ref[name]'>[VV_HTML_ENCODE(name)]</a> = <a href='byond://?_src_=vars;VarsList=\ref[L]'>/list ([length(L)])</a><ul>[items.Join()]</ul>"
			else
				item = "<a href='byond://?_src_=vars;VarsList=\ref[L]'>[VV_HTML_ENCODE(name)] = /list ([length(L)])</a><ul>[items.Join()]</ul>"

		else
			item = "<a href='byond://?_src_=vars;VarsList=\ref[L]'>[VV_HTML_ENCODE(name)] = /list ([L.len])</a>"

	else if(name in GLOB.bitfields)
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>[VV_HTML_ENCODE(translate_bitfield(VV_BITFIELD, name, value))]</span>"

	else
		item = "[VV_HTML_ENCODE(name)] = <span class='value'>[VV_HTML_ENCODE(value)]</span>"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE

/client/proc/view_var_Topic(href, href_list, hsrc)

	if(view_var_Topic_list(href, href_list, hsrc))  // done because you can't use UIDs with lists and I don't want to snowflake into the below check to supress warnings
		return

	// Correct and warn about any VV topic links that aren't using UIDs
	for(var/paramname in href_list)
		if(findtext(href_list[paramname], "]_"))
			continue // Contains UID-specific formatting, skip it
		var/datum/D = locate(href_list[paramname])
		if(!D)
			continue
		var/datuminfo = "[D]"
		if(istype(D))
			datuminfo = datum_info_line(D)
			href_list[paramname] = D.UID()
		else if(isclient(D))
			var/client/C = D
			href_list[paramname] = C.UID()
		log_runtime(EXCEPTION("Found \\ref-based '[paramname]' param in VV topic for [datuminfo], should be UID: [href]"))

	if(href_list["Vars"])
		debug_variables(locateUID(href_list["Vars"]))

	//~CARN: for renaming mobs (updates their name, real_name, mind.name, their ID/PDA and datacore records).
	else if(href_list["rename"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locateUID(href_list["rename"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		var/new_name = reject_bad_name(sanitize(tgui_input_text(usr, "What would you like to name this mob?", "Input a name", M.real_name, encode = FALSE, max_length = MAX_NAME_LEN)), allow_numbers = TRUE)
		if( !new_name || !M )
			return

		message_admins("Admin [key_name_admin(usr)] renamed [key_name_admin(M)] to [new_name].")
		M.rename_character(M.real_name, new_name)
		vv_update_display(M, "name", new_name)
		vv_update_display(M, "real_name", M.real_name || "No real name")

	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locateUID(href_list["datumedit"])
		if(!isdatum(D) && !isclient(D))
			to_chat(usr, "This can only be used on instances of types /client or /datum", confidential=TRUE)
			return

		if (!modify_variables(D, href_list["varnameedit"], 1))
			return

		switch(href_list["varnameedit"])
			if("name")
				vv_update_display(D, "name", "[D]")
			if("dir")
				var/atom/A = D
				if(istype(A))
					vv_update_display(D, "dir", dir2text(A.dir) || A.dir)
			if("ckey")
				var/mob/living/mob = D
				if(istype(mob))
					vv_update_display(D, "ckey", mob.ckey || "No ckey")
			if("real_name")
				var/mob/living/mob = D
				if(istype(mob))
					vv_update_display(D, "real_name", mob.real_name || "No real name")

	else if(href_list["matrix_tester"])
		var/atom/atom = locateUID(href_list["matrix_tester"])
		if(!istype(atom))
			to_chat(usr, "Это можно использовать только для экземпляров типов /atom", confidential = TRUE)
			return
		usr?.client.open_matrix_tester(atom)

	else if(href_list["togbit"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/D = locateUID(href_list["subject"])
		if(!isdatum(D) && !isclient(D))
			to_chat(usr, "This can only be used on instances of types /client or /datum", confidential=TRUE)
			return
		if(!(href_list["var"] in D.vars))
			to_chat(usr, "Unable to find variable specified.", confidential=TRUE)
			return
		var/value = D.vars[href_list["var"]]
		value ^= 1 << text2num(href_list["togbit"])

		D.vars[href_list["var"]] = value

	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))	return

		var/D = locateUID(href_list["datumchange"])
		if(!isdatum(D) && !isclient(D))
			to_chat(usr, "This can only be used on instances of types /client or /datum", confidential=TRUE)
			return

		modify_variables(D, href_list["varnamechange"], 0)

	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))	return

		var/atom/A = locateUID(href_list["datummass"])
		if(!istype(A))
			to_chat(usr, "This can only be used on instances of type /atom", confidential=TRUE)
			return

		cmd_mass_modify_object_variables(A, href_list["varnamemass"])


	else if(href_list["mob_player_panel"])
		if(!check_rights(R_ADMIN|R_MOD))	return

		var/mob/M = locateUID(href_list["mob_player_panel"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		src.holder.show_player_panel(M)

	else if(href_list["give_spell"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/M = locateUID(href_list["give_spell"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		src.give_spell(M)

	else if(href_list["givemartialart"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/carbon/C = locateUID(href_list["givemartialart"])
		if(!istype(C))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon", confidential=TRUE)
			return

		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M

		var/result = tgui_input_list(usr, "Choose the martial art to teach", "JUDO CHOP", artnames)
		if(!usr)
			return
		if(QDELETED(C))
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(C)


	else if(href_list["give_disease"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/M = locateUID(href_list["give_disease"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		src.give_disease(M)

	else if(href_list["give_taipan_hud"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/living/M = locateUID(href_list["give_taipan_hud"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob/living", confidential=TRUE)
			return
		var/selected_job = tgui_input_list(usr, "Select a job", "Hud Job Selection", GLOB.all_taipan_jobs)

		if(!selected_job)
			to_chat(usr, "No job selected!", confidential=TRUE)
			return

		var/selected_role = M.find_taipan_hud_number_by_job(job = selected_job)
		M.give_taipan_hud(role = selected_role)

	else if(href_list["godmode"])
		if(!check_rights(R_REJUVINATE))	return

		var/mob/M = locateUID(href_list["godmode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		src.cmd_admin_godmode(M)

	else if(href_list["gib"])
		if(!check_rights(R_ADMIN|R_EVENT))	return

		var/mob/M = locateUID(href_list["gib"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		src.cmd_admin_gib(M)

	else if(href_list["build_mode"])
		if(!check_rights(R_BUILDMODE))	return

		var/mob/M = locateUID(href_list["build_mode"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		togglebuildmode(M)

	else if(href_list["drop_everything"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locateUID(href_list["drop_everything"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		if(usr.client)
			usr.client.cmd_admin_drop_everything(M)

	else if(href_list["direct_control"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/mob/M = locateUID(href_list["direct_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return

		if(usr.client)
			usr.client.cmd_assume_direct_control(M)

	else if(href_list["make_skeleton"])
		if(!check_rights(R_SERVER|R_EVENT))	return

		var/mob/living/carbon/human/H = locateUID(href_list["make_skeleton"])
		if(!istype(H))
			to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		var/confirm = tgui_alert(usr, "Are you sure you want to turn this mob into a skeleton?", "Confirm Skeleton Transformation", list("Yes", "No"))
		if(confirm != "Yes")
			return

		H.makeSkeleton()
		log_and_message_admins("has turned [key_name_admin(H)] into a skeleton")

	else if(href_list["offer_control"])
		if(!check_rights(R_ADMIN))	return

		var/mob/M = locateUID(href_list["offer_control"])
		if(!istype(M))
			to_chat(usr, "This can only be used on instances of type /mob", confidential=TRUE)
			return
		offer_control(M)

	else if(href_list["delete"])
		if(!check_rights(R_DEBUG, 0))
			return

		var/datum/D = locateUID(href_list["delete"])
		if(!D)
			to_chat(usr, "Unable to locate item!", confidential=TRUE)
		admin_delete(D)
		if (isturf(D))  // show the turf that took its place
			debug_variables(D)

	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))	return

		var/obj/O = locateUID(href_list["delall"])
		if(!isobj(O))
			to_chat(usr, "This can only be used on instances of type /obj", confidential=TRUE)
			return

		var/action_type = tgui_alert(usr, "Strict type ([O.type]) or type and all subtypes?",, list("Strict type", "Type and subtypes", "Cancel"))
		if(action_type == "Cancel" || !action_type)
			return

		if(tgui_alert(usr, "Are you really sure you want to delete all objects of type [O.type]?",, list("Yes", "No")) != "Yes")
			return

		if(tgui_alert(usr, "Second confirmation required. Delete?",, list("Yes", "No")) != "Yes")
			return

		var/O_type = O.type
		switch(action_type)
			if("Strict type")
				var/i = 0
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist", confidential=TRUE)
					return
				log_and_message_admins("deleted all objects of type [O_type] ([i] objects deleted)")
			if("Type and subtypes")
				var/i = 0
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
				if(!i)
					to_chat(usr, "No objects of this type exist", confidential=TRUE)
					return
				log_and_message_admins("deleted all objects of type or subtype of [O_type] ([i] objects deleted)")

	else if(href_list["makespeedy"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		var/obj/A = locateUID(href_list["makespeedy"])
		if(!istype(A))
			return
		A.datum_flags |= DF_VAR_EDITED
		A.makeSpeedProcess()
		log_and_message_admins("has made [A] speed process")
		return TRUE

	else if(href_list["makenormalspeed"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		var/obj/A = locateUID(href_list["makenormalspeed"])
		if(!istype(A))
			return
		A.datum_flags |= DF_VAR_EDITED
		A.makeNormalProcess()
		log_and_message_admins("has made [A] process normally")
		return TRUE

	else if(href_list["modifyarmor"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		var/obj/A = locateUID(href_list["modifyarmor"])
		if(!istype(A))
			return
		A.datum_flags |= DF_VAR_EDITED
		var/list/armorlist = A.armor.getList()
		var/list/displaylist

		var/result
		do
			displaylist = list()
			for(var/key in armorlist)
				displaylist += "[key] = [armorlist[key]]"
			result = tgui_input_list(usr, "Select an armor type to modify..", "Modify armor", displaylist + "(ADD ALL)" + "(SET ALL)" + "(DONE)")

			if(result == "(DONE)")
				break
			else if(result == "(ADD ALL)" || result == "(SET ALL)")
				var/new_amount = tgui_input_number(usr, result == "(ADD ALL)" ? "Enter armor to add to all types:" : "Enter new armor value for all types:", "Modify all types")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				for(var/key in armorlist)
					armorlist[key] = (result == "(ADD ALL)" ? armorlist[key] : 0) + proper_amount
			else if(result)
				var/list/fields = splittext(result, " = ")
				if(length(fields) != 2)
					continue
				var/type = fields[1]
				if(isnull(armorlist[type]))
					continue
				var/new_amount = tgui_input_number(usr, "Enter new armor value for [type]:", "Modify [type]")
				if(isnull(new_amount))
					continue
				var/proper_amount = text2num(new_amount)
				if(isnull(proper_amount))
					continue
				armorlist[type] = proper_amount
		while(result)

		if(!result || !A)
			return TRUE

		A.armor = A.armor.setRating(armorlist["melee"], armorlist["bullet"], armorlist["laser"], armorlist["energy"], armorlist["bomb"], armorlist["bio"], armorlist["rad"], armorlist["fire"], armorlist["acid"], armorlist["magic"])

		log_and_message_admins("modified the armor on [A] to: melee = [armorlist["melee"]], bullet = [armorlist["bullet"]], laser = [armorlist["laser"]], energy = [armorlist["energy"]], bomb = [armorlist["bomb"]], bio = [armorlist["bio"]], rad = [armorlist["rad"]], fire = [armorlist["fire"]], acid = [armorlist["acid"]], magic = [armorlist["magic"]]")
		return TRUE

	else if(href_list["addreagent"]) /* Made on /TG/, credit to them. */
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/atom/A = locateUID(href_list["addreagent"])

		try_add_reagent(A)

	else if(href_list["editreagents"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return

		var/atom/A = locateUID(href_list["editreagents"])

		try_open_reagent_editor(A)

	else if(href_list["explode"])
		if(!check_rights(R_DEBUG|R_EVENT))	return

		var/atom/A = locateUID(href_list["explode"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf", confidential=TRUE)
			return

		src.cmd_admin_explosion(A)

	else if(href_list["emp"])
		if(!check_rights(R_DEBUG|R_EVENT))	return

		var/atom/A = locateUID(href_list["emp"])
		if(!isobj(A) && !ismob(A) && !isturf(A))
			to_chat(usr, "This can only be done to instances of type /obj, /mob and /turf", confidential=TRUE)
			return

		src.cmd_admin_emp(A)

	else if(href_list["mark_object"])
		if(!check_rights(0))	return

		var/datum/D = locateUID(href_list["mark_object"])
		if(!istype(D))
			to_chat(usr, "This can only be done to instances of type /datum", confidential=TRUE)
			return

		src.holder.marked_datum = D
		if(holder.marked_datum)
			vv_update_display(holder.marked_datum, "marked", "")
		holder.marked_datum = D
		vv_update_display(D, "marked", VV_MSG_MARKED)

	else if(href_list["proc_call"])
		if(!check_rights(R_PROCCALL))
			return

		var/T = locateUID(href_list["proc_call"])

		if(T)
			callproc_datum(T)

	if(href_list["addcomponent"])
		if(!check_rights(R_DEBUG|R_EVENT))
			return
		var/list/names = list()
		var/list/componentsubtypes = sort_list(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/datum/target = locateUID(href_list["addcomponent"])
		var/result = tgui_input_list(usr, "Choose a component/element to add", "Add Component", names)
		if(isnull(result))
			return
		if(!usr || result == "---Components---" || result == "---Elements---")
			return
		if(QDELETED(target))
			to_chat(usr, "That thing doesn't exist anymore!", confidential=TRUE)
			return
		var/list/lst = get_callproc_args()
		if(!lst)
			return
		if(QDELETED(target))
			to_chat(usr, "That thing doesn't exist anymore!", confidential=TRUE)
			return
		var/datumname = "error"
		lst.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(lst)
		else
			datumname = "element"
			target._AddElement(lst)
		log_admin("[key_name(usr)] has added [result] [datumname] to [key_name(target)].")
		message_admins("[key_name_admin(usr)] has added [result] [datumname] to [key_name_admin(target)].")

	if(href_list["removecomponent"] || href_list["removecomponent_mass"])
		if(!check_rights(R_DEBUG|R_EVENT))
			return
		var/mass_remove = href_list["removecomponent_mass"]
		var/datum/target = locateUID(href_list["removecomponent"]) || locateUID(mass_remove)
		var/list/components = target.datum_components?.Copy()
		var/list/names = list()
		names += "---Components---"
		if(length(components))
			names += sort_list(components, GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Elements---"
		// We have to list every element here because there is no way to know what element is on this object without doing some sort of hack.
		names += sort_list(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/path = tgui_input_list(usr, "Choose a component/element to remove. All elements listed here may not be on the datum.", "Remove element", names)
		if(isnull(path))
			return
		if(!usr || path == "---Components---" || path == "---Elements---")
			return
		if(QDELETED(target))
			to_chat(usr, "That thing doesn't exist anymore!")
			return

		var/list/targets_to_remove_from = list(target)
		if(mass_remove)
			var/method = vv_subtype_prompt(target.type)
			targets_to_remove_from = get_all_of_type(target.type, method)

			if(tgui_alert(usr, "Are you sure you want to mass-delete [path] on [target.type]?", "Mass Remove Confirmation", list("Yes", "No")) == "No")
				return

		for(var/datum/target_to_remove_from as anything in targets_to_remove_from)
			if(ispath(path, /datum/element))
				var/list/lst = get_callproc_args()
				if(QDELETED(target_to_remove_from))
					continue
				if(!lst)
					lst = list()
				lst.Insert(1, path)
				target._RemoveElement(lst)
			else
				var/list/components_actual = target_to_remove_from.GetComponents(path)
				for(var/to_delete in components_actual)
					qdel(to_delete)

		message_admins(span_notice("[key_name_admin(usr)] has removed [path] component from [key_name_admin(target)]."))

	else if(href_list["jump_to"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/A = locateUID(href_list["jump_to"])
		var/turf/T = get_turf(A)
		if(T)
			usr.client.jumptoturf(T)


	else if(href_list["rotatedatum"])
		if(!check_rights(R_DEBUG|R_ADMIN))	return

		var/atom/A = locateUID(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom", confidential=TRUE)
			return

		switch(href_list["rotatedir"])
			if("right")	A.dir = turn(A.dir, -45)
			if("left")	A.dir = turn(A.dir, 45)

		log_and_message_admins("has rotated \the [A]")
		vv_update_display(A, "dir", dir2text(A.dir))

	else if(href_list["makemonkey"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makemonkey"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("monkeyone"=href_list["makemonkey"]))

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("makerobot"=href_list["makerobot"]))

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("makealien"=href_list["makealien"]))

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("makeslime"=href_list["makeslime"]))

	else if(href_list["makesuper"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makesuper"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("makesuper"=href_list["makesuper"]))

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		if(tgui_alert(usr, "Confirm mob type change?",, list("Transform", "Cancel")) != "Transform")
			return
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		holder.Topic(href, list("makeai"=href_list["makeai"]))

	else if(href_list["setspecies"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/human/H = locateUID(href_list["setspecies"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon/human", confidential=TRUE)
			return

		var/new_species = tgui_input_list(usr, "Please choose a new species.","Species", GLOB.all_species)

		if(!new_species)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		var/datum/species/S = GLOB.all_species[new_species]
		if(H.set_species(S.type))
			to_chat(usr, "Set species of [H] to [H.dna.species].", confidential=TRUE)
			H.regenerate_icons()
			log_and_message_admins("has changed the species of [key_name_admin(H)] to [new_species]")
		else
			to_chat(usr, "Failed! Something went wrong.", confidential=TRUE)

	else if(href_list["addlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["addlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return

		var/new_language = tgui_input_list(usr, "Please choose a language to add.","Language", GLOB.all_languages)

		if(!new_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		if(H.add_language(new_language))
			to_chat(usr, "Added [new_language] to [H].", confidential=TRUE)
			log_and_message_admins("has given [key_name_admin(H)] the language [new_language]")
		else
			to_chat(usr, "Mob already knows that language.", confidential=TRUE)

	else if(href_list["remlanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["remlanguage"])
		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return

		if(!LAZYLEN(H.languages))
			to_chat(usr, "This mob knows no languages (Perhaps because he was stricken with Babylonian Fewer).", confidential=TRUE)
			return

		var/datum/language/rem_language = tgui_input_list(usr, "Please choose a language to remove.","Language", H.languages)

		if(!rem_language)
			return

		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		if(H.remove_language(rem_language.name))
			to_chat(usr, "Removed [rem_language] from [H].", confidential=TRUE)
			log_and_message_admins("has removed language [rem_language] from [key_name(H)]")
		else
			to_chat(usr, "Mob doesn't know that language.", confidential=TRUE)

	else if(href_list["grantalllanguage"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["grantalllanguage"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return

		H.grant_all_languages()

		to_chat(usr, "Added all languages to [H].", confidential=TRUE)
		log_and_message_admins("has given [key_name(H)] all languages")

	else if(href_list["changevoice"])
		if(!check_rights(R_SPAWN))	return

		var/mob/H = locateUID(href_list["changevoice"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return

		var/old_tts_seed = H.tts_seed
		var/new_tts_seed = H.change_voice(usr)
		if(!new_tts_seed)
			return

		to_chat(usr, "Changed voice from [old_tts_seed] to [new_tts_seed] for [H].", confidential=TRUE)
		to_chat(H, "<span class='notice'>Your voice has been changed from [old_tts_seed] to [new_tts_seed].</span>", confidential=TRUE)
		log_and_message_admins("has changed [key_name(H)]'s voice from [old_tts_seed] to [new_tts_seed]")

	else if(href_list["addverb"])
		if(!check_rights(R_DEBUG))			return

		var/mob/living/H = locateUID(href_list["addverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob/living", confidential=TRUE)
			return
		var/list/possibleverbs = list()
		possibleverbs += "Cancel" 								// One for the top...
		possibleverbs += typesof(/mob/proc,/mob/verb,/mob/living/proc,/mob/living/verb)
		switch(H.type)
			if(/mob/living/carbon/human)
				possibleverbs += typesof(/mob/living/carbon/proc,/mob/living/carbon/verb,/mob/living/carbon/human/verb,/mob/living/carbon/human/proc)
			if(/mob/living/silicon/robot)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/robot/proc,/mob/living/silicon/robot/verb)
			if(/mob/living/silicon/ai)
				possibleverbs += typesof(/mob/living/silicon/proc,/mob/living/silicon/ai/proc,/mob/living/silicon/ai/verb)
		possibleverbs -= H.verbs
		possibleverbs += "Cancel" 								// ...And one for the bottom

		var/verb = tgui_input_list(usr, "Select a verb!", "Verbs", possibleverbs, null)
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		if(!verb || verb == "Cancel")
			return
		else
			add_verb(H, verb)
			log_and_message_admins("has given [key_name(H)] the verb [verb]")

	else if(href_list["remverb"])
		if(!check_rights(R_DEBUG))			return

		var/mob/H = locateUID(href_list["remverb"])

		if(!istype(H))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return
		var/verb = tgui_input_list(usr, "Please choose a verb to remove.","Verbs", H.verbs)
		if(!H)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return
		if(!verb)
			return
		else
			remove_verb(H, verb)
			log_and_message_admins("has removed verb [verb] from [key_name(H)]")

	else if(href_list["addorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locateUID(href_list["addorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon", confidential=TRUE)
			return

		var/new_organ = tgui_input_list(usr, "Please choose an organ to add.","Organ", subtypesof(/obj/item/organ)-/obj/item/organ)
		if(!new_organ) return

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		if(locateUID(new_organ) in M.internal_organs)
			to_chat(usr, "Mob already has that organ.", confidential=TRUE)
			return
		new new_organ(M)
		M.regenerate_icons()
		log_and_message_admins("has given [key_name(M)] the organ [new_organ]")

	else if(href_list["remorgan"])
		if(!check_rights(R_SPAWN))	return

		var/mob/living/carbon/M = locateUID(href_list["remorgan"])
		if(!istype(M))
			to_chat(usr, "This can only be done to instances of type /mob/living/carbon", confidential=TRUE)
			return

		var/obj/item/organ/internal/rem_organ = tgui_input_list(usr, "Please choose an organ to remove.", "Organ", M.internal_organs)

		if(!M)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		if(!(rem_organ in M.internal_organs))
			to_chat(usr, "Mob does not have that organ.", confidential=TRUE)
			return

		to_chat(usr, "Removed [rem_organ] from [M].", confidential=TRUE)
		rem_organ.remove(M)
		log_and_message_admins("has removed the organ [rem_organ] from [key_name(M)]")
		qdel(rem_organ)

	else if(href_list["regenerateicons"])
		if(!check_rights(0))	return

		var/mob/M = locateUID(href_list["regenerateicons"])
		if(!ismob(M))
			to_chat(usr, "This can only be done to instances of type /mob", confidential=TRUE)
			return
		M.regenerate_icons()

	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_EVENT))	return

		var/mob/living/L = locateUID(href_list["mobToDamage"])
		if(!istype(L)) return

		var/Text = href_list["adjustDamage"]

		var/amount = tgui_input_number(usr, "Deal how much damage to mob? (Negative values here heal)", "Adjust [Text]loss", 0)

		if(!L)
			to_chat(usr, "Mob doesn't exist anymore", confidential=TRUE)
			return

		var/newamt
		switch(Text)
			if("brute")
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					H.adjustBruteLoss(amount, affect_robotic = TRUE)
				else
					L.adjustBruteLoss(amount)
				newamt = L.getBruteLoss()
			if("fire")
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					H.adjustFireLoss(amount, affect_robotic = TRUE)
				else
					L.adjustFireLoss(amount)
				newamt = L.getFireLoss()
			if("toxin")
				L.adjustToxLoss(amount)
				newamt = L.getToxLoss()
			if("oxygen")
				L.adjustOxyLoss(amount)
				newamt = L.getOxyLoss()
			if("brain")
				L.adjustBrainLoss(amount)
				newamt = L.getBrainLoss()
			if("clone")
				L.adjustCloneLoss(amount)
				newamt = L.getCloneLoss()
			if("stamina")
				L.adjustStaminaLoss(amount)
				newamt = L.getStaminaLoss()
			else
				to_chat(usr, "You caused an error. DEBUG: Text:[Text] Mob:[L]", confidential=TRUE)
				return

		if(amount != 0)
			log_and_message_admins("dealt [amount] amount of [Text] damage to [L]")
			vv_update_display(L, Text, "[newamt]")

	else if(href_list["traitmod"])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		var/datum/A = locateUID(href_list["traitmod"])
		if(!istype(A))
			return
		holder.modify_traits(A)

	if(href_list["datumrefresh"])
		var/datum/DAT = locateUID(href_list["datumrefresh"])
		if(!isdatum(DAT) && !isclient(DAT))
			return
		src.debug_variables(DAT)

	if(href_list["copyoutfit"])
		if(!check_rights(R_EVENT))
			return
		var/mob/living/carbon/human/H = locateUID(href_list["copyoutfit"])
		if(istype(H))
			H.copy_outfit()

	if(href_list["grantdeadchatcontrol"])
		if(!check_rights(R_EVENT))
			return

		var/atom/movable/A = locateUID(href_list["grantdeadchatcontrol"])
		if(!istype(A))
			return

		if(!CONFIG_GET(flag/dsay_allowed))
			// TODO verify what happens when deadchat is muted
			to_chat(usr, span_warning("Дедчат глобально отключён, включите его перед тем как включать это."))
			return

		if(A.GetComponent(/datum/component/deadchat_control))
			to_chat(usr, span_warning("[capitalize(A.declent_ru(NOMINATIVE))] уже находится под контролем призраков!"))
			return

		var/control_mode = tgui_input_list(usr, "Выберите режим управления","Тип управления", list("демократия", "анархия"), null)

		var/selected_mode
		switch(control_mode)
			if("демократия")
				selected_mode = DEADCHAT_DEMOCRACY_MODE
			if("анархия")
				selected_mode = DEADCHAT_ANARCHY_MODE
			else
				return

		var/cooldown = tgui_input_number(usr, "Пожалуйста, введите время между действиями в секундах. Для демократии это время между действиями (должно быть больше нуля). Для анархии это время между действиями каждого пользователя или -1, если время между ними отсутствует.", "Время между действиями", 0)
		if(isnull(cooldown) || (cooldown == -1 && selected_mode == DEADCHAT_DEMOCRACY_MODE))
			return
		if(cooldown < 0 && selected_mode == DEADCHAT_DEMOCRACY_MODE)
			to_chat(usr, span_warning("Время между действиями режима демократии должно быть больше нуля."))
			return
		if(cooldown == -1)
			cooldown = 0
		else
			cooldown = cooldown SECONDS

		A.deadchat_plays(selected_mode, cooldown)
		log_and_message_admins("provided deadchat control to [A].")

	if(href_list["removedeadchatcontrol"])
		if(!check_rights(R_EVENT))
			return

		var/atom/movable/A = locateUID(href_list["removedeadchatcontrol"])
		if(!istype(A))
			return

		if(!A.GetComponent(/datum/component/deadchat_control))
			to_chat(usr, "[capitalize(A.declent_ru(NOMINATIVE))] больше не находится под контролем призраков!")
			return

		A.stop_deadchat_plays()
		log_and_message_admins("removed deadchat control from [A].")

	if(href_list["atom_say"])
		if(!check_rights(R_EVENT))
			return

		var/atom/object = locateUID(href_list["atom_say"])
		if(!istype(object))
			return
		var/say_text = tgui_input_text(usr, "Введите текст, который будет озвучен объектом", "Введите текст", multiline = TRUE, encode = FALSE)

		object.atom_say(say_text)

		log_and_message_admins("atom_said on behalf of [object] the following: [say_text].")

/client/proc/view_var_Topic_list(href, href_list, hsrc)
	if(href_list["VarsList"])
		debug_variables(locate(href_list["VarsList"]))
		return TRUE

	if(href_list["listedit"] && href_list["index"])
		if(!check_rights(R_VAREDIT))
			return
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listedit"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = TRUE)
		return TRUE

	if(href_list["listchange"] && href_list["index"])
		if(!check_rights(R_VAREDIT))
			return
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listchange"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = FALSE)
		return TRUE

	if(href_list["listremove"] && href_list["index"])
		if(!check_rights(R_VAREDIT))
			return
		var/index = text2num(href_list["index"])
		if(!index)
			return TRUE

		var/list/L = locate(href_list["listremove"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return

		var/variable = L[index]
		var/prompt = tgui_alert(usr, "Do you want to remove item number [index] from list?", "Confirm", list("Yes", "No"))
		if(prompt != "Yes")
			return
		L.Cut(index, index+1)
		log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")
		log_admin("[key_name(src)] modified list's contents: REMOVED=[variable]")
		message_admins("[key_name_admin(src)] modified list's contents: REMOVED=[variable]")
		return TRUE

	if(href_list["listadd"])
		if(!check_rights(R_VAREDIT))
			return
		var/list/L = locate(href_list["listadd"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return TRUE

		mod_list_add(L, null, "list", "contents")
		return TRUE

	if(href_list["listdupes"])
		if(!check_rights(R_VAREDIT))
			return
		var/list/L = locate(href_list["listdupes"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return TRUE

		uniqueList_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")
		log_admin("[key_name(src)] modified list's contents: CLEAR DUPES")
		message_admins("[key_name_admin(src)] modified list's contents: CLEAR DUPES")
		return TRUE

	if(href_list["listnulls"])
		if(!check_rights(R_VAREDIT))
			return
		var/list/L = locate(href_list["listnulls"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return TRUE

		listclearnulls(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")
		log_admin("[key_name(src)] modified list's contents: CLEAR NULLS")
		message_admins("[key_name_admin(src)] modified list's contents: CLEAR NULLS")
		return TRUE

	if(href_list["listlen"])
		if(!check_rights(R_VAREDIT))
			return
		var/list/L = locate(href_list["listlen"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return TRUE
		var/value = vv_get_value(VV_NUM)
		if(value["class"] != VV_NUM)
			return TRUE

		L.len = value["value"]
		log_world("### ListVarEdit by [src]: /list len: [L.len]")
		log_admin("[key_name(src)] modified list's len: [L.len]")
		message_admins("[key_name_admin(src)] modified list's len: [L.len]")
		return TRUE

	if(href_list["listshuffle"])
		if(!check_rights(R_VAREDIT))
			return

		var/list/L = locate(href_list["listshuffle"])
		if(!istype(L))
			to_chat(usr, "This can only be used on instances of type /list", confidential=TRUE)
			return TRUE

		shuffle_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")
		log_admin("[key_name(src)] modified list's contents: SHUFFLE")
		message_admins("[key_name_admin(src)] modified list's contents: SHUFFLE")
		return TRUE

	if(href_list["listrefresh"])
		debug_variables(locate(href_list["listrefresh"]))
		return TRUE
