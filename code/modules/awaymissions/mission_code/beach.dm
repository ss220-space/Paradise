/obj/effect/waterfall
	name = "waterfall effect"
	icon_state = "extinguish"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT

	var/water_frequency = 15
	var/water_timer = 0

/obj/effect/waterfall/Initialize(mapload)
	. = ..()
	
	water_timer = addtimer(CALLBACK(src, PROC_REF(drip)), water_frequency, TIMER_STOPPABLE | TIMER_LOOP)

/obj/effect/waterfall/Destroy()
	if(water_timer)
		deltimer(water_timer)
	water_timer = null
	return ..()

/obj/effect/waterfall/proc/drip()
	var/obj/effect/particle_effect/water/water = new(loc)
	water.dir = dir
	spawn(1)
		water.loc = get_step(water, dir)
