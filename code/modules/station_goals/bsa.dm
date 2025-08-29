// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts


/// Delay between shots in burst mode
#define BSA_BURST_SHOT_DELAY 0.5
/// Spread by every axis (x, y) for signal calibration
#define BSA_CALIBRATION_ACCURACY 7
/// Spread by every axis (x, y) for single shot mode
#define BSA_SHOT_SPREAD 1
/// Spread by every axis (x, y) for burst fire mode
#define BSA_BURST_SPREAD 4
/// Max correction by every axis (x, y), use absolute value
#define BSA_MAX_AXIS_CORRECTION 15
/// How longer reload after construction (10 sec)
#define BSA_CALIBRATE_TIME 10
/// Delay between firing and impact on the target
#define BSA_IMPACT_DELAY 3
/// Laser notification duration before bsa strike (must be less than BSA_IMPACT_DELAY)
#define BSA_IMPACT_LASER_NOTIFY_BEFORE 1
/// Radius of notification about bsa strike
#define BSA_IMPACT_NOTIFY_RADIUS 10
/// Delay between last strike and check goal complete
#define BSA_AFTER_STRIKE_GOACL_CHECK_DELAY 3
/// Cooldown after bsa building
#define BSA_INITIAL_COOLDOWN 600

GLOBAL_LIST_EMPTY(BSA_modes_list)

/// BSA fire mode
/datum/bluespace_cannon_fire_mode
	var/name
	var/spread
	var/power_use
	var/reload_duration
	var/list/power
	var/need_emag = FALSE

/datum/bluespace_cannon_fire_mode/burst
	var/shots_count
	var/delay_between_shots = BSA_BURST_SHOT_DELAY


/datum/bluespace_cannon_fire_mode/proc/fire(obj/machinery/bsa/full/cannon, mob/user, turf/target, target_signal)
	var/turf/impact_turf = cannon.spread(target, spread)
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, TRUE)
	addtimer(CALLBACK(cannon, TYPE_PROC_REF(/obj/machinery/bsa/full, incoming_shot_aim), impact_turf), (BSA_IMPACT_DELAY - BSA_IMPACT_LASER_NOTIFY_BEFORE) SECONDS)
	addtimer(CALLBACK(src, PROC_REF(create_explosion), user, impact_turf), BSA_IMPACT_DELAY SECONDS)
	addtimer(CALLBACK(cannon, TYPE_PROC_REF(/obj/machinery/bsa/full, check_goal_complete), target_signal), (BSA_IMPACT_DELAY + BSA_AFTER_STRIKE_GOACL_CHECK_DELAY) SECONDS)

/datum/bluespace_cannon_fire_mode/burst/fire(obj/machinery/bsa/full/cannon, mob/user, turf/target, target_signal)
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, TRUE)
	for(var/i = 0; i < shots_count; i++)
		var/turf/impact_turf = cannon.spread(target, spread)
		var/delay = BSA_IMPACT_DELAY + i * delay_between_shots
		addtimer(CALLBACK(cannon, TYPE_PROC_REF(/obj/machinery/bsa/full, incoming_shot_aim), impact_turf), (delay - BSA_IMPACT_LASER_NOTIFY_BEFORE) SECONDS)
		addtimer(CALLBACK(src, PROC_REF(create_explosion), user, impact_turf), delay SECONDS)
	var/check_goal_delay = BSA_IMPACT_DELAY + (shots_count - 1) * delay_between_shots + BSA_AFTER_STRIKE_GOACL_CHECK_DELAY
	addtimer(CALLBACK(cannon, TYPE_PROC_REF(/obj/machinery/bsa/full, check_goal_complete), target_signal), check_goal_delay SECONDS)

/datum/bluespace_cannon_fire_mode/proc/create_explosion(mob/user, turf/impact_turf)
	message_admins("[key_name_admin(user)] has launched an artillery strike with power=([power[1]],[power[2]],[power[3]]) into [ADMIN_COORDJMP(impact_turf)].")
	log_admin("[key_name_log(user)] has launched an artillery strike with power=([power[1]],[power[2]],[power[3]]) mode into [COORD(impact_turf)].") // Line below handles logging the explosion to disk
	explosion(impact_turf, devastation_range = power[1], heavy_impact_range = power[2], light_impact_range = power[3], cause = "Bluespace artillery strike")


/datum/bluespace_cannon_fire_mode/power
	name = "Мощный выстрел"
	spread = BSA_SHOT_SPREAD
	power_use = 2000000
	reload_duration = 600
	power = list(3, 7, 14)

