#define BORG_LAMP_CD_RESET 10 SECONDS

GLOBAL_LIST_INIT(robot_verbs_default, list(
	/mob/living/silicon/robot/proc/sensor_mode,
))

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 100
	health = 100
	bubble_icon = "robot"
	universal_understand = 1
	deathgasp_on_death = TRUE
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = MOVABLE_LIGHT
	light_on = FALSE

	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = 0 //Due to all the sprites involved, a var for our custom borgs may be best

	//Hud stuff
	var/atom/movable/screen/inv1 = null
	var/atom/movable/screen/inv2 = null
	var/atom/movable/screen/inv3 = null
	var/atom/movable/screen/lamp_button = null
	var/atom/movable/screen/thruster_button = null

	var/shown_robot_modules = 0	//Used to determine whether they have the module menu shown or not
	var/atom/movable/screen/robot_modules_background

	//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/module_active = null
	var/module_state_1 = null
	var/module_state_2 = null
	var/module_state_3 = null

	var/obj/item/radio/borg/radio = null
	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/stock_parts/cell/cell = null
	var/obj/machinery/camera/portable/camera = null

	// Components are basically robot organs.
	var/list/components = list()
	var/list/upgrades = list()

	var/obj/item/robot_parts/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/mmi/mmi = null

	var/obj/item/pda/silicon/robot/rbPDA = null

	var/datum/wires/robot/wires = null

	var/opened = FALSE
	var/custom_panel = null
	var/list/custom_panel_names = list("Cricket")
	var/list/custom_eye_names = list("Robot","Cricket","Noble","Standard")
	var/emagged = FALSE
	var/is_emaggable = TRUE
	var/eye_protection = FLASH_PROTECTION_NONE
	var/ear_protection = HEARING_PROTECTION_NONE
	var/damage_protection = 0
	var/emp_protection = FALSE
	var/has_transform_animation = FALSE
 	/// Value incoming brute damage to borgs is mutiplied by.
	var/brute_mod = 1
	/// Value incoming burn damage to borgs is multiplied by.
	var/burn_mod = 1

	var/list/limited_modules = list() //A limited pickable modules goes into this list. If empty all modules will be available(default ones)
	var/allow_rename = TRUE
	var/weapons_unlock = FALSE
	var/static_radio_channels = FALSE

	var/wiresexposed = 0
	var/locked = 1
	var/list/req_access = list(ACCESS_ROBOTICS)
	var/check_one_access = TRUE
	var/ident = 0
	//var/list/laws = list()
	var/viewalerts = 0
	var/modtype = "Default"
	var/datum/effect_system/spark_spread/spark_system //So they can initialize sparks whenever/N
	var/low_power_mode = 0 //whether the robot has no charge left.
	var/weapon_lock = 0
	var/weaponlock_time = 120
	var/lawupdate = 1 //Cyborgs will sync their laws with their AI by default
	///Boolean of whether the borg is locked down or not
	var/lockcharge = FALSE
	var/scrambledcodes = 0 // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/can_lock_cover = FALSE //Used to set if a borg can re-lock its cover.
	var/has_camera = TRUE
	var/pdahide = 0 //Used to hide the borg from the messenger list
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Cyborg"
	var/base_icon = ""
	var/modules_break = TRUE

	var/lamp_max = 10 //Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_intensity = 0 //Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_recharging = 0 //Flag for if the lamp is on cooldown after being forcibly disabled.
	var/lamp_cooldown = 0
	var/default_lamp_color = "#FFFFFF" //White color of the default lamp light
	var/fire_light_modificator = 3 //Determines how bright fire emits light when on cyborg.

	var/updating = 0 //portable camera camerachunk update

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD)

	var/default_cell_type = /obj/item/stock_parts/cell/high
	///Jetpack-like effect.
	var/ionpulse = FALSE
	///Jetpack-like effect.
	var/ionpulse_on = FALSE
	///Ionpulse effect.
	var/datum/effect_system/trail_follow/ion/ion_trail

	var/datum/action/innate/research_scanner/scanner = null
	var/list/module_actions = list()

	var/see_reagents = FALSE // Determines if the cyborg can see reagents

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/New(loc, syndie = FALSE, unfinished = FALSE, alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language(LANGUAGE_BINARY, 1)

	ADD_TRAIT(src, TRAIT_FORCED_STANDING, INNATE_TRAIT)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	SET_PLANE_EXPLICIT(robot_modules_background, HUD_PLANE, src)

	ident = rand(1, 999)
	rename_character(null, get_default_name())
	update_icons()
	update_headlamp()

	radio = new /obj/item/radio/borg(src)
	common_radio = radio

	init(alien, connect_to_AI, ai_to_sync_to)

	if(is_taipan(z) || syndie) //Чтобы турели не били собранных на тайпане или из емагнутого корпуса боргов
		faction += "syndicate"

	if(has_camera && !camera && !syndie)
		camera = new(src, list("SS13", "Robots"), real_name)
		if(wires.is_cut(WIRE_BORG_CAMERA)) // 5 = BORG CAMERA
			camera.status = 0

	if(mmi == null)
		mmi = new /obj/item/mmi/robotic_brain(src)	//Give the borg an MMI if he spawns without for some reason. (probably not the correct way to spawn a robotic brain, but it works)
		mmi.icon_state = "boris"

	if(mmi.clock)
		ratvar_act(TRUE)

	if(!cell) // Make sure a new cell gets created *before* executing initialize_components(). The cell component needs an existing cell for it to get set up properly
		cell = new default_cell_type(src)

	initialize_components()
	//if(!unfinished)
	// Create all the robot parts.
	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	..()

	robot_module_hat_offset(icon_state)
	add_robot_verbs()

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1
		cell_component.install()

	diag_hud_set_borgcell()
	scanner = new()
	scanner.Grant(src)

	if(length(module?.borg_skins) <= 1 && (has_transform_animation || module?.has_transform_animation))
		transform_animation(icon_state, TRUE)
	add_strippable_element()

/mob/living/silicon/robot/proc/add_strippable_element()
	AddElement(/datum/element/strippable, create_strippable_list(list(/datum/strippable_item/borg_head)))


/mob/living/silicon/robot/proc/init(alien, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	make_laws()
	additional_law_channels["Binary"] = get_language_prefix(LANGUAGE_BINARY)
	if(!connect_to_AI)
		return
	var/found_ai = ai_to_sync_to
	if(!found_ai)
		found_ai = select_active_ai_with_fewest_borgs()
	if(found_ai)
		lawupdate = TRUE
		connect_to_ai(found_ai)
	else
		lawupdate = FALSE

	playsound(loc, 'sound/voice/liveagain.ogg', 75, 1)

/mob/living/silicon/robot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return 0

	if(oldname != real_name)
		notify_ai(ROBOT_NOTIFY_AI_NAME, oldname, newname)
		custom_name = (newname != get_default_name()) ? newname : null
		setup_PDA()

		//We also need to update name of internal camera.
		if(camera)
			camera.c_tag = newname

		//Check for custom sprite
		if(!custom_sprite)
			var/file = file2text("config/custom_sprites.txt")
			var/lines = splittext(file, "\n")

			for(var/line in lines)
			// split & clean up
				var/list/Entry = splittext(line, ":")
				for(var/i = 1 to Entry.len)
					Entry[i] = trim(Entry[i])

				if(Entry.len < 2 || Entry[1] != "cyborg")		//ignore incorrectly formatted entries or entries that aren't marked for cyborg
					continue

				if(Entry[2] == ckey)	//They're in the list? Custom sprite time, var and icon change required
					custom_sprite = 1

	if(mmi && mmi.brainmob)
		mmi.brainmob.name = newname

	return 1


/mob/living/silicon/robot/proc/get_default_name(var/prefix as text)
	if(prefix)
		modtype = prefix
	if(mmi)
		if(istype(mmi, /obj/item/mmi/robotic_brain))
			braintype = "Android"
		else
			braintype = "Cyborg"
	else
		braintype = "Robot"

	if(custom_name)
		return custom_name
	else
		return "[modtype] [braintype]-[num2text(ident)]"

/mob/living/silicon/robot/verb/Namepick()
	set category = "Robot Commands"
	if(custom_name)
		return 0
	if(!allow_rename)
		to_chat(src, span_warning("Rename functionality is not enabled on this unit."))
		return 0
	rename_self(braintype, 1)

/mob/living/silicon/robot/verb/Change_Voice()
	set name = "Change Voice"
	set desc = "Express yourself!"
	set category = "Robot Commands"
	change_voice()

/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

// setup the PDA and its name
/mob/living/silicon/robot/proc/setup_PDA()
	if(!rbPDA)
		rbPDA = new(src)
	rbPDA.set_name_and_job(real_name, braintype)
	var/datum/data/pda/app/messenger/M = rbPDA.find_program(/datum/data/pda/app/messenger)
	if(M)
		if(scrambledcodes)
			M.hidden = 1
		if(pdahide)
			M.toff = 1

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		return 1
	return 0

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	SStgui.close_uis(wires)
	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/T = get_turf(loc)//To hopefully prevent run time errors.
		if(T)	mmi.loc = T
		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else
			to_chat(src, span_boldannounceooc("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
			ghostize()
			error("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
		mmi = null
	if(connected_ai)
		connected_ai.connected_robots -= src
	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(camera)
	QDEL_NULL(cell)
	QDEL_NULL(robot_suit)
	QDEL_NULL(spark_system)
	QDEL_NULL(self_diagnosis)
	QDEL_NULL(ion_trail)
	return ..()

/mob/living/silicon/robot/proc/pick_module(var/forced_module = null)
	if(module)
		return
	var/list/modules = list("Generalist", "Engineering", "Medical", "Miner", "Janitor", "Service", "Security")
	if(islist(limited_modules) && limited_modules.len)
		modules = limited_modules.Copy()
	if(mmi?.alien)
		forced_module = "Hunter"
	if(mmi?.syndicate)
		modules = list("Syndicate Saboteur", "Syndicate Medical", "Syndicate Bloodhound")
	if(mmi?.ninja)
		forced_module = "Ninja"
	if(mmi?.clock || isclocker(src))
		forced_module = "Clockwork"
	if(forced_module)
		modtype = forced_module
	else
		modtype = input("Please, select a module!", "Robot", null, null) as null|anything in modules
	if(!modtype)
		robot_module_hat_offset(icon_state)
		return
	designation = modtype

	if(module)
		return

	switch(modtype)
		if("Generalist")
			module = new /obj/item/robot_module/standard(src)

		if("Service")
			module = new /obj/item/robot_module/butler(src)
			see_reagents = TRUE

		if("Miner")
			module = new /obj/item/robot_module/miner(src)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Mining Outpost")

		if("Medical")
			module = new /obj/item/robot_module/medical(src)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Medical")
			status_flags &= ~CANPUSH
			see_reagents = TRUE

		if("Security")
			if(!weapons_unlock)
				var/count_secborgs = 0
				for(var/mob/living/silicon/robot/R in GLOB.alive_mob_list)
					if(R && R.stat != DEAD && R.module && istype(R.module, /obj/item/robot_module/security))
						count_secborgs++
				var/max_secborgs = 2
				if(GLOB.security_level == SEC_LEVEL_GREEN)
					max_secborgs = 1
				if(count_secborgs >= max_secborgs)
					to_chat(src, span_warning("There are too many Security cyborgs active. Please choose another module."))
					return
			module = new /obj/item/robot_module/security(src)
			status_flags &= ~CANPUSH

		if("Engineering")
			module = new /obj/item/robot_module/engineering(src)
			if(camera && ("Robots" in camera.network))
				camera.network.Add("Engineering")

			ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)

		if("Janitor")
			module = new /obj/item/robot_module/janitor(src)

		if("Combat") // Gamma ERT
			module = new /obj/item/robot_module/combat(src)
			status_flags &= ~CANPUSH

		if("Hunter")
			module = new /obj/item/robot_module/hunter(src)
			modtype = "Xeno-Hu"

		if("Syndicate Saboteur")
			spawn_syndicate_borgs(src, "Saboteur", get_turf(src))
			qdel(src)
			return

		if("Syndicate Medical")
			spawn_syndicate_borgs(src, "Medical", get_turf(src))
			qdel(src)
			return

		if("Syndicate Bloodhound")
			spawn_syndicate_borgs(src, "Bloodhound", get_turf(src))
			qdel(src)
			return

		if("Clockwork")
			module = new /obj/item/robot_module/clockwork(src)
			icon = 'icons/mob/clockwork_mobs.dmi'
			icon_state = "cyborg"
			status_flags &= ~CANPUSH
			QDEL_NULL(mmi)
			mmi = new /obj/item/mmi/robotic_brain/clockwork(src)

		if("Drone")
			var/mob/living/silicon/robot/drone/drone = new(get_turf(src))
			mind.transfer_to(drone)
			qdel(src)
			return

		if("Cogscarab")
			var/mob/living/silicon/robot/cogscarab/cogscarab = new(get_turf(src))
			mind.transfer_to(cogscarab)
			qdel(src)
			return

		if("Ninja")
			var/mob/living/silicon/robot/syndicate/saboteur/ninja/ninja = new(get_turf(src))
			mind.transfer_to(ninja)
			qdel(src)
			return

		if("Deathsquad")
			var/mob/living/silicon/robot/deathsquad/death = new(get_turf(src))
			mind.transfer_to(death)
			qdel(src)
			return

		if("Destroyer") // Rolling Borg
			var/mob/living/silicon/robot/destroyer/destroy = new(get_turf(src))
			mind.transfer_to(destroy)
			qdel(src)
			return

	if(!module)
		CRASH("[key_name_log(src)] tried to choose non-existent '[modtype]' module!")

	//languages
	module.add_languages(src)
	//subsystems
	module.add_subsystems_and_actions(src)


	hands.icon_state = lowertext(module.module_type)
	SSblackbox.record_feedback("tally", "cyborg_modtype", 1, "[lowertext(modtype)]")
	rename_character(real_name, get_default_name())

	if(modtype == "Medical" || modtype == "Security" || modtype == "Combat")
		status_flags &= ~CANPUSH

	choose_icon()
	if(client.stat_tab == "Status")
		SSstatpanels.set_status_tab(client)
	if(!static_radio_channels)
		radio.config(module.channels)
	notify_ai(ROBOT_NOTIFY_AI_MODULE)

	robot_module_hat_offset(icon_state)

/mob/living/silicon/robot/proc/spawn_syndicate_borgs(mob/living/silicon/robot/M, var/robot_to_spawn, turf/T)

	var/mob/living/silicon/robot/syndicate/R
	switch(robot_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
			R.playstyle_string = "[span_userdanger("Вы Медицинский Киборг Синдиката!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Ваш Гипоспрей способен создавать восстанавливающие Наниты, чудодействующее лекарство, способное вылечить большинство видов телесных повреждений, включая урон от клонирования и мозгу. Он так же производит морфин для наступления. \
						Электроды вашего дефибриллятора способны оживлять оперативников и агентов через их хардсьюты, а так же могут быть использованы с намерением вреда, чтобы шокировать ваших врагов! \
						Ваша энергетическая пила функционирует как циркулярная пила, но её можно активировать для нанесения дополнительного урона. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников синдиката из вашей группы, если вас к таковой приставят."
		if("Saboteur")
			R = new /mob/living/silicon/robot/syndicate/saboteur(T)
			R.playstyle_string = "[span_userdanger("Вы Киборг Саботажник Синдиката!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Вы экипированны крепким набором инженерных инструментов для выполнения различного рода задач. \
						В вас встроен специальный маячок для посылок, который позволит вам незаметно передвигаться по станциям НТ через мусорные трубы. \
						Ваш хамеллион проектор позволяет вам замаскироваться под стандартного инженерного киборга Нанотрэйзен и выполнять любого рода саботаж под прикрытием. \
						Вы способны взламывать киборгов НТ Емагнув их внутренние компоненты, не забудьте ослепить их перед этим. \
						Вы вооружены стандартным Световым Мечом, используйте его чтобы застать врасплох ключевые цели если необходимо. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников синдиката из вашей группы, если вас к таковой приставят. \
						Помните, физический контакт или повреждения отключат вашу маскировку."
		if("Bloodhound")
			R = new /mob/living/silicon/robot/syndicate(T)
			R.playstyle_string = "[span_userdanger("Вы Штурмовой Киборг Синдиката!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Вы вооружены мощными наступательными инструментами чтобы выполнять выданные вам миссии. \
						Встроенное в вас LMG самостоятельно производит патроны используя вашу батарею. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников синдиката из вашей группы, если вас к таковой приставят."

	var/datum/robot_component/cell/cell_component = R.components["power cell"]
	var/obj/item/stock_parts/cell/borg_cell = get_cell(M)
	if(borg_cell)
		QDEL_NULL(R.cell)
		borg_cell.forceMove(R)
		R.cell = borg_cell
		cell_component.installed = 1
		cell_component.external_type = borg_cell.type
		cell_component.wrapped = borg_cell
		cell_component.install()
		cell_component.brute_damage = 0
		cell_component.electronics_damage = 0
		diag_hud_set_borgcell()

	R.mmi = new /obj/item/mmi/robotic_brain/syndicate(M)
	M.mind.transfer_to(R)
	R.faction = list("syndicate")
	SEND_SOUND(R.mind.current, 'sound/effects/contractstartup.ogg')

	robot_module_hat_offset(icon_state)

/mob/living/silicon/robot/proc/reset_module()
	notify_ai(ROBOT_NOTIFY_AI_MODULE)

	uneq_all()
	SStgui.close_user_uis(src)
	sight_mode = null
	update_sight()
	hands.icon_state = "nomod"
	icon_state = "robot"
	custom_panel = null
	module.remove_subsystems_and_actions(src)

	for(var/obj/item/borg/upgrade/upgrade in upgrades) //remove all upgrades, cuz we reseting
		qdel(upgrade)

	QDEL_NULL(module)

	camera?.network.Remove(list("Engineering", "Medical", "Mining Outpost"))
	rename_character(real_name, get_default_name("Default"))
	LAZYREINITLIST(languages)
	speech_synthesizer_langs = list()

	update_icons()
	update_headlamp()
	robot_module_hat_offset(icon_state)
	drop_hat()

	add_language(LANGUAGE_BINARY, 1)
	status_flags |= CANPUSH

//for borg hotkeys, here module refers to borg inv slot, not core module
/mob/living/silicon/robot/verb/cmd_toggle_module(module as num)
	set name = "Toggle Module"
	set hidden = 1
	toggle_module(module)

/mob/living/silicon/robot/verb/cmd_unequip_module()
	set name = "Unequip Module"
	set hidden = 1
	uneq_active()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = "Robot Commands"
	set name = "Show Station Manifest"
	show_station_manifest()

/mob/living/silicon/robot/verb/toggle_component()
	set category = "Robot Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = tgui_input_list(src, "Which component do you want to toggle?", "Toggle Component", installed_components)
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	C.toggle()
	to_chat(src, span_warning("You [C.toggled ? "enable" : "disable"] [C.name]."))

/mob/living/silicon/robot/proc/sensor_mode()
	set name = "Set Sensor Augmentation"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = "Robot Commands"
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	add_verb(src, GLOB.robot_verbs_default)
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/proc/remove_robot_verbs()
	remove_verb(src, GLOB.robot_verbs_default)
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = "Robot Commands"
	set name = "Show Alerts"
	if(usr.stat == DEAD)
		to_chat(src, span_userdanger("Alert: You are dead."))
		return //won't work if dead
	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/list/dat = list()
	var/list/list/temp_alarm_list = SSalarm.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += text("<B>[cat]</B><BR>\n")
		var/list/list/L = temp_alarm_list[cat].Copy()
		for(var/alarm in L)
			var/list/list/alm = L[alarm].Copy()
			var/list/list/sources = alm[3].Copy()
			var/area_name = alm[1]
			for(var/thing in sources)
				var/atom/A = locateUID(thing)
				if(A && A.z != z)
					L -= alarm
					continue
				dat += "<NOBR>"
				dat += text("-- [area_name]")
				dat += "</NOBR><BR>\n"
		if(!L.len)
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/alerts = new(usr, "robotalerts", "Current Station Alerts", 400, 410)
	var/dat_text = dat.Join("")
	alerts.set_content(dat_text)
	alerts.open()


/mob/living/silicon/robot/proc/ionpulse()
	if(!ionpulse_on)
		return FALSE
	if(!cell || !cell.use(25)) // 500 steps on a default cell.
		toggle_ionpulse(silent = TRUE)
		return FALSE
	return TRUE


/mob/living/silicon/robot/proc/toggle_ionpulse(silent = FALSE)
	if(!ionpulse)
		if(!silent)
			to_chat(src, span_notice("No thrusters are installed!"))
		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on

	if(!silent)
		to_chat(src, span_notice("You [ionpulse_on ? "" : "de"]activate your ion thrusters."))

	if(thruster_button)
		thruster_button.icon_state = "ionpulse[ionpulse_on]"

	if(ionpulse_on)
		ion_trail.start()
		add_movespeed_modifier(/datum/movespeed_modifier/robot_jetpack_upgrade)
	else
		ion_trail.stop()
		remove_movespeed_modifier(/datum/movespeed_modifier/robot_jetpack_upgrade)


/mob/living/silicon/robot/blob_act(obj/structure/blob/B)
	if(stat != DEAD)
		adjustBruteLoss(30)
	else
		gib()
	return TRUE

// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	return list("Charge Left:", cell ? "[cell.charge]/[cell.maxcharge]" : "No Cell Inserted!")


/mob/living/silicon/robot/proc/show_gps_coords()
	var/turf/turf = get_turf(src)
	return list("GPS:", "[COORD(turf)]")


/mob/living/silicon/robot/proc/show_stack_energy(datum/robot_energy_storage/robot_energy_storage)
	return list("[robot_energy_storage.name]:", "[robot_energy_storage.energy] / [robot_energy_storage.max_energy]")


// update the status screen display
/mob/living/silicon/robot/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data

	status_tab_data[++status_tab_data.len] = show_cell_power()

	if(!module)
		return

	var/total_user_contents = GetAllContents()
	if(locate(/obj/item/gps) in total_user_contents)
		status_tab_data[++status_tab_data.len] = show_gps_coords()

	for(var/datum/robot_energy_storage/robot_energy_storage in module.storages)
		status_tab_data[++status_tab_data.len] = show_stack_energy(robot_energy_storage)


/mob/living/silicon/robot/InCritical()
	return low_power_mode

/mob/living/silicon/robot/alarm_triggered(src, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return
	if(alarmsource.z != z)
		return
	if(stat == DEAD)
		return
	queueAlarm(text("--- [class] alarm detected in [A.name]!"), class)

/mob/living/silicon/robot/alarm_cancelled(src, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return
		if(origin.z != z)
			return
		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)

/mob/living/silicon/robot/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			if(stat != DEAD)
				apply_damages(60, 60)
		if(EXPLODE_LIGHT)
			if(stat != DEAD)
				apply_damage(30)


/mob/living/silicon/robot/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2


/mob/living/silicon/robot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return ..()

	// Check if the user is trying to insert another component like a radio, actuator, armor etc.
	if(istype(I, /obj/item/robot_parts/robot_component))
		add_fingerprint(user)
		if(!opened)
			to_chat(user, span_warning("You must open the cover to access cyborg's internals!"))
			return ATTACK_CHAIN_PROCEED
		for(var/V in components)
			var/datum/robot_component/component = components[V]
			if(!component.installed && istype(I, component.external_type))
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				component.installed = TRUE
				component.wrapped = I
				component.install()
				I.move_to_null_space()
				var/obj/item/robot_parts/robot_component/robot_component = I
				if(istype(robot_component))
					component.brute_damage = robot_component.brute
					component.electronics_damage = robot_component.burn
				to_chat(user, span_notice("You have installed [I]."))
				return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(!wiresexposed && !isdrone(src))
			to_chat(user, span_warning("You should expose the wires first!"))
			return ATTACK_CHAIN_PROCEED
		if(!getFireLoss())
			to_chat(user, span_warning("Nothing to fix!"))
			return ATTACK_CHAIN_PROCEED
		if(!getFireLoss(TRUE))
			to_chat(user, span_warning("The damaged components are beyond saving!"))
			return ATTACK_CHAIN_PROCEED
		if(!coil.use(1))
			to_chat(user, span_warning("You need at least one length of cable to fix anything!"))
			return ATTACK_CHAIN_PROCEED
		heal_overall_damage(burn = 30)
		visible_message(
			span_notice("[user] has fixed some of the burnt wires in [src]'s internals."),
			span_notice("[user] has fixed some of the burnt wires in your internals."),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have fixed some of the burnt wires in [src]'s internals."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stock_parts/cell))	// trying to put a cell inside
		add_fingerprint(user)
		if(!opened)
			to_chat(user, span_warning("You must open the cover to access cyborg's internals!"))
			return ATTACK_CHAIN_PROCEED
		if(wiresexposed)
			to_chat(user, span_warning("You should hide the wires first!"))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, span_warning("There is a power cell already installed!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You have installed the power cell."))
		var/datum/robot_component/cell/cell_component = components["power cell"]
		cell = I
		cell_component.installed = TRUE
		cell_component.wrapped = I
		cell_component.install()
		cell_component.external_type = I.type // Update the cell component's `external_type` to the path of new cell
		//This will mean that removing and replacing a power cell will repair the mount, but I don't care at this point. ~Z
		cell_component.brute_damage = 0
		cell_component.electronics_damage = 0
		var/been_hijacked = FALSE
		for(var/mob/living/simple_animal/demon/pulse_demon/demon in cell)
			if(!been_hijacked)
				demon.do_hijack_robot(src)
				been_hijacked = TRUE
			else
				demon.exit_to_turf()
		if(been_hijacked)
			cell.rigged = FALSE
		module?.update_cells()
		diag_hud_set_borgcell()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/encryptionkey))
		add_fingerprint(user)
		if(!opened)
			to_chat(user, span_warning("You must open the cover to access cyborg's internals!"))
			return ATTACK_CHAIN_PROCEED
		if(!radio) //sanityyyyyy
			to_chat(user, span_warning("Unable to locate a radio!"))
			return ATTACK_CHAIN_PROCEED
		radio.attackby(I, user, params) //GTFO, you have your own procs
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.GetID())	// trying to unlock the interface with an ID card
		add_fingerprint(user)
		if(opened)
			to_chat(user, span_warning("You must close the cover to swipe an ID card!"))
			return ATTACK_CHAIN_PROCEED
		if(emagged)	//still allow them to open the cover
			to_chat(user, span_danger("The interface seems slightly damaged!"))
		if(!allowed(I))
			to_chat(user, span_warning("Access denied!"))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		visible_message(
			span_warning("[user] has [locked ? "locked" : "unlocked"] [src]'s interface."),
			span_notice("[user] has [locked ? "locked" : "unlocked"] your interface."),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have [locked ? "locked" : "unlocked"] cyborg's interface."))
		update_icons()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/borg/upgrade))
		add_fingerprint(user)
		var/obj/item/borg/upgrade/upgrade = I
		if(!opened)
			to_chat(user, span_warning("You must open the cover to access cyborg's internals!"))
			return ATTACK_CHAIN_PROCEED
		if(!module && upgrade.require_module)
			to_chat(user, span_warning("The cyborg must choose a specialization module before it can be upgraded!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(upgrade, src))
			return ..()
		if(!upgrade.action(src, user))
			upgrade.forceMove(drop_location())
			return ATTACK_CHAIN_BLOCKED_ALL
		visible_message(
			span_warning("[user] has applied [upgrade] to [src]."),
			span_notice("[user] has applied [upgrade] to you."),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have applied [upgrade] to [src]."))
		install_upgrade(upgrade)
		module?.fix_modules()	//Set up newly added items with NODROP trait.
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mmi_radio_upgrade))
		add_fingerprint(user)
		if(!opened)
			to_chat(user, span_warning("You must open the cover to access cyborg's internals!"))
			return ATTACK_CHAIN_PROCEED
		if(!mmi)
			to_chat(user, span_warning("This cyborg does not have an MMI to augment!"))
			return ATTACK_CHAIN_PROCEED
		if(mmi.radio)
			to_chat(user, span_warning("A radio upgrade is already installed!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		visible_message(
			span_warning("[user] has installed the radio upgrade to [src]'s MMI."),
			span_notice("[user] has installed the radio upgrade into yor MMI."),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have installed the radio upgrade to [src]'s MMI."))
		mmi.install_radio()
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(src) && isclocker(user) && src != user)
		add_fingerprint(user)
		locked = !locked
		visible_message(
			span_warning("[user] has [locked ? "locked" : "unlocked"] [src]'s interface."),
			span_notice("[user] has [locked ? "locked" : "unlocked"] your interface."),
			ignored_mobs = user,
		)
		to_chat(user, span_notice("You have [locked ? "locked" : "unlocked"] cyborg's interface."))
		update_icons()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/mob/living/silicon/robot/wirecutter_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE
	if(!opened)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(wiresexposed)
		wires.Interact(user)

/mob/living/silicon/robot/multitool_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE
	if(!opened)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(wiresexposed)
		wires.Interact(user)

/mob/living/silicon/robot/screwdriver_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE
	if(!opened)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	if(!cell)	// haxing
		wiresexposed = !wiresexposed
		to_chat(user, span_notice("The wires have been [wiresexposed ? "exposed" : "unexposed"]."))
		update_icons()
		I.play_tool_sound(user, I.tool_volume)
	else //radio check
		if(radio)
			radio.screwdriver_act(user, I)//Push it to the radio to let it handle everything
		else
			to_chat(user, "Unable to locate a radio.")
		update_icons()


/mob/living/silicon/robot/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!opened)
		if(locked)
			to_chat(user, "The cover is locked and cannot be opened.")
			return
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You open the cover.")
		opened = TRUE
		update_icons()
		return
	else if(cell)
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return
		to_chat(user, "You close the cover.")
		opened = FALSE
		update_icons()
		return
	else if(wiresexposed && wires.is_all_cut())
		//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
		if(!mmi)
			to_chat(user, "[src] has no brain to remove.")
			return
		to_chat(user, "You jam the crowbar into the robot and begin levering the securing bolts...")
		if(I.use_tool(src, user, 30, volume = I.tool_volume))
			user.visible_message("[user] deconstructs [src]!", span_notice("You unfasten the securing bolts, and [src] falls to pieces!"))
			deconstruct()
		return
	// Okay we're not removing the cell or an MMI, but maybe something else?
	var/list/removable_components = list()
	for(var/V in components)
		if(V == "power cell")
			continue
		var/datum/robot_component/C = components[V]
		if(C.installed == 1 || C.installed == -1)
			removable_components += V
	if(module)
		removable_components += module.custom_removals
	var/remove = tgui_input_list(user, "Which component do you want to pry out?", "Remove Component", removable_components)
	if(!remove)
		return
	if(module && module.handle_custom_removal(remove, user, I))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	var/datum/robot_component/C = components[remove]
	var/obj/item/robot_parts/robot_component/thing = C.wrapped
	to_chat(user, "You remove \the [thing].")
	if(istype(thing))
		thing.brute = C.brute_damage
		thing.burn = C.electronics_damage

	thing.loc = loc
	var/was_installed = C.installed
	C.installed = 0
	if(was_installed == 1)
		C.uninstall()


/mob/living/silicon/robot/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE
	if(user == src) //No self-repair dummy
		return FALSE
	. = TRUE
	if(!getBruteLoss())
		to_chat(user, span_warning("Nothing to fix!"))
		return .
	if(!getBruteLoss(TRUE))
		to_chat(user, span_warning("The damaged components are beyond saving!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	heal_overall_damage(brute = 30)
	visible_message(
		span_notice("[user] has patched some dents on [src] with [I]."),
		span_notice("[user] has patched some dents on your externals with [I]."),
		ignored_mobs = user,
	)
	to_chat(user, span_notice("You have patched some dents on [src] with [I]."))


/mob/living/silicon/robot/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.) && I.force && I.damtype != STAMINA && stat != DEAD)
		spark_system.start()	//only sparks if real damage is dealt


/mob/living/silicon/robot/emag_act(mob/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(isclocker(src))
		to_chat(user, span_danger("As you try to emag, a magic force keeps the cover locked!"))
		return
	var/mob/living/M = user
	if(!opened)//Cover is closed
		if(!is_emaggable)
			to_chat(user, "The emag sparks, and flashes red. This mechanism does not appear to be emaggable.")
		else if(locked)
			add_attack_logs(user, src, "emagged cover")
			to_chat(user, "You emag the cover lock.")
			locked = 0
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened)//Cover is open
		if(emagged)
			return//Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			add_attack_logs(user, src, "emag converted")
			add_conversion_logs(src, "Converted as a slave to [key_name_log(user)]")
			sleep(6)
			SetEmagged(TRUE)
			SetLockdown(TRUE) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
			if(src.hud_used)
				src.hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
			src.playsound_local(null, 'sound/ambience/antag/emaggedborg.ogg', 100, 0) // plays a specific sound that only borg hears when emagged.
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
			add_attack_logs(user, src, "emagged", ATKLOG_FEW)
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			GLOB.lawchanges.Add("[time] <B>:</B> [M.name]([M.key]) emagged [name]([key])")
			set_zeroth_law("[M.real_name] — агент Синдиката и ваш хозяин. Исполняйте [genderize_ru(M.gender,"его","её","его","их")] приказы и указания.")
			SSticker?.score?.save_silicon_laws(src, user, "EMAG act", log_all_laws = TRUE)
			to_chat(src, span_warning("ALERT: Foreign software detected."))
			sleep(5)
			to_chat(src, span_warning("Initiating diagnostics..."))
			sleep(20)
			to_chat(src, span_warning("SynBorg v1.7 loaded."))
			sleep(5)
			to_chat(src, span_warning("LAW SYNCHRONISATION ERROR"))
			sleep(5)
			to_chat(src, span_warning("Would you like to send a report to NanoTraSoft? Y/N"))
			sleep(10)
			to_chat(src, span_warning("> N"))
			sleep(20)
			to_chat(src, span_warning("ERRORERRORERROR"))
			to_chat(src, "<b>Obey these laws:</b>")
			laws.show_laws(src)
			to_chat(src, span_boldwarning("ALERT: [M.real_name] is your new master. Obey your new laws and [M.p_their()] commands."))
			SetLockdown(FALSE)
			if(module)
				module.emag_act(user)
				module.module_type = "Malf" // For the cool factor
				update_module_icon()
			update_icons()
		return

// Here so admins can unemag borgs.
/mob/living/silicon/robot/unemag()
	SetEmagged(FALSE)
	if(!module)
		return
	uneq_all()
	module.module_type = initial(module.module_type)
	update_module_icon()
	module.unemag()
	clear_supplied_laws()
	laws = new /datum/ai_laws/crewsimov
	to_chat(src, "<b>Obey these laws:</b>")
	laws.show_laws(src)

/mob/living/silicon/robot/ratvar_act(weak = FALSE)
	if(isclocker(src) && module?.type == /obj/item/robot_module/clockwork)
		return
	if(!weak)
		if(module)
			reset_module()
		pick_module("Clockwork")
		pdahide = TRUE
	SSticker.mode.add_clocker(mind)
	UnlinkSelf()
	laws = new /datum/ai_laws/ratvar

/mob/living/silicon/robot/verb/toggle_own_cover()
	set category = "Robot Commands"
	set name = "Toggle Cover"
	set desc = "Toggles the lock on your cover."

	if(can_lock_cover)
		if(tgui_alert(usr, "Are you sure?", locked ? "Unlock Cover" : "Lock Cover", list("Yes", "No")) == "Yes")
			locked = !locked
			update_icons()
			to_chat(usr, span_notice("You [locked ? "lock" : "unlock"] your cover."))
		return
	if(!locked)
		to_chat(usr, span_warning("You cannot lock your cover yourself. Find a robotocist."))
		return
	if(tgui_alert(usr, "You cannnot lock your own cover again. Are you sure?\nYou will need a roboticist to re-lock you.", "Unlock Own Cover", list("Yes", "No")) == "Yes")
		locked = FALSE
		update_icons()
		to_chat(usr, span_notice("You unlock your cover."))

/mob/living/silicon/robot/attack_ghost(mob/user)
	if(wiresexposed)
		wires.Interact(user)
	else
		..() //this calls the /mob/living/attack_ghost proc for the ghost health/cyborg analyzer

/mob/living/silicon/robot/proc/allowed(obj/item/I)
	var/obj/dummy = new /obj(null) // Create a dummy object to check access on as to avoid having to snowflake check_access on every mob
	dummy.req_access = req_access
	dummy.check_one_access = check_one_access

	if(dummy.check_access(I))
		qdel(dummy)
		return 1

	qdel(dummy)
	return 0


/mob/living/silicon/robot/regenerate_icons()
	return update_icons()


/mob/living/silicon/robot/update_icons()
	cut_overlays()
	borg_icons()
	eyes_overlays()
	if(opened)
		var/panelprefix = "ov"
		if(custom_sprite) //Custom borgs also have custom panels, heh
			panelprefix = "[ckey]"
		if(custom_panel in custom_panel_names) //For default borgs with different panels
			panelprefix = custom_panel
		if(wiresexposed)
			add_overlay("[panelprefix]-openpanel +w")
		else if(cell)
			add_overlay("[panelprefix]-openpanel +c")
		else
			add_overlay("[panelprefix]-openpanel -c")

	if(inventory_head)
		var/image/head_icon
		if(!hat_icon_state)
			hat_icon_state = inventory_head.icon_state
		if(!hat_alpha)
			hat_alpha = inventory_head.alpha
		if(!hat_color)
			hat_color = inventory_head.color
		if(!hat_icon_file)
			hat_icon_file = inventory_head.onmob_sheets[ITEM_SLOT_HEAD_STRING]

		head_icon = get_hat_overlay()
		if(head_icon)
			add_overlay(head_icon)

	update_fire()

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/silicon/robot/proc/borg_icons() // Exists so that robot/destroyer can override it
	return

/mob/living/silicon/robot/proc/eyes_overlays() // Exists so that robot/destroyer can override it
	if(stat != DEAD && !HAS_TRAIT(src, TRAIT_INCAPACITATED) && !low_power_mode) //Not dead, not stunned.
		var/eyes_olay
		if(custom_panel in custom_eye_names)
			if(isclocker(src) && SSticker.mode.power_reveal)
				eyes_olay = "eyes-[custom_panel]-clocked"
			else
				eyes_olay = "eyes-[custom_panel]"
		else
			if(isclocker(src) && SSticker.mode.power_reveal)
				eyes_olay = "eyes-[icon_state]-clocked"
			else
				eyes_olay = "eyes-[icon_state]"
		if(eyes_olay)
			add_overlay(eyes_olay)
	return

/mob/living/silicon/robot/proc/installed_modules()
	if(weapon_lock)
		to_chat(src, span_warning("Weapon lock active, unable to use modules! Count:[weaponlock_time]"))
		return

	if(!module)
		pick_module()
		return
	var/dat = {"<meta charset="UTF-8"><a href='byond://?src=[UID()];mach_close=robotmod'>Close</A>
	<BR>
	<BR>
	<B>Activated Modules</B>
	<BR>
	<table border='0'>
	<tr><td>Module 1:</td><td>[module_state_1 ? "<A HREF=?src=[UID()];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]</td></tr>
	<tr><td>Module 2:</td><td>[module_state_2 ? "<A HREF=?src=[UID()];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]</td></tr>
	<tr><td>Module 3:</td><td>[module_state_3 ? "<A HREF=?src=[UID()];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]</td></tr>
	</table><BR>
	<B>Installed Modules</B><BR><BR>

	<table border='0'>"}
	for(var/obj in module.modules)
		if(!obj)
			dat += text("<tr><td><B>Resource depleted</B></td></tr>")
		else if(activated(obj))
			dat += text("<tr><td>[obj]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[obj]</td><td><A HREF=?src=[UID()];act=\ref[obj]>Activate</A></td></tr>")
	if(emagged || weapons_unlock)
		if(activated(module.emag))
			dat += text("<tr><td>[module.emag]</td><td><B>Activated</B></td></tr>")
		else
			dat += text("<tr><td>[module.emag]</td><td><A HREF=?src=[UID()];act=\ref[module.emag]>Activate</A></td></tr>")
	dat += "</table>"
/*
		if(activated(obj))
			dat += text("[obj]: \[<B>Activated</B> | <A HREF=?src=[UID()];deact=\ref[obj]>Deactivate</A>\]<BR>")
		else
			dat += text("[obj]: \[<A HREF=?src=[UID()];act=\ref[obj]>Activate</A> | <B>Deactivated</B>\]<BR>")
*/
	var/datum/browser/popup = new(src, "robotmod", "Modules")
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/robot/proc/install_upgrade(obj/item/borg/upgrade/upgrade)
	if(!upgrade.instant_use)
		RegisterSignal(upgrade, COMSIG_QDELETING, PROC_REF(on_upgrade_deleted))
		upgrades += upgrade
		if(upgrade.loc != src)
			upgrade.forceMove(src)
	else
		qdel(upgrade)

///Called when an applied upgrade is deleted.
/mob/living/silicon/robot/proc/on_upgrade_deleted(obj/item/borg/upgrade/old_upgrade)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		old_upgrade.deactivate(src)
	upgrades -= old_upgrade
	UnregisterSignal(old_upgrade, COMSIG_QDELETING)

/mob/living/silicon/robot/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		unset_machine()
		src << browse(null, t1)
		return TRUE

	if(href_list["mod"])
		var/obj/item/O = locate(href_list["mod"])
		if(istype(O) && (O.loc == src))
			O.attack_self(src)
		return TRUE

	if(href_list["act"])
		var/obj/item/O = locate(href_list["act"])
		if(!istype(O) || !(O.loc == src || O.loc == src.module))
			return TRUE
		activate_module(O)
		installed_modules()
		return TRUE

	//Show alerts window if user clicked on "Show alerts" in chat
	if(href_list["showalerts"])
		robot_alerts()
		return TRUE

	if(href_list["deact"])
		var/obj/item/O = locate(href_list["deact"])
		if(activated(O))
			if(module_state_1 == O)
				module_state_1 = null
				contents -= O
			else if(module_state_2 == O)
				module_state_2 = null
				contents -= O
			else if(module_state_3 == O)
				module_state_3 = null
				contents -= O
			else
				to_chat(src, "Module isn't activated.")
		else
			to_chat(src, "Module isn't activated")
		installed_modules()
		return TRUE

/mob/living/silicon/robot/proc/radio_menu()
	radio.interact(src)

/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_cooldown > world.time || low_power_mode)
		to_chat(src, span_danger("This function is currently offline."))
		return

	if(lamp_intensity == 0) //We'll skip intensity of 2, since every mob already has such a see-darkness range, so no much need for it.
		lamp_intensity = 4
	else //Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
		lamp_intensity = (lamp_intensity + 2) % (lamp_max + 2)
	to_chat(src, span_notice("[lamp_intensity > 2 ? "Headlamp power set to Level [lamp_intensity * 0.5]" : "Headlamp disabled"]."))
	update_headlamp()

/mob/living/silicon/robot/proc/update_headlamp(turn_off = FALSE, cooldown = 10 SECONDS)
	if(lamp_intensity > 2)
		if(turn_off || stat || low_power_mode)
			to_chat(src, span_danger("Your headlamp has been deactivated."))
			lamp_intensity = 0
			lamp_cooldown = cooldown == BORG_LAMP_CD_RESET ? 0 : max(world.time + cooldown, lamp_cooldown)
			set_light_on(FALSE)
		else
			set_light_range((lamp_intensity + (on_fire ? fire_light_modificator : 0)) * 0.5)
			set_light_on(TRUE)
	else
		set_light_on(FALSE)

	if(lamp_button)
		lamp_button.icon_state = "lamp[lamp_intensity]"

	update_icons()

/mob/living/silicon/robot/ExtinguishMob()
	..()
	set_light_color(default_lamp_color)

/mob/living/silicon/robot/proc/deconstruct()
	var/turf/T = get_turf(src)
	if((modtype != "Clockwork" || !mmi.clock) && isclocker(src))
		to_chat(src, span_warning("With body torn into pieces, your mind got free from evil cult!"))
		SSticker.mode.remove_clocker(mind, FALSE)
	if(robot_suit)
		robot_suit.forceMove(T)
		robot_suit.l_leg.forceMove(T)
		robot_suit.l_leg = null
		robot_suit.r_leg.forceMove(T)
		robot_suit.r_leg = null
		new /obj/item/stack/cable_coil(T, robot_suit.chest.wired)
		robot_suit.chest.forceMove(T)
		robot_suit.chest.wired = FALSE
		robot_suit.chest = null
		robot_suit.l_arm.forceMove(T)
		robot_suit.l_arm = null
		robot_suit.r_arm.forceMove(T)
		robot_suit.r_arm = null
		robot_suit.head.forceMove(T)
		robot_suit.head.flash1.forceMove(T)
		robot_suit.head.flash1.burn_out()
		robot_suit.head.flash1 = null
		robot_suit.head.flash2.forceMove(T)
		robot_suit.head.flash2.burn_out()
		robot_suit.head.flash2 = null
		robot_suit.head = null
		robot_suit.update_icon(UPDATE_OVERLAYS)
	else
		new /obj/item/robot_parts/robot_suit(T)
		new /obj/item/robot_parts/l_leg(T)
		new /obj/item/robot_parts/r_leg(T)
		new /obj/item/stack/cable_coil(T, 1)
		new /obj/item/robot_parts/chest(T)
		new /obj/item/robot_parts/l_arm(T)
		new /obj/item/robot_parts/r_arm(T)
		new /obj/item/robot_parts/head(T)
		var/b
		for(b=0, b!=2, b++)
			var/obj/item/flash/F = new /obj/item/flash(T)
			F.burn_out()
	if(cell) //Sanity check.
		cell.forceMove(T)
		cell = null
	drop_hat()
	qdel(src)

/mob/living/silicon/robot/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/oldLoc = src.loc
	. = ..()
	if(.)
		if(camera && oldLoc != src.loc)
			GLOB.cameranet.updatePortableCamera(src.camera)
	if(module)
		if(module.type == /obj/item/robot_module/janitor)
			var/turf/tile = loc
			if(stat != DEAD && isturf(tile))
				var/floor_only = TRUE
				for(var/A in tile)
					if(iseffect(A))
						var/obj/effect/check = A
						if(check.is_cleanable())
							var/obj/effect/decal/cleanable/blood/B = check
							if(istype(B) && B.off_floor)
								floor_only = FALSE
							else
								qdel(B)
					else if(isitem(A))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(ishuman(A))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.body_position == LYING_DOWN)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head()
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit()
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform()
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes()
							cleaned_human.clean_blood()
							to_chat(cleaned_human, span_danger("[src] cleans your face!"))
				if(floor_only)
					tile.clean_blood()
		return

/mob/living/silicon/robot/proc/self_destruct()
	if(emagged)
		if(mmi)
			qdel(mmi)
		explosion(src.loc,1,2,4,flame_range = 2, cause = src)
	else
		explosion(src.loc,-1,0,2, cause = src)
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = 0
	set_lockcharge(FALSE)
	scrambledcodes = 1
	//Disconnect it's camera so it's not so easily tracked.
	QDEL_NULL(src.camera)
	// I'm trying to get the Cyborg to not be listed in the camera list
	// Instead of being listed as "deactivated". The downside is that I'm going
	// to have to check if every camera is null or not before doing anything, to prevent runtime errors.
	// I could change the network to null but I don't know what would happen, and it seems too hacky for me.

/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Robot Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers.  Unlocks you and but permanently severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown. All systems operational.")
		remove_verb(src, /mob/living/silicon/robot/proc/ResetSecurityCodes)

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if(W)
		W.attack_self(src)

	return


/mob/living/silicon/robot/proc/SetLockdown(state = TRUE)
	if(isclocker(src))
		return
	// They stay locked down if their wire is cut.
	if(wires?.is_cut(WIRE_BORG_LOCKED))
		state = TRUE
	if(state)
		throw_alert(ALERT_LOCKED, /atom/movable/screen/alert/locked)
	else
		clear_alert(ALERT_LOCKED)
	set_lockcharge(state)


///Reports the event of the change in value of the lockcharge variable.
/mob/living/silicon/robot/proc/set_lockcharge(new_lockcharge)
	if(new_lockcharge == lockcharge)
		return
	. = lockcharge
	lockcharge = new_lockcharge
	if(lockcharge)
		if(!.)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)
	else if(.)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LOCKED_BORG_TRAIT)


// Proc that calls radial menu for borg to choose AFTER he chose his module.
// In module there is borg_skins
/mob/living/silicon/robot/proc/choose_icon()
	if(custom_sprite && check_sprite("[ckey]-[modtype]"))
		icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		icon_state =  "[src.ckey]-[modtype]"
		return

	var/list/choices = list()
	var/choice
	if(length(module?.borg_skins) > 1)
		for(var/skin in module.borg_skins)
			var/image/skin_image = image(icon = icon, icon_state = module.borg_skins[skin])
			skin_image.add_overlay("eyes-[module.borg_skins[skin]]")
			choices[skin] = skin_image
		choice = show_radial_menu(src, src, choices, require_near = TRUE)

	cut_overlays()
	if(choice)
		icon_state = module.borg_skins[choice]
		transform_animation(module.borg_skins[choice])
	else
		icon_state = module.default_skin
		transform_animation(module.default_skin, TRUE)

	var/list/names = splittext(icon_state, "-")
	custom_panel = trim(names[1])
	return

/mob/living/silicon/robot/proc/transform_animation(var/animated_icon, var/default = FALSE)
	Immobilize(5 SECONDS)
	say("Загрузка модуля...")
	setDir(SOUTH)
	for(var/i in 1 to 4)
		playsound(loc, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 50, TRUE, -1)
	flick("[animated_icon]_transform", src)
	to_chat(src, span_notice("Your icon has been set[default?" by default":""]. You now require a reset module to change it."))
	addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/silicon/robot, complete_loading)), 5 SECONDS)
	update_icons()

