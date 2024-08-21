/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	anchored = TRUE
	var/obj/item/card/id/inserted_id
	var/list/categories = list("Gear", "Consumables", "Kinetic Accelerator", "Digging Tools", "Minebot", "Miscellaneous")
	var/list/prize_list // Initialized just below! (if you're wondering why - check CONTRIBUTING.md, look for: "hidden" init proc)
	var/dirty_items = FALSE // Used to refresh the static/redundant data in case the machine gets VV'd

/obj/machinery/mineral/equipment_vendor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/Initialize(mapload)
	. = ..()
	prize_list = list()
	for(var/category in categories)
		prize_list[category] = GLOB.mining_vendor_items[category]

/obj/machinery/mineral/equipment_vendor/proc/remove_id()
	if(inserted_id)
		inserted_id.forceMove(get_turf(src))
		inserted_id = null

/obj/machinery/mineral/equipment_vendor/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
	if(inserted_id && !powered())
		visible_message("<span class='notice'>The ID slot indicator light flickers on \the [src] as it spits out a card before powering down.</span>")
		remove_id()

/obj/machinery/mineral/equipment_vendor/update_icon_state()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/mineral/equipment_vendor/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mineral/equipment_vendor/ui_data(mob/user)
	var/list/data = list()

	// ID
	if(inserted_id)
		data["has_id"] = TRUE
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"points" = inserted_id.mining_points,
		)
	else
		data["has_id"] = FALSE

	return data

/obj/machinery/mineral/equipment_vendor/ui_static_data(mob/user)
	var/list/static_data = list()

	// Available items - in static data because we don't wanna compute this list every time! It hardly changes.
	static_data["items"] = list()
	for(var/cat in prize_list)
		var/list/cat_items = list()
		for(var/prize_name in prize_list[cat])
			var/datum/data/mining_equipment/prize = prize_list[cat][prize_name]
			cat_items[prize_name] = list("name" = prize_name, "price" = prize.cost, "imageId" = ckeyEx(prize_name))
		static_data["items"][cat] = cat_items

	return static_data

/obj/machinery/mineral/equipment_vendor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/mining_vendor)
	)

/obj/machinery/mineral/equipment_vendor/vv_edit_var(var_name, var_value)
	// Gotta update the static data in case an admin VV's the items for some reason..!
	if(var_name == NAMEOF(src, prize_list))
		dirty_items = TRUE
	return ..()

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user, datum/tgui/ui = null)
	// Update static data if need be
	if(dirty_items)
		if(!ui)
			ui = SStgui.get_open_ui(user, src)
		dirty_items = FALSE

	// Open the window
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningVendor", name)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/mineral/equipment_vendor/ui_act(action, params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("logoff")
			if(!inserted_id)
				return
			if(ishuman(usr))
				inserted_id.forceMove_turf()
				usr.put_in_hands(inserted_id, ignore_anim = FALSE)
			else
				inserted_id.forceMove(get_turf(src))
			inserted_id = null
		if("purchase")
			if(!inserted_id)
				return
			var/category = params["cat"] // meow
			var/name = params["name"]
			if(!(category in prize_list) || !(name in prize_list[category])) // Not trying something that's not in the list, are you?
				return
			var/datum/data/mining_equipment/prize = prize_list[category][name]
			if(prize.cost > inserted_id.mining_points) // shouldn't be able to access this since the button is greyed out, but..
				to_chat(usr, "<span class='danger'>You have insufficient points.</span>")
				return

			inserted_id.mining_points -= prize.cost
			var/obj/created = new prize.equipment_path(loc)
			if(Adjacent(usr))
				usr.put_in_hands(created, ignore_anim = FALSE)
		else
			return FALSE
	add_fingerprint()


