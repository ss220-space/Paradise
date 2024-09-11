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
	if(istype(I, /obj/item/card) || is_sharp(I))
		to_chat(user, span_notice("You have formed two trails of cocaine on the surface."))	// FBI OPEN UP
		var/turf/our_turf = get_turf(src)
		for(var/i = 1 to 2)
			var/obj/item/coca_trail/trail = new(our_turf)
			transfer_fingerprints_to(trail)
			trail.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


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
		add_fingerprint(user)
		if(reagents.total_volume + 5 > reagents.maximum_volume)
			to_chat(user, span_warning("The [name] is full."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		reagents.add_reagent("crack", 5)
		to_chat(user, span_notice("You fill [src] with crack crystals."))
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


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