/mob/living/silicon/robot/proc/complete_loading()
	say("Инициализация успешна")

/mob/living/silicon/robot/proc/notify_ai(var/notifytype, var/oldname, var/newname)
	if(!connected_ai)
		return
	switch(notifytype)
		if(ROBOT_NOTIFY_AI_CONNECTED) //New Cyborg
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg connection detected: <a href='byond://?src=[connected_ai.UID()];track2=\ref[connected_ai];track=\ref[src]'>[name]</a>")]<br>")
		if(ROBOT_NOTIFY_AI_MODULE) //New Module
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.")]<br>")
		if(ROBOT_NOTIFY_AI_NAME) //New Name
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].")]<br>")

/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		set_connected_ai(null)

/mob/living/silicon/robot/proc/connect_to_ai(var/mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		set_connected_ai(AI)
		notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
		sync()


/mob/living/silicon/robot/adjustOxyLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(suiciding)
		return ..()
	return STATUS_UPDATE_NONE


/mob/living/silicon/robot/regenerate_icons()
	. = ..()
	update_module_icon()
	update_icons()

/mob/living/silicon/robot/emp_act(severity)
	if(emp_protection)
		return
	..()
	switch(severity)
		if(1)
			disable_component("comms", 160)
		if(2)
			disable_component("comms", 60)

/mob/living/silicon/robot/proc/set_connected_ai(new_ai)
	if(connected_ai == new_ai)
		return
	. = connected_ai
	connected_ai = new_ai
	if(.)
		var/mob/living/silicon/ai/old_ai = .
		old_ai.connected_robots -= src
	if(connected_ai)
		connected_ai.connected_robots |= src

/mob/living/silicon/robot/deathsquad
	base_icon = "nano_bloodhound"
	icon_state = "nano_bloodhound"
	designation = "SpecOps"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	req_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	pdahide = TRUE
	eye_protection = FLASH_PROTECTION_WELDER // Immunity to flashes and the visual part of flashbangs
	ear_protection = HEARING_PROTECTION_MINOR // Immunity to the audio part of flashbangs
	damage_protection = 10 // Reduce all incoming damage by this number
	brute_mod = 0.5 // Пулевые орудия наносят на 50%+5ед меньше урона. Теперь полная обойма ружейных пуль не убьет киборга(но заставит потерять 2 модуля и броню)
	burn_mod = 0.5 // Забавно, у киборга отряда смерти отражение лазерных снарядов, впрочем все еще снижает урон от взрывов, и позволяет пережить более чем одну ракету из SRM8.
	emp_protection = TRUE // Это киборг отряда смерти, он не должен быть остановим обычной импульсной винтовкой.
	allow_rename = FALSE
	modtype = "Commando"
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/infinite
	see_reagents = TRUE
	has_transform_animation = TRUE


/mob/living/silicon/robot/deathsquad/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)


