// Rusted Soviet special weapons

/obj/item/gun/projectile/automatic/aksu
	name = "AKSU assault rifle"
	desc = "An AK assault rifle favored by Soviet soldiers."
	icon_state = "aksu"
	item_state = "aksu"
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=4;materials=3"
	mag_type = /obj/item/ammo_box/magazine/aksu
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	slot_flags = ITEM_SLOT_BACK
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 19, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 6),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/aksu/rusted
	name = "Rusted AKSU assault rifle"
	desc = "An old AK assault rifle favored by Soviet soldiers."
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/aksu/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 25, destroy_max_chance = 5, malf_low_bound = 10, malf_high_bound = 30)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 10, misfire_high_bound = 30)


/obj/item/gun/projectile/automatic/ppsh
	name = "PPSh submachine gun"
	desc = "A submachine gun favored by Soviet soldiers."
	icon_state = "ppsh"
	item_state = "ppsh"
	mag_type = /obj/item/ammo_box/magazine/ppsh
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=4;materials=3"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 5
	fire_delay = 1.5
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 20, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 5, "y" = 5),
	)
	recoil = GUN_RECOIL_HIGH


/obj/item/gun/projectile/automatic/ppsh/rusted
	name = "Rusted PPSh submachine gun"
	desc = "An old submachine gun favored by Soviet soldiers."
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/ppsh/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 4, malf_low_bound = 15, malf_high_bound = 71)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 30, misfire_high_bound = 71)


//////////// Shotguns

/obj/item/gun/projectile/shotgun/lethal/rusted
	desc = "A traditional shotgun. It looks like it has been lying here for a very long time, rust is pouring."
	accuracy = GUN_ACCURACY_SHOTGUN

/obj/item/gun/projectile/shotgun/lethal/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 4)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)

//////////// Revolvers

/obj/item/gun/projectile/revolver/nagant/rusted
	desc = "An old model of revolver that originated in Russia. This one is a real relic, rust is pouring."

/obj/item/gun/projectile/revolver/nagant/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 3)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)
