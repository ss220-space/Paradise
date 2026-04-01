#define EXTINGUISHER_TEMP_MED (T0C + 45)
#define EXTINGUISHER_TEMP_HIGH (T0C + 75)
#define EXTINGUISHER_TEMP_ULTRA T100C
#define EXTINGUISHER_TEMP_DETONATION (T100C + 35)
#define EXTINGUISHER_EXPLOSION_FRAME_DELAY (0.2 SECONDS)
#define EXTINGUISHER_STEAM_BY_VOLUME_MULTIPLIER 0.2

/obj/item/extinguisher
	name = "fire extinguisher"
	desc = "Традиционный красный огнетушитель."
	icon = 'icons/obj/tools.dmi'
	icon_state = "fire_extinguisher0"
	base_icon_state = "fire_extinguisher"
	item_state = "fire_extinguisher"
	hitsound = 'sound/weapons/smash.ogg'
	flags = CONDUCT
	throwforce = 10
	force = 10
	container_type = AMOUNT_VISIBLE
	materials = list(MAT_METAL=90)
	attack_verb = list("огрел", "ударил", "стукнул")
	dog_fashion = /datum/dog_fashion/back
	resistance_flags = FIRE_PROOF
	/// The max amount of water this extinguisher can hold.
	var/max_water = 50
	/// Does the welder extinguisher start with water.
	var/starting_water = TRUE
	/// Cooldown between uses.
	COOLDOWN_DECLARE(last_use)
	/// Can we actually fire currently?
	var/safety = TRUE
	/// Maximum distance launched water will travel.
	var/power = 5
	/// By default, turfs picked from a spray are random, set to TRUE to make it always have at least one water effect per row.
	var/precision = FALSE
	/// Sets the cooling_temperature of the water reagent datum inside of the extinguisher when it is refilled.
	var/cooling_power = 2
	/// Is extinguisher can explode on heating
	var/can_explode = TRUE
	/// Detects when extinguisher exploding
	var/blowing_up = FALSE

/obj/item/extinguisher/get_ru_names()
	return list(
		NOMINATIVE = "огнетушитель",
		GENITIVE = "огнетушителя",
		DATIVE = "огнетушителю",
		ACCUSATIVE = "огнетушитель",
		INSTRUMENTAL = "огнетушителем",
		PREPOSITIONAL = "огнетушителе",
	)

/obj/item/extinguisher/mini
	name = "pocket fire extinguisher"
	desc = "Лёгкая и компактная модель огнетушителя в фиберглассовом корпусе."
	icon_state = "miniFE0"
	base_icon_state = "miniFE"
	item_state = "miniFE"
	hitsound = null	//it is much lighter, after all.
	flags = null //doesn't CONDUCT
	throwforce = 2
	w_class = WEIGHT_CLASS_SMALL
	force = 3
	materials = list()
	max_water = 30
	dog_fashion = null
	toolbox_radial_menu_compatibility = TRUE
	can_explode = FALSE

/obj/item/extinguisher/mini/get_ru_names()
	return list(
		NOMINATIVE = "карманный огнетушитель",
		GENITIVE = "карманного огнетушителя",
		DATIVE = "карманному огнетушителю",
		ACCUSATIVE = "карманный огнетушитель",
		INSTRUMENTAL = "карманным огнетушителем",
		PREPOSITIONAL = "карманном огнетушителе",
	)

/obj/item/extinguisher/Initialize(mapload)
	. = ..()
	if(!reagents && starting_water)
		create_reagents(max_water)
		reagents.add_reagent("water", max_water)

	if(!can_explode)
		return .

	reagents.set_reacting(FALSE)
	RegisterSignal(src, COMSIG_MOVABLE_IMPACT, PROC_REF(steam_explosion))

/obj/item/extinguisher/examine(mob/user)
	. = ..()
	. += span_notice("Предохранитель <b>[safety ? "включён" : "выключен"]</b>.")

/obj/item/extinguisher/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	burn_hands(user)

/obj/item/extinguisher/proc/burn_hands(mob/user)
	if(!user || !ishuman(user))
		return

	var/mob/living/carbon/human/holding_human = user

	if(!holding_human.is_in_hands(src) || reagents.chem_temp < EXTINGUISHER_TEMP_HIGH)
		return

	if(holding_human.gloves && holding_human.gloves.heat_protection)
		return

	holding_human.apply_damage(3, BURN, pick(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND))
	to_chat(holding_human, span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] невыносимо обжигает вам ладони!"))

/obj/item/extinguisher/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!I.get_temperature())
		return .

	update_appearance(UPDATE_ICON_STATE)
	explode_at_heat()
	burn_hands(user)

/obj/item/extinguisher/update_icon_state()
	if(blowing_up)
		return

	if(can_explode && safety && reagents && reagents.reagent_list.len)
		var/temp = reagents.chem_temp

		if(temp >= EXTINGUISHER_TEMP_DETONATION)
			icon_state = "[base_icon_state]_temp_detonate"
			return
		if(temp >= EXTINGUISHER_TEMP_ULTRA)
			icon_state = "[base_icon_state]_temp_ultra"
			return
		if(temp >= EXTINGUISHER_TEMP_HIGH)
			icon_state = "[base_icon_state]_temp_high"
			return
		if(temp >= EXTINGUISHER_TEMP_MED)
			icon_state = "[base_icon_state]_temp_med"
			return

	icon_state = "[base_icon_state][!safety]"

