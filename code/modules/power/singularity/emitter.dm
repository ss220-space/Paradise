/obj/machinery/power/emitter
	name = "emitter"
	desc = "Мощный промышленный лазер, который часто применяется для питания защитных полей при производстве электроэнергии."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "emitter"
	base_icon_state = "emitter"

	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_ENGINE_EQUIP)

	idle_power_usage = 10
	active_power_usage = 300

	/// Is the emitter turned on?
	var/active = FALSE
	/// Is the emitter powered?
	var/powered = FALSE
	/// Delay between each emitter shot
	var/fire_delay = 10 SECONDS
	/// Maximum delay between each emitter shot
	var/maximum_fire_delay = 10 SECONDS
	/// Minimum delay between each emitter shot
	var/minimum_fire_delay = 2 SECONDS
	///Modifier to the preceeding two numbers
	var/fire_rate_mod = 1
	///Deactivates the "pause every 3 shots" system
	var/no_shot_counter = FALSE
	/// When was the last emitter shot
	var/last_shot = 0
	/// Number of shots made (gets reset every few shots)
	var/shot_number = 0
	/// If it's welded down to the ground or not. the emitter will not fire while unwelded. If set to true, the emitter will start anchored as well.
	var/welded = FALSE
	/// Locked by an ID card
	var/locked = FALSE
	/// What projectile type are we shooting?
	var/projectile_type = /obj/projectile/beam/emitter/hitscan
	/// What's the projectile sound?
	var/projectile_sound = 'sound/weapons/emitter.ogg'
	/// Sparks emitted with every shot
	var/datum/effect_system/spark_spread/sparks
	/// Amount of power inside
	var/charge = 0
	/// the disk in the gun
	var/obj/item/emitter_disk/diskie

/obj/machinery/power/emitter/get_ru_names()
	return list(
		NOMINATIVE = "эмиттер",
		GENITIVE = "эмиттера",
		DATIVE = "эмиттеру",
		ACCUSATIVE = "эмиттер",
		INSTRUMENTAL = "эмиттером",
		PREPOSITIONAL = "эмиттере"
	)

