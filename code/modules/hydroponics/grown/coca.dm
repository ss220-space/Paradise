/obj/item/seeds/coca
	name = "pack of coca bush"
	desc = "This seed grows into coca bush."
	icon_state = "seed-coca"
	species = "coca"
	plantname = "Coca Bush"
	product = /obj/item/reagent_containers/food/snacks/grown/coca
	lifespan = 50
	endurance = 40
	maturation = 5
	production = 3
	yield = 5
	potency = 10
	growthstages = 6
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	icon_dead = "tobacco-dead"
	reagents_add = list("cocaextract" = 0.1, "plantmatter" = 0.1)
	genes = list(/datum/plant_gene/trait/repeated_harvest)

/obj/item/reagent_containers/food/snacks/grown/coca
	seed = /obj/item/seeds/coca
	name = "coca leaves"
	desc = "Looks inedible"
	icon_state = "coca"
	filling_color = "#008000"
	bitesize_mod = 2
	tastes = list("coca extract" = 1)

/obj/item/coca_packet
	name = "coca packet"
	desc = "Zip packet of cocainet. Can`t wait to make trail of it."
	icon_state = "coca_packet"

/obj/item/coca_packet/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card) || I.sharp)
		new /obj/item/coca_trail(get_turf(src))
		new /obj/item/coca_trail(get_turf(src))
		qdel(src)
	. = ..()

/obj/item/crack_crystal
	name = "crystal"
	desc = "White crack crystal. Where is my pipe?"
	icon_state = "crack_crystal"

/obj/item/clothing/mask/cigarette/pipe/crack_pipe
	name = "glass pipe"
	desc = "Just fill and ignite."
	icon = 'icons/obj/items.dmi'
	icon_state = "crackpipe0"
	item_state = "crackpipe0"
	icon_on = "crackpipe1"
	icon_off = "crackpipe0"
	list_reagents = list()
	smoketime = 150

/obj/item/clothing/mask/cigarette/pipe/crack_pipe/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crack_crystal))
		src.reagents.add_reagent("crack", 5)
		to_chat(user, span_notice("You fill \the [src] with crack crystal."))
		qdel(I)
		return
	. = ..()

/obj/item/coca_trail
	name = "cocaine trail"
	desc = "Straight trail of white powder"
	icon_state = "coca_trail"

/obj/item/coca_trail/pickup(mob/user)
	SHOULD_CALL_PARENT(FALSE)
	user.reagents.add_reagent("cocaine", 5)
	to_chat(user, span_notice("You sniff the trail of cocaine and it hits you to the very brain."))
	qdel(src)
	return FALSE

