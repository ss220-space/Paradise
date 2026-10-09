/obj/vehicle/ridden/motorbike
	name = "motorbike"
	desc = "Внедорожный мотоцикл для передвижения по пересечённой местности."
	icon_state = "motorbike"
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 100, BOMB = 40, BIO = 100, FIRE = 80, ACID = 50)
	integrity_failure = 150
	key_type = /obj/item/key/motorbike

	/// Mutable appearance overlay that covers up the mob with the bike as needed
	var/mutable_appearance/motorbike_cover
	/// Fuel count, fuel usage is one per tile moved
	var/fuel_count = 0
	/// Max fuel that this bike can hold
	var/fuel_max = 1000
	/// Whether the engine is currently running
	var/engine_on = FALSE
	/// Internal storage of the bike
	var/obj/item/storage/motorbike_pack/storage
	/// The looping sound that plays while the engine is running
	var/datum/looping_sound/bike_idle/idle_sound
	/// Which sound is played when the bike is unbuckled from
	var/dismount_sound = 'sound/vehicles/bikedismount.ogg'
	/// Sound played when trying to start the engine without fuel
	var/dry_start_sound = 'sound/vehicles/bikedry.ogg'
	/// A list of potential sounds played when the bike is revved via RMB
	var/list/rev_sounds = list(
		'sound/vehicles/bikerev-1.ogg',
		'sound/vehicles/bikerev-2.ogg',
		'sound/vehicles/bikerev-3.ogg',
		'sound/vehicles/bikerev-4.ogg',
	)
	/// Cooldown for revving the bike, to prevent spamming
	COOLDOWN_DECLARE(rev_cooldown)

/obj/vehicle/ridden/motorbike/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/motorbike/engine_toggle, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/motorbike/Initialize(mapload)
	. = ..()
	idle_sound = new(src, FALSE)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/motorbike)
	motorbike_cover = mutable_appearance(icon, "motorbike_cover", MOB_LAYER + 0.1)
	storage = new(src)
	fuel_count = fuel_max

/obj/vehicle/ridden/motorbike/get_ru_names()
	return alist(
		NOMINATIVE = "мотоцикл",
		GENITIVE = "мотоцикла",
		DATIVE = "мотоциклу",
		ACCUSATIVE = "мотоцикл",
		INSTRUMENTAL = "мотоциклом",
		PREPOSITIONAL = "мотоцикле",
	)

/obj/vehicle/ridden/motorbike/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(idle_sound)
		idle_sound.stop()
	QDEL_NULL(idle_sound)
	QDEL_NULL(storage)
	QDEL_NULL(particles)
	motorbike_cover = null
	return ..()

/obj/vehicle/ridden/motorbike/examine(mob/user)
	. = ..()
	var/list/hints = .
	for(var/hint in hints.Copy())
		if(istext(hint) && findtext(hint, "извлечь ключ"))
			hints -= hint
	. += span_notice("Alt+ЛКМ — открыть внутреннее хранилище.")
	. += span_notice("Alt+ПКМ — извлечь ключ из замка зажигания.")
	. += span_notice("ПКМ — резко нажать газ (нужно сидеть на мотоцикле).")
	. += span_notice("Топливный бак: \"[round(fuel_count / fuel_max * 100)]%\".")
	. += span_notice("Двигатель [engine_on ? "заведён" : "заглушен"].")

/// Returns a boolean indicating whether the motorbike has fuel left.
/obj/vehicle/ridden/motorbike/proc/has_fuel()
	return fuel_count > 0

/// Toggles the engine. Requires the key to be inserted and fuel to start.
/obj/vehicle/ridden/motorbike/proc/toggle_engine(mob/user)
	if(engine_on)
		engine_on = FALSE
		idle_sound.stop()
		return
	if(!is_key(inserted_key))
		balloon_alert(user, "нет ключа!")
		return
	if(!has_fuel())
		playsound(src, dry_start_sound, 40, TRUE)
		balloon_alert(user, "нет топлива!")
		return
	engine_on = TRUE
	idle_sound.start()

/// Stops the engine, e.g. when it runs out of fuel.
/obj/vehicle/ridden/motorbike/proc/stall_engine()
	if(!engine_on)
		return
	engine_on = FALSE
	idle_sound.stop()
	for(var/mob/rider in buckled_mobs)
		balloon_alert(rider, "двигатель заглох!")

/obj/vehicle/ridden/motorbike/post_buckle_mob(mob/living/M)
	add_overlay(motorbike_cover)
	return ..()

/obj/vehicle/ridden/motorbike/post_unbuckle_mob(mob/living/M)
	if(!LAZYLEN(buckled_mobs))
		cut_overlay(motorbike_cover)
	if(engine_on)
		playsound(src, dismount_sound, 25, TRUE)
	return ..()

/obj/vehicle/ridden/motorbike/relaymove(mob/living/user, direction)
	if(is_driver(user))
		if(!engine_on)
			if(COOLDOWN_FINISHED(src, message_cooldown))
				balloon_alert(user, "двигатель не запущен!")
				COOLDOWN_START(src, message_cooldown, 1 SECONDS)
			return FALSE
		if(!has_fuel())
			if(COOLDOWN_FINISHED(src, message_cooldown))
				balloon_alert(user, "нет топлива!")
				COOLDOWN_START(src, message_cooldown, 1 SECONDS)
			stall_engine()
			return FALSE
	return ..()

