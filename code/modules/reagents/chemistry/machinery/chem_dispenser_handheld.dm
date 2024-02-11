// Handheld chem dispenser
/obj/item/chem_dispenser_handheld
	name = "handheld chem dispenser"
	icon = 'icons/obj/chemical.dmi'
	item_state = "handheld_chem"
	icon_state = "handheld_chem"
	flags = NOBLUDGEON
	var/obj/item/stock_parts/cell/high/cell = null
	var/obj/item/reagent_containers/reagent_container = null

	var/amount = 10
	var/mode = "dispense"
	var/is_drink = FALSE
	var/list/dispensable_reagents = list("hydrogen", "lithium", "carbon", "nitrogen", "oxygen", "fluorine",
	"sodium", "aluminum", "silicon", "phosphorus", "sulfur", "chlorine", "potassium", "iron",
	"copper", "mercury", "plasma", "radium", "water", "ethanol", "sugar", "iodine", "bromine", "silver", "chromium")
	var/current_reagent = null

	// For every X of reagent amount we spend X / 0.2 energy.
	var/power_efficiency = 0.2

	// How fast we restore the buffer.
	// Integer. Higher - less efficient rechange rate per tick.
	var/recharge_rate = 1

	var/recharge_counter = 0
	var/recharge_counter_threshold = 4

/obj/item/chem_dispenser_handheld/Initialize()
	..()
	cell = new(src)
	dispensable_reagents = sortList(dispensable_reagents)
	current_reagent = pick(dispensable_reagents)
	update_icon(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/item/chem_dispenser_handheld/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/chem_dispenser_handheld/get_cell()
	return cell

/obj/item/chem_dispenser_handheld/attack_self(mob/user)
	if(cell)
		ui_interact(user)
	else
		to_chat(user, "<span class='warning'>The [src] lacks a power cell!</span>")


/obj/item/chem_dispenser_handheld/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ChemDispenserHandheld", name, 477, 655)
		ui.open()

/obj/item/chem_dispenser_handheld/ui_data(mob/user)
	var/list/data = list()

	// Human need to hold an container in another hand. (//TODO)
	// Robot can use built-in shaker.
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.module)
			var/obj/item/reagent_containers/food/drinks/shaker/S = locate() in R.module.modules
			if (S)
				reagent_container = S

	data["energy"] = cell.charge ? cell.charge * power_efficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * power_efficiency
	data["glass"] = is_drink
	data["containerName"] = reagent_container.name ? reagent_container.name : "Nothing"
	data["amount"] = amount
	data["current_reagent"] = current_reagent
	data["mode"] = mode
	data["isContainerLoaded"] = reagent_container ? 1 : 0

	var/containerContents[0]
	var/containerCurrentVolume = 0

	if(reagent_container && reagent_container.reagents && reagent_container.reagents.reagent_list.len)
		for(var/datum/reagent/R in reagent_container.reagents.reagent_list)
			containerContents.Add(list(list("name" = R.name, "id"=R.id, "volume" = R.volume))) // list in a list because Byond merges the first list...
			containerCurrentVolume += R.volume
	data["containerContents"] = containerContents

	if(reagent_container)
		data["containerCurrentVolume"] = containerCurrentVolume
		data["containerMaxVolume"] = reagent_container.volume
	else
		data["containerCurrentVolume"] = null
		data["containerMaxVolume"] = null


	return data

/obj/item/chem_dispenser_handheld/ui_static_data()
	var/list/data = list()
	var/list/chemicals = list()
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			chemicals.Add(list(list("title" = temp.name, "id" = temp.id, "commands" = list("dispense" = temp.id)))) // list in a list because Byond merges the first list...
	data["chemicals"] = chemicals


	return data

