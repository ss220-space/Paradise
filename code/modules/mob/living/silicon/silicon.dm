/mob/living/silicon
	voice_name = "synthesized voice"
	bubble_icon = "machine"
	has_unlimited_silicon_privilege = TRUE
	weather_immunities = list(TRAIT_WEATHER_IMMUNE)
	abstract_type = /mob/living/silicon
	looting_icon_mode = LOOT_ICON_FLAT_ICON
	var/syndicate = 0
	var/obj/item/gps/cyborg/gps
	var/const/MAIN_CHANNEL = "Main Frequency"
	var/lawchannel = MAIN_CHANNEL // Default channel on which to state laws
	var/list/stating_laws = list()// Channels laws are currently being stated on
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarms_listend_for = list("Motion", "Fire", "Atmosphere", "Power", "Camera")
	//var/list/hud_list[10]
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/designation = ""
	var/obj/item/camera/siliconcam/aiCamera = null //photography
//Used in say.dm, allows for pAIs to have different say flavor text, as well as silicons, although the latter is not implemented.
	var/speak_statement = "заявляет"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/death_sound = 'sound/voice/borg_deathsound.ogg'

	//var/sensor_mode = 0 //Determines the current HUD.

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD)

	var/med_hud = DATA_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = DATA_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/d_hud = DATA_HUD_DIAGNOSTIC_ADVANCED //There is only one kind of diag hud

	var/obj/item/radio/common_radio

	var/register_alarms = TRUE
	var/datum/ui_module/atmos_control/atmos_control
	var/datum/ui_module/crew_monitor/crew_monitor
	var/datum/ui_module/law_manager/law_manager
	var/datum/ui_module/power_monitor/digital/power_monitor
	var/obj/item/areaeditor/blueprints/cyborg/blueprints

	var/list/silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/proc/subsystem_law_manager
	)

	var/obj/item/inventory_head
	var/list/strippable_inventory_slots = list()

	var/hat_offset_y = -3
	var/isCentered = FALSE //центрирован ли синтетик. Если нет, то шляпа будет растянута

	var/list/blacklisted_hats = list(//Запрещённые шляпы на ношение для боргов с большими головами
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/snowman,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bomb_hood,
		/obj/item/clothing/head/blob,
		/obj/item/clothing/head/chicken,
		/obj/item/clothing/head/corgi,
		/obj/item/clothing/head/cueball,
		/obj/item/clothing/head/hardhat/pumpkinhead,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/papersack,
		/obj/item/clothing/head/human_head,
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/hardhat/reindeer,
		/obj/item/clothing/head/cardborg
	)

	var/hat_icon_file
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/canBeHatted = FALSE
	var/canWearBlacklistedHats = FALSE

	var/datum/ai_laws/laws = null
	var/list/additional_law_channels = list("State" = "")

/mob/living/silicon/Initialize(mapload)
	. = ..()
	GLOB.silicon_mob_list |= src

	add_language(LANGUAGE_GALACTIC_COMMON)

	init_subsystems()

	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_atom_to_hud(src)

	diag_hud_set_status()
	diag_hud_set_health()

	ADD_TRAIT(src, TRAIT_WET_IMMUNITY, INNATE_TRAIT)

	RegisterSignal(GLOB.alarm_manager, COMSIG_TRIGGERED_ALARM, PROC_REF(alarm_triggered))
	RegisterSignal(GLOB.alarm_manager, COMSIG_CANCELLED_ALARM, PROC_REF(alarm_cancelled))

/mob/living/silicon/med_hud_set_health()
	return diag_hud_set_health() //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return diag_hud_set_status() //we use a different hud

/mob/living/silicon/Destroy()
	UnregisterSignal(GLOB.alarm_manager, list(
		COMSIG_TRIGGERED_ALARM,
		COMSIG_CANCELLED_ALARM
	))

	GLOB.silicon_mob_list -= src

	QDEL_NULL(atmos_control)
	QDEL_NULL(crew_monitor)
	QDEL_NULL(law_manager)
	QDEL_NULL(power_monitor)
	QDEL_NULL(gps)
	QDEL_NULL(blueprints)

	return ..()

/mob/living/silicon/proc/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	return

