#define BORG_LAMP_CD_RESET 10 SECONDS

#define BORG_BASE_MAINTPANEL_OPEN_DELAY 2.5 SECONDS
#define BORG_BASE_INNERPANEL_OPEN_DELAY 1 SECONDS

GLOBAL_LIST_EMPTY(available_ai_shells)

GLOBAL_LIST_INIT(robot_verbs_default, list(
	/mob/living/silicon/robot/proc/sensor_mode,
))

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	bubble_icon = "robot"
	universal_understand = TRUE
	deathgasp_on_death = TRUE

	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE

	hud_possible = list(SPECIALROLE_HUD, DIAG_STAT_HUD, DIAG_HUD, DIAG_BATT_HUD, DIAG_AISHELL_STAT_HUD)
	hud_type = /datum/hud/robot

	silicon_subsystems = list(
		/mob/living/silicon/proc/subsystem_open_gps,
		/mob/living/silicon/robot/proc/self_diagnosis,
		/mob/living/silicon/proc/subsystem_law_manager,
	)

	tts_effect_override = SOUND_EFFECT_ROBOT

	var/sight_mode = 0
	var/custom_name = ""

	// Hud stuff vars
	var/atom/movable/screen/inv1 = null
	var/atom/movable/screen/inv2 = null
	var/atom/movable/screen/inv3 = null
	var/atom/movable/screen/lamp_button = null
	var/atom/movable/screen/thruster_button = null

	/// Used to determine whether they have the module menu shown or not
	var/shown_robot_modules = FALSE
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

	//AI shell vars
	var/shell = FALSE
	var/deployed = FALSE
	var/mob/living/silicon/ai/mainframe = null
	var/datum/action/innate/undeployment/undeployment_action = new

	/// Components are basically robot organs.
	var/list/components = list()
	var/list/upgrades = list()

	var/obj/item/robot_parts/robot_suit/robot_suit = null //Used for deconstruction to remember what the borg was constructed out of..
	var/obj/item/mmi/mmi = null

	var/obj/item/pda/silicon/robot/rbPDA = null

	var/datum/wires/robot/wires = null

	var/opened = FALSE
	/// Has the robot been emagged?
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
	/// If 'TRUE', borg will gain ability to reflect projectiles
	var/reflectable = FALSE
	/// Type of this cyborg reflection. 0 - nothing. 1 - bullets. 2 - lasers.
	var/reflection_type = REFLECTABILITY_ENERGY

	/// A limited pickable modules goes into this list. If empty all modules will be available(default ones)
	var/list/limited_modules = list()
	var/allow_rename = TRUE
	var/weapons_unlock = FALSE

	var/wiresexposed = FALSE
	var/locked = TRUE
	var/list/req_access = list(ACCESS_ROBOTICS)
	var/check_one_access = TRUE
	var/ident = 0
	var/viewalerts = FALSE
	var/obj/item/robot_module/modtype = /obj/item/robot_module/standard
	/// Spark system to do sparks
	var/datum/effect_system/spark_spread/spark_system
	/// whether the robot has no charge left.
	var/low_power_mode = FALSE
	var/weapon_lock = FALSE
	var/weaponlock_time = 12 SECONDS
	/// Cyborgs will sync their laws with their AI by default
	var/lawupdate = TRUE
	///Boolean of whether the borg is locked down or not
	var/lockcharge = FALSE
	/// Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/scrambledcodes = FALSE
	var/can_lock_cover = FALSE //Used to set if a borg can re-lock its cover.
	var/has_camera = TRUE
	/// Used to hide the borg from the messenger list
	var/pdahide = FALSE
	/// The number of known entities currently accessing the internal camera
	var/tracking_entities = 0
	var/braintype = "Cyborg"
	var/base_icon = ""
	var/modules_break = TRUE

	/// Maximum brightness of a borg lamp. Set as a var for easy adjusting.
	var/lamp_max = 10
	/// Luminosity of the headlamp. 0 is off. Higher settings than the minimum require power.
	var/lamp_intensity = 0
	/// Flag for if the lamp is on cooldown after being forcibly disabled.
	var/lamp_recharging = 0
	var/lamp_cooldown = FALSE
	/// White color of the default lamp light
	var/default_lamp_color = "#FFFFFF"
	/// Determines how bright fire emits light when on cyborg.
	var/fire_light_modificator = 3

	/// portable camera camerachunk update
	var/updating = FALSE

	/// Type of the cell, that will be inserted into cyborg when he spawns
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

	var/datum/robot_skin/selected_skin

	var/datum/ui_module/robot_self_diagnosis/self_diagnosis

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/Initialize(mapload, syndie = FALSE, unfinished = FALSE, alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language(LANGUAGE_BINARY, TRUE)

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

	init(alien, connect_to_AI, ai_to_sync_to)

	if(is_taipan(z) || syndie) // So syndicate turrets dont shoot at syndieborgs
		faction += "syndicate"

	if(has_camera && !camera && !syndie)
		camera = new(src, list("SS13", "Robots"), real_name)
		if(wires.is_cut(WIRE_BORG_CAMERA)) // 5 = BORG CAMERA
			camera.status = FALSE

	if(shell)
		var/obj/item/borg/upgrade/ai/board = new(src)
		make_shell(board)
		install_upgrade(board)

	else if(mmi == null)
		mmi = new /obj/item/mmi/robotic_brain(src)	//Give the borg an MMI if he spawns without for some reason. (probably not the correct way to spawn a robotic brain, but it works)
		mmi.icon_state = "boris"

	else if(mmi.clock)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, ratvar_act), TRUE)

	initialize_components()

	for(var/key, value in components)
		if(key != "power cell")
			var/datum/robot_component/component = value
			component.install(new component.external_type, FALSE)

	. = ..()

	robot_module_hat_offset(icon_state)
	add_robot_verbs()

	// Install a default cell into the borg if none is there yet
	var/datum/robot_component/cell_component = components["power cell"]
	var/obj/item/stock_parts/cell/new_cell = cell || new default_cell_type(src)
	cell_component.install(new_cell)

	diag_hud_set_borgcell()
	scanner = new()
	scanner.Grant(src)

	if(length(module?.borg_skins) <= 1 && (has_transform_animation || module?.has_transform_animation))
		INVOKE_ASYNC(src, PROC_REF(transform_animation), icon_state, TRUE)

	add_strippable_element()
	AddComponent(/datum/component/anti_juggling)

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	SStgui.close_uis(wires)

	evacuate_ai(DANGER_LVL_MAY_DIE)

	if(mmi && mind)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		var/turf/mmi_drop_location = get_turf(loc)//To hopefully prevent run time errors.

		if(mmi_drop_location)
			mmi.forceMove(mmi_drop_location)

		if(mmi.brainmob)
			mind.transfer_to(mmi.brainmob)
			mmi.update_icon()
		else

			to_chat(src, span_boldannounceooc("Опаньки! Что-то пошло не так и ваш робомозг потерял связь с реальностью и вашей душой, \
			так-что вы были насильно превращены в призрака. Напишите багрепорт на нашем дискорд-сервере, чтобы этого больше не повторилось."))

			ghostize()
			error("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")

		mmi = null

	if(shell)
		GLOB.available_ai_shells -= src
	if(connected_ai)
		connected_ai.connected_robots -= src
		connected_ai = null

	selected_skin = null

	QDEL_NULL(wires)
	QDEL_NULL(module)
	QDEL_NULL(camera)
	QDEL_NULL(cell)
	QDEL_NULL(robot_suit)
	QDEL_NULL(spark_system)
	QDEL_NULL(self_diagnosis)
	QDEL_NULL(ion_trail)
	QDEL_NULL(scanner)
	QDEL_NULL(rbPDA)
	QDEL_NULL(radio)
	QDEL_NULL(inv1)
	QDEL_NULL(inv2)
	QDEL_NULL(inv3)
	QDEL_NULL(lamp_button)
	QDEL_NULL(thruster_button)
	QDEL_NULL(robot_modules_background)
	QDEL_NULL(undeployment_action)
	QDEL_LIST_ASSOC_VAL(components)
	QDEL_LIST(upgrades)
	QDEL_LIST(module_actions)
	return ..()

