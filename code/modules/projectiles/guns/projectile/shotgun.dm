/obj/item/gun/projectile/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags = CONDUCT
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	weapon_weight = WEAPON_HEAVY
	pb_knockback = 2
	COOLDOWN_DECLARE(last_pump)	// to prevent spammage


/obj/item/gun/projectile/shotgun/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box/speedloader) || istype(I, /obj/item/ammo_casing))
		add_fingerprint(user)
		var/num_loaded = magazine.reload(I, user)
		if(num_loaded)
			update_appearance()
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/shotgun/process_chamber(eject_casing = TRUE, empty_chamber = TRUE)
	return ..(FALSE, FALSE)


/obj/item/gun/projectile/shotgun/chamber_round()
	return


/obj/item/gun/projectile/shotgun/can_shoot(mob/user)
	if(!chambered)
		return FALSE
	return (chambered.BB ? TRUE : FALSE)


/obj/item/gun/projectile/shotgun/attack_self(mob/living/user)
	if(!COOLDOWN_FINISHED(src, last_pump))
		return
	COOLDOWN_START(src, last_pump, 1 SECONDS)
	pump(user)


/obj/item/gun/projectile/shotgun/proc/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/shotgunpump.ogg', 60, 1)
	pump_unload(M)
	pump_reload(M)
	update_icon() //I.E. fix the desc
	return 1

/obj/item/gun/projectile/shotgun/proc/pump_unload(mob/M)
	if(chambered)//We have a shell in the chamber
		chambered.loc = get_turf(src)//Eject casing
		chambered.SpinAnimation(5, 1)
		playsound(src, chambered.casing_drop_sound, 60, 1)
		chambered = null

/obj/item/gun/projectile/shotgun/proc/pump_reload(mob/M)
	if(!magazine.ammo_count())
		return 0
	var/obj/item/ammo_casing/AC = magazine.get_round() //load next casing.
	chambered = AC

/obj/item/gun/projectile/shotgun/examine(mob/user)
	. = ..()
	if(chambered)
		. += "<span class='notice'>A [chambered.BB ? "live" : "spent"] one is in the chamber.</span>"

/obj/item/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	sawn_state = SAWN_INTACT
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'


