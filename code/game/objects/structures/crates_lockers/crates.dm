// MARK: Basic crate
/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	climbable = TRUE
	open_sound = 'sound/machines/crate_open.ogg'
	close_sound = 'sound/machines/crate_close.ogg'
	pass_flags_self = PASSSTRUCTURE|LETPASSTHROW
	var/rigged = FALSE
	var/obj/item/paper/manifest/manifest
	// A list of beacon names that the crate will announce the arrival of, when delivered.
	var/list/announce_beacons = list()
	/// Overlay for lightmask of our crate
	var/overlay_lightmask
	/// Can our crate make emissive light?
	var/can_be_emissive = FALSE

/obj/structure/closet/crate/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "_open" : ""]"

/obj/structure/closet/crate/update_overlays()
	// . = ..() is not needed here because of different overlay handling logic for crates
	underlays.Cut()
	. = list()
	if(manifest)
		. += "manifest"
	if(can_be_emissive)
		underlays += emissive_appearance(icon, overlay_lightmask, src)

/obj/structure/closet/crate/can_open()
	return TRUE

/obj/structure/closet/crate/can_close()
	return TRUE

/obj/structure/closet/crate/open(by_hand = FALSE)
	if(opened || !can_open())
		return FALSE

	if(by_hand)
		for(var/obj/O in src)
			if(O.density)
				var/response = tgui_alert(usr, "This crate has been packed extremely tightly, an item inside won't fit back inside. Are you sure you want to open it?", "Compressed Materials Warning", list("Yes", "No"))
				if(response != "Yes" || !Adjacent(usr))
					return FALSE
				break

	if(rigged && locate(/obj/item/radio/electropack) in src)
		if(isliving(usr))
			var/mob/living/L = usr
			if(L.electrocute_act(17, src))
				do_sparks(5, TRUE, src)
				return 2

	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	for(var/obj/O in src) //Objects
		O.forceMove(loc)
	for(var/mob/M in src) //Mobs
		M.forceMove(loc)

	opened = TRUE
	update_icon()

	if(climbable)
		structure_shaken()

	return TRUE

/obj/structure/closet/crate/close()
	if(!opened || !can_close())
		return FALSE

	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	var/itemcount = 0
	for(var/atom/movable/O in get_turf(src))
		if(itemcount >= storage_capacity)
			break
		if(O.density || O.anchored || iscloset(O) || isobserver(O) || O.has_buckled_mobs())
			continue
		O.forceMove(src)
		itemcount++

	opened = FALSE
	update_icon()
	return TRUE

