/obj/projectile/colossus
	name = "смертоносный заряд"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 3.5

/obj/projectile/colossus/get_ru_names()
	return list(
		NOMINATIVE = "смертоносный заряд",
		GENITIVE = "смертоносного заряда",
		DATIVE = "смертоносному заряду",
		ACCUSATIVE = "смертоносный заряд",
		INSTRUMENTAL = "смертоносным зарядом",
		PREPOSITIONAL = "смертоносном заряде",
	)

/obj/projectile/colossus/on_hit(atom/target, blocked = 0)
	. = ..()
	if(isturf(target) || isobj(target))
		target.ex_act(EXPLODE_HEAVY)
