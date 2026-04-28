/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|KEEP_TOGETHER|LONG_GLIDE
	flags =  CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "materials=3;combat=3"
	needs_permit = TRUE
	attack_verb = list("ударил")
	pickup_sound = 'sound/items/handling/pickup/gun_pickup.ogg'
	drop_sound = 'sound/items/handling/drop/gun_drop.ogg'

	var/fire_sound = SFX_GUNSHOT
	var/suppressed_fire_sound = 'sound/weapons/gunshots/1suppres.ogg'
	var/magin_sound = 'sound/weapons/gun_interactions/smg_magin.ogg'
	var/magout_sound = 'sound/weapons/gun_interactions/smg_magout.ogg'
	var/fire_sound_text = "выстрел" //the fire sound that shows in chat messages: laser blast, gunshot, etc.
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	/// Firing cooldown, true if this gun shouldn't be allowed to manually fire
	var/fire_cd = 0
	var/weapon_weight = WEAPON_LIGHT
	var/list/restricted_species
	var/ninja_weapon = FALSE			//Оружия со значением TRUE обходят ограничение ниндзя на использование пушек
	var/bolt_open = FALSE
	/// Gun accuracy (without distance accuracy)
	var/datum/gun_accuracy/accuracy = GUN_ACCURACY_DEFAULT
	var/datum/gun_recoil/recoil = null
	var/barrel_dir = EAST // barel direction need for a rotate gun with telekinesis for shot to target (default: matched with tile direction)
	var/randomspread = TRUE

	/// Allows renaming with a pen
	var/unique_rename = TRUE

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	/// Guns can be placed on racks
	var/on_rack = FALSE

	/// Damage modifier for projectile
	var/damage_mod = 1
	/// Stamina modifier for projectile
	var/stamina_mod = 1

/*
 * Gun modules
 */
	///List of allowed attachments, IT MUST INCLUDE THE STARTING ATTACHMENT TYPES OR THEY WILL NOT ATTACH.
	var/attachable_allowed = 0
	///The attachments this gun starts with on Init
	var/list/starting_attachment_types = null
	///Image list of attachments overlays.
	var/list/image/attachment_overlays = list()
	///List of offsets to make attachment overlays not look wonky.
	var/list/attachable_offset = list(
		ATTACHMENT_SLOT_MUZZLE = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0),
		ATTACHMENT_SLOT_RAIL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0),
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0),
		ATTACHMENT_SLOT_SIBYL = list(ATTACHMENT_OFFSET_X = 0, ATTACHMENT_OFFSET_Y = 0)
	)
	///List of slots a gun can have.
	var/list/obj/item/gun_module/attachments_by_slot = list(
		ATTACHMENT_SLOT_MUZZLE,
		ATTACHMENT_SLOT_RAIL,
		ATTACHMENT_SLOT_UNDER,
		ATTACHMENT_SLOT_SIBYL
	)

	var/suppressed = FALSE
	var/suppress_muzzle_flash = FALSE
	var/can_suppress = 0
	var/can_unsuppress = 1
	/// Currently attached flashlight.
	var/obj/item/flashlight/seclite/gun_light

	var/can_holster = TRUE

	var/list/upgrades = list()

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/datum/action/toggle_scope_zoom/azoom

	light_on = FALSE

	/// Responsible for the range of the throwing back when shooting at point blank range
	var/pb_knockback = 0
	/// Point blank shot cooldown
	var/pb_cooldown_duration = 3 SECONDS
	COOLDOWN_DECLARE(pb_cooldown)
	/// Shots counter
	var/shots_counter = 0

/obj/item/gun/Initialize(mapload)
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	build_zooming()
	create_start_gun_modules()
	if(islist(accuracy))
		accuracy = getAccuracy(arglist(accuracy))
	else if(!accuracy)
		accuracy = GUN_ACCURACY_DEFAULT
	else if(!istype(accuracy, /datum/gun_accuracy))
		stack_trace("Invalid type [accuracy.type] found in .accuracy during /obj/item/gun Initialize()")

