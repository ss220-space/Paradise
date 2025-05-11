#define UPDATE_TYPE_HACK 1
#define UPDATE_TYPE_COMPONENTS 2


/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Высокотехнологичная машина, способная синтезировать определённые вещества с помощью сложных физико-химических процессов. Даже не спрашивайте, как оно работает - вы всё равно не поймёте."
	ru_names = list(
		NOMINATIVE = "химический раздатчик",
		GENITIVE = "химического раздатчика",
		DATIVE = "химическому раздатчику",
		ACCUSATIVE = "химический раздатчик",
		INSTRUMENTAL = "химическим раздатчиком",
		PREPOSITIONAL = "химическом раздатчике"
	)
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/ui_title = "ХимРаздатчик 5000"
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/powerefficiency = 0.1
	var/amount = 10
	var/recharge_amount = 100
	var/recharge_counter = 0
	var/hackedcheck = FALSE
	var/componentscheck = FALSE
	var/obj/item/reagent_containers/beaker = null
	var/mutable_appearance/icon_beaker //cached overlay
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver", "chromium")
	var/list/upgrade_reagents = list("oil", "ash", "acetone", "saltpetre", "ammonia", "diethylamine", "fuel")
	var/list/hacked_reagents = list("toxin")
	var/is_drink = FALSE

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/machinery/chem_dispenser/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	dispensable_reagents = sortAssoc(dispensable_reagents)
	RefreshParts()

/obj/machinery/chem_dispenser/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/chem_dispenser/supgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	component_parts += new /obj/item/stock_parts/cell/bluespace
	RefreshParts()

/obj/machinery/chem_dispenser/mutagensaltpeter
	name = "botanical chemical dispenser"
	desc = "Узкоспециализированная модель химического раздатчика, настроенная на синтез ограниченного числа веществ, специально для ботанических нужд."
	ru_names = list(
		NOMINATIVE = "ботанический раздатчик",
		GENITIVE = "ботанического раздатчика",
		DATIVE = "ботаническому раздатчику",
		ACCUSATIVE = "ботанический раздатчик",
		INSTRUMENTAL = "ботаническим раздатчиком",
		PREPOSITIONAL = "ботаническом раздатчике"
	)
	obj_flags = NODECONSTRUCT

	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"atrazine",
		"pestkiller",
		"cryoxadone",
		"ammonia",
		"ash",
		"diethylamine")
	upgrade_reagents = list()

/obj/machinery/chem_dispenser/mutagensaltpeter/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null)
	RefreshParts()

/obj/machinery/chem_dispenser/RefreshParts()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		newpowereff += 0.0166666666 * M.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_amount *= C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(M.rating > 3)
			componentscheck = TRUE
			update_reagents(UPDATE_TYPE_COMPONENTS)
	powerefficiency = round(newpowereff, 0.01)

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("Панель техобслуживания открыта.")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("<br>Монитор состояния сообщает: скорость зарядки - <b>[recharge_amount]</b> единиц[declension_ru(recharge_amount, "у", "ы", "")] энергии за единицу времени.<br>Энергоэффективность увеличена на <b>[round((powerefficiency * 1000) - 100, 1)]%</b>")


/obj/machinery/chem_dispenser/process()
	if(recharge_counter >= 4)
		if(!is_operational())
			return
		var/usedpower = cell.give(recharge_amount)
		if(usedpower)
			use_power(15 * recharge_amount)
		recharge_counter = 0
		return
	recharge_counter++


/obj/machinery/chem_dispenser/ex_act(severity)
	if(severity < 3)
		if(beaker)
			beaker.ex_act(severity)
		..()

/obj/machinery/chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/chem_dispenser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", ui_title)
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
	var/list/data = list()

	data["glass"] = is_drink
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * powerefficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * powerefficiency
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id"=R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if(beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var/chemicals[0]
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id), "reagentColor" = temp.color))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals

	return data

