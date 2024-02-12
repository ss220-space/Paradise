//Stetchkin//
/obj/item/gun/projectile/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=3;materials=2;syndicate=3"
	can_holster = TRUE
	mag_type = /obj/item/ammo_box/magazine/m10mm
	fire_sound = 'sound/weapons/gunshots/1stechkin.ogg'
	magin_sound = 'sound/weapons/gun_interactions/pistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/pistol_magout.ogg'
	can_suppress = TRUE
	burst_size = 1
	fire_delay = 0
	actions_types = null


/obj/item/gun/projectile/automatic/pistol/update_icon_state()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"


//M1911//
/obj/item/gun/projectile/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m45
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	can_suppress = FALSE

//Enforcer//
/obj/item/gun/projectile/automatic/pistol/enforcer
	name = "Enforcer"
	desc = "A pistol of modern design."
	icon_state = "enforcer_grey"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/enforcer
	fire_sound = 'sound/weapons/gunshots/1colt.ogg'
	can_suppress = TRUE
	unique_reskin = TRUE
	can_flashlight = TRUE
	gun_light_overlay = "enforcer-light"


/obj/item/gun/projectile/automatic/pistol/enforcer/update_gun_skins()
	add_skin("Grey slide", "enforcer_grey")
	add_skin("Red slide", "enforcer_red")
	add_skin("Green slide", "enforcer_green")
	add_skin("Tan slide", "enforcer_tan")
	add_skin("Black slide", "enforcer_black")
	add_skin("Green Handle", "enforcer_greengrip")
	add_skin("Tan Handle", "enforcer_tangrip")
	add_skin("Red Handle", "enforcer_redgrip")


/obj/item/gun/projectile/automatic/pistol/enforcer/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"


/obj/item/gun/projectile/automatic/pistol/enforcer/update_overlays()
	. = ..()
	if(suppressed)
		. += image(icon = icon, icon_state = "enforcer_supp", pixel_x = 4)


/obj/item/gun/projectile/automatic/pistol/enforcer/ui_action_click()
	toggle_gunlight()

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal

/obj/item/gun/projectile/automatic/pistol/enforcer/lethal/Initialize(mapload)
	magazine = new/obj/item/ammo_box/magazine/enforcer/lethal
	. = ..()


//СБшный инфорсер//
/obj/item/gun/projectile/automatic/pistol/enforcer/security
	name = "Enforcer"
	desc = "Стандартный дешевый пистолет для сотрудников службы безопасности."
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=2"
	can_suppress = TRUE

//SP8 Pistol OBR and Warden//
/obj/item/gun/projectile/automatic/pistol/sp8
	name = "SP-8"
	desc = "Базовая версия новейшего пистолета сил защиты активов. Под патрон 40N&R."
	icon_state = "sp8_black"  // thanks split
	force = 10
	mag_type = /obj/item/ammo_box/magazine/sp8
	fire_sound = 'sound/weapons/gunshots/sp8.ogg'
	can_suppress = TRUE
	unique_reskin = TRUE
	can_flashlight = TRUE
	gun_light_overlay = "sp8-light"


/obj/item/gun/projectile/automatic/pistol/sp8/update_gun_skins()
	add_skin("Black", "sp8_black")
	add_skin("Red", "sp8_red")
	add_skin("Green", "sp8_green")
	add_skin("Olive", "sp8_olive")
	add_skin("Yellow", "sp8_yellow")
	add_skin("White", "sp8_white")


/obj/item/gun/projectile/automatic/pistol/sp8/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][chambered ? "" : "-e"]"
	else
		icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"


/obj/item/gun/projectile/automatic/pistol/sp8/update_overlays()
	. = ..()
	if(suppressed)
		. += image(icon = icon, icon_state = "sp8_supp")


/obj/item/gun/projectile/automatic/pistol/sp8/ui_action_click()
	toggle_gunlight()


/obj/item/gun/projectile/automatic/pistol/sp8/sp8t
	name = "SP-8-T"
	icon_state = "sp8t_dust"
	desc = "Новейшая разработка для сил защиты активов."
	fire_sound = 'sound/weapons/gunshots/sp8t.ogg'
	can_suppress = FALSE
	unique_reskin = TRUE
	can_flashlight = TRUE


/obj/item/gun/projectile/automatic/pistol/sp8/sp8t/update_gun_skins()
	add_skin("Dust", "sp8t_dust")
	add_skin("Sea", "sp8t_sea")


/obj/item/gun/projectile/automatic/pistol/sp8/sp8ar
	name = "SP-8-AR"
	desc = "Пистолет сил защиты активов оснащённый ДТК."
	icon_state = "sp8ar"
	fire_sound = 'sound/weapons/gunshots/sp8ar.ogg'
	can_suppress = FALSE
	unique_reskin = FALSE
	can_flashlight = TRUE


//Desert Eagle//
/obj/item/gun/projectile/automatic/pistol/deagle
	name = "desert eagle"
	desc = "A robust .50 AE handgun."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "deagle"
	force = 14.0
	mag_type = /obj/item/ammo_box/magazine/m50
	fire_sound = 'sound/weapons/gunshots/1deagle.ogg'
	magin_sound = 'sound/weapons/gun_interactions/hpistol_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/hpistol_magout.ogg'
	can_suppress = FALSE


/obj/item/gun/projectile/automatic/pistol/deagle/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"


/obj/item/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

//APS Pistol//
/obj/item/gun/projectile/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "The original russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=3;materials=2;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = TRUE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
