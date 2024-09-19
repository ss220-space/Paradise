// Potato
/obj/item/seeds/potato
	name = "pack of potato seeds"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "seed-potato"
	species = "potato"
	plantname = "Potato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/potato
	lifespan = 30
	maturation = 10
	production = 1
	yield = 4
	growthstages = 4
	growing_icon = 'icons/obj/hydroponics/growing_vegetables.dmi'
	icon_grow = "potato-grow"
	icon_dead = "potato-dead"
	genes = list(/datum/plant_gene/trait/battery)
	mutatelist = list(/obj/item/seeds/potato/sweet)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/potato
	seed = /obj/item/seeds/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	filling_color = "#E9967A"
	tastes = list("potato" = 1)
	bitesize = 100
	distill_reagent = "vodka"


/obj/item/reagent_containers/food/snacks/grown/potato/wedges
	name = "potato wedges"
	desc = "Slices of neatly cut potato."
	icon_state = "potato_wedges"
	filling_color = "#E9967A"
	tastes = list("potato" = 1)
	bitesize = 100
	distill_reagent = "sbiten"


/obj/item/reagent_containers/food/snacks/grown/potato/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !is_sharp(I))
		return .

	if(!isturf(loc))
		to_chat(user, span_warning("You cannot cut [src] [ismob(loc) ? "in inventory" : "in [loc]"]."))
		return .

	var/static/list/acceptable_surfaces = typecacheof(list(
		/obj/structure/table,
		/obj/machinery/optable,
		/obj/item/storage/bag/tray,
	))
	var/acceptable = FALSE
	for(var/thing in loc)
		if(is_type_in_typecache(thing, acceptable_surfaces))
			acceptable = TRUE
			break
	if(!acceptable)
		to_chat(user, span_warning("You cannot cut [src] here! You need a table or at least a tray to do it."))
		return .

	. |= ATTACK_CHAIN_BLOCKED_ALL
	user.visible_message(
		span_notice("[user] cuts the potato into wedges with [I]."),
		span_notice("You have cut the potato into wedges."),
	)
	var/obj/item/reagent_containers/food/snacks/grown/potato/wedges/wedges = new(loc)
	transfer_fingerprints_to(wedges)
	wedges.add_fingerprint(user)
	qdel(src)


// Sweet Potato
/obj/item/seeds/potato/sweet
	name = "pack of sweet potato seeds"
	desc = "These seeds grow into sweet potato plants."
	icon_state = "seed-sweetpotato"
	species = "sweetpotato"
	plantname = "Sweet Potato Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/potato/sweet
	mutatelist = list()
	reagents_add = list("vitamin" = 0.1, "sugar" = 0.1, "plantmatter" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/potato/sweet
	seed = /obj/item/seeds/potato/sweet
	name = "sweet potato"
	desc = "It's sweet."
	tastes = list("sweet potato" = 1)
	icon_state = "sweetpotato"