/obj/machinery/power/emitter/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/emitter(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()
	if(welded)
		if(!anchored)
			set_anchored(TRUE)
		connect_to_network()
	sparks = new
	sparks.attach(src)
	sparks.set_up(5, TRUE, src)

/obj/machinery/power/emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/current_turf = get_turf(src)
		message_admins("Emitter deleted at [ADMIN_VERBOSEJMP(current_turf)]. [usr ? "Broken by [ADMIN_LOOKUPFLW(usr)]." : ""]", ATKLOG_FEW)
		add_game_logs("Emitter deleted at [AREACOORD(current_turf)].")
		investigate_log("deleted at [AREACOORD(current_turf)]. [usr ? "Broken by [key_name_log(usr)]." : ""]", INVESTIGATE_ENGINE)
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/power/emitter/welded/Initialize(mapload)
	welded = TRUE
	. = ..()

/obj/machinery/power/emitter/set_anchored(anchorvalue)
	. = ..()
	if(!anchored && welded) // make sure they're keep in sync in case it was forcibly unanchored by badmins or by a megafauna.
		welded = FALSE

/obj/machinery/power/emitter/examine(mob/user)
	. = ..()
	if(welded)
		. += span_notice("Он прочно приварен к полу. Вы можете разварить его с помощью <b>сварочного аппарата</b>.")
	else if(anchored)
		. += span_notice("В настоящее время он прикреплён к полу. Вы можете надёжно приварить его с помощью <b>сварочного аппарата</b> или открепить с помощью <b>гаечного ключа</b>.")
	else
		. += span_notice("Он не прикреплён к полу. Вы можете прикрутить его с помощью <b>гаечного ключа</b>.")

	if(!in_range(user, src) && !isobserver(user))
		return

	if(!active)
		. += span_notice("Его дисплей состояния в настоящее время выключен.")
	else if(!powered)
		. += span_notice("Его дисплей состояния слабо светится.")
	else
		. += span_notice("На его дисплее состояния указано: Излучает луч в диапазоне между <b>[DisplayTimeText(minimum_fire_delay * fire_rate_mod)]</b> и <b>[DisplayTimeText(maximum_fire_delay * fire_rate_mod)]</b>.")
		. += span_notice("Потребляемая мощность: <b>[display_power(active_power_usage)]</b>.")

/obj/machinery/power/emitter/RefreshParts()
	. = ..()
	var/max_fire_delay = 12 SECONDS
	var/fire_shoot_delay = 12 SECONDS
	var/min_fire_delay = 2.4 SECONDS
	var/power_usage = 350
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		max_fire_delay -= 2 SECONDS * laser.rating
		min_fire_delay -= 0.4 SECONDS * laser.rating
		fire_shoot_delay -= 2 SECONDS * laser.rating
	maximum_fire_delay = max_fire_delay
	minimum_fire_delay = min_fire_delay
	fire_delay = fire_shoot_delay
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		power_usage -= 50 * manipulator.rating
	active_power_usage = power_usage

/obj/machinery/power/emitter/click_alt(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return CLICK_ACTION_BLOCKING

	if(anchored)
		to_chat(user, "It is fastened to the floor!")
		return CLICK_ACTION_BLOCKING

	add_fingerprint(user)
	dir = turn(dir, 90)

	return CLICK_ACTION_SUCCESS

/obj/machinery/power/emitter/update_overlays()
	. = ..()
	if(!active)
		return
	var/laser_color = COLOR_VIBRANT_LIME
	if(!powered)
		laser_color = COLOR_ORANGE //stank low power orange
	else if(diskie)
		laser_color = diskie.laser_color
	var/mutable_appearance/overlay = mutable_appearance(icon, "emitter_overlay")
	overlay.color = laser_color
	. += overlay
	. += emissive_appearance(icon, "emitter_overlay", src, alpha = src.alpha)

/obj/machinery/power/emitter/update_icon_state()
	if(panel_open)
		icon_state = "[base_icon_state]_open"
	else
		icon_state = base_icon_state
	return ..()

/obj/machinery/power/emitter/attack_hand(mob/user)
	add_fingerprint(user)
	if(!welded)
		to_chat(user, span_warning("[src] needs to be firmly secured to the floor first."))
		return TRUE

	if(!powernet)
		to_chat(user, span_warning("The emitter isn't connected to a wire."))
		return TRUE

	if(panel_open)
		to_chat(user, span_warning("The maintenance panel needs to be closed!"))
		return

	if(locked)
		to_chat(user, span_warning("The controls are locked!"))
		return

	if(active)
		active = FALSE
	else
		active = TRUE
		shot_number = 0
		fire_delay = maximum_fire_delay

	to_chat(user, span_notice("You turn [active ? "on" : "off"] [src]."))
	message_admins("[src] turned [active ? "ON" : "OFF"] by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(src)]")
	log_game("[src] turned [active ? "ON" : "OFF"] by [key_name(user)] in [AREACOORD(src)]")
	investigate_log("turned [active ? "ON" : "OFF"] by [key_name(user)] at [AREACOORD(src)]", INVESTIGATE_ENGINE)
	update_appearance()

/obj/machinery/power/emitter/emp_act(severity) // Emitters are hardened but still might have issues
	return TRUE

/obj/machinery/power/emitter/attack_animal(mob/living/simple_animal/user)
	if(ismegafauna(user) && anchored)
		anchored = FALSE
		user.visible_message(span_warning("[user] rips [src] free from its moorings!"))
	else
		. = ..()

	if(. && !anchored)
		step(src, get_dir(user, src))

/obj/machinery/power/emitter/process(seconds_per_tick)
	var/power_usage = active_power_usage * seconds_per_tick
	if(stat & (BROKEN))
		return

	if(!welded || (!powernet && power_usage))
		active = FALSE
		update_appearance()
		return

	if(!active)
		return

	if(power_usage && surplus() < power_usage)
		if(powered)
			powered = FALSE
			update_appearance()
			investigate_log("lost power and turned OFF at [AREACOORD(src)]", INVESTIGATE_ENGINE)
			log_game("[src] lost power in [AREACOORD(src)]")
		return

	add_load(power_usage)
	if(!powered)
		powered = TRUE
		update_appearance()
		investigate_log("regained power and turned ON at [AREACOORD(src)]", INVESTIGATE_ENGINE)

	if(charge <= 80)
		charge += 2.5 * seconds_per_tick

	if(!check_delay())
		return FALSE

	fire_beam()

/obj/machinery/power/emitter/proc/check_delay()
	if((last_shot + fire_delay) <= world.time)
		return TRUE
	return FALSE

/obj/machinery/power/emitter/proc/fire_beam()
	var/obj/projectile/projectile = new projectile_type(get_turf(src))
	playsound(src, projectile_sound, 50, TRUE)
	if(prob(35))
		sparks.start()
	switch(dir)
		if(NORTH)
			projectile.yo = 20
			projectile.xo = 0
		if(NORTHEAST)
			projectile.yo = 20
			projectile.xo = 20
		if(EAST)
			projectile.yo = 0
			projectile.xo = 20
		if(SOUTHEAST)
			projectile.yo = -20
			projectile.xo = 20
		if(WEST)
			projectile.yo = 0
			projectile.xo = -20
		if(SOUTHWEST)
			projectile.yo = -20
			projectile.xo = -20
		if(NORTHWEST)
			projectile.yo = 20
			projectile.xo = -20
		else // Any other
			projectile.yo = -20
			projectile.xo = 0

	// The hardcode for projectiles to properly fly in this direction. I don't know why.
	if(dir == WEST)
		projectile.pixel_x = -1
	else if(dir == SOUTH)
		projectile.pixel_y = -1

	last_shot = world.time
	if(shot_number < 3 || no_shot_counter)
		fire_delay = 20 * fire_rate_mod
		shot_number ++
	else
		fire_delay = rand(minimum_fire_delay, maximum_fire_delay) * fire_rate_mod
		shot_number = 0

	projectile.setDir(dir)
	projectile.starting = loc
	projectile.firer_source_atom = src
	projectile.Angle = null
	projectile.fire()

	return projectile

/obj/machinery/power/emitter/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, item))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(item.GetID() || is_pda(item))
		add_fingerprint(user)
		if(emagged)
			to_chat(user, span_warning("The lock seems to be broken."))
			return ATTACK_CHAIN_PROCEED
		if(!allowed(user))
			to_chat(user, span_warning("Access denied."))
			return ATTACK_CHAIN_PROCEED
		if(!active)
			locked = FALSE //just in case it somehow gets locked
			to_chat(user, span_warning("The controls can only be locked while [src] is online."))
			return ATTACK_CHAIN_PROCEED
		locked = !locked
		to_chat(user, span_notice("The controls are now [locked ? "locked." : "unlocked."]"))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(panel_open && istype(item, /obj/item/emitter_disk))
		var/obj/item/emitter_disk/config_disk = item
		if(!user.transfer_item_to_loc(config_disk, src))
			balloon_alert(user, "stuck in hand!")
			return
		if(diskie)
			user.put_in_hands(diskie)
			balloon_alert(user, "disks swapped!")
		else
			balloon_alert(user, "disk inserted")
		diskie = config_disk
		projectile_type = diskie.stored_proj
		projectile_sound = diskie.stored_sound
		fire_rate_mod = diskie.fire_rate_mod
		no_shot_counter = diskie.no_shot_counter
		playsound(src, 'sound/machines/card_slide.ogg', 50)
		to_chat(user, span_notice("You update the [src]'s diode configuration with the [config_disk]."))
		update_appearance()
		if(diskie.consumable)
			qdel(diskie)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/power/emitter/proc/remove_disk(mob/user)
	if(!diskie)
		return
	if(diskie.consumed_on_removal)
		qdel(diskie)
	else
		user.put_in_hands(diskie)
	diskie = null
	playsound(src, 'sound/machines/card_slide.ogg', 50, TRUE)
	update_appearance()
	return TRUE