/obj/item/gun/Destroy()
	QDEL_NULL(gun_light)
	for(var/attachment in attachments_by_slot)
		if(!attachments_by_slot[attachment])
			continue
		qdel(attachments_by_slot[attachment])
	LAZYCLEARLIST(attachments_by_slot)
	LAZYCLEARLIST(attachment_overlays)
	QDEL_NULL(azoom)
	QDEL_NULL(chambered)
	if(accuracy)
		QDEL_NULL(accuracy)
	if(recoil)
		QDEL_NULL(recoil)
	return ..()

/obj/item/gun/handle_atom_del(atom/target)
	if(target == gun_light)
		set_gun_light(null)
	return ..()

/obj/item/gun/examine(mob/user)
	. = ..()
	if(attachments_by_slot[ATTACHMENT_SLOT_RAIL])
		. += span_notice("На прицельную планку прикреплен [attachments_by_slot[ATTACHMENT_SLOT_RAIL].declent_ru(NOMINATIVE)].")
	else if(attachable_allowed & GUN_MODULE_CLASS_RIFLE_RAIL)
		. += span_notice("Имеет большое крепление для прицелов. Можно установить все виды прицелов.")
	if(attachable_allowed & GUN_MODULE_CLASS_SHOTGUN_RAIL)
		. += span_notice("Имеет среднее крепление для прицелов. Подойдут большинство прицелов и коллиматоров.")
	else if(attachable_allowed & GUN_MODULE_CLASS_PISTOL_RAIL)
		. += span_notice("Имеет малое крепление для прицелов. Подойдут только маленькие коллиматоры.")

	if(attachments_by_slot[ATTACHMENT_SLOT_MUZZLE])
		. += span_notice("На ствол прикручен [attachments_by_slot[ATTACHMENT_SLOT_MUZZLE].declent_ru(NOMINATIVE)].")
	else if(attachable_allowed & GUN_MODULE_CLASS_ANY_MUZZLE)
		. += span_notice("Имеет нарезы для крепления наствольных модулей.")

	if(attachments_by_slot[ATTACHMENT_SLOT_UNDER])
		. += span_notice("К цевью прикреплен [attachments_by_slot[ATTACHMENT_SLOT_UNDER].declent_ru(NOMINATIVE)].")
	else if(attachable_allowed & GUN_MODULE_CLASS_PISTOL_UNDER)
		. += span_notice("Имеет маленькую планку на цевье для крепление пистолетного фонаря.")
	else if(attachable_allowed & (GUN_MODULE_CLASS_RIFLE_UNDER|GUN_MODULE_CLASS_SHOTGUN_UNDER))
		. += span_notice("Имеет большую планку на цевье для крепление большого фонаря или рукоятки.")

	if(unique_rename)
		. += span_notice("Используйте ручку чтобы переименовать его.")


/obj/item/gun/update_overlays()
	. = ..()
	for(var/slot, overlay_value in attachment_overlays)
		var/image/overlay = overlay_value
		if(!overlay)
			continue
		. += overlay

/obj/item/gun/proc/add_attachment_overlay(obj/item/gun_module/module)
	var/image/overlay = module.create_overlay()
	if(overlay && attachable_offset)
		apply_attachment_offset(module.slot, overlay, module)
	attachment_overlays[module.slot] = overlay
	update_icon()

/obj/item/gun/proc/update_attachment_overlays()
	for(var/slot, overlay in attachment_overlays)
		var/image/overlay_img = overlay
		if(!overlay_img)
			continue
		var/obj/item/gun_module/module = attachments_by_slot[slot]
		apply_attachment_offset(slot, overlay_img, module)

/obj/item/gun/proc/apply_attachment_offset(slot, image/overlay_img, obj/item/gun_module/module)
	var/x_offset = attachable_offset[slot][ATTACHMENT_OFFSET_X]
	var/y_offset = attachable_offset[slot][ATTACHMENT_OFFSET_Y]
	if(module.overlay_offset)
		x_offset += module.overlay_offset[ATTACHMENT_OFFSET_X]
		y_offset += module.overlay_offset[ATTACHMENT_OFFSET_Y]
	overlay_img.pixel_w = x_offset
	overlay_img.pixel_z = y_offset