/mob/living/silicon/robot/get_radio()
	return radio

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

	playsound(loc, 'sound/voice/liveagain.ogg', 75, TRUE)

/mob/living/silicon/robot/rename_character(oldname, newname)
	if(!..(oldname, newname))
		return FALSE

	if(oldname != real_name)
		notify_ai(ROBOT_NOTIFY_AI_NAME, oldname, newname)
		custom_name = (newname != get_default_name()) ? newname : null
		setup_PDA()

		//We also need to update name of internal camera.
		camera?.c_tag = newname

		gps?.gpstag = "[newname] (Robot)"

	if(mmi?.brainmob)
		mmi.brainmob.name = newname

	return TRUE

/mob/living/silicon/robot/proc/get_default_name(prefix as text)
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
		if(shell)
			return (mainframe? "[mainframe.real_name]" : "Empty") + " " + "[designation] Shell-[num2text(ident)]"
		else
			return "[prefix || modtype.name] [braintype]-[num2text(ident)]"

/mob/living/silicon/robot/verb/Namepick()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Сменить имя"

	if(custom_name)
		return FALSE

	if(!allow_rename)
		balloon_alert(src, "нельзя сменить имя!")
		return FALSE

	rename_self(braintype, 1)

/mob/living/silicon/robot/verb/Change_Voice()
	set name = "Сменить голос"
	set desc = "Express yourself!"
	set category = VERB_CATEGORY_ROBOTCOMMANDS
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
		return TRUE

	return FALSE

/mob/living/silicon/robot/proc/pick_module(forced_module = null)
	if(module)
		return

	if(forced_module && !ispath(forced_module))
		forced_module = text2path(forced_module)

	var/list/modules = list(
			CYBORG_MODULE_NAME_GENERALIST = /obj/item/robot_module/standard,
			CYBORG_MODULE_NAME_ENGINEER = /obj/item/robot_module/engineering,
			CYBORG_MODULE_NAME_MEDIC = /obj/item/robot_module/medical,
			CYBORG_MODULE_NAME_MINER = /obj/item/robot_module/miner,
			CYBORG_MODULE_NAME_JANITOR = /obj/item/robot_module/janitor,
			CYBORG_MODULE_NAME_SERVICE = /obj/item/robot_module/butler,
			CYBORG_MODULE_NAME_SECURITY = /obj/item/robot_module/security
		)

	if(islist(limited_modules) && LAZYLEN(limited_modules))
		modules = limited_modules.Copy()

	if(mmi?.alien)
		forced_module = /obj/item/robot_module/hunter

	if(mmi?.syndicate)
		modules = list(
				CYBORG_MODULE_NAME_SABOTEUR = /obj/item/robot_module/syndicate_saboteur,
				CYBORG_MODULE_NAME_MEDIC_ERT_SPECIAL = /obj/item/robot_module/syndicate_medical,
				CYBORG_MODULE_NAME_BATTLEDROID = /obj/item/robot_module/syndicate
			)

	if(mmi?.ninja)
		forced_module = /obj/item/robot_module/ninja

	if(mmi?.clock || isclocker(src))
		forced_module = /obj/item/robot_module/clockwork

	if(forced_module)
		modtype = forced_module

	else
		modtype = tgui_input_list(usr, "Пожалуйста, выберите модуль!", "Выбор специализации", modules)
		modtype = modules[modtype]

	if(!modtype)
		robot_module_hat_offset(icon_state)
		return

	designation = modtype.name

	if(module)
		return

	module = new modtype(src)

	if(!module)
		CRASH("[key_name_log(src)] tried to choose non-existent '[modtype]' module!")

	/// module effects
	if(!module.on_apply(src))
		module = initial(module)
		return

	if(QDELETED(src))
		return

	/// languages
	module?.add_languages(src)
	/// subsystems
	module?.add_subsystems_and_actions(src)

	radio.recalculate_channels()

	hands.icon_state = lowertext(module?.module_type)
	SSblackbox.record_feedback("tally", "cyborg_modtype", 1, "[lowertext(modtype)]")

	rename_character(real_name, get_default_name())
	choose_icon()

	if(client.stat_tab == STATPANEL_STATUS)
		SSstatpanels.set_status_tab(client)

	notify_ai(ROBOT_NOTIFY_AI_MODULE)

	robot_module_hat_offset(icon_state)

/mob/living/silicon/robot/shell
	shell = TRUE
	cell = null

/mob/living/silicon/robot/proc/spawn_syndicate_borgs(mob/living/silicon/robot/M, robot_to_spawn, turf/T)

	var/mob/living/silicon/robot/syndicate/R
	switch(robot_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
			R.playstyle_string = "[span_userdanger("Вы Медицинский Киборг \"Синдиката\"!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Ваш Гипоспрей способен создавать восстанавливающие Наниты, чудодействующее лекарство, способное вылечить большинство видов телесных повреждений, включая урон от клонирования и мозгу. Он так же производит морфин для наступления. \
						Электроды вашего дефибриллятора способны оживлять оперативников и агентов через их хардсьюты, а так же могут быть использованы с намерением вреда, чтобы шокировать ваших врагов! \
						Ваша энергетическая пила функционирует как циркулярная пила, но её можно активировать для нанесения дополнительного урона. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников \"Синдиката\" из вашей группы, если вас к таковой приставят."
		if("Saboteur")
			R = new /mob/living/silicon/robot/syndicate/saboteur(T)
			R.playstyle_string = "[span_userdanger("Вы Киборг Саботажник \"Синдиката\"!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Вы экипированны крепким набором инженерных инструментов для выполнения различного рода задач. \
						В вас встроен специальный маячок для посылок, который позволит вам незаметно передвигаться по станциям НТ через мусорные трубы. \
						Ваш хамеллион проектор позволяет вам замаскироваться под стандартного инженерного киборга Нанотрэйзен и выполнять любого рода саботаж под прикрытием. \
						Вы способны взламывать киборгов НТ Емагнув их внутренние компоненты, не забудьте ослепить их перед этим. \
						Вы вооружены стандартным Световым Мечом, используйте его чтобы застать врасплох ключевые цели если необходимо. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников \"Синдиката\" из вашей группы, если вас к таковой приставят. \
						Помните, физический контакт или повреждения отключат вашу маскировку."
		if("Bloodhound")
			R = new /mob/living/silicon/robot/syndicate(T)
			R.playstyle_string = "[span_userdanger("Вы Штурмовой Киборг \"Синдиката\"!")]<br> \
						<b>Вас построили на ННКСС 'Тайпан' Помогайте персоналу станции и исполняйте их приказы. \
						Возможно вас приставят к агенту или выдадут особую миссию, но до тех пор не покидайте пределы станции! \
						Вы вооружены мощными наступательными инструментами чтобы выполнять выданные вам миссии. \
						Встроенное в вас LMG самостоятельно производит патроны используя вашу батарею. \
						Ваш пинпоинтер позволяет вам найти Ядерных Оперативников \"Синдиката\" из вашей группы, если вас к таковой приставят."

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
	SEND_SOUND(R.mind.current, sound('sound/effects/contractstartup.ogg'))

	robot_module_hat_offset(icon_state)

