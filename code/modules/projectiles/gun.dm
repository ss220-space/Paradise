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
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	needs_permit = 1
	attack_verb = list("struck", "hit", "bashed")
	pickup_sound = 'sound/items/handling/gun_pickup.ogg'
	drop_sound = 'sound/items/handling/gun_drop.ogg'

	var/fire_sound = "gunshot"
	var/magin_sound = 'sound/weapons/gun_interactions/smg_magin.ogg'
	var/magout_sound = 'sound/weapons/gun_interactions/smg_magout.ogg'
	var/fire_sound_text = "gunshot" //the fire sound that shows in chat messages: laser blast, gunshot, etc.
	var/suppressed = 0					//whether or not a message is displayed when fired
	var/can_suppress = 0
	var/can_unsuppress = 1
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = 1
	var/obj/item/ammo_casing/chambered = null
	var/trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_state = SAWN_INTACT
	var/burst_size = 1					//how large a burst is
	var/fire_delay = 0					//rate of fire for burst firing and semi auto
	var/firing_burst = 0				//Prevent the weapon from firing again while already firing
	var/semicd = 0						//cooldown handler
	var/weapon_weight = WEAPON_LIGHT
	///Additional spread when dual wielding.
	var/dual_wield_spread = 24
	var/list/restricted_species
	var/ninja_weapon = FALSE 			//Оружия со значением TRUE обходят ограничение ниндзя на использование пушек
	var/bolt_open = FALSE
	var/spread = 0
	var/barrel_dir = EAST // barel direction need for a rotate gun with telekinesis for shot to target (default: matched with tile direction)
	var/randomspread = TRUE

	/// Allows renaming with a pen
	var/unique_rename = TRUE
	/// Allows reskinning
	var/unique_reskin = FALSE
	/// The skin choice if we had a reskin
	var/current_skin
	/// Lazy list of gun visual skins. Filled on Initialize() in proc/update_gun_skins()
	var/list/skin_options

	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'

	/// Whether user can attach/detach flashlights to/from this gun.
	var/can_flashlight = FALSE
	/// Currently attached flashlight.
	var/obj/item/flashlight/seclite/gun_light
	/// Specified icon_state used to show flashlight overlay on this gun.
	var/gun_light_overlay
	/// Offsets flashlight's overlay pixel_x by this value.
	var/flight_x_offset = 0
	/// Offsets flashlight's overlay pixel_y by this value.
	var/flight_y_offset = 0

	/// Whether user can attach/detach bayonets to/from this gun.
	var/can_bayonet = FALSE
	/// Currently attached bayonet.
	var/obj/item/kitchen/knife/bayonet
	/// Currently used bayonet overlay.
	var/mutable_appearance/bayonet_overlay
	/// Offsets bayonet's overlay pixel_x by this value.
	var/bayonet_x_offset = 0
	/// Offsets bayonet's overlay pixel_y by this value.
	var/bayonet_y_offset = 0

	var/can_holster = TRUE

	var/list/upgrades = list()

	var/ammo_x_offset = 0 //used for positioning ammo count overlay on sprite
	var/ammo_y_offset = 0

	//Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/datum/action/toggle_scope_zoom/azoom

	//Rusted
	var/rusted_weapon = FALSE
	var/self_shot_divisor = 3 // higher value means more shots in the face
	var/malf_low_bound = 40 // shots before gun exploding
	var/malf_high_bound = 80
	var/malf_counter // random number between malf_low_bound and malf_high_bound

	light_on = FALSE

	/// Responsible for the range of the throwing back when shooting at point blank range
	var/pb_knockback = 0


/obj/item/gun/Initialize()
	. = ..()
	appearance_flags |= KEEP_TOGETHER
	build_zooming()
	if(rusted_weapon)
		malf_counter = rand(malf_low_bound, malf_high_bound)
	update_gun_skins()


/obj/item/gun/Destroy()
	QDEL_NULL(gun_light)
	QDEL_NULL(bayonet)
	return ..()


/obj/item/gun/handle_atom_del(atom/target)
	if(target == bayonet)
		set_bayonet(null)
	else if(target == gun_light)
		set_gun_light(null)
	return ..()