/obj/item/gun/proc/remove_attachment_overlay(obj/item/gun_module/module)
	if(attachment_overlays[module.slot])
		attachment_overlays[module.slot] = null
	update_icon()

/obj/item/gun/proc/create_start_gun_modules()
	if(!starting_attachment_types)
		return
	for(var/module_path in starting_attachment_types)
		if(!ispath(module_path, /obj/item/gun_module))
			continue
		var/obj/item/gun_module/module = new module_path(src)
		attachments_by_slot[module.slot] = module
		add_attachment_overlay(module)
		module.gun = src
		module.on_attach(src, null)
		SEND_SIGNAL(src, COMSIG_GUN_MODULE_ATTACH, null, src, module)

//called after the gun has successfully fired its chambered ammo.
/obj/item/gun/proc/process_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	handle_chamber(empty_chamber, from_firing, chamber_next_round)
	SEND_SIGNAL(src, COMSIG_GUN_CHAMBER_PROCESSED)

/obj/item/gun/proc/handle_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE)
	return

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot(mob/user)
	return TRUE

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, span_danger("*клик*"))
	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)

/obj/item/gun/proc/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	if(pointblank && !COOLDOWN_FINISHED(src, pb_cooldown))
		pointblank = FALSE

	do_recoil(user, target)

	if(!chambered)
		return

	var/muzzle_range = chambered.muzzle_flash_range
	var/muzzle_strength = chambered.muzzle_flash_strength
	var/muzzle_flash_time = 0.2 SECONDS
	if(suppress_muzzle_flash)
		muzzle_range *= 0.5
		muzzle_strength *= 0.2
		muzzle_flash_time *= 0.5
	if(suppressed)
		playsound(user, suppressed_fire_sound, 30, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	else
		playsound(user, fire_sound, 50, TRUE)
		if(message)
			if(pointblank)
				do_pointblank_shot(user, target)
			else
				user.visible_message(span_danger("[user] стреля[PLUR_ET_YUT(user)] из [declent_ru(GENITIVE)]!"), span_danger("Вы стреляете из [declent_ru(GENITIVE)]!"), "Вы слышите [fire_sound_text]!", projectile_message = TRUE)
	if(chambered.muzzle_flash_effect)
		var/obj/effect/temp_visual/target_angled/muzzle_flash/effect = new chambered.muzzle_flash_effect(get_turf(src), target, muzzle_flash_time)
		effect.alpha = min(255, muzzle_strength * 255)
		if(chambered.muzzle_flash_color)
			effect.color = chambered.muzzle_flash_color
			effect.set_light_range_power_color(muzzle_range, muzzle_strength, chambered.muzzle_flash_color)
		else
			effect.color = LIGHT_COLOR_TUNGSTEN


/obj/item/gun/proc/do_pointblank_shot(mob/living/user, atom/target)
	user.visible_message(span_danger("[user] стреля[PLUR_ET_YUT(user)] из [declent_ru(GENITIVE)] в упор в [target]!"), span_danger("Вы стреляете из [declent_ru(GENITIVE)] в упор в [target]!"), span_italics("Вы слышите [fire_sound_text]!"), projectile_message = TRUE)
	if(pb_knockback > 0 && isliving(target))
		do_pb_knockback(user, target)

/obj/item/gun/proc/do_pb_knockback(mob/living/user, mob/living/target)
	if(target.move_resist > MOVE_FORCE_NORMAL) // no knockbacking prince of terror or somethin
		return
	COOLDOWN_START(src, pb_cooldown, pb_cooldown_duration)
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, pb_knockback, 2)

