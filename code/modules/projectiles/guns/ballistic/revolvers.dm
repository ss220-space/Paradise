// MARK: .38 Mars Special
/obj/item/gun/projectile/revolver/detective
	name = ".38 Mars Special"
	desc = "A cheap Martian knock-off of a classic law enforcement firearm. Uses .38-special rounds."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/detective/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

// MARK: Taurus
/obj/item/gun/projectile/revolver/taurus
	name = "Taurus revolver"
	desc = "Револьвер под калибр .45 Colt, используемый силовыми структурами \"Нанотрейзен\". \
			Отличается простотой конструкции, высокой надёжностью и минимальным количеством движущихся частей. Произведён \"Оружейной Ауссек\"."
	icon_state = "taurus"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/taurus
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_MUZZLE | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 20, "y" = 2),
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -6),
	)
	can_air_shoot = FALSE

/obj/item/gun/projectile/revolver/taurus/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/item_skins)

/obj/item/gun/projectile/revolver/taurus/get_ru_names()
	return list(
		NOMINATIVE = "револьвер \"Таурус\"",
		GENITIVE = "револьвера \"Таурус\"",
		DATIVE = "револьверу \"Таурус\"",
		ACCUSATIVE = "револьверу \"Таурус\"",
		INSTRUMENTAL = "револьвером \"Таурус\"",
		PREPOSITIONAL = "револьвере \"Таурус\"",
	)

// MARK: Finger gun (Mime)
/obj/item/gun/projectile/revolver/fingergun //Summoned by the Finger Gun spell, from advanced mimery traitor item
	name = "finger gun"
	desc = "Bang bang bang!"
	icon_state = "fingergun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible
	origin_tech = ""
	item_flags = ABSTRACT|DROPDEL
	slot_flags = NONE
	fire_sound = null
	fire_sound_text = null
	lefthand_file = null
	righthand_file = null
	can_holster = FALSE // Get your fingers out of there!
	clumsy_check = FALSE //Stole your uplink! Honk!
	needs_permit = FALSE //go away beepsky
	var/obj/effect/proc_holder/spell/mime/fingergun/parent_spell
	accuracy = GUN_ACCURACY_DEFAULT
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/fingergun/Initialize(mapload, new_parent_spell)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	parent_spell = new_parent_spell
	verbs -= /obj/item/gun/projectile/revolver/verb/spin

/obj/item/gun/projectile/revolver/fingergun/fake
	desc = "Pew pew pew!"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38/invisible/fake

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
	return ..()

/obj/item/gun/projectile/revolver/fingergun/attackby(obj/item/I, mob/user, params)
	return ATTACK_CHAIN_PROCEED

/obj/item/gun/projectile/revolver/fingergun/attack_self(mob/living/user)
	. = ..()
	if(istype(user))
		to_chat(user, span_notice("You holster your fingers. Another time."))
	qdel(src)

/obj/item/gun/projectile/revolver/fingergun/unload_act(mob/user)
	return

// MARK: Unica-6
/obj/item/gun/projectile/revolver/mateba
	name = "Unica 6 auto-revolver"
	desc = "A retro high-powered autorevolver typically used by officers of the New Russia military. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 18, "y" = 2),
	)

// MARK: Tkach Ya-Sui
/obj/item/gun/projectile/revolver/ga12
	name = "Tkach Ya-Sui GA 12 revolver"
	desc = "An outdated sidearm rarely seen in use by certain PMCs that operate throughout the frontier systems, featuring a three-shell cylinder. Thats right, shell, this one shoots twelve gauge."
	icon_state = "12garevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/ga12
	fire_sound = 'sound/weapons/gunshots/1rev12.ogg'
	fire_delay = 5
	accuracy = new /datum/gun_accuracy/pistol/extends_spread()
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_HIGH
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 16, "y" = 2),
	)