/datum/bluespace_cannon_fire_mode/burst/power
	name = "Мощная очередь"
	spread = BSA_BURST_SPREAD
	power_use = 6000000
	reload_duration = 1200
	power = list(3, 7, 14)
	need_emag = TRUE
	shots_count = 3

/datum/bluespace_cannon_fire_mode/pulse
	name = "Слабый выстрел"
	spread = BSA_SHOT_SPREAD
	power_use = 200000
	reload_duration = 90
	power = list(0, 1, 5)

/datum/bluespace_cannon_fire_mode/burst/pulse
	name = "Слабая очередь"
	spread = BSA_BURST_SPREAD
	power_use = 1000000
	reload_duration = 300
	power = list(0, 1, 5)
	shots_count = 5


/// BSA Cannon
/datum/station_goal/bluespace_cannon
	name = "Блюспейс Артиллерия"

/datum/station_goal/bluespace_cannon/get_report()
	if(SSmapping.lavaland_theme.lavaland_type == LAVALAND_TYPE_PLASMA)
		return {"<b>Постройка Блюспейс Артиллерии</b><br>
			Вам необходимо построить Блюспейс Артиллерию №[rand(1,99)]. \
			После постройки необходимо проверить работоспособность выстрелив по любой цели.
			<br><br>
			Основные части артиллерии должны быть доступны для заказа в отделе снабжения.
			<br>
			– Центральное Командование Nanotrasen"}
	return {"<b>Смена цикла Лазиса</b><br>
		Вам необходимо построить Блюспейс Артиллерию №[rand(1,99)]. \
		После постройки необходимо выстрелить по огромному месторождению плазмы на Лазисе, отмеченному как \"[/obj/item/gps/internal/bfl_crack::gpstag]\"".
		<br><br>
		Основные части артиллерии должны быть доступны для заказа в отделе снабжения.
		<br>
		– Центральное Командование Nanotrasen"}


/datum/station_goal/bluespace_cannon/on_report()
	//Unlock BSA parts
	var/datum/supply_packs/misc/station_goal/bsa/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/bsa]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

/datum/station_goal/bluespace_cannon/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/bsa/full/bsa in SSmachines.get_by_type(/obj/machinery/bsa/full))
		if(bsa.bfl_crack_fired)
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
	var/bfl_crack_fired = FALSE
	var/last_fire_time = 0 // The time at which the gun was last fired
	var/last_calibrate_time = 0 // The time at which the gun was last fired
	var/reload_cooldown = BSA_INITIAL_COOLDOWN
	var/datum/bluespace_cannon_fire_mode/mode

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

/obj/machinery/bsa/full/proc/fire(mob/user, turf/target, target_signal)
	if(!mode)
		to_chat(user, span_warning("Клик! Осечка?!<br>Может стоит поставить другой режим стрельбы?"))
		return
	destroy_all_on_fire_beam(user, target)
	incoming_shot_notify(target)
	mode.fire(src, user, target, target_signal)
	reload()

/obj/machinery/bsa/full/proc/destroy_all_on_fire_beam(mob/user, turf/bullseye)
	var/turf/point = get_front_turf()
	for(var/turf/T as anything in get_line(get_step(point,dir),get_target_turf()))
		T.ex_act(1)
		for(var/atom/A in T)
			A.ex_act(1)
	point.Beam(get_target_turf(), icon_state = "bsa_beam", time = 50, maxdistance = world.maxx, beam_type = /obj/effect/ebeam/reacting/deadly) //ZZZAP

/obj/machinery/bsa/full/proc/incoming_shot_notify(turf/target)
	playsound(target, 'sound/weapons/gun_mortar_travel.ogg', 75, 1)
	for(var/mob/mob in range(BSA_IMPACT_NOTIFY_RADIUS, target))
		mob.show_message( \
			span_danger("Что-то приближается к вам сверху!"), EMOTE_VISIBLE, \
			span_danger("Вы слышите приближающийся гул!"), EMOTE_AUDIBLE \
		)

/obj/machinery/bsa/full/proc/incoming_shot_aim(turf/target)
	new /obj/effect/overlay/temp/blinking_laser(target)

/obj/machinery/bsa/full/proc/check_goal_complete(target_signal)
	// if lavaland is plasma, goal complete after any shot
	if(SSmapping.lavaland_theme.lavaland_type == LAVALAND_TYPE_PLASMA)
		bfl_crack_fired = TRUE
		return
	// else check target gps
	if(!istype(target_signal, /obj/item/gps/internal/bfl_crack))
		return
	// Fire at target gps - change lavaland to plasma
	bfl_crack_fired = TRUE
	to_chat(usr, span_big("Вы замечаете как планета начинается трястись!"))
	set_lazis_type(/datum/lavaland_theme/plasma)