/obj/structure/closet/crate/attackby(obj/item/I, mob/user, params)
	if(!opened && try_rig(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/obj/structure/closet/crate/proc/try_rig(obj/item/W, mob/user)
	if(iscoil(W))
		var/obj/item/stack/cable_coil/C = W
		if(rigged)
			to_chat(user, span_notice("[src] is already rigged!"))
			return TRUE
		if(C.use(15))
			to_chat(user, span_notice("You rig [src]."))
			rigged = TRUE
		else
			to_chat(user, span_warning("You need atleast 15 wires to rig [src]!"))
		return TRUE
	if(istype(W, /obj/item/radio/electropack))
		if(rigged)
			if(!user.drop_transfer_item_to_loc(W, src))
				to_chat(user, span_warning("[W] seems to be stuck to your hand!"))
				return TRUE
			to_chat(user, span_notice("You attach [W] to [src]."))
		return TRUE

/obj/structure/closet/crate/wirecutter_act(mob/living/user, obj/item/I)
	if(opened)
		return
	if(!rigged)
		return

	if(I.use_tool(src, user))
		to_chat(user, span_notice("You cut away the wiring."))
		playsound(loc, I.usesound, 100, TRUE)
		rigged = FALSE
		return TRUE

/obj/structure/closet/crate/welder_act()
	return

/// Removes the supply manifest from the closet
/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	add_fingerprint(user)
	to_chat(user, span_notice("You tear the manifest off of [src]."))
	playsound(loc, 'sound/items/poster_ripped.ogg', 75, TRUE)
	manifest.forceMove_turf(drop_location(src))
	if(ishuman(user))
		user.put_in_hands(manifest, ignore_anim = FALSE)
	manifest = null
	update_appearance()

/obj/structure/closet/crate/attack_hand(mob/user)
	if(manifest)
		tear_manifest(user)
	else
		var/obj/item/radio/electropack = locate() in src
		if(rigged && electropack)
			if(isliving(user))
				var/mob/living/L = user
				if(L.electrocute_act(17, electropack))
					do_sparks(5, TRUE, src)
					return
		add_fingerprint(user)
		toggle(user, by_hand = TRUE)

// Called when a crate is delivered by MULE at a location, for notifying purposes
/obj/structure/closet/crate/proc/notifyRecipient(destination)
	var/msg = "[capitalize(name)] has arrived at [destination]."
	if(destination in announce_beacons)
		for(var/obj/machinery/requests_console/D in GLOB.allRequestConsoles)
			if(D.department in src.announce_beacons[destination])
				D.createMessage(name, "Your Crate has Arrived!", msg, 1)

// MARK: Specific crates

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "plasticcrate"

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash Cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/trashcart/NTdelivery
	name = "Special Delivery from Central Command"

/obj/structure/closet/crate/trashcart/gibs
	desc = "A heavy, metal trashcart with wheels. You better don't ask."
	name = "trash cart with gibs"
	icon_state = "trashcartgib"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of the RCD."
	name = "RCD crate"

/obj/structure/closet/crate/rcd/populate_contents()
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd_ammo(src)
	new /obj/item/rcd(src)

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "Freezer"
	icon_state = "freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40

/obj/structure/closet/crate/freezer/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/datum/gas_mixture/gas = ..()
	if(!gas)
		var/turf/location = get_turf(src)
		gas = location.get_readonly_air()
	var/datum/gas_mixture/newgas = new/datum/gas_mixture()
	newgas.set_oxygen(gas.oxygen())
	newgas.set_carbon_dioxide(gas.carbon_dioxide())
	newgas.set_nitrogen(gas.nitrogen())
	newgas.set_toxins(gas.toxins())
	newgas.volume = gas.volume
	newgas.set_temperature(gas.temperature())
	if(newgas.temperature() <= target_temp)
		return

	if((newgas.temperature() - cooling_power) > target_temp)
		newgas.set_temperature(newgas.temperature() - cooling_power)
	else
		newgas.set_temperature(target_temp)
	return newgas

/obj/structure/closet/crate/can
	desc = "A large can, looks like a bin to me."
	name = "garbage can"
	icon_state = "largebin"
	anchored = TRUE

/obj/structure/closet/crate/can/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 40)

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radioactive gear crate"
	icon_state = "radiation"

/obj/structure/closet/crate/radiation/populate_contents()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/vault
	desc = "Ящик с ценностями."
	name = "vault crate"
	icon_state = "vaultcrate"

/obj/structure/closet/crate/vault/get_ru_names()
	return list(
		NOMINATIVE = "ящик с ценностями",
		GENITIVE = "ящика с ценностями",
		DATIVE = "ящику с ценностями",
		ACCUSATIVE = "ящик с ценностями",
		INSTRUMENTAL = "ящиком с ценностями",
		PREPOSITIONAL = "ящике с ценностями",
	)

/obj/structure/closet/crate/wooden //i'm sure hope this won't be used as cheese strat to obtain cargo points
	name = "wooden crate"
	desc = "Ящик, сделанный из дерева."
	icon_state = "wooden_crate"

/obj/structure/closet/crate/wooden/get_ru_names()
	return list(
		NOMINATIVE = "деревянный ящик",
		GENITIVE = "деревянного ящика",
		DATIVE = "деревянному ящику",
		ACCUSATIVE = "деревянный ящик",
		INSTRUMENTAL = "деревянным ящиком",
		PREPOSITIONAL = "деревянном ящике",
	)

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/hydroponics/prespawned
	//This exists so the prespawned hydro crates spawn with their contents.

// Do I need the definition above? Who knows!
/obj/structure/closet/crate/hydroponics/prespawned/populate_contents()
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/reagent_containers/glass/bucket(src)
	new /obj/item/screwdriver(src)
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/wrench(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wirecutters(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/shovel/spade(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/storage/box/beakers(src)
	new /obj/item/hand_labeler(src)
	new /obj/item/hand_labeler(src)

/obj/structure/closet/crate/sci
	name = "science crate"
	desc = "A science crate."
	icon_state = "scicrate"

/obj/structure/closet/crate/engineering/electrical
	name = "electrical engineering crate"
	desc = "An electrical engineering crate."
	icon_state = "electricalcrate"

/obj/structure/closet/crate/tape/populate_contents()
	if(prob(10))
		new /obj/item/bikehorn/rubberducky(src)

//crates of gear in the free golem ship
/obj/structure/closet/crate/golemgear/populate_contents()
	new /obj/item/storage/backpack/industrial(src)
	new /obj/item/shovel(src)
	new /obj/item/pickaxe(src)
	new /obj/item/t_scanner/adv_mining_scanner/lesser(src)
	new /obj/item/storage/bag/ore(src)
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/card/id/golem(src)
	new /obj/item/flashlight/lantern(src)

//syndie crates by Furukai
/obj/structure/closet/crate/syndicate
	desc = "Definitely a property of an evil corporation!"
	icon_state = "syndiecrate"
	material_drop = /obj/item/stack/sheet/mineral/plastitanium