/obj/vehicle/ridden/motorbike/relaydrive(mob/living/user, direction)
	if(isliving(user.pulling))
		var/mob/living/towed = user.pulling
		user.stop_pulling()
		towed.Knockdown(2 SECONDS)
	. = ..()
	if(!.)
		return
	fuel_count--
	if(fuel_count <= 0)
		fuel_count = 0
		stall_engine()

/// Revs the engine via RMB while riding the bike. Costs a bit of fuel.
/obj/vehicle/ridden/motorbike/attack_hand_secondary(mob/user, list/modifiers)
	if(!(user in buckled_mobs))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(!engine_on)
		balloon_alert(user, "двигатель заглушен!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, rev_cooldown))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(fuel_count < 5)
		balloon_alert(user, "нет топлива!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	COOLDOWN_START(src, rev_cooldown, 3 SECONDS)
	to_chat(user, span_notice("Вы резко нажимаете на газ."))
	fuel_count -= 5
	playsound(src, pick(rev_sounds), 30, TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Alt+LMB opens the internal storage.
/obj/vehicle/ridden/motorbike/click_alt(mob/user)
	if(!storage)
		return NONE
	storage.open(user)
	return CLICK_ACTION_SUCCESS

/// Alt+RMB removes the key. The engine must be stopped first.
/obj/vehicle/ridden/motorbike/click_alt_secondary(mob/user)
	if(!inserted_key)
		return NONE
	if(engine_on)
		to_chat(user, span_warning("Сначала заглушите двигатель, чтобы извлечь ключ."))
		return CLICK_ACTION_BLOCKING
	if(!is_occupant(user))
		to_chat(user, span_warning("Вы должны находиться на мотоцикле, чтобы извлечь ключ!"))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("Вы извлекаете ключ из замка зажигания."))
	inserted_key.forceMove_turf()
	user.put_in_hands(inserted_key)
	inserted_key = null
	return CLICK_ACTION_SUCCESS

/obj/vehicle/ridden/motorbike/attackby(obj/item/I, mob/user, params)
	// Keys always go to the base ignition logic, never into storage
	if(is_key(I))
		return ..()

	// Refueling from any reagent container holding fuel
	if(is_reagent_container(I))
		var/obj/item/reagent_containers/fuel_container = I
		if(fuel_container.reagents?.has_reagent("fuel"))
			pour_fuel(fuel_container, user)
			return ATTACK_CHAIN_BLOCKED_ALL

	// Everything else goes into internal storage if it fits
	if(storage && storage.attempt_insert(I))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/// Transfers fuel from the container into the bike's tank.
/obj/vehicle/ridden/motorbike/proc/pour_fuel(obj/item/reagent_containers/container, mob/user)
	if(!container.is_open_container())
		balloon_alert(user, "сначала откройте контейнер!")
		return
	if(fuel_count >= fuel_max)
		balloon_alert(user, "бак полный!")
		return
	var/pour_amount = min(container.amount_per_transfer_from_this, container.reagents.get_reagent_amount("fuel"), fuel_max - fuel_count)
	if(pour_amount <= 0)
		return
	container.reagents.remove_reagent("fuel", pour_amount)
	fuel_count += pour_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, TRUE)
	balloon_alert(user, "[round(fuel_count / fuel_max * 100)]%")
	to_chat(user, span_notice("Залито <b>[pour_amount]</b> ед. топлива ([round(fuel_count / fuel_max * 100)]% бака)."))

/obj/vehicle/ridden/motorbike/welder_act(mob/living/user, obj/item/welder)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(DOING_INTERACTION(user, src))
		balloon_alert(user, "вы уже чините это!")
		return
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "не повреждено!")
		return
	if(!welder.tool_start_check(user, amount = 1))
		return
	audible_message(span_hear("Вы слышите звук сварки."))
	var/did_repair = FALSE
	while(obj_integrity < max_integrity)
		if(welder.use_tool(src, user, 2 SECONDS, volume = 50))
			did_repair = TRUE
			repair_damage(10)
			audible_message(span_hear("Вы слышите звук сварки."))
		else
			break
	if(did_repair)
		balloon_alert(user, obj_integrity >= max_integrity ? "полностью отремонтировано" : "частично отремонтировано")
	else
		balloon_alert(user, "ремонт прерван")

/obj/vehicle/ridden/motorbike/obj_break(damage_flag)
	if(!particles)
		particles = new /particles/smoke/burning()
		particles.position = list(0, 0, 0)
	return ..()

/obj/vehicle/ridden/motorbike/process()
	if(obj_integrity > integrity_failure)
		QDEL_NULL(particles)
		return PROCESS_KILL

/obj/vehicle/ridden/motorbike/obj_destruction(damage_flag)
	explosion(get_turf(src), 0, 0, 2, 0)
	return ..()

/*
 * Internal storage of the motorbike. Opened via Alt+LMB on the bike, items are inserted by clicking the bike with them.
 */
/obj/item/storage/motorbike_pack
	name = "внутреннее хранилище"
	desc = "Небольшие отсеки для хранения вещей, встроенные в мотоцикл."
	storage_slots = 4
	max_combined_w_class = 8
