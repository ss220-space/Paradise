
/obj/machinery/kitchen_machine/grill
	name = "grill"
	desc = "Backyard grilling, IN SPACE."
	icon = 'icons/obj/machines/cooking_machines.dmi'
	icon_state = "grill_off"
	cook_verbs = list("Grilling", "Searing", "Frying")
	recipe_type = RECIPE_GRILL
	off_icon = "grill_off"
	on_icon = "grill_on"
	broken_icon = "grill_broke"
	dirty_icon = "grill_dirty"
	open_icon = "grill_open"

// see code/modules/food/recipes_grill.dm for recipes

/*******************
*   Initialising
********************/

/obj/machinery/kitchen_machine/grill/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/grill(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stock_parts/micro_laser/ultra(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	RefreshParts()

/obj/machinery/kitchen_machine/grill/RefreshParts()
	var/E
	for(var/obj/item/stock_parts/micro_laser/M in component_parts)
		E += M.rating
	efficiency = round((E/2), 1) // There's 2 lasers, so halve the effect on the efficiency to keep it balanced


/obj/machinery/kitchen_machine/grill/special_grab_attack(atom/movable/grabbed_thing, mob/living/grabber)
	if(!ishuman(grabbed_thing) || !Adjacent(grabbed_thing))
		return
	var/mob/living/carbon/human/victim = grabbed_thing
	add_fingerprint(grabber)
	victim.visible_message(
		span_danger("[grabber] forces [victim] onto [src], searing [victim]'s body!"),
		span_userdanger("[grabber] forces you onto [src]! It burns!"),
	)
	if(victim.has_pain())
		victim.emote("scream")
	victim.adjustFireLoss(30)
	add_attack_logs(grabber, victim, "Burned with [src]")
	//Removes the grip to prevent rapid sears and give you a chance to run
	grabber.stop_pulling()

