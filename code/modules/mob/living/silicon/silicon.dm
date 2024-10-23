/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	bubble_icon = "machine"
	has_unlimited_silicon_privilege = 1
	weather_immunities = list(TRAIT_WEATHER_IMMUNE)
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
	var/speak_statement = "states"
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

/mob/living/silicon/New()
	GLOB.silicon_mob_list |= src
	..()
	add_language(LANGUAGE_GALACTIC_COMMON)
	init_subsystems()
	RegisterSignal(SSalarm, COMSIG_TRIGGERED_ALARM, PROC_REF(alarm_triggered))
	RegisterSignal(SSalarm, COMSIG_CANCELLED_ALARM, PROC_REF(alarm_cancelled))

/mob/living/silicon/Initialize()
	. = ..()
	var/datum/atom_hud/data/diagnostic/diag_hud = GLOB.huds[DATA_HUD_DIAGNOSTIC]
	diag_hud.add_to_hud(src)
	diag_hud_set_status()
	diag_hud_set_health()

/mob/living/silicon/med_hud_set_health()
	return diag_hud_set_health() //we use a different hud

/mob/living/silicon/med_hud_set_status()
	return diag_hud_set_status() //we use a different hud

/mob/living/silicon/Destroy()
	GLOB.silicon_mob_list -= src
	QDEL_NULL(atmos_control)
	QDEL_NULL(crew_monitor)
	QDEL_NULL(law_manager)
	QDEL_NULL(power_monitor)
	QDEL_NULL(gps)
	QDEL_NULL(blueprints)
	return ..()

/mob/living/silicon/proc/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	return

/mob/living/silicon/proc/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	return

/mob/living/silicon/proc/queueAlarm(message, type, incoming = TRUE)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
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
	if(alarms_to_show.len < 5)
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

		msg += "<A href=?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"
		var/msg_text = msg.Join("")
		to_chat(src, msg_text)

	if(alarms_to_clear.len < 3)
		for(var/msg in alarms_to_clear)
			to_chat(src, msg)

	else if(alarms_to_clear.len)
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

		msg += "<A href=?src=[UID()];showalerts=1'>\[Show Alerts\]</a>"

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

/mob/living/silicon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
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


/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/can_inject(mob/user, error_msg, target_zone, penetrate_thick, ignore_pierceimmune)
	if(error_msg)
		to_chat(user, "<span class='alert'>[p_their(TRUE)] outer shell is too tough.</span>")
	return FALSE

/mob/living/silicon/IsAdvancedToolUser()
	return TRUE


/mob/living/silicon/move_into_vent(obj/machinery/atmospherics/ventcrawl_target, message = TRUE)
	. = ..()
	if(. && inventory_head)
		drop_hat(drop_on_turf = TRUE)
		if(message)
			ventcrawl_target.visible_message("<b>[name] опрокинул шляпу при залезании в вентиляцию!</b>")


/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)

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
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  sanitize(copytext_char(input(usr, "This is [src]. It is...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/silicon/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	update_flavor_text()

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/proc/remove_med_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.remove_hud_from(src)
	secsensor.remove_hud_from(src)
	medsensor.remove_hud_from(src)


/mob/living/silicon/proc/add_sec_hud()
	var/datum/atom_hud/secsensor = GLOB.huds[sec_hud]
	secsensor.add_hud_to(src)

/mob/living/silicon/proc/add_med_hud()
	var/datum/atom_hud/medsensor = GLOB.huds[med_hud]
	medsensor.add_hud_to(src)

/mob/living/silicon/proc/add_diag_hud()
	for(var/datum/atom_hud/data/diagnostic/diagsensor in GLOB.huds)
		diagsensor.add_hud_to(src)


/mob/living/silicon/proc/toggle_sensor_mode()
	var/sensor_type = input("Please select sensor type.", "Sensor Integration", null) in list("Security", "Medical","Diagnostic", "Multisensor","Disable")
	remove_med_sec_hud()
	switch(sensor_type)
		if("Security")
			add_sec_hud()
			to_chat(src, "<span class='notice'>Security records overlay enabled.</span>")
		if("Medical")
			add_med_hud()
			to_chat(src, "<span class='notice'>Life signs monitor overlay enabled.</span>")
		if("Diagnostic")
			add_diag_hud()
			to_chat(src, "<span class='notice'>Robotics diagnostic overlay enabled.</span>")
		if("Multisensor")
			add_sec_hud()
			add_med_hud()
			add_diag_hud()
			to_chat(src, "<span class='notice'>Multisensor overlay enabled.</span>")
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