/obj/item/chem_dispenser_handheld/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)

		if("amount")
			amount = clamp(round(text2num(params["amount"])), 0, 50) // round to nearest 1 and clamp to 0 - 50

		if("dispense")
			// We are missing container or no reagent name in dispensable list.
			if(!reagent_container || !dispensable_reagents.Find(params["reagent"]) || isnull(reagent_container.reagents))
				return

			var/datum/reagents/R = reagent_container.reagents
			var/free = R.maximum_volume - R.total_volume
			var/amount_to_add = min(amount, (cell.charge * power_efficiency) * 10, free)

			// No cell power.
			if(!cell.use(amount_to_add / power_efficiency))
				atom_say("Недостаточно энергии для завершения операции!")
				return

			R.add_reagent(params["reagent"], amount_to_add)
			current_reagent = params["reagent"]
			update_icon(UPDATE_OVERLAYS)

		if("remove")
			var/amount = text2num(params["amount"])
			if(!reagent_container || !amount)
				return
			var/datum/reagents/R = reagent_container.reagents
			var/id = params["reagent"]
			if(amount > 0)
				R.remove_reagent(id, amount)
			else if(amount == -1) //Isolate instead
				R.isolate_reagent(id)
			else if(amount == -2) //Round to lesser number (a.k.a 14.61 -> 14)
				R.floor_reagent(id)

		else
			return FALSE

	add_fingerprint(usr)

/obj/item/chem_dispenser_handheld/update_overlays()
	. = ..()

	if(cell && cell.charge)
		var/percent = round((cell.charge / cell.maxcharge) * 100)

		switch(percent)
			if(0 to 33)
				. += "light_low"

			if(34 to 66)
				. += "light_mid"

			if(67 to INFINITY)
				. += "light_full"

	var/datum/reagent/R = GLOB.chemical_reagents_list[current_reagent]

	// If no current reagent selected, don't update the icon to avoid exceptions.
	if (R != null)
		var/image/chamber_contents = image('icons/obj/chemical.dmi', src, "reagent_filling")
		chamber_contents.icon += R.color
		. += chamber_contents

/obj/item/chem_dispenser_handheld/process()
	if(recharge_counter >= recharge_counter_threshold)
		// Recharge built in battery from borg battery right away.
		if(isrobot(loc) && cell.charge < cell.maxcharge)
			var cell_charge_diff = cell.maxcharge - cell.charge
			var/mob/living/silicon/robot/R = loc
			if(R && R.cell && R.cell.charge > cell_charge_diff)
				R.cell.use(cell_charge_diff / recharge_rate)
				cell.give(cell_charge_diff / recharge_rate)
				update_icon(UPDATE_OVERLAYS)
				return TRUE
		recharge_counter = 0
	recharge_counter++

/obj/item/chem_dispenser_handheld/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(C.maxcharge < 100)
				to_chat(user, "<span class='notice'>[src] requires a higher capacity cell.</span>")
				return
			if(!user.drop_transfer_item_to_loc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()

/obj/item/chem_dispenser_handheld/screwdriver_act(mob/user, obj/item/I)
	if(!isrobot(loc) && cell)
		cell.update_icon()
		cell.loc = get_turf(src)
		cell = null
		to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
		update_icon()
		return
	..()

/obj/item/chem_dispenser_handheld/booze
	name = "handheld bar tap"
	item_state = "handheld_booze"
	icon_state = "handheld_booze"
	is_drink = TRUE
	dispensable_reagents = list("ice", "cream", "cider", "beer", "kahlua", "whiskey", "wine", "vodka", "gin", "rum", "tequila",
	"vermouth", "cognac", "ale", "mead", "synthanol", "jagermeister", "bluecuracao", "sambuka", "schnaps", "sheridan", "iced_beer",
	"irishcream", "manhattan", "antihol", "synthignon", "bravebull", "goldschlager", "patron", "absinthe", "ethanol", "nothing",
	"sake", "bitter", "champagne", "aperol", "alcohol_free_beer")
/obj/item/chem_dispenser_handheld/soda
	name = "handheld soda fountain"
	item_state = "handheld_soda"
	icon_state = "handheld_soda"
	is_drink = TRUE
	dispensable_reagents = list("water", "ice", "milk", "soymilk", "coffee", "tea", "hot_coco", "cola", "spacemountainwind", "dr_gibb",
	"space_up", "tonic", "sodawater", "lemon_lime", "grapejuice", "sugar", "orangejuice", "lemonjuice", "limejuice", "tomatojuice",
	"banana", "watermelonjuice", "carrotjuice", "potato", "berryjuice", "bananahonk", "milkshake", "cafe_latte", "cafe_mocha",
	"triple_citrus", "icecoffe", "icetea", "thirteenloko")
/obj/item/chem_dispenser_handheld/botanical
	name = "handheld botanical chemical dispenser"
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