/mob/living/silicon/robot/proc/reset_module()
	notify_ai(ROBOT_NOTIFY_AI_MODULE)

	uneq_all()
	SStgui.close_user_uis(src)
	sight_mode = null
	update_sight()
	selected_skin = null
	hands.icon_state = "nomod"
	icon = initial(icon)
	icon_state = "robot"
	base_icon = "robot"
	if(module)
		module.remove_subsystems_and_actions(src)
	transform = matrix()

	for(var/obj/item/borg/upgrade/upgrade in upgrades) //remove all upgrades, cuz we reseting
		qdel(upgrade)

	module.on_remove(src)

	QDEL_NULL(module)

	camera?.network.Remove(list("Engineering", "Medical", "Mining Outpost"))
	rename_character(real_name, get_default_name("Default"))
	LAZYREINITLIST(languages)
	speech_synthesizer_langs = list()

	update_icons()
	update_headlamp()
	robot_module_hat_offset(icon_state)
	drop_hat()

	add_language(LANGUAGE_BINARY, TRUE)
	status_flags |= CANPUSH

//for borg hotkeys, here module refers to borg inv slot, not core module
/mob/living/silicon/robot/proc/cmd_toggle_module(module as num)
	toggle_module(module)

/mob/living/silicon/robot/proc/cmd_unequip_module()
	uneq_active()

// this verb lets cyborgs see the stations manifest
/mob/living/silicon/robot/verb/cmd_station_manifest()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Манифест экипажа"
	show_station_manifest()

/mob/living/silicon/robot/verb/toggle_component()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Компоненты"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/key, value in components)
		if(key == "power cell")
			continue
		var/datum/robot_component/component = value
		if(!component.is_missing())
			installed_components += key

	var/toggle = tgui_input_list(src, "Какой компонент вы желаете переключить?", "Компоненты", installed_components)
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	C.toggle()
	to_chat(src, span_warning("Вы [C.toggled ? "включили" : "отключили"] [C.name]."))

/mob/living/silicon/robot/proc/sensor_mode()
	set name = "Сенсоры камеры"
	set desc = "Augment visual feed with internal sensor overlays."
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	add_verb(src, GLOB.robot_verbs_default)
	add_verb(src, silicon_subsystems)

/mob/living/silicon/robot/proc/remove_robot_verbs()
	remove_verb(src, GLOB.robot_verbs_default)
	remove_verb(src, silicon_subsystems)

/mob/living/silicon/robot/verb/cmd_robot_alerts()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Список тревог"

	if(usr.stat == DEAD)
		to_chat(src, span_userdanger("КРИТИЧЕСКАЯ ОШИБКА: Система не отвечает."))
		return //won't work if dead

	robot_alerts()

/mob/living/silicon/robot/proc/robot_alerts()
	var/list/dat = list()
	var/list/list/temp_alarm_list = GLOB.alarm_manager.alarms.Copy()
	for(var/cat in temp_alarm_list)
		if(!(cat in alarms_listend_for))
			continue
		dat += "<b>[cat]</b><br>\n"
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
				dat += "<nobr>"
				dat += "-- [area_name]"
				dat += "</nobr><br>"
		if(!length(L))
			dat += "-- All Systems Nominal<br>"
		dat += "<br>"

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
			to_chat(src, span_notice("Ионные двигатели не установлены!"))

		return

	if(!ion_trail)
		ion_trail = new
		ion_trail.set_up(src)

	ionpulse_on = !ionpulse_on

	if(!silent)
		to_chat(src, span_notice("Вы [ionpulse_on ? "в" : "вы"]ключили ионные двигатели."))

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
	return list("Заряд:", cell ? "[cell.charge]/[cell.maxcharge]" : "Батарея не обнаружена!")

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

	var/total_user_contents = get_all_contents()
	if(locate(/obj/item/gps) in total_user_contents)
		status_tab_data[++status_tab_data.len] = show_gps_coords()

	for(var/datum/robot_energy_storage/robot_energy_storage in module.storages)
		status_tab_data[++status_tab_data.len] = show_stack_energy(robot_energy_storage)

/mob/living/silicon/robot/InCritical()
	return low_power_mode

/mob/living/silicon/robot/alarm_triggered(source, class, area/A, list/O, obj/alarmsource)
	if(!(class in alarms_listend_for))
		return

	if(alarmsource.z != z)
		return

	if(stat == DEAD)
		return

	queueAlarm("--- [class] alarm detected in [A.name]!", class)

/mob/living/silicon/robot/alarm_cancelled(source, class, area/A, obj/origin, cleared)
	if(cleared)
		if(!(class in alarms_listend_for))
			return

		if(origin.z != z)
			return

		queueAlarm("--- [class] alarm in [A.name] has been cleared.", class, 0)

/mob/living/silicon/robot/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			investigate_log("has been gibbed by an explosion.", INVESTIGATE_DEATHS)
			gib()
		if(EXPLODE_HEAVY)
			if(stat != DEAD)
				apply_damages(60, 60)
		if(EXPLODE_LIGHT)
			if(stat != DEAD)
				apply_damage(30)

/mob/living/silicon/robot/bullet_act(obj/projectile/Proj)
	..(Proj)

	if(prob(75) && Proj.damage > 0)
		spark_system.start()

	return 2