/obj/item/gun/projectile/shotgun/riot/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/circular_saw) || istype(I, /obj/item/gun/energy/plasmacutter))
		add_fingerprint(user)
		if(sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/melee/energy))
		add_fingerprint(user)
		var/obj/item/melee/energy/sword = I
		if(sword.active && sawoff(user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/pipe))
		add_fingerprint(user)
		if(unsaw(I, user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/shotgun/riot/sawoff(mob/user)
	if(sawn_state == SAWN_OFF)
		balloon_alert(user, "уже укорочено!")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack(user, user)
			user.visible_message("The [src] goes click!", "<span class='notice'>The [src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo(FALSE) > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 3 SECONDS, src))
		user.visible_message("[user] shortens \the [src]!", "<span class='notice'>You shorten \the [src].</span>")
		post_sawoff()
		return 1


/obj/item/gun/projectile/shotgun/riot/proc/post_sawoff()
	name = "assault shotgun"
	desc = sawn_desc
	w_class = WEIGHT_CLASS_NORMAL
	current_skin = "riotshotgun-short"
	item_state = "gun"			//phil235 is it different with different skin?
	slot_flags &= ~ITEM_SLOT_BACK    //you can't sling it on your back
	slot_flags |= ITEM_SLOT_BELT     //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
	sawn_state = SAWN_OFF
	magazine.max_ammo = 3
	update_icon()


/obj/item/gun/projectile/shotgun/riot/proc/unsaw(obj/item/A, mob/user)
	if(sawn_state == SAWN_INTACT)
		balloon_alert(user, "операция провалилась!")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message("<span class='danger'>\The [src] goes off!</span>", "<span class='danger'>\The [src] goes off in your face!</span>")
			return
		else
			afterattack(user, user)
			user.visible_message("The [src] goes click!", "<span class='notice'>The [src] you are holding goes click.</span>")
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message("<span class='danger'>[user.name] opens [src] up and the shells go goes flying around!</span>", "<span class='userdanger'>You open [src] up and the shells go goes flying everywhere!!</span>")
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 3 SECONDS, src))
		qdel(A)
		user.visible_message("<span class='notice'>[user] lengthens [src]!</span>", "<span class='notice'>You lengthen [src].</span>")
		post_unsaw(user)
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_unsaw()
	name = initial(name)
	desc = initial(desc)
	w_class = initial(w_class)
	current_skin = "riotshotgun"
	item_state = initial(item_state)
	slot_flags &= ~ITEM_SLOT_BELT
	slot_flags |= ITEM_SLOT_BACK
	sawn_state = SAWN_INTACT
	magazine.max_ammo = 6
	update_icon()

/obj/item/gun/projectile/shotgun/riot/update_icon_state() //Can't use the old proc as it makes it go to riotshotgun-short_sawn
	if(current_skin)
		icon_state = "[current_skin]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/projectile/shotgun/riot/short
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/short

/obj/item/gun/projectile/shotgun/riot/short/Initialize(mapload)
	. = ..()
	post_sawoff()

/obj/item/gun/projectile/shotgun/riot/buckshot	//comes pre-loaded with buckshot rather than rubber
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/buckshot


///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/projectile/shotgun/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. Has a bayonet lug for attaching a knife."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = NONE //no ITEM_SLOT_BACK sprite, alas
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	fire_sound = 'sound/weapons/gunshots/1rifle.ogg'
	bolt_open = FALSE
	can_bayonet = TRUE
	bayonet_x_offset = 27
	bayonet_y_offset = 13
	pb_knockback = 0

/obj/item/gun/projectile/shotgun/boltaction/pump(mob/M)
	playsound(M, 'sound/weapons/gun_interactions/rifle_load.ogg', 60, 1)
	if(bolt_open)
		pump_reload(M)
	else
		pump_unload(M)
	bolt_open = !bolt_open
	update_icon(UPDATE_ICON_STATE)
	return 1


/obj/item/gun/projectile/shotgun/boltaction/update_icon_state()
	icon_state = "[initial(icon_state)][bolt_open ? "-open" : ""]"


/obj/item/gun/projectile/shotgun/blow_up(mob/user)
	. = 0
	if(chambered && chambered.BB)
		process_fire(user, user,0)
		. = 1


/obj/item/gun/projectile/shotgun/boltaction/attackby(obj/item/I, mob/user, params)
	if(!bolt_open)
		add_fingerprint(user)
		balloon_alert(user, "затвор закрыт!")
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/gun/projectile/shotgun/boltaction/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The bolt is [bolt_open ? "open" : "closed"].</span>"

/obj/item/gun/projectile/shotgun/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted
	can_bayonet = FALSE

/obj/item/gun/projectile/shotgun/boltaction/enchanted/Initialize(mapload)
	. = ..()
	bolt_open = 1
	pump()

/obj/item/gun/projectile/shotgun/boltaction/enchanted/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	guns_left = 0

/obj/item/gun/projectile/shotgun/boltaction/enchanted/attack_self()
	return

/obj/item/gun/projectile/shotgun/boltaction/enchanted/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	if(guns_left)
		var/obj/item/gun/projectile/shotgun/boltaction/enchanted/GUN = new type
		GUN.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.drop_from_active_hand()
		user.put_in_hands(GUN)
	else
		discard_gun(user)

/obj/item/gun/projectile/shotgun/boltaction/enchanted/proc/discard_gun(mob/living/user)
	user.visible_message("<span class='warning'>[user] tosses aside the spent rifle!</span>")
	user.throw_item(pick(oview(7, get_turf(user))))

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	slot_flags = null
	item_flags = NOBLUDGEON|DROPDEL|ABSTRACT
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/examine(mob/user)
	var/f_name = "\a [src]."
	. = list("[bicon(src)] That's [f_name]")
	. += desc // Override since magical hand lasers don't have chambers or bolts

/obj/item/gun/projectile/shotgun/boltaction/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

// Automatic Shotguns//

/obj/item/gun/projectile/shotgun/automatic

/obj/item/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	pump(user)

/obj/item/gun/projectile/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'

//Dual Feed Shotgun

/obj/item/gun/projectile/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	origin_tech = "combat=4;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine
	fire_sound = 'sound/weapons/gunshots/1shotgun_auto.ogg'

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if(!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		pump()
	else
		toggle_tube(user)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		balloon_alert(user, "переключено на первый ствол")
	else
		balloon_alert(user, "переключено на второй ствол")
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, 1)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	. = ..()
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user) || !istype(user))
		return
	pump()

// DOUBLE BARRELED SHOTGUN, IMPROVISED SHOTGUN, and CANE SHOTGUN are in revolver.dm
