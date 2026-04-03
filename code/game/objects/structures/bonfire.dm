/// How many fire stacks are applied when you step into a bonfire
#define BONFIRE_FIRE_STACK_STRENGTH 5

/**
 * ## BONFIRES
 *
 * Structure that makes a big old fire. You can add rods to construct a grill for grilling meat, or a stake for buckling people to the fire,
 * salem style. Keeping the fire on requires oxygen. You can dismantle the bonfire back into logs when it is unignited.
 */
/obj/structure/bonfire
	name = "bonfire"
	desc = "Для приготовления пищи, включая жарку, копчение, обугливание, запекание, поджаривание, тушение, обжиг, плавление, а иногда и для сжигания вещей."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "bonfire"
	light_color = LIGHT_COLOR_FIRE
	anchored = TRUE
	buckle_lying = 0
	pass_flags_self = PASSTABLE | LETPASSTHROW
	/// is the bonfire lit?
	var/burning = FALSE
	/// the looping sound effect that is played while burning
	var/datum/looping_sound/burning/burning_loop
	/// is the rod installed?
	var/rod_installed = FALSE
	/// Who lit the fucking thing
	var/lighter

/obj/structure/bonfire/get_ru_names()
	return list(
		NOMINATIVE = "костёр",
		GENITIVE = "костра",
		DATIVE = "костру",
		ACCUSATIVE = "костёр",
		INSTRUMENTAL = "костром",
		PREPOSITIONAL = "костре",
	)

/obj/structure/bonfire/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	burning_loop = new(src)

/obj/structure/bonfire/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(burning_loop)
	return ..()

/obj/structure/bonfire/update_icon_state()
	icon_state = "bonfire[burning ? "_on_fire" : ""]"

/obj/structure/bonfire/update_overlays()
	. = ..()
	underlays.Cut()
	if(!rod_installed)
		return

	var/static/mutable_appearance/rod
	if(isnull(rod))
		rod = mutable_appearance('icons/obj/hydroponics/equipment.dmi', "bonfire_rod")
		rod.pixel_z = 16

	underlays += rod

/obj/structure/bonfire/attackby(obj/item/used_item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(used_item, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = used_item
		if(rod_installed)
			to_chat(user, span_warning("На [declent_ru(PREPOSITIONAL)] уже установлен металлический стержень."))
			return ATTACK_CHAIN_PROCEED

		if(!rods.use(1))
			to_chat(user, span_warning("Для этого вам потребуется как минимум один стержень."))
			return ATTACK_CHAIN_PROCEED

		user.visible_message(
			span_notice("[user] устанавлива[PLUR_ET_YUT(user)] центральный стержень внутри [declent_ru(GENITIVE)]."),
			span_notice("Вы установили металлический стержень внутри [declent_ru(GENITIVE)]."),
		)
		rod_installed = TRUE
		can_buckle = TRUE
		buckle_requires_restraints = TRUE
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(used_item.get_temperature() >= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
		start_burning()
		add_fingerprint(user)
		lighter = user.ckey
		add_misc_logs(user, "lit a bonfire", src)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/structure/bonfire/attack_hand(mob/user)
	if(burning)
		to_chat(user, span_warning("Перед извлечением поленьев необходимо потушить [declent_ru(ACCUSATIVE)]!"))
		return

	if(!has_buckled_mobs() && do_after(user, 5 SECONDS, src))
		for(var/i in 1 to 5)
			var/obj/item/grown/log/log = new(loc)
			log.set_base_pixel_x(rand(1, 4))
			log.set_base_pixel_y(rand(1, 4))
			log.add_fingerprint(user)
			transfer_fingerprints_to(log)

		if(rod_installed)
			var/obj/item/stack/rods/rod = new(loc)
			rod.add_fingerprint(user)
			transfer_fingerprints_to(rod)
		qdel(src)
		return

	return ..()

/// Check if we're standing in an oxygenless environment
/obj/structure/bonfire/proc/check_oxygen()
	var/turf/turf = get_turf(src)
	var/datum/gas_mixture/gas = turf.get_readonly_air()
	if(gas.oxygen() > 8)
		return TRUE

	return FALSE

/obj/structure/bonfire/proc/start_burning()
	if(burning && !check_oxygen())
		return

	burning_loop.start()
	burning = TRUE
	update_icon(UPDATE_ICON_STATE)
	set_light(6, l_on = TRUE)
	bonfire_burn()
	particles = new /particles/bonfire()
	START_PROCESSING(SSobj, src)

/obj/structure/bonfire/fire_act(exposed_temperature, exposed_volume)
	..()
	start_burning()

/obj/structure/bonfire/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(burning)
		return

	// Not currently burning, let's see if we can ignite it.
	if(isliving(entered))
		var/mob/living/burning_body = entered
		if(burning_body.on_fire)
			start_burning()
			visible_message(span_notice("[entered] пробегает по [declent_ru(DATIVE)], зажигая его!"))

	else if(entered.resistance_flags & ON_FIRE)
		start_burning()
		visible_message(span_notice("Огонь с [entered] перекидывается на [declent_ru(ACCUSATIVE)], поджигая его!"))

	var/mob/living/carbon/human/arrived = entered
	if(ishuman(arrived) && arrived.mind)
		add_attack_logs(src, arrived, "Burned by a bonfire (Lit by [lighter ? lighter : "Unknown"])", ATKLOG_ALMOSTALL)

/obj/structure/bonfire/proc/bonfire_burn(seconds_per_tick = 2)
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000, 250 * seconds_per_tick)
	for(var/burn_target in current_location)
		if(burn_target == src)
			continue
		if(isliving(burn_target))
			var/mob/living/burn_victim = burn_target
			burn_victim.adjust_fire_stacks(BONFIRE_FIRE_STACK_STRENGTH * 0.5 * seconds_per_tick)
			burn_victim.IgniteMob()
			continue
		var/atom/movable/burned_movable = burn_target
		burned_movable.fire_act(1000, 250 * seconds_per_tick)

/obj/structure/bonfire/process(seconds_per_tick)
	if(!check_oxygen())
		extinguish()
		return
	bonfire_burn(seconds_per_tick)

/obj/structure/bonfire/extinguish()
	if(!burning)
		return

	burning_loop.stop()
	burning = FALSE
	update_icon(UPDATE_ICON_STATE)
	set_light_on(FALSE)
	QDEL_NULL(particles)
	STOP_PROCESSING(SSobj, src)

/obj/structure/bonfire/extinguish_light(force = FALSE)
	if(force)
		extinguish()

/obj/structure/bonfire/post_buckle_mob(mob/living/target)
	target.pixel_y += 13

/obj/structure/bonfire/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 13

/obj/structure/bonfire/dense
	density = TRUE

/obj/structure/bonfire/dense/prelit/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/bonfire/dense/prelit/LateInitialize()
	start_burning()

/obj/structure/bonfire/prelit/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

// Late init so that we can wait for air to exist in lazyloaded templates
/obj/structure/bonfire/prelit/LateInitialize()
	start_burning()

#undef BONFIRE_FIRE_STACK_STRENGTH