/obj/item/extinguisher/update_desc(updates = ALL)
	. = ..()
	desc = "Предохранитель [safety ? "включён" : "выключен"]."

/obj/item/extinguisher/attack_self(mob/user)
	if(blowing_up)
		return

	user.visible_message(
		span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] возится с предохранителем [declent_ru(GENITIVE)]."),
		span_notice("Вы начинаете [safety ? "снимать" : "ставить"] предохранитель...")
	)

	if(!user || !do_after(user, 0.5 SECONDS, target = src) || QDELETED(src))
		return

	safety = !safety

	if(!reagents)
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		return

	if(safety)
		reagents.set_reacting(FALSE)
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		return

	reagents.set_reacting(TRUE)
	var/temp = reagents.chem_temp

	if(temp >= EXTINGUISHER_TEMP_ULTRA)
		to_chat(user, span_userdanger("Как только вы вытаскиваете чеку, [declent_ru(NOMINATIVE)] ошпаривает вас паром!"))
		playsound(src, 'sound/effects/refill.ogg', 50, TRUE)

		if(isliving(user))
			var/mob/living/living_user = user
			living_user.apply_damage(30, BURN, spread_damage = TRUE)
			living_user.emote("scream")
			reagents.chem_temp = T20C

		reagents.clear_reagents()

	else if(temp >= EXTINGUISHER_TEMP_HIGH && temp < EXTINGUISHER_TEMP_ULTRA)
		reagents.chem_temp = EXTINGUISHER_TEMP_MED

	else
		reagents.chem_temp = T20C

	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

/obj/item/extinguisher/proc/explode_at_heat()
	if(!safety || blowing_up || !reagents || !reagents.reagent_list.len)
		return

	var/temp = reagents.chem_temp

	if(temp >= EXTINGUISHER_TEMP_DETONATION)
		visible_message(span_userdanger("[DECLENT_RU_CAP(src, NOMINATIVE)] разрывается от чудовищного давления!"))
		if(QDELETED(src))
			return

		INVOKE_ASYNC(src, PROC_REF(steam_explosion))
		return

	if(temp < EXTINGUISHER_TEMP_ULTRA)
		return

	if(prob(20))
		visible_message(span_danger("Корпус [declent_ru(GENITIVE)] не выдерживает и лопается!"))
		if(QDELETED(src))
			return

		INVOKE_ASYNC(src, PROC_REF(steam_explosion))
		return

	playsound(src, 'sound/effects/refill.ogg', 30, TRUE)

/obj/item/extinguisher/fire_act(exposed_temperature, exposed_volume)
	..()

	if(QDELETED(src) || !reagents || !reagents.reagent_list.len || blowing_up)
		return

	update_appearance(UPDATE_ICON_STATE)
	explode_at_heat()

/obj/item/extinguisher/attack_obj(obj/object, mob/living/user, params)
	if(AttemptRefill(object, user))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/extinguisher/proc/AttemptRefill(atom/target, mob/user)
	if(!istype(target, /obj/structure/reagent_dispensers/watertank) || !target.Adjacent(user))
		return FALSE
	var/safety_save = safety
	safety = TRUE
	if(reagents.total_volume == reagents.maximum_volume)
		to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] уже полностью заправлен!"))
	else
		var/obj/structure/reagent_dispensers/watertank/watertank = target
		var/transferred = watertank.reagents.trans_to(src, max_water)
		if(transferred > 0)
			to_chat(user, span_notice("[DECLENT_RU_CAP(src, NOMINATIVE)] был заправлен на [transferred] единиц[DECL_SEC_MIN(transferred)]."))
			playsound(loc, 'sound/effects/refill.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
			for(var/datum/reagent/water/reagent in reagents.reagent_list)
				reagent.cooling_temperature = cooling_power
		else
			to_chat(user, span_notice("[DECLENT_RU_CAP(watertank, NOMINATIVE)] пуст!"))
	safety = safety_save
	return TRUE

/obj/item/extinguisher/afterattack(atom/target, mob/user, flag, params)
	. = ..()
	//TODO; Add support for reagents in water.
	if(target.loc == user)//No more spraying yourself when putting your extinguisher away
		return

	if(safety)
		return

	if(reagents.total_volume < 1)
		to_chat(user, span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] пуст."))
		return

	if(!COOLDOWN_FINISHED(src, last_use))
		return
	COOLDOWN_START(src, last_use, 2 SECONDS)

	if(reagents.chem_temp > 300 || reagents.chem_temp < 280)
		add_attack_logs(user, target, "Sprayed with superheated or cooled fire extinguisher at Temperature [reagents.chem_temp]K")
	playsound(loc, 'sound/effects/extinguish.ogg', 75, TRUE, -3)

	var/direction = get_dir(src,target)

	if(user.buckled && isobj(user.buckled) && !user.buckled.anchored)
		var/movementdirection = REVERSE_DIR(direction)
		addtimer(CALLBACK(src, PROC_REF(move_chair), user.buckled, movementdirection), 0.1 SECONDS)
		if(prob(20))
			user.buckled.unbuckle_mob(user)
			var/mob/living/living = user
			if(istype(living))
				living.Knockdown(1 SECONDS)
	else
		user.newtonian_move(REVERSE_DIR(direction))

	//Get all the turfs that can be shot at
	var/turf/T = get_turf(target)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)
	if(precision)
		var/turf/T3 = get_step(T1, turn(direction, 90))
		var/turf/T4 = get_step(T2,turn(direction, -90))
		the_targets.Add(T3,T4)

	var/list/water_particles = list()
	for(var/a in 1 to 5)
		var/obj/effect/particle_effect/water/extinguisher/water = new (get_turf(src))
		var/my_target = pick(the_targets)
		water_particles[water] = my_target
		// If precise, remove turf from targets so it won't be picked more than once
		if(precision)
			the_targets -= my_target
		var/datum/reagents/water_reagents = new(5)
		water.reagents = water_reagents
		water_reagents.my_atom = water
		reagents.trans_to(water, 1)

	//Make em move dat ass, hun
	move_particles(water_particles)