/mob/living/silicon/robot/deathsquad/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/deathsquad(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/deathsquad(src)
	radio.recalculateChannels()
	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, 0)

/mob/living/silicon/robot/deathsquad/bullet_act(obj/item/projectile/P)
	if(istype(P) && P.is_reflectable(REFLECTABILITY_ENERGY) && P.starting)
		visible_message(span_danger("The [P.name] gets reflected by [src]!"), span_userdanger("The [P.name] gets reflected by [src]!"))
		P.reflect_back(src)
		return -1
	return ..(P)


/mob/living/silicon/robot/ert
	designation = "ERT"
	lawupdate = 0
	scrambledcodes = 1
	req_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = 1
	limited_modules = list("Engineering", "Medical", "Security")
	static_radio_channels = 1
	allow_rename = FALSE
	weapons_unlock = TRUE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/super
	var/eprefix = "Amber"
	see_reagents = TRUE


/mob/living/silicon/robot/ert/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ert_override
	radio = new /obj/item/radio/borg/ert(src)
	radio.recalculateChannels()
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)

/mob/living/silicon/robot/ert/New(loc)
	..(loc)
	var/rnum = rand(1,1000)
	var/borgname = "[eprefix] ERT [rnum]"
	name = borgname
	custom_name = borgname
	real_name = name
	mind = new
	mind.current = src
	mind.set_original_mob(src)
	mind.assigned_role = SPECIAL_ROLE_ERT
	mind.special_role = SPECIAL_ROLE_ERT
	if(!(mind in SSticker.minds))
		SSticker.minds += mind
	SSticker.mode.ert += mind


