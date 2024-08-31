/* Define to simple.
 * * n - name itself.
 * * o - path to the object.
 * * b - brass cost.
 * * p - power cost from clockwork.
 * * t - time to make.
 */
#define CLOCK_DESIGN(n, o, b, p, t) n = new /datum/clockwork_design(n, o, b, p, t)

/obj/structure/clockwork/workshop
	name = "ratvar's workshop"
	desc = "A workshop of elder god. Has unique brass tools to manipulate both power and metal to make fine clockwork pieces."
	icon_state = "workshop"
	max_integrity = 400

/obj/structure/clockwork/functional/workshop
	name = "ratvar's workshop"
	desc = "A workshop of elder god. Has unique brass tools to manipulate both power and metal to make fine clockwork pieces."
	icon_state = "workshop"
	max_integrity = 400
	death_message = "<span class='danger'>The workshop begins to crumble in pieces as the tools and the gears on table starts to dust!</span>"
	var/temp_search
	var/datum/clockwork_design/being_built = null
	var/list/item_list
	var/brass_amount = 0
	var/build_start = 0
	var/build_end = 0
	canbehidden = TRUE


// CLOCK_DESIGN(NAME, PATH, BRASS_AMOUNT, POWER_AMOUNT, TIME),
// and remember brass is in 2000x not 1x
/obj/structure/clockwork/functional/workshop/Initialize(mapload)
	. = ..()
	item_list = list()
	item_list["Weapon"] = list(
		CLOCK_DESIGN("Clockwork Slab", /obj/item/clockwork/clockslab, 100, 0, 3),
		CLOCK_DESIGN("Ratvarian Spear", /obj/item/twohanded/ratvarian_spear, 2000, 400, 10),
		CLOCK_DESIGN("Clock Hammer", /obj/item/twohanded/clock_hammer, 2000, 400, 10),
		CLOCK_DESIGN("Rustless Sword", /obj/item/melee/clock_sword, 1000, 200, 4),
		CLOCK_DESIGN("Brass Buckler", /obj/item/shield/clock_buckler, 500, 200, 4),
	)
	item_list["Clothing"] = list(
		CLOCK_DESIGN("Clock Robe", /obj/item/clothing/suit/hooded/clockrobe, 400, 80, 3),
		CLOCK_DESIGN("Cuirass", /obj/item/clothing/suit/armor/clockwork, 4000, 400, 20),
		CLOCK_DESIGN("Gauntlets", /obj/item/clothing/gloves/clockwork, 800, 200, 5),
		CLOCK_DESIGN("Treads", /obj/item/clothing/shoes/clockwork, 300, 50, 5),
		CLOCK_DESIGN("Helmet", /obj/item/clothing/head/helmet/clockwork, 300, 100, 5),
		CLOCK_DESIGN("Judical Visors", /obj/item/clothing/glasses/clockwork, 400, 200, 5),
	)
	item_list["Consumables"] = list(
		CLOCK_DESIGN("Brass sheet", /obj/item/stack/sheet/brass, 0, 200, 3),
		CLOCK_DESIGN("Integration Cog", /obj/item/clockwork/integration_cog, 100, 0, 3),
		CLOCK_DESIGN("Soul Vessel", /obj/item/mmi/robotic_brain/clockwork, 500, 100, 5),
		CLOCK_DESIGN("Clocked Upgrade", /obj/item/borg/upgrade/clockwork, 1000, 200, 5),
		CLOCK_DESIGN("Marauder", /obj/item/clockwork/marauder, 1200, 300, 10),
		CLOCK_DESIGN("Strange Shard", /obj/item/clockwork/shard, 2000, 500, 15),
	)

/obj/structure/clockwork/functional/workshop/Destroy()
	// let all the brass out!
	// Change it back from 2000x to 1x
	brass_amount = round(brass_amount / MINERAL_MATERIAL_AMOUNT)

	while(brass_amount >= MAX_STACK_SIZE)
		new /obj/item/stack/sheet/brass(src, MAX_STACK_SIZE)
		brass_amount -= MAX_STACK_SIZE
	if(brass_amount >= 1)
		new /obj/item/stack/sheet/brass(src, brass_amount)

	SStgui.close_uis()
	return ..()

/obj/structure/clockwork/functional/workshop/attack_hand(mob/user)
	if(hidden)
		if(isclocker(user))
			to_chat(user,"<span class='warning'>This workshop is hidden. You need clockwork slab to reveal it!</span>")
		return
	if(!isclocker(user))
		to_chat(user,"<span class='warning'>You are trying to understand how this table works, but to no avail.</span>")
		return
	if(anchored && !hidden)
		add_fingerprint(user)
		ui_interact(user)

/obj/structure/clockwork/functional/workshop/attack_ghost(mob/user)
	ui_interact(user)


