// Rusted Soviet special weapons

/obj/item/gun/projectile/automatic/rusted
	name = "Rusted gun"
	desc = "An old gun, be careful using it."
	icon_state = "aksu"
	item_state = "aksu"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/aksu
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_bayonet = FALSE
	slot_flags = ITEM_SLOT_BACK
	burst_size = 3
	fire_delay = 1
	rusted_weapon = TRUE
	self_shot_divisor = 3
	malf_low_bound = 60
	malf_high_bound = 90
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_HIGH


/obj/item/gun/projectile/automatic/rusted/aksu
	name = "Rusted AKSU assault rifle"
	desc = "An old AK assault rifle favored by Soviet soldiers."
	icon_state = "aksu"
	item_state = "aksu"
	mag_type = /obj/item/ammo_box/magazine/aksu
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=3"
	burst_size = 3
	fire_delay = 2
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 19, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6)
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/rusted/ppsh
	name = "Rusted PPSh submachine gun"
	desc = "An old submachine gun favored by Soviet soldiers."
	icon_state = "ppsh"
	item_state = "ppsh"
	mag_type = /obj/item/ammo_box/magazine/ppsh
	w_class = WEIGHT_CLASS_HUGE
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	self_shot_divisor = 5
	malf_high_bound = 100
	burst_size = 5
	fire_delay = 1.5
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 20, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 5, "y" = 5)
	)
	recoil = GUN_RECOIL_HIGH


//////////// Shotguns

/obj/item/gun/projectile/shotgun/lethal/rusted
	desc = "A traditional shotgun. It looks like it has been lying here for a very long time, rust is pouring."
	rusted_weapon = TRUE
	self_shot_divisor = 3
	malf_low_bound = 12
	malf_high_bound = 24
	accuracy = GUN_ACCURACY_SHOTGUN

//////////// Revolvers

/obj/item/gun/projectile/revolver/nagant/rusted
	desc = "An old model of revolver that originated in Russia. This one is a real relic, rust is pouring."
	rusted_weapon = TRUE
	self_shot_divisor = 2
	malf_low_bound = 7
	malf_high_bound = 21
