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
