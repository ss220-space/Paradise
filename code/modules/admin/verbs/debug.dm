ADMIN_VERB(toggle_game_debug, R_DEBUG, "Debug-Game", "Toggles game debugging.", ADMIN_CATEGORY_DEBUG)
	GLOB.debugging_enabled = !GLOB.debugging_enabled
	var/message = "toggled debugging [(GLOB.debugging_enabled ? "ON" : "OFF")]"
	message_admins("[key_name_admin(user)] [message].")
	log_admin("[key_name(user)] [message].")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Debug Two")

ADMIN_VERB(advanced_proc_call, R_PROCCALL, "Advanced ProcCall", "Call a proc on any datum in the server.", ADMIN_CATEGORY_DEBUG)
	spawn(0)
		var/target = null
		var/targetselected = 0
		var/returnval = null
		var/class = null

		switch(tgui_alert(user, "Proc owned by something?",, list("Yes", "No")))
			if("Yes")
				targetselected = 1
				if(user.holder && user.holder.marked_datum)
					class = tgui_input_list(user, "Proc owned by...", "Owner", list("Obj", "Mob", "Area or Turf", "Client", "Marked datum ([user.holder.marked_datum.type])"), null)
					if(class == "Marked datum ([user.holder.marked_datum.type])")
						class = "Marked datum"
				else
					class = tgui_input_list(user,"Proc owned by...", "Owner", list("Obj","Mob","Area or Turf","Client"), null)
				switch(class)
					if("Obj")
						target = input(user, "Enter target:", "Target", user) as obj in world
					if("Mob")
						target = tgui_input_list(user, "Enter target:", "Target", GLOB.mob_list, user)
					if("Area or Turf")
						target = input(user, "Enter target:", "Target", user.mob.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = tgui_input_list(user, "Please, select a player!", "Selection", keys, null)
					if("Marked datum")
						target = user.holder.marked_datum
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = tgui_input_text(user, "Введите имя прока после /proc/. Пример: если путь /proc/fake_blood, нужно ввести fake_blood", "Путь:", null, encode = FALSE)
		if(!procname)
			return

		//strip away everything but the proc name
		var/list/proclist = splittext(procname, "/")
		if(!length(proclist))
			return
		procname = proclist[length(proclist)]

		var/proctype = "proc"
		if("verb" in proclist)
			proctype = "verb"

		if(targetselected && !hascall(target,procname))
			to_chat(user, span_red("Error: callproc(): type [class] has no [proctype] named [procname]."))
			return

		var/list/lst = user.get_callproc_args()
		if(!lst)
			return

		if(targetselected)
			if(!target)
				to_chat(user, span_red("Error: callproc(): owner of proc no longer exists."))
				return
			message_admins("[key_name_admin(user)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"].")
			log_admin("[key_name(user)] called [target]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			message_admins("[key_name_admin(user)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
			log_admin("[key_name(user)] called [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
			returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc

		to_chat(user, "<font color='#EB4E00'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>")
		BLACKBOX_LOG_ADMIN_VERB("Advanced Proc-Call")

// All these vars are related to proc call protection
// If you add more of these, for the love of fuck, protect them

/// Who is currently calling procs
GLOBAL_VAR(AdminProcCaller)
GLOBAL_PROTECT(AdminProcCaller)
/// How many procs have been called
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)
/// UID of the admin who last called
GLOBAL_VAR(LastAdminCalledTargetUID)
GLOBAL_PROTECT(LastAdminCalledTargetUID)
/// Last target to have a proc called on it
GLOBAL_VAR(LastAdminCalledTarget)
GLOBAL_PROTECT(LastAdminCalledTarget)
/// Last proc called
GLOBAL_VAR(LastAdminCalledProc)
GLOBAL_PROTECT(LastAdminCalledProc)
/// List to handle proc call spam prevention
GLOBAL_LIST_EMPTY(AdminProcCallSpamPrevention)
GLOBAL_PROTECT(AdminProcCallSpamPrevention)

// Wrapper for proccalls where the datum is flagged as vareditted
/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target && procname == "Del")
		to_chat(usr, "Calling Del() is not allowed")
		return

	if(target != GLOBAL_PROC && !target.CanProcCall(procname))
		to_chat(usr, "Proccall on [target.type]/proc/[procname] is disallowed!")
		return
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr ? usr.client.ckey : GLOB.AdminProcCaller
	if(!ckey)
		CRASH("WrapAdminProcCall with no ckey: [target] [procname] [english_list(arguments)]")
	if(current_caller && current_caller != ckey)
		if(!GLOB.AdminProcCallSpamPrevention[ckey])
			to_chat(usr, span_adminnotice("Another set of admin called procs are still running, your proc will be run after theirs finish."))
			GLOB.AdminProcCallSpamPrevention[ckey] = TRUE
			UNTIL(!GLOB.AdminProcCaller)
			to_chat(usr, span_adminnotice("Running your proc"))
			GLOB.AdminProcCallSpamPrevention -= ckey
		else
			UNTIL(!GLOB.AdminProcCaller)
	GLOB.LastAdminCalledProc = procname
	if(target != GLOBAL_PROC)
		GLOB.LastAdminCalledTargetUID = target.UID()
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	try
		. = world.WrapAdminProcCall(target, procname, arguments)
	catch
		to_chat(usr, span_adminnotice("Your proc call failed to execute, likely from runtimes. You <i>should</i> be out of safety mode. If not, god help you."))

	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(datum/target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call("/proc/[procname]")(arglist(arguments))
	else if(target != world)
		return call(target, procname)(arglist(arguments))
	else
		to_chat(usr, span_boldannounceooc("Call to world/proc/[procname] blocked: Advanced ProcCall detected."))
		message_admins("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]")
		log_admin("[key_name(usr)] attempted to call world/proc/[procname] with arguments: [english_list(arguments)]l")

/proc/IsAdminAdvancedProcCall()
#if defined(GAME_TESTS) || defined(MAP_TESTS) || defined(TESTING)
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

ADMIN_VERB_ONLY_CONTEXT_MENU(call_proc_datum, R_PROCCALL, "Atom ProcCall", atom/A as null|area|mob|obj|turf)
	var/procname = tgui_input_text(user, "Введите имя прока после /proc/. Пример: если путь /proc/fake_blood, нужно ввести fake_blood", "Путь:", null, encode = FALSE)
	if(!procname)
		return

	if(!hascall(A,procname))
		to_chat(user, span_warning("Error: callproc_datum(): target has no such call [procname]."), confidential = TRUE)
		return

	var/list/lst = user.get_callproc_args()
	if(!lst)
		return

	if(!A || !is_valid_src(A))
		to_chat(user, span_warning("Error: callproc_datum(): owner of proc no longer exists."), confidential = TRUE)
		return
	message_admins("[key_name_admin(user)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")
	log_admin("[key_name(user)] called [A]'s [procname]() with [length(lst) ? "the arguments [list2params(lst)]":"no arguments"]")

	spawn()
		var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
		to_chat(user, span_notice("[procname] returned: [!isnull(returnval) ? returnval : "null"]"), confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Atom Proc-Call")

/client/proc/get_callproc_args(is_atom_new = FALSE)
	var/argnum = tgui_input_number(src, "Введите число аргументов [is_atom_new ? " (За исключением loc)" : ""]", "Число аргументов:", 0)
	if(argnum <= 0)
		return list() // to allow for calling with 0 args

	argnum = clamp(argnum, 1, 50)

	var/list/lst = list()
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn
	var/extra_classes = list("type", "reference", "mob's area", "CANCEL")
	while(argnum--)
		var/value = vv_get_value(extra_classes = extra_classes)

		if(!(value["class"] in extra_classes))
			lst += value["value"]
			continue

		var/class = value["class"]
		// Make a list with each index containing one variable, to be given to the proc
		switch(class)
			if("CANCEL")
				return null

			if("type")
				lst += tgui_input_list(src, "Выберите тип:", "Тип", typesof(/obj,/mob,/area,/turf))

			if("reference")
				lst += input(src, "Выберите ссылку:", "Ссылка", src) as mob|obj|turf|area in world

			if("mob's area")
				var/mob/temp = tgui_input_list(src, "Выберите моба", "Выбор", GLOB.mob_list, usr)
				lst += temp.loc

	return lst

ADMIN_VERB_VISIBILITY(air_status, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(air_status, R_DEBUG, "Air Status In Location", "Gets the air status for your current turf.", ADMIN_CATEGORY_DEBUG)
	var/turf/user_turf = get_turf(user.mob)
	if(!isturf(user_turf))
		return
	atmos_scan(user.mob, user_turf, silent = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Air Status In Location")

ADMIN_VERB(cmd_admin_robotize, R_SPAWN, "Make Robot", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target)
	if(!SSticker.HasRoundStarted())
		tgui_alert(user, "Wait until the game starts")
		return

	if(issilicon(target))
		tgui_alert(user, "They are already a robot.")
		return

	if(ishuman(target))
		var/mob/living/carbon/human/human = target
		log_admin("[key_name(user)] has robotized [human.key].")
		spawn(10)
			var/mob/living/silicon/robot/new_robot = human.Robotize()
			if(new_robot)
				SSticker?.score?.save_silicon_laws(new_robot, user.mob, "admin robotized user", log_all_laws = TRUE)
	else
		tgui_alert(user, "Invalid mob")

ADMIN_VERB(cmd_admin_animalize, R_SPAWN, "Make Simple Animal", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!SSticker)
		tgui_alert(user, "Wait until the game starts")
		return

	if(!target)
		tgui_alert(user, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(target))
		tgui_alert(user, "The mob must not be a new_player.")
		return

	log_admin("[key_name(user)] has animalized [target.key].")
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, Animalize)), 1 SECONDS)

ADMIN_VERB(cmd_admin_gorillize, R_SPAWN, "Make Gorilla", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!SSticker)
		tgui_alert(user, "Wait until the game starts")
		return

	if(!target)
		tgui_alert(user, "That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(target))
		tgui_alert(user, "The mob must not be a new_player.")
		return

	if(tgui_alert(user, "Confirm make gorilla?", null, list("Yes", "No")) != "Yes")
		return

	var/gorilla_type = tgui_alert(user, "What kind of gorilla?", null, list("Normal", "Enraged", "Cargorilla"))
	if(!gorilla_type)
		return

	log_admin("[key_name(user)] has gorillized [target.key].")
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, gorillize), gorilla_type), 1 SECONDS)

ADMIN_VERB(cmd_admin_super, R_SPAWN, "Make Superhero", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!SSticker)
		tgui_alert(user, "Wait until the game starts")
		return

	if(ishuman(target))
		var/type = tgui_input_list(user, "Pick the Superhero", "Superhero", GLOB.all_superheroes)
		var/datum/superheroes/superhero = GLOB.all_superheroes[type]
		if(superhero)
			superhero.create(target)
		log_and_message_admins(span_notice("made [key_name(target)] into a Superhero."))
	else
		tgui_alert(user, "Invalid mob")

ADMIN_VERB(cmd_debug_del_sing, R_DEBUG, "Del Singulo / Tesla", "Delete all singularities and tesla balls.", ADMIN_CATEGORY_DEBUG)
	//This gets a confirmation check because it's way easier to accidentally hit this and delete things than it is with qdel-all
	var/confirm = tgui_alert(user, "This will delete ALL Singularities and Tesla orbs except for any that are on away mission z-levels or the centcomm z-level. Are you sure you want to delete them?", "Confirm Panic Button", list("Yes", "No"))
	if(confirm != "Yes")
		return

	for(var/I in GLOB.singularities)
		var/obj/singularity/S = I
		if(!is_level_reachable(S.z))
			continue
		qdel(S)
	log_and_message_admins("has deleted all Singularities and Tesla orbs.")
	BLACKBOX_LOG_ADMIN_VERB("Del Singulo/Tesla")

ADMIN_VERB(cmd_debug_make_powernets, R_DEBUG, "Make Powernets", "Regenerates all powernets for all cables.", ADMIN_CATEGORY_DEBUG)
	SSmachines.makepowernets()
	log_and_message_admins("has remade the powernets. makepowernets() called.")
	BLACKBOX_LOG_ADMIN_VERB("Make Powernets")

ADMIN_VERB(cmd_admin_grantfullaccess, R_EVENT, "Grant Full Access", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!SSticker)
		tgui_alert(user, "Wait until the game starts")
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/card/id/id = null
		if(H.wear_id)
			id = H.wear_id.GetID()
		if(istype(id))
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		if(!H.wear_id || !istype(id))
			id = new/obj/item/card/id(target)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = JOB_TITLE_CAPTAIN
			id.name = "[id.registered_name]’s ID Card ([id.assignment])"
			H.equip_to_slot_or_del(id, ITEM_SLOT_ID)
			H.update_worn_id()
	else
		tgui_alert(user, "Invalid mob")
	BLACKBOX_LOG_ADMIN_VERB("Grant Full Access")
	log_admin("[key_name(user)] has granted [target.key] full access.")
	message_admins(span_adminnotice("[key_name_admin(user)] has granted [target.key] full access."))

ADMIN_VERB_VISIBILITY(cmd_admin_grantfullaccess_in_list, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(cmd_admin_grantfullaccess_in_list, R_EVENT, "Grant Full Access in List", "Grant full access to a mob.", ADMIN_CATEGORY_DEBUG)
	var/mob/target = tgui_input_list(user, "Please, select a player!", "Grant Full Access", GLOB.mob_list)
	if(!target)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_admin_grantfullaccess, target)

ADMIN_VERB(cmd_assume_direct_control, R_DEBUG|R_ADMIN, "Assume Direct Control", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(target.ckey)
		if(tgui_alert(user, "This mob is being controlled by [target.ckey]. Are you sure you wish to assume control of it? [target.ckey] will be made a ghost.", null, list("Yes", "No")) != "Yes")
			return
	if(!target || QDELETED(target))
		to_chat(user, span_warning("The target mob no longer exists."))
		return
	message_admins(span_adminnotice("[key_name_admin(user)] assumed direct control of [target]."))
	log_admin("[key_name(user)] assumed direct control of [target].")
	var/mob/adminmob = user.mob
	if(target.ckey)
		target.ghostize(FALSE)

	target.possess_by_player(user.key)
	user.init_verbs()
	if(isobserver(adminmob))
		qdel(adminmob)

	BLACKBOX_LOG_ADMIN_VERB("Assume Direct Control")

ADMIN_VERB(cmd_assume_direct_control_in_list, R_DEBUG|R_ADMIN, "Assume Direct Control in List", "Assume direct control of a mob.", ADMIN_CATEGORY_DEBUG)
	var/mob/target = tgui_input_list(user, "Please, select a player!", "Assume Direct Control", GLOB.mob_list)
	if(!target)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_assume_direct_control, target)

ADMIN_VERB_VISIBILITY(cmd_admin_areatest, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(cmd_admin_areatest, R_DEBUG, "Test Areas", "Tests the areas for various machinery.", ADMIN_CATEGORY_MAPPING, on_station as num, filter_maint as num)
	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(user, "Game still loading, please hold!", confidential = TRUE)
		return

	var/log_message
	if(on_station)
		dat += "<b>Only checking areas on station z-levels.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"
	if(filter_maint)
		dat += "<b>Maintenance Areas Filtered Out</b>"
		log_message += ", with no maintenance areas"

	message_admins(span_adminnotice("[key_name_admin(user)] used the Test Areas debug command checking [log_message]."))
	log_admin("[key_name(user)] used the Test Areas debug command checking [log_message].")

	for(var/area/A as anything in GLOB.areas)
		if(on_station)
			var/list/area_turfs = get_area_turfs(A.type)
			if(!length(area_turfs))
				continue
			var/turf/picked = pick(area_turfs)
			if(is_station_level(picked.z))
				if(!(A.type in areas_all))
					if(filter_maint && istype(A, /area/maintenance))
						continue
					areas_all.Add(A.type)
		else if(!(A.type in areas_all))
			areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC as anything in SSmachines.get_by_type(/obj/machinery/power/apc))
		var/area/A = APC.area
		if(!A)
			dat += "Skipped over [APC] in invalid location, [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/alarm/AA in GLOB.air_alarms)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Skipped over [AA] in invalid location, [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in SSmachines.get_by_type(/obj/machinery/requests_console))
		var/area/A = get_area(RC)
		if(!A)
			dat += "Skipped over [RC] in invalid location, [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L as anything in SSmachines.get_by_type(/obj/machinery/light))
		var/area/A = get_area(L)
		if(!A)
			dat += "Skipped over [L] in invalid location, [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS as anything in SSmachines.get_by_type(/obj/machinery/light_switch))
		var/area/A = get_area(LS)
		if(!A)
			dat += "Skipped over [LS] in invalid location, [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I in GLOB.global_radios)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in SSmachines.get_by_type(/obj/machinery/camera))
		var/area/A = get_area(C)
		if(!A)
			dat += "Skipped over [C] in invalid location, [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>AREAS WITHOUT AN APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>AREAS WITH MULTIPLE APCS:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>AREAS WITHOUT AN AIR ALARM:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>AREAS WITHOUT A REQUEST CONSOLE:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>AREAS WITHOUT ANY LIGHTS:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>AREAS WITHOUT A LIGHT SWITCH:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>AREAS WITHOUT ANY INTERCOMS:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>AREAS WITHOUT ANY CAMERAS:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>No problem areas!</b>"

	var/datum/browser/popup = new(user.mob, "testareas", "Test Areas", 500, 750)
	popup.set_content(dat.Join())
	popup.open()

ADMIN_VERB_ONLY_CONTEXT_MENU(select_equipment, R_EVENT, "Select Equipment", mob/living/carbon/human/M in GLOB.mob_list)
	if(!ishuman(M) && !isobserver(M))
		tgui_alert(user, "Неподходящее существо")
		return

	var/dresscode = user.robust_dress_shop()

	if(!dresscode)
		return

	var/delete_pocket
	var/mob/living/carbon/human/H
	if(isobserver(M))
		if(!check_rights(R_SPAWN))
			return
		var/mob/dead/observer/ghost = M
		H = ghost.incarnate_ghost()
	else
		H = M
		if(H.l_store || H.r_store || H.s_store) //saves a lot of time for admins and coders alike
			if(tgui_alert(user, "Нужно ли выбрасывать вещи из карманов? Выбор \"Нет\" удалит их.", "Выбор экипировки существа", "Да", "Нет") == "Нет")
				delete_pocket = TRUE

	for(var/obj/item/I in H.get_equipped_items(delete_pocket ? INCLUDE_POCKETS : NONE))
		qdel(I)
	if(dresscode != "Naked")
		H.equipOutfit(dresscode)
	else	// We have regenerate_icons() proc in the end of equipOutfit(), so don't need to call it two times.
		H.regenerate_icons()
		// Grey translator fix for admin equip
	if(isgrey(H.dna.species))
		var/obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator/retranslator = new
		retranslator.insert(H)

		if(HAS_TRAIT(H, TRAIT_WINGDINGS))
			var/obj/item/translator_chip/wingdings/chip = new
			retranslator.install_chip(H, chip, ignore_lid = TRUE)
			to_chat(H, span_notice("В связи с вашим недугом, у вас уже установлен чип Вингдингс."))

	log_and_message_admins(span_notice("changed the equipment of [key_name_admin(M)] to [dresscode]."))
	BLACKBOX_LOG_ADMIN_VERB("Select Equipment")

/client/proc/robust_dress_shop()
	var/list/outfits = list(
		"Naked",
		"As Job...",
		"Custom..."
	)

	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job)
	for(var/path in paths)
		var/datum/outfit/outfit = path //not much to initalize here but whatever
		if(initial(outfit.can_be_admin_equipped))
			outfits[initial(outfit.name)] = path

	var/dresscode = tgui_input_list(usr, "Select outfit", "Robust quick dress shop", outfits)
	if(isnull(dresscode))
		return

	if(outfits[dresscode])
		dresscode = outfits[dresscode]

	if(dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/outfit = path
			if(initial(outfit.can_be_admin_equipped))
				job_outfits[initial(outfit.name)] = path

		dresscode = tgui_input_list(usr, "Select job equipment", "Robust quick dress shop", job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "Custom...")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = tgui_input_list(usr, "Select outfit", "Robust quick dress shop", custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

ADMIN_VERB_VISIBILITY(start_singulo, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(start_singulo, R_DEBUG, "Start Singularity", "Sets up the singularity and all machines to get power flowing through the station.", ADMIN_CATEGORY_DEBUG)
	if(tgui_alert(user, "Are you sure? This will start up the engine. Should only be used during debug!", null, list("Yes", "No")) != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in SSmachines.get_by_type(/obj/machinery/power/emitter))
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in SSmachines.get_by_type(/obj/machinery/field/generator))
		if(F.active == 0)
			F.active = 1
			F.state = 2
			F.power = 250
			F.set_anchored(TRUE)
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in SSmachines.get_by_type(/obj/machinery/the_singularitygen))
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G))
				S.energy = 800
				break

	for(var/obj/machinery/power/rad_collector/Rad in SSmachines.get_by_type(/obj/machinery/power/rad_collector))
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				Plasma.air_contents.set_toxins(70)
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in SSmachines.get_by_type(/obj/machinery/power/smes))
		if(SMES.anchored)
			SMES.input_attempt = 1