//Particle movement loop
/obj/item/extinguisher/proc/move_particles(list/particles)
	var/delay = 2
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/extinguisher/water as anything in particles)
		water.move_at(particles[water], delay, power)

//Chair movement loop
/obj/item/extinguisher/proc/move_chair(obj/buckled_object, movementdirection)
	var/datum/move_loop/loop = GLOB.move_manager.move(buckled_object, movementdirection, 1, timeout = 9, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	//This means the chair slowing down is dependant on the extinguisher existing, which is weird
	//Couldn't figure out a better way though
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(manage_chair_speed))

/obj/item/extinguisher/proc/manage_chair_speed(datum/move_loop/move/source)
	SIGNAL_HANDLER
	switch(source.lifetime)
		if(4 to 5)
			source.delay = 2
		if(1 to 3)
			source.delay = 3

/obj/item/extinguisher/proc/steam_explosion()
	SIGNAL_HANDLER

	if(!can_explode || blowing_up || !reagents || !reagents.reagent_list.len || !safety)
		return

	var/temp = reagents.chem_temp
	if(temp < EXTINGUISHER_TEMP_HIGH)
		return

	blowing_up = TRUE

	playsound(src, 'sound/effects/refill.ogg', 30, TRUE)

	var/list/animation_steps = list(
		list("icon" = "[base_icon_state]_temp_high", "delay" = EXTINGUISHER_EXPLOSION_FRAME_DELAY, "temp_check" = EXTINGUISHER_TEMP_ULTRA),
		list("icon" = "[base_icon_state]_temp_ultra", "delay" = EXTINGUISHER_EXPLOSION_FRAME_DELAY, "temp_check" = EXTINGUISHER_TEMP_DETONATION),
		list("icon" = "[base_icon_state]_temp_detonate", "delay" = EXTINGUISHER_EXPLOSION_FRAME_DELAY, "temp_check" = INFINITY)
	)

	var/current_delay = 0
	for(var/list/step as anything in animation_steps)
		if(temp >= step["temp_check"])
			continue

		addtimer(CALLBACK(src, PROC_REF(set_icon_state), step["icon"]), current_delay)
		current_delay += step["delay"]

	addtimer(CALLBACK(src, PROC_REF(finalize_steam_explosion)), current_delay)

/obj/item/extinguisher/proc/finalize_steam_explosion()
	if(QDELETED(src) || !reagents || !reagents.reagent_list.len)
		return

	var/turf/landed_turf = get_turf(src)
	if(!landed_turf)
		return

	explosion(landed_turf, 0, 0, 1, 2, cause = src)
	playsound(landed_turf, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	visible_message(span_danger("[declent_ru(NOMINATIVE)] разрывается от давления пара!"))
	var/datum/effect_system/fluid_spread/smoke/bad/steam = new()
	var/smoke_amount = floor(reagents.total_volume * EXTINGUISHER_STEAM_BY_VOLUME_MULTIPLIER)
	steam.set_up(amount = smoke_amount, location = landed_turf)
	steam.start()

	for(var/mob/living/living in range(3, landed_turf))
		living.Confused(10 SECONDS)

	qdel(src)

/obj/item/extinguisher/proc/set_icon_state(new_state)
	if(!blowing_up)
		return
	icon_state = new_state

#undef EXTINGUISHER_TEMP_MED
#undef EXTINGUISHER_TEMP_HIGH
#undef EXTINGUISHER_TEMP_ULTRA
#undef EXTINGUISHER_TEMP_DETONATION
#undef EXTINGUISHER_EXPLOSION_FRAME_DELAY
#undef EXTINGUISHER_STEAM_BY_VOLUME_MULTIPLIER
