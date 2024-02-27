/*
Fishing bites, fish, fishing related stuff
*/
/obj/item/reagent_containers/food/snacks/bait
	name = "worm"
	desc = "Simple bait for fishing, try to use it on fishing rod!"
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "ash_eater"
	list_reagents = list("protein" = 1) //mmmm tasty
	tastes = list("ash" = 5, "hopelessness" = 1)
	bitesize = 1
	foodtype = MEAT
	var/rod_overlay  = "ash_eater_rod"

/obj/item/reagent_containers/food/snacks/bait/examine(mob/user)
	. = ..()
	. += span_notice("You could use this as a bait for a fishing rod.")


/obj/item/reagent_containers/food/snacks/bait/ash_eater
	name = "ash eater"
	desc = "A tiny worm with a thousand sharp teeth covering its mouth. There are rumors that these crumbs could grow to gigantic sizes. The ash must flow."
	icon_state = "ash_eater"
	rod_overlay = "ash_eater_rod"

/obj/item/reagent_containers/food/snacks/bait/bloody_leach
	name = "bloody leach"
	desc = "A parasitic life form that sucks on the victim with its suckers and feeds on it. Her petite body is covered in red from drinking blood."
	icon_state = "bloody_leach"
	rod_overlay = "bloody_leach_rod"

/obj/item/reagent_containers/food/snacks/bait/goldgrub_larva
	name = "goldgrub larva"
	desc = "A tiny worm that feeds on minerals sprinkled into the ashes. It is just as timid as its adult relatives."
	icon_state = "goldgrub_larva"
	rod_overlay = "goldgrub_larva_rod"

//shrimp. Working little different than standart bait

/obj/item/reagent_containers/food/snacks/charred_krill
	name = "charred krill"
	desc = "One of the rarest inhabitants of Lavaland, considered extinct. This shrimp is one of the most favorite treats for local fish."
	icon = 'icons/obj/lavaland/lava_fishing.dmi'
	icon_state = "charred_krill"
	list_reagents = list("protein" = 1)
	bitesize = 1
	tastes = list("ash" = 5, "wasted opportunity" = 1)
	var/in_lava = FALSE

/obj/item/reagent_containers/food/snacks/charred_krill/examine(mob/user)
	. = ..()
	. += span_notice("You could throw it into lava to attract fish onto the surface.")

/obj/item/reagent_containers/food/snacks/charred_krill/can_be_pulled(atom/movable/user, force, show_message)
	if(in_lava)
		if(show_message)
			to_chat(user, span_warning("[src] is almost drowned in lava!"))
		return

/obj/item/reagent_containers/food/snacks/charred_krill/attack_hand(mob/user, pickupfireoverride)
	if(in_lava)
		return
	else
		return ..()

/obj/item/reagent_containers/food/snacks/charred_krill/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is going to krill himself! Oh god...</span>")
	user.say("goodbye krill world.")
	sleep(20)
	var/obj/item/reagent_containers/food/snacks/charred_krill/krill = new /obj/item/reagent_containers/food/snacks/charred_krill(drop_location())
	krill.desc += " Look's like someone KRILLED himself."
	qdel(user)
	return OBLITERATION