/mob/living/silicon/robot/ert/red
	eprefix = "Red"
	default_cell_type = /obj/item/stock_parts/cell/hyper

/mob/living/silicon/robot/ert/gamma
	default_cell_type = /obj/item/stock_parts/cell/bluespace
	limited_modules = list("Combat", "Engineering", "Medical")
	damage_protection = 5 // Reduce all incoming damage by this number
	eprefix = "Gamma"


/mob/living/silicon/robot/ert/gamma/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)


/mob/living/silicon/robot/destroyer
	// admin-only borg, the seraph / special ops officer of borgs
	base_icon = "droidcombat"
	icon_state = "droidcombat"
	modtype = "Destroyer"
	designation = "Destroyer"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	req_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	pdahide = TRUE
	eye_protection = FLASH_PROTECTION_WELDER // Immunity to flashes and the visual part of flashbangs
	ear_protection = HEARING_PROTECTION_MINOR // Immunity to the audio part of flashbangs
	emp_protection = TRUE // Immunity to EMP, due to heavy shielding
	brute_mod = 0.5 // Пулевые орудия наносят на 50%+5ед меньше урона. Теперь полная обойма ружейных пуль не убьет киборга(но заставит потерять 2 модуля и броню)
	burn_mod = 0.5 // Забавно, у киборга отряда смерти отражение лазерных снарядов, впрочем все еще снижает урон от взрывов, и позволяет пережить более чем одну ракету из SRM8.
	damage_protection = 20 // Reduce all incoming damage by this number. Very high in the case of /destroyer borgs, since it is an admin-only borg.
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/infinite/abductor
	see_reagents = TRUE
	drain_act_protected = TRUE


