/obj/projectile/blastwave
	name = "blast wave"
	icon_state = "blastwave"
	damage = 0
	forcedodge = -1
	range = 150
	var/heavyr = 0
	var/mediumr = 0
	var/lightr = 0

/obj/projectile/blastwave/New(loc, _h, _m, _l)
	..()
	heavyr = _h
	mediumr = _m
	lightr = _l

/obj/projectile/blastwave/Range()
	..()
	var/amount_destruction = 0
	if(heavyr)
		amount_destruction = EXPLODE_DEVASTATE
	else if(mediumr)
		amount_destruction = EXPLODE_HEAVY
	else if(lightr)
		amount_destruction = EXPLODE_LIGHT
	if(amount_destruction && isturf(loc))
		var/turf/T = loc
		for(var/thing in T.contents)
			var/atom/AM = thing
			if(AM?.simulated)
				AM.ex_act(amount_destruction)
				CHECK_TICK
		T.ex_act(amount_destruction)
	else
		qdel(src)
	heavyr = max(heavyr - 1, 0)
	mediumr = max(mediumr - 1, 0)
	lightr = max(lightr - 1, 0)

/obj/projectile/blastwave/ex_act()
	return
