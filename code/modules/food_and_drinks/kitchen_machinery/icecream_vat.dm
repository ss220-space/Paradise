//ICE CREAM MACHINE
//Code made by Sawu at Sawu-Station.

/obj/machinery/icemachine
	name = "Cream-Master Deluxe"
	desc = "Современный комплекс для синтеза замороженных молочных десертов. Гарантирует идеальную консистенцию и температуру готового продукта. Ром со вкусом детства."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "icecream_vat"
	max_integrity = 300
	idle_power_usage = 20
	var/obj/item/reagent_containers/glass/beaker = null
	var/useramount = 15	//Last used amount

/obj/machinery/icemachine/get_ru_names()
	return list(
		NOMINATIVE = "Крем-Мастер Делюкс",
		GENITIVE = "Крем-Мастер Делюкс",
		DATIVE = "Крем-Мастер Делюкс",
		ACCUSATIVE = "Крем-Мастер Делюкс",
		INSTRUMENTAL = "Крем-Мастер Делюкс",
		PREPOSITIONAL = "Крем-Мастер Делюкс"
	)

/obj/machinery/icemachine/proc/generate_name(reagent_name)
	var/name_prefix = pick("Капитан", "Доктор", "Мега", "Весёлый", "Генерал", "Профессор")
	var/name_suffix = pick(" Кремберос", " Взбивайс", " Сладкоежка", " Муссон", " Пломбир", " Эскимо", " Зефирко")
	var/cone_name = null	//Heart failure prevention.
	cone_name += name_prefix
	cone_name += name_suffix
	cone_name += " — [reagent_name]"
	return cone_name

/obj/machinery/icemachine/Initialize(mapload)
	. = ..()
	create_reagents(500)

/obj/machinery/icemachine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IcecreamMachine", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/icemachine/ui_data(mob/user)
	var/list/data = list()
	data["name"] = DECLENT_RU_CAP(src, NOMINATIVE)
	data["beaker"] = !!beaker
	data["totalVolume"] = reagents.total_volume
	data["maxVolume"] = reagents.maximum_volume

	data["beakerContents"] = list()
	if(beaker)
		var/obj/item/reagent_containers/glass/A = beaker
		var/datum/reagents/R = A.reagents
		for(var/datum/reagent/G in R.reagent_list)
			data["beakerContents"] += list(list(
				"name" = G.name,
				"volume" = G.volume,
				"id" = G.id,
				"color" = G.color || "#ffffff"
			))

	data["machineContents"] = list()
	for(var/datum/reagent/N in reagents.reagent_list)
		data["machineContents"] += list(list(
			"name" = N.name,
			"volume" = N.volume,
			"id" = N.id,
			"color" = N.color || "#ffffff"
		))

	return data

