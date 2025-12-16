#define EMITTER_NEEDS_WRENCH 0
#define EMITTER_NEEDS_WELDER 1
#define EMITTER_WELDED 2

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
	/// When was the last emitter shot
	var/last_shot = 0
	/// Number of shots made (gets reset every few shots)
	var/shot_number = 0
	/// Construction state
	var/state = EMITTER_NEEDS_WRENCH
	/// Locked by an ID card
	var/locked = FALSE
	/// What projectile type are we shooting?
	var/projectile_type = /obj/projectile/beam/emitter/hitscan
	/// What's the projectile sound?
	var/projectile_sound = 'sound/weapons/emitter.ogg'
	/// Sparks emitted with every shot
	var/datum/effect_system/spark_spread/sparks

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
	if(state == EMITTER_WELDED && anchored)
		connect_to_network()
	sparks = new
	sparks.attach(src)
	sparks.set_up(5, TRUE, src)

/obj/machinery/power/emitter/examine(mob/user)
	. = ..()
	if(state == EMITTER_WELDED && anchored)
		. += span_notice("Он прочно приварен к полу. Вы можете разварить его с помощью <b>сварочного аппарата</b>.")
	else if(state == EMITTER_NEEDS_WELDER && anchored)
		. += span_notice("В настоящее время он прикреплён к полу. Вы можете надёжно приварить его с помощью <b>сварочного аппарата</b> или открепить с помощью <b>гаечного ключа</b>.")
	else if(state == EMITTER_NEEDS_WRENCH && !anchored)
		. += span_notice("Он не прикреплён к полу. Вы можете прикрутить его с помощью <b>гаечного ключа</b>.")

	if(!in_range(user, src) && !isobserver(user))
		return

	if(!active)
		. += span_notice("Его дисплей состояния в настоящее время выключен.")
	else if(!powered)
		. += span_notice("Его дисплей состояния слабо светится.")
	else
		. += span_notice("На его дисплее состояния указано: Излучает луч в диапазоне между <b>[DisplayTimeText(minimum_fire_delay)]</b> и <b>[DisplayTimeText(maximum_fire_delay)]</b>.")
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
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("You can't do that right now!"))
		return CLICK_ACTION_BLOCKING

	if(anchored)
		to_chat(usr, "It is fastened to the floor!")
		return CLICK_ACTION_BLOCKING

	add_fingerprint(usr)
	dir = turn(dir, 90)

	return CLICK_ACTION_SUCCESS

/obj/machinery/power/emitter/Destroy()
	if(SSticker.IsRoundInProgress())
		var/turf/turf = get_turf(src)
		message_admins("Emitter deleted at [ADMIN_VERBOSEJMP(turf)]. [usr ? "Broken by [ADMIN_LOOKUPFLW(usr)]." : ""]", ATKLOG_FEW)
		add_game_logs("Emitter deleted at [AREACOORD(turf)].")
		investigate_log("deleted at [AREACOORD(turf)]. [usr ? "Broken by [key_name_log(usr)]." : ""]", INVESTIGATE_ENGINE)
	QDEL_NULL(sparks)
	return ..()

/obj/machinery/power/emitter/update_icon_state()
	if(active && powernet && avail(active_power_usage))
		icon_state = "[base_icon_state]_on"
	else
		icon_state = base_icon_state

/obj/machinery/power/emitter/attack_hand(mob/user)
	add_fingerprint(user)
	if(state != EMITTER_WELDED)
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
		state = EMITTER_NEEDS_WRENCH
		anchored = FALSE
		user.visible_message(span_warning("[user] rips [src] free from its moorings!"))
	else
		. = ..()

	if(. && !anchored)
		step(src, get_dir(user, src))

