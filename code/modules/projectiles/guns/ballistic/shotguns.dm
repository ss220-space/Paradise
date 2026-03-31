// MARK: Lethal
/obj/item/gun/projectile/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// MARK: Riot shotgun
/obj/item/gun/projectile/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	item_state = "riotshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Come with me if you want to live."
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -6),
	)

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
	if(attachments_by_slot[ATTACHMENT_SLOT_MUZZLE])
		balloon_alert(user, "нужно снять дульный модуль!")
		return
	if(sawn_state == SAWN_OFF)
		balloon_alert(user, "уже укорочено!")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message(
				span_danger("\The [src] goes off!"),
				span_danger("\The [src] goes off in your face!")
			)
			return
		else
			afterattack(user, user)
			user.visible_message(
				"The [src] goes click!",
				span_notice("The [src] you are holding goes click.")
			)
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message(
			span_danger("[user.name] opens [src] up and the shells go goes flying around!"),
			span_userdanger("You open [src] up and the shells go goes flying everywhere!!")
		)
		while(get_ammo(FALSE) > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 3 SECONDS, src))
		user.visible_message(
			"[user] shortens \the [src]!",
			span_notice("You shorten \the [src].")
		)
		post_sawoff()
		return 1

/obj/item/gun/projectile/shotgun/riot/proc/post_sawoff()
	name = "assault shotgun"
	desc = sawn_desc
	w_class = WEIGHT_CLASS_NORMAL
	current_skin = "riotshotgun-short"
	item_state = "riotshotgun-short"			//phil235 is it different with different skin?
	item_color = "riotshotgun-short"
	slot_flags &= ~ITEM_SLOT_BACK    //you can't sling it on your back
	slot_flags |= ITEM_SLOT_BELT     //but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
	sawn_state = SAWN_OFF
	accuracy = GUN_ACCURACY_MINIMAL
	magazine.max_ammo = 3
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 18, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -6),
	)
	update_icon()

/obj/item/gun/projectile/shotgun/riot/proc/unsaw(obj/item/A, mob/user)
	if(attachments_by_slot[ATTACHMENT_SLOT_MUZZLE])
		balloon_alert(user, "нужно снять дульный модуль!")
		return
	if(sawn_state == SAWN_INTACT)
		balloon_alert(user, "операция провалилась!")
		return
	if(isstorage(loc))	//To prevent inventory exploits
		balloon_alert(user, "не подходящее место!")
		return
	if(chambered)	//if the gun is chambering live ammo, shoot self, if chambering empty ammo, 'click'
		if(chambered.BB)
			afterattack(user, user)
			user.visible_message(span_danger("\The [src] goes off!"), span_danger("\The [src] goes off in your face!"))
			return
		else
			afterattack(user, user)
			user.visible_message("The [src] goes click!", span_notice("The [src] you are holding goes click."))
	if(magazine.ammo_count())	//Spill the mag onto the floor
		user.visible_message(span_danger("[user.name] opens [src] up and the shells go goes flying around!"), span_userdanger("You open [src] up and the shells go goes flying everywhere!!"))
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round(0)
			if(CB)
				CB.loc = get_turf(loc)
				CB.update_icon()

	if(do_after(user, 3 SECONDS, src))
		qdel(A)
		user.visible_message(span_notice("[user] lengthens [src]!"), span_notice("You lengthen [src]."))
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
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -6),
	)
	update_icon()

/obj/item/gun/projectile/shotgun/riot/update_icon_state() //Can't use the old proc as it makes it go to riotshotgun-short_sawn
	if(current_skin)
		icon_state = "[current_skin]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/gun/projectile/shotgun/riot/short
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/short
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA

/obj/item/gun/projectile/shotgun/riot/short/Initialize(mapload)
	. = ..()
	post_sawoff()

/obj/item/gun/projectile/shotgun/riot/buckshot	//comes pre-loaded with buckshot rather than rubber
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot/buckshot

