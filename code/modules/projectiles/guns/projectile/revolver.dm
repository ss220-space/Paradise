/obj/item/gun/projectile/revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	origin_tech = "combat=3;materials=2"
	fire_sound = 'sound/weapons/gunshots/1rev.ogg'

/obj/item/gun/projectile/revolver/Initialize(mapload)
	. = ..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/chamber_round(spin = TRUE)
	if(!magazine)
		return
	if(spin)
		chambered = magazine.get_round(TRUE)
	else
		chambered = magazine.stored_ammo[1]
	return

/obj/item/gun/projectile/revolver/shoot_with_empty_chamber(mob/living/user)
	..()
	chamber_round(TRUE)

/obj/item/gun/projectile/revolver/process_chamber()
	return ..(FALSE, TRUE)

/obj/item/gun/projectile/revolver/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(A, /obj/item/ammo_box/speedloader) || istype(A, /obj/item/ammo_casing))
		var/num_loaded = magazine.attackby(A, user, params, TRUE)
		if(num_loaded)
			to_chat(user, span_notice("You load [num_loaded] shell\s into \the [src]."))
			A.update_icon()
			update_icon()
			chamber_round(FALSE)

/obj/item/gun/projectile/revolver/attack_self(mob/living/user)
	var/num_unloaded = 0
	chambered = null
	while(get_ammo(FALSE) > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(FALSE)
		if(CB)
			CB.loc = get_turf(loc)
			CB.SpinAnimation(10, 1)
			CB.update_icon()
			playsound(get_turf(CB), "casingdrop", 60, 1)
			num_unloaded++
	if(num_unloaded)
		to_chat(user, span_notice("You unload [num_unloaded] shell\s from [src]."))
	else
		to_chat(user, span_notice("[src] is empty!"))

/obj/item/gun/projectile/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M, src))
		return

	if(istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
		C.spin()
		chamber_round(FALSE)
		playsound(loc, 'sound/weapons/revolver_spin.ogg', 50, 1)
		usr.visible_message("[usr] spins [src]'s chamber.",  span_notice("You spin [src]'s chamber."))
	else
		verbs -= /obj/item/gun/projectile/revolver/verb/spin


/obj/item/gun/projectile/revolver/can_shoot()
	return get_ammo(FALSE, FALSE)


/obj/item/gun/projectile/revolver/get_ammo(countchambered = FALSE, countempties = TRUE)
	. = ..()


/obj/item/gun/projectile/revolver/examine(mob/user)
	. = ..()
	. += span_notice("[get_ammo(FALSE, FALSE)] of those are live rounds")

/obj/item/gun/projectile/revolver/detective
	name = ".38 Mars Special"
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	unique_rename = TRUE
	unique_reskin = TRUE


/obj/item/gun/projectile/revolver/detective/update_gun_skins()
	add_skin("The Original", "detective")
	add_skin("Leopard Spots", "detective_leopard")
	add_skin("Black Panther", "detective_panther")
	add_skin("White Gold", "detective_gold")
	add_skin("Gold Wood", "detective_gold_alt")
	add_skin("The Peacemaker", "detective_peacemaker")
	add_skin("Silver", "detective_silver")


/obj/item/gun/projectile/revolver/fingergun //Summoned by the Finger Gun spell, from advanced mimery traitor item
	name = "\improper finger gun"
	desc = "Bang bang bang!"
	icon_state = "fingergun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	origin_tech = ""
	flags = ABSTRACT | NODROP | DROPDEL
	slot_flags = null
	fire_sound = null
	fire_sound_text = null
	lefthand_file = null
	righthand_file = null
	can_holster = FALSE // Get your fingers out of there!
	clumsy_check = FALSE //Stole your uplink! Honk!
	needs_permit = FALSE //go away beepsky
	var/obj/effect/proc_holder/spell/mime/fingergun/parent_spell


/obj/item/gun/projectile/revolver/fingergun/fake
	desc = "Pew pew pew!"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake


/obj/item/gun/projectile/revolver/fingergun/Initialize(loc, new_parent_spell)
	. = ..()
	parent_spell = new_parent_spell
	verbs -= /obj/item/gun/projectile/revolver/verb/spin


/obj/item/gun/projectile/revolver/fingergun/Destroy()
	if(parent_spell)
		parent_spell.current_gun = null
		parent_spell.UnregisterSignal(parent_spell.action.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_spell = null
	return ..()


/obj/item/gun/projectile/revolver/fingergun/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, span_notice("You are out of ammo! You holster your fingers."))
	qdel(src)
	return

/obj/item/gun/projectile/revolver/fingergun/afterattack(atom/target, mob/living/user, flag, params)
	if(!user.mind?.miming)
		to_chat(user, span_notice("You must dedicate yourself to silence first. Use your fingers if you wish to holster them."))
		return
	..()

/obj/item/gun/projectile/revolver/fingergun/attackby(obj/item/A, mob/user, params)
	return

/obj/item/gun/projectile/revolver/fingergun/attack_self(mob/living/user)
	if(istype(user))
		to_chat(user, span_notice("You holster your fingers. Another time."))
	qdel(src)
	return

/obj/item/gun/projectile/revolver/mateba
	name = "\improper Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"

/obj/item/gun/projectile/revolver/ga12
	name = "\improper Tkach Ya-Sui GA 12 revolver"
	desc = "An outdated sidearm rarely seen in use by certain PMCs that operate throughout the frontier systems, featuring a three-shell cylinder. Thats right, shell, this one shoots twelve gauge."
	icon_state = "12garevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ga12
	fire_sound = 'sound/weapons/gunshots/1rev12.ogg'
	spread = 15
	recoil = 1
	fire_delay = 5

/obj/item/gun/projectile/revolver/golden
	name = "golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	recoil = 8

/obj/item/gun/projectile/revolver/nagant
	name = "nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	origin_tech = "combat=3"
	can_suppress = TRUE
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762

/obj/item/gun/projectile/revolver/c36
	name = ".36 revolver"
	desc = "An old fashion .36 chambered revolver."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev36
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/gun/projectile/revolver/russian
	name = "\improper Russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism that spins the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/rus357
	var/spun = FALSE


/obj/item/gun/projectile/revolver/russian/Initialize(mapload)
	. = ..()
	Spin()
	update_icon()

/obj/item/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(FALSE, FALSE))
		chamber_round()
	spun = TRUE