/obj/machinery/power/emitter/proc/set_projectile()
	projectile_type = initial(projectile_type)
	projectile_sound = initial(projectile_sound)
	fire_rate_mod = initial(fire_rate_mod)
	no_shot_counter = initial(no_shot_counter)

/obj/machinery/power/emitter/screwdriver_act(mob/living/user, obj/item/item)
	. = TRUE
	if(active)
		to_chat(user, span_warning("[src] needs to be disabled first!"))
		return
	default_deconstruction_screwdriver(user, "[base_icon_state]_open", base_icon_state, item)

/obj/machinery/power/emitter/crowbar_act(mob/living/user, obj/item/item)
	if(panel_open && diskie)
		return remove_disk(user)
	default_deconstruction_crowbar(user, item)
	return TRUE

/obj/machinery/power/emitter/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		locked = FALSE
		emagged = TRUE
		if(user)
			user.visible_message(
				span_warning("[user] emags the [src]."),
				span_warning("You short out the lock."),
			)

/obj/machinery/power/emitter/wrench_act(mob/living/user, obj/item/item)
	. = TRUE
	if(active)
		to_chat(user, span_warning("Turn off [src] first!"))
		return
	if(welded)
		to_chat(user, span_warning("[src] needs to be unwelded from the floor!"))
		return

	if(!anchored && !welded)
		for(var/obj/machinery/power/emitter/emitter in get_turf(src))
			if(emitter.anchored)
				to_chat(user, span_warning("There is already an emitter here!"))
				return
		anchored = TRUE
		WRENCH_ANCHOR_MESSAGE
	else
		anchored = FALSE
		WRENCH_UNANCHOR_MESSAGE
	playsound(src, item.usesound, item.tool_volume, TRUE)