/obj/item/gun/examine(mob/user)
	. = ..()
	if(unique_reskin)
		. += "<span class='info'>Alt-click it to reskin it.</span>"
	if(unique_rename)
		. += "<span class='info'>Use a pen on it to rename it.</span>"
	if(bayonet)
		. += "<span class='notice'>It has \a [bayonet] [can_bayonet ? "" : "permanently "]affixed to it.</span>"
		if(can_bayonet) //if it has a bayonet and this is false, the bayonet is permanent.
			. += "<span class='info'>[bayonet] looks like it can be <b>unscrewed</b> from [src].</span>"
	else if(can_bayonet)
		. += "<span class='notice'>It has a <b>bayonet</b> lug on it.</span>"


/obj/item/gun/proc/update_gun_skins()
	return


/**
 * Adds skin in associative lazy list: skin_options[skin_name] = skin_icon_state
 *
 * Arguments:
 * * skin_name - what skin name user will see.
 * * skin_icon_state - which icon_state will be used for the gun.
 */
/obj/item/gun/proc/add_skin(skin_name, skin_icon_state)
	if(!unique_reskin)
		return
	LAZYSET(skin_options, skin_name, skin_icon_state)


/obj/item/gun/proc/process_chamber()
	return FALSE

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot(mob/user)
	return TRUE

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, span_danger("*click*"))
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)

/obj/item/gun/proc/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	var/muzzle_range = chambered.muzzle_flash_range
	var/muzzle_strength = chambered.muzzle_flash_strength
	var/muzzle_flash_time = 0.2 SECONDS
	if(suppressed)
		playsound(user, fire_sound, 10, TRUE, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
		muzzle_range *= 0.5
		muzzle_strength *= 0.2
		muzzle_flash_time *= 0.5
	else
		playsound(user, fire_sound, 50, TRUE)
		if(message)
			if(pointblank)
				user.visible_message("<span class='danger'>[user] fires [src] point blank at [target]!</span>", "<span class='danger'>You fire [src] point blank at [target]!</span>", "<span class='italics'>You hear \a [fire_sound_text]!</span>")
				if(pb_knockback > 0 && isliving(target))
					var/mob/living/living_target = target
					if(!(living_target.move_resist > MOVE_FORCE_NORMAL)) //no knockbacking prince of terror or somethin
						var/atom/throw_target = get_edge_target_turf(living_target, user.dir)
						living_target.throw_at(throw_target, pb_knockback, 2)
			else
				user.visible_message("<span class='danger'>[user] fires [src]!</span>", "<span class='danger'>You fire [src]!</span>", "You hear \a [fire_sound_text]!")
	if(chambered.muzzle_flash_effect)
		var/obj/effect/temp_visual/target_angled/muzzle_flash/effect = new chambered.muzzle_flash_effect(get_turf(src), target, muzzle_flash_time)
		effect.alpha = min(255, muzzle_strength * 255)
		if(chambered.muzzle_flash_color)
			effect.color = chambered.muzzle_flash_color
			effect.set_light_range_power_color(muzzle_range, muzzle_strength, chambered.muzzle_flash_color)
		else
			effect.color = LIGHT_COLOR_TUNGSTEN

/obj/item/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	if(firing_burst)
		return
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return

	if(!can_trigger_gun(user))
		return

	if(flag)
		if(user.zone_selected == "mouth")
			if(target == user && HAS_TRAIT(user, TRAIT_BADASS))
				user.visible_message("<span class='danger'>[user] blows smoke off of [src]'s barrel. What a badass.</span>")
			else
				handle_suicide(user, target, params)
			return

	//Exclude lasertag guns from the CLUMSY check.
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
		to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with \the [src]!</span>")
		var/shot_leg = pick(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)
		process_fire(user, user, 0, params, zone_override = shot_leg)
		user.drop_from_active_hand()
		return

	if(weapon_weight == WEAPON_HEAVY && (user.get_inactive_hand() || !user.has_inactive_hand() || (user.pulling && user.pull_hand != PULL_WITHOUT_HANDS)))
		to_chat(user, "<span class='userdanger'>You need both hands free to fire \the [src]!</span>")
		return

	//DUAL WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0
	if(ishuman(user) && user.a_intent == INTENT_HARM)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/gun/G in get_both_hands(H))
			if(G == src || G.weapon_weight >= WEAPON_MEDIUM)
				continue
			else if(G.can_trigger_gun(user))
				if(!HAS_TRAIT(user, TRAIT_BADASS))
					bonus_spread += dual_wield_spread * G.weapon_weight
				loop_counter++
				addtimer(CALLBACK(G, PROC_REF(process_fire), target, user, 1, params, null, bonus_spread), loop_counter)

	process_fire(target,user,1,params, null, bonus_spread)


