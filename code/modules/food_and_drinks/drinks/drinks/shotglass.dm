/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	name = "shot glass"
	desc = "No glasses were shot in the making of this glass."
	icon_state = "shotglass"
	custom_fire_overlay = "shotglass_fire"
	amount_per_transfer_from_this = 15
	volume = 15
	materials = list(MAT_GLASS=100)
	var/light_intensity = 2
	light_color = LIGHT_COLOR_LIGHTBLUE
	resistance_flags = FLAMMABLE

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/on_reagent_change()
	if(!isShotFlammable() && (resistance_flags & ON_FIRE))
		extinguish()
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/update_name()
	. = ..()
	if(reagents.total_volume)
		name = "shot glass of " + reagents.get_master_reagent_name() //No matter what, the glass will tell you the reagent's name. Might be too abusable in the future.
		if(resistance_flags & ON_FIRE)
			name = "flaming [name]"
	else
		name = "shot glass"


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]1")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 25)
				filling.icon_state = "[icon_state]1"
			if(26 to 79)
				filling.icon_state = "[icon_state]5"
			if(80 to INFINITY)
				filling.icon_state = "[icon_state]12"
		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/proc/clumsilyDrink(mob/living/carbon/human/user) //Clowns beware
	if(!(resistance_flags & ON_FIRE))
		return ATTACK_CHAIN_PROCEED
	user.visible_message(
		span_warning("[user] pours [src] all over [user.p_them()]self!"),
		span_danger("You pour [src] all over yourself!"),
		span_italics("You hear a 'whoompf' and a sizzle."),
	)
	extinguish(TRUE)
	reagents.reaction(user, REAGENT_TOUCH)
	reagents.clear_reagents()
	user.IgniteMob()
	return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/proc/isShotFlammable()
	var/datum/reagent/R = reagents.get_master_reagent()
	if(istype(R, /datum/reagent/consumable/ethanol))
		var/datum/reagent/consumable/ethanol/A = R
		if(A.volume >= 5 && A.alcohol_perc >= 0.35) //Only an approximation to if something's flammable but it will do
			return TRUE

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = FALSE)
	if(!isShotFlammable() || (resistance_flags & ON_FIRE)) //You can't light a shot that's not flammable!
		return
	..()
	set_light_range_power_color(light_intensity, 1, light_color)
	set_light_on(TRUE)
	visible_message("<span class = 'notice'>[src] begins to burn with a blue hue!</span>")
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/extinguish(silent = FALSE)
	..()
	set_light_on(FALSE)
	if(!silent)
		visible_message("<span class = 'notice'>The dancing flame on [src] dies out.</span>")
	update_appearance(UPDATE_NAME|UPDATE_OVERLAYS)

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/burn() //Let's override fire deleting the reagents inside the shot
	return


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && (resistance_flags & ON_FIRE))
		return clumsilyDrink(user)
	return ..()


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ATTACK_CHAIN_CANCEL_CHECK(.) && is_hot(I))
		fire_act()


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack_hand(mob/user, pickupfireoverride = TRUE)
	..()

/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/attack_self(mob/living/carbon/human/user)
	..()
	if(!(resistance_flags & ON_FIRE))
		return
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		clumsilyDrink(user)
	else
		user.visible_message("<span class = 'notice'>[user] places [user.p_their()] hand over [src] to put it out!</span>", "<span class = 'notice'>You use your hand to extinguish [src]!</span>")
		extinguish()


/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/MouseDrop(mob/living/carbon/human/user, src_location, over_location, src_control, over_control, params)
	if(!ishuman(user) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return ..()

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50) && (resistance_flags & ON_FIRE))
		clumsilyDrink(user)
		return

	return ..()