/obj/machinery/power/emitter/process()
	if((stat & BROKEN) || !active)
		return

	if(state != EMITTER_WELDED || (!powernet && active_power_usage))
		active = FALSE
		update_appearance()
		return

	if(active_power_usage && surplus() < active_power_usage)
		if(powered)
			powered = FALSE
			update_appearance()
			investigate_log("lost power and turned OFF at [AREACOORD(src)]", INVESTIGATE_ENGINE)
			log_game("[src] lost power in [AREACOORD(src)]")
		return

	add_load(active_power_usage)
	if(!powered)
		powered = TRUE
		update_appearance()
		investigate_log("regained power and turned ON at [AREACOORD(src)]", INVESTIGATE_ENGINE)

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
	projectile.firer_source_atom = src
	projectile.Angle = dir2angle(dir)
	projectile.fire((dir2angle(dir)))

	// The hardcode for projectiles to properly fly in this direction. I don't know why.
	if(dir == WEST)
		projectile.pixel_x = -1
	else if(dir == SOUTH)
		projectile.pixel_y = -1

	last_shot = world.time
	if(shot_number < 3)
		fire_delay = 20
		shot_number ++
	else
		fire_delay = rand(minimum_fire_delay, maximum_fire_delay)
		shot_number = 0

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

	return ..()

/obj/machinery/power/emitter/screwdriver_act(mob/living/user, obj/item/item)
	. = TRUE
	if(active)
		to_chat(user, span_warning("[src] needs to be disabled first!"))
		return
	default_deconstruction_screwdriver(user, "[base_icon_state]_open", base_icon_state, item)

/obj/machinery/power/emitter/crowbar_act(mob/living/user, obj/item/item)
	. = TRUE
	default_deconstruction_crowbar(user, item)

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
	if(state == EMITTER_WELDED)
		to_chat(user, span_warning("[src] needs to be unwelded from the floor!"))
		return

	if(state == EMITTER_NEEDS_WRENCH)
		for(var/obj/machinery/power/emitter/emitter in get_turf(src))
			if(emitter.anchored)
				to_chat(user, span_warning("There is already an emitter here!"))
				return
		state = EMITTER_NEEDS_WELDER
		anchored = TRUE
		user.visible_message(
			span_notice("[user] secures [src] to the floor."),
			span_notice("You secure the external reinforcing bolts to the floor."),
			span_hear("You hear a ratchet."),
		)
	else
		state = EMITTER_NEEDS_WRENCH
		anchored = FALSE
		user.visible_message(
			span_notice("[user] unsecures [src]'s reinforcing bolts from the floor."),
			span_notice("You undo the external reinforcing bolts."),
			span_hear("You hear a ratchet."),
		)
	playsound(src, item.usesound, item.tool_volume, TRUE)

/obj/machinery/power/emitter/welder_act(mob/user, obj/item/item)
	. = TRUE
	if(active)
		to_chat(user, span_notice("Turn off [src] first."))
		return

	if(state == EMITTER_NEEDS_WRENCH)
		to_chat(user, span_warning("[src] needs to be wrenched to the floor."))
		return

	if(!item.tool_use_check(user, 0))
		return

	if(state == EMITTER_NEEDS_WELDER)
		WELDER_ATTEMPT_FLOOR_WELD_MESSAGE
	else if(state == EMITTER_WELDED)
		WELDER_ATTEMPT_FLOOR_SLICE_MESSAGE

	if(!item.use_tool(src, user, 2 SECONDS, volume = item.tool_volume))
		return

	if(state == EMITTER_NEEDS_WELDER)
		WELDER_FLOOR_WELD_SUCCESS_MESSAGE
		connect_to_network()
		state = EMITTER_WELDED
	else if(state == EMITTER_WELDED)
		WELDER_FLOOR_SLICE_SUCCESS_MESSAGE
		disconnect_from_network()
		state = EMITTER_NEEDS_WELDER

#undef EMITTER_NEEDS_WRENCH
#undef EMITTER_NEEDS_WELDER
#undef EMITTER_WELDED