/obj/machinery/chem_dispenser/ui_act(actions, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	. = TRUE
	switch(actions)
		//Chem dispenser dispense amount
		if("amount")
			amount = clamp(round(text2num(params["amount"]), 1), 0, 100) //Round to nearest 1 and clamp to 0 - 100
		if("dispense")
			if(!is_operational() || QDELETED(cell))
				return
			if(!beaker || !dispensable_reagents.Find(params["reagent"]))
				return
			var/datum/reagents/R = beaker.reagents
			var/free = R.maximum_volume - R.total_volume
			var/actual = min(amount, (cell.charge * powerefficiency) * 10, free)
			if(!cell.use(actual / powerefficiency))
				atom_say("Недостаточно энергии для завершения операции!")
				return
			R.add_reagent(params["reagent"], actual)
			update_icon(UPDATE_OVERLAYS)
		if("remove")
			var/amount = text2num(params["amount"])
			if(!beaker || !amount)
				return
			var/datum/reagents/R = beaker.reagents
			var/id = params["reagent"]
			if(amount > 0)
				R.remove_reagent(id, amount)
			else if(amount == -1) //Isolate instead
				R.isolate_reagent(id)
			else if(amount == -2) //Round to lesser number (a.k.a 14.61 -> 14)
				R.floor_reagent(id)
		if("ejectBeaker")
			if(!beaker)
				return
			beaker.forceMove(loc)
			if(Adjacent(usr) && !issilicon(usr))
				usr.put_in_hands(beaker, ignore_anim = FALSE)
			beaker = null
			update_icon(UPDATE_OVERLAYS)
		else
			return FALSE

	add_fingerprint(usr)


/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, I))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks))
		add_fingerprint(user)
		if(panel_open)
			balloon_alert(user, "техпанель открыта!")
			return ATTACK_CHAIN_PROCEED
		if(beaker)
			balloon_alert(user, "слот для ёмкости занят!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		beaker = I
		balloon_alert(user, "ёмкость установлена")
		SStgui.update_uis(src) // update all UIs attached to src
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/chem_dispenser/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		balloon_alert(user, "техпанель закрыта!")
		return
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/chem_dispenser/deconstruct(disassembled)
	if(beaker)
		beaker.forceMove(loc)
		beaker = null
	if(cell)
		cell.forceMove(loc)
		cell = null
	return ..()


/obj/machinery/chem_dispenser/proc/update_reagents(update_type)
	switch(update_type)
		if(UPDATE_TYPE_HACK)
			if(hackedcheck)
				dispensable_reagents += hacked_reagents
			else
				dispensable_reagents -= hacked_reagents
		if(UPDATE_TYPE_COMPONENTS)
			dispensable_reagents |= upgrade_reagents

	dispensable_reagents = sortAssoc(dispensable_reagents)


/obj/machinery/chem_dispenser/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return

	hackedcheck = !hackedcheck
	balloon_alert(user, "защитные протоколы [hackedcheck ? "активированы" : "дезактивированы"]")
	update_reagents(UPDATE_TYPE_HACK)
	SStgui.update_uis(src)


/obj/machinery/chem_dispenser/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", "[initial(icon_state)]", I))
		return TRUE

/obj/machinery/chem_dispenser/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	set_anchored(!anchored)
	if(anchored)
		WRENCH_ANCHOR_MESSAGE
	else
		WRENCH_UNANCHOR_MESSAGE

/obj/machinery/chem_dispenser/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/chem_dispenser/attack_ghost(mob/user)
	if(stat & BROKEN)
		return
	ui_interact(user)

/obj/machinery/chem_dispenser/attack_hand(mob/user)
	if(stat & BROKEN)
		return

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)


/obj/machinery/chem_dispenser/update_overlays()
	. = ..()

	if(!beaker)
		return .

	var/static/list/beaker_cache = list()
	var/random_pixel = rand(-10, 5)	// randomize beaker overlay position
	if(!beaker_cache["[random_pixel]"])
		var/mutable_appearance/beaker_olay = mutable_appearance('icons/obj/chemical.dmi', "disp_beaker")
		beaker_olay.pixel_w = random_pixel
		beaker_cache["[random_pixel]"] = beaker_olay
	. += beaker_cache["[random_pixel]"]


/obj/machinery/chem_dispenser/soda
	name = "soda fountain"
	desc = "Машина, способная синтезировать целый ряд самых разных напитков. Круто!"
	ru_names = list(
		NOMINATIVE = "раздатчик напитков",
		GENITIVE = "раздатчика напитков",
		DATIVE = "раздатчику напитков",
		ACCUSATIVE = "раздатчик напитков",
		INSTRUMENTAL = "раздатчиком напитков",
		PREPOSITIONAL = "раздатчике напитков"
	)
	icon_state = "soda_dispenser"
	ui_title = "Фонтан Напитков 10000"
	dispensable_reagents = list("water", "ice", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb", "space_up",
	"tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice", "banana",
	"watermelonjuice", "carrotjuice", "potato", "berryjuice")
	upgrade_reagents = list("bananahonk", "milkshake", "cafe_latte", "cafe_mocha", "triple_citrus", "icecoffe","icetea")
	hacked_reagents = list("thirteenloko")
	var/list/hackedupgrade_reagents = list("zaza") //I possess zaza
	is_drink = TRUE

