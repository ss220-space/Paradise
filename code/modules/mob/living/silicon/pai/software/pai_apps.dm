// Main Menu //
/datum/pai_software/main_menu
	name = "Main Menu"
	id = "mainmenu"
	default = TRUE
	template_file = "pai_main_menu"
	ui_icon = "home"

/datum/pai_software/main_menu/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	data["available_ram"] = user.ram

	// Emotions
	var/list/emotions = list()
	for(var/name in GLOB.base_pai_emotions)
		var/list/emote = list()
		emote["name"] = name
		emote["id"] = GLOB.base_pai_emotions[name]
		emotions[++emotions.len] = emote
	if(pai_holder.syndipai || pai_holder.syndi_emote)
		for(var/name in GLOB.spec_pai_emotions)
			var/list/emote = list()
			emote["name"] = name
			emote["id"] = GLOB.spec_pai_emotions[name]
			emote["syndi"] = TRUE
			emotions[++emotions.len] = emote

	data["emotions"] = emotions
	data["current_emotion"] = user.card.current_emotion

	var/list/available_s = list()
	for(var/s in GLOB.pai_software_by_key)
		var/datum/pai_software/PS = GLOB.pai_software_by_key[s]
		if(!PS.only_syndi || pai_holder.syndipai)
			available_s += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "cost" = PS.ram_cost, "syndi" = PS.only_syndi))

	// Split to installed software and toggles for the UI
	var/list/installed_s = list()
	var/list/installed_t = list()
	for(var/s in pai_holder.installed_software)
		var/datum/pai_software/PS = pai_holder.installed_software[s]
		if(PS.toggle_software)
			installed_t += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon, "active" = PS.is_active(user)))
		else
			installed_s += list(list("name" = PS.name, "key" = PS.id, "icon" = PS.ui_icon))

	data["available_software"] = available_s
	data["installed_software"] = installed_s
	data["installed_toggles"] = installed_t

	return data

/datum/pai_software/main_menu/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("purchaseSoftware")
			var/datum/pai_software/S = GLOB.pai_software_by_key[params["key"]]
			if(S && (pai_holder.ram >= S.ram_cost))
				var/datum/pai_software/newPS = new S.type(pai_holder)
				pai_holder.ram -= newPS.ram_cost
				pai_holder.installed_software[newPS.id] = newPS
		if("setEmotion")
			var/emotion = clamp(text2num(params["emotion"]), 1, 12)
			pai_holder.card.setEmotion(emotion)
		if("startSoftware")
			var/software_key = params["software_key"]
			if(pai_holder.installed_software[software_key])
				pai_holder.active_software = pai_holder.installed_software[software_key]
		if("setToggle")
			var/toggle_key = params["toggle_key"]
			if(pai_holder.installed_software[toggle_key])
				pai_holder.installed_software[toggle_key].toggle(pai_holder)

// Directives //
/datum/pai_software/directives
	name = "Directives"
	id = "directives"
	default = TRUE
	template_file = "pai_directives"
	ui_icon = "clipboard-list"

/datum/pai_software/directives/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["master"] = user.master
	data["dna"] = user.master_dna
	data["prime"] = user.pai_law0
	data["supplemental"] = user.pai_laws

	return data

/datum/pai_software/directives/ui_act(action, list/params)
	if(..())
		return

	. = TRUE

	switch(action)
		if("getdna")
			var/mob/living/M = get_holding_mob()
			if(!istype(M))
				return

			// Check the carrier
			var/answer = tgui_alert(M, "[pai_holder] запрашивает у вас образец ДНК. Предоставить образец для подтверждения вашей личности?", "[pai_holder] запрашивает ДНК", list("Да", "Нет"))
			if(answer == "Да")
				M.visible_message(span_notice("[M] помеща[pluralize_ru(M.gender,"ет","ют")] палец на сканер ДНК."), span_notice("Вы помещаете палец на сканер ДНК."))
				var/datum/dna/dna = M.dna
				to_chat(usr, span_notice("Сканируемый: [M]"))
				to_chat(usr, span_notice("UE код: [dna.unique_enzymes]"))
				if(dna.unique_enzymes == pai_holder.master_dna)
					to_chat(usr, span_notice("<font color=green>ДНК совпадает с записанным ДНК мастера.</font>"))
				else
					to_chat(usr, span_warning("ДНК не совпадает с записанным ДНК мастера!"))
			else
				to_chat(usr, span_warning("[M] отказа[genderize_ru(M.gender,"лся","лась","лось","лись" )] предоставлять вам образец ДНК."))