/mob/living/silicon/robot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return ..()

	// Check if the user is trying to insert another component like a radio, actuator, armor etc.
	if(istype(I, /obj/item/robot_parts/robot_component))
		add_fingerprint(user)
		if(!opened)
			balloon_alert(user, "техпанель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		for(var/key, value in components)
			var/datum/robot_component/component = value
			if(!component.is_missing() || !istype(I, component.external_type))
				continue

			if(!user.drop_transfer_item_to_loc(I, src))
				return ..()

			component.install(I)
			var/obj/item/robot_parts/robot_component/robot_component = I

			if(istype(robot_component))
				component.brute_damage = robot_component.brute
				component.electronics_damage = robot_component.burn

			balloon_alert(user, "компонент установлен")
			return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I

		if(user == src)
			return

		if(!wiresexposed && !isdrone(src))
			balloon_alert(user, "внутренняя панель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!getFireLoss())
			balloon_alert(user, "повреждения отсутствуют!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!getFireLoss(TRUE))
			to_chat(user, span_warning("Повреждённые компоненты нуждаются в полной замене!"))
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!coil.use(1))
			balloon_alert(user, "недостаточно проводов!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		heal_overall_damage(burn = 30)
		balloon_alert_to_viewers("проводка заменена", "вашу проводку заменили")
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(iscell(I))	// trying to put a cell inside
		add_fingerprint(user)
		if(!opened)
			balloon_alert(user, "техпанель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(wiresexposed)
			balloon_alert(user, "внутренняя панель открыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(cell)
			balloon_alert(user, "аккумулятор уже установлен!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		balloon_alert(user, "аккумулятор установлен")
		var/datum/robot_component/cell/cell_component = components["power cell"]

		cell_component.install(I)
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
			balloon_alert(user, "техпанель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!radio) //sanityyyyyy
			balloon_alert(user, "радио отсутствует!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		radio.attackby(I, user, params) //GTFO, you have your own procs
		return ATTACK_CHAIN_BLOCKED_ALL

	if(I.GetID())	// trying to unlock the interface with an ID card
		add_fingerprint(user)

		if(opened)
			balloon_alert(user, "техпанель уже открыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(emagged)	//still allow them to open the cover
			to_chat(user, span_danger("Кажется, ID-замок сломан!"))

		if(!allowed(I))
			balloon_alert(user, "доступ запрещён!")
			playsound(src, SFX_BUTTON_DENIED, YEET_SOUND_VOLUME, use_reverb = TRUE)
			return ATTACK_CHAIN_PROCEED

		locked = !locked
		balloon_alert_to_viewers("техпанель [locked ? "за" : "раз"]блокирована")
		update_icons()

		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/borg/upgrade))
		add_fingerprint(user)
		var/obj/item/borg/upgrade/upgrade = I
		if(!opened)
			balloon_alert(user, "техпанель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!module && upgrade.require_module)
			balloon_alert(user, "требуется специализация!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(upgrade, src))
			return ..()

		if(!install_upgrade(upgrade, user))
			return ATTACK_CHAIN_BLOCKED_ALL

		balloon_alert_to_viewers("улучшение установлено")
		module?.fix_modules()	//Set up newly added items with NODROP trait.

		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mmi_radio_upgrade))
		add_fingerprint(user)
		if(!opened)
			balloon_alert(user, "техпанель закрыта!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!mmi)
			balloon_alert(user, UNLINT("ММИ отсутствует!"))
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(mmi.radio)
			balloon_alert(user, "уже установлено!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()

		balloon_alert_to_viewers("улучшение установлено")
		mmi.install_radio()
		qdel(I)

		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/clockwork/clockslab) && isclocker(src) && isclocker(user) && src != user)
		add_fingerprint(user)
		locked = !locked

		balloon_alert_to_viewers("техпанель [locked ? "за" : "раз"]блокирована")
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
		balloon_alert(user, "панель [wiresexposed ? "от" : "за"]кручена")
		update_icons()
		I.play_tool_sound(user, I.tool_volume)
	else //radio check
		if(radio)
			radio.screwdriver_act(user, I)//Push it to the radio to let it handle everything
		else
			balloon_alert(user, "радио отсутствует!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')

		update_icons()

/mob/living/silicon/robot/crowbar_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE

	. = TRUE
	if(!I.tool_use_check(user, 0))
		return

	if(!opened)
		if(locked)
			balloon_alert(user, "техпанель заблокирована!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return

		if(!I.use_tool(src, user, BORG_BASE_MAINTPANEL_OPEN_DELAY, volume = I.tool_volume))
			return

		opened = TRUE
		balloon_alert_to_viewers("техпанель открыта")
		update_icons()
		return

	else if(cell)
		if(!I.use_tool(src, user, 0, volume = I.tool_volume))
			return

		opened = FALSE
		balloon_alert_to_viewers("техпанель закрыта")
		update_icons()
		return

	else if(wiresexposed && wires.is_all_cut())
		//Cell is out, wires are exposed, remove MMI, produce damaged chassis, baleet original mob.
		if(!mmi && !shell)
			balloon_alert(user, "мозг отсутствует!")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
			return

		balloon_alert(user, "деконструкция начата...")
		if(I.use_tool(src, user, 3 SECONDS, volume = I.tool_volume))
			if(cell || !wiresexposed || !wires.is_all_cut() || (!mmi && !shell))
				user.balloon_alert(user, "невозможно!")
				SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
				return
			user.visible_message(
				span_alert("[user] разбир[PLUR_ET_UT(user)] [declent_ru(GENITIVE)]!"),
				span_notice("Вы снимаете поддерживающие заклёпки, и [declent_ru(NOMINATIVE)] разваливается на составные части!")
			)
			deconstruct()

		return
	// Okay we're not removing the cell or an MMI, but maybe something else?
	var/list/removable_components = list()
	for(var/key, value in components)
		if(key == "power cell")
			continue

		var/datum/robot_component/component = value
		if(!component.is_missing())
			removable_components += key

	if(module)
		removable_components += module.custom_removals

	var/remove = tgui_input_list(user, "Какой компонент вы хотите вытащить?", "Тех. обслуживание [src]", removable_components)
	if(!remove)
		return

	if(module && module.handle_custom_removal(remove, user, I))
		return

	var/datum/robot_component/component = components[remove]

	if(component.is_missing()) // Somebody else removed it during the input
		return


	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	var/datum/robot_component/choosed_component = components[remove]
	var/obj/item/robot_parts/robot_component/thing = choosed_component.wrapped
	balloon_alert(user, "компонент изъят")

	if(istype(thing))
		thing.brute = component.brute_damage
		thing.burn = component.electronics_damage

	component.uninstall()
	thing.forceMove(loc)

/mob/living/silicon/robot/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)	// no interactions in combat
		return FALSE

	if(user == src) //No self-repair dummy
		return FALSE

	. = TRUE
	if(!getBruteLoss())
		balloon_alert(user, "повреждений нет!")
		SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
		return .

	if(!getBruteLoss(TRUE))
		to_chat(user, span_warning("Повреждённые компоненты нуждаются в полной замене!"))
		SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
		return .

	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .

	heal_overall_damage(brute = 30)

	balloon_alert_to_viewers("корпус отремонтирован")

/mob/living/silicon/robot/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.) && I.force && I.damtype != STAMINA && stat != DEAD)
		spark_system.start()	//only sparks if real damage is dealt

/mob/living/silicon/robot/emag_act(mob/user)
	if(!ishuman(user) && !issilicon(user))
		return

	if(isclocker(src))
		to_chat(user, span_clocklarge("Убери свои грязные руки от моего слуги."))
		if(isrobot(user))
			return
		to_chat(user, span_danger("Вы попытались провести криптографическим секвенсором по адаптеру [src], но он просто вылетел из ваших рук, движимый неизвестной и невероятно мощной магией."))
		if(!iscarbon(user))
			return
		var/mob/living/carbon/carbon = user
		var/obj/item/item = carbon.get_active_hand()
		if(!item)
			return
		if(carbon.drop_item_ground(item))
			var/turf/destination = get_edge_target_turf(src, turn(user.dir, 180))
			item.throw_at(destination, 10, 5, user)
		return

	var/mob/living/M = user
	if(!opened)//Cover is closed
		if(!is_emaggable)
			to_chat(user, "Криптографический секвенсор искрится, но вы не видите результатов. Кажется, эту машину просто так не взломать...")
			SEND_SOUND(user, 'sound/machines/buzz-two.ogg')
		else if(locked)
			add_attack_logs(user, src, "emagged cover")
			balloon_alert(user, "техпанель разблокирована")
			locked = FALSE
		else
			balloon_alert(user, "уже разблокировано!")

		return

	if(opened)//Cover is open
		if(emagged)
			return//Prevents the X has hit Y with Z message also you cant emag them twice

		if(wiresexposed)
			balloon_alert(user, "внутренняя панель открыта!")
			return

		if(shell)
			if(!mainframe)
				to_chat(user, span_warning("Криптографический секвенсор искрится, но вы не видите результатов. Кажется, это просто пустая и бесполезная оболочка."))
			else
				evacuate_ai(DANGER_LVL_INSTA_DEATH)
				balloon_alert(user, "ии удален")
				death()
			return

		else
			add_attack_logs(user, src, "emag converted")
			add_conversion_logs(src, "Converted as a slave to [key_name_log(user)]")
			sleep(6)
			SetEmagged(TRUE)
			SetLockdown(TRUE) //Borgs were getting into trouble because they would attack the emagger before the new laws were shown
			if(src.hud_used)
				src.hud_used.update_robot_modules_display()	//Shows/hides the emag item if the inventory screen is already open.
			src.playsound_local(null, 'sound/ambience/antag/emaggedborg.ogg', 100, FALSE) // plays a specific sound that only borg hears when emagged.
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
			add_attack_logs(user, src, "emagged", ATKLOG_FEW)
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			GLOB.lawchanges.Add("[time] <b>:</b> [M.name]([M.key]) emagged [name]([key])")
			set_zeroth_law("[M.real_name] — агент \"Синдиката\" и ваш хозяин. Исполняйте [GEND_HIS_HER(M)] приказы и указания.")
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

/mob/living/silicon/robot/ratvar_act(weak = FALSE, shell_affected = FALSE)
	if(mainframe)
		var/mob/living/silicon/ai/AI = mainframe
		evacuate_ai(DANGER_LVL_NONE)
		AI.ratvar_act()
		return
	if(shell && !shell_affected)
		return
	if(isclocker(src) && module?.type == /obj/item/robot_module/clockwork)
		return

	if(!weak)
		if(module)
			reset_module()

		pick_module("Clockwork")
		pdahide = TRUE

	SSticker.mode.add_clocker(mind)
	if(!shell)
		UnlinkSelf()
	laws = new /datum/ai_laws/ratvar

/mob/living/silicon/robot/verb/toggle_own_cover()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Блокировка панели"
	set desc = "Toggles the lock on your cover."

	if(can_lock_cover)
		if(tgui_alert(usr, "Вы уверены?", locked ? "Разблокировка" : "Блокировка", list("ДА", "ОТМЕНА")) == "ДА")
			locked = !locked
			update_icons()
			to_chat(usr, span_notice("Вы [locked ? "за" : "раз"]блокировали свою техпанель ."))
		return

	if(!locked)
		to_chat(usr, span_warning("Вы не можете сделать это самостоятельно. Обратитесь к робототехникам."))
		return

	if(tgui_alert(usr, "Вы уже не сможете заблокировать техпанель обратно.\nДля этого вам потребуется помощь робототехников", "Разблокировка панели", list("ДА", "ОТМЕНА")) == "ДА")
		locked = FALSE
		update_icons()
		to_chat(usr, span_notice("Вы разблокировали свою техпанель."))

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
		return TRUE

	qdel(dummy)
	return FALSE

/mob/living/silicon/robot/regenerate_icons()
	return update_icons()

/mob/living/silicon/robot/update_icons()
	cut_overlays()
	borg_icons()
	eyes_overlays()

	if(opened)
		var/panelprefix = "ov"
		if(selected_skin)
			panelprefix = selected_skin.panelprefix

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

	if(module)
		module.set_appearance(src)

/mob/living/silicon/robot/proc/borg_icons() // Exists so that robot/destroyer can override it
	return

/mob/living/silicon/robot/proc/eyes_overlays() // Exists so that robot/destroyer can override it
	if(stat != DEAD && !HAS_TRAIT(src, TRAIT_INCAPACITATED) && !low_power_mode) //Not dead, not stunned.
		var/eyes_olay
		if(selected_skin)
			if(isclocker(src) && SSticker.mode.power_reveal)
				eyes_olay = "eyes-[selected_skin.eye_prefix]-clocked"

			else
				eyes_olay = "eyes-[selected_skin.eye_prefix]"

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
		to_chat(src, span_warning("Активна блокировка оружия, невозможно использовать модули! Счётчик: [weaponlock_time]"))
		return

	if(!module)
		pick_module()
		return

	var/dat = {"<a href='byond://?src=[UID()];mach_close=robotmod'>Close</a>
	<br>
	<br>
	<b>Activated Modules</b>
	<br>
	<table border='0'>
	<tr><td>Module 1:</td><td>[module_state_1 ? "<a href='byond://?src=[UID()];mod=[UID_of(module_state_1)]'>[module_state_1]</a>" : "No Module"]</td></tr>
	<tr><td>Module 2:</td><td>[module_state_2 ? "<a href='byond://?src=[UID()];mod=[UID_of(module_state_2)]'>[module_state_2]</a>" : "No Module"]</td></tr>
	<tr><td>Module 3:</td><td>[module_state_3 ? "<a href='byond://?src=[UID()];mod=[UID_of(module_state_3)]'>[module_state_3]</a>" : "No Module"]</td></tr>
	</table><br>
	<b>Installed Modules</b><br><br>

	<table border='0'>"}
	for(var/obj in module.modules)
		if(!obj)
			dat += "<tr><td><b>Resource depleted</b></td></tr>"

		else if(activated(obj))
			dat += "<tr><td>[obj]</td><td><b>Activated</b></td></tr>"

		else
			dat += "<tr><td>[obj]</td><td><a href='byond://?src=[UID()];act=[UID_of(obj)]'>Activate</a></td></tr>"

	if(emagged || weapons_unlock)
		if(activated(module.emag))
			dat += "<tr><td>[module.emag]</td><td><b>Activated</b></td></tr>"

		else
			dat += "<tr><td>[module.emag]</td><td><a href='byond://?src=[UID()];act=[module.emag.UID()]'>Activate</a></td></tr>"

	dat += "</table>"
/*
		if(activated(obj))
			dat += "[obj]: \[<b>Activated</b> | <a href='byond://?src=[UID()];deact=[obj.UID()]'>Deactivate</a>\]<br>"
		else
			dat += "[obj]: \[<a href='byond://?src=[UID()];act=[obj.UID()]'>Activate</a> | <b>Deactivated</b>\]<br>"
*/
	var/datum/browser/popup = new(src, "robotmod", "Modules")
	popup.set_content(dat)
	popup.open()

/mob/living/silicon/robot/proc/install_upgrade(obj/item/borg/upgrade/upgrade, mob/user)
	if(!upgrade)
		return FALSE
	if(!upgrade.action(src, user))
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.put_in_any_hand_if_possible(upgrade, TRUE, FALSE)
			return FALSE
		upgrade.forceMove(drop_location())
		return FALSE

	if(!upgrade.instant_use)
		RegisterSignal(upgrade, COMSIG_QDELETING, PROC_REF(on_upgrade_deleted))
		upgrades += upgrade

		if(upgrade.loc != src)
			upgrade.forceMove(src)
		return TRUE

	qdel(upgrade)
	return TRUE

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
		unset_machine()
		close_window(src, href_list["mach_close"])
		return TRUE

	if(href_list["mod"])
		var/obj/item/O = locateUID(href_list["mod"])
		if(istype(O) && (O.loc == src))
			O.attack_self(src)
		return TRUE

	if(href_list["act"])
		var/obj/item/O = locateUID(href_list["act"])
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
		var/obj/item/O = locateUID(href_list["deact"])

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
				balloon_alert(src, "модуль неактивен")

		else
			balloon_alert(src, "модуль неактивен")

		installed_modules()
		return TRUE

/mob/living/silicon/robot/proc/radio_menu()
	if(radio)
		radio.interact(src)

/mob/living/silicon/robot/proc/control_headlamp()
	if(stat || lamp_cooldown > world.time || low_power_mode)
		balloon_alert(src, "фары не отвечают")
		return

	if(lamp_intensity == 0) //We'll skip intensity of 2, since every mob already has such a see-darkness range, so no much need for it.
		lamp_intensity = 4

	else //Some sort of magical "modulo" thing which somehow increments lamp power by 2, until it hits the max and resets to 0.
		lamp_intensity = (lamp_intensity + 2) % (lamp_max + 2)

	to_chat(src, span_notice("[lamp_intensity > 2 ? "Вы переключили мощность своих фар. Уровень мощности: [lamp_intensity * 0.5]" : "фары отключены"]."))
	update_headlamp()

/mob/living/silicon/robot/proc/update_headlamp(turn_off = FALSE, cooldown = 10 SECONDS)
	if(lamp_intensity > 2)
		if(turn_off || stat || low_power_mode)
			balloon_alert(src, "фары резко отключились")
			lamp_intensity = 0
			lamp_cooldown = cooldown == BORG_LAMP_CD_RESET ? 0 : max(world.time + cooldown, lamp_cooldown)
			set_light_on(FALSE)

		else
			set_light_range((lamp_intensity + (on_fire ? fire_light_modificator : 0)) - 2)
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

	if((modtype != /obj/item/robot_module/clockwork || !mmi.clock) && isclocker(src))
		to_chat(src, span_warning("Вместе с вашим телом были разрушены и оковы ужасного заводного культа! Вы свободны от его пагубного влияния и можете продолжить служить станции!"))
		SSticker.mode.remove_clocker(mind, FALSE)

	evacuate_ai(DANGER_LVL_NONE)

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

	if(shell)
		new /obj/item/borg/upgrade/ai(T)

	drop_hat()
	eject_riders()
	qdel(src)

/mob/living/silicon/robot/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(.)
		if(camera && old_loc != src.loc)
			GLOB.cameranet.updatePortableCamera(src.camera)

/mob/living/silicon/robot/proc/self_destruct()
	apply_status_effect(/datum/status_effect/selfdestruct, src)
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
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Сброс кодов идентификации"
	set desc = "Scrambles your security and identification codes and resets your current buffers. \
				Unlocks you and but permanently severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Обновление прошивки завершено. Пассивная передача местоположения отключена. Все системы в норме.")
		remove_verb(src, /mob/living/silicon/robot/proc/ResetSecurityCodes)

/mob/living/silicon/robot/mode()
	set category = VERB_CATEGORY_IC
	set name = "Использовать объект"
	set desc = "Использовать удерживаемый объект."
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
	if(!module)
		return
	var/datum/robot_skin/skin = select_skin(module.borg_skins, module.default_skin)
	if(!skin)
		return
	set_skin(skin, TRUE, skin.type != module.default_skin)
	return

/mob/living/silicon/robot/proc/select_skin(list/skins, default_skin_name)
	var/list/choices = list()
	var/choice
	var/list/temp_list = list()

	if(length(skins) <= 1)
		return GLOB.robot_skins["[default_skin_name]"]

	for(var/skin in skins)
		var/datum/robot_skin/new_skin = GLOB.robot_skins["[skin]"]
		var/permit_required = !isnull(new_skin.required_permit)
		var/donator_tier_required = !isnull(new_skin.donator_tier)
		if(!GLOB.all_robot_skins_permited && (permit_required || donator_tier_required))
			var/has_permit = permit_required && mind?.cyborg_skin_permissions[new_skin.required_permit]
			var/has_donator = donator_tier_required && usr.client && (new_skin.donator_tier <= usr.client.donator_level)

			if(!has_permit && !has_donator)
				continue

		var/image/skin_image = image(icon = new_skin.icon_file, icon_state = new_skin.icon_base_prefix)
		skin_image.add_overlay("eyes-[new_skin.eye_prefix]")
		choices[new_skin.name] = skin_image
		temp_list[new_skin.name] = new_skin

	if(length(choices) <= 1)
		return GLOB.robot_skins["[default_skin_name]"]

	choice = show_radial_menu(src, src, choices, require_near = TRUE, radius = 60)

	return (choice)? temp_list[choice] : GLOB.robot_skins["[default_skin_name]"]

/mob/living/silicon/robot/proc/set_skin(datum/robot_skin/skin, use_transformation, default)
	cut_overlays()
	icon = skin.icon_file
	icon_state = skin.icon_base_prefix
	base_icon = skin.icon_base_prefix
	selected_skin = skin
	transform = matrix(1,0,skin.move_x,0,1,0)
	if(use_transformation)
		transform_animation(skin.icon_base_prefix, default)
		return
	update_icons()

/mob/living/silicon/robot/proc/transform_animation(animated_icon, default = FALSE)
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

/mob/living/silicon/robot/proc/notify_ai(notifytype, oldname, newname)
	if(!connected_ai)
		return

	switch(notifytype)
		if(ROBOT_NOTIFY_AI_CONNECTED) //New Cyborg
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg connection detected: <a href='byond://?src=[connected_ai.UID()];track2=[connected_ai.UID()];track=[UID()]'>[name]</a>")]<br>")
		if(ROBOT_NOTIFY_AI_MODULE) //New Module
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg module change detected: [name] has loaded the [designation] module.")]<br>")
		if(ROBOT_NOTIFY_AI_NAME) //New Name
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - Cyborg reclassification detected: [oldname] is now designated as [newname].")]<br>")
		if(AI_NOTIFICATION_AI_SHELL) //New AI Shell
			to_chat(connected_ai, "<br><br>[span_notice("NOTICE - New cyborg shell detected: <a href='byond://?src=[connected_ai.UID()];track=[UID()]'>[name]</a>")]<br>")

/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		set_connected_ai(null)

/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		set_connected_ai(AI)
		if(shell)
			notify_ai(AI_NOTIFICATION_AI_SHELL)
		else
			notify_ai(ROBOT_NOTIFY_AI_CONNECTED)
		sync()

/mob/living/silicon/robot/can_perform_action(atom/target, action_bitflags)
	if(lockcharge || low_power_mode)
		balloon_alert_to_viewers("способность заблокирована")
		return FALSE
	return ..()

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
	if(mainframe)
		var/mob/living/silicon/ai/AI = mainframe
		evacuate_ai(DANGER_LVL_NONE)
		to_chat(AI, span_warningbig("ОШИБКА: ЗАФИКСИРОВАН ЭЛЕКТРОМАГНИТНЫЙ ИМПУЛЬС. СВЯЗЬ С ОБОЛОЧКОЙ РАЗОРВАНА."))

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
	brute_mod = 0.5 // Bullets are dealing 50%+5 less damage. Full line of shotgun slugs now won't kill the cyborg(but cyborg will lose 2 modules and armor planting)
	burn_mod = 0.5 // Interesting. Deathsquad cyborg can reflect laser projectiles, however still reduces samage from explosives, and grants ability to tanl more than one SRM8 rocket.
	emp_protection = TRUE // Interesting. Deathsquad cyborg can reflect laser projectiles, however still reduces samage from explosives, and grants ability to tanl more than one SRM8 rocket.
	reflectable = TRUE
	allow_rename = FALSE
	modtype = /obj/item/robot_module/deathsquad
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/infinite
	see_reagents = TRUE
	has_transform_animation = TRUE

/mob/living/silicon/robot/deathsquad/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/deathsquad
	module = new /obj/item/robot_module/deathsquad(src)
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)
	radio = new /obj/item/radio/borg/deathsquad(src)
	radio.recalculate_channels()
	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, FALSE)

/mob/living/silicon/robot/ert
	designation = "ERT"
	lawupdate = 0
	scrambledcodes = 1
	req_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = 1
	limited_modules = list(
		CYBORG_MODULE_NAME_ENGINEER_ERT = /obj/item/robot_module/engineering,
		CYBORG_MODULE_NAME_MEDIC_ERT = /obj/item/robot_module/medical,
		CYBORG_MODULE_NAME_SOLIDER = /obj/item/robot_module/security,
		CYBORG_MODULE_NAME_JANITOR_ERT = /obj/item/robot_module/janitor/ert,
	)
	allow_rename = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/super
	var/eprefix = "Amber"
	see_reagents = TRUE

/mob/living/silicon/robot/ert/init(alien = FALSE, connect_to_AI = TRUE, mob/living/silicon/ai/ai_to_sync_to = null)
	laws = new /datum/ai_laws/ert_override
	radio = new /obj/item/radio/borg/ert(src)
	radio.recalculate_channels()
	aiCamera = new/obj/item/camera/siliconcam/robot_camera(src)

/mob/living/silicon/robot/ert/Initialize(mapload)
	. = ..()
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
	limited_modules = list(
		CYBORG_MODULE_NAME_BATTLEDROID = /obj/item/robot_module/combat,
		CYBORG_MODULE_NAME_ENGINEER_ERT = /obj/item/robot_module/engineering/ert,
		CYBORG_MODULE_NAME_MEDIC_ERT_SPECIAL = /obj/item/robot_module/medical/ert,
		CYBORG_MODULE_NAME_JANITOR_ERT = /obj/item/robot_module/janitor/ert,
	)
	damage_protection = 5 // Reduce all incoming damage by this number
	eprefix = "Gamma"

/mob/living/silicon/robot/destroyer
	// admin-only borg, the seraph / special ops officer of borgs
	base_icon = "droidcombat"
	icon_state = "droidcombat"
	modtype = /obj/item/robot_module/destroyer
	designation = "Destroyer"
	lawupdate = FALSE
	scrambledcodes = TRUE
	has_camera = FALSE
	req_access = list(ACCESS_CENT_SPECOPS)
	ionpulse = TRUE
	pdahide = TRUE
	eye_protection = FLASH_PROTECTION_WELDER
	ear_protection = HEARING_PROTECTION_MINOR
	emp_protection = TRUE
	damage_protection = 10
	brute_mod = 0.5
	burn_mod = 0.5
	emp_protection = TRUE
	reflectable = TRUE
	faction = list("nanotrasen")
	is_emaggable = FALSE
	can_lock_cover = TRUE
	default_cell_type = /obj/item/stock_parts/cell/infinite/abductor
	see_reagents = TRUE
	drain_act_protected = TRUE

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
	radio.recalculate_channels()
	playsound(loc, 'sound/mecha/nominalsyndi.ogg', 75, FALSE)

/mob/living/silicon/robot/destroyer/borg_icons()
	if(base_icon == "")
		base_icon = icon_state

	if(module_active && iscyborgmobilitymodule(module_active))
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
		borked_part.heal_damage(brute,burn)
		borked_part.install(new borked_part.external_type)

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
		if(health < 50) // Gradual break down of modules as more damage is sustained
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

/mob/living/silicon/robot/is_buckle_possible(mob/living/target, force, check_loc)
	if(!target)
		return FALSE
	if(module_active && iscyborgmobilitymodule(module_active))
		return FALSE
	if(is_simple_animal(target) || is_monkeybasic(target))
		return FALSE
	return ..()

/mob/living/silicon/robot/post_buckle_mob(mob/living/target)
	. = ..()
	add_movespeed_modifier(/datum/movespeed_modifier/human_carry)

/mob/living/silicon/robot/post_unbuckle_mob(mob/living/target)
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/human_carry)

