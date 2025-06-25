#define ANOMALY_DOUBLE_MOVE_CHANCE 5
#define ANOMALY_ITEM_TO_RELIC_CHANCE 1
#define ANOMALY_STRENGHT_MOVE_MULTIPLIER 2

/obj/effect/anomaly
	name = "аномалия"
	desc = "Загадочная аномалия. Обычно такую можно наблюдать только в станционном секторе."
	ru_names = list(
		NOMINATIVE = "аномалия", \
		GENITIVE = "аномалии", \
		DATIVE = "аномалии", \
		ACCUSATIVE = "аномалию", \
		INSTRUMENTAL = "аномалией", \
		PREPOSITIONAL = "аномалии"
	)
	icon_state = "bhole3"
	gender = FEMALE
	anchored = TRUE
	density = TRUE
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

	/// The moment from which the anomaly will be able to move.
	var/move_moment = 0
	/// The moment from which the anomaly will be able to move by impulse.
	var/move_impulse_moment = 0
	/// The amount by which the strength of the anomaly's effects is temporarily reduced.
	var/weaken = 0
	/// The moment at which the reduction in the effects of the anomaly will be reset.
	var/weaken_moment = 0
	/// Matrix used for anomaly animations.
	var/matrix/matr = matrix()
	/// Cool visual effect.
	var/obj/effect/warp_effect/supermatter/warp
	/// If FALSE, there won't be warp effect.
	var/has_warp = FALSE

/obj/effect/anomaly/proc/size_by_strenght(cur_strenght)
	if(!cur_strenght)
		cur_strenght = strenght

	return (tier * 50 + cur_strenght / 2) / 100

/obj/effect/anomaly/proc/init_animation()
	matr.Scale(0.1, 0.1)
	animate(src, transform = matr, time = 0, flags = ANIMATION_PARALLEL)
	var/mult = size_by_strenght() * 10
	matr.Scale(mult, mult)
	animate(src, transform = matr, time = 1 SECONDS, alpha = 255, flags = ANIMATION_PARALLEL)


/obj/effect/anomaly/Initialize(spawnloc, spawn_strenght = rand(20, 40), spawn_stability = rand(10, 29))
	GLOB.created_anomalies[anomaly_type]++
	. = ..()
	if(!get_area(src))
		return INITIALIZE_HINT_QDEL

	set_strenght(spawn_strenght, FALSE)
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/effect/anomaly, init_animation))
	stability = spawn_stability

	GLOB.poi_list |= src
	START_PROCESSING(SSobj, src)

	for(var/imp_type in impulses_types)
		impulses.Add(new imp_type(src))

	for(var/datum/anomaly_impulse/imp in impulses)
		addtimer(CALLBACK(imp, TYPE_PROC_REF(/datum/anomaly_impulse, impulse_cycle)), rand(0, imp.scale_by_strenght(imp.period_low, imp.period_high)))

	if(!has_warp)
		return

	warp = new(src)
	vis_contents += warp
	apply_wibbly_filters(warp)

/obj/effect/anomaly/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(!has_warp)
		return ..()

	vis_contents -= warp
	QDEL_NULL(warp)
	QDEL_LAZYLIST(impulses)
	return ..()

/obj/effect/anomaly/proc/update_warp()
	if(!warp)
		return

	warp.pixel_x = initial(warp.pixel_x) - pixel_x
	warp.pixel_y = initial(warp.pixel_x) - pixel_y
	var/scaling = (get_strenght() * (1 << (tier - 1))) / 250
	animate(warp, time = 6, transform = matrix().Scale(0.5 * scaling, 0.5 * scaling))
	animate(time = 14, transform = matrix().Scale(scaling, scaling))

/obj/effect/anomaly/proc/get_move_dir()
	return pick(GLOB.alldirs)

/obj/effect/anomaly/attack_ghost(mob/dead/observer/user)
	var/datum/browser/popup = new(user, "anomalyscanner", "Информация об аномалии", 500, 600)
	popup.set_content(chat_box_yellow("[jointext(get_data(), "<br>")]"))
	popup.open(no_focus = 1)