/obj/machinery/bsa/full/proc/spread(turf/target, axis_spread)
	var/x = target.x + rand(-axis_spread, axis_spread)
	var/y = target.y + rand(-axis_spread, axis_spread)
	return locate(x, y, target.z)

/obj/machinery/bsa/full/proc/reload()
	last_fire_time = world.time / 10
	if(!mode)
		return
	use_power(mode.power_use)
	reload_cooldown = mode.reload_duration

/obj/machinery/bsa/full/proc/calibrate()
	last_calibrate_time = world.time / 10

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
	var/image/crosshair

/obj/machinery/computer/bsa_control/Initialize(mapload)
	. = ..()
	var/map_name = "camera_console_[src.UID()]_map"
	// Initialize map objects
	cam_screen = new
	cam_screen.generate_view(map_name)
	crosshair = image('icons/obj/supplypods_32x32.dmi', "LZ", get_turf(src))
	crosshair.layer = CAMERA_STATIC_LAYER
	crosshair.plane = MASSIVE_OBJ_PLANE
	crosshair.appearance_flags = PIXEL_SCALE
	crosshair.transform = matrix(4, 4, MATRIX_SCALE)

/obj/machinery/computer/bsa_control/Destroy()
	QDEL_NULL(cam_screen)
	qdel(crosshair)
	. = ..()

/obj/machinery/computer/bsa_control/admin
	area_aim = TRUE
	target_all_areas = TRUE
	camera_xray = TRUE
	emagged = TRUE // Unlock power burst mode for admin

/obj/machinery/computer/bsa_control/admin/Initialize(mapload)
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
	else if(cannon && (!is_reload_ready() || !target || !is_calibrate_ready()))
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
		ui = new(user, src, "BlueSpaceArtilleryControl", "Консоль управления БСА")
		ui.open()
		cam_screen.display_to(user, ui.window)
		user.client.images += crosshair

/obj/machinery/computer/bsa_control/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. == UI_DISABLED)
		return UI_CLOSE
	return .

/obj/machinery/computer/bsa_control/ui_data(mob/user)
	var/list/data = list()
	data["modal"] = ui_modal_data(src)
	data["connected"] = cannon
	data["notice"] = notice
	if(!cannon)
		return data
	data["power"] = !cannon.stat
	data["reload_ready"] = is_reload_ready()
	data["reloadtime_text"] = get_reloading_time()
	data["calibrate_ready"] = is_calibrate_ready()
	data["calibrate_duration"] = get_calibrating_duration()
	data["correction_x"] = x_correction
	data["correction_y"] = y_correction
	data["ready"] = is_ready_to_shot()
	if(cannon.mode)
		data["mode"] = cannon.mode.name
	else
		data["mode"] = "Не выбран"
	if(!target)
		return data
	data["calibrated"] = TRUE
	data["target"] = get_target_name()
	var/turf/target_turf = get_target_turf()
	if(target_turf)
		data["target_coord"] = "[target_turf.x], [target_turf.y], [target_turf.z]"
	else
		data["target_coord"] = "???"
	return data

/obj/machinery/computer/bsa_control/proc/is_reload_ready()
	if(!cannon)
		return FALSE
	return (cannon.last_fire_time + cannon.reload_cooldown) <= (world.time / 10)

/obj/machinery/computer/bsa_control/proc/is_calibrate_ready()
	if(!cannon)
		return FALSE
	return (cannon.last_calibrate_time + BSA_CALIBRATE_TIME) <= (world.time / 10)

/obj/machinery/computer/bsa_control/proc/is_ready_to_shot()
	return is_reload_ready() && target && is_calibrate_ready() && !cannon.stat && cannon.mode

/obj/machinery/computer/bsa_control/proc/get_reloading_time()
	if(!cannon)
		return "???"
	var/reload_cooldown = cannon.reload_cooldown
	var/last_fire_time = cannon.last_fire_time
	var/time_to_wait = max(0, round(reload_cooldown - ((world.time / 10) - last_fire_time)))
	var/minutes = max(0, round(time_to_wait / 60))
	var/seconds = max(0, time_to_wait - (60 * minutes))
	var/seconds2 = (seconds < 10) ? "0[seconds]" : seconds
	return "[minutes]:[seconds2]"