// MARK: Golder revolver
/obj/item/gun/projectile/revolver/golden
	name = "golden revolver"
	desc = "This ain't no game, ain't never been no show, And I'll gladly gun down the oldest lady you know. Uses .357 ammo."
	icon_state = "goldrevolver"
	fire_sound = 'sound/weapons/resonator_blast.ogg'
	accuracy = new /datum/gun_accuracy/pistol/extends_spread()
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Nagant
/obj/item/gun/projectile/revolver/nagant
	name = "nagant revolver"
	desc = "An old model of revolver that originated in Russia. Able to be suppressed. Uses 7.62x38mmR ammo."
	icon_state = "nagant"
	origin_tech = "combat=3"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev762
	accuracy = GUN_ACCURACY_PISTOL_UPLINK
	recoil = GUN_RECOIL_MEDIUM
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 17, "y" = 3),
	)

/obj/item/gun/projectile/revolver/nagant/rusted
	desc = "An old model of revolver that originated in Russia. This one is a real relic, rust is pouring."

/obj/item/gun/projectile/revolver/nagant/rusted/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/rusted_weapon, face_shot_max_chance = 20, destroy_max_chance = 8, malf_low_bound = 0, malf_high_bound = 3)
	AddElement(/datum/element/misfire_weapon, misfire_max_chance = 5, misfire_low_bound = 0, misfire_high_bound = 1)

// MARK: .36
/obj/item/gun/projectile/revolver/c36
	name = ".36 revolver"
	desc = "An old fashion .36 chambered revolver."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev36
	fire_sound = 'sound/weapons/gunshots/1rev38.ogg'
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_allowed = GUN_MODULE_CLASS_NONE

// MARK: Russian Roulette gun
/obj/item/gun/projectile/revolver/russian
	name = "Russian revolver"
	desc = "A Russian-made revolver for drinking games. Uses .357 ammo, and has a mechanism that spins the chamber before each trigger pull."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/rus357
	var/spun = FALSE
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	can_air_shoot = FALSE
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 19, "y" = 3),
	)

/obj/item/gun/projectile/revolver/russian/Initialize(mapload)
	. = ..()
	Spin()

/obj/item/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(FALSE, FALSE))
		chamber_round()
	spun = TRUE

/obj/item/gun/projectile/revolver/russian/attackby(obj/item/I, mob/user, params)
	if(isspeedloader(I) || isammocasing(I))
		if(get_ammo() > 0)
			to_chat(user, span_warning("The [name] can only hold a single bullet."))
			return ATTACK_CHAIN_PROCEED
		var/loaded = magazine.reload(I, user, silent = TRUE)
		if(loaded)
			user.visible_message(
				span_notice("[user] has loaded a single bullet into the revolver and spins the chamber."),
				span_notice("You have loaded a single bullet into the chamber and spin it."),
			)
			Spin()
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()

/obj/item/gun/projectile/revolver/russian/attack_self(mob/user)
	add_fingerprint(user)
	if(!spun && can_shoot(user))
		user.visible_message(
			span_notice("[user] has spinned the chamber of the revolver."),
			span_notice("You have spinned the revolver's chamber.")
		)
		Spin()
		return
	var/num_unloaded = 0
	var/atom/drop_loc = drop_location()
	while(get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round()
		chambered = null
		CB.forceMove(drop_loc)
		CB.pixel_x = rand(-10, 10)
		CB.pixel_y = rand(-10, 10)
		CB.setDir(pick(GLOB.alldirs))
		CB.update_appearance()
		CB.SpinAnimation(10, 1)
		playsound(drop_loc, CB.casing_drop_sound, 60, TRUE)
		num_unloaded++
	if(num_unloaded)
		balloon_alert(user, "[declension_ru(num_unloaded, "разряжен [num_unloaded] патрон",  "разряжено [num_unloaded] патрона",  "разряжено [num_unloaded] патронов")]")
	else
		balloon_alert(user, "уже разряжено!")

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
			balloon_alert(user, "не подходящая цель!")
		return

	if(ishuman(user))
		if(!spun)
			balloon_alert(user, "прокрутите барабан!")
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire(user, user, firer_source_atom = src))
				playsound(user, fire_sound, 50, TRUE)
				var/zone = check_zone(user.zone_selected)
				if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH)
					shoot_self(user, zone)
				else
					user.visible_message(span_danger("[user.name] cowardly fires [src] at [user.p_their()] [zone]!"), span_userdanger("You cowardly fire [src] at your [zone]!"), span_italics("You hear a gunshot!"))
				chambered.after_fire()
				return
			chambered.after_fire()

		user.visible_message(span_danger("*click*"))
		playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)

