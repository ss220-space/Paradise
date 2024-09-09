/obj/item/potato_mine
	name = "pack of potato mine seeds"
	desc = "Семяна картофельной мины. Нужно сажать на плющ.
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed-potato"
	species = "potato"

/obj/item/potato_mine/try_plant(mob/living/user, turf/simulated/floor/ivy/T)
	if (!istype(T, /turf/simulated/floor/ivy))
		user.balloon_alert(user, "неподходящая поверхность")
		return

	new
	qdel(src)

/obj/item/potato_mine/attack_self(mob/user)
	try_plant(user, get_turf(user))

/obj/item/potato_mine/attack(turf/target, mob/living/user)
	try_plant(user, target)