// MARK: Rusted shotgun
/obj/item/gun/projectile/shotgun/lethal/rusted
	desc = "A traditional shotgun. It looks like it has been lying here for a very long time, rust is pouring."
	accuracy = GUN_ACCURACY_SHOTGUN

/obj/item/gun/projectile/shotgun/lethal/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 4)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)

// MARK: Basic Auto Shotgun
/obj/item/gun/projectile/shotgun/automatic

/obj/item/gun/projectile/shotgun/automatic/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	addtimer(CALLBACK(src, PROC_REF(pump), user), 1)

// MARK: Combat shotgun
/obj/item/gun/projectile/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	item_state = "cshotgun"
	origin_tech = "combat=6"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 22, "y" = 3),
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 9, "y" = -4),
	)
	recoil = GUN_RECOIL_HIGH

// MARK: Dual Tube
/obj/item/gun/projectile/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = 0
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine
	fire_sound = 'sound/weapons/gunshots/1shotgun_auto.ogg'
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 3, "y" = 7),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if(!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/unload_act(mob/user)
	if(!chambered && length(magazine.contents))
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
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, TRUE)

/obj/item/gun/projectile/shotgun/automatic/dual_tube/click_alt(mob/living/user)
	pump()
	return CLICK_ACTION_SUCCESS

/obj/item/gun/projectile/shotgun/automatic/dual_tube/AltShiftClick(mob/user)
	. = ..()
	try_detach_gun_module(user)

// MARK: Bulldog
/obj/item/gun/projectile/automatic/shotgun/bulldog
	name = "'Bulldog' Shotgun"
	desc = "A compact, mag-fed semi-automatic shotgun for combat in narrow corridors, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 12/24-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/bulldog.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	magin_sound = 'sound/weapons/gun_interactions/batrifle_magin.ogg'
	magout_sound = 'sound/weapons/gun_interactions/batrifle_magout.ogg'
	burst_size = 1
	fire_delay = 0
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 7, "y" = 9),
		ATTACHMENT_SLOT_UNDER = list("x" = 10, "y" = -6),
	)
	recoil = GUN_RECOIL_HIGH
	fire_modes = GUN_MODE_SINGLE_ONLY

/obj/item/gun/projectile/automatic/shotgun/bulldog/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff
	name = "'Mastiff' Shotgun"
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

// MARK: AS-12 Minotaur
/obj/item/gun/projectile/automatic/shotgun/minotaur
	name = "AS-12 'Minotaur' Shotgun"
	desc = "Smooth, powerful, highly illegal. The newest full auto shotgun available at the market, utilizes standard 12g drum mags. Property of Gorlex Marauders."
	icon_state = "minotaur"
	item_state = "minotaur"
	weapon_weight = WEAPON_HEAVY
	origin_tech = "combat=6;materials=4;syndicate=6"
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_sound = 'sound/weapons/gunshots/minotaur.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	magin_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_in.ogg'
	magout_sound = 'sound/weapons/gun_interactions/autoshotgun_mag_out.ogg'
	fire_delay = 1.5
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL | GUN_MODULE_CLASS_SHOTGUN_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 0),
		ATTACHMENT_SLOT_RAIL = list("x" = 1, "y" = 4),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -5),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/shotgun/minotaur/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm, 'sound/weapons/smg_empty_alarm.ogg')

/obj/item/gun/projectile/automatic/shotgun/minotaur/New()
	magazine = new/obj/item/ammo_box/magazine/m12g/XtrLrg
	..()

// MARK: C.A.T.S.
/obj/item/gun/projectile/automatic/cats
	name = "C.A.T. Shotgun"
	desc = "Terra Light Armories - Combat Automatic Tactical Shotgun - мощный автоматический дробовик, в основном используемый силами Транс-Солнечной Федерации. Производится корпорацией Terra Industries."
	icon_state = "tla_cats"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/cats12g
	fire_delay = 0
	fire_sound = 'sound/weapons/gunshots/1shotgun.ogg'
	suppressed_fire_sound = 'sound/weapons/gunshots/shotgunsupp.ogg'
	burst_size = 2
	accuracy = GUN_ACCURACY_SHOTGUN
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_SHOTGUN_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 6),
	)
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/projectile/automatic/cats/update_icon_state()
	icon_state = "tla_cats[magazine ? "" : "-e"]"

