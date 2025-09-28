//Security modules for MODsuits

///Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/get_ru_names()
	return list(
		NOMINATIVE = "модуль кобуры МЭК",
		GENITIVE = "модуля кобуры МЭК",
		DATIVE = "модулю кобуры МЭК",
		ACCUSATIVE = "модуль кобуры МЭК",
		INSTRUMENTAL = "модулем кобуры МЭК",
		PREPOSITIONAL = "модуле кобуры МЭК",
	)

/obj/item/mod/module/holster/on_use()
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_hand()
		if(!holding)
			balloon_alert(mod.wearer, "нечего положить в кобуру!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_NORMAL) //god no holstering a BSG / combat shotgun
			balloon_alert(mod.wearer, "не лезет в кобуру!")
			return
		holstered = holding
		mod.wearer.visible_message(span_notice("[mod.wearer] убира[pluralize_ru(mod.wearer.gender,"ет","ют")] [holding.declent_ru(ACCUSATIVE)] в кобуру."), span_notice("вы убираете [holding.declent_ru(ACCUSATIVE)] в кобуру."))
		mod.wearer.temporarily_remove_item_from_inventory(holding)
		holding.forceMove(src)
	else if(mod.wearer.put_in_active_hand(holstered))
		mod.wearer.visible_message(span_warning("[mod.wearer] вытаскива[pluralize_ru(mod.wearer.gender,"ет","ют")] [holstered.declent_ru(ACCUSATIVE)] из кобуры!"), \
			span_warning("Вы вытаскиваете [holstered.declent_ru(ACCUSATIVE)] из кобуры!"))
	else
		balloon_alert(mod.wearer, "освободите руку!")

/obj/item/mod/module/holster/on_uninstall(deleting = FALSE)
	. = ..()
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/holster/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == holstered)
		holstered = null

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()

///Mirage grenade dispenser - Dispenses grenades that copy the user's appearance.
/obj/item/mod/module/dispenser/mirage
	name = "MOD mirage grenade dispenser module"
	desc = "This module can create mirage grenades at the user's liking. These grenades create holographic copies of the user."
	icon_state = "mirage_grenade"
	cooldown_time = 20 SECONDS
	overlay_state_inactive = "module_mirage_grenade"
	dispense_type = /obj/item/grenade/mirage

/obj/item/mod/module/dispenser/mirage/on_use()
	var/obj/item/grenade/mirage/grenade = .
	grenade.attack_self(mod.wearer)

/obj/item/mod/module/dispenser/mirage/get_ru_names()
	return list(
		NOMINATIVE = "модуль диспенсера гранат класса \"Мираж\" МЭК",
		GENITIVE = "модуля диспенсера гранат класса \"Мираж\" МЭК",
		DATIVE = "модулю диспенсера гранат класса \"Мираж\" МЭК",
		ACCUSATIVE = "модуль диспенсера гранат класса \"Мираж\" МЭК",
		INSTRUMENTAL = "модулем диспенсера гранат класса \"Мираж\" МЭК",
		PREPOSITIONAL = "модуле диспенсера гранат класса \"Мираж\" МЭК",
	)

/obj/item/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a holographic copy of the user."
	icon_state = "mirage"
	det_time = 3 SECONDS
	/// Mob that threw the grenade.
	var/mob/living/thrower

/obj/item/grenade/mirage/get_ru_names()
	return list(
		NOMINATIVE = "граната класса \"Мираж\"",
		GENITIVE = "гранаты класса \"Мираж\"",
		DATIVE = "гранате класса \"Мираж\"",
		ACCUSATIVE = "гранату класса \"Мираж\"",
		INSTRUMENTAL = "гранатой класса \"Мираж\"",
		PREPOSITIONAL = "гранате класса \"Мираж\"",
	)

/obj/item/grenade/mirage/Destroy()
	thrower = null
	return ..()

/obj/item/grenade/mirage/attack_self(mob/user)
	. = ..()
	thrower = user

/obj/item/grenade/mirage/prime()
	do_sparks(rand(3, 6), FALSE, src)
	if(thrower)
		var/mob/living/simple_animal/hostile/illusion/mirage/M = new(get_turf(src))
		M.Copy_Parent(thrower, 15 SECONDS)
	qdel(src)

/mob/living/simple_animal/hostile/illusion/mirage //It's just standing there, menacingly
	AIStatus = AI_OFF
	density = FALSE

/mob/living/simple_animal/hostile/illusion/mirage/death(gibbed)
	do_sparks(rand(3, 6), FALSE, src)
	return ..()