/obj/item/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/gun/afterattack(atom/target, mob/living/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(firing_burst)
		return
	if(proximity_flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != BODY_ZONE_PRECISE_MOUTH) //so we can't shoot ourselves (unless mouth selected)
			return

	if(!can_trigger_gun(user))
		return

	if(proximity_flag)
		if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
			if(target == user && HAS_TRAIT(user, TRAIT_BADASS))
				user.visible_message(span_danger("[user] сдул[GEND_A_O_I(user)] дым с дула [declent_ru(GENITIVE )]. Как же [GEND_HE_SHE(user)] хорош[GEND_A_O_I(user)]!"))
			else
				handle_suicide(user, target, modifiers)
			return

	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		to_chat(user, span_userdanger("Вы случайно прострелили себе ногу из [declent_ru(GENITIVE )]!"))
		var/shot_leg = pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
		process_fire(user, user, 0, modifiers, zone_override = shot_leg)
		user.drop_from_active_hand()
		return

	if(!HAS_TRAIT(user, TRAIT_BADASS) && weapon_weight == WEAPON_HEAVY && (user.get_inactive_hand() || !user.has_inactive_hand() || (user.pulling && user.pull_hand != PULL_WITHOUT_HANDS)))
		to_chat(user, span_userdanger("Для стрельбы из [declent_ru(GENITIVE )] нужны две свободные руки!"))
		return

	//DUAL WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/gun/G in get_both_hands(H))
			if(G == src || (!HAS_TRAIT(user, TRAIT_BADASS) && G.weapon_weight >= WEAPON_MEDIUM))
				continue
			else if(G.can_trigger_gun(user))
				if(!HAS_TRAIT(user, TRAIT_BADASS))
					bonus_spread += accuracy.dual_wield_spread * G.weapon_weight
				loop_counter++
				addtimer(CALLBACK(G, PROC_REF(process_fire), target, user, 1, modifiers, null, bonus_spread), loop_counter)
	//CLOWN CHECK
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		bonus_spread += 45

	process_fire(target, user, 1, modifiers, null, bonus_spread)

/obj/item/gun/proc/can_trigger_gun(mob/living/user)
	if(istype(user))
		if(!user.can_use_guns(src))
			return FALSE

		if(restricted_species && length(restricted_species) && !is_type_in_list(user.dna.species, restricted_species))
			to_chat(user, span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] несовместим с вашей биологией!"))
			return FALSE

	if(!can_shoot(user)) //Just because you can pull the trigger doesn't mean it can't shoot.
		shoot_with_empty_chamber(user)
		return FALSE
	return TRUE

/obj/item/gun/proc/newshot()
	return

/obj/item/gun/proc/process_fire(atom/target, mob/living/user, message = TRUE, list/modifiers, zone_override, bonus_spread = 0)
	var/is_tk_grab = !isnull(user.tkgrabbed_objects[src])
	if(is_tk_grab) // don't add fingerprints if gun is hold by telekinesis grab
		add_fingerprint(user)

	if(chambered)
		chambered.leave_residue(user)

	if(fire_cd)
		return

	var/is_left_hand = user.l_hand == src
	bonus_spread += user.get_fracture_spread_bonus(is_left_hand)
	if(user.buckled)
		bonus_spread += 45

	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target)
	var/sprd = 0

	if(is_tk_grab)
		rotate_to_target(target)

	if(burst_size > 1)
		if(chambered?.harmful)
			if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				to_chat(user, span_warning("В [declent_ru(ACCUSATIVE)] заряжены смертельные патроны! Лучше не рисковать..."))
				return
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if(i>1 && !(src in get_both_hands(user))) //for burst firing
					break
			if(chambered)
				if(randomspread)
					sprd = accuracy.randomize_spread(user, bonus_spread)
				else
					sprd = round((i / burst_size - 0.5) * accuracy.randomize_spread(user, bonus_spread))
				if(!chambered.fire(target = target, user = user, modifiers = modifiers, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src, damage_mod = damage_mod, stamina_mod = stamina_mod))
					shoot_with_empty_chamber(user)
					break
				else
					if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
						shoot_live_shot(user, target, TRUE, message)
					else
						shoot_live_shot(user, target, FALSE, message)
				if(chambered)
					chambered.after_fire()
			else
				shoot_with_empty_chamber(user)
				break
			process_chamber()
			update_icon()
			sleep(fire_delay)
		firing_burst = 0
	else
		if(chambered)
			if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				if(chambered.harmful) // Is the bullet chambered harmful?
					to_chat(user, span_warning("В [declent_ru(ACCUSATIVE)] заряжены смертельные патроны! Лучше не рисковать..."))
					return
			sprd = accuracy.randomize_spread(user, bonus_spread)
			if(!chambered.fire(target = target, user = user, modifiers = modifiers, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src, damage_mod = damage_mod, stamina_mod = stamina_mod))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, target, TRUE, message)
				else
					shoot_live_shot(user, target, FALSE, message)
			if(chambered)
				chambered.after_fire()
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber()
		update_icon()
		fire_cd = TRUE
		spawn(fire_delay)
			fire_cd = FALSE

	if(user)
		user.update_held_items()
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	shots_counter += burst_size
	SEND_SIGNAL(src, COMSIG_GUN_AFTER_PROCESS_FIRE, target, user)

