/obj/item/gun/projectile
	name = "projectile gun"
	desc = "Now comes in flavors like GUN. Uses 10mm ammo, for some reason."
	icon_state = "pistol"
	origin_tech = "combat=2;materials=2"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=1000)

	var/mag_type = /obj/item/ammo_box/magazine/m10mm //Removes the need for max_ammo and caliber info
	var/obj/item/ammo_box/magazine/magazine
	var/can_tactical = FALSE //check to see if the gun can tactically reload


/obj/item/gun/projectile/Initialize(mapload)
	. = ..()
	if(!magazine && mag_type)
		magazine = new mag_type(src)
	chamber_round()
	update_weight()
	update_icon()


/obj/item/gun/projectile/update_name(updates = ALL)
	. = ..()
	if(sawn_state)
		name = "sawn-off [name]"
	else
		name = initial(name)


/obj/item/gun/projectile/update_desc(updates = ALL)
	. = ..()
	if(sawn_state)
		desc = sawn_desc
	else
		desc = initial(desc)


/obj/item/gun/projectile/update_icon_state()
	if(current_skin)
		icon_state = "[current_skin][suppressed ? "-suppressed" : ""][sawn_state ? "-sawn" : ""]"
	else
		icon_state = "[initial(icon_state)][suppressed ? "-suppressed" : ""][sawn_state ? "-sawn" : ""][bolt_open ? "-open" : ""]"


/obj/item/gun/projectile/update_overlays()
	. = ..()
	if(bayonet && bayonet_overlay)
		. += bayonet_overlay


/obj/item/gun/proc/update_weight()
	return


/obj/item/gun/projectile/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	var/obj/item/ammo_casing/hold_casing = chambered //Find chambered round
	if(isnull(hold_casing) || !istype(hold_casing))
		chamber_round()
		return
	if(eject_casing)
		hold_casing.forceMove(drop_location())	//Eject casing onto ground.
		hold_casing.pixel_x = rand(-10, 10)
		hold_casing.pixel_y = rand(-10, 10)
		hold_casing.setDir(pick(GLOB.alldirs))
		hold_casing.update_appearance()
		hold_casing.SpinAnimation(10, 1) //next gen special effects
		playsound(hold_casing.loc, chambered.casing_drop_sound, 100, TRUE)
	if(empty_chamber)
		chambered = null
	chamber_round()