// MARK: Double-barreled
/obj/item/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	sawn_desc = "Omar's coming!"
	can_holster = FALSE
	pb_knockback = 3
	accuracy = GUN_ACCURACY_SHOTGUN
	recoil = GUN_RECOIL_HIGH
	attachable_allowed = GUN_MODULE_CLASS_NONE
	can_air_shoot = FALSE

/obj/item/gun/projectile/revolver/doublebarrel/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/revolver/doublebarrel/attackby(obj/item/I, mob/user, params)
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

	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	if(.)
		weapon_weight = WEAPON_MEDIUM
		can_holster = TRUE
		accuracy = GUN_ACCURACY_MINIMAL

/obj/item/gun/projectile/revolver/doublebarrel/unload_act(mob/user)
	var/num_unloaded = 0
	var/atom/drop_loc = drop_location()
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.forceMove(drop_loc)
		CB.pixel_x = rand(-10, 10)
		CB.pixel_y = rand(-10, 10)
		CB.setDir(pick(GLOB.alldirs))
		CB.update_appearance()
		CB.SpinAnimation(10, 1)
		playsound(drop_loc, CB.casing_drop_sound, 70, TRUE)
		num_unloaded++
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "разряжен [num_unloaded] патрон",  "разряжено [num_unloaded] патрона",  "разряжено [num_unloaded] патронов")]")
	else
		balloon_alert(user, "уже разряжено!")

// MARK: Improvised
/obj/item/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	fire_sound = 'sound/weapons/gunshots/1shotgunpipe.ogg'
	sawn_desc = "I'm just here for the gasoline."
	unique_rename = FALSE
	pb_knockback = 0
	var/slung = FALSE
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA

/obj/item/gun/projectile/revolver/doublebarrel/improvised/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(sawn_state == SAWN_OFF)
			balloon_alert(user, "не совместимо!")
			return ATTACK_CHAIN_PROCEED
		if(!coil.use(10))
			balloon_alert(user, "нужно больше кабеля!")
			return ATTACK_CHAIN_PROCEED
		slot_flags |= ITEM_SLOT_BACK
		balloon_alert(user, "присоединён самодельный ремень!")
		slung = TRUE
		update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/update_icon_state()
	icon_state = "ishotgun[slung ? "sling" : sawn_state == SAWN_OFF ? "-sawn" : ""]"

/obj/item/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(drop_location(), 10)
		slung = FALSE
		update_icon()

// MARK: Cane shotgun
/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "Трость — верный спутник настоящего джентльмена. Или клоуна."
	gender = FEMALE
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "cane"
	item_state = "stick"
	sawn_state = SAWN_OFF
	w_class = WEIGHT_CLASS_SMALL
	can_unsuppress = FALSE
	slot_flags = null
	origin_tech = "" // NO GIVAWAYS
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised/cane
	sawn_desc = "Прошу прощения, но зачем вы распилили свою трость?"
	attack_verb = list("огрел", "проучил")
	suppressed = TRUE
	needs_permit = FALSE //its just a cane beepsky.....
	accuracy = GUN_ACCURACY_SHOTGUN
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/get_ru_names()
	return list(
		NOMINATIVE = "трость",
		GENITIVE = "трости",
		DATIVE = "трости",
		ACCUSATIVE = "трость",
		INSTRUMENTAL = "тростью",
		PREPOSITIONAL = "трости",
	)

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/is_crutch()
	return 2

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_icon_state()
	return

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_overlays()
	return list()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/attackby(obj/item/I, mob/user, params)
	if(iscoil(I))
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user) // HAD TO REPEAT EXAMINE CODE BECAUSE GUN CODE DOESNT STEALTH
	var/f_name = "\a [src]."
	if(blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += span_danger("blood-stained [name]!")

	. = list("[icon2html(src, user)] That's [f_name]")

	if(desc)
		. += desc