/obj/machinery/computer/bsa_control/proc/get_calibrating_duration()
	if(!cannon)
		return 0
	var/last_calibrate_time = cannon.last_calibrate_time
	var/time_to_wait = max(0, round(BSA_CALIBRATE_TIME - ((world.time / 10) - last_calibrate_time)))
	return max(0, time_to_wait)

/obj/machinery/computer/bsa_control/ui_static_data()
	var/list/data = list()
	data["mapRef"] = cam_screen.assigned_map
	data["mode_options"] = get_available_modes()
	return data

/obj/machinery/computer/bsa_control/proc/get_available_modes()
	var/list/modes = list()
	for (var/mode_id in GLOB.BSA_modes_list)
		var/datum/bluespace_cannon_fire_mode/mode = GLOB.BSA_modes_list[mode_id]
		if (mode.need_emag && !emagged)
			continue
		modes += mode.name
	return modes

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon = deploy()
		if("fire")
			if(is_ready_to_shot())
				fire(usr, target)
		if("recalibrate")
			calibrate(usr)
		if("select_mode")
			switch_mode(usr, params)
		if("aim")
			coord_aim(usr, params)
	update_icon()
	return TRUE


/obj/machinery/computer/bsa_control/ui_close(mob/user)
	cam_screen?.hide_from(user)
	user.client.images -= crosshair

/obj/machinery/computer/bsa_control/proc/calibrate(mob/user)
	if(!cannon)
		return
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
	if(caibrated_turf)
		caibrated_turf = cannon.spread(caibrated_turf, BSA_CALIBRATION_ACCURACY)
	x_correction = 0
	y_correction = 0
	aim_turf = caibrated_turf
	crosshair.loc = aim_turf
	cannon.calibrate()
	update_active_camera_screen()

/obj/machinery/computer/bsa_control/proc/switch_mode(mob/user, var/params)
	var/mode_name = params["mode"]
	var/new_mode = GLOB.BSA_modes_list[mode_name]
	if(!new_mode)
		return
	cannon.mode = new_mode

/obj/machinery/computer/bsa_control/emag_act(mob/user)
	if(emagged)
		return FALSE
	emagged = TRUE
	if(user)
		to_chat(user, span_warning("Вы взламываете [declent_ru(ACCUSATIVE)], протоколы безопасности отключены!"))
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
		if(center)
			return locate(center.x, center.y, center.z)
	else if(istype(target,/obj/item/gps))
		return get_turf(target)

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	return aim_turf

/obj/machinery/computer/bsa_control/proc/fire(mob/user, target)
	if(!cannon || !target)
		return
	if(cannon.stat)
		return
	notice = null
	cannon.fire(user, get_impact_turf(), target)

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
	var/value = text2num(params["value"])
	value = clamp(value, -BSA_MAX_AXIS_CORRECTION, BSA_MAX_AXIS_CORRECTION)
	if(axis == "x")
		x_correction = value
	else
		y_correction = value
	aim_turf = locate(caibrated_turf.x + x_correction, caibrated_turf.y + y_correction, caibrated_turf.z)
	crosshair.loc = aim_turf
	update_active_camera_screen()

/obj/machinery/computer/bsa_control/proc/update_active_camera_screen()
	// Code from /obj/machinery/computer/security/update_active_camera_screen
	var/turf/new_cam_turf = get_target_turf()
	if(!new_cam_turf)
		cam_screen.show_camera_static()
		return
	if(last_camera_turf == new_cam_turf)
		return // Update only if camera change position
	last_camera_turf = new_cam_turf
	var/list/visible_things = camera_xray ? range(camera_view_range, new_cam_turf) : view(camera_view_range, new_cam_turf)
	var/list/visible_turfs = list()
	for(var/turf/visible_turf in visible_things)
		visible_turfs += visible_turf
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1
	cam_screen.show_camera(visible_turfs, size_x, size_y)


#undef BSA_BURST_SHOT_DELAY
#undef BSA_CALIBRATION_ACCURACY
#undef BSA_SHOT_SPREAD
#undef BSA_BURST_SPREAD
#undef BSA_MAX_AXIS_CORRECTION
#undef BSA_CALIBRATE_TIME
#undef BSA_IMPACT_DELAY
#undef BSA_IMPACT_LASER_NOTIFY_BEFORE
#undef BSA_IMPACT_NOTIFY_RADIUS
#undef BSA_AFTER_STRIKE_GOACL_CHECK_DELAY
#undef BSA_INITIAL_COOLDOWN
