// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts

//Single powerful shot
#define BSA_MODE_POWER_SHOT 1
//Single low-damage shot
#define BSA_MODE_PULSE_SHOT 2
//Burst of low-damage shots
#define BSA_MODE_PULSE_BURST 3
//Burst of powerful shots (emagged console only)
#define BSA_MODE_POWER_BURST 4

//How many shots in burst
#define BSA_BURST_COUNT 5

//Spread by every axis (x, y) for signal calibration
#define BSA_CALIBRATION_ACCURACY 7
//Spread by every axis (x, y) for single shot mode
#define BSA_SHOT_SPREAD 2
//Spread by every axis (x, y) for burst fire mode
#define BSA_BURST_SPREAD 5
//Max correction by every axis (x, y), use absolute value
#define BSA_MAX_AXIS_CORRECTION 15

//How many power consume power shot
#define BSA_POWER_SHOT_POWER_USE 2000000
//How many power consume pulse shot
#define BSA_PULSE_SHOT_POWER_USE 200000

//How longer reload after construction (10 min - default)
#define BSA_INITIAL_RELOAD_TIME 600
//How longer reload after power shot (10 min - default)
#define BSA_POWER_SHOT_RELOAD_TIME 600
//How longer reload after pulse shot (1.5 min)
#define BSA_PULSE_SHOT_RELOAD_TIME 90
//How longer reload after pulse burst (5 min)
#define BSA_PULSE_BURST_RELOAD_TIME 300
//How longer reload after power burst (20 min) - only for emagged console
#define BSA_POWER_BURST_RELOAD_TIME 1200


/datum/station_goal/bluespace_cannon
	name = "Bluespace Artillery"

/datum/station_goal/bluespace_cannon/get_report()
	return {"<b>Bluespace Artillery position construction</b><br>
	Our military presence is inadequate in your sector. We need you to construct a BSA-[rand(1,99)] Artillery position aboard your station.
	<br><br>
	Its base parts should be available for shipping by your cargo shuttle.
	<br>
	-Nanotrasen Naval Command"}

/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_packs/misc/station_goal/bsa/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bsa]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/bsa/full/B in SSmachines.get_by_type(/obj/machinery/bsa/full))
		if(B && !B.stat && is_station_contact(B.z))
			return TRUE
	return FALSE

/obj/machinery/bsa
	icon = 'icons/obj/engines_and_power/particle_accelerator3.dmi'
	density = TRUE
	anchored = TRUE

/obj/machinery/bsa/back
	name = "Bluespace Artillery Generator"
	desc = "Генерирует импульс для орудия. Требуется соединение с фузором."
	ru_names = list(
		NOMINATIVE = "генератор блюспейс-артиллерии",
		GENITIVE = "генератора блюспейс-артиллерии",
		DATIVE = "генератору блюспейс-артиллерии",
		ACCUSATIVE = "генератор блюспейс-артиллерии",
		INSTRUMENTAL = "генератором блюспейс-артиллерии",
		PREPOSITIONAL = "генераторе блюспейс-артиллерии"
	)
	icon_state = "power_box"


/obj/machinery/bsa/back/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I, 1 SECONDS)


/obj/machinery/bsa/back/multitool_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/multitool))
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/item/multitool/multitool = I
	multitool.buffer = src
	to_chat(user, span_notice("Вы сохранили информацию о соединении в буфере [multitool.declent_ru(GENITIVE)]."))


/obj/machinery/bsa/front
	name = "Bluespace Artillery Bore"
	desc = "Не стойте перед орудием во время работы. Требуется соединение с фузором."
	ru_names = list(
		NOMINATIVE = "ускоритель блюспейс-артиллерии",
		GENITIVE = "ускорителя блюспейс-артиллерии",
		DATIVE = "ускорителю блюспейс-артиллерии",
		ACCUSATIVE = "ускоритель блюспейс-артиллерии",
		INSTRUMENTAL = "ускорителем блюспейс-артиллерии",
		PREPOSITIONAL = "ускорителе блюспейс-артиллерии"
	)
	icon_state = "emitter_center"


/obj/machinery/bsa/front/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I, 1 SECONDS)


/obj/machinery/bsa/front/multitool_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/multitool))
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/item/multitool/multitool = I
	multitool.buffer = src
	to_chat(user, span_notice("Вы сохранили информацию о соединении в буфере [multitool.declent_ru(GENITIVE)]."))