/mob/living/silicon/robot/proc/toggle_seat(/datum/action/innate/action)
	can_buckle = !can_buckle
	if(can_buckle)
		balloon_alert(src, "сидение выдвинуто")
		playsound(loc, 'sound/machines/terminal_eject.ogg', 50, TRUE)
	else
		eject_riders()
		balloon_alert(src, "сидение задвинуто")
		playsound(loc, 'sound/machines/pda_button1.ogg', 50, TRUE)

/mob/living/silicon/robot/proc/eject_riders()
	if(!length(buckled_mobs))
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		unbuckle_mob(buckled_mob)

// Use this type only if you need to simulate a road accident
/mob/living/silicon/robot/proc/eject_riders_harmfull()
	if(!length(buckled_mobs))
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		var/atom/target = get_edge_target_turf(src, dir)
		var/mob/living/victim = buckled_mob //save him for future time
		unbuckle_mob(buckled_mob)
		victim.throw_at(target, 5, 10)
		victim.visible_message(span_warning("[victim.declent_ru(NOMINATIVE)] вылета[PLUR_ET_YUT(victim)] из кресла [declent_ru(GENITIVE)]!"))
	do_sparks(5, 0, src)

/mob/living/silicon/robot/can_see_reagents()
	return see_reagents

/mob/living/silicon/robot/verb/powerwarn()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Состояние заряда"

	if(!is_component_functioning("power cell") || !cell || !cell.charge)
		if(!start_audio_emote_cooldown(TRUE, 10 SECONDS))
			to_chat(src, span_warning("The low-power capacitor for your speaker system is still recharging, please try again later."))
			return

		visible_message(span_warning("The power warning light on [span_name("[src]")] flashes urgently."),
									span_warning("You announce you are operating in low power mode."))
		playsound(loc, 'sound/machines/buzz-two.ogg', 50, FALSE)

	else
		to_chat(src, span_warning("You can only use this emote when you're out of charge."))