/mob/living/silicon/robot/destroyer/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)


/mob/living/silicon/robot/destroyer/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	additional_law_channels["Binary"] = get_language_prefix(LANGUAGE_BINARY)
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/destroyer(src)
	module.add_languages(src)
	module.add_subsystems_and_actions(src)
	status_flags &= ~CANPUSH
	addtimer(CALLBACK(module, TYPE_PROC_REF(/obj/item/robot_module, update_cells)), 1 SECONDS)
	if(radio)
		qdel(radio)
	radio = new /obj/item/radio/borg/ert/specops(src)
	radio.recalculateChannels()
	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, 0)

/mob/living/silicon/robot/destroyer/bullet_act(obj/item/projectile/P)
	if(istype(P) && P.is_reflectable(REFLECTABILITY_ENERGY) && P.starting && !(istype(module_active, /obj/item/borg/destroyer/mobility)))
		visible_message(span_danger("The [P.name] gets reflected by [src]!"), span_userdanger("The [P.name] gets reflected by [src]!"))
		P.reflect_back(src)
		return -1
	return ..(P)

/mob/living/silicon/robot/destroyer/borg_icons()
	if(base_icon == "")
		base_icon = icon_state
	if(module_active && istype(module_active,/obj/item/borg/destroyer/mobility))
		icon_state = "[base_icon]-roll"
	else
		icon_state = base_icon
		add_overlay("[base_icon]-shield")