/obj/item/gun/proc/can_trigger_gun(mob/living/user)
	if(istype(user))
		if(!user.can_use_guns(src))
			return FALSE

		if(restricted_species && restricted_species.len && !is_type_in_list(user.dna.species, restricted_species))
			to_chat(user, span_danger("[src] is incompatible with your biology!"))
			return FALSE

	if(!can_shoot(user)) //Just because you can pull the trigger doesn't mean it can't shoot.
		shoot_with_empty_chamber(user)
		return FALSE
	return TRUE


/obj/item/gun/proc/newshot()
	return

/obj/item/gun/proc/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	var/is_tk_grab = !isnull(user.tkgrabbed_objects[src])
	if(is_tk_grab) // don't add fingerprints if gun is hold by telekinesis grab
		add_fingerprint(user)

	if(chambered)
		chambered.leave_residue(user)

	if(semicd)
		return

	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target)
	var/sprd = 0
	var/randomized_gun_spread = 0
	if(spread)
		randomized_gun_spread =	rand(0,spread)
	var/randomized_bonus_spread = rand(0, bonus_spread)

	if (is_tk_grab)
		rotate_to_target(target)

	if(burst_size > 1)
		if(chambered && chambered.harmful)
			if(HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
				to_chat(user, span_warning("[src] is lethally chambered! You don't want to risk harming anyone..."))
				return
		firing_burst = 1
		for(var/i = 1 to burst_size)
			if(!user)
				break
			if(!issilicon(user))
				if( i>1 && !(src in get_both_hands(user))) //for burst firing
					break
			if(chambered)
				if(randomspread)
					sprd = round((rand() - 0.5) * (randomized_gun_spread + randomized_bonus_spread))
				else
					sprd = round((i / burst_size - 0.5) * (randomized_gun_spread + randomized_bonus_spread))
				if(!chambered.fire(target = target, user = user, params = params, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src))
					shoot_with_empty_chamber(user)
					break
				else
					if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
						shoot_live_shot(user, target, TRUE, message)
					else
						shoot_live_shot(user, target, FALSE, message)
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
					to_chat(user, span_warning("[src] is lethally chambered! You don't want to risk harming anyone..."))
					return
			sprd = round((pick(1,-1)) * (randomized_gun_spread + randomized_bonus_spread))
			if(!chambered.fire(target = target, user = user, params = params, distro = null, quiet = suppressed, zone_override = zone_override, spread = sprd, firer_source_atom = src))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, target, TRUE, message)
				else
					shoot_live_shot(user, target, FALSE, message)
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber()
		update_icon()
		semicd = 1
		spawn(fire_delay)
			semicd = 0

	if(user)
		if(user.hand)
			user.update_inv_l_hand()
		else
			user.update_inv_r_hand()
	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

	if(rusted_weapon)
		malf_counter -= burst_size
		// if the gun grabbed by telekinesis, it's can exploise but without damage for user
		if (user.tkgrabbed_objects[src])
			if (malf_counter <= 0 && prob(50))
				user.drop_item_ground(user.tkgrabbed_objects[src])
				new /obj/effect/decal/cleanable/ash(loc)
				to_chat(user, span_userdanger("WOAH! [src] blows up!"))
				playsound(user, 'sound/effects/explosion1.ogg', 30, TRUE)
				qdel(src)
				return FALSE
			return TRUE
		if(malf_counter <= 0 && prob(50))
			new /obj/effect/decal/cleanable/ash(user.loc)
			user.take_organ_damage(0, 30)
			user.flash_eyes()
			to_chat(user, span_userdanger("WOAH! [src] blows up in your hands!"))
			playsound(user, 'sound/effects/explosion1.ogg', 30, TRUE)
			qdel(src)
			return FALSE
		if(prob(40 - (malf_counter > 0 ? round(malf_counter / self_shot_divisor) : 0)))
			playsound(user, fire_sound, 30, TRUE)
			to_chat(user, span_userdanger("[src] blows up in your face!"))
			user.take_organ_damage(0, 10)
			return FALSE