/obj/item/gun/projectile/revolver/russian/attackby(obj/item/A, mob/user, params)
	var/num_loaded = ..()
	if(num_loaded)
		user.visible_message("[user] loads a single bullet into the revolver and spins the chamber.", span_notice("You load a single bullet into the chamber and spin it."))
	else
		user.visible_message("[user] spins the chamber of the revolver.", span_notice("You spin the revolver's chamber."))
	if(get_ammo() > 0)
		Spin()
	update_icon()
	A.update_icon()
	return

/obj/item/gun/projectile/revolver/russian/attack_self(mob/user)
	if(!spun && can_shoot())
		user.visible_message("[user] spins the chamber of the revolver.", span_notice("You spin the revolver's chamber."))
		Spin()
	else
		var/num_unloaded = 0
		while(get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round()
			chambered = null
			CB.loc = get_turf(loc)
			CB.update_icon()
			playsound(get_turf(CB), "casingdrop", 60, 1)
			num_unloaded++
		if(num_unloaded)
			to_chat(user, span_notice("You unload [num_unloaded] shell\s from [src]."))
		else
			to_chat(user, span_notice("[src] is empty."))

/obj/item/gun/projectile/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == INTENT_HARM) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			to_chat(user, span_notice("A mechanism prevents you from shooting anyone but yourself!"))
		return

	if(ishuman(user))
		if(!spun)
			to_chat(user, span_notice("You need to spin the revolver's chamber first!"))
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire(user, user, firer_source_atom = src))
				playsound(user, fire_sound, 50, 1)
				var/zone = check_zone(user.zone_selected)
				if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH)
					shoot_self(user, zone)
				else
					user.visible_message(span_danger("[user.name] cowardly fires [src] at [user.p_their()] [zone]!"), span_userdanger("You cowardly fire [src] at your [zone]!"), span_italics("You hear a gunshot!"))
				return

		user.visible_message(span_danger("*click*"))
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/gun/projectile/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(span_danger("[user.name] fires [src] at [user.p_their()] head!"), span_userdanger("You fire [src] at your head!"), span_italics("You hear a gunshot!"))

