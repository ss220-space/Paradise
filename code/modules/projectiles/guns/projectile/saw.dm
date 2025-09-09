/obj/item/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	desc = "A heavily modified 5.56 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6closed100"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/a762x51
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshots/1mg2.ogg'
	magin_sound = 'sound/weapons/gun_interactions/lmg_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/lmg_magout.ogg'
	var/cover_open = 0
	fire_delay = 1
	burst_size = 3
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_HIGH
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 21, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 1, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -7)
	)
	fire_modes = GUN_MODE_SINGLE_BURST_AUTO
	autofire_delay = 0.2 SECONDS

/obj/item/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "крышка [cover_open ? "от" : "за"]крыта")
	playsound(src, cover_open ? 'sound/weapons/gun_interactions/sawopen.ogg' : 'sound/weapons/gun_interactions/sawclose.ogg', 50, TRUE)
	update_icon()


/obj/item/gun/projectile/automatic/l6_saw/update_icon_state()
	icon_state = "l6[cover_open ? "open" : "closed"][magazine ? CEILING(get_ammo(FALSE)/25, 1)*25 : "-empty"]"
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"


/obj/item/gun/projectile/automatic/l6_saw/can_shoot(mob/user)
	if(cover_open)
		balloon_alert(user, "крышка не закрыта!")
		return FALSE
	return ..()


/obj/item/gun/projectile/automatic/l6_saw/attack_hand(mob/user)
	if(loc != user)
		..()
		return	//let them pick it up
	if(!cover_open || (cover_open && !magazine))
		..()
	else if(cover_open && magazine)
		//drop the mag
		magazine.update_appearance(UPDATE_ICON | UPDATE_DESC)
		magazine.forceMove(drop_location())
		user.put_in_hands(magazine, silent = TRUE)
		magazine = null
		playsound(src, magout_sound, 50, TRUE)
		update_icon()
		balloon_alert(user, "магазин вынут")


/obj/item/gun/projectile/automatic/l6_saw/attackby(obj/item/I, mob/user, params)
	if(istype(I, mag_type) && !cover_open)
		balloon_alert(user, "крышка закрыта!")
		return ATTACK_CHAIN_PROCEED
	return ..()


//ammo//

/obj/projectile/bullet/saw
	damage = 45
	armour_penetration = 5

/obj/projectile/bullet/saw/weak
	damage = 30

/obj/projectile/bullet/saw/bleeding
	damage = 20
	armour_penetration = 0

/obj/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(35)

/obj/projectile/bullet/saw/hollow
	damage = 60
	armour_penetration = -10

/obj/projectile/bullet/saw/ap
	damage = 40
	armour_penetration = 75

/obj/projectile/bullet/saw/incen
	damage = 7
	armour_penetration = 0

/obj/projectile/bullet/saw/incen/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		new /obj/effect/hotspot(location)
		location.hotspot_expose(700, 50, 1)

/obj/projectile/bullet/saw/incen/on_hit(atom/target, blocked = 0)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.adjust_fire_stacks(3)
		M.IgniteMob()

//magazines//

/obj/item/ammo_box/magazine/a762x51
	name = "box magazine (7.62x51mm)"
	icon_state = "a762"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51/weak
	caliber = CALIBER_7_DOT_62X51MM
	max_ammo = 100

/obj/item/ammo_box/magazine/a762x51/bleeding
	name = "box magazine (Bleeding 7.62x51mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/magazine/a762x51/hollow
	name = "box magazine (Hollow-Point 7.62x51mm)"
	origin_tech = "combat=3"
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/magazine/a762x51/ap
	name = "box magazine (Armor Penetrating 7.62x51mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/magazine/a762x51/incen
	name = "box magazine (Incendiary 7.62x51mm)"
	origin_tech = "combat=4"
	ammo_type = /obj/item/ammo_casing/a762x51/incen

/obj/item/ammo_box/magazine/a762x51/update_icon_state()
	icon_state = "a762-[round(ammo_count(), 20)]"

//casings//

/obj/item/ammo_casing/a762x51
	desc = "A 7.62x51mm bullet casing."
	icon_state = "762-casing"
	caliber = CALIBER_7_DOT_62X51MM
	projectile_type = /obj/projectile/bullet/saw
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_STRONG
	muzzle_flash_range = MUZZLE_FLASH_RANGE_STRONG

/obj/item/ammo_casing/a762x51/weak
	projectile_type = /obj/projectile/bullet/saw/weak

/obj/item/ammo_casing/a762x51/bleeding
	desc = "A 7.62x51mm bullet casing with specialized inner-casing, that when it makes contact with a target, release tiny shrapnel to induce internal bleeding."
	icon_state = "762-casing"
	projectile_type = /obj/projectile/bullet/saw/bleeding