/obj/machinery/icemachine/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("eject")
			if(beaker)
				beaker.forceMove(loc)
				reagents.trans_to(beaker, reagents.total_volume)
				beaker = null
				. = TRUE

		if("add")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(beaker && validexchange(id))
				var/obj/item/reagent_containers/glass/A = beaker
				var/datum/reagents/R = A.reagents
				R.trans_id_to(src, id, amount)
				. = TRUE

		if("remove")
			var/id = params["id"]
			var/amount = text2num(params["amount"])
			if(beaker && validexchange(id))
				var/obj/item/reagent_containers/glass/A = beaker
				reagents.trans_id_to(A, id, amount)
			else
				reagents.remove_reagent(id, amount)
			. = TRUE

		if("synthcond")
			var/type = text2num(params["type"])
			if(type == 2 || type == 3)
				var/brand = pick(1,2,3,4)
				if(brand == 1)
					if(type == 2)
						reagents.add_reagent("cola",5)
					else
						reagents.add_reagent("kahlua",5)
				else if(brand == 2)
					if(type == 2)
						reagents.add_reagent("dr_gibb",5)
					else
						reagents.add_reagent("vodka",5)
				else if(brand == 3)
					if(type == 2)
						reagents.add_reagent("space_up",5)
					else
						reagents.add_reagent("rum",5)
				else if(brand == 4)
					if(type == 2)
						reagents.add_reagent("spacemountainwind",5)
					else
						reagents.add_reagent("gin",5)
			else if(type == 4)
				var/remaining_space = min(30, reagents.maximum_volume - reagents.total_volume)
				if(remaining_space > 0)
					reagents.add_reagent("cream", remaining_space)
				. = TRUE
			else if(type == 5)
				var/remaining_space = min(30, reagents.maximum_volume - reagents.total_volume)
				if(remaining_space > 0)
					reagents.add_reagent("water", remaining_space)
				. = TRUE

		if("createcup")
			var/name = generate_name(reagents.get_master_reagent_name())
			var/obj/item/reagent_containers/food/snacks/icecream/icecreamcup/C
			C = new/obj/item/reagent_containers/food/snacks/icecream/icecreamcup(loc)
			C.name = "мороженное в стаканчике [name]"
			C.ru_names = list(
				NOMINATIVE = "мороженое в стаканчике \"[name]\"",
				GENITIVE = "мороженого в стаканчике \"[name]\"",
				DATIVE = "мороженому в стаканчике \"[name]\"",
				ACCUSATIVE = "мороженое в стаканчике \"[name]\"",
				INSTRUMENTAL = "мороженым в стаканчике \"[name]\"",
				PREPOSITIONAL = "мороженом в стаканчике \"[name]\""
			)
			C.pixel_x = rand(-8, 8)
			C.pixel_y = -16
			reagents.trans_to(C,30)
			if(reagents)
				reagents.clear_reagents()
			C.update_icon()
			. = TRUE

		if("createcone")
			var/name = generate_name(reagents.get_master_reagent_name())
			var/obj/item/reagent_containers/food/snacks/icecream/icecreamcone/C
			C = new/obj/item/reagent_containers/food/snacks/icecream/icecreamcone(loc)
			C.name = "мороженное в рожке [name]"
			C.ru_names = list(
				NOMINATIVE = "мороженое в рожке \"[name]\"",
				GENITIVE = "мороженого в рожке \"[name]\"",
				DATIVE = "мороженому в рожке \"[name]\"",
				ACCUSATIVE = "мороженое в рожке \"[name]\"",
				INSTRUMENTAL = "мороженым в рожке \"[name]\"",
				PREPOSITIONAL = "мороженом в рожке \"[name]\""
			)
			C.pixel_x = rand(-8, 8)
			C.pixel_y = -16
			reagents.trans_to(C,15)
			if(reagents)
				reagents.clear_reagents()
			C.update_icon()
			. = TRUE

/obj/machinery/icemachine/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(beaker)
			balloon_alert(user, "внутри уже есть ёмкость!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		balloon_alert(user, "ёмкость вставлена")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/reagent_containers/food/snacks/icecream))
		add_fingerprint(user)
		if(I.reagents.has_reagent("sprinkles"))
			balloon_alert(user, "уже есть посыпка!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "посыпка добавлена")
		if(I.reagents.total_volume > 29)
			I.reagents.remove_any(1)
		I.reagents.add_reagent("sprinkles", 1)
		I.name += " c посыпкой"
		I.desc += " С ароматной посыпкой."
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/icemachine/proc/validexchange(reag)
	if(reag == "sprinkles" | reag == "cola" | reag == "kahlua" | reag == "dr_gibb" | reag == "vodka" | reag == "space_up" | reag == "rum" | reag == "spacemountainwind" | reag == "gin" | reag == "cream" | reag == "water")
		return 1
	else
		if(reagents.total_volume < 500)
			visible_message(span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] вибрирует, принимая неизвестную жидкость."))
			playsound(loc, 'sound/machines/twobeep.ogg', 10, TRUE)
		return 1

/obj/machinery/icemachine/attack_ai(mob/user)
	return ui_interact(user)

/obj/machinery/icemachine/attack_hand(mob/user)
	if(..()) return
	add_fingerprint(user)
	user.set_machine(src)
	ui_interact(user)

/obj/machinery/icemachine/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)