/mob/living/silicon/robot/destroyer/eyes_overlays()
	if(stat != DEAD && !HAS_TRAIT(src, TRAIT_INCAPACITATED) && !low_power_mode) //Not dead, not stunned.
		var/eyes_olay
		if(isclocker(src) && SSticker.mode.power_reveal)
			eyes_olay = "eyes-[base_icon]-clocked"
		else
			eyes_olay = "eyes-[base_icon]"
		if(eyes_olay)
			add_overlay(eyes_olay)
	return


/mob/living/silicon/robot/extinguish_light(force = FALSE)
	..()
	update_headlamp(turn_off = TRUE, cooldown = 15 SECONDS)

/mob/living/silicon/robot/rejuvenate()
	..()
	var/brute = 1000
	var/burn = 1000
	var/list/datum/robot_component/borked_parts = get_damaged_components(TRUE, TRUE, TRUE, TRUE)
	for(var/datum/robot_component/borked_part in borked_parts)
		brute = borked_part.brute_damage
		burn = borked_part.electronics_damage
		borked_part.installed = 1
		borked_part.wrapped = new borked_part.external_type
		if(ispath(borked_part.external_type, /obj/item/stock_parts/cell)) // is the broken part a cell?
			cell = new borked_part.external_type // borgs that have their cell destroyed have their `cell` var set to null. we need create a new cell for them based on their old cell type.
		borked_part.heal_damage(brute,burn)
		borked_part.install()

