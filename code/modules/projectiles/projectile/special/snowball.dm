/obj/projectile/snowball
	name = "snowball"
	icon_state = "snowball"
	hitsound = 'sound/items/dodgeball.ogg'
	damage = 4
	damage_type = BURN

/obj/projectile/snowball/get_ru_names()
	return list(
		NOMINATIVE = "снежок",
		GENITIVE = "снежка",
		DATIVE = "снежку",
		ACCUSATIVE = "снежок",
		INSTRUMENTAL = "снежком",
		PREPOSITIONAL = "снежке",
	)

/obj/projectile/snowball/on_hit(atom/target)	//chilling
	. = ..()
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_bodytemperature(-50)	//each hit will drop your body temp, so don't get surrounded!
		M.ExtinguishMob()	//bright side, they counter being on fire!