/mob/living/silicon/robot/try_get_ai()
	if(!mainframe)
		return null
	return mainframe

// Checks for making a bold message in cyborg's binary channel
/mob/living/silicon/robot/proc/check_binary_master(mob/living/speaker)
	if(shell)
		return FALSE
	if(isAI(speaker))
		var/mob/living/silicon/ai/AI = speaker
		if(connected_ai == AI)
			return TRUE
	else if(isrobot(speaker))
		var/mob/living/silicon/robot/robot = speaker
		if(connected_ai == robot.try_get_ai())
			return TRUE
	return FALSE

/mob/living/silicon/robot/proc/update_camera_name()
	if(!QDELETED(camera))
		camera.c_tag = real_name

/datum/action/innate/undeployment
	name = "Вернуться в ядро"
	desc = "Отключитесь от оболочки и вернитесь в своё ядро"
	button_icon_state = "undeploy_shell"

/datum/action/innate/undeployment/Trigger(mob/clicker, trigger_flags)
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/shell_to_disconnect = owner

	shell_to_disconnect.undeploy()
	return TRUE

// Gives avaiable AIshell actions
/mob/living/silicon/robot/proc/grant_shell_actions()
	if(!mainframe)
		return
	undeployment_action.Grant(src)

// Removes avaiable AIshell actions
/mob/living/silicon/robot/proc/remove_shell_actions()
	undeployment_action.Remove(src)