/obj/item/gun/projectile/revolver/russian/soul
	name = "cursed Russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/gun/projectile/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/soulstone/anybody/SS = new /obj/item/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message(span_danger("[user.name]'s soul is captured by \the [src]!"), span_userdanger("You've lost the gamble! Your soul is forfeit!"))

/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/cap

/obj/item/gun/projectile/revolver/improvised
	name = "improvised revolver"
	desc = "Weapon for crazy fun with friends."
	icon_state = "irevolver"
	item_state = "revolver"
	mag_type = null
	fire_sound = 'sound/weapons/gunshots/1rev257.ogg'
	var/unscrewed = TRUE
	var/obj/item/weaponcrafting/revolverbarrel/barrel

/obj/item/gun/projectile/revolver/improvised/New()
	..()
	barrel = new	// I just want it to spawn with barrel.
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/update_overlays()
	. = ..()
	if(magazine)
		. += icon('icons/obj/weapons/projectile.dmi', magazine.icon_state)
	if(barrel)
		var/icon/barrel_icon = icon('icons/obj/weapons/projectile.dmi', barrel.icon_state)
		if(unscrewed)
			barrel_icon.Turn(-90)
			barrel_icon.Shift(WEST, 5)
		. += barrel_icon

/obj/item/gun/projectile/revolver/improvised/afterattack(atom/target, mob/living/user, flag, params)
	if(unscrewed)
		shoot_with_empty_chamber(user)
		return
	if(istype(barrel, /obj/item/weaponcrafting/revolverbarrel/steel) || prob(80))
		return ..()
	chamber_round(TRUE)
	user.visible_message(span_dangerbigger("*CRACK*"))
	playsound(user, 'sound/weapons/jammed.ogg', 140, TRUE)

/obj/item/gun/projectile/revolver/improvised/proc/radial_menu(mob/user)
	var/list/choices = list()

	if(barrel)
		choices["Barrel"] = image(icon = barrel.icon, icon_state = barrel.icon_state)
	if(magazine)
		choices["Magazine"] = image(icon = magazine.icon, icon_state = magazine.icon_state)
	var/choice = choices.len == 1 ? pick(choices) : show_radial_menu(user, src, choices, require_near = TRUE)

	if(!choice || loc != user)
		return

	switch(choice)
		if("Barrel")
			if(!do_mob(user, src, 8 SECONDS))
				return
			to_chat(user, span_notice("You unscrew [barrel] from [src]."))
			user.put_in_hands(barrel)
			barrel = null
		if("Magazine")
			to_chat(user, span_notice("You unscrew [magazine] from [src]."))
			user.put_in_hands(magazine)
			magazine = null
			verbs -= /obj/item/gun/projectile/revolver/verb/spin
	playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attack_hand(mob/user)
	if(loc == user && unscrewed)
		radial_menu(user)
	else ..()

/obj/item/gun/projectile/revolver/improvised/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume))
		return
	if(!magazine || !barrel)
		to_chat(user, span_notice("You can't do it without cylinder and barrel, attached to revolver."))
	else
		to_chat(user, span_notice("You [unscrewed ? "screwed [magazine] to the place" : "unscrewed [magazine] from [src]"]."))
		unscrewed = !unscrewed
		update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attackby(obj/item/A, mob/user, params)
	if(unscrewed)
		if(istype(A, /obj/item/ammo_box/magazine/internal/cylinder/improvised))
			if(magazine)
				to_chat(user, span_notice("[src] already have [magazine]."))
			else if(user.drop_transfer_item_to_loc(A, src))
				magazine = A
				verbs += /obj/item/gun/projectile/revolver/verb/spin
				update_icon(UPDATE_OVERLAYS)
				playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
		else if(istype(A, /obj/item/weaponcrafting/revolverbarrel))
			if(barrel)
				to_chat(user, span_notice("[src] already have [barrel]."))
			else if(do_mob(user, src, 8 SECONDS))
				if(user.drop_transfer_item_to_loc(A, src))
					var/obj/item/weaponcrafting/revolverbarrel/new_barrel = A
					barrel = A
					fire_sound = new_barrel.new_fire_sound
					update_icon(UPDATE_OVERLAYS)
					playsound(src, 'sound/items/screwdriver.ogg', 40, 1)
	else
		return ..()