/obj/item/gun/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(azoom)
		zoom(user)
		return
	. = ..()

/obj/item/gun/attack(mob/living/target, mob/living/user, list/modifiers, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM)
		return ATTACK_CHAIN_BLOCKED
	return ..()

/obj/item/gun/attackby(obj/item/I, mob/user, list/modifiers)
	if(is_pen(I))
		if(!unique_rename)
			add_fingerprint(user)
			to_chat(user, span_warning("Вы не можете переименовать [declent_ru(ACCUSATIVE)]!"))
			return ATTACK_CHAIN_BLOCKED_ALL
		var/new_name = rename_interactive(user, I, use_prefix = FALSE)
		if(!isnull(new_name))
			to_chat(user, span_notice("Вы переименовываете \"[name]\". Познакомьтесь со своим новым другом."))
		return ATTACK_CHAIN_BLOCKED

	if(istype(I, /obj/item/gun_module))
		add_fingerprint(user)
		var/obj/item/gun_module/module = I
		if(module.try_attach(src, user))
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_gunlight))
		toggle_gunlight()
		return TRUE
	return ..()

/obj/item/gun/proc/toggle_gunlight_verb()
	set name = "Оружейный фонарик"
	set category = VERB_CATEGORY_OBJECT
	set desc = "Click to toggle your weapon's attached flashlight."

	toggle_gunlight(usr)

/obj/item/gun/proc/toggle_gunlight(mob/user, silent = FALSE)
	if(!gun_light)
		return

	if(user && !isturf(user.loc))
		if(!silent)
			to_chat(user, span_warning("Вы не можете переключить фонарь, находясь в [user.loc]!"))
		return

	gun_light.on = !gun_light.on
	if(!silent)
		playsound(loc, 'sound/weapons/empty.ogg', 100, TRUE)
		if(user)
			to_chat(user, span_notice("Вы переключаете фонарь: [gun_light.on ? "вкл": "выкл"]."))
	gun_light.set_light_on(gun_light.on)
	SEND_SIGNAL(src, COMSIG_GUN_LIGHT_TOGGLE, user)
	update_icon(UPDATE_OVERLAYS)
	update_equipped_item(update_speedmods = FALSE)

/// Sets gun's flashlight and do all the necessary updates
/obj/item/gun/proc/set_gun_light(obj/item/flashlight/seclite/new_light)
	if(gun_light == new_light)
		return

	if(new_light && !istype(new_light))
		CRASH("Wrong object passed as an argument ([isdatum(new_light) ? "[new_light.type]" : "[new_light]"])")

	. = gun_light
	gun_light = new_light

	if(gun_light)
		gun_light.set_light_flags(gun_light.light_flags | LIGHT_ATTACHED)
		verbs |= /obj/item/gun/proc/toggle_gunlight_verb
		if(gun_light.loc != src)
			gun_light.forceMove(src)
		var/datum/action/item_action/toggle_gunlight/toggle_gunlight_action = locate() in actions
		if(!toggle_gunlight_action)
			toggle_gunlight_action = new(src)
			add_item_action(toggle_gunlight_action)
	else
		verbs -= /obj/item/gun/proc/toggle_gunlight_verb

		var/datum/action/item_action/toggle_gunlight/toggle_gunlight_action = locate() in actions
		if(toggle_gunlight_action)
			remove_item_action(toggle_gunlight_action)
			qdel(toggle_gunlight_action)

		if(.)
			var/obj/item/flashlight/seclite/old_gun_light = .
			old_gun_light.set_light_flags(old_gun_light.light_flags & ~LIGHT_ATTACHED)
			if(old_gun_light.loc == src)
				old_gun_light.forceMove(get_turf(src))
			old_gun_light.update_brightness()

	update_icon(UPDATE_OVERLAYS)
	update_equipped_item(update_speedmods = FALSE)