/obj/machinery/power/emitter/welder_act(mob/user, obj/item/item)
	. = TRUE
	if(active)
		to_chat(user, span_notice("Turn off [src] first."))
		return

	if(!anchored && !welded)
		to_chat(user, span_warning("[src] needs to be wrenched to the floor."))
		return

	if(!item.tool_use_check(user, 0))
		return

	if(!welded && anchored)
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
	else if(welded)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE

	if(!item.use_tool(src, user, 2 SECONDS, volume = item.tool_volume))
		return

	if(!welded && anchored)
		WELDER_FLOOR_WELD_SUCCESS_MESSAGE
		connect_to_network()
		welded = TRUE
	else if(welded)
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		disconnect_from_network()
		welded = FALSE

/obj/item/emitter_disk
	name = "Diode Disk: Debugger"
	desc = "This disk can be used on an emitter with an open panel to reset its projectile. Unless this was handed to you by an admin, you should report this on github."
	icon = 'icons/obj/devices/floppy_disks.dmi'
	icon_state = "datadisk4"
	var/disk_overlay = "o_E"
	var/laser_color = COLOR_VIBRANT_LIME
	var/stored_proj = /obj/projectile/beam/emitter/hitscan
	var/stored_sound = 'sound/weapons/emitter.ogg'
	var/consumed_on_removal = TRUE
	var/consumable = TRUE
	var/fire_rate_mod = 1
	var/no_shot_counter = FALSE

/obj/item/emitter_disk/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/emitter_disk/update_overlays()
	. = ..()
	. += disk_overlay

/obj/item/emitter_disk/stamina
	name = "Diode Disk: Electrodisruptive"
	desc = "This disk can be used on an emitter with an open panel to make it shoot lasers which will increase the integrity of supermatter crystals and exhaust living creatures. The disk will be consumed in the process."
	icon_state = "datadisk7"
	stored_proj = /obj/projectile/beam/emitter/hitscan/bluelens
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_TRUE_BLUE

/obj/item/emitter_disk/healing
	name = "Diode Disk: Bioregenerative"
	desc = "This disk can be installed into an emitter with an open panel to make it shoot lasers which will heal the physical damages of living creatures."
	icon_state = "datadisk2"
	stored_proj = /obj/projectile/beam/emitter/hitscan/bioregen
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_YELLOW

/obj/item/emitter_disk/incendiary
	name = "Diode Disk: Conflagratory"
	desc = "This disk can be used on an emitter with an open panel to make it shoot lasers which will set living creatures ablaze."
	icon_state = "datadisk9"
	stored_proj = /obj/projectile/beam/emitter/hitscan/incend
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_RED_LIGHT

/obj/item/emitter_disk/sanity
	name = "Diode Disk: Psychosiphoning"
	desc = "This disk can be used on an emitter with an open panel to make it shoot lasers which will depress living creatures and calm supermatter crystals."
	icon_state = "datadisk1"
	stored_proj = /obj/projectile/beam/emitter/hitscan/psy
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_TONGUE_PINK

/obj/item/emitter_disk/magnetic
	name = "Diode Disk: Magnetogenerative"
	desc = "This disk can be used on an emitter with an open panel to make it shoot lasers which will attract nearby objects."
	icon_state = "datadisk6"
	stored_proj = /obj/projectile/beam/emitter/hitscan/magnetic
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_SILVER

/obj/item/emitter_disk/blast
	name = "Diode Disk: Hyperconcussive"
	desc = "This disk, loaded with proprietary syndicate firmware, can be used on an emitter with an open panel to make it shoot beams of concussive force which will cause small explosions."
	icon_state = "datadisk0"
	disk_overlay = "o_syndicate"
	stored_proj = /obj/projectile/beam/emitter/hitscan/blast
	consumed_on_removal = FALSE
	consumable = FALSE
	laser_color = COLOR_SYNDIE_RED //magnetic is already grey
	fire_rate_mod = 2