///Active Sonar - Displays a hud circle on the turf of any living creatures in the given radius
/obj/item/mod/module/active_sonar
	name = "MOD active sonar"
	desc = "Ancient tech from the 20th century, this module uses sonic waves to detect living creatures within the user's radius. \
		Its loud ping is much harder to hide in an indoor station than in the outdoor operations it was designed for."
	icon_state = "active_sonar"
	module_type = MODULE_USABLE
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 4
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/active_sonar)
	cooldown_time = 7.5 SECONDS //come on man this is discount thermals, it doesnt need a 15 second cooldown
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/active_sonar/get_ru_names()
	return list(
		NOMINATIVE = "модуль сонара МЭК",
		GENITIVE = "модуля сонара МЭК",
		DATIVE = "модулю сонара МЭК",
		ACCUSATIVE = "модуль сонара МЭК",
		INSTRUMENTAL = "модулем сонара МЭК",
		PREPOSITIONAL = "модуле сонара МЭК",
	)

/obj/item/mod/module/active_sonar/on_use()
	playsound(mod.wearer, 'sound/mecha/skyfall_power_up.ogg', vol = 20, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	if(!do_after(mod.wearer, 1.1 SECONDS, target = mod.wearer))
		return
	var/creatures_detected = 0
	for(var/mob/living/creature in range(9, mod.wearer))
		if(creature == mod.wearer || creature.stat == DEAD)
			continue
		new /obj/effect/temp_visual/sonar_ping(mod.wearer.loc, mod.wearer, creature)
		creatures_detected++
	playsound(mod.wearer, 'sound/effects/ping_hit.ogg', vol = 75, vary = TRUE, extrarange = 9) // Should be audible for the radius of the sonar
	//ксайкок перепиши эту ебалу, я в рот ебал прописывать декленты и подсчет количества найденных
	to_chat(mod.wearer, (span_notice("You slam your fist into the ground, sending out a sonic wave that detects [creatures_detected] living beings nearby!")))

/obj/effect/temp_visual/sonar_ping
	duration = 3 SECONDS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	randomdir = FALSE
	/// The image shown to modsuit users
	var/image/modsuit_image
	/// The person in the modsuit at the moment, really just used to remove this from their screen
	var/source_UID
	/// The icon state applied to the image created for this ping.
	var/real_icon_state = "sonar_ping"

/obj/effect/temp_visual/sonar_ping/Initialize(mapload, mob/living/looker, mob/living/creature)
	. = ..()
	if(!looker || !creature)
		return INITIALIZE_HINT_QDEL
	modsuit_image = image(icon = icon, loc = src, icon_state = real_icon_state, layer = ABOVE_ALL_MOB_LAYER, pixel_x = ((creature.x - looker.x) * 32), pixel_y = ((creature.y - looker.y) * 32))
	modsuit_image.plane = ABOVE_LIGHTING_PLANE
	modsuit_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	source_UID = looker.UID()
	add_mind(looker)

/obj/effect/temp_visual/sonar_ping/Destroy()
	var/mob/living/previous_user = locateUID(source_UID)
	if(previous_user)
		remove_mind(previous_user)
	// Null so we don't shit the bed when we delete
	modsuit_image = null
	return ..()

/// Add the image to the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/add_mind(mob/living/looker)
	looker?.client?.images |= modsuit_image

/// Remove the image from the modsuit wearer's screen
/obj/effect/temp_visual/sonar_ping/proc/remove_mind(mob/living/looker)
	looker?.client?.images -= modsuit_image

///Firewall. Deployable dropwall that lights projectiles on fire.
/obj/item/mod/module/anomaly_locked/firewall
	name = "MOD firewall module"
	desc = "A module that uses a pyroclastic core to make immolating dropwalls."
	icon_state = "firewall"
	overlay_state_inactive = "module_mirage_grenade"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 20 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/core/atmospheric)
	/// Path we dispense.
	var/dispense_type = /obj/item/grenade/barrier/dropwall/firewall

/obj/item/mod/module/anomaly_locked/firewall/get_ru_names()
	return list(
		NOMINATIVE = "модуль огненного щита МЭК",
		GENITIVE = "модуля огненного щита МЭК",
		DATIVE = "модулю огненного щита МЭК",
		ACCUSATIVE = "модуль огненного щита МЭК",
		INSTRUMENTAL = "модулем огненного щита МЭК",
		PREPOSITIONAL = "модуле огненного щита МЭК",
	)

/obj/item/mod/module/anomaly_locked/firewall/on_use()
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_energy_cost)
	var/obj/item/grenade/grenade = dispensed
	grenade.attack_self(mod.wearer)
	return grenade

/obj/item/mod/module/anomaly_locked/firewall/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