/obj/item/gun/extinguish_light(force = FALSE)
	if(gun_light?.on)
		toggle_gunlight(silent = TRUE)
		visible_message(span_danger("Фонарь [declent_ru(GENITIVE)] гаснет."))

/obj/item/gun/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	zoom(user, FALSE)
	if(azoom)
		azoom.Remove(user)

/obj/item/gun/click_alt(mob/user)
	if(loc != user)
		return NONE
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("Вы не можете сделать это сейчас!"))
		return CLICK_ACTION_BLOCKING
	try_detach_gun_module(user)
	return CLICK_ACTION_SUCCESS

/obj/item/gun/proc/try_detach_gun_module(mob/user)
	. = FALSE
	var/list/choices = list()
	for(var/slot in attachments_by_slot)
		if(!attachments_by_slot[slot])
			continue
		var/obj/item/gun_module/module = attachments_by_slot[slot]
		if(module.can_detach)
			choices[module.declent_ru(NOMINATIVE)] = image(icon = module.icon, icon_state = module.icon_state)
	if(length(choices) == 0)
		return
	var/choice = choices[1]
	if(length(choices) > 1)
		choice = show_radial_menu(user, src, choices, require_near = TRUE)
	if(!choice)
		return FALSE
	for(var/slot in attachments_by_slot)
		if(!attachments_by_slot[slot])
			continue
		var/obj/item/gun_module/module = attachments_by_slot[slot]
		if(module.declent_ru(NOMINATIVE) == choice)
			return module.detach_without_check(src, user)


/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, list/modifiers)
	if(!ishuman(user) || !ishuman(target))
		return

	if(fire_cd)
		return

	if(user == target)
		target.visible_message(
			span_warning("[user] вставля[PLUR_ET_YUT(user)] ствол [declent_ru(GENITIVE)] себе в рот, готовясь нажать на спуск..."),
			span_userdanger("Вы вставляете ствол [declent_ru(GENITIVE)] себе в рот, готовясь нажать на спуск..."),
		)
	else
		target.visible_message(
			span_warning("[user] направля[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] в голову [target], готовясь выстрелить..."),
			span_userdanger("[user] направля[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)] вам в голову, готовясь выстрелить..."),
		)

	fire_cd = TRUE

	if(!do_after(user, 12 SECONDS, target, NONE) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		if(user)
			if(user == target)
				user.visible_message(
					span_notice("[user] реша[PLUR_ET_YUT(user)], что жить всё-таки хочется."),
				)
			else if(target && target.Adjacent(user))
				target.visible_message(
					span_notice("[user] реша[PLUR_ET_YUT(user)] пощадить [target]."),
					span_notice("[user] реша[PLUR_ET_YUT(user)] оставить вас в живых!"),
				)
		fire_cd = FALSE
		return

	fire_cd = FALSE

	target.visible_message(
		span_warning("[user] нажима[PLUR_ET_YUT(user)] на спусковой крючок!"),
		span_userdanger("[user] нажима[PLUR_ET_YUT(user)] на спусковой крючок!")
	)

	if(chambered?.BB)
		chambered.BB.damage *= 15

	var/fired = process_fire(target, user, TRUE, modifiers, BODY_ZONE_HEAD)
	if(!fired && chambered?.BB)
		chambered.BB.damage /= 15

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Масштаб"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	button_icon_state = "sniper_zoom"
	var/obj/item/gun/gun = null

/datum/action/toggle_scope_zoom/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable(feedback = FALSE)
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	if(gun)
		gun.zoom(L, FALSE)
	..()

/datum/action/toggle_scope_zoom/Destroy()
	gun = null
	return ..()

/obj/item/gun/proc/zoom(mob/living/user, forced_zoom)
	if(!user || !user.client)
		return

	var/old_zoomed = zoomed
	switch(forced_zoom)
		if(FALSE)
			zoomed = FALSE
		if(TRUE)
			zoomed = TRUE
		else
			zoomed = !zoomed

	if(old_zoomed != zoomed) // Send signal only if zoomed state changed!
		SEND_SIGNAL(src, COMSIG_GUN_ZOOM_TOGGLE, user, zoomed)

	if(zoomed)
		var/_x = 0
		var/_y = 0
		switch(user.dir)
			if(NORTH)
				_y = zoom_amt
			if(EAST)
				_x = zoom_amt
			if(SOUTH)
				_y = -zoom_amt
			if(WEST)
				_x = -zoom_amt

		user.client.pixel_x = ICON_SIZE_X*_x
		user.client.pixel_y = ICON_SIZE_Y*_y

		for(var/mob/dead/observer/observe in user.inventory_observers)
			if(!observe.client)
				LAZYREMOVE(user.inventory_observers, observe)
				continue
			observe.client.pixel_x = ICON_SIZE_X*_x
			observe.client.pixel_y = ICON_SIZE_Y*_y
	else
		user.client.pixel_x = 0
		user.client.pixel_y = 0

		for(var/mob/dead/observer/observe in user.inventory_observers)
			if(!observe.client)
				LAZYREMOVE(user.inventory_observers, observe)
				continue
			observe.client.pixel_x = 0
			observe.client.pixel_y = 0

//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src
		RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(ZoomGrantCheck))

