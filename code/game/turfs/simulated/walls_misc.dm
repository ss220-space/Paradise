/turf/simulated/wall/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	canSmoothWith = null
	smooth = NONE
	sheet_type = /obj/item/stack/sheet/runed_metal
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult
	var/holy = FALSE

/turf/simulated/wall/cult_fake
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head remember school. Oh no.."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	canSmoothWith = null
	smooth = NONE
	sheet_type = /obj/item/stack/sheet/runed_metal_fake
	sheet_amount = 1
	girder_type = /obj/structure/girder/cult_fake


/turf/simulated/wall/cult/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)


/turf/simulated/wall/cult/update_icon_state()
	if(SSticker?.cultdat && !holy)
		icon_state = SSticker.cultdat.cult_wall_icon_state
		return
	icon_state = initial(icon_state)


/turf/simulated/wall/cult_fake/Initialize(mapload)
	. = ..()
	if(SSticker.mode)
		new /obj/effect/temp_visual/cult/turf(src)

/turf/simulated/wall/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/simulated/wall/cult/artificer/holy
	name = "holy runed wall"
	desc = "Теплая стена, один взгляд на которую наполняет вас святостью."
	icon_state = "holy"
	sheet_type = /obj/item/stack/sheet/metal
	girder_type = /obj/structure/girder
	holy = TRUE

/turf/simulated/wall/cult/artificer/break_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))
	return null //excuse me we want no runed metal here

/turf/simulated/wall/cult/artificer/devastate_wall()
	new /obj/effect/temp_visual/cult/turf(get_turf(src))

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/cult/devastate_wall()
	new sheet_type(get_turf(src), sheet_amount)

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "rusty_wall-0"
	base_icon_state = "rusty_wall"

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rusty_reinforced_wall-0"
	base_icon_state = "rusty_reinforced_wall"

/turf/simulated/wall/r_wall/coated			//Coated for heat resistance
	name = "coated reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms. It seems to have additional plating to protect against heat."
	icon = 'icons/turf/walls/coated_reinforced_wall.dmi'
	max_temperature = INFINITY
	smooth = SMOOTH_BITMASK
	base_icon_state = "coated_reinforced_wall"

//Clockwork walls
/turf/simulated/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	canSmoothWith = SMOOTH_GROUP_CLOCKWORK_WALLS
	smoothing_groups = SMOOTH_GROUP_CLOCKWORK_WALLS
	smooth = SMOOTH_BITMASK
	explosion_block = 2
	hardness = 10
	slicing_duration = 80
	sheet_type = /obj/item/stack/sheet/brass
	sheet_amount = 1
	girder_type = /obj/structure/clockwork/wall_gear
	baseturf = /turf/simulated/floor/clockwork
	var/heated
	var/obj/effect/clockwork/overlay/wall/realappearance

/turf/simulated/wall/clockwork/fake
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates in the corner of your eyes. Maybe just a wind..."
	sheet_type = /obj/item/stack/sheet/brass_fake
	sheet_amount = 1
	girder_type = /obj/structure/clockwork/wall_gear/fake
	baseturf = /turf/simulated/floor/clockwork/fake

/turf/simulated/wall/clockwork/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/wall(src)
	new /obj/effect/temp_visual/ratvar/beam(src)
	realappearance = new /obj/effect/clockwork/overlay/wall(src)
	realappearance.linked = src

/turf/simulated/wall/clockwork/Destroy()
	QDEL_NULL(realappearance)
	return ..()

/turf/simulated/wall/clockwork/ReplaceWithLattice()
	..()
	for(var/obj/structure/lattice/L in src)
		L.ratvar_act()

/turf/simulated/wall/clockwork/narsie_act()
	..()
	if(istype(src, /turf/simulated/wall/clockwork)) //if we haven't changed type
		var/previouscolor = color
		color = COLOR_CULT_RED
		animate(src, color = previouscolor, time = 8)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_atom_colour)), 8)

/turf/simulated/wall/clockwork/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we want a gear!
			transfer_fingerprints_to(newgirder)

	ChangeTurf(/turf/simulated/floor/clockwork)
	return TRUE

/turf/simulated/wall/clockwork/devastate_wall()
	new sheet_type(src, sheet_amount)

/turf/simulated/wall/clockwork/mech_melee_attack(obj/mecha/M)
	..()
	if(heated)
		to_chat(M.occupant, span_userdanger("The wall's intense heat completely reflects your [M.name]'s attack!"))
		M.take_damage(20, BURN)

/turf/simulated/wall/clockwork/proc/turn_up_the_heat()
	if(!heated)
		name = "superheated [name]"
		visible_message(span_warning("[src] sizzles with heat!"))
		playsound(src, 'sound/machines/fryer/deep_fryer_emerge.ogg', 50, TRUE)
		heated = TRUE
		hardness = -100 //Lower numbers are tougher, so this makes the wall essentially impervious to smashing
		slicing_duration = 150
		animate(realappearance, color = "#FFC3C3", time = 5)
	else
		name = initial(name)
		visible_message(span_notice("[src] cools down."))
		heated = FALSE
		hardness = initial(hardness)
		slicing_duration = initial(slicing_duration)
		animate(realappearance, color = initial(realappearance.color), time = 25)
