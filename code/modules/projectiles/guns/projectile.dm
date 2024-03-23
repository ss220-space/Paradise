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
	if(bayonet && knife_overlay)
		. += knife_overlay


/obj/item/gun/proc/update_weight()
	return


/obj/item/gun/projectile/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		chamber_round()
		return
	if(eject_casing)
		AC.loc = get_turf(src) //Eject casing onto ground.
		AC.SpinAnimation(10, 1) //next gen special effects
		playsound(src, chambered.casing_drop_sound, 100, TRUE)
	if(empty_chamber)
		chambered = null
	chamber_round()
	return

/obj/item/gun/projectile/proc/chamber_round()
	if(chambered || !magazine)
		return
	else if(magazine.ammo_count())
		chambered = magazine.get_round()
		chambered.loc = src
	return

/obj/item/gun/projectile/can_shoot()
	if(!magazine || !magazine.ammo_count(FALSE))
		return FALSE
	return TRUE

/obj/item/gun/projectile/proc/can_reload()
	return !magazine


/obj/item/gun/projectile/proc/reload(obj/item/ammo_box/magazine/AM, mob/user)
	user.drop_item_ground(AM)
	magazine = AM
	magazine.loc = src
	playsound(src, magin_sound, 50, 1)
	chamber_round()
	update_weight()
	AM.update_icon()
	update_icon()


/obj/item/gun/projectile/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/magazine))
		var/obj/item/ammo_box/magazine/AM = A
		if(istype(AM, mag_type))
			if(can_reload())
				reload(AM, user)
				to_chat(user, span_notice("You load a new magazine into \the [src]."))
				return TRUE
			else if(!can_tactical)
				to_chat(user, span_notice("There's already a magazine in \the [src]."))
				return TRUE
			else
				to_chat(user, span_notice("You perform a tactical reload on \the [src], replacing the magazine."))
				magazine.loc = get_turf(loc)
				magazine.update_icon()
				magazine = null
				reload(AM, user)
				return TRUE
		else
			to_chat(user, span_notice("You can't put this type of ammo in \the [src]."))
			return TRUE
	if(istype(A, /obj/item/suppressor))
		var/obj/item/suppressor/S = A
		if(can_suppress)
			if(!suppressed)
				if(!user.drop_transfer_item_to_loc(A, src))
					return
				to_chat(user, span_notice("You screw [S] onto [src]."))
				playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
				suppressed = A
				S.oldsound = fire_sound
				S.initial_w_class = w_class
				fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
				w_class = WEIGHT_CLASS_NORMAL //so pistols do not fit in pockets when suppressed
				update_icon()
				return
			else
				to_chat(user, span_warning("[src] already has a suppressor."))
				return
		else
			to_chat(user, span_warning("You can't seem to figure out how to fit [S] on [src]."))
			return
	else
		return ..()

/obj/item/gun/projectile/attack_hand(mob/user)
	if(loc == user)
		if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			if(user.l_hand != src && user.r_hand != src)
				..()
				return
			to_chat(user, span_notice("You unscrew [suppressed] from [src]."))
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
		magazine.loc = get_turf(loc)
		user.put_in_hands(magazine)
		magazine.update_icon()
		magazine = null
		update_weight()
		to_chat(user, span_notice("You pull the magazine out of \the [src]!"))
		playsound(src, magout_sound, 50, 1)
	else if(chambered)
		AC.loc = get_turf(src)
		AC.SpinAnimation(10, 1)
		chambered = null
		to_chat(user, span_notice("You unload the round from \the [src]'s chamber."))
		playsound(src, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, 1)
	else
		to_chat(user, span_notice("There's no magazine in \the [src]."))
	update_icon()
	return

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
	if(sawn_state == SAWN_OFF)
		to_chat(user, span_warning("\The [src] is already shortened!"))
		return
	if(bayonet)
		to_chat(user, span_warning("You cannot saw-off [src] with [bayonet] attached!"))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("[user] begins to shorten \the [src].", span_notice("You begin to shorten \the [src]..."))

	//if there's any live ammo inside the gun, makes it go off
	if(blow_up(user))
		user.visible_message(span_danger("\The [src] goes off!"), span_danger("\The [src] goes off in your face!"))
		return

	if(do_after(user, 3 SECONDS, target = src))
		if(sawn_state == SAWN_OFF)
			return
		user.visible_message("[user] shortens \the [src]!", span_notice("You shorten \the [src]."))
		w_class = WEIGHT_CLASS_NORMAL
		item_state = "gun"//phil235 is it different with different skin?
		slot_flags &= ~SLOT_BACK	//you can't sling it on your back
		slot_flags |= SLOT_BELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
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
