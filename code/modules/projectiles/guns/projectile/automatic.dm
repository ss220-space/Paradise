/obj/item/gun/projectile/automatic
	w_class = WEIGHT_CLASS_NORMAL
	var/alarmed = FALSE
	var/select = 1
	can_tactical = TRUE
	can_suppress = 1
	can_holster = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)


/obj/item/gun/projectile/automatic/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"


/obj/item/gun/projectile/automatic/update_overlays()
	. = ..()
	if(!select)
		. += "[initial(icon_state)]semi"
	if(select == 1)
		. += "[initial(icon_state)]burst"

	if(gun_light && gun_light_overlay)
		var/iconF = gun_light_overlay
		if(gun_light.on)
			iconF = "[gun_light_overlay]_on"
		. += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)


/obj/item/gun/projectile/automatic/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine))
		add_fingerprint(user)
		var/obj/item/ammo_box/magazine/new_magazine = I
		if(!istype(new_magazine, mag_type))
			balloon_alert(user, "не совместимо!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_magazine, src))
			return ..()
		if(magazine)
			magazine.forceMove(drop_location())
			magazine.update_appearance()
		balloon_alert(user, "заряжено")
		alarmed = FALSE	// Reset the alarm once a magazine is loaded
		magazine = new_magazine
		chamber_round()
		magazine.update_appearance()
		update_appearance()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/gun/projectile/automatic/ui_action_click(mob/user, datum/action/action, leftclick)
    if(istype(action, /datum/action/item_action/toggle_firemode))
        burst_select()
        return TRUE

/obj/item/gun/projectile/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		balloon_alert(user, "полуавтомат")
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		balloon_alert(user, "отсечка по [burst_size] [declension_ru(burst_size, "патрону",  "патрона",  "патронов")]")

	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/projectile/automatic/can_shoot(mob/user)
	return get_ammo()

/obj/item/gun/projectile/automatic/proc/empty_alarm()
	if(!chambered && !get_ammo() && !alarmed)
		playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 40, TRUE)
		update_icon()
		alarmed = TRUE

//Saber SMG//
/obj/item/gun/projectile/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	origin_tech = "combat=4;materials=2"
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'

//C-20r SMG//
/obj/item/gun/projectile/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	origin_tech = "combat=5;materials=2;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_sound = 'sound/weapons/gunshots/1c20.ogg'
	fire_delay = 2
	burst_size = 2
	can_bayonet = TRUE
	bayonet_x_offset = 26
	bayonet_y_offset = 12


/obj/item/gun/projectile/automatic/c20r/Initialize()
	. = ..()
	update_icon()


/obj/item/gun/projectile/automatic/c20r/afterattack(atom/target, mob/living/user, flag, params)
	..()
	empty_alarm()


/obj/item/gun/projectile/automatic/c20r/update_icon_state()
	icon_state = "c20r[magazine ? "-[CEILING(get_ammo(FALSE)/4, 1)*4]" : ""][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"



//WT550//
/obj/item/gun/projectile/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defense weapon utilized by law enforcement. The WT-550 Automatic Rifle fires 4.6x30mm rounds."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	fire_sound = 'sound/weapons/gunshots/1wt.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 2
	can_suppress = FALSE
	can_flashlight = TRUE
	burst_size = 2
	can_bayonet = TRUE
	bayonet_x_offset = 25
	bayonet_y_offset = 12
	gun_light_overlay = "wt-light"


/obj/item/gun/projectile/automatic/wt550/update_icon_state()
	icon_state = "wt550[magazine ? "-[CEILING(get_ammo(FALSE)/4, 1)*4]" : ""]"


/obj/item/gun/projectile/automatic/wt550/ui_action_click(mob/user, datum/action/action, leftclick)
	if(..())
		return TRUE
	if(istype(action, /datum/action/item_action/toggle_gunlight))
		toggle_gunlight()
		return TRUE

//"SP-91-RC//
/obj/item/gun/projectile/automatic/sp91rc
	name = "SP-91-RC"
	desc = "Compact submachine gun designed for riot control."
	icon_state = "SP-91-RC"
	item_state = "SP-91-RC"
	mag_type = /obj/item/ammo_box/magazine/sp91rc
	fire_sound = 'sound/weapons/gunshots/1sp_91.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	fire_delay = 2
	can_suppress = FALSE
	can_flashlight = TRUE
	burst_size = 3
	can_bayonet = FALSE
	gun_light_overlay = "SP-91-RC-light"


/obj/item/gun/projectile/automatic/sp91rc/update_icon_state()
	icon_state = "SP-91-RC[magazine ? "-[CEILING(get_ammo(FALSE)/5, 1)*5]" : ""]"
	item_state = "SP-91-RC[magazine ? "-[get_ammo(FALSE) ? "20" : "0"]" : ""]"