/mob/living/silicon/proc/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = TRUE)
	var/in_cooldown = (length(alarms_to_show) > 0 || length(alarms_to_clear) > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(in_cooldown)
		return

	addtimer(CALLBACK(src, PROC_REF(show_alarms)), 3 SECONDS)

/mob/living/silicon/proc/show_alarms()
	if(length(alarms_to_show) < 5)
		for(var/msg in alarms_to_show)
			to_chat(src, msg)
	else if(length(alarms_to_show))

		var/list/msg = list("--- ")

		if(alarm_types_show["Burglar"])
			msg += "BURGLAR: [alarm_types_show["Burglar"]] alarms detected. - "

		if(alarm_types_show["Motion"])
			msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

		if(alarm_types_show["Fire"])
			msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

		if(alarm_types_show["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

		if(alarm_types_show["Power"])
			msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

		if(alarm_types_show["Camera"])
			msg += "CAMERA: [alarm_types_show["Camera"]] alarms detected. - "

		msg += "<a href=byond://?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"
		var/msg_text = msg.Join("")
		to_chat(src, msg_text)

	if(length(alarms_to_clear) < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(length(alarms_to_clear))
		var/list/msg = list("--- ")

		if(alarm_types_clear["Motion"])
			msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

		if(alarm_types_clear["Fire"])
			msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

		if(alarm_types_clear["Atmosphere"])
			msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

		if(alarm_types_clear["Power"])
			msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

		if(alarm_types_show["Camera"])
			msg += "CAMERA: [alarm_types_clear["Camera"]] alarms cleared. - "

		msg += "<a href=byond://?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"

		var/msg_text = msg.Join("")
		to_chat(src, msg_text)

	alarms_to_show.Cut()
	alarms_to_clear.Cut()
	for(var/key in alarm_types_show)
		alarm_types_show[key] = 0
	for(var/key in alarm_types_clear)
		alarm_types_clear[key] = 0

/mob/living/silicon/rename_character(oldname, newname)
	// we actually don't want it changing minds and stuff
	if(!newname)
		return 0

	real_name = newname
	name = real_name
	return 1

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/drop_from_active_hand(force = FALSE)
	return

/mob/living/silicon/electrocute_act(shock_damage, atom/source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	return FALSE //So borgs they don't die trying to fix wiring

/mob/living/silicon/emp_act(severity)
	..()
	switch(severity)
		if(EMP_HEAVY)
			take_organ_damage(20)
			Stun(16 SECONDS)
		if(EMP_LIGHT)
			take_organ_damage(10)
			Stun(6 SECONDS)
	flash_eyes(3, affect_silicon = TRUE)
	to_chat(src, span_danger("*BZZZT*"))
	to_chat(src, span_warning("Warning: Electromagnetic pulse detected."))

/mob/living/silicon/proc/damage_mob(brute = 0, fire = 0, tox = 0)
	return

/mob/living/silicon/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	if(error_msg)
		to_chat(user, span_alert("[p_their(TRUE)] outer shell is too tough."))
	return FALSE

/mob/living/silicon/IsAdvancedToolUser()
	return TRUE

/mob/living/silicon/move_into_vent(obj/machinery/atmospherics/ventcrawl_target, message = TRUE)
	. = ..()
	if(. && inventory_head)
		drop_hat(drop_on_turf = TRUE)
		if(message)
			ventcrawl_target.visible_message("<b>[name] опрокинул шляпу при залезании в вентиляцию!</b>")

/mob/living/silicon/bullet_act(obj/projectile/Proj)

	Proj.on_hit(src,2)

	if(!Proj.nodamage)
		switch(Proj.damage_type)
			if(BRUTE)
				adjustBruteLoss(Proj.damage)
			if(BURN)
				adjustFireLoss(Proj.damage)

	return 2

/proc/islinked(mob/living/silicon/robot/bot, mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if(bot.connected_ai == ai)
		return 1
	return 0

// this function shows the health of the pAI in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	return list("System integrity:", stat ? "Nonfunctional" : "[round((health / maxHealth) * 100)]%")

// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = show_system_integrity()

//Silicon mob language procs

/mob/living/silicon/can_speak_language(datum/language/speaking)
	return universal_speak || (speaking in speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(language, can_speak = TRUE)
	if(..(language) && can_speak)
		speech_synthesizer_langs.Add(GLOB.all_languages[language])
		return TRUE

/mob/living/silicon/remove_language(language_name)
	..(language_name)

	for(var/datum/language/language in speech_synthesizer_langs)
		if(language.name == language_name)
			speech_synthesizer_langs -= language

/mob/living/silicon/check_lang_data()
	. = ""

	if(default_language)
		. += "Current default language: [default_language] - <a href='byond://?src=[UID()];default_lang=reset'>reset</a><br><br>"

	for(var/datum/language/language in languages)
		if(!(language.flags & NONGLOBAL))
			var/default_str
			if(language == default_language)
				default_str = " - default - <a href='byond://?src=[UID()];default_lang=reset'>reset</a>"
			else
				default_str = " - <a href=\"byond://?src=[UID()];default_lang=[language]\">set default</a>"

			var/synth = (language in speech_synthesizer_langs)
			. += "<b>[language.name] (:[language.key])</b>[synth ? default_str : null]<br>Speech Synthesizer: <i>[synth ? "YES" : "NOT SUPPORTED"]</i><br>[language.desc]<br><br>"

// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	GLOB.generic_crew_manifest.ui_interact(usr)

/mob/living/silicon/assess_threat() //Secbots won't hunt silicon units
	return -10

/mob/living/silicon/verb/pose()
	set name = "Задать позу"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = VERB_CATEGORY_IC

	pose =  tgui_input_text(usr, "This is [src]. It is...", "Pose", null, max_length = MAX_MESSAGE_LEN)

/mob/living/silicon/verb/set_flavor()
	set name = "Описание внешности"
	set desc = "Sets an extended description of your character's features."
	set category = VERB_CATEGORY_IC

	update_flavor_text()

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/proc/remove_med_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.hide_from(src)
	secsensor.hide_from(src)
	medsensor.hide_from(src)

/mob/living/silicon/proc/add_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	secsensor.show_to(src)

/mob/living/silicon/proc/add_med_hud()
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	medsensor.show_to(src)

/mob/living/silicon/proc/add_diag_hud()
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.show_to(src)

/mob/living/silicon/proc/toggle_sensor_mode()
	var/sensor_type = tgui_input_list(usr, "Please select sensor type.", "Sensor Integration", list("Security", "Medical","Diagnostic", "Multisensor","Disable"), null)
	remove_med_sec_hud()
	switch(sensor_type)
		if("Security")
			add_sec_hud()
			to_chat(src, span_notice("Security records overlay enabled."))
		if("Medical")
			add_med_hud()
			to_chat(src, span_notice("Life signs monitor overlay enabled."))
		if("Diagnostic")
			add_diag_hud()
			to_chat(src, span_notice("Robotics diagnostic overlay enabled."))
		if("Multisensor")
			add_sec_hud()
			add_med_hud()
			add_diag_hud()
			to_chat(src, span_notice("Multisensor overlay enabled."))
		if("Disable")
			to_chat(src, "Sensor augmentations disabled.")

/mob/living/silicon/adjustToxLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	return STATUS_UPDATE_NONE

/mob/living/silicon/get_access()
	return IGNORE_ACCESS //silicons always have access

/mob/living/silicon/flash_eyes(intensity = 1, override_blindness_check, affect_silicon, visual, type = /atom/movable/screen/fullscreen/flash/noise)
	if(affect_silicon)
		return ..()

/mob/living/silicon/is_mechanical()
	return 1

/mob/living/silicon/is_literate()
	return 1

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////
/mob/living/silicon/can_hear()
	return TRUE

/mob/living/silicon/put_in_hand_check() // This check is for borgs being able to receive items, not put them in others' hands.
	return FALSE

/mob/living/silicon/on_handsblocked_start()
	return // AIs and borgs have no hands

/mob/living/silicon/on_handsblocked_end()
	return // AIs and borgs have no hands

/mob/living/silicon/on_floored_start()
	return // Silicons are always standing by default.

/mob/living/silicon/on_floored_end()
	return // Silicons are always standing by default.

/mob/living/silicon/on_lying_down()
	return // Silicons are always standing by default.

/mob/living/silicon/on_standing_up()
	return // Silicons are always standing by default.

/mob/living/silicon/throw_impact(atom/hit_atom, throwingdatum, speed = 1)
	. = ..()
	var/damage = 10 + 1.5 * speed
	hit_atom.hit_by_thrown_mob(src, throwingdatum, damage, FALSE, FALSE)