// It is in function because the size will change depending on the strength of the anomaly.
/obj/effect/anomaly/proc/set_strenght(new_strenght, do_anim = TRUE)
	if(do_anim)
		var/mult = size_by_strenght(new_strenght) / size_by_strenght(strenght)
		matr.Scale(mult, mult)
		animate(src, transform = matr, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL)

	strenght = clamp(new_strenght, 0, 100)
	check_size_change()

/obj/effect/anomaly/proc/collapse()
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] достигает критической массы и распадается!"))
	add_filter("collapse", 1, gauss_blur_filter(1))
	matr.Scale(3, 3)
	animate(src, transform = matr, time = 1 SECONDS, alpha = 0, flags = ANIMATION_PARALLEL)
	sleep(1 SECONDS)
	qdel(src)

/obj/effect/anomaly/proc/stabilyse()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(tier * 3, FALSE, loc)
	smoke.start()

	if(strenght < 50)
		core_type = text2path("/obj/item/assembly/signaler/core/tier[tier]")

	new core_type(loc, strenght)
	GLOB.poi_list.Remove(src)
	qdel(src)

/obj/effect/anomaly/proc/level_down()
	if(weaker_anomaly_type)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] ослабевает!"))
		new weaker_anomaly_type(loc, rand(50, 80), clamp(stability + rand(10, 20), 0, 100))
		qdel(src)
		return

	matr.Scale(0, 0)
	animate(src, transform = matr, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] теряет свою энергию и растворяется в пространстве!"))
	sleep(1 SECONDS)
	qdel(src)

/obj/effect/anomaly/proc/level_up()
	if(!stronger_anomaly_type)
		collapse()
		return

	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] становится мощнее!"))
	new stronger_anomaly_type(loc, rand(20, 50), clamp(stability - rand(10, 20), 0, 100))
	qdel(src)

/obj/effect/anomaly/proc/mob_touch_effect(mob/living/matr)
	return TRUE

/obj/effect/anomaly/proc/check_size_change()
	if(!strenght)
		level_down()
		return

	if(strenght != 100)
		return

	if(stability >= 50)
		level_up()
	else
		collapse()

/obj/effect/anomaly/proc/core_touch_effect(obj/item/assembly/signaler/core/core)
	if(!COOLDOWN_FINISHED(core, anomaly_toch_cooldown))
		return

	var/mult = core.tier <= tier ? (1 << (tier - core.tier)) : (1.0 / (1 << (core.tier - tier)))

	if(!iscoreempty(core))
		core.visible_message(span_warning("[capitalize(core.declent_ru(NOMINATIVE))] распадается, передавая свой заряд [declent_ru(DATIVE)]."))
		set_strenght(strenght + core.charge / mult)
		qdel(core)
		do_sparks(5, FALSE, src)
		return

	var/charge_delta = min(100, round(strenght / 3 * mult))
	var/new_charge = core.charge + charge_delta

	do_sparks(5, FALSE, src)
	set_strenght(strenght - round(charge_delta / mult))

	if(new_charge <= 50)
		core.charge = new_charge
		core.random_throw(3, 6, 5)
		core.visible_message(span_warning("[capitalize(core.declent_ru(NOMINATIVE))] заряжается от [declent_ru(GENITIVE)], \
											но остаётся пустым из-за слишком низкого заряда."))
		COOLDOWN_START(core, anomaly_toch_cooldown, 5 SECONDS)
		return

	var/path = "/obj/item/assembly/signaler/core/[anomaly_type]/tier[(core.tier < 4 ? core.tier : "tier3/tier4")]"
	path = text2path(path)
	var/obj/item/assembly/signaler/core/new_core = new path(core.loc, new_charge)
	COOLDOWN_START(new_core, anomaly_toch_cooldown, 5 SECONDS)
	new_core.visible_message(span_warning("[capitalize(core.declent_ru(NOMINATIVE))] заряжается от [declent_ru(GENITIVE)], \
											превращаясь в [new_core.declent_ru(ACCUSATIVE)]."))
	qdel(core)
	new_core.random_throw(3, 6, 5)
	return

