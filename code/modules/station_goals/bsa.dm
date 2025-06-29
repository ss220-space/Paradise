// Crew has to build a bluespace cannon
// Cargo orders part for high price
// Requires high amount of power
// Requires high level stock parts

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
	var/ex_power = 3
	var/power_used_per_shot = 2000000 //enough to kil standard apc - todo : make this use wires instead and scale explosion power with it
	var/last_fire_time = 0 // The time at which the gun was last fired
	var/reload_cooldown = 600 // The gun's cooldown

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
	power_used_per_shot = 0
	reload_cooldown = 100

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
	reload()

/obj/machinery/bsa/full/proc/fire(mob/user, turf/bullseye)
	var/turf/point = get_front_turf()
	for(var/turf/T as anything in get_line(get_step(point,dir),get_target_turf()))
		T.ex_act(1)
		for(var/atom/A in T)
			A.ex_act(1)

	point.Beam(get_target_turf(), icon_state = "bsa_beam", time = 50, maxdistance = world.maxx, beam_type = /obj/effect/ebeam/reacting/deadly) //ZZZAP
	playsound(src, 'sound/machines/bsa_fire.ogg', 100, 1)

	message_admins("[key_name_admin(user)] has launched an artillery strike into [ADMIN_COORDJMP(bullseye)].")
	log_admin("[key_name_log(user)] has launched an artillery strike into [COORD(bullseye)].") // Line below handles logging the explosion to disk
	explosion(bullseye,ex_power,ex_power*2+1,ex_power*4+2, cause = "Bluespace artillery strike") // 3 7 14 at ex_power = 3

	reload()

/obj/machinery/bsa/full/proc/reload()
	use_power(power_used_per_shot)
	last_fire_time = world.time / 10

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

/obj/machinery/computer/bsa_control/admin
	area_aim = TRUE
	target_all_areas = TRUE

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
	if(!ui)
		ui = new(user, src, "BlueSpaceArtilleryControl", name)
		ui.open()

/obj/machinery/computer/bsa_control/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = cannon
	data["notice"] = notice
	if(target)
		data["target"] = get_target_name()
	if(cannon)
		var/reload_cooldown = cannon.reload_cooldown
		var/last_fire_time = cannon.last_fire_time
		var/time_to_wait = max(0, round(reload_cooldown - ((world.time / 10) - last_fire_time)))
		var/minutes = max(0, round(time_to_wait / 60))
		var/seconds = max(0, time_to_wait - (60 * minutes))
		var/seconds2 = (seconds < 10) ? "0[seconds]" : seconds
		data["reloadtime_text"] = "[minutes]:[seconds2]"
		data["ready"] = minutes == 0 && seconds == 0
	else
		data["ready"] = FALSE
	return data

/obj/machinery/computer/bsa_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("build")
			cannon = deploy()
		if("fire")
			fire(usr)
		if("recalibrate")
			calibrate(usr)
	update_icon()
	return TRUE

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

/obj/machinery/computer/bsa_control/proc/get_target_name()
	if(istype(target,/area))
		var/area/A = target
		return A.name
	else if(istype(target,/obj/item/gps))
		var/obj/item/gps/G = target
		return G.gpstag

/obj/machinery/computer/bsa_control/proc/get_impact_turf()
	if(istype(target,/area))
		return pick(get_area_turfs(target))
	else if(istype(target,/obj/item/gps))
		return get_turf(target)

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