/obj/structure/clockwork/functional/workshop/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/brass) && isclocker(user))
		add_fingerprint(user)
		var/obj/item/stack/sheet/brass/brass = I
		if(!user.drop_transfer_item_to_loc(brass, src))
			return ..()
		to_chat(user, span_notice("You reconstruct [brass] for workshop to work with."))
		brass_amount += MINERAL_MATERIAL_AMOUNT*brass.amount
		qdel(brass)
		flick("workshop_b", src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/structure/clockwork/functional/workshop/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Workshop", name)
		ui.open()

/obj/structure/clockwork/functional/workshop/ui_static_data(mob/user)
	var/list/static_data = list()
	// implement item.requirements from autolathe but to brass and power

		// Available items - in static data because we don't wanna compute this list every time! It hardly changes.
	static_data["items"] = list()
	for(var/cat in item_list)
		var/list/cat_items = list()
		for(var/item_name in item_list[cat])
			var/datum/clockwork_design/design = item_list[cat][item_name]
			var/list/matreq = list()
			var/obj/item/I = design.design_path
			if(design.brass_cost)
				matreq["brass"] = design.brass_cost
			else
				matreq["brass"] = 0
			if(design.power_cost)
				matreq["power"] = design.power_cost
			else
				matreq["power"] = 0
			cat_items[item_name] = list(
				"name" = item_name,
				"brass" = design.brass_cost,
				"power" = design.power_cost,
				"requirements" =  matreq,
				"image" = "[icon2base64(icon(initial(I.icon), initial(I.icon_state), SOUTH, 1))]"
			)
		static_data["items"][cat] = cat_items

	return static_data

/obj/structure/clockwork/functional/workshop/ui_data(mob/user)
	var/list/data = list()
	data["brass_amount"] = brass_amount
	data["power_amount"] = GLOB.clockwork_power

	// Current build
	if(being_built)
		data["building"] = being_built.design_name
		data["buildStart"] = build_start
		data["buildEnd"] = build_end
		data["worldTime"] = world.time
	else // Redundant data to ensure the clientside state is refreshed.
		data["building"] = null
		data["buildStart"] = null
		data["buildEnd"] = null

	return data

/obj/structure/clockwork/functional/workshop/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	. = TRUE
	if(hidden || !anchored)
		return
	switch(action)
		if("make")
			var/category = params["cat"] // meow
			var/name = params["name"]
			if(!(category in item_list) || !(name in item_list[category])) // Not trying something that's not in the list, are you?
				return
			var/datum/clockwork_design/item = item_list[category][name]
			if(item.brass_cost > brass_amount) // shouldn't be able to access this since the button is greyed out, but..
				to_chat(usr, "<span class='danger'>You have insufficient brass in workshop.</span>")
				return
			if(item.power_cost > GLOB.clockwork_power)
				to_chat(usr, "<span class='danger'>Your cult have insufficient power.</span>")
				return
			build_design(item)
		if("dispense")
			if(brass_amount < MINERAL_MATERIAL_AMOUNT)
				to_chat(usr, "<span class='danger'>You have insufficient brass in workshop.</span>")
			else
				brass_amount -= MINERAL_MATERIAL_AMOUNT
				new /obj/item/stack/sheet/brass(loc)
		else
			return FALSE

/obj/structure/clockwork/functional/workshop/proc/build_design(datum/clockwork_design/CD)
	. = FALSE
	if(being_built)
		to_chat(usr, "<span class='danger'>Something is already being built!</span>")
		return
	if(CD.brass_cost > brass_amount) // IF
		to_chat(usr, "<span class='danger'>You have insufficient brass in workshop.</span>")
		return
	if(CD.power_cost > GLOB.clockwork_power)
		to_chat(usr, "<span class='danger'>Your cult have insufficient power.</span>")
		return

	// Subtract the materials from the holder
	brass_amount -= CD.brass_cost
	adjust_clockwork_power(-CD.power_cost)

	// Start building the design
	being_built = CD
	build_start = world.time
	build_end = build_start + CD.build_time SECONDS
	desc = "It's creating \a [initial(CD.design_name)]."
	addtimer(CALLBACK(src, PROC_REF(build_design_timer_finish), CD), CD.build_time SECONDS)

	return TRUE

/obj/structure/clockwork/functional/workshop/proc/build_design_timer_finish(datum/clockwork_design/CD)
	new CD.design_path(loc)
	// Clean up
	being_built = null
	build_start = 0
	build_end = 0
	desc = initial(desc)
	SStgui.update_uis(src)


// DATUM OF CLOCK DESIGN AAAAAAAAAAAAAAAAAAA
/datum/clockwork_design
	var/design_name = "generic"
	var/design_path = null
	var/brass_cost = 0
	var/power_cost = 0
	var/build_time = 1

/datum/clockwork_design/New(name, path, brass, power, time)
	design_name = name
	design_path = path
	brass_cost = brass
	power_cost = power
	build_time = time