/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !powered())
		return ..()

	if(istype(I, /obj/item/mining_voucher))
		add_fingerprint(user)
		redeem_voucher(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(inserted_id)
			to_chat(user, span_warning("The [name] is already holding another ID-card."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		inserted_id = I
		ui_interact(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/mineral/equipment_vendor/screwdriver_act(mob/living/user, obj/item/I)
	return default_deconstruction_screwdriver(user, "mining-open", "mining", I)


/obj/machinery/mineral/equipment_vendor/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!panel_open)
		to_chat(user, span_warning("You should open the service panel first."))
		return .
	remove_id() //Prevents deconstructing the ORM from deleting whatever ID was inside it.
	default_deconstruction_crowbar(user, I)


/**
  * Called when someone slaps the machine with a mining voucher
  *
  * Arguments:
  * * voucher - The voucher card item
  * * redeemer - The person holding it
  */
/obj/machinery/mineral/equipment_vendor/proc/redeem_voucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Explorer's Webbing", "Resonator Kit", "Minebot Kit", "Extraction and Rescue Kit", "Plasma Cutter Kit", "Mining Explosives Kit", "Crusher Kit", "Mining Conscription Kit")

	var/selection = tgui_input_list(redeemer, "Pick your equipment", "Mining Voucher Redemption", items)
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return FALSE

	if(!redeemer.drop_transfer_item_to_loc(voucher, src))
		return FALSE

	. = TRUE

	var/drop_location = drop_location()
	switch(selection)
		if("Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/resonator(drop_location)
			new /obj/item/storage/bag/ore/bigger(drop_location)
		if("Minebot Kit")
			new /obj/item/storage/backpack/duffel/minebot_kit(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/storage/backpack/duffel/vendor_ext(drop_location)
		if("Plasma Cutter Kit")
			new /obj/item/gun/energy/plasmacutter(drop_location)
			new /obj/item/t_scanner/adv_mining_scanner/lesser(drop_location)
			new /obj/item/storage/bag/ore/bigger(drop_location)
		if("Mining Explosives Kit")
			new /obj/item/storage/backpack/duffel/miningcharges(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/storage/box/hardmode_box(drop_location)
			new /obj/item/twohanded/kinetic_crusher(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffel/mining_conscript(drop_location)

	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/obj/machinery/mineral/equipment_vendor/Destroy()
	remove_id()
	return ..()


/**********************Mining Equiment Vendor (Golem)**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"
	categories = list("Gear", "Consumables", "Kinetic Accelerator", "Digging Tools", "Minebot", "Miscellaneous", "Extra")

/obj/machinery/mineral/equipment_vendor/golem/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/golem/Initialize()
	. = ..()
	desc += "\nIt seems a few selections have been added."

/**********************Mining Equiment Vendor (Gulag)**************************/

/obj/machinery/mineral/equipment_vendor/labor
	name = "labor camp equipment vendor"
	desc = "An equipment vendor for scum, points collected at an ore redemption machine can be spent here."
	categories = list("Scum")

/obj/machinery/mineral/equipment_vendor/labor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/labor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()


/**********************Mining Equipment Datum**************************/

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/atom/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, equipment_cost)
	equipment_name = name
	equipment_path = path
	cost = equipment_cost

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/items.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining point card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/card/mining_point_card/thousand
	points = 1000

/obj/item/card/mining_point_card/fivethousand
	points = 5000


/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	var/obj/item/card/id/id_card = I.GetID()
	if(id_card)
		add_fingerprint(user)
		if(!points)
			to_chat(user, span_warning("The [name] has zero points left."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_info("You have transfered <b>[points]</b> points to your ID-card."))
		id_card.mining_points += points
		points = 0
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There's [points] points on the card.</span>"

/*********************Jump Boots Implants********************/

/obj/item/storage/box/jumpbootimplant
	name = "box of jumpboot implants"
	desc = "A box holding a set of jumpboot implants. They will require surgical implantation to function."
	icon_state = "cyber_implants"

/obj/item/storage/box/jumpbootimplant/populate_contents()
	new /obj/item/organ/internal/cyberimp/leg/jumpboots(src)
	new /obj/item/organ/internal/cyberimp/leg/jumpboots/l(src)

/*********************mining access card********************/
/obj/item/card/mining_access_card
	name = "mining access card"
	desc = "A small card, that when used on any ID, will add mining access."
	icon_state = "data"

/obj/item/card/mining_access_card/afterattack(atom/movable/AM, mob/user, proximity, params)
	if(!istype(AM, /obj/item/card/id))
		return

	if(!proximity)
		return

	var/obj/item/card/id/I = AM
	I.access |= list(
		ACCESS_MAILSORTING,
		ACCESS_CARGO,
		ACCESS_CARGO_BOT,
		ACCESS_MINT,
		ACCESS_MINING,
		ACCESS_MINING_STATION,
		ACCESS_MINERAL_STOREROOM,
	)
	to_chat(user, "You upgrade [I] with mining access.")
	qdel(src)

