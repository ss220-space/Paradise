// MARK: L6 SAW
/obj/item/gun/projectile/automatic/l6_saw
	name = "L6 SAW"
	desc = "A heavily modified 5.56 light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "l6saw"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	origin_tech = "combat=6;engineering=3;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/l6saw
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshots/1mg2.ogg'
	magin_sound = 'sound/weapons/gun_interactions/lmg_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/lmg_magout.ogg'
	fire_delay = 0.2 SECONDS
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_HIGH
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_MUZZLE | GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 21, ATTACHMENT_OFFSET_Y = -2),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 1, ATTACHMENT_OFFSET_Y = 3),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -11),
	)
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOMATIC)
	var/cover_open = 0

/obj/item/gun/projectile/automatic/l6_saw/attack_self(mob/user)
	cover_open = !cover_open
	balloon_alert(user, "крышка [cover_open ? "от" : "за"]крыта")
	playsound(src, cover_open ? 'sound/weapons/gun_interactions/sawopen.ogg' : 'sound/weapons/gun_interactions/sawclose.ogg', 50, TRUE)
	update_appearance(UPDATE_ICON | UPDATE_OVERLAYS)

/obj/item/gun/projectile/automatic/l6_saw/update_icon_state()
	item_state = "l6[cover_open ? "openmag" : "closedmag"]"


/obj/item/gun/projectile/automatic/l6_saw/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "[base_icon_state]_cap_[cover_open ? "open" : "close"]", layer = FLOAT_LAYER - 0.01)
	if(!magazine)
		return
	. += mutable_appearance(icon, "[base_icon_state]_mag", layer = FLOAT_LAYER - 1)
	. += mutable_appearance(icon, "[base_icon_state]_ammo-[ceil(get_ammo(FALSE) / 25) * 25]", layer = FLOAT_LAYER - 0.01)

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
		update_appearance(UPDATE_ICON | UPDATE_OVERLAYS)
		balloon_alert(user, "магазин вынут")

/obj/item/gun/projectile/automatic/l6_saw/attackby(obj/item/I, mob/user, params)
	if(istype(I, mag_type) && !cover_open)
		balloon_alert(user, "крышка закрыта!")
		return ATTACK_CHAIN_PROCEED
	return ..()
