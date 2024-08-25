/datum/holiday/xmas/handle_event()
	for(var/obj/structure/flora/tree/pine/xmas/xmas in world)
		if(!is_station_level(xmas.z))	continue
		for(var/turf/simulated/floor/T in (xmas.get_all_adjacent_turfs() - get_turf(xmas)))
			var/direction = get_dir(xmas, T)
			for(var/i=1,i<=rand(1,5),i++)
				var/obj/item/a_gift/gift = new(T)
				handle_present_location(gift, direction, 16)

	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/Ian in GLOB.mob_list)
		Ian.place_on_head(new /obj/item/clothing/head/helmet/space/santahat)
	for(var/datum/crafting_recipe/snowman/S in GLOB.crafting_recipes)
		S.always_availible = TRUE
		break
	var/datum/supply_packs/misc/snow_machine/xmas = SSshuttle.supply_packs["[/datum/supply_packs/misc/snow_machine]"]
	xmas.special = FALSE

	//As fun at it is sounds, peacefulness is better
	//if(prob(eventChance))
	//	spawnTree()

/**
 * Offsets pixel location for presents to move visually closer to direction
 */
/datum/holiday/xmas/proc/handle_present_location(obj/present, center_direction, offset)
	var/pixel_x_offset = 0
	var/pixel_y_offset = 0
	switch(center_direction)
		if(NORTH)
			pixel_x_offset = rand(-offset, offset)
			pixel_y_offset = rand(-offset, 0)
		if(SOUTH)
			pixel_x_offset = rand(-offset, offset)
			pixel_y_offset = rand(0, offset)
		if(EAST)
			pixel_x_offset = rand(-offset, 0)
			pixel_y_offset = rand(-offset, offset)
		if(WEST)
			pixel_x_offset = rand(0, offset)
			pixel_y_offset = rand(-offset, offset)
		if(NORTHEAST)
			pixel_x_offset = rand(-offset, 0)
			pixel_y_offset = rand(-offset, 0)
		if(NORTHWEST)
			pixel_x_offset = rand(0, offset)
			pixel_y_offset = rand(-offset, 0)
		if(SOUTHEAST)
			pixel_x_offset = rand(-offset, 0)
			pixel_y_offset = rand(0, offset)
		if(SOUTHWEST)
			pixel_x_offset = rand(0, offset)
			pixel_y_offset = rand(0, offset)

	present.pixel_x = pixel_x_offset
	present.pixel_y = pixel_y_offset

/datum/holiday/xmas/proc/spawnTree()
	for(var/obj/structure/flora/tree/pine/xmas in world)
		var/mob/living/simple_animal/hostile/tree/evil_tree = new /mob/living/simple_animal/hostile/tree(xmas.loc)
		evil_tree.icon_state = xmas.icon_state
		evil_tree.icon_living = evil_tree.icon_state
		evil_tree.icon_dead = evil_tree.icon_state
		evil_tree.icon_gib = evil_tree.icon_state
		qdel(xmas)


/obj/item/toy/xmas_cracker
	name = "xmas cracker"
	icon = 'icons/obj/christmas.dmi'
	icon_state = "cracker"
	desc = "Directions for use: Requires two people, one to pull each end."
	var/cracked = FALSE


/obj/item/toy/xmas_cracker/update_icon_state()
	icon_state = "[initial(icon_state)][cracked ? "1" : ""]"


/obj/item/toy/xmas_cracker/other_half
	icon_state = "cracker2"
	cracked = TRUE


/obj/item/toy/xmas_cracker/other_half/update_icon_state()
	return


/obj/item/toy/xmas_cracker/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(cracked || !ishuman(target) || (target.stat != CONSCIOUS) || target.get_active_hand())
		return ..()

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	target.visible_message(
		span_notice("[user] and [target] pop [src]! *pop*"),
		span_notice("You pull [src] with [target]! *pop*"),
		span_italics("You hear a *pop*."),
	)
	var/turf/user_turf = get_turf(user)
	var/obj/item/paper/Joke = new(user_turf)
	Joke.name = "[pick("awful","terrible","unfunny")] joke"
	Joke.info = pick("What did one snowman say to the other?\n\n<i>'Is it me or can you smell carrots?'</i>",
		"Why couldn't the snowman get laid?\n\n<i>He was frigid!</i>",
		"Where are santa's helpers educated?\n\n<i>Nowhere, they're ELF-taught.</i>",
		"What happened to the man who stole advent calanders?\n\n<i>He got 25 days.</i>",
		"What does Santa get when he gets stuck in a chimney?\n\n<i>Claus-trophobia.</i>",
		"Where do you find chili beans?\n\n<i>The north pole.</i>",
		"What do you get from eating tree decorations?\n\n<i>Tinsilitis!</i>",
		"What do snowmen wear on their heads?\n\n<i>Ice caps!</i>",
		"Why is Christmas just like life on ss13?\n\n<i>You do all the work and the fat guy gets all the credit.</i>",
		"Why doesn�t Santa have any children?\n\n<i>Because he only comes down the chimney.</i>")

	var/obj/item/clothing/head/festive/hat = new(user_turf)
	user.equip_to_slot_if_possible(hat, ITEM_SLOT_HEAD)

	cracked = TRUE
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item(update_speedmods = FALSE)

	var/obj/item/toy/xmas_cracker/other_half/other_half = new(user_turf)
	target.put_in_active_hand(other_half, ignore_anim = FALSE)
	playsound(user, 'sound/effects/snap.ogg', 50, TRUE)


/obj/item/clothing/head/festive
	name = "festive paper hat"
	icon_state = "xmashat"
	desc = "A crappy paper hat that you are REQUIRED to wear."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