/// Vortex arm mounted shotgun. Fucks up reality in front of it, very power draining. Compeating with the vortex arm and stealth armor after all
/obj/item/mod/module/anomaly_locked/vortex_shotgun
	name = "MOD vortex shotgun module"
	desc = "A module that uses a vortex core to rend the fabric of space time in front of it."
	icon_state = "vortex"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 750
	device = /obj/item/gun/energy/vortex_shotgun
	accepted_anomalies = list(/obj/item/assembly/signaler/core/vortex)

/obj/item/mod/module/anomaly_locked/vortex_shotgun/get_ru_names()
	return list(
		NOMINATIVE = "модуль вихревого дробовика МЭК",
		GENITIVE = "модуля вихревого дробовика МЭК",
		DATIVE = "модулю вихревого дробовика МЭК",
		ACCUSATIVE = "модуль вихревого дробовика МЭК",
		INSTRUMENTAL = "модулем вихревого дробовика МЭК",
		PREPOSITIONAL = "модуле вихревого дробовика МЭК",
	)

/obj/item/mod/module/anomaly_locked/vortex_shotgun/Initialize(mapload)
	. = ..()
	RegisterSignal(device, COMSIG_GUN_FIRED, PROC_REF(on_gun_fire))

/obj/item/mod/module/anomaly_locked/vortex_shotgun/proc/on_gun_fire()
	SIGNAL_HANDLER
	if(!drain_power(use_energy_cost)) //Drain the rest dry
		drain_power(mod.core.check_charge())

/obj/item/mod/module/anomaly_locked/vortex_shotgun/prebuilt
	prebuilt = TRUE
	removable = FALSE // No switching it into another suit / no free anomaly core

///Criminal Capture - Generates hardlight bags you can put people in and sinch.
/obj/item/mod/module/criminalcapture
	name = "MOD criminal capture module"
	desc = "The private security that had orders to take in people dead were quite \
		happy with their space-proofed suit, but for those who wanted to bring back \
		whomever their targets were still breathing needed a way to \"share\" the \
		space-proofing. And thus: criminal capture! Creates a hardlight prisoner transport bag \
		around the apprehended that has breathable atmospheric conditions."
	icon_state = "criminal_capture"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/criminalcapture)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Time to capture a prisoner.
	var/capture_time = 2.5 SECONDS
	/// Time to dematerialize a bodybag.
	var/packup_time = 1 SECONDS
	/// Typepath of our bodybag
	var/bodybag_type = /obj/structure/closet/body_bag/environmental/prisoner/hardlight
	/// Our linked bodybag.
	var/obj/structure/closet/body_bag/linked_bodybag

/obj/item/mod/module/criminalcapture/on_process(seconds_per_tick)
	idle_power_cost = linked_bodybag ? (DEFAULT_CHARGE_DRAIN * 3) : 0
	return ..()

/obj/item/mod/module/criminalcapture/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!linked_bodybag)
		return
	packup()

/obj/item/mod/module/criminalcapture/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!mod.wearer.Adjacent(target))
		return
	if(target == linked_bodybag)
		playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
		if(!do_after(mod.wearer, packup_time, target = target))
			balloon_alert(mod.wearer, "interrupted!")
		packup()
		return
	if(linked_bodybag)
		return
	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
		return
	playsound(src, 'sound/machines/ding.ogg', 25, TRUE)
	if(!do_after(mod.wearer, capture_time, target = target))
		balloon_alert(mod.wearer, "interrupted!")
		return
	if(linked_bodybag)
		return
	linked_bodybag = new bodybag_type(target_turf)
	linked_bodybag.take_contents()
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	RegisterSignal(linked_bodybag, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))

/obj/item/mod/module/criminalcapture/proc/packup()
	if(!linked_bodybag)
		return
	playsound(linked_bodybag, 'sound/weapons/egloves.ogg', 80, TRUE)
	apply_wibbly_filters(linked_bodybag)
	animate(linked_bodybag, 0.5 SECONDS, alpha = 50, flags = ANIMATION_PARALLEL)
	addtimer(CALLBACK(src, PROC_REF(delete_bag), linked_bodybag), 0.5 SECONDS)
	linked_bodybag = null

/obj/item/mod/module/criminalcapture/proc/check_range()
	SIGNAL_HANDLER

	if(get_dist(mod.wearer, linked_bodybag) <= 9)
		return
	packup()

/obj/item/mod/module/criminalcapture/proc/delete_bag(obj/structure/closet/body_bag/bag)
	if(mod?.wearer)
		UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED, PROC_REF(check_range))
		balloon_alert(mod.wearer, "bag dissipated")
	bag.open()
	qdel(bag)

//Security modules for MODsuits