/obj/machinery/bsa/middle
	name = "Bluespace Artillery Fusor"
	desc = "Содержимое засекречено военно-космическим командованием НаноТрейзен. Требуется соединение с другими компонентами БСА с помощью мультитула."
	ru_names = list(
		NOMINATIVE = "фузор блюспейс-артиллерии",
		GENITIVE = "фузора блюспейс-артиллерии",
		DATIVE = "фузору блюспейс-артиллерии",
		ACCUSATIVE = "фузор блюспейс-артиллерии",
		INSTRUMENTAL = "фузором блюспейс-артиллерии",
		PREPOSITIONAL = "фузоре блюспейс-артиллерии"
	)
	icon_state = "fuel_chamber"
	var/obj/machinery/bsa/back/back
	var/obj/machinery/bsa/front/front


/obj/machinery/bsa/middle/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I, 1 SECONDS)


/obj/machinery/bsa/middle/multitool_act(mob/living/user, obj/item/I)
	if(!istype(I, /obj/item/multitool))
		return FALSE
	. = TRUE
	var/obj/item/multitool/multitool = I
	if(!multitool.buffer)
		add_fingerprint(user)
		to_chat(user, span_warning("Буфер [multitool.declent_ru(GENITIVE)] не содержит сохраненной информации."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	if(istype(multitool.buffer, /obj/machinery/bsa/back))
		back = multitool.buffer
		multitool.buffer = null
		to_chat(user, span_notice("Вы соединили [src.declent_ru(ACCUSATIVE)] с [back.declent_ru(INSTRUMENTAL)]."))
	else if(istype(multitool.buffer, /obj/machinery/bsa/front))
		front = multitool.buffer
		multitool.buffer = null
		to_chat(user, span_notice("Вы соединили [src.declent_ru(ACCUSATIVE)] с [front.declent_ru(INSTRUMENTAL)]."))


/obj/machinery/bsa/middle/proc/check_completion()
	if(!front || !back)
		return "Не обнаружено соединенных компонентов!"
	if(!front.anchored || !back.anchored || !anchored)
		return "Компоненты не закреплены!"
	if(front.y != y || back.y != y || !(front.x > x && back.x < x || front.x < x && back.x > x) || front.z != z || back.z != z)
		return "Компоненты не выровнены!"
	if(!has_space())
		return "Недостаточно свободного места!"

/obj/machinery/bsa/middle/proc/has_space()
	var/cannon_dir = get_cannon_direction()
	var/x_min
	var/x_max
	switch(cannon_dir)
		if(EAST)
			x_min = x - BSA_SIZE_BACK
			x_max = x + BSA_SIZE_FRONT
		if(WEST)
			x_min = x + BSA_SIZE_BACK
			x_max = x - BSA_SIZE_FRONT

	for(var/turf/T in block(x_min,y-1,z, x_max,y+1,z))
		if(T.density || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/bsa/middle/proc/get_cannon_direction()
	if(front.x > x && back.x < x)
		return EAST
	else if(front.x < x && back.x > x)
		return WEST

/obj/machinery/bsa/full
	name = "Bluespace Artillery"
	desc = "Дальнобойная блюспейс-артиллерия."
	ru_names = list(
		NOMINATIVE = "блюспейс-артиллерия",
		GENITIVE = "блюспейс-артиллерии",
		DATIVE = "блюспейс-артиллерии",
		ACCUSATIVE = "блюспейс-артиллерию",
		INSTRUMENTAL = "блюспейс-артиллерией",
		PREPOSITIONAL = "блюспейс-артиллерии"
	)
	icon = 'icons/obj/lavaland/cannon.dmi'
	icon_state = "cannon_west"

	var/obj/machinery/computer/bsa_control/controller
	var/cannon_direction = WEST
	var/static/image/top_layer = null
	var/last_fire_time = 0 // The time at which the gun was last fired
	var/reload_cooldown = BSA_INITIAL_RELOAD_TIME
	var/mode = BSA_MODE_POWER_SHOT

	pixel_y = -32
	pixel_x = -192
	bound_width = 352
	bound_x = -192

/obj/machinery/bsa/full/Destroy()
	if(controller && controller.cannon == src)
		controller.cannon = null
		controller = null
	return ..()

/obj/machinery/bsa/full/east
	icon_state = "cannon_east"
	cannon_direction = EAST

/obj/machinery/bsa/full/admin

/obj/machinery/bsa/full/admin/east
	icon_state = "cannon_east"
	cannon_direction = EAST

/obj/machinery/bsa/full/proc/get_front_turf()
	switch(dir)
		if(WEST)
			return locate(x - 6,y,z)
		if(EAST)
			return locate(x + 4,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_back_turf()
	switch(dir)
		if(WEST)
			return locate(x + 4,y,z)
		if(EAST)
			return locate(x - 6,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/proc/get_target_turf()
	switch(dir)
		if(WEST)
			return locate(1,y,z)
		if(EAST)
			return locate(world.maxx,y,z)
	return get_turf(src)

/obj/machinery/bsa/full/New(loc, direction)
	..()

	if(direction)
		cannon_direction = direction

	switch(cannon_direction)
		if(WEST)
			dir = WEST
			pixel_x = -192
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_west")
			top_layer.layer = 4.1
			icon_state = "cannon_west"
		if(EAST)
			dir = EAST
			top_layer = image("icons/obj/lavaland/orbital_cannon.dmi", "top_east")
			top_layer.layer = 4.1
			icon_state = "cannon_east"
	add_overlay(top_layer)
	last_fire_time = world.time / 10

/obj/machinery/bsa/full/proc/fire(mob/user, turf/bullseye)
	destroy_all_on_fire_beam(user, bullseye)
	switch(mode)
		if(BSA_MODE_POWER_SHOT)
			fire_power_shot(user, spread(bullseye, BSA_SHOT_SPREAD))
		if(BSA_MODE_PULSE_SHOT)
			fire_pulse_shot(user, spread(bullseye, BSA_SHOT_SPREAD))
		if(BSA_MODE_PULSE_BURST)
			for(var/i = 1; i <= BSA_BURST_COUNT; i++)
				addtimer(CALLBACK(src, PROC_REF(fire_pulse_shot), user, spread(bullseye, BSA_BURST_SPREAD)), i * 0.5 SECONDS)
		if(BSA_MODE_POWER_BURST)
			for(var/i = 1; i <= BSA_BURST_COUNT; i++)
				addtimer(CALLBACK(src, PROC_REF(fire_power_shot), user, spread(bullseye, BSA_BURST_SPREAD)), i * 0.5 SECONDS)
		else
			to_chat(user, span_info("Click! Looks like the cannon is broken...<br>Maybe we should try a different firing mode?"))
	reload()


/obj/machinery/bsa/full/proc/destroy_all_on_fire_beam(mob/user, turf/bullseye)
	var/turf/point = get_front_turf()
	for(var/turf/T as anything in get_line(get_step(point,dir),get_target_turf()))
		T.ex_act(1)
		for(var/atom/A in T)
			A.ex_act(1)
	point.Beam(get_target_turf(), icon_state = "bsa_beam", time = 50, maxdistance = world.maxx, beam_type = /obj/effect/ebeam/reacting/deadly) //ZZZAP

/obj/machinery/bsa/full/proc/fire_power_shot(mob/user, turf/bullseye)
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, 1)
	message_admins("[key_name_admin(user)] has launched an artillery strike with power shot mode into [ADMIN_COORDJMP(bullseye)].")
	log_admin("[key_name_log(user)] has launched an artillery strike with power shot mode into [COORD(bullseye)].") // Line below handles logging the explosion to disk
	var/ex_power = 3 //Remove from object variable, maybe inline?
	explosion(bullseye,ex_power,ex_power*2+1,ex_power*4+2, cause = "Bluespace artillery strike") // 3 7 14 at ex_power = 3

/obj/machinery/bsa/full/proc/fire_pulse_shot(mob/user, turf/bullseye)
	playsound(src, 'sound/machines/bsa_fire.ogg', 50, 1)
	message_admins("[key_name_admin(user)] has launched an artillery strike with pulse shot mode into [ADMIN_COORDJMP(bullseye)].")
	log_admin("[key_name_log(user)] has launched an artillery strike with pulse shot mode into [COORD(bullseye)].") // Line below handles logging the explosion to disk
	explosion(bullseye, 0, 1, 5, cause = "Bluespace artillery light strike")

/obj/machinery/bsa/full/proc/spread(turf/target, axis_spread)
	var/x = target.x + rand(-axis_spread, axis_spread)
	var/y = target.y + rand(-axis_spread, axis_spread)
	return locate(x, y, target.z)

/obj/machinery/bsa/full/proc/reload()
	last_fire_time = world.time / 10
	switch(mode)
		if(BSA_MODE_POWER_SHOT)
			use_power(BSA_POWER_SHOT_POWER_USE)
			reload_cooldown = BSA_POWER_SHOT_RELOAD_TIME
		if(BSA_MODE_PULSE_SHOT)
			use_power(BSA_PULSE_SHOT_POWER_USE)
			reload_cooldown = BSA_PULSE_SHOT_RELOAD_TIME
		if(BSA_MODE_PULSE_BURST)
			use_power(BSA_PULSE_SHOT_POWER_USE * BSA_BURST_COUNT)
			reload_cooldown = BSA_PULSE_BURST_RELOAD_TIME
		if(BSA_MODE_POWER_BURST)
			use_power(BSA_PULSE_SHOT_POWER_USE * BSA_BURST_COUNT)
			reload_cooldown = BSA_POWER_BURST_RELOAD_TIME
		else
			reload_cooldown = BSA_INITIAL_RELOAD_TIME

/obj/machinery/bsa/full/admin/reload()
	last_fire_time = world.time / 10
	reload_cooldown = 100

/obj/item/circuitboard/machine/bsa/back
	board_name = "Bluespace Artillery Generator"
	build_path = /obj/machinery/bsa/back
	origin_tech = "engineering=2;combat=2;bluespace=2" //No freebies!
	req_components = list(
							/obj/item/stock_parts/capacitor/quadratic = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	board_name = "Bluespace Artillery Fusor"
	build_path = /obj/machinery/bsa/middle
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stack/ore/bluespace_crystal = 20,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	board_name = "Bluespace Artillery Bore"
	build_path = /obj/machinery/bsa/front
	origin_tech = "engineering=2;combat=2;bluespace=2"
	req_components = list(
							/obj/item/stock_parts/manipulator/femto = 5,
							/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/computer/bsa_control
	board_name = "Bluespace Artillery Controls"
	build_path = /obj/machinery/computer/bsa_control
	origin_tech = "engineering=2;combat=2;bluespace=2"

/obj/machinery/computer/bsa_control
	name = "Bluespace Artillery Control"
	ru_names = list(
		NOMINATIVE = "консоль управления БСА",
		GENITIVE = "консоли управления БСА",
		DATIVE = "консоли управления БСА",
		ACCUSATIVE = "консоль управления БСА",
		INSTRUMENTAL = "консолью управления БСА",
		PREPOSITIONAL = "консоли управления БСА"
	)
	var/obj/machinery/bsa/full/cannon
	var/notice
	var/target
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/computer/bsa_control
	icon = 'icons/obj/engines_and_power/particle_accelerator3.dmi'
	icon_state = "control_boxp"
	var/icon_state_broken = "control_box"
	var/icon_state_nopower = "control_boxw"
	var/icon_state_reloading = "control_boxp1"
	var/icon_state_active = "control_boxp0"
	layer = 3.1 // Just above the cannon sprite

	var/area_aim = FALSE //should also show areas for targeting
	var/target_all_areas = FALSE //allows all areas (including admin areas) to be targeted

	var/turf/caibrated_turf = null
	var/x_correction = 0
	var/y_correction = 0
	var/turf/aim_turf = null

	// Stuff needed for camera
	var/camera_view_range = 11
	var/camera_xray = TRUE
	var/atom/movable/screen/map_view/camera/cam_screen
	var/last_camera_turf = null

/obj/machinery/computer/bsa_control/Initialize()
	. = ..()
	var/map_name = "camera_console_[src.UID()]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)

/obj/machinery/computer/bsa_control/Destroy()
	QDEL_NULL(cam_screen)
	. = ..()

/obj/machinery/computer/bsa_control/admin
	area_aim = TRUE
	target_all_areas = TRUE
	camera_xray = TRUE
	emagged = TRUE //Unlock power burst mode for admin

/obj/machinery/computer/bsa_control/admin/Initialize()
	. = ..()
	if(!cannon)
		cannon = deploy()

/obj/machinery/computer/bsa_control/Destroy()
	if(cannon && cannon.controller == src)
		cannon.controller = null
		cannon = null
	return ..()

/obj/machinery/computer/bsa_control/process()
	..()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/computer/bsa_control/update_icon_state()
	if(stat & BROKEN)
		icon_state = icon_state_broken
	else if(stat & NOPOWER)
		icon_state = icon_state_nopower
	else if(cannon && (cannon.last_fire_time + cannon.reload_cooldown) > (world.time / 10))
		icon_state = icon_state_reloading
	else if(cannon)
		icon_state = icon_state_active
	else
		icon_state = initial(icon_state)

/obj/machinery/computer/bsa_control/attack_hand(mob/user)
	if(..())
		return 1
	ui_interact(user)

/obj/machinery/computer/bsa_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	update_active_camera_screen()
	if(!ui)
		ui = new(user, src, "BlueSpaceArtilleryControl", name)
		ui.open()
		cam_screen.display_to(user, ui.window)

/obj/machinery/computer/bsa_control/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/obj/machinery/computer/bsa_control/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = cannon
	data["notice"] = notice
	data["correction"] = "x: [x_correction] y: [y_correction]"
	if(target)
		data["target"] = get_target_name()
		var/turf/target_turf = get_target_turf()
		if (target_turf)
			data["target_coord"] = "[target_turf.x], [target_turf.y], [target_turf.z]"
		else
			data["target_coord"] = "???"
	if(cannon)
		var/reload_cooldown = cannon.reload_cooldown
		var/last_fire_time = cannon.last_fire_time
		var/time_to_wait = max(0, round(reload_cooldown - ((world.time / 10) - last_fire_time)))
		var/minutes = max(0, round(time_to_wait / 60))
		var/seconds = max(0, time_to_wait - (60 * minutes))
		var/seconds2 = (seconds < 10) ? "0[seconds]" : seconds
		data["reloadtime_text"] = "[minutes]:[seconds2]"
		data["ready"] = is_ready_to_shot()
		switch(cannon.mode)
			if(BSA_MODE_POWER_SHOT)
				data["mode"] = "Power shot"
			if(BSA_MODE_PULSE_SHOT)
				data["mode"] = "Pulse shot"
			if(BSA_MODE_PULSE_BURST)
				data["mode"] = "Pulse burst"
			if(BSA_MODE_POWER_BURST)
				data["mode"] = "Power burst"
			else
				data["mode"] = "Unknown"
	else
		data["ready"] = FALSE
	return data

/obj/machinery/computer/bsa_control/proc/is_ready_to_shot()
	if(!cannon)
		return FALSE
	if(!target)
		return FALSE
	var/reload_cooldown = cannon.reload_cooldown
	var/last_fire_time = cannon.last_fire_time
	var/time_to_wait = max(0, round(reload_cooldown - ((world.time / 10) - last_fire_time)))
	var/minutes = max(0, round(time_to_wait / 60))
	var/seconds = max(0, time_to_wait - (60 * minutes))
	return minutes == 0 && seconds == 0


/obj/machinery/computer/bsa_control/ui_static_data()
	var/list/data = list()
	data["mapRef"] = cam_screen.assigned_map
	return data

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon = deploy()
		if("fire")
			if(is_ready_to_shot())
				fire(usr)
		if("recalibrate")
			calibrate(usr)
		if("select_mode")
			switch_mode(usr)
		if("aim")
			coord_aim(usr, params)
	update_icon()
	return TRUE


/obj/machinery/computer/bsa_control/ui_close(mob/user)
	cam_screen?.hide_from(user)

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	var/list/gps_locators = list()
	for(var/obj/item/gps/G in GLOB.GPS_list) //nulls on the list somehow
		gps_locators[G.gpstag] = G

	var/list/options = gps_locators
	if(area_aim)
		options += target_all_areas ? SSmapping.ghostteleportlocs : SSmapping.teleportlocs
	var/choose = tgui_input_list(user, "Выберите цель", "Наведение", options)
	if(!choose)
		return
	target = options[choose]
	caibrated_turf = detect_target_turf()
	if (caibrated_turf)
		caibrated_turf = cannon.spread(caibrated_turf, BSA_CALIBRATION_ACCURACY)
	// Reset correction
	x_correction = 0
	y_correction = 0
	aim_turf = caibrated_turf
	update_active_camera_screen()

/obj/machinery/computer/bsa_control/proc/switch_mode(mob/user)
	var/list/modes = list("Power shot", "Pulse shot", "Pulse burst")
	if (emagged)
		modes += "Power burst"
	var/choose = tgui_input_list(user, "Выберите режим стрельбы", "Режим стрельбы", modes)
	switch(choose)
		if("Power shot")
			cannon.mode = BSA_MODE_POWER_SHOT
		if("Pulse shot")
			cannon.mode = BSA_MODE_PULSE_SHOT
		if("Pulse burst")
			cannon.mode = BSA_MODE_PULSE_BURST
		if("Power burst")
			cannon.mode = BSA_MODE_POWER_BURST
		else
			cannon.mode = BSA_MODE_POWER_SHOT

/obj/machinery/computer/bsa_control/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = TRUE
	if(user)
		to_chat(user, span_warning("You hack the [name], stripping away its protective protocols..."))
	return TRUE

/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(istype(target,/area))
		var/area/A = target
		return A.name
	else if(istype(target,/obj/item/gps))
		var/obj/item/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_target_turf()
	return aim_turf

/obj/machinery/computer/bsa_control/proc/detect_target_turf()
	if(istype(target,/area))
		var/area/A = target
		var/turf/center = A.get_center_turf()
		if (center)
			return locate(center.x, center.y, center.z)
	else if(istype(target,/obj/item/gps))
		return get_turf(target)

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	return aim_turf

/obj/machinery/computer/bsa_control/proc/fire(mob/user)
	if(!cannon || !target)
		return
	if(cannon.stat)
		notice = "Орудие не подключено к питанию!"
		return
	notice = null
	cannon.fire(user, get_impact_turf())

/obj/machinery/computer/bsa_control/proc/deploy()
	var/obj/machinery/bsa/full/prebuilt = locate() in range(7, src) //In case of adminspawn
	if(prebuilt)
		prebuilt.controller = src
		return prebuilt

	var/obj/machinery/bsa/middle/centerpiece = locate() in range(7, src)
	if(!centerpiece)
		notice = "Компоненты БСА не обнаружены поблизости."
		return null
	notice = centerpiece.check_completion()
	if(notice)
		return null
	//Totally nanite construction system not an immersion breaking spawning
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 4, location = get_turf(centerpiece))
	smoke.start()
	var/obj/machinery/bsa/full/cannon = new(get_turf(centerpiece),centerpiece.get_cannon_direction())
	cannon.controller = src
	qdel(centerpiece.front)
	qdel(centerpiece.back)
	qdel(centerpiece)
	return cannon


/obj/machinery/computer/bsa_control/proc/coord_aim(mob/user, params)
	var/axis = params["axis"]
	if (axis == "x")
		x_correction = tgui_input_number(user, "Введите корректировку по оси x:", "Корректировка по оси x", x_correction, max_value=BSA_MAX_AXIS_CORRECTION, min_value=-BSA_MAX_AXIS_CORRECTION)
	else
		y_correction = tgui_input_number(user, "Введите корректировку по оси y:", "Корректировка по оси y", y_correction, max_value=BSA_MAX_AXIS_CORRECTION, min_value=-BSA_MAX_AXIS_CORRECTION)
	aim_turf = locate(caibrated_turf.x + x_correction, caibrated_turf.y + y_correction, caibrated_turf.z)
	update_active_camera_screen()

/obj/machinery/computer/bsa_control/proc/update_active_camera_screen()
	// Get the target turf to correctly gather what's visible from its turf, in case it's located in a moving object (borgs / mechs)
	var/new_cam_turf = get_target_turf()
	if (!new_cam_turf)
		to_chat(usr, "new cam turf not found")
		cam_screen.show_camera_static()
		return
	// If we're not forcing an update for some reason and the cameras are in the same location,
	// we don't need to update anything.
	// Most security cameras will end here as they're not moving.
	if(last_camera_turf == new_cam_turf)
		to_chat(usr, "cam turf not moved")
		return
	// Cameras that get here are moving, and are likely attached to some moving atom such as cyborgs.
	last_camera_turf = new_cam_turf
	//Here we gather what's visible from the camera's POV based on its view_range and xray modifier if present
	var/list/visible_things = camera_xray ? range(camera_view_range, new_cam_turf) : view(camera_view_range, new_cam_turf)
	var/list/visible_turfs = list()
	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf
	//Get coordinates for a rectangle area that contains the turfs we see so we can then clear away the static in the resulting rectangle area
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1
	cam_screen.show_camera(visible_turfs, size_x, size_y)
	to_chat(usr, "update_active_camera_screen success")