// Crew Manifest //
/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	ram_cost = 5
	id = "manifest"
	template_file = "pai_manifest"
	ui_icon = "users"

/datum/pai_software/crew_manifest/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	GLOB.data_core.get_manifest_json()
	data["manifest"] = GLOB.PDA_Manifest

	return data

// Med Records //
/datum/pai_software/med_records
	name = "Medical Records"
	ram_cost = 10
	id = "med_records"
	template_file = "pai_medrecords"
	ui_icon = "heartbeat"
	/// Integrated medical records module to reduce duplicated code
	var/datum/data/pda/app/crew_records/medical/integrated_records = new

/datum/pai_software/med_records/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	integrated_records.update_ui(user, data)
	return data

/datum/pai_software/med_records/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.ui_act(action, params, ui, state)

// Sec Records //
/datum/pai_software/sec_records
	name = "Security Records"
	ram_cost = 10
	id = "sec_records"
	template_file = "pai_secrecords"
	ui_icon = "id-badge"
	/// Integrated security records module to reduce duplicated code
	var/datum/data/pda/app/crew_records/security/integrated_records = new

/datum/pai_software/sec_records/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	integrated_records.update_ui(user, data)
	return data

/datum/pai_software/sec_records/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	// Double proxy here
	integrated_records.ui_act(action, params, ui, state)

// Atmos Scan //
/datum/pai_software/atmosphere_sensor
	name = "Atmosphere Sensor"
	ram_cost = 5
	id = "atmos_sense"
	template_file = "pai_atmosphere"
	ui_icon = "fire"
	/// Integrated PDA atmos scan module to reduce duplicated code
	var/datum/data/pda/app/atmos_scanner/scanner = new

/datum/pai_software/atmosphere_sensor/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	// Just grab the stuff internally
	scanner.update_ui(user, data)
	return data

// Messenger //
/datum/pai_software/messenger
	name = "Digital Messenger"
	ram_cost = 5
	id = "messenger"
	template_file = "pai_messenger"
	ui_icon = "envelope"

/datum/pai_software/messenger/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	// Some safety checks
	if(!user.pda)
		CRASH("pAI found without PDA.")

	var/datum/data/pda/app/messenger/PM = user.pda.find_program(/datum/data/pda/app/messenger)
	if(!PM)
		CRASH("pAI PDA lacks a messenger program")

	// Grab the internal data
	PM.update_ui(user, data)

	return data

/datum/pai_software/messenger/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	// Grab their messenger
	var/datum/data/pda/app/messenger/PM = pai_holder.pda.find_program(/datum/data/pda/app/messenger)
	// Double proxy here
	PM.ui_act(action, params, ui, state)

// Radio
/datum/pai_software/radio_config
	name = "Radio Configuration"
	id = "radio"
	default = TRUE
	template_file = "pai_radio"
	ui_icon = "broadcast-tower"

/datum/pai_software/radio_config/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()
	data["frequency"] = user.radio.frequency
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ
	data["broadcasting"] = user.radio.broadcasting
	return data

/datum/pai_software/radio_config/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("toggleBroadcast")
			// Just toggle it
			pai_holder.radio.broadcasting = !pai_holder.radio.broadcasting

		if("freq")
			var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
			pai_holder.radio.set_frequency(new_frequency)

// Signaler //
/datum/pai_software/signaler
	name = "Remote Signaler"
	ram_cost = 5
	id = "signaler"
	template_file = "pai_signaler"
	ui_icon = "rss"

/datum/pai_software/signaler/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["frequency"] = user.sradio.frequency
	data["code"] = user.sradio.code
	data["minFrequency"] = PUBLIC_LOW_FREQ
	data["maxFrequency"] = PUBLIC_HIGH_FREQ

	return data

/datum/pai_software/signaler/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("signal")
			pai_holder.sradio.send_signal("ACTIVATE")

		if("freq")
			var/new_frequency = sanitize_frequency(text2num(params["freq"]) * 10)
			pai_holder.sradio.set_frequency(new_frequency)

		if("code")
			pai_holder.sradio.code = clamp(text2num(params["code"]), 1, 100)

// Door Jack //
/datum/pai_software/door_jack
	name = "Door Jack"
	ram_cost = 30
	id = "door_jack"
	template_file = "pai_doorjack"
	ui_icon = "door-open"
	/// Are we hacking?
	var/hacking = FALSE
	/// The cable being plugged into a door
	var/obj/item/pai_cable/cable
	/// The machine being hacked
	var/obj/machinery/hackmachine
	/// last ai message time (prevent ai spam)
	var/last_message_time

