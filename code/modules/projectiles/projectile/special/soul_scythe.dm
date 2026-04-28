/obj/projectile/soulscythe
	name = "soulslash"
	icon_state = "soulslash"
	flag = MELEE //jokair
	damage = 15
	light_range = 1
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/projectile/soulscythe/get_ru_names()
	return list(
		NOMINATIVE = "рассечение души",
		GENITIVE = "рассечения души",
		DATIVE = "рассечению души",
		ACCUSATIVE = "рассечение души",
		INSTRUMENTAL = "рассечением души",
		PREPOSITIONAL = "рассечении души",
	)

/obj/projectile/soulscythe/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isliving(target))
		var/mob/living/as_living = target
		if(firer.faction_check_mob(as_living))
			damage *= 0
		if(faction_check(as_living.faction, MINING_FACTIONS))
			damage *= 2
	return ..()