/obj/item/gun/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(user.a_intent != INTENT_HARM)
		return ATTACK_CHAIN_BLOCKED
	if(bayonet) //Flogging
		bayonet.melee_attack_chain(user, target, params)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/gun/attack_obj(obj/object, mob/user, params)
	if(bayonet)
		bayonet.melee_attack_chain(user, object, params)
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/gun/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		if(!unique_rename)
			add_fingerprint(user)
			to_chat(user, span_warning("You cannot rename [src]!"))
			return ATTACK_CHAIN_BLOCKED_ALL
		var/new_name = rename_interactive(user, I, use_prefix = FALSE)
		if(!isnull(new_name))
			to_chat(user, span_notice("You name the gun '[name]'. Say hello to your new friend."))
		return ATTACK_CHAIN_BLOCKED

	if(istype(I, /obj/item/flashlight/seclite))
		add_fingerprint(user)
		if(!can_flashlight)
			to_chat(user, span_warning("You cannot attach [I] to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(gun_light)
			to_chat(user, span_warning("There is already [gun_light] attached to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You click [I] into place on [src]."))
		set_gun_light(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/kitchen/knife))
		add_fingerprint(user)
		var/obj/item/kitchen/knife/knife = I
		//ensure the gun has an attachment point available and that the knife is compatible with it.
		if(!can_bayonet || !knife.bayonet_suitable)
			to_chat(user, span_warning("You cannot attach [knife] to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(bayonet)
			to_chat(user, span_warning("There is already [knife] attached to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(knife, src))
			return ..()
		to_chat(user, span_notice("You attach [knife] to [src]'s bayonet lug."))
		set_bayonet(knife)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/gun/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(gun_light && can_flashlight)
		to_chat(user, span_notice("You unscrew [gun_light] from [src]."))
		set_gun_light(null)
	else if(bayonet && can_bayonet) //if it has a bayonet, and the bayonet can be removed
		to_chat(user, span_notice("You unscrew [bayonet] from [src]."))
		set_bayonet(null)


/obj/item/gun/proc/toggle_gunlight_verb()
	set name = "Toggle Gun Light"
	set category = "Object"
	set desc = "Click to toggle your weapon's attached flashlight."

	toggle_gunlight(usr)


/obj/item/gun/proc/toggle_gunlight(mob/user, silent = FALSE)
	if(!gun_light)
		return

	if(user && !isturf(user.loc))
		if(!silent)
			to_chat(user, span_warning("You cannot toggle the gun light while in [user.loc]!"))
		return

	gun_light.on = !gun_light.on
	if(!silent)
		playsound(loc, 'sound/weapons/empty.ogg', 100, TRUE)
		if(user)
			to_chat(user, span_notice("You toggle the gun light [gun_light.on ? "on": "off"]."))
	gun_light.set_light_on(gun_light.on)
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
			if(ismob(loc))
				var/mob/user = loc
				if(!(toggle_gunlight_action in user.actions))
					toggle_gunlight_action.Grant(user)
	else
		verbs -= /obj/item/gun/proc/toggle_gunlight_verb

		var/datum/action/item_action/toggle_gunlight/toggle_gunlight_action = locate() in actions
		if(toggle_gunlight_action)
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
		visible_message(span_danger("[src]'s light fades and turns off."))


/// Sets gun's bayonet and do all the necessary updates
/obj/item/gun/proc/set_bayonet(obj/item/kitchen/knife/new_bayonet)
	if(bayonet == new_bayonet)
		return

	if(new_bayonet && (!istype(new_bayonet) || !new_bayonet.bayonet_suitable))
		CRASH("Wrong object passed as an argument ([isdatum(new_bayonet) ? "[new_bayonet.type]" : "[new_bayonet]"])")

	. = bayonet
	bayonet = new_bayonet

	if(bayonet)
		if(bayonet.loc != src)
			bayonet.forceMove(src)

		var/overlay_type = "bayonet"	//Generic state.
		if(icon_exists('icons/obj/weapons/bayonets.dmi', bayonet.icon_state))	//Snowflake state?
			overlay_type = bayonet.icon_state
		bayonet_overlay = mutable_appearance('icons/obj/weapons/bayonets.dmi', overlay_type)
		bayonet_overlay.pixel_x = bayonet_x_offset
		bayonet_overlay.pixel_y = bayonet_y_offset
	else
		bayonet_overlay = null
		if(.)
			var/obj/item/kitchen/knife/old_bayonet = .
			if(old_bayonet.loc == src)
				old_bayonet.forceMove(get_turf(src))

	update_icon(UPDATE_OVERLAYS)
	update_equipped_item(update_speedmods = FALSE)


/obj/item/gun/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	zoom(user, FALSE)
	if(azoom)
		azoom.Remove(user)


/obj/item/gun/AltClick(mob/user)
	if(!unique_reskin || current_skin || loc != user)
		return ..()
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return ..()
	reskin_gun(user)


/obj/item/gun/proc/reskin_gun(mob/user)
	if(!LAZYLEN(skin_options))
		stack_trace("[src] has unique_reskin set to TRUE but skin_options list is empty.")
		return
	var/list/skins = list()
	for(var/skin in skin_options)
		skins[skin] = image(icon = icon, icon_state = skin_options[skin])
	var/choice = show_radial_menu(user, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), user), require_near = TRUE)

	if(choice && reskin_radial_check(user) && !current_skin)
		current_skin = skin_options[choice]
		to_chat(user, "Your gun is now skinned as [choice]. Say hello to your new friend.")
		update_icon()
		update_equipped_item(update_speedmods = FALSE)


/obj/item/gun/proc/reskin_radial_check(mob/living/carbon/human/user)
	if(!ishuman(user) || QDELETED(src) || !user.is_in_hands(src) || user.incapacitated())
		return FALSE
	return TRUE


/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params)
	if(!ishuman(user) || !ishuman(target))
		return

	if(semicd)
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	semicd = 1

	if(!do_after(user, 12 SECONDS, target, NONE) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]'s life.</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
		semicd = 0
		return

	semicd = 0

	target.visible_message("<span class='warning'>[user] pulls the trigger!</span>", "<span class='userdanger'>[user] pulls the trigger!</span>")

	if(chambered && chambered.BB)
		chambered.BB.damage *= 15

	process_fire(target, user, 1, params)

/////////////
// ZOOMING //
/////////////

/datum/action/toggle_scope_zoom
	name = "Toggle Scope"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	button_icon_state = "sniper_zoom"
	var/obj/item/gun/gun = null

/datum/action/toggle_scope_zoom/Trigger(left_click = TRUE)
	gun.zoom(owner)

/datum/action/toggle_scope_zoom/IsAvailable()
	. = ..()
	if(!. && gun)
		gun.zoom(owner, FALSE)

/datum/action/toggle_scope_zoom/Remove(mob/living/L)
	gun.zoom(L, FALSE)
	..()

/obj/item/gun/proc/zoom(mob/living/user, forced_zoom)
	if(!user || !user.client)
		return

	switch(forced_zoom)
		if(FALSE)
			zoomed = FALSE
		if(TRUE)
			zoomed = TRUE
		else
			zoomed = !zoomed

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

		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		user.client.pixel_x = 0
		user.client.pixel_y = 0


//Proc, so that gun accessories/scopes/etc. can easily add zooming.
/obj/item/gun/proc/build_zooming()
	if(azoom)
		return

	if(zoomable)
		azoom = new()
		azoom.gun = src
		RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(ZoomGrantCheck))

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

//Guns can be placed on racks
/obj/item/gun
	var/on_rack = FALSE

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
	if (barrel_dir == upd_dir)
		return
	var/angle = dir2angle(upd_dir) - dir2angle(barrel_dir)
	if (angle > 180)
		angle -= 360
	var/matrix/M = matrix(transform)
	M.Turn(angle)
	animate(src, transform = M, time = 2)
	barrel_dir = upd_dir

// if the gun have rotate transformation - reset it
/obj/item/gun/proc/reset_direction()
	if (barrel_dir == EAST)
		return
	var/matrix/M = matrix()
	transform = M
	barrel_dir = EAST

/obj/item/gun/pickup(mob/user)
	. = ..()
	if (on_rack)
		remove_from_rack()
	else
		reset_direction()

/obj/item/gun/equipped(mob/user, slot, initial)
	reset_direction()
	return ..()
