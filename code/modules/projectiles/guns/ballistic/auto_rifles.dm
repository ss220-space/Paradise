// MARK: M-90gl Carbine
/obj/item/gun/projectile/automatic/m90
	name = "M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon_state = "m90"
	item_state = "m90-4"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 1
	var/obj/item/gun/projectile/revolver/grenadelauncher/underbarrel
	accuracy = GUN_ACCURACY_RIFLE_UPLINK
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 18, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 12, ATTACHMENT_OFFSET_Y = 7),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/projectile/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/projectile/automatic/m90/Destroy()
	QDEL_NULL(underbarrel)
	return ..()

/obj/item/gun/projectile/automatic/m90/attackby(obj/item/I, mob/user, params)
	if(istype(I, underbarrel.magazine.ammo_type))
		add_fingerprint(user)
		var/reload = underbarrel.magazine.reload(I, user, replace_spent = TRUE)
		if(reload)
			underbarrel.chamber_round(FALSE)
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/automatic/m90/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"
	if(magazine)
		item_state = "m90-[ceil(get_ammo(FALSE)/7.5)]"
	else
		item_state = "m90-0"

/obj/item/gun/projectile/automatic/m90/update_overlays()
	. = ..()
	if(magazine)
		. += image(icon = icon, icon_state = "m90-[ceil(get_ammo(FALSE)/6)*6]")
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			. += "[initial(icon_state)]gren"
		if(GUN_FIREMODE_BURSTFIRE)
			.  += "[initial(icon_state)]burst"

/obj/item/gun/projectile/automatic/m90/rusted
	name = "M-90gl Carbine (Rusted)"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher which can be toggled on and off. Looks rusty."
	damage_mod = 0.85

/obj/item/gun/projectile/automatic/m90/rusted/Initialize(mapload)
	. = ..()
	QDEL_NULL(underbarrel.chambered)

/obj/item/gun/projectile/automatic/m90/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 10, destroy_max_chance = 3, malf_low_bound = 50, malf_high_bound = 100)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 50, misfire_high_bound = 100)

// MARK: ARG
/obj/item/gun/projectile/automatic/arg
	name = "ARG"
	desc = "A robust assault rile used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	origin_tech = "combat=6;engineering=4"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 1
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 8, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

// MARK: AK-814
/obj/item/gun/projectile/automatic/ak814
	name = "AK-814 assault rifle"
	desc = "A modern AK assault rifle favored by elite Soviet soldiers."
	icon_state = "ak814"
	item_state = "ak814"
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/ak814
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 2
	fire_delay = 1
	accuracy = GUN_ACCURACY_RIFLE
	weapon_weight = WEAPON_HEAVY
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = 1),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 5, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -5),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/ak814/weakened
	desc = "Импортная версия классической штурмовой винтовки AK-814 с уменьшенным магазином и планками для установки оружейных модулей."
	mag_type = /obj/item/ammo_box/magazine/ak814/fusty

// MARK: AKS74-U
/obj/item/gun/projectile/automatic/aks74u
	name = "AKSU assault rifle"
	desc = "An AK assault rifle favored by Soviet soldiers."
	icon_state = "aksu"
	item_state = "aksu"
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=4;materials=3"
	mag_type = /obj/item/ammo_box/magazine/aks74u
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	slot_flags = ITEM_SLOT_BACK
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 19, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 6),
	)
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/automatic/aks74u/rusted
	name = "Rusted AKSU assault rifle"
	desc = "An old AK assault rifle favored by Soviet soldiers."
	damage_mod = 0.75

/obj/item/gun/projectile/automatic/aks74u/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 25, destroy_max_chance = 5, malf_low_bound = 10, malf_high_bound = 30)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 15, misfire_low_bound = 10, misfire_high_bound = 30)

// MARK: IK-60
/obj/item/gun/projectile/automatic/ik60
	name = "IK-60 Laser Carbine"
	desc = "A short, compact carbine like rifle, relying more on battery cartridges rather than a built in power cell. Utilized by the Nanotrasen Navy for combat operations."
	icon_state = "lasercarbine"
	item_state = "laser"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/ik60mag
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 2
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 6),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -4),
	)
	recoil = GUN_RECOIL_MIN

/obj/item/gun/projectile/automatic/ik60/update_icon_state()
	icon_state = "lasercarbine[magazine ? "-[ceil(get_ammo(FALSE)/5)*5]" : ""]"

// MARK: LR-30
/obj/item/gun/projectile/automatic/lr30
	name = "LR-30 Laser Rifle"
	desc = "A compact rifle, relying more on battery cartridges rather than a built in power cell. Utilized by the Nanotrasen Navy for combat operations."
	icon_state = "lr30"
	item_state = "lr30"
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/lr30mag
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_amount = 1
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 3, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 10, ATTACHMENT_OFFSET_Y = -2),
	)
	recoil = GUN_RECOIL_MIN
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

/obj/item/gun/projectile/automatic/lr30/update_icon_state()
	icon_state = "lr30[magazine ? "-[ceil(get_ammo(FALSE)/3)*3]" : ""]"

// MARK: M-52
/obj/item/gun/projectile/automatic/m52
	name = "aussec armory M-52"
	desc = "One of the least popular examples of heavy assault rifles. It has impressive firepower."
	icon_state = "M52"
	item_state = "arg"
	fire_sound = 'sound/weapons/gunshots/aussec.ogg'
	mag_type = /obj/item/ammo_box/magazine/m52mag
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 20, ATTACHMENT_OFFSET_Y = 2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 2, ATTACHMENT_OFFSET_Y = 9),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 9, ATTACHMENT_OFFSET_Y = -7),
	)
	recoil = GUN_RECOIL_MEDIUM
