/obj/projectile/bullet/reusable
	name = "reusable bullet"
	desc = "Как вообще можно повторно использовать пулю?"
	ru_names = list(
		NOMINATIVE = "многоразовая пуля",
		GENITIVE = "многоразовой пули",
		DATIVE = "многоразовой пуле",
		ACCUSATIVE = "многоразовую пулю",
		INSTRUMENTAL = "многоразовой пулей",
		PREPOSITIONAL = "многоразовой пуле"
	)
	var/ammo_type = /obj/item/ammo_casing/caseless/
	var/dropped = 0
	impact_effect_type = null

/obj/projectile/bullet/reusable/on_hit(atom/target, blocked = 0)
	. = ..()
	handle_drop()

/obj/projectile/bullet/reusable/on_range()
	handle_drop()
	..()

/obj/projectile/bullet/reusable/proc/handle_drop()
	if(!dropped)
		new ammo_type(loc)
		dropped = 1

/obj/projectile/bullet/reusable/magspear
	name = "magnetic spear"
	desc = "БЕЛЫЙ КИТ, СВЯТОЙ ГРААЛЬ!"
	ru_names = list(
		NOMINATIVE = "магнитное копье",
		GENITIVE = "магнитного копья",
		DATIVE = "магнитному копью",
		ACCUSATIVE = "магнитное копье",
		INSTRUMENTAL = "магнитным копьем",
		PREPOSITIONAL = "магнитном копье"
	)
	damage = 30 //takes 3 spears to kill a mega carp, one to kill a normal carp
	hitsound = 'sound/weapons/pierce.ogg'
	icon_state = "magspear"
	ammo_type = /obj/item/ammo_casing/caseless/magspear

/obj/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "Надеюсь, ты в защитных очках."
	ru_names = list(
		NOMINATIVE = "пенный дротик",
		GENITIVE = "пенного дротика",
		DATIVE = "пенному дротику",
		ACCUSATIVE = "пенный дротик",
		INSTRUMENTAL = "пенным дротиком",
		PREPOSITIONAL = "пенном дротике"
	)
	damage = 0 // It's a damn toy.
	hitsound = 'sound/weapons/tap.ogg'
	hitsound_wall = 'sound/weapons/tap.ogg'
	damage_type = OXY
	nodamage = TRUE
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foamdart"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/obj/item/pen/pen = null
	log_override = TRUE//it won't log even when there's a pen inside, but since the damage will be so low, I don't think there's any point in making it any more complex

/obj/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newdart = new ammo_type(get_turf(src))
	var/obj/item/ammo_casing/caseless/foam_dart/old_dart = ammo_casing
	newdart.modified = old_dart.modified
	if(pen)
		var/obj/projectile/bullet/reusable/foam_dart/newdart_FD = newdart.BB
		newdart_FD.pen = pen
		pen.loc = newdart_FD
		pen = null
	newdart.BB.damage = damage
	newdart.BB.nodamage = nodamage
	newdart.BB.damage_type = damage_type
	newdart.update_icon()

/obj/projectile/bullet/reusable/foam_dart/Destroy()
	QDEL_NULL(pen)
	return ..()

/obj/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	ru_names = list(
		NOMINATIVE = "усиленный пенный дротик",
		GENITIVE = "усиленного пенного дротика",
		DATIVE = "усиленному пенному дротику",
		ACCUSATIVE = "усиленный пенный дротик",
		INSTRUMENTAL = "усиленным пенным дротиком",
		PREPOSITIONAL = "усиленном пенном дротике"
	)
	icon_state = "foamdart_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25
	log_override = FALSE

/obj/projectile/bullet/reusable/foam_dart/sniper
	name = "foam sniper dart"
	ru_names = list(
		NOMINATIVE = "пенный снайперский дротик",
		GENITIVE = "пенного снайперского дротика",
		DATIVE = "пенному снайперскому дротику",
		ACCUSATIVE = "пенный снайперский дротик",
		INSTRUMENTAL = "пенным снайперским дротиком",
		PREPOSITIONAL = "пенном снайперском дротике"
	)
	icon_state = "foamdartsniper"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper
	range = 30

/obj/projectile/bullet/reusable/foam_dart/sniper/riot
	name = "riot sniper foam dart"
	ru_names = list(
		NOMINATIVE = "усиленный пенный снайперский дротик",
		GENITIVE = "усиленного пенного снайперского дротика",
		DATIVE = "усиленному пенному снайперскому дротику",
		ACCUSATIVE = "усиленный пенный снайперский дротик",
		INSTRUMENTAL = "усиленным пенным снайперским дротиком",
		PREPOSITIONAL = "усиленном пенном снайперском дротике"
	)
	icon_state = "foamdartsniper_riot"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	stamina = 100
	log_override = FALSE
