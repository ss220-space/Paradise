/obj/projectile/bullet/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 33
	damage_type = TOX
	weaken = 1 SECONDS

/obj/projectile/bullet/neurotoxin/get_ru_names()
	return list(
		NOMINATIVE = "слюна с нейротоксином",
		GENITIVE = "слюны с нейротоксином",
		DATIVE = "слюне с нейротоксином",
		ACCUSATIVE = "слюну с нейротоксином",
		INSTRUMENTAL = "слюной с нейротоксином",
		PREPOSITIONAL = "слюне с нейротоксином",
	)

/obj/projectile/bullet/neurotoxin/prehit(atom/target)
	if(isalien(target))
		weaken = 0
		nodamage = TRUE
	if(isobj(target) || issilicon(target) || ismachineperson(target))
		damage_type = BURN
	. = ..()
