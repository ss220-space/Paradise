/obj/effect/decal/cleanable/blood/gibs/robot
	name = "robot debris"
	desc = "It's a useless heap of junk... <i>or is it?</i>"
	icon = 'icons/effects/robot.dmi'
	icon_state = "gib1"
	basecolor = "#030303"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	squishy = FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/update_icon(updates = ALL)
	color = "#FFFFFF"
	. = ..(NONE)

/obj/effect/decal/cleanable/blood/gibs/robot/dry()	//pieces of robots do not dry up like
	return

/obj/effect/decal/cleanable/blood/gibs/robot/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/robot/streak(list/directions)
	oil_streak(get_turf(src), directions, /obj/effect/decal/cleanable/blood/oil)

/proc/oil_streak(turf/location, list/directions, streaktype)
	set waitfor = FALSE

	var/direction = pick(directions)
	for(var/i in 0 to pick(1, 200; 2, 150; 3, 50; 4))
		sleep(0.3 SECONDS)
		if(i > 0)
			if(prob(40))
				var/obj/effect/decal/streak = new streaktype(location)
				streak.update_icon()
			else if(prob(10))
				do_sparks(3, TRUE, location)
		if(step_to(location, get_step(location, direction), 0))
			break

/obj/effect/decal/cleanable/blood/gibs/robot/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/effect/decal/cleanable/blood/gibs/robot/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7", "gibup1", "gibup1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/gibs/robot/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7", "gibdown1", "gibdown1") //2:7 is close enough to 1:4

/obj/effect/decal/cleanable/blood/oil
	name = "motor oil"
	desc = "It's black and greasy. Looks like Beepsky made another mess."
	basecolor = "#030303"
	bloodiness = MAX_SHOE_BLOODINESS

/obj/effect/decal/cleanable/blood/oil/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/oil/dry()
	return

/obj/effect/decal/cleanable/blood/oil/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2
