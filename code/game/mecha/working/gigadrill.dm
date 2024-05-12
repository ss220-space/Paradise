/obj/mecha/working/gigadrill
	name = "Old driller"
	desc = "Old fshion dissel driller. It's so fucking big."
	icon_state = "gigadrill"
	initial_icon = "gigadrill"
	icon = 'icons/obj/mecha/gigadrill.dmi'
	step_in = 8
	fast_pressure_step_in = 8
	slow_pressure_step_in = 8
	max_temperature = 20000
	max_integrity = 400
	lights_power = 3
	lights_color = "#ffb366"
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 20, "laser" = 15, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 10, "fire" = 100, "acid" = 100)
	max_equip = 2
	deflect_chance = 15
	mech_enter_time = 60
	var/datum/looping_sound/gigadrill/soundloop

	starting_voice = /obj/item/mecha_modkit/voice/silent

	ruin_mecha = TRUE
	stepsound = null
	turnsound = null
//	wreckage = /obj/effect/decal/mecha_wreckage/gigadrill // no dmi :(

/obj/mecha/working/gigadrill/Initialize()
	. = ..()
	soundloop = new(list(src), FALSE)
	pixel_x = -16
	pixel_y = -16
	var/obj/item/mecha_parts/mecha_equipment/drill/giga/drill = new
	drill.attach(src)
	LAZYADD(cargo, new /obj/structure/ore_box(src))

	var/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/clamp = new
	clamp.integrated = TRUE
	clamp.attach(src)

/obj/mecha/working/gigadrill/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)

/obj/mecha/working/gigadrill/transfer_ai()
	return FALSE

/obj/mecha/working/gigadrill/mmi_move_inside()
	return FALSE

/obj/mecha/working/gigadrill/toggle_internal_tank()
	return FALSE

/obj/mecha/working/gigadrill/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/mecha/working/gigadrill/moved_inside(var/mob/living/carbon/human/H as mob)
	..()
	soundloop.start()

/obj/mecha/working/gigadrill/go_out(forced, atom/newloc = loc)
	..()
	soundloop.stop()

/*
/obj/effect/decal/mecha_wreckage/gigadrill
	// TODO: SPRITE PLS
	//icon = 'icons/obj/vehicles.dmi'
	//icon_state = "gigadrill_wreck"
	name = "gigadrill wreckage"
	desc = "The rocks are safer.  For now."
*/