/obj/machinery/chem_dispenser/soda/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/soda/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/soda(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()


/obj/machinery/chem_dispenser/soda/update_reagents(update_type)
	if(update_type == UPDATE_TYPE_HACK && componentscheck)
		if(hackedcheck)
			dispensable_reagents += hackedupgrade_reagents
		else
			dispensable_reagents -= hackedupgrade_reagents

	else if(update_type == UPDATE_TYPE_COMPONENTS && hackedcheck)
		dispensable_reagents |= hackedupgrade_reagents
	..()


/obj/machinery/chem_dispenser/beer
	name = "booze dispenser"
	desc = "Машина, способная синтезировать для вас любую алкогольную бурду, которая только может прийти в голову. Настоящее чудо алкологольных технологий!"
	ru_names = list(
		NOMINATIVE = "раздатчик алкоголя",
		GENITIVE = "раздатчика алкоголя",
		DATIVE = "раздатчику алкоголя",
		ACCUSATIVE = "раздатчик алкоголя",
		INSTRUMENTAL = "раздатчиком алкоголя",
		PREPOSITIONAL = "раздатчике алкоголя"
	)
	icon_state = "booze_dispenser"
	ui_title = "Наливатель Бухла 9001"
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila", "vermouth", "cognac", "ale", "mead", "synthanol", "jagermeister", "bluecuracao", "sambuka", "schnaps", "sheridan")
	upgrade_reagents = list("iced_beer", "irishcream", "manhattan", "antihol", "synthignon", "bravebull")
	hacked_reagents = list("goldschlager", "patron", "absinthe", "ethanol", "nothing", "sake", "bitter", "champagne", "aperol", "noalco_beer")
	is_drink = TRUE

/obj/machinery/chem_dispenser/beer/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/beer/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/beer(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/capacitor/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

//botanical chemical dispenser
/obj/machinery/chem_dispenser/botanical
	name = "botanical chemical dispenser"
	desc = "Узкоспециализированная модель химического раздатчика, настроенная на синтез ограниченного числа веществ, специально для ботанических нужд."
	ru_names = list(
		NOMINATIVE = "ботанический раздатчик",
		GENITIVE = "ботанического раздатчика",
		DATIVE = "ботаническому раздатчику",
		ACCUSATIVE = "ботанический раздатчик",
		INSTRUMENTAL = "ботаническим раздатчиком",
		PREPOSITIONAL = "ботаническом раздатчике"
	)
	ui_title = "Ботанический ХимРаздатчик"
	dispensable_reagents = list("mutagen", "saltpetre", "ammonia", "water")
	upgrade_reagents = list("atrazine", "glyphosate", "pestkiller", "diethylamine", "ash")

/obj/machinery/chem_dispenser/botanical/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/botanical(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/capacitor(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

/obj/machinery/chem_dispenser/botanical/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/chem_dispenser/botanical(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace(null)
	component_parts += new /obj/item/stock_parts/capacitor/quadratic(null)
	component_parts += new /obj/item/stock_parts/manipulator/femto(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new cell_type(null)
	RefreshParts()

// Handheld chem dispenser
/obj/item/handheld_chem_dispenser
	name = "handheld chem dispenser"
	desc = "Компактная версия химического раздатчика. Удобно!"
	ru_names = list(
		NOMINATIVE = "ручной химический раздатчик",
		GENITIVE = "ручного химического раздатчика",
		DATIVE = "ручному химическому раздатчику",
		ACCUSATIVE = "ручной химический раздатчик",
		INSTRUMENTAL = "ручным химическим раздатчиком",
		PREPOSITIONAL = "ручном химическом раздатчике"
	)
	icon = 'icons/obj/chemical.dmi'
	item_state = "handheld_chem"
	icon_state = "handheld_chem"
	item_flags = NOBLUDGEON
	var/obj/item/stock_parts/cell/high/cell = null
	var/amount = 10
	var/mode = "dispense"
	var/is_drink = FALSE
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver", "chromium")
	var/current_reagent = null
	var/efficiency = 0.2
	var/recharge_rate = 1 // Keep this as an integer

/obj/item/handheld_chem_dispenser/Initialize()
	. = ..()
	cell = new(src)
	dispensable_reagents = sortList(dispensable_reagents)
	current_reagent = pick(dispensable_reagents)
	update_icon(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/item/handheld_chem_dispenser/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/handheld_chem_dispenser/get_cell()
	return cell

/obj/item/handheld_chem_dispenser/afterattack(obj/target, mob/user, proximity)
	if(!proximity || !current_reagent || !amount)
		return

	if(!check_allowed_items(target,target_self = TRUE) || !target.is_refillable())
		return
	switch(mode)
		if("dispense")
			var/free = target.reagents.maximum_volume - target.reagents.total_volume
			var/actual = min(amount, cell.charge / efficiency, free)
			target.reagents.add_reagent(current_reagent, actual)
			cell.charge -= actual / efficiency
			if(actual)
				to_chat(user, span_notice("Вы наливаете [amount] единиц[declension_ru(amount, "у", "ы", "")] [current_reagent] в [target.declent_ru(ACCUSATIVE)]."))
			update_icon(UPDATE_OVERLAYS)
		if("remove")
			if(!target.reagents.remove_reagent(current_reagent, amount))
				to_chat(user, span_notice("Вы удаляете [amount] единиц[declension_ru(amount, "у", "ы", "")] [current_reagent] из [target.declent_ru(GENITIVE)]."))
		if("isolate")
			if(!target.reagents.isolate_reagent(current_reagent))
				to_chat(user, span_notice("Вы удаляете всё, кроме [current_reagent] в [target.declent_ru(PREPOSITIONAL)]."))

/obj/item/handheld_chem_dispenser/attack_self(mob/user)
	if(cell)
		ui_interact(user)
	else
		balloon_alert(user, "нет батареи!")

/obj/item/handheld_chem_dispenser/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/handheld_chem_dispenser/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HandheldChemDispenser", capitalize(declent_ru(NOMINATIVE)))
		ui.open()

/obj/item/handheld_chem_dispenser/ui_data(mob/user)
	var/list/data = list()

	data["glass"] = is_drink
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * efficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * efficiency
	data["current_reagent"] = current_reagent
	data["mode"] = mode

	return data

/obj/item/handheld_chem_dispenser/ui_static_data()
	var/list/data = list()
	var/list/chemicals = list()
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals


	return data

/obj/item/handheld_chem_dispenser/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("amount")
			amount = clamp(round(text2num(params["amount"])), 0, 50) // round to nearest 1 and clamp to 0 - 50
		if("dispense")
			if(params["reagent"] in dispensable_reagents)
				current_reagent = params["reagent"]
				update_icon(UPDATE_OVERLAYS)
		if("mode")
			switch(params["mode"])
				if("remove")
					mode = "remove"
				if("dispense")
					mode = "dispense"
				if("isolate")
					mode = "isolate"
			update_icon(UPDATE_OVERLAYS)
		else
			return FALSE

	add_fingerprint(usr)


/obj/item/handheld_chem_dispenser/update_overlays()
	. = ..()
	if(cell && cell.charge)
		var/image/power_light = image('icons/obj/chemical.dmi', src, "light_low")
		var/percent = round((cell.charge / cell.maxcharge) * 100)
		switch(percent)
			if(0 to 33)
				power_light.icon_state = "light_low"
			if(34 to 66)
				power_light.icon_state = "light_mid"
			if(67 to INFINITY)
				power_light.icon_state = "light_full"
		. += power_light

		var/image/mode_light = image('icons/obj/chemical.dmi', src, "light_remove")
		mode_light.icon_state = "light_[mode]"
		. += mode_light

		var/image/chamber_contents = image('icons/obj/chemical.dmi', src, "reagent_filling")
		var/datum/reagent/R = GLOB.chemical_reagents_list[current_reagent]
		chamber_contents.icon += R.color
		. += chamber_contents


/obj/item/handheld_chem_dispenser/process()
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell && R.cell.charge && (R.cell != cell))
			cell = R.cell //Use robot's power source.

	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/item/handheld_chem_dispenser/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			balloon_alert(user, "слот для батареи занят!")
			return ATTACK_CHAIN_PROCEED
		if(cell.maxcharge < 100)
			balloon_alert(user, "требуется батарея большей ёмкости!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		update_icon(UPDATE_OVERLAYS)
		balloon_alert(user, "батарея установлена")
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/handheld_chem_dispenser/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(isrobot(loc))
		balloon_alert(user, "невозможно!")
		return .
	if(!cell)
		add_fingerprint(user)
		balloon_alert(user, "батарея отсутствует!")
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	balloon_alert(user, "батарея извлечена")
	cell.update_icon()
	cell.forceMove(drop_location())
	cell.add_fingerprint(user)
	cell = null
	update_icon(UPDATE_OVERLAYS)


/obj/item/handheld_chem_dispenser/booze
	name = "handheld bar tap"
	desc = "Компактная версия алкогольного раздатчика. Удобно!"
	ru_names = list(
		NOMINATIVE = "ручной алкогольный раздатчик",
		GENITIVE = "ручного алкогольного раздатчика",
		DATIVE = "ручному алкогольному раздатчику",
		ACCUSATIVE = "ручной алкогольный раздатчик",
		INSTRUMENTAL = "ручным алкогольным раздатчиком",
		PREPOSITIONAL = "ручном алкогольном раздатчике"
	)
	item_state = "handheld_booze"
	icon_state = "handheld_booze"
	is_drink = TRUE
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila",
	"vermouth", "cognac", "ale", "mead", "synthanol", "jagermeister", "bluecuracao", "sambuka", "schnaps", "sheridan", "iced_beer",
	"irishcream", "manhattan", "antihol", "synthignon", "bravebull", "goldschlager", "patron", "absinthe", "ethanol", "nothing",
	"sake", "bitter", "champagne", "aperol", "noalco_beer")

/obj/item/handheld_chem_dispenser/soda
	name = "handheld soda fountain"
	desc = "Компактная версия раздатчика напитков. Удобно!"
	ru_names = list(
		NOMINATIVE = "ручной раздатчик напитков",
		GENITIVE = "ручного раздатчика напитков",
		DATIVE = "ручному раздатчику напитков",
		ACCUSATIVE = "ручной раздатчик напитков",
		INSTRUMENTAL = "ручным раздатчиком напитков",
		PREPOSITIONAL = "ручном раздатчике напитков"
	)
	item_state = "handheld_soda"
	icon_state = "handheld_soda"
	is_drink = TRUE
	dispensable_reagents = list("water", "ice", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb",
	"space_up", "tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice",
	"banana", "watermelonjuice", "carrotjuice", "potato", "berryjuice", "bananahonk", "milkshake", "cafe_latte", "cafe_mocha",
	"triple_citrus", "icecoffe", "icetea", "thirteenloko")

/obj/item/handheld_chem_dispenser/botanical
	name = "handheld botanical chemical dispenser"
	desc = "Компактная версия ботанического раздатчика. Удобно!"
	ru_names = list(
		NOMINATIVE = "ручной ботанический раздатчик",
		GENITIVE = "ручного ботанического раздатчика",
		DATIVE = "ручному ботаническому раздатчику",
		ACCUSATIVE = "ручной ботанический раздатчик",
		INSTRUMENTAL = "ручным ботаническим раздатчиком",
		PREPOSITIONAL = "ручном ботаническом раздатчике"
	)
	dispensable_reagents = list(
		"mutagen",
		"saltpetre",
		"eznutriment",
		"left4zednutriment",
		"robustharvestnutriment",
		"water",
		"atrazine",
		"pestkiller",
		"cryoxadone",
		"ammonia",
		"ash",
		"diethylamine")


/obj/item/handheld_chem_dispenser/cooking
	name = "handheld cooking chemical dispenser"
	desc = "Компактный кухонный раздатчик. Удобно!"
	ru_names = list(
		NOMINATIVE = "компактный кухонный раздатчик",
		GENITIVE = "компактного кухонного раздатчика",
		DATIVE = "компактному кухонному раздатчику",
		ACCUSATIVE = "компактный кухонный раздатчик",
		INSTRUMENTAL = "компактным кухонным раздатчиком",
		PREPOSITIONAL = "компактном кухонном раздатчике"
	)
	dispensable_reagents = list(
		"sodiumchloride",
		"blackpepper",
		"ketchup",
		"herbsmix")

#undef UPDATE_TYPE_HACK
#undef UPDATE_TYPE_COMPONENTS