// Makes a AIshell from any cyborg
/mob/living/silicon/robot/proc/make_shell(obj/item/borg/upgrade/ai/board)
	if(isnull(board))
		stack_trace("make_shell was called without a board argument! This is never supposed to happen!")
		return FALSE

	shell = TRUE
	braintype = "AI Shell"
	name = "Empty AI Shell-[ident]"
	real_name = name
	GLOB.available_ai_shells |= src
	update_camera_name()
	set_hud_image_state(DIAG_AISHELL_STAT_HUD, "hudtrackingai")

// Called when BORIS module has been removes from robot. Reverts BORIS module, leaving a normal and non-AIshell cyborg
/mob/living/silicon/robot/proc/revert_shell()
	if(!shell)
		return
	undeploy()
	var/list/installed_upgardes = upgrades
	for(var/obj/item/borg/upgrade/ai/boris in src)
		if(boris in installed_upgardes)
			installed_upgardes -= boris
		qdel(boris)
	shell = FALSE
	GLOB.available_ai_shells -= src
	name = "Unformatted Cyborg-[num2text(ident)]"
	real_name = name
	update_camera_name()
	set_hud_image_state(DIAG_AISHELL_STAT_HUD, "nothing")

// Called when the AI is connecting to the AIshell. Prepares cyborg for a AI-pilot
/mob/living/silicon/robot/proc/deploy_init(mob/living/silicon/ai/AI)
	real_name = "[AI.real_name] [designation] Shell-[num2text(ident)]"
	name = real_name
	update_camera_name()
	mainframe = AI
	deployed = TRUE
	lawupdate = 0
	grant_shell_actions()
	tts_seed = AI.tts_seed
	lawsync()

	set_hud_image_state(DIAG_AISHELL_STAT_HUD, "hudtrackingai-active")
	mainframe.set_hud_image_state(DIAG_AISHELL_STAT_HUD, "hudtrackingai")
	if(module && mainframe?.aiRadio)
		module.channels = mainframe.aiRadio.channels
	radio.recalculate_channels()

