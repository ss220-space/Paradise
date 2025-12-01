GLOBAL_LIST_EMPTY(monkey_recyclers)

/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "Экологично перерабатывает органику обратно в удобные для хранения обезьяньи кубики."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1
	var/cycle_through = 0
	var/obj/item/reagent_containers/food/snacks/monkeycube/cube_type = /obj/item/reagent_containers/food/snacks/monkeycube
	var/list/connected = list()

/obj/machinery/monkey_recycler/get_ru_names()
	return list(
		NOMINATIVE = "утилизатор обезьян",
		GENITIVE = "утилизатора обезьян",
		DATIVE = "утилизатору обезьян",
		ACCUSATIVE = "утилизатор обезьян",
		INSTRUMENTAL = "утилизатором обезьян",
		PREPOSITIONAL = "утилизаторе обезьян"
	)

/obj/machinery/monkey_recycler/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	GLOB.monkey_recyclers += src
	RefreshParts()
	locate_camera_console()

/obj/machinery/monkey_recycler/Destroy()
	GLOB.monkey_recyclers -= src
	for(var/thing in connected)
		var/obj/machinery/computer/camera_advanced/xenobio/console = thing
		console.connected_recycler = null
	connected.Cut()
	return ..()

/obj/machinery/monkey_recycler/proc/locate_camera_console()
	if(length(connected))
		return // we're already connected!
	for(var/obj/machinery/computer/camera_advanced/xenobio/xeno_camera in SSmachines.get_by_type(/obj/machinery/computer/camera_advanced/xenobio))
		if(get_area(xeno_camera) == get_area(loc))
			xeno_camera.connected_recycler = src
			connected |= xeno_camera
			break

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 0
	for(var/obj/item/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cubes_made += M.rating
	cube_production = cubes_made
	required_grind = max(req_grind, 1)

/obj/machinery/monkey_recycler/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/monkey_recycler/screwdriver_act(mob/living/user, obj/item/I)
	return default_deconstruction_screwdriver(user, "grinder_open", "grinder", I)

/obj/machinery/monkey_recycler/wrench_act(mob/living/user, obj/item/I)
	return default_unfasten_wrench(user, I)

/obj/machinery/monkey_recycler/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)

/obj/machinery/monkey_recycler/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(panel_open)
		if(!ismultitool(I))
			return FALSE
		if(!I.use_tool(src, user, volume = I.tool_volume))
			return .
		var/obj/item/multitool/multitool = I
		multitool.buffer = src
		to_chat(user, span_notice("Вы сохраняете [declent_ru(ACCUSATIVE)] в буфере [multitool.declent_ru(GENITIVE)]."))
		return .
	cycle_through++
	var/cubename
	switch(cycle_through)
		if(1)
			cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/farwacube
			cubename = "фарву"
		if(2)
			cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/wolpincube
			cubename = "вульпина"
		if(3)
			cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/stokcube
			cubename = "стока"
		if(4)
			cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/neaeracube
			cubename = "неару"
		if(5)
			cube_type = /obj/item/reagent_containers/food/snacks/monkeycube
			cubename = "обезьяну"
			cycle_through = 0
	to_chat(user, span_notice("Вы изменили тип кубика на [cubename]."))

/obj/machinery/monkey_recycler/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || (stat & (NOPOWER|BROKEN)))
		return .
	if(!ishuman(grabbed_thing))
		to_chat(grabber, span_warning("Эта машина принимает только гуманоидов!"))
		return .
	var/mob/living/carbon/human/victim = grabbed_thing
	if(!is_monkeybasic(victim))
		to_chat(grabber, span_warning("Эта машина принимает только низшие формы жизни!"))
		return .
	if(!victim.stat)
		to_chat(grabber, span_warning("[capitalize(victim)] слишком сильно сопротивляется, чтобы поместить его в утилизатор."))
		return .
	add_fingerprint(grabber)
	to_chat(grabber, span_notice("Вы запихиваете [victim] в [declent_ru(ACCUSATIVE)]."))
	grabber.stop_pulling()
	qdel(victim)
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
	use_power(500)
	grinded++
	sleep(5 SECONDS)
	pixel_x = initial(pixel_x)
	to_chat(grabber, span_notice("В машине теперь содержится материала на [grinded] кубик[DECL_SEC_MIN(grinded)]."))

/obj/machinery/monkey_recycler/attack_hand(mob/user)
	if(stat != 0) //NOPOWER etc
		return
	if(grinded >= required_grind)
		add_fingerprint(user)
		to_chat(user, span_notice("Машина громко шипит, сжимая переработанное мясо. Через мгновение она выдаёт новый кубик."))
		playsound(loc, 'sound/machines/hiss.ogg', 50, TRUE)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++) // Forgot to fix this bit the first time through
			new cube_type(loc)
		to_chat(user, span_notice("На дисплее машины мигает сообщение, что осталось материала на [grinded] кубик[DECL_CREDIT(grinded)]."))
	else // I'm not sure if the \s macro works with a word in between; I'll play it safe
		to_chat(user, span_warning("Для производства [cube_production] кубик[DECL_SEC_MIN(cube_production)] машине требуется как минимум материал от [required_grind] обезьян[DECL_SEC_MIN(required_grind)]. Сейчас внутри: [grinded]."))
	return