///Magnetic Harness - Automatically puts guns in your suit storage when you drop them.
/obj/item/mod/module/magnetic_harness
	name = "MOD magnetic harness module"
	desc = "Based off old TerraGov harness kits, this magnetic harness automatically attaches dropped guns back to the wearer."
	icon_state = "mag_harness"
	complexity = 2
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/magnetic_harness)
	required_slots = list(ITEM_SLOT_CLOTH_OUTER)
	/// Time before we activate the magnet.
	var/magnet_delay = 0.8 SECONDS
	/// The typecache of all guns we allow.
	var/static/list/guns_typecache
	/// The guns already allowed by the modsuit chestplate.
	var/list/already_allowed_guns = list()

/obj/item/mod/module/magnetic_harness/Initialize(mapload)
	. = ..()
	if(!guns_typecache)
		guns_typecache = typecacheof(list(/obj/item/gun/projectile, /obj/item/gun/energy, /obj/item/gun/grenadelauncher, /obj/item/gun/syringe))

/obj/item/mod/module/magnetic_harness/on_install()
	. = ..()
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_CLOTH_OUTER)
	if(!istype(suit))
		return
	already_allowed_guns = guns_typecache & suit.allowed
	suit.allowed |= guns_typecache

/obj/item/mod/module/magnetic_harness/on_uninstall(deleting = FALSE)
	. = ..()
	if(deleting)
		return
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_CLOTH_OUTER)
	if(!istype(suit))
		return
	suit.allowed -= (guns_typecache - already_allowed_guns)

/obj/item/mod/module/magnetic_harness/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(check_dropped_item))

/obj/item/mod/module/magnetic_harness/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/obj/item/mod/module/magnetic_harness/proc/check_dropped_item(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(dropped_item, guns_typecache))
		return
	if(new_location != get_turf(src))
		return
	addtimer(CALLBACK(src, PROC_REF(pick_up_item), dropped_item), magnet_delay)

/obj/item/mod/module/magnetic_harness/proc/pick_up_item(obj/item/item)
	if(!isturf(item.loc) || !item.Adjacent(mod.wearer))
		return
	if(!mod.wearer.equip_to_slot_if_possible(item, ITEM_SLOT_SUITSTORE, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "[item] reattached")
	drain_power(use_energy_cost)

///Pepper Shoulders - When hit, reacts with a spray of pepper spray around the user.
/obj/item/mod/module/pepper_shoulders
	name = "MOD pepper shoulders module"
	desc = "A module that attaches two pepper sprayers on shoulders of a MODsuit, reacting to touch with a spray around the user."
	icon_state = "pepper_shoulder"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/pepper_shoulders)
	cooldown_time = 5 SECONDS
	overlay_state_inactive = "module_pepper"
	overlay_state_use = "module_pepper_used"
	required_slots = list(ITEM_SLOT_CLOTH_OUTER)

/obj/item/mod/module/pepper_shoulders/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_check_block))

/obj/item/mod/module/pepper_shoulders/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/pepper_shoulders/on_use()
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	var/datum/reagents/capsaicin_holder = new(10)
	capsaicin_holder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	var/datum/effect_system/fluid_spread/smoke/chem/quick/smoke = new
	smoke.set_up(1, holder = src, location = get_turf(src), carry = capsaicin_holder)
	smoke.start(log = TRUE)
	QDEL_NULL(capsaicin_holder) // Reagents have a ref to their holder which has a ref to them. No leaks please.

/obj/item/mod/module/pepper_shoulders/proc/on_check_block()
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return
	if(!check_power(use_energy_cost))
		return
	mod.wearer.visible_message(span_warning("[src] reacts to the attack with a smoke of pepper spray!"), span_notice("Your [src] releases a cloud of pepper spray!"))
	on_use()

///Megaphone - Lets you speak loud.
/obj/item/mod/module/megaphone
	name = "MOD megaphone module"
	desc = "A microchip megaphone linked to a MODsuit, for very important purposes, like: loudness."
	icon_state = "megaphone"
	module_type = MODULE_ACTIVE
	complexity = 1
	device = /obj/item/megaphone
	incompatible_modules = list(/obj/item/mod/module/megaphone)
	removable = TRUE
	cooldown_time = 0.05 SECONDS

/obj/item/mod/module/quick_cuff
	name = "MOD restraint assist module"
	desc = "Enhanced gauntlet grip pads that help with placing individuals in restraints more quickly. Doesn't look like they'll come off."
	removable = FALSE
	complexity = 0
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/quick_cuff/on_part_activation()
	. = ..()
	ADD_TRAIT(mod.wearer, TRAIT_FAST_CUFFING, UNIQUE_TRAIT_SOURCE(src))

/obj/item/mod/module/quick_cuff/on_part_deactivation(deleting = FALSE)
	. = ..()
	REMOVE_TRAIT(mod.wearer, TRAIT_FAST_CUFFING, UNIQUE_TRAIT_SOURCE(src))