/obj/item/ammo_casing/a762x51/hollow
	desc = "A 7.62x51mm bullet casing designed to cause more damage to unarmored targets."
	projectile_type = /obj/projectile/bullet/saw/hollow

/obj/item/ammo_casing/a762x51/ap
	desc = "A 7.62x51mm bullet casing designed with a hardened-tipped core to help penetrate armored targets."
	projectile_type = /obj/projectile/bullet/saw/ap

/obj/item/ammo_casing/a762x51/incen
	desc = "A 7.62x51mm bullet casing designed with a chemical-filled capsule on the tip that when bursted, reacts with the atmosphere to produce a fireball, engulfing the target in flames. "
	projectile_type = /obj/projectile/bullet/saw/incen
	muzzle_flash_color = LIGHT_COLOR_FIRE

/obj/item/ammo_box/a762x51
	name = "ammo box (7.62x51mm)"
	desc = "Коробка, содержащая патроны калибра 7.62x51мм."
	icon_state = "ammobox_762x51"
	origin_tech = "combat=2"
	ammo_type = /obj/item/ammo_casing/a762x51
	max_ammo = 60

/obj/item/ammo_box/a762x51/get_ru_names()
	return list(
		NOMINATIVE = "коробка патронов (7.62x51мм)",
		GENITIVE = "коробки патронов (7.62x51мм)",
		DATIVE = "коробке патронов (7.62x51мм)",
		ACCUSATIVE = "коробку патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке патронов (7.62x51мм)"
	)

/obj/item/ammo_box/a762x51/weak
	name = "weak ammo box (7.62x51mm)"
	desc = "Коробка, содержащая ослабленные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/weak

/obj/item/ammo_box/a762x51/weak/get_ru_names()
	return list(
		NOMINATIVE = "коробка ослабленныx патронов (7.62x51мм)",
		GENITIVE = "коробки ослабленныx патронов (7.62x51мм)",
		DATIVE = "коробке ослабленныx патронов (7.62x51мм)",
		ACCUSATIVE = "коробку ослабленныx патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой ослабленныx патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке ослабленныx патронов (7.62x51мм)"
	)

/obj/item/ammo_box/a762x51/bleeding
	name = "bleeding ammo box (7.62x51mm)"
	desc = "Коробка, содержащая кровопускающие патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/bleeding

/obj/item/ammo_box/a762x51/bleeding/get_ru_names()
	return list(
		NOMINATIVE = "коробка кровопускающих патронов (7.62x51мм)",
		GENITIVE = "коробки кровопускающих патронов (7.62x51мм)",
		DATIVE = "коробке кровопускающих патронов (7.62x51мм)",
		ACCUSATIVE = "коробку кровопускающих патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой кровопускающих патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке кровопускающих патронов (7.62x51мм)"
	)

/obj/item/ammo_box/a762x51/hollow
	name = "hollow ammo box (7.62x51mm)"
	desc = "Коробка, содержащая экспансивные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/hollow

/obj/item/ammo_box/a762x51/hollow/get_ru_names()
	return list(
		NOMINATIVE = "коробка экспансивных патронов (7.62x51мм)",
		GENITIVE = "коробки экспансивных патронов (7.62x51мм)",
		DATIVE = "коробке экспансивных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку экспансивных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой экспансивных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке экспансивных патронов (7.62x51мм)"
	)

/obj/item/ammo_box/a762x51/ap
	name = "ap ammo box (7.62x51mm)"
	desc = "Коробка, содержащая бронебойные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/ap

/obj/item/ammo_box/a762x51/ap/get_ru_names()
	return list(
		NOMINATIVE = "коробка бронебойных патронов (7.62x51мм)",
		GENITIVE = "коробки бронебойных патронов (7.62x51мм)",
		DATIVE = "коробке бронебойных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку бронебойных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой бронебойных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке бронебойных патронов (7.62x51мм)"
	)

/obj/item/ammo_box/a762x51/incen
	name = "incendiary ammo box (7.62x51mm)"
	desc = "Коробка, содержащая зажигательные патроны калибра 7.62x51мм."
	ammo_type = /obj/item/ammo_casing/a762x51/incen

/obj/item/ammo_box/a762x51/incen/get_ru_names()
	return list(
		NOMINATIVE = "коробка зажигательных патронов (7.62x51мм)",
		GENITIVE = "коробки зажигательных патронов (7.62x51мм)",
		DATIVE = "коробке зажигательных патронов (7.62x51мм)",
		ACCUSATIVE = "коробку зажигательных патронов (7.62x51мм)",
		INSTRUMENTAL = "коробкой зажигательных патронов (7.62x51мм)",
		PREPOSITIONAL = "коробке зажигательных патронов (7.62x51мм)"
	)
