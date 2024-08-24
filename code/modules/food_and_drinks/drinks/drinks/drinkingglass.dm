

/obj/item/reagent_containers/food/drinks/drinkingglass
	name = "glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	item_state = "drinking_glass"
	amount_per_transfer_from_this = 10
	volume = 50
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	materials = list(MAT_GLASS=500)
	max_integrity = 20
	resistance_flags = ACID_PROOF
	drop_sound = 'sound/items/handling/drinkglass_drop.ogg'
	pickup_sound =  'sound/items/handling/drinkglass_pickup.ogg'

/obj/item/reagent_containers/food/drinks/set_APTFT()
	set hidden = FALSE
	..()

/obj/item/reagent_containers/food/drinks/empty()
	set hidden = FALSE
	..()


/obj/item/reagent_containers/food/drinks/drinkingglass/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/egg)) //breaking eggs
		add_fingerprint(user)
		if(!reagents)
			to_chat(user, span_warning("The [I.name] is empty."))
			return ATTACK_CHAIN_PROCEED
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, span_warning("The [name] is full."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You break [I] into [src]."))
		I.reagents.trans_to(src, I.reagents.total_volume)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/reagent_containers/food/drinks/drinkingglass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	if(!reagents.total_volume)
		return
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/burn()
	reagents.clear_reagents()
	extinguish()


/obj/item/reagent_containers/food/drinks/drinkingglass/update_icon_state()
	if(length(reagents.reagent_list))
		var/datum/reagent/check = reagents.get_master_reagent()
		if(check.drink_icon)
			icon_state = check.drink_icon


/obj/item/reagent_containers/food/drinks/drinkingglass/update_overlays()
	. = ..()
	if(length(reagents.reagent_list))
		var/datum/reagent/check = reagents.get_master_reagent()
		if(!check.drink_icon)
			. += mutable_appearance(icon, "glassoverlay", color = mix_color_from_reagents(reagents.reagent_list))
	else
		icon_state = initial(icon_state)


/obj/item/reagent_containers/food/drinks/drinkingglass/update_name(updates)
	. = ..()
	if(length(reagents.reagent_list))
		var/datum/reagent/check = reagents.get_master_reagent()
		name = check.drink_name
	else
		name = initial(name)


/obj/item/reagent_containers/food/drinks/drinkingglass/update_desc(updates)
	. = ..()
	if(length(reagents.reagent_list))
		var/datum/reagent/check = reagents.get_master_reagent()
		desc = check.drink_desc
	else
		desc = initial(desc)


/obj/item/reagent_containers/food/drinks/drinkingglass/on_reagent_change()
	update_appearance()


// for /obj/machinery/vending/sovietsoda
/obj/item/reagent_containers/food/drinks/drinkingglass/soda
	list_reagents = list("sodawater" = 50)


/obj/item/reagent_containers/food/drinks/drinkingglass/cola
	list_reagents = list("cola" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/devilskiss
	list_reagents = list("devilskiss" = 50)

/obj/item/reagent_containers/food/drinks/drinkingglass/alliescocktail
	list_reagents = list("alliescocktail" = 25, "omnizine" = 25)
