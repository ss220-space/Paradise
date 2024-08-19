
/obj/machinery/kitchen_machine/oven
	name = "oven"
	desc = "Cookies are ready, dear."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "oven_off"
	cook_verbs = list("Baking", "Roasting", "Broiling")
	recipe_type = RECIPE_OVEN
	off_icon = "oven_off"
	on_icon = "oven_on"
	broken_icon = "oven_broke"
	dirty_icon = "oven_dirty"
	open_icon = "oven_open"

// see code/modules/food/recipes_oven.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/oven/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/oven(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/oven/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/oven(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/oven/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced


/obj/machinery/kitchen_machine/oven/special_grab_attack(atom/movable/grabbed_thing, mob/living/grabber)
	if(!ishuman(grabbed_thing) || !Adjacent(grabbed_thing))
		return
	var/mob/living/carbon/human/victim = grabbed_thing
	var/obj/item/organ/external/head/head = victim.get_organ(BODY_ZONE_HEAD)
	if(!head)
		to_chat(grabber, span_warning("This person doesn't have a head!"))
		return
	add_fingerprint(grabber)
	victim.visible_message(
		span_danger("[grabber] bashes [victim]'s head in [src]'s door!"),
		span_userdanger("[grabber] bashes your head in [src]'s door! It feels rather hot in the oven!"),
	)
	if(victim.has_pain())
		victim.emote("scream")
	//5 fire damage, 15 brute damage, and knockdown because your head was just in a hot oven with the door bashing into your neck!
	victim.apply_damage(5, BURN, BODY_ZONE_HEAD)
	victim.apply_damage(15, BRUTE, BODY_ZONE_HEAD)
	victim.Knockdown(2 SECONDS)
	add_attack_logs(grabber, victim, "Smashed with [src]")
	//Removes the grip to prevent rapid bashes. With the knockdown, you PROBABLY can't run unless they are slow to grab you again...
	grabber.stop_pulling()