/datum/pai_software/door_jack/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["cable"] = (cable != null)
	data["machine"] = (cable?.machine != null)
	data["inprogress"] = (hackmachine != null)

	return data

/datum/pai_software/door_jack/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("jack")
			if(cable && cable.machine)
				hackmachine = cable.machine
				if(hacking)
					to_chat(usr, span_warning("Вы уже взламываете этот шлюз!"))
				else
					hacking = TRUE
					INVOKE_ASYNC(src, PROC_REF(hackloop))
		if("cancel")
			hackmachine = null
		if("cable")
			if(cable) // Retracting
				pai_holder.visible_message(span_warning("[pai_holder] с быстрым щелчком втягивает кабель в свой корпус."))
				QDEL_NULL(cable)
			else // Extending
				cable = new /obj/item/pai_cable(get_turf(pai_holder))
				var/mob/living/carbon/human/H = get_holding_mob()
				if(H)
					H.put_in_hands(cable)
				pai_holder.visible_message(span_warning("На интелкарте пИИ открывается порт, из которого тут же выпадает кабель."))

/**
  * Door jack hack loop
  *
  * Self-contained proc for handling the hacking of a machinery.
  * Invoked asyncly, but will only allow one instance at a time
  */
/datum/pai_software/door_jack/proc/hackloop()
	if(!is_type_in_list(cable.machine, cable.allowed_types))
		cleanup_hack()
		return
	var/obj/machinery/machinery = cable.machine
	var/hack_time = 10 SECONDS * pai_holder.doorjack_factor
	var/turf/pai_turf = get_turf(pai_holder)
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(!is_station_level(pai_turf.z))
			break
		if(world.time < last_message_time + 100 SECONDS)
			break
		to_chat(AI, span_warning("Несанкционированный взлом от персонального искусственного интеллекта. Локация: ошибка."))
		last_message_time = world.time

	to_chat(pai_holder, span_warning("Начался взлом объекта. Необходимо избегать любого передвижения для сохранения сигнала. Время ожидания: [hack_time/10] секунд."))
	if(!do_after(pai_holder, hack_time, machinery, max_interact_count = 1))
		to_chat(pai_holder, span_notice("Ошибка. Взлом объекта завершён."))
		cleanup_hack()
		return
	if(cable && cable.machine == machinery && cable.machine == hackmachine)
		if(istype(machinery, /obj/machinery/door))
			var/obj/machinery/door/D = machinery
			D.open()
		else if(isapc(machinery))
			var/obj/machinery/power/apc/apc = machinery
			apc.locked = FALSE
			apc.update_icon()
		else if(istype(machinery, /obj/machinery/alarm))
			var/obj/machinery/alarm/alarm = machinery
			alarm.locked = FALSE
		else if(istype(machinery, /obj/machinery/computer/rdconsole))
			var/obj/machinery/computer/rdconsole/rdconsole = machinery
			var/list/current_access = rdconsole.req_access.Copy()
			if(!length(current_access))
				to_chat(pai_holder, span_notice("Консоль уже не имеет доступа."))
				cleanup_hack()
				return
			rdconsole.req_access = list()
			addtimer(VARSET_CALLBACK(rdconsole, req_access, current_access), 180 SECONDS)
	to_chat(pai_holder, span_notice("Взлом завершён."))
	cleanup_hack()

/**
  * Door jack cleanup proc
  *
  * Self-contained proc for cleaning up failed hack attempts
  */
/datum/pai_software/door_jack/proc/cleanup_hack()
	hackmachine = null
	cable.machine = null
	QDEL_NULL(cable)
	hacking = FALSE

// pAI GPS module //
/datum/pai_software/gps
	name = "GPS"
	ram_cost = 10
	id = "pai_gps"
	template_file = "pai_gps_module"
	ui_icon = "location-arrow"


/datum/pai_software/gps/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("ui_interact")
			pai_holder.gps.ui_interact(pai_holder)

// Host Bioscan //
/datum/pai_software/host_scan
	name = "Host Bioscan"
	ram_cost = 10
	id = "bioscan"
	template_file = "pai_bioscan"
	ui_icon = "heartbeat"