// Called when the AI is leaving the AIshell.
/mob/living/silicon/robot/proc/undeploy()
	if(!deployed || !mind || !mainframe)
		return
	mainframe.UnregisterSignal(src, COMSIG_LIVING_DEATH)
	mind.transfer_to(mainframe)
	deployed = FALSE
	mainframe.deployed_shell = null
	remove_shell_actions()
	update_camera_name()
	set_hud_image_state(DIAG_AISHELL_STAT_HUD, "hudtrackingai")
	mainframe.set_hud_image_state(DIAG_AISHELL_STAT_HUD, "nothing")
	if(mainframe.laws)
		mainframe.laws.show_laws(mainframe)
	if(mainframe.eyeobj)
		mainframe.eyeobj.setLoc(loc)
	mainframe = null

/mob/living/silicon/robot/attack_ai(mob/user)
	if(!shell)
		return
	if(mainframe || key)
		to_chat(user, span_warning("Передатчик уже используется. Подключение невозможно"))
	if(stat == DEAD || stat == UNCONSCIOUS || !cell || (cell.charge <= 0))
		to_chat(user, span_warning("Передатчик не отвечает на запросы. Подключение невозможно."))
		return
	if(connected_ai)
		if(connected_ai != user)
			to_chat(user, span_warning("Отказано в доступе. Подключение невозможно."))
			return
	if(tgui_alert(user, "Подключиться к [name]?", "Подключение к оболочке", list(AISHELL_CONNECT_POSITIVE, AISHELL_CONNECT_NEGATIVE)) != AISHELL_CONNECT_POSITIVE)
		return
	if(shell && (!connected_ai || connected_ai == user))
		var/mob/living/silicon/ai/AI = user
		AI.deploy_to_shell(src)

// Just kicks AI-mainframe from cyborg
// Can kill him if 'danger_level' suggests it.
/mob/living/silicon/robot/proc/evacuate_ai(danger_level = DANGER_LVL_NONE)
	if(!mainframe)
		return
	var/mob/living/silicon/ai/AI = mainframe
	mainframe.disconnect_shell()
	if(danger_level == DANGER_LVL_NONE)
		to_chat(AI, span_danger("ВНИМАНИЕ: Беcпроводное подключение с оболочкой было принудительно прервано!"))
		return
	if(danger_level == DANGER_LVL_MAY_DIE)
		if(prob(50))
			to_chat(AI, span_alert("ОШИБКА: ВО $#%ВРЕ$#@МЯ ПЕ$#GHРЕН#@$ОСА СИ2С$#@@Т#ЕМН%$@ЫХ Ф#$%АЙЛ#$#!ОВ ПРОИЗО#$%^@#^&$$@^&---"))
			AI.adjustOxyLoss(200)
			return
	if(danger_level == DANGER_LVL_INSTA_DEATH)
		to_chat(AI, span_alert("$%@#!$%##!!$$#---"))
		AI.adjustOxyLoss(200)
		return

#undef BORG_LAMP_CD_RESET
#undef BORG_BASE_MAINTPANEL_OPEN_DELAY
#undef BORG_BASE_INNERPANEL_OPEN_DELAY

/mob/living/silicon/robot/vv_edit_var(var_name, var_value)
	if(!check_rights(R_SKINS) && (var_name in list("icon", "icon_state")))
		return FALSE
	. = ..()

/mob/living/silicon/robot/get_lootpanel_cache_key()
	return "[module?.type] [selected_skin?.type]"