/obj/effect/anomaly/proc/item_touch_effect(obj/item/item)
	. = TRUE
	if(!istype(item))
		return

	if(tier == 3 && istype(item, /obj/item/anomaly_upgrader))
		visible_message(span_danger("[capitalize(item.declent_ru(NOMINATIVE))] попадает в [declent_ru(ACCUSATIVE)], прикрепляется к ней и активируется!"))
		var/type = text2path("/obj/effect/anomaly/[anomaly_type]/tier4")
		new type(loc, rand(20, 50), clamp(stability - rand(10, 20), 0, 100))
		qdel(item)
		qdel(src)
		return FALSE

	if(iscore(item))
		var/obj/item/assembly/signaler/core/core = item
		if(core.born_moment + 1 SECONDS >= world.time)
			return TRUE

		core_touch_effect(core)
		return FALSE

	if(!item.origin_tech)
		return

	if(prob(ANOMALY_ITEM_TO_RELIC_CHANCE))
		do_sparks(5, TRUE, src)
		new /obj/item/relic(get_turf(item))
		qdel(item)
		return

	if(!istype(item, /obj/item/relict_production/rapid_dupe))
		return

	var/amount = rand(1, 3)
	for (var/i; i <= amount; i++)
		new /obj/item/relic(get_turf(item))
		//var/datum/effect_system/fluid_spread/smoke/smoke = new
		//smoke.set_up(5, get_turf(item))
		//smoke.start()

	qdel(item)

/obj/effect/anomaly/attackby(obj/item/item, mob/living/user, params)
	. = ..()
	mob_touch_effect(user)

/obj/effect/anomaly/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	mob_touch_effect(user)

/obj/effect/anomaly/Bumped(atom/movable/moving_atom)
	. = ..()
	if(isitem(moving_atom))
		item_touch_effect(moving_atom)

	if(isliving(moving_atom))
		mob_touch_effect(moving_atom)

/obj/effect/anomaly/proc/after_move()
	for(var/obj/item/item in get_turf(src))
		item_touch_effect(item)

	for(var/mob/living/matr in get_turf(src))
		mob_touch_effect(matr)

/obj/effect/anomaly/proc/normal_move()
	if(world.time > move_moment)
		return do_move(get_move_dir())

/obj/effect/anomaly/proc/do_move(dir)
	step(src, dir)
	return TRUE

/obj/effect/anomaly/proc/get_strenght()
	if(world.time > weaken_moment)
		weaken = 0

	return max(min(strenght, 10), strenght - weaken)

/obj/effect/anomaly/process()
	if(stability < ANOMALY_GROW_STABILITY)
		set_strenght(strenght + 1)

	if(stability > ANOMALY_DECREASE_STABILITY)
		set_strenght(strenght - 1)

	if(stability == 100)
		stabilyse()
		return

	if(stability > ANOMALY_MOVE_MAX_STABILITY || !prob(get_strenght() * ANOMALY_STRENGHT_MOVE_MULTIPLIER))
		return

	if(normal_move())
		after_move()

	if(ANOMALY_DOUBLE_MOVE_CHANCE && normal_move())
		after_move()

	if(has_warp)
		update_warp()

/obj/effect/anomaly/proc/go_to(target, steps)
	var/reversed = steps < 0
	if(reversed)
		steps = -steps

	for(var/i = 1 to steps)
		var/move_dir = reversed ? get_dir(target, src) : get_dir(src, target)
		do_move(move_dir)
		sleep(2)

/obj/effect/anomaly/proc/can_move_sth(obj/O) {
	if(QDELETED(O))
		return FALSE

	if(O.anchored)
		return FALSE

	if(O.move_resist >= MOVE_FORCE_OVERPOWERING)
		return FALSE

	if(O.pulledby)
		return FALSE

	if(isobserver(O))
		return FALSE

	if(iseffect(O))
		return FALSE

	return TRUE
}

/obj/effect/anomaly/singularity_act()
	collapse()

/obj/effect/anomaly/tesla_act()
	collapse()

/obj/effect/anomaly/ratvar_act()
	collapse()

/obj/effect/anomaly/narsie_act()
	collapse()

/obj/effect/anomaly/ex_act(severity)
	return

#undef ANOMALY_DOUBLE_MOVE_CHANCE
#undef ANOMALY_ITEM_TO_RELIC_CHANCE
#undef ANOMALY_STRENGHT_MOVE_MULTIPLIER
