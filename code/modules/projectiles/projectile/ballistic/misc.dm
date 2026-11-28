// MARK: Magnetic spear
/obj/projectile/bullet/reusable/magspear
	name = "magnetic spear"
	desc = "БЕЛЫЙ КИТ, СВЯТОЙ ГРААЛЬ!"
	damage = 30 //takes 3 spears to kill a mega carp, one to kill a normal carp
	hitsound = 'sound/weapons/pierce.ogg'
	icon_state = "magspear"
	ammo_type = /obj/item/ammo_casing/caseless/magspear

/obj/projectile/bullet/reusable/magspear/get_ru_names()
	return alist(
		NOMINATIVE = "магнитное копье",
		GENITIVE = "магнитного копья",
		DATIVE = "магнитному копью",
		ACCUSATIVE = "магнитное копье",
		INSTRUMENTAL = "магнитным копьем",
		PREPOSITIONAL = "магнитном копье",
	)

/obj/projectile/kitty
	name = "kitty"
	icon = 'icons/mob/pets.dmi'
	icon_state = "kitten"
	damage = 2

/obj/projectile/bullet/weakbullet3/kitty
	name = "kitty"
	icon = 'icons/mob/pets.dmi'
	icon_state = "kitten"