/obj/item/gun/projectile/automatic/sp91rc/ui_action_click(mob/user, datum/action/action, leftclick)
	if(..())
		return TRUE
	if(istype(action, /datum/action/item_action/toggle_gunlight))
		toggle_gunlight()
		return TRUE


//Type-U3 Uzi//
/obj/item/gun/projectile/automatic/mini_uzi
	name = "\improper ''Type U3 Uzi"
	desc = "A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "mini-uzi"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	fire_sound = 'sound/weapons/gunshots/1uzi.ogg'
	burst_size = 4

//M-90gl Carbine//
/obj/item/gun/projectile/automatic/m90
	name = "\improper M-90gl Carbine"
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
	burst_size = 3
	fire_delay = 2


/obj/item/gun/projectile/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/projectile/revolver/grenadelauncher(src)
	update_icon()


/obj/item/gun/projectile/automatic/m90/afterattack(atom/target, mob/living/user, flag, params)
	if(select == 0)
		underbarrel.afterattack(target, user, flag, params)
	else
		..()


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
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	if(magazine)
		item_state = "m90-[CEILING(get_ammo(FALSE)/7.5, 1)]"
	else
		item_state = "m90-0"


/obj/item/gun/projectile/automatic/m90/update_overlays()
	. = ..()
	if(magazine)
		. += image(icon = icon, icon_state = "m90-[CEILING(get_ammo(FALSE)/6, 1)*6]")
	switch(select)
		if(0)
			. += "[initial(icon_state)]gren"
		if(1)
			.  += "[initial(icon_state)]burst"


/obj/item/gun/projectile/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			balloon_alert(user, "отсечка по [burst_size] [declension_ru(burst_size, "патрону",  "патрона",  "патронов")]")
		if(1)
			select = 0
			balloon_alert(user, "подствольный гранатомёт")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)
	update_icon()

//Tommy Gun//
/obj/item/gun/projectile/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "A genuine 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=5;materials=1;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshots/1saber.ogg'
	can_suppress = 0
	burst_size = 4
	fire_delay = 1

//ARG Assault Rifle//
/obj/item/gun/projectile/automatic/ar
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
	can_suppress = 0
	burst_size = 3
	fire_delay = 1

//AK-814 Soviet Assault Rifle
/obj/item/gun/projectile/automatic/ak814
	name = "\improper AK-814 assault rifle"
	desc = "A modern AK assault rifle favored by elite Soviet soldiers."
	icon_state = "ak814"
	item_state = "ak814"
	origin_tech = "combat=5;materials=3"
	mag_type = /obj/item/ammo_box/magazine/ak814
	fire_sound = 'sound/weapons/gunshots/1m90.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = FALSE
	can_bayonet = TRUE
	bayonet_x_offset = 26
	bayonet_y_offset = 10
	burst_size = 2
	fire_delay = 1

// Bulldog shotgun //
/obj/item/gun/projectile/automatic/shotgun/bulldog
	name = "\improper 'Bulldog' Shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 12/24-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/bulldog.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	actions_types = null


/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff
	name = "\improper 'Mastiff' Shotgun"
	desc = "A cheap copy of famous mag-fed semi-automatic 'Bulldog' shotgun used by multiple pirate groups. A critical duplication failure has made it impossible to use the original drum magazines, so do not lose them."
	mag_type = /obj/item/ammo_box/magazine/cheap_m12g
	color = COLOR_ASSEMBLY_BROWN


/obj/item/gun/projectile/automatic/shotgun/bulldog/update_icon_state()
	icon_state = "bulldog[chambered ? "" : "-e"]"


/obj/item/gun/projectile/automatic/shotgun/bulldog/update_overlays()
	. = ..()
	if(magazine)
		. += "[magazine.icon_state]"


/obj/item/gun/projectile/automatic/shotgun/bulldog/update_weight()
	if(magazine)
		if(istype(magazine, /obj/item/ammo_box/magazine/m12g/XtrLrg))
			w_class = WEIGHT_CLASS_BULKY
		else
			w_class = WEIGHT_CLASS_NORMAL
	else
		w_class = WEIGHT_CLASS_NORMAL


/obj/item/gun/projectile/automatic/shotgun/bulldog/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine/m12g/XtrLrg) && isstorage(loc))	// To prevent inventory exploits
		var/obj/item/storage/storage = loc
		if(storage.max_w_class < WEIGHT_CLASS_BULKY)
			to_chat(user, span_warning("You cannot reload [src] with a XL mag, while it's in a normal bag."))
			return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/automatic/shotgun/bulldog/afterattack(atom/target, mob/living/user, flag, params)
	..()
	empty_alarm()

