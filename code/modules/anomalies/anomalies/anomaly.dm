/obj/effect/anomaly
	name = "аномалия"
	desc = "Загадочная аномалия, обычно наблюдаемая только в секторе станции..."
	icon_state = "bhole3"
	gender = FEMALE
	anchored = TRUE
	alpha = 0
	light_range = 3
	layer = ABOVE_ALL_MOB_LAYER
	/// Type of core that will be dropped after stabilisation.
	var/core_type = /obj/item/toy/plushie/blahaj/twohanded
	/// Type of anomaly of the next tier.
	var/stronger_anomaly_type = null
	/// Type of anomaly of the prew tier.
	var/weaker_anomaly_type = null
	/// Name of the type of anomaly.
	var/anomaly_type = ANOMALY_TYPE_RANDOM
	/// Tier of anomaly.
	var/tier = 0
	/// Level of strenght. Affects the effects of anomaly.
	var/strenght = 100
	/// Anomaly stability. Affects speed and strenght change.
	var/stability = 50
	/// List of impulses types.
	var/list/impulses_types = list()
	/// List of impulses datums.
	var/list/datum/anomaly_impulse/impulses = list()

/obj/effect/anomaly/Initialize(spawnloc, spawn_strenght = rand(30, 70), spawn_stability = rand(10, 29))
	. = ..()
	if(!get_area(src))
		return INITIALIZE_HINT_QDEL

	var/matrix/M = matrix()
	M.Scale(0.1, 0.1)
	animate(src, transform = M, time = 0)
	var/mult = (spawn_strenght + 50) / 100 * 20
	mult *= tier * tier
	M.Scale(mult, mult)
	animate(src, transform = M, time = 1 SECONDS, alpha = 255)

	set_strenght(spawn_strenght)
	stability = spawn_stability

	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)

	for(var/imp_type in impulses_types)
		impulses.Add(new imp_type(src))

	for(var/datum/anomaly_impulse/imp in impulses)
		addtimer(CALLBACK(imp, TYPE_PROC_REF(/datum/anomaly_impulse, impulse_cycle)), rand(0, imp.scale_by_strenght(imp.period_low, imp.period_high)))

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/anomaly/proc/get_move_dir()
	return pick(GLOB.alldirs)

// It is in function because the size will change depending on the strength of the anomaly.
/obj/effect/anomaly/proc/set_strenght(new_strenght)
	var/matrix/M = matrix()
	var/mult = (new_strenght + 50) / (strenght + 50)
	M.Scale(mult, mult)
	animate(src, transform = M, time = 0)
	strenght = new_strenght

/obj/effect/anomaly/proc/collapse()
	visible_message(span_warning("Вы видите как [src] достигает критической массы, в следствии чего, разрушается!"))
	var/matrix/M = matrix()
	var/mult = 3
	M.Scale(mult, mult)
	animate(src, transform = M, time = 1 SECONDS, alpha = 0)
	sleep(1 SECONDS)
	qdel(src)

/obj/effect/anomaly/proc/stabilyse()
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(tier * 3, FALSE, loc)
	smoke.start()

	new core_type(loc)
	GLOB.poi_list.Remove(src)
	qdel(src)

/obj/effect/anomaly/proc/level_down()
	if(!weaker_anomaly_type)
		var/matrix/M = matrix()
		M.Scale(0, 0)
		animate(src, transform = M, time = 1 SECONDS)
		visible_message(span_warning("Вы видите как [src] полностью угасает!"))
		sleep(1 SECONDS)
		qdel(src)
	else
		visible_message(span_warning("Вы видите как [src] значительно слабеет!"))
		new weaker_anomaly_type(loc, rand(50, 80), clamp(stability + rand(10, 20), 0, 100))
		qdel(src)

/obj/effect/anomaly/proc/level_up()
	if(!stronger_anomaly_type)
		collapse()
	else
		visible_message(span_warning("Вы видите как [src] становится значительно опасней!"))
		new stronger_anomaly_type(loc, rand(20, 50), clamp(stability - rand(10, 20), 0, 100))
		qdel(src)

/obj/effect/anomaly/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(ismob(mover))
		return mob_touch_effect(mover)

	if(isitem(mover))
		return item_touch_effect(mover)


/obj/effect/anomaly/proc/mob_touch_effect(mob/living/M)
	return TRUE

/obj/effect/anomaly/proc/item_touch_effect(obj/item/I)
	. = TRUE
	if(!istype(I))
		return

	if(!I.origin_tech)
		return

	if (prob(2))
		do_sparks(5, TRUE, src)
		new /obj/item/relic(get_turf(I))
		qdel(I)
		return

	if (!istype(I, /obj/item/relict_production/rapid_dupe))
		return

	var/amount = rand(1, 3)
	for (var/i; i <= amount; i++)
		new /obj/item/relic(get_turf(I))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(5, get_turf(I))
		smoke.start()

	qdel(I)

/obj/effect/anomaly/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	mob_touch_effect(user)

/obj/effect/anomaly/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	mob_touch_effect(user)

/obj/effect/anomaly/Bumped(atom/movable/moving_atom)
	. = ..()
	item_touch_effect(moving_atom)

/obj/effect/anomaly/proc/after_move()
	for(var/obj/item/I in get_turf(src))
		item_touch_effect(I)

	for(var/mob/living/M in get_turf(src))
		mob_touch_effect(M)

/obj/effect/anomaly/proc/move()
	step(src, get_move_dir())
	return TRUE

/obj/effect/anomaly/process()
	if(stability < 30)
		set_strenght(strenght + 1)

	if(stability > 70)
		set_strenght(strenght - 1)

	if(strenght == 100)
		if(stability >= 50)
			level_up()
		else
			collapse()

		return

	if(stability == 100)
		stabilyse()
		return

	if(!strenght)
		level_down()
		return

	if(!prob(strenght))
		return

	if(move())
		after_move()