/obj/item/gun/projectile/proc/chamber_round()
	if(chambered || !magazine)
		return
	if(magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.forceMove(src)


/obj/item/gun/projectile/can_shoot(mob/user)
	if(!magazine || !magazine.ammo_count(FALSE))
		return FALSE
	return TRUE

/obj/item/gun/projectile/proc/can_reload()
	return !magazine


/obj/item/gun/projectile/proc/reload(obj/item/ammo_box/magazine/new_magazine, mob/user)
	if(user && magazine.loc == user && !user.drop_transfer_item_to_loc(new_magazine, src))
		return FALSE
	. = TRUE
	magazine = new_magazine
	if(magazine.loc != src)
		magazine.forceMove(src)
	playsound(loc, magin_sound, 50, TRUE)
	chamber_round()
	update_weight()
	magazine.update_icon()
	update_icon()


/obj/item/gun/projectile/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/magazine))
		add_fingerprint(user)
		var/obj/item/ammo_box/magazine/new_magazine = I
		if(!istype(new_magazine, mag_type))
			balloon_alert(user, "не совместимо!")
			return ATTACK_CHAIN_PROCEED
		if(can_reload())
			if(!user.can_unEquip(new_magazine))
				return ..()
			reload(new_magazine, user)
			balloon_alert(user, "заряжено")
			return ATTACK_CHAIN_BLOCKED_ALL
		if(!can_tactical)
			balloon_alert(user, "уже заряжено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.can_unEquip(new_magazine))
			return ..()
		balloon_alert(user, "заряжено")
		magazine.forceMove(drop_location())
		magazine.update_appearance(UPDATE_ICON|UPDATE_DESC)
		magazine = null
		reload(new_magazine, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/suppressor))
		add_fingerprint(user)
		var/obj/item/suppressor/suppressor = I
		if(!can_suppress)
			balloon_alert(user, "не совместимо!")
			return ATTACK_CHAIN_PROCEED
		if(suppressed)
			balloon_alert(user, "уже установлено!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(suppressor, src))
			return ..()
		balloon_alert(user, "установлено")
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		suppressed = suppressor
		suppressor.oldsound = fire_sound
		suppressor.initial_w_class = w_class
		fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
		w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
		update_icon()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/gun/projectile/attack_hand(mob/user)
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(user.l_hand != src && user.r_hand != src)
				..()
				return

			balloon_alert(user, "глушитель снят!")
			playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
			user.put_in_hands(suppressed)
			fire_sound = S.oldsound
			w_class = S.initial_w_class
			suppressed = null
			update_icon()
			return
	..()


/obj/item/gun/projectile/attack_self(mob/living/user)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(magazine)
		magazine.forceMove(drop_location())
		user.put_in_hands(magazine)
		magazine.update_appearance()
		magazine = null
		update_weight()
		balloon_alert(user, "магазин извлечён")
		playsound(loc, magout_sound, 50, TRUE)
	else if(chambered)
		AC.forceMove(drop_location())
		AC.pixel_x = rand(-10, 10)
		AC.pixel_y = rand(-10, 10)
		AC.setDir(pick(GLOB.alldirs))
		AC.update_appearance()
		AC.SpinAnimation(10, 1)
		chambered = null
		balloon_alert(user, "патрон извлечён")
		playsound(loc, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, TRUE)
		playsound(AC.loc, AC.casing_drop_sound, 50, TRUE)
	else
		balloon_alert(user, "уже разряжено!")
	update_icon()


/obj/item/gun/projectile/examine(mob/user)
	. = ..()
	. += span_notice("Has [get_ammo()] round\s remaining.")

/obj/item/gun/projectile/proc/get_ammo(countchambered = TRUE, countempties = TRUE)
	var/boolets = 0 //mature var names for mature people
	if(chambered && countchambered)
		boolets++
	if(magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/projectile/suicide_act(mob/user)
	if(chambered && chambered.BB && !chambered.BB.nodamage)
		user.visible_message(span_suicide("[user] is putting the barrel of the [name] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide."))
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			process_fire(user, user, 0, zone_override = BODY_ZONE_HEAD)
			user.visible_message(span_suicide("[user] blows [user.p_their()] brains out with the [name]!"))
			return BRUTELOSS
		else
			user.visible_message(span_suicide("[user] panics and starts choking to death!"))
			return OXYLOSS
	else
		user.visible_message(span_suicide("[user] is pretending to blow [user.p_their()] brains out with the [name]! It looks like [user.p_theyre()] trying to commit suicide!"))
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return OXYLOSS


/obj/item/gun/projectile/proc/sawoff(mob/user)
	. = FALSE
	if(sawn_state == SAWN_OFF)
		balloon_alert(user, "уже укорочено!")
		return .
	if(bayonet)
		balloon_alert(user, "мешает штык-нож!")
		return .
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", span_notice("You begin to shorten \the [src]..."))

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message(span_danger("\The [src] goes off!"), span_danger("\The [src] goes off in your face!"))
		return .

	if(do_after(user, 3 SECONDS, src))
		if(sawn_state == SAWN_OFF)
			return .
		user.visible_message("[user] shortens \the [src]!", span_notice("You shorten \the [src]."))
		w_class = WEIGHT_CLASS_NORMAL
		item_state = "gun"//phil235 is it different with different skin?
		slot_flags &= ~ITEM_SLOT_BACK	//you can't sling it on your back
		slot_flags |= ITEM_SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
		sawn_state = SAWN_OFF
		update_appearance()
		update_equipped_item()
		return TRUE


// Sawing guns related proc
/obj/item/gun/projectile/proc/blow_up(mob/user)
	. = FALSE
	for(var/obj/item/ammo_casing/AC in magazine.stored_ammo)
		if(AC.BB)
			process_fire(user, user,0)
			. = TRUE