/obj/item/gun/projectile/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(span_danger("[user.name] fires [src] at [user.p_their()] head!"), span_userdanger("You fire [src] at your head!"), span_italics("You hear a gunshot!"), projectile_message = TRUE)

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

// MARK: Capgun
/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	origin_tech = null
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/cap
	accuracy = GUN_ACCURACY_PISTOL
	recoil = GUN_RECOIL_MEDIUM
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 19, "y" = 3),
	)

// MARK: Improvised .257
/obj/item/gun/projectile/revolver/improvised
	name = "improvised revolver"
	desc = "Weapon for crazy fun with friends."
	icon_state = "irevolver"
	item_state = "revolver"
	mag_type = null
	fire_sound = 'sound/weapons/gunshots/1rev257.ogg'
	var/unscrewed = TRUE
	var/obj/item/weaponcrafting/revolverbarrel/barrel
	accuracy = GUN_ACCURACY_MINIMAL
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/projectile/revolver/improvised/Initialize(mapload)
	. = ..()
	barrel = new	// I just want it to spawn with barrel.
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/update_overlays()
	. = ..()
	if(magazine)
		. += mutable_appearance('icons/obj/weapons/projectile.dmi', magazine.icon_state)
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
	user.visible_message(span_biggerdanger("*CRACK*"))
	playsound(user, 'sound/weapons/jammed.ogg', 140, TRUE)

/obj/item/gun/projectile/revolver/improvised/proc/radial_menu(mob/user)
	var/list/choices = list()

	if(barrel)
		choices["Barrel"] = image(icon = barrel.icon, icon_state = barrel.icon_state)
	if(magazine)
		choices["Magazine"] = image(icon = magazine.icon, icon_state = magazine.icon_state)
	var/choice = length(choices) == 1 ? pick(choices) : show_radial_menu(user, src, choices, require_near = TRUE)

	if(!choice || loc != user)
		return

	switch(choice)
		if("Barrel")
			if(!do_after(user, 8 SECONDS, src, NONE, category = DA_CAT_TOOL))
				return
			to_chat(user, span_notice("You unscrew [barrel] from [src]."))
			user.put_in_hands(barrel)
			barrel = null
		if("Magazine")
			to_chat(user, span_notice("You unscrew [magazine] from [src]."))
			user.put_in_hands(magazine)
			magazine = null
			verbs -= /obj/item/gun/projectile/revolver/verb/spin
	playsound(src, 'sound/items/screwdriver.ogg', 40, TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attack_hand(mob/user)
	if(loc == user && unscrewed)
		radial_menu(user)
		return
	return ..()

/obj/item/gun/projectile/revolver/improvised/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!magazine || !barrel)
		add_fingerprint(user)
		to_chat(user, span_notice("You cannot do this without cylinder and barrel, attached to the revolver."))
		return .
	to_chat(user, span_notice("You start to [unscrewed ? "assemble" : "disassemble"] the revolver..."))
	if(!I.use_tool(src, user, 8 SECONDS, volume = I.tool_volume) || !magazine || !barrel)
		return .
	unscrewed = !unscrewed
	to_chat(user, span_notice("You have [unscrewed ? "disassembled" : "assembled"] the revolver."))
	update_icon(UPDATE_OVERLAYS)

