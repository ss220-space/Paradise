//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/projectile/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun-sawn"
	item_state = "gun"
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/weapons/gunshots/1grenlauncher.ogg'
	w_class = WEIGHT_CLASS_NORMAL


/obj/item/gun/projectile/revolver/grenadelauncher/multi
	desc = "A revolving 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon_state = "bulldog"
	item_state = "bulldog"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/grenadelauncher/multi

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg
	desc = "A 6-shot grenade launcher."
	icon = 'icons/obj/mecha/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"

/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg/attack_self()
	return

/obj/item/gun/projectile/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/effects/explosion1.ogg'
	origin_tech = "combat=5"
	mag_type = /obj/item/ammo_box/magazine/m75
	can_holster = TRUE // Override default automatic setting since it is a handgun sized gun
	burst_size = 1
	fire_delay = 0
	actions_types = null


/obj/item/gun/projectile/automatic/gyropistol/process_chamber(eject_casing = 0, empty_chamber = 1)
	..()


/obj/item/gun/projectile/automatic/gyropistol/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "loaded" : ""]"


/obj/item/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=4;engineering=4"
	force = 10
	can_suppress = FALSE
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/genhit.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = null


/obj/item/gun/projectile/automatic/speargun/update_icon_state()
	return


/obj/item/gun/projectile/automatic/speargun/attack_self()
	return


/obj/item/gun/projectile/automatic/speargun/can_shoot(mob/user)
	if(chambered)
		return TRUE
	return FALSE


/obj/item/gun/projectile/automatic/speargun/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()


/obj/item/gun/projectile/automatic/speargun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
		add_fingerprint(user)
		var/num_loaded = magazine.reload(I, user, silent = TRUE, count_chambered = TRUE)
		if(num_loaded)
			balloon_alert(user, "копьё заряжено")
			chamber_round()
			update_icon()
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/revolver/rocketlauncher //nice revolver you got here
	name = "\improper PML-9"
	desc = "A reusable rocket propelled grenade launcher. The words \"NT this way\" and an arrow have been written near the barrel."
	icon_state = "rocketlauncher"
	item_state = "rocketlauncher"
	mag_type = /obj/item/ammo_box/magazine/internal/rocketlauncher
	fire_sound = 'sound/weapons/gunshots/1launcher.ogg'
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	can_holster = FALSE
	flags = CONDUCT
	show_live_rounds = FALSE


/obj/item/gun/projectile/revolver/rocketlauncher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
		add_fingerprint(user)
		var/num_loaded = magazine.reload(I, user, silent = TRUE, count_chambered = TRUE)
		if(num_loaded)
			balloon_alert(user, "ракета заряжена")
			chamber_round()
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/revolver/rocketlauncher/can_shoot(mob/user)
	if(chambered)
		return TRUE
	return FALSE


/obj/item/gun/projectile/revolver/rocketlauncher/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()


/obj/item/gun/projectile/revolver/rocketlauncher/chamber_round()
	if(chambered || !magazine)
		return
	if(magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.forceMove(src)


/obj/item/gun/projectile/revolver/rocketlauncher/get_ammo(countchambered = TRUE, countempties = TRUE)
	. = ..()


/obj/item/gun/projectile/revolver/rocketlauncher/attack_self(mob/living/user)
	add_fingerprint(user)
	var/num_unloaded = 0
	var/atom/drop_loc = drop_location()
	while(get_ammo(FALSE) > 0)
		var/obj/item/ammo_casing/CB = magazine.get_round()
		CB.forceMove(drop_loc)
		CB.pixel_x = rand(-10, 10)
		CB.pixel_y = rand(-10, 10)
		CB.SpinAnimation(5, 1)
		CB.setDir(pick(GLOB.alldirs))
		CB.update_appearance()
		playsound(drop_loc, CB.casing_drop_sound, 60, TRUE)
		num_unloaded++
	if(chambered)
		chambered.forceMove(drop_loc)
		chambered.pixel_x = rand(-10, 10)
		chambered.pixel_y = rand(-10, 10)
		chambered.setDir(pick(GLOB.alldirs))
		chambered.update_appearance()
		chambered.SpinAnimation(5, 1)
		playsound(drop_loc, chambered.casing_drop_sound, 60, TRUE)
		chambered = null
		num_unloaded++
	update_icon(UPDATE_OVERLAYS)
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "ракета извлечена",  "извлечено [num_unloaded] ракеты",  "извлечено [num_unloaded] ракет")]")
	else
		balloon_alert(user, "уже разряжено!")


/obj/item/gun/projectile/revolver/rocketlauncher/update_icon_state()
	return


/obj/item/gun/projectile/revolver/rocketlauncher/update_overlays()
	. = ..()
	if(!chambered)
		. += "[icon_state]_empty"


/obj/item/gun/projectile/revolver/rocketlauncher/suicide_act(mob/user)
	user.visible_message("<span class='warning'>[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!<span>")
	if(can_shoot(user))
		ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
		playsound(src, 'sound/weapons/rocketlaunch.ogg', 80, 1, 5)
		animate(user, pixel_z = 300, time = 3 SECONDS, easing = LINEAR_EASING)
		sleep(7 SECONDS)
		animate(user, pixel_z = 0, time = 0.5 SECONDS, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
		process_fire(user, user, TRUE)
		if(!QDELETED(user)) //if they weren't gibbed by the explosion, take care of them for good.
			user.gib()
		return OBLITERATION
	else
		sleep(0.5 SECONDS)
		shoot_with_empty_chamber(user)
		sleep(2 SECONDS)
		user.visible_message("<span class='warning'>[user] looks about the room realizing [user.p_theyre()] still there. [user.p_they(TRUE)] proceed to shove [src] down their throat and choke [user.p_them()]self with it!<span>")
		sleep(2 SECONDS)
		return OXYLOSS