/datum/pai_software/host_scan/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	var/mob/living/carbon/human/held = get_holding_mob(FALSE)

	if(!istype(held))
		return data

	data["holder"] = held.name
	data["dead"] = (held.stat > UNCONSCIOUS)
	data["health"] = held.health
	data["brute"] = held.getBruteLoss()
	data["oxy"] = held.getOxyLoss()
	data["tox"] = held.getToxLoss()
	data["burn"] = held.getFireLoss()

	if(held.reagents)
		for(var/datum/reagent/reagent in held.reagents.reagent_list)
			data["reagents"] += list(list("title" = reagent.name, "id" = reagent.id, "volume" = reagent.volume, "overdosed" = reagent.overdosed))
		for(var/datum/reagent/a_reagent in held.reagents.addiction_list)
			data["addictions"] += list(list("addiction_name" = a_reagent.name, "id" = a_reagent.id, "stage" = a_reagent.addiction_stage))

	for(var/name in held.bodyparts_by_name)
		var/obj/item/organ/external/bodypart = held.bodyparts_by_name[name]
		if(data["fractures"] && data["internal_bleeding"])
			break
		if(!bodypart)
			continue
		if(bodypart.has_fracture())
			data["fractures"] = TRUE
		if(bodypart.has_internal_bleeding())
			data["internal_bleeding"] = TRUE

	return data

// Camera Bug //
/datum/pai_software/cam_bug
	name = "Internal Camera Bug"
	ram_cost = 30
	id = "cam_bug"
	ui_icon = "eye"
	template_file = "pai_camera_bug"
	only_syndi = TRUE

/datum/pai_software/cam_bug/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("ui_interact")
			pai_holder.integrated_console.ui_interact(pai_holder)

// Secrete Chemicals (as borer) //
/datum/pai_software/sec_chem
	name = "Special Secrete Chemical"
	ram_cost = 60
	id = "sec_chem"
	ui_icon = "blind"
	template_file = "pai_sec_chem"
	only_syndi = TRUE

/datum/pai_software/sec_chem/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	var/mob/living/held = get_holding_mob(FALSE)

	if(isliving(held))
		data["holder"] = held.name
		data["dead"] = (held.stat > UNCONSCIOUS)
		data["health"] = held.health

	var/list/available_c = list()
	for(var/datum in typesof(/datum/pai_chem))
		var/datum/pai_chem/C = datum
		if(initial(C.chemname))
			available_c += list(list("name" = initial(C.chemname), "key" = initial(C.key), "desc" = initial(C.chemdesc), "cost" = initial(C.chemuse)))

	data["current_chemicals"] = pai_holder.chemicals
	data["available_chemicals"] = available_c
	return data

/datum/pai_software/sec_chem/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("secreteChemicals")
			var/mob/living/held = get_holding_mob(FALSE)
			var/datum/pai_chem/C = null
			for(var/datum in typesof(/datum/pai_chem))
				var/datum/pai_chem/test = datum
				if(initial(test.key) == params["key"])
					C = new test()
					break

			if(!C || !held || !src)
				return

			var/datum/reagent/R = GLOB.chemical_reagents_list[C.key]
			to_chat(pai_holder, span_notice("В кровоток носителя введён синтезированный реагент: \"[R.name]\"."))
			held.reagents.add_reagent(C.key, C.quantity)
			pai_holder.chemicals -= C.chemuse


// Advanced Security Records //
/datum/pai_software/adv_sec_records
	name = "Advanced Security Records"
	ram_cost = 25
	id = "adv_sec_records"
	template_file = "pai_advsecrecords"
	ui_icon = "calendar"
	only_syndi = TRUE

/datum/pai_software/adv_sec_records/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("ui_interact")
			pai_holder.integrated_records.ui_interact(pai_holder)

/datum/pai_software/pai_encoder
	name = "Encoder"
	ram_cost = 5
	id = "pai_encoder"
	template_file = "pai_encoder"
	ui_icon = "key"

/datum/pai_software/pai_encoder/get_app_data(mob/living/silicon/pai/user)
	var/list/data = list()

	data["radio_name"] = pai_holder.radio_name
	data["radio_rank"] = pai_holder.radio_rank

	return data

/datum/pai_software/pai_encoder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	switch(action)
		if("set_newname")
			var/newname = reject_bad_name(params["newname"], TRUE)
			if(newname)
				pai_holder.radio_name = newname

		if("set_newrank")
			var/newrank = reject_bad_name(params["newrank"])
			if(newrank)
				pai_holder.radio_rank = newrank
