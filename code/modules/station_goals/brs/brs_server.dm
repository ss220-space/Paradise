//Сервер для контроля спутников
/obj/item/circuitboard/brs_server
	name = "Сервер сканирирования разлома (Computer Board)"
	desc = "Плата для сбора сервера изучения сканирования разломов."
	build_path = /obj/machinery/brs_server
	icon_state = "cpuboard_super"
	origin_tech = "engineering=4;bluespace=3"
	req_components = list(
					/obj/item/stack/sheet/metal = 10,
					/obj/item/stack/sheet/glass = 5,
					/obj/item/stock_parts/capacitor/super = 10,
					/obj/item/stock_parts/scanning_module/phasic = 2,
					/obj/item/stack/cable_coil = 20
					)

/obj/machinery/brs_server
	name = "Сервер сканирования разлома"
	icon = 'icons/obj/machines/BRS/scanner_server.dmi'
	icon_state = "scan_server"
	anchored = TRUE
	density = TRUE
	luminosity = TRUE
	max_integrity = 500
	var/active = FALSE
	var/research_points = 0
	var/activate_sound = 'sound/effects/electheart.ogg'
	var/deactivate_sound = 'sound/effects/basscannon.ogg'

	var/research_time = 10 SECONDS		//время для процесса изучения "активной анимации"
	var/counter_research_time = 0		//счетчик до завершения анимации
	//var/id = 0

/obj/machinery/brs_server/Initialize(mapload)
	. = ..()
	GLOB.bluespace_rifts_server_list.Add(src)
	GLOB.poi_list |= src
	update_icon()
	new_component_parts()

/obj/machinery/brs_server/Destroy()
	GLOB.bluespace_rifts_server_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/machinery/brs_server/process()
	if (active && counter_research_time < world.time)
		change_active()

/obj/machinery/brs_server/proc/research_process(var/points)
	if (!active)
		change_active()
	research_points += points
	counter_research_time = world.time + research_time

/obj/machinery/brs_server/proc/change_active()
	active = !active
	if (active)
		playsound(loc, activate_sound, 100, 1)
	else
		playsound(loc, deactivate_sound, 100, 1)
	update_icon()

/obj/machinery/brs_server/update_icon()
	var/prefix = initial(icon_state)
	if(stat & (BROKEN))
		icon_state = "[prefix]-broken"
		return
	if(stat & (NOPOWER))
		icon_state = prefix
		return
	icon_state = active ? "[prefix]-act" : "[prefix]-on"

//==========Взаимодействия========
/obj/machinery/brs_server/wrench_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='notice'>Болты заблокированы протоколом безопасности.</span>")
		return
	. = default_unfasten_wrench(user, I, 80)
	if(.)
		power_change()

/obj/machinery/brs_server/power_change()
	var/old_stat = stat
	..()
	if(old_stat != stat)
		update_icon()

/obj/machinery/brs_server/screwdriver_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return

	to_chat(user, "<span class='notice'>[anchored ? "От" : "За"]кручиваю панель-блокатор [name].</span>")
	if(!I.use_tool(src, user, 120, volume = I.tool_volume))
		return

	. = default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>Панель-блокатор [name] [anchored ? "от" : "за"]кручена..</span>")
	overlays.Cut()
	if(panel_open)
		overlays += image(icon, "[initial(icon_state)]-panel")

/obj/machinery/brs_server/crowbar_act(mob/living/user, obj/item/I)
	if (active && !emagged)
		to_chat(user, "<span class='warning'>Панель заблокирована протоколом безопасности.</span>")
		return
	to_chat(user, "<span class='notice'>Начат процесс разборки [name] на составные компоненты.</span>")
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_deconstruction_crowbar(user, I)
	if(!.)
		return
	to_chat(user, "<span class='notice'>[name] разобран на составные компоненты.</span>")

/obj/machinery/brs_server/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0))
		return
	if(!I.use_tool(src, user, 200, volume = I.tool_volume))
		return

	. = default_welder_repair(user, I)
	if(!.)
		return
	stat &= ~BROKEN
	obj_integrity = max_integrity

// Составные компоненты
/obj/machinery/brs_server/proc/new_component_parts()
	component_parts = list()
	var/obj/item/circuitboard/brs_server/board = new(null)
	for (var/obj/item/stock_parts/component in board.req_components)
		component_parts += new component(null)
	component_parts += board
	component_parts += new /obj/item/stack/sheet/metal(null, 10)
	component_parts += new /obj/item/stack/sheet/glass(null, 5)
	component_parts += new /obj/item/stack/cable_coil(null, 20)

	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)

	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	RefreshParts()

//Перезапись протоколов безопасности.
/obj/machinery/brs_server/proc/rewrite_protocol()
	emagged = TRUE
	playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
	update_icon()

/obj/machinery/brs_server/emag_act(mob/user)
	if(!emagged)
		rewrite_protocol()
		to_chat(user, "<span class='warning'>@?%!№@Протоколы безопасности сканнера перезаписаны@?%!№@</span>")

/obj/machinery/brs_server/emp_act(severity)
	if(!emagged && prob(40 / severity))
		rewrite_protocol()



//открываем ТГУИшку?
///obj/machinery/smartfridge/attackby(obj/item/O, var/mob/user)



/obj/machinery/brs_server/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/brs_server/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	//ui_interact(user)
	return ..()