ADMIN_VERB(debug_mob_lists, R_DEBUG, "Debug Mob Lists", "For when you just gotta know.", ADMIN_CATEGORY_DEBUG)
	switch(tgui_input_list(user, "Which list?", items = list("Players", "Admins", "Mobs", "Living Mobs", "Alive Mobs", "Dead Mobs", "Silicons", "Clients", "Respawnable Mobs")))
		if("Players")
			to_chat(user, jointext(GLOB.player_list, ","))
		if("Admins")
			to_chat(user, jointext(GLOB.admins, ","))
		if("Mobs")
			to_chat(user, jointext(GLOB.mob_list, ","))
		if("Living Mobs")
			to_chat(user, jointext(GLOB.mob_living_list, ","))
		if("Alive Mobs")
			to_chat(user, jointext(GLOB.alive_mob_list, ","))
		if("Dead Mobs")
			to_chat(user, jointext(GLOB.dead_mob_list, ","))
		if("Silicons")
			to_chat(user, jointext(GLOB.silicon_mob_list, ","))
		if("Clients")
			to_chat(user, jointext(GLOB.clients, ","))
		if("Respawnable Mobs")
			to_chat(user, jointext(GLOB.respawnable_list, ","))

ADMIN_VERB(display_del_log, R_DEBUG, "Display del() Log", "Display del's log of everything that's passed through it.", ADMIN_CATEGORY_DEBUG)
	var/list/dellog = list("<b>List of things that have gone through qdel this round</b><br><br><ol>")
	sortTim(SSgarbage.items, cmp = /proc/cmp_qdel_item_time, associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if(I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if(I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
		if(I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if(I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if(I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	var/datum/browser/popup = new(user, "dellog", "Del logs")
	popup.set_content(dellog.Join())
	popup.open(FALSE)

ADMIN_VERB(display_del_log_simple, R_DEBUG, "Display Simple del() Log", "Display a compacted del's log.", ADMIN_CATEGORY_DEBUG)
	var/dat = {"<b>List of things that failed to GC this round</b><br><br>"}
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.failures)
			dat += "[I] - [I.failures] times<br>"

	dat += "<b>List of paths that did not return a qdel hint in Destroy()</b><br><br>"
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.no_hint)
			dat += "[I]<br>"

	dat += "<b>List of paths that slept in Destroy()</b><br><br>"
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		if(I.slept_destroy)
			dat += "[I]<br>"

	var/datum/browser/popup = new(user, "simpledellog", "Simple del logs")
	popup.set_content(dat)
	popup.open(FALSE)

/client/proc/cmd_admin_toggle_block(mob/M, block)
	if(!check_rights(R_SPAWN))
		return

	if(!SSticker)
		tgui_alert(usr, "Wait until the game starts")
		return
	if(iscarbon(M))
		var/state_value = M.dna.GetSEState(block)
		M.force_gene_block(block, !state_value)
		var/state_word = "[state_value?"on":"off"]"
		var/blockname = GLOB.assigned_blocks[block]
		message_admins("[key_name_admin(src)] has toggled [M.key]'s [blockname] block [state_word]!")
		log_admin("[key_name(src)] has toggled [M.key]'s [blockname] block [state_word]!")
	else
		tgui_alert(usr, "Invalid mob")

ADMIN_VERB(view_runtimes, R_DEBUG|R_VIEWRUNTIMES, "View Runtimes", "Opens the runtime viewer.", ADMIN_CATEGORY_DEBUG)
	GLOB.error_cache.show_to(user.mob)

ADMIN_VERB(allow_browser_inspect, R_DEBUG, "Allow Browser Inspect", "Allow browser debugging via inspect.", ADMIN_CATEGORY_DEBUG)
	if(user.byond_version < 516)
		to_chat(user, span_warning("You can only use this on 516!"))
		return

	to_chat(user, span_notice("You can now right click to use inspect on browsers."))
	winset(user, null, list("browser-options" = "+devtools"))
	winset(user, null, list("browser-options" = "+find"))
	winset(user, null, list("browser-options" = "+refresh"))

ADMIN_VERB(toggle_medal_disable, R_DEBUG, "Toggle Medal Disable", "Toggles the safety lock on trying to contact the medal hub.", ADMIN_CATEGORY_TOGGLES)
	SSachievements.achievements_enabled = !SSachievements.achievements_enabled

	log_and_message_admins("[SSachievements.achievements_enabled? "disabled" : "enabled"] the medal hub lockout.")
	BLACKBOX_LOG_ADMIN_VERB("Toggle Medal Disable")

ADMIN_VERB_VISIBILITY(view_pingstat, ADMIN_VERB_VISIBLITY_FLAG_HOST)
ADMIN_VERB(view_pingstat, R_HOST, "View Pingstat", "Open the Pingstat Report.", ADMIN_CATEGORY_DEBUG)
	var/msg = ""
	var/color
	msg += "<table border='1'><tr>"
	msg += "<th>Player</th>"
	msg += "<th>Quality</th>"
	msg += "<th>Ping</th>"
	msg += "<th>AvgPing</th>"
	msg += "<th>Url</th>"
	msg += "<th>IP</th>"
	msg += "<th>Country</th>"
	msg += "<th>CountryCode</th>"
	msg += "<th>Region</th>"
	msg += "<th>Region Name</th>"
	msg += "<th>City</th>"
	msg += "<th>Timezone</th>"
	msg += "<th>ISP</th>"
	msg += "<th>Mobile</th>"
	msg += "<th>Proxy</th>"
	msg += "<th>Status</th>"

	msg += "</tr>"
	for(var/client/C in GLOB.clients)
		msg += "<tr>"

		msg += "<td>[key_name_admin(C.mob)]</td>"
		color = "rgb([C.lastping], [255 - clamp(text2num(C.lastping), 0, 255)], 0)"
		msg += "<td bgcolor='[color]' >&nbsp;</td>"
		msg += "<td><b>[C.lastping]<b></td>"
		msg += "<td><b>[round(C.avgping,1)]<b></td>"
		msg += "<td>[C.url]</td>"

		if(C.geoip.status != "updated")
			C.geoip.try_update_geoip(C, C.address)
		msg += "<td>[C.geoip.ip]</td>"
		msg += "<td>[C.geoip.country]</td>"
		msg += "<td>[C.geoip.countryCode]</td>"
		msg += "<td>[C.geoip.region]</td>"
		msg += "<td>[C.geoip.regionName]</td>"
		msg += "<td>[C.geoip.city]</td>"
		msg += "<td>[C.geoip.timezone]</td>"
		msg += "<td>[C.geoip.isp]</td>"
		msg += "<td>[C.geoip.mobile]</td>"
		msg += "<td>[C.geoip.proxy]</td>"
		msg += "<td>[C.geoip.status]</td>"

		msg += "</tr>"

	msg += "</table>"
	var/datum/browser/popup = new(user, "pingstat_report", "Pingstat Report", 1500, 600)
	popup.set_content(msg)
	popup.open(FALSE)

ADMIN_VERB(display_overlay_log, R_DEBUG, "Display Overlay Log", "Display SSoverlays log of everything that's passed through it.", ADMIN_CATEGORY_DEBUG)
	render_stats(SSoverlays.stats, user)

ADMIN_VERB(clear_turf_reservations, R_DEBUG, "Clear Dynamic Turf Reservations", "Deallocates all reserved space, restoring it to round start conditions.", ADMIN_CATEGORY_DEBUG)
	var/answer = tgui_alert(user, "WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!", "Really wipe dynamic turfs?", list("YES", "NO"))
	if(answer != "YES")
		return
	log_and_message_admins("cleared dynamic transit space.")
	BLACKBOX_LOG_ADMIN_VERB("CDT")
	SSmapping.wipe_reservations() //this goes after it's logged, incase something horrible happens.

ADMIN_VERB(cmd_reload_polls, R_DEBUG, "Reload Polls", "Reloading all polls.", ADMIN_CATEGORY_DEBUG)
	//This gets a confirmation check because it's way easier to accidentally hit this and delete things than it is with qdel-all
	var/confirm = tgui_alert(user, "This will reload all polls? Consider using it ONLY if polls do stopped working.", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	GLOB.polls.Cut()
	GLOB.poll_options.Cut()
	load_poll_data()

	log_and_message_admins("reloaded polls.")
	BLACKBOX_LOG_ADMIN_VERB("Reload Polls")

ADMIN_VERB(clear_legacy_asset_cache, R_DEBUG, "Clear Legacy Asset Cache", "Clears the legacy asset cache, regenerating it immediately (may cause lag).", ADMIN_CATEGORY_DEBUG)
	if(!CONFIG_GET(flag/cache_assets))
		to_chat(user, span_warning("Asset caching is disabled in the config!"))
		return
	var/regenerated = 0
	for(var/datum/asset/target_spritesheet as anything in subtypesof(/datum/asset))
		if(!initial(target_spritesheet.cross_round_cachable))
			continue
		if(target_spritesheet == initial(target_spritesheet._abstract))
			continue
		var/datum/asset/asset_datum = GLOB.asset_datums[target_spritesheet]
		asset_datum.regenerate()
		regenerated++
	to_chat(user, span_notice("Regenerated [regenerated] asset\s."))

ADMIN_VERB(clear_smart_asset_cache, R_DEBUG, "Clear Smart Asset Cache", "Clear the smart asset cache, causing it to regenerate next round.", ADMIN_CATEGORY_DEBUG)
	if(!CONFIG_GET(flag/smart_cache_assets))
		to_chat(user, span_warning("Smart asset caching is disabled in the config!"))
		return
	var/cleared = 0
	for(var/datum/asset/spritesheet_batched/target_spritesheet as anything in subtypesof(/datum/asset/spritesheet_batched))
		if(target_spritesheet == initial(target_spritesheet._abstract))
			continue
		fdel("[ASSET_CROSS_ROUND_SMART_CACHE_DIRECTORY]/spritesheet_cache.[initial(target_spritesheet.name)].json")
		cleared++
	to_chat(user, span_notice("Cleared [cleared] asset\s."))