//AS-12 Minotaur//
/obj/item/gun/projectile/automatic/shotgun/minotaur
	name = "\improper AS-12 'Minotaur' Shotgun"
	desc = "Smooth, powerful, highly illegal. The newest full auto shotgun available at the market, utilizes standard 12g drum mags. Property of Gorlex Marauders."
	icon_state = "minotaur"
	item_state = "minotaur"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/minotaur.ogg'
	magin_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_in.ogg'
	magout_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_out.ogg'
	can_suppress = 0
	burst_size = 3
	fire_delay = 1.5

/obj/item/gun/projectile/automatic/shotgun/minotaur/New()
	magazine = new/obj/item/ammo_box/magazine/m12g/XtrLrg
	..()

/obj/item/gun/projectile/automatic/shotgun/minotaur/afterattack(atom/target, mob/living/user, flag, params)
	..()
	empty_alarm()

//Combat Automatic Tactical Shotgun//

/obj/item/gun/projectile/automatic/cats
	name = "\improper C.A.T. Shotgun"
	desc = "Terra Light Armories - Combat Automatic Tactical Shotgun - мощный автоматический дробовик, в основном используемый силами Транс-Солнечной Федерации. Производится корпорацией Terra Industries."
	icon_state = "tla_cats"
	item_state = "arg"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/cats12g
	fire_delay = 0
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	burst_size = 2
	can_suppress = 0


/obj/item/gun/projectile/automatic/cats/update_icon_state()
	icon_state = "tla_cats[magazine ? "" : "-e"]"


/obj/item/gun/projectile/automatic/cats/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		if(user.say_understands(null, GLOB.all_languages[LANGUAGE_SOL_COMMON]))
			. += "Вы видите гравировку на прикладе, написанную на Общесолнечном: 'Свобода через тотальное превосходство'"
		else
			. += "Вы видите символы на прикладе, но не понимаете что они значат."

//Laser carbine//
/obj/item/gun/projectile/automatic/lasercarbine
	name = "\improper IK-60 Laser Carbine"
	desc = "A short, compact carbine like rifle, relying more on battery cartridges rather than a built in power cell. Utilized by the Nanotrasen Navy for combat operations."
	icon_state = "lasercarbine"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/laser
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 2

/obj/item/gun/projectile/automatic/lasercarbine/update_icon_state()
	icon_state = "lasercarbine[magazine ? "-[CEILING(get_ammo(FALSE)/5, 1)*5]" : ""]"

/obj/item/gun/projectile/automatic/lr30
	name = "\improper LR-30 Laser Rifle"
	desc = "A compact rifle, relying more on battery cartridges rather than a built in power cell. Utilized by the Nanotrasen Navy for combat operations."
	icon_state = "lr30"
	item_state = "lr30"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "combat=3;materials=2"
	mag_type = /obj/item/ammo_box/magazine/lr30mag
	fire_sound = 'sound/weapons/gunshots/gunshot_lascarbine.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	can_suppress = 0
	burst_size = 1
	actions_types = null

/obj/item/gun/projectile/automatic/lr30/update_icon_state()
	icon_state = "lr30[magazine ? "-[CEILING(get_ammo(FALSE)/4, 1)*4]" : ""]"

//Semi-Machine Gun SFG

/obj/item/gun/projectile/automatic/sfg
	name = "SFG-5 SMG"
	desc = "Данное оружие, созданное для различных спецслужб по всей галактике одной компанией, имеет в качестве калибра 9мм, возможность стрельбы очередями отсечкой по 3 патрона и имеет место для фонарика и глушителя."
	icon_state = "sfg-5"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/sfg9mm
	burst_size = 3
	can_flashlight = TRUE
	gun_light_overlay = "sfg-light"


/obj/item/gun/projectile/automatic/sfg/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"][suppressed ? "-suppressed" : ""]"


/obj/item/gun/projectile/automatic/sfg/ui_action_click(mob/user, datum/action/action, leftclick)
	if(..())
		return TRUE
	if(istype(action, /datum/action/item_action/toggle_gunlight))
		toggle_gunlight()
		return TRUE

//Aussec Armory M-52

/obj/item/gun/projectile/automatic/m52
	name = "aussec armory M-52"
	desc = "One of the least popular examples of heavy assault rifles. It has impressive firepower."
	icon_state = "M52"
	item_state = "arg"
	fire_sound = 'sound/weapons/gunshots/aussec.ogg'
	mag_type = /obj/item/ammo_box/magazine/m52mag
	can_suppress = 0