/obj/item/gun/proc/destroy_zooming()
	if(!azoom)
		return
	if(zoomable)
		return
	QDEL_NULL(azoom)
	UnregisterSignal(src, COMSIG_ITEM_EQUIPPED)

/**
 * Proc which will be called when the gun receives the `COMSIG_ITEM_EQUIPPED` signal.
 *
 * This happens if the mob picks up the gun, or equips it to any of their slots.
 * If the slot is anything other than either of their hands (such as the back slot), un-zoom them, and `Remove` the zoom action button from the mob.
 * Otherwise, `Grant` the mob the zoom action button.
 *
 * Arguments:
 * * source - the gun that got equipped, which is `src`.
 * * user - the mob equipping the gun.
 * * slot - the slot the gun is getting equipped to.
 */
/obj/item/gun/proc/ZoomGrantCheck(datum/source, mob/user, slot)
	// Checks if the gun got equipped into either of the user's hands.
	if(!(slot & ITEM_SLOT_HANDS))
		// If its not in their hands, un-zoom, and remove the zoom action button.
		zoom(user, FALSE)
		azoom.Remove(user)
		return FALSE

	// The gun is equipped in their hands, give them the zoom ability.
	azoom.Grant(user)

/obj/item/gun/proc/place_on_rack()
	on_rack = TRUE
	var/matrix/M = matrix()
	M.Turn(-90)
	transform = M
	barrel_dir = NORTH

/obj/item/gun/proc/remove_from_rack()
	var/matrix/M = matrix()
	transform = M
	on_rack = FALSE
	barrel_dir = EAST

// rotating the gun to targer for a shot with telekinesis
/obj/item/gun/proc/rotate_to_target(atom/target)
	setDir(barrel_dir)
	var/upd_dir = get_dir(src, target)
	if(barrel_dir == upd_dir)
		return
	var/angle = dir2angle(upd_dir) - dir2angle(barrel_dir)
	if(angle > 180)
		angle -= 360
	var/matrix/M = matrix(transform)
	M.Turn(angle)
	animate(src, transform = M, time = 2)
	barrel_dir = upd_dir

// if the gun have rotate transformation - reset it
/obj/item/gun/proc/reset_direction()
	if(barrel_dir == EAST)
		return
	var/matrix/M = matrix()
	transform = M
	barrel_dir = EAST

/obj/item/gun/pickup(mob/user)
	. = ..()
	if(on_rack)
		remove_from_rack()
	else
		reset_direction()

/obj/item/gun/equipped(mob/user, slot, initial)
	reset_direction()
	return ..()