/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/projectile/revolver/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	force = 10
	flags = CONDUCT
	slot_flags = SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	fire_sound = 'sound/weapons/gunshots/1shotgun_old.ogg'
	sawn_desc = "Omar's coming!"
	can_holster = FALSE
	unique_rename = TRUE
	unique_reskin = TRUE


/obj/item/gun/projectile/revolver/doublebarrel/update_gun_skins()
	add_skin("Default", "dshotgun")
	add_skin("Dark Red Finish", "dshotgun-d")
	add_skin("Ash", "dshotgun-f")
	add_skin("Faded Grey", "dshotgun-g")
	add_skin("Maple", "dshotgun-l")
	add_skin("Rosewood", "dshotgun-p")


/obj/item/gun/projectile/revolver/doublebarrel/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_box/speedloader) || istype(A, /obj/item/ammo_casing))
		chamber_round()
	if(istype(A, /obj/item/melee/energy))
		var/obj/item/melee/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/sawoff(mob/user)
	. = ..()
	weapon_weight = WEAPON_MEDIUM
	can_holster = TRUE

/obj/item/gun/projectile/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while(get_ammo(FALSE) > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(loc)
		CB.SpinAnimation(10, 1)
		CB.update_icon()
		playsound(get_turf(CB), 'sound/weapons/gun_interactions/shotgun_fall.ogg', 70, 1)
		num_unloaded++
	if(num_unloaded)
		to_chat(user, span_notice("You break open \the [src] and unload [num_unloaded] shell\s."))
	else
		to_chat(user, span_notice("[src] is empty."))

// IMPROVISED SHOTGUN //

/obj/item/gun/projectile/revolver/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	fire_sound = 'sound/weapons/gunshots/1shotgunpipe.ogg'
	sawn_desc = "I'm just here for the gasoline."
	unique_rename = FALSE
	unique_reskin = FALSE
	var/slung = FALSE

/obj/item/gun/projectile/revolver/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_state)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = SLOT_BACK
			to_chat(user, span_notice("You tie the lengths of cable to the shotgun, making a sling."))
			slung = TRUE
			update_icon()
		else
			to_chat(user, span_warning("You need at least ten lengths of cable if you want to make a sling."))
			return
	else
		return ..()


/obj/item/gun/projectile/revolver/doublebarrel/improvised/update_icon_state()
	icon_state = "ishotgun[slung ? "sling" : sawn_state == SAWN_OFF ? "-sawn" : ""]"


/obj/item/gun/projectile/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = FALSE
		update_icon()

//caneshotgun

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "cane"
	item_state = "stick"
	sawn_state = SAWN_OFF
	w_class = WEIGHT_CLASS_SMALL
	force = 10
	can_unsuppress = FALSE
	slot_flags = null
	origin_tech = "" // NO GIVAWAYS
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised/cane
	sawn_desc = "I'm sorry, but why did you saw your cane in the first place?"
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")
	fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	suppressed = TRUE
	needs_permit = FALSE //its just a cane beepsky.....

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/is_crutch()
	return TRUE

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_icon_state()
	return

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/update_overlays()
	return list()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/stack/cable_coil))
		return
	else
		return ..()

/obj/item/gun/projectile/revolver/doublebarrel/improvised/cane/examine(mob/user) // HAD TO REPEAT EXAMINE CODE BECAUSE GUN CODE DOESNT STEALTH
	var/f_name = "\a [src]."
	if(blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		f_name += span_danger("blood-stained [name]!")

	. = list("[bicon(src)] That's [f_name]")

	if(desc)
		. += desc
