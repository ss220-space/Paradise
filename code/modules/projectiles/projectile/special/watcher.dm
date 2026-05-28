/obj/projectile/watcher
	name = "stunning blast"
	icon_state = "temp_0"
	damage_type = BURN
	speed = 0.8

/obj/projectile/watcher/get_ru_names()
	return list(
		NOMINATIVE = "оглушающий выброс",
		GENITIVE = "оглушающего выброса",
		DATIVE = "оглушающему выбросу",
		ACCUSATIVE = "оглушающий выброс",
		INSTRUMENTAL = "оглушающим выбросом",
		PREPOSITIONAL = "оглушающем выбросе",
	)

/obj/projectile/watcher/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L) && !isrobot(L))
			L.AdjustWeakened(1 SECONDS)
			L.Slowed(3 SECONDS)
			L.Confused(3 SECONDS)
