/obj/item/potato_mine
	name = "pack of potato mine seeds"
	desc = "Семяна картофельной мины. Нужно сажать на плющ."
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-potato"

/obj/item/potato_mine/proc/try_plant(mob/living/user, turf/T)
	if (!istype(T, /turf/simulated/floor/ivy))
		user.balloon_alert(user, "неподходящая поверхность")
		return

	var/turf/simulated/floor/ivy/ivy_turf = T
	if (ivy_turf.mine_mob || ivy_turf.has_ready_mine)
		user.balloon_alert(user, "занято")
		return

	qdel(src)
	ivy_turf.mine_mob = new /mob/living/simple_animal/hostile/plant/potato_mine(T)

/obj/item/potato_mine/attack_self(mob/user)
	try_plant(user, get_turf(user))