/obj/item/gun/projectile/revolver/improvised/attackby(obj/item/I, mob/user, params)
	if(!unscrewed)
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_fingerprint(user)
	if(istype(I, /obj/item/ammo_box/magazine/internal/cylinder/improvised))
		if(magazine)
			to_chat(user, span_notice("The [name] already has [magazine]."))
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		magazine = I
		verbs |= /obj/item/gun/projectile/revolver/verb/spin
		update_icon(UPDATE_OVERLAYS)
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/weaponcrafting/revolverbarrel))
		var/obj/item/weaponcrafting/revolverbarrel/new_barrel = I
		if(barrel)
			to_chat(user, span_notice("The [name] already has [barrel]."))
			return .
		to_chat(user, span_notice("You start to install [new_barrel] to [src]..."))
		if(!do_after(user, 8 SECONDS, src, NONE, category = DA_CAT_TOOL) || barrel)
			return .
		if(!user.drop_transfer_item_to_loc(new_barrel, src))
			return .
		to_chat(user, span_notice("You have installed [new_barrel] to [src]."))
		barrel = new_barrel
		fire_sound = new_barrel.new_fire_sound
		update_icon(UPDATE_OVERLAYS)
		playsound(loc, 'sound/items/screwdriver.ogg', 40, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL


//MARK: Rsh-12
/obj/item/gun/projectile/revolver/rsh_12
	name = "RSh-12"
	desc = "Крупнокалиберный револьвер под калибр 12.7х55 мм. \
			Отличается высокой убойностью и страшной отдачей. Произведён \"Оружейной Ауссек\"."
	icon_state = "rsh-12"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rsh_12
	fire_sound = 'sound/weapons/gunshots/bulldog.ogg'
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_MEGA
	attachable_allowed = GUN_MODULE_CLASS_SHOTGUN_MUZZLE | GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_PISTOL_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list("x" = 23, "y" = 1),
		ATTACHMENT_SLOT_RAIL = list("x" = 9, "y" = 8),
		ATTACHMENT_SLOT_UNDER = list("x" = 11, "y" = -5),
	)
	/// Opened state flag
	var/opened = FALSE

/obj/item/gun/projectile/revolver/rsh_12/get_ru_names()
	return list(
		NOMINATIVE = "револьвер \"РШ-12\"",
		GENITIVE = "револьвера \"РШ-12\"",
		DATIVE = "револьверу \"РШ-12\"",
		ACCUSATIVE = "револьвер \"РШ-12\"",
		INSTRUMENTAL = "револьвером \"РШ-12\"",
		PREPOSITIONAL = "револьвере \"РШ-12\"",
	)

/obj/item/gun/projectile/revolver/rsh_12/attack_self(mob/living/user)
	playsound(loc, 'sound/weapons/bombarda/pump.ogg', 60, TRUE)
	if(opened)
		opened = FALSE
		user.balloon_alert(user, "закрыто!")
	else
		opened = TRUE
		user.balloon_alert(user, "открыто!")
		unload_act(user)
	update_icon()

/obj/item/gun/projectile/revolver/rsh_12/update_icon_state()
	icon_state = "[initial(icon_state)][opened ? "_open" : ""]"

/obj/item/gun/projectile/revolver/rsh_12/can_shoot(mob/user)
	. = ..()
	if(. && opened)
		return FALSE

/obj/item/gun/projectile/revolver/rsh_12/attackby(obj/item/item, mob/user, params)
	if(!opened && isammocasing(item))
		user.balloon_alert(user, "надо открыть барабан!")
		to_chat(user, span_notice("Надо открыть барабан чтобы зарядить патрон."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/projectile/revolver/rsh_12/admin
	pb_knockback = 3
	starting_attachment_types = list(
		/obj/item/gun_module/rail/scope/collimator/pistol,
		/obj/item/gun_module/under/laser/point,
	)