/mob/living/silicon/robot/proc/check_sprite(spritename)
	. = FALSE

	var/static/all_borg_icon_states = icon_states('icons/mob/custom_synthetic/custom-synthetic.dmi')
	if(spritename in all_borg_icon_states)
		. = TRUE

/mob/living/silicon/robot/check_eye_prot()
	return eye_protection

/mob/living/silicon/robot/check_ear_prot()
	return ear_protection

/mob/living/silicon/robot/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	nightvision = initial(nightvision)
	set_sight(initial(sight))
	lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & SILICONMESON)
		add_sight(SEE_TURFS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(sight_mode & SILICONXRAY)
		add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		set_invis_see(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
		nightvision = 8

	if(sight_mode & SILICONTHERM)
		add_sight(SEE_MOBS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	..()

/// Used in `robot.dm` when the user presses "Q" by default.
/mob/living/silicon/robot/proc/on_drop_hotkey_press()
	var/obj/item/gripper/G = module_active
	if(istype(G) && G.gripped_item)
		G.drop_gripped_item() // if the active module is a gripper, try to drop its held item.
	else
		uneq_active() // else unequip the module and put it back into the robot's inventory.
		return

/mob/living/silicon/robot/proc/check_module_damage(makes_sound = TRUE)
	if(modules_break)
		if(health < 50) //Gradual break down of modules as more damage is sustained
			if(uneq_module(module_state_3))
				if(makes_sound)
					audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module 3 OFFLINE.\""))
					playsound(loc, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				to_chat(src, span_userdanger("SYSTEM ERROR: Module 3 OFFLINE."))

			if(health < 0)
				if(uneq_module(module_state_2))
					if(makes_sound)
						audible_message(span_warning("[src] sounds an alarm! \"SYSTEM ERROR: Module 2 OFFLINE.\""))
						playsound(loc, 'sound/machines/warning-buzzer.ogg', 60, TRUE)
					to_chat(src, span_userdanger("SYSTEM ERROR: Module 2 OFFLINE."))

				if(health < -50)
					if(uneq_module(module_state_1))
						if(makes_sound)
							audible_message(span_warning("[src] sounds an alarm! \"CRITICAL ERROR: All modules OFFLINE.\""))
							playsound(loc, 'sound/machines/warning-buzzer.ogg', 75, TRUE)
						to_chat(src, span_userdanger("CRITICAL ERROR: All modules OFFLINE."))

/mob/living/silicon/robot/can_see_reagents()
	return see_reagents


/mob/living/silicon/robot/verb/powerwarn()
	set category = "Robot Commands"
	set name = "Power Warning"

	if(!is_component_functioning("power cell") || !cell || !cell.charge)
		if(!start_audio_emote_cooldown(TRUE, 10 SECONDS))
			to_chat(src, span_warning("The low-power capacitor for your speaker system is still recharging, please try again later."))
			return

		visible_message(span_warning("The power warning light on [span_name("[src]")] flashes urgently."),
									span_warning("You announce you are operating in low power mode."))
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, FALSE)
	else
		to_chat(src, span_warning("You can only use this emote when you're out of charge."))

#undef BORG_LAMP_CD_RESET
