/obj/item/storm_staff
	name = "staff of storms"
	desc = "Древний посох, извлечённый из останков Легиона. Ветер колышется, когда вы двигаете им."
	ru_names = list(
		NOMINATIVE = "посох бурь",
		GENITIVE = "посоха бурь",
		DATIVE = "посоху бурь",
		ACCUSATIVE = "посох бурь",
		INSTRUMENTAL = "посохом бурь",
		PREPOSITIONAL = "посохе бурь"
	)
	icon_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	item_state = "staffofstorms"
	icon = 'icons/obj/weapons/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 25
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	needs_permit = TRUE
	var/max_thunder_charges = 3
	var/thunder_charges = 3
	var/thunder_charge_time = 15 SECONDS
	var/static/list/excluded_areas = list(/area/space)
	///This is a list of turfs currently being targeted.
	var/list/targeted_turfs = list()

/obj/item/storm_staff/Destroy()
	targeted_turfs = null
	return ..()

/obj/item/storm_staff/examine(mob/user)
	. = ..()
	. += span_notice("Осталось зарядов: [thunder_charges].")
	. += span_notice("Используйте в руке, чтобы рассеять бурю.")
	. += span_notice("Используйте на цели, чтобы призвать молнии с небес.")
	. += span_notice("Молнии усиливаются в зоне погодных аномалий.")

/obj/item/storm_staff/attack_self(mob/user)
	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)
	if(!user_area || !user_turf)
		to_chat(user, span_warning("Что-то мешает вам использовать посох здесь."))
		return
	var/datum/weather/A
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((user_turf.z in W.impacted_z_levels) && W.area_type == user_area.type)
			A = W
			break

	if(A)
		if(A.stage != END_STAGE)
			if(A.stage == WIND_DOWN_STAGE)
				to_chat(user, span_warning("Буря уже стихает! Использовать посох сейчас было бы расточительством."))
				return
			user.visible_message(
				span_warning("[user] поднима[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)] к небу, и оранжевый луч устремляется ввысь!"),
				span_notice("Вы поднимаете [declent_ru(ACCUSATIVE)] к небу, рассеивая бурю!")
			)
			playsound(user, 'sound/magic/staff_change.ogg', 200, FALSE)
			A.wind_down()
			var/old_color = user.color
			user.color = list(340/255, 240/255, 0,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
			var/old_transform = user.transform
			user.transform *= 1.2
			animate(user, color = old_color, transform = old_transform, time = 1 SECONDS)

/obj/item/storm_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!thunder_charges)
		to_chat(user, span_warning("Посох должен перезарядиться."))
		return
	var/turf/target_turf = get_turf(target)
	var/area/target_area = get_area(target)
	var/area/user_area = get_area(user)
	if(!target_turf || !target_area || (is_type_in_list(target_area, excluded_areas)) || !user_area || (is_type_in_list(user_area, excluded_areas)))
		to_chat(user, span_warning("Посох не будет работать здесь."))
		return
	if(target_turf in targeted_turfs)
		to_chat(user, span_warning("Это место УЖЕ под ударом!"))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("Вы не хотите никому вредить!"))
		return
	var/power_boosted = FALSE
	for(var/V in SSweather.processing)
		var/datum/weather/W = V
		if((target_turf.z in W.impacted_z_levels) && W.area_type == target_area.type)
			power_boosted = TRUE
			break
	playsound(src, 'sound/magic/lightningshock.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	targeted_turfs += target_turf
	to_chat(user, span_warning("Вы целитесь в [target_turf.declent_ru(ACCUSATIVE)]!"))
	new /obj/effect/temp_visual/thunderbolt_targeting(target_turf)
	addtimer(CALLBACK(src, PROC_REF(throw_thunderbolt), target_turf, power_boosted), 1.5 SECONDS)
	thunder_charges--
	addtimer(CALLBACK(src, PROC_REF(recharge)), thunder_charge_time)

/obj/item/storm_staff/proc/recharge(mob/user)
	thunder_charges = min(thunder_charges + 1, max_thunder_charges)
	playsound(src, 'sound/magic/charge.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

/obj/item/storm_staff/proc/throw_thunderbolt(turf/target, boosted)
	targeted_turfs -= target
	new /obj/effect/temp_visual/thunderbolt(target)
	var/list/affected_turfs = list(target)
	if(boosted)
		for(var/direction in GLOB.alldirs)
			var/turf_to_add = get_step(target, direction)
			if(!turf_to_add)
				continue
			affected_turfs += turf_to_add
	for(var/turf/T as anything in affected_turfs)
		new /obj/effect/temp_visual/electricity(T)
		for(var/mob/living/hit_mob in T)
			to_chat(hit_mob, span_userdanger("Вас поразила молния!"))
			hit_mob.electrocute_act(15 * (isanimal(hit_mob) ? 3 : 1) * (T == target ? 2 : 1) * (boosted ? 2 : 1), "штормового посоха", flags = SHOCK_NOGLOVES)

		for(var/obj/hit_thing in T)
			hit_thing.take_damage(20, BURN, ENERGY, FALSE)
	playsound(target, 'sound/magic/lightningbolt.ogg', 100, TRUE)
	target.visible_message(span_danger("Молния ударяет в [target.declent_ru(ACCUSATIVE)]!"))
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = (boosted ? 1 : 0), flame_range = (boosted ? 2 : 1), silent = TRUE)


/obj/effect/temp_visual/thunderbolt_targeting
	icon_state = "target_circle"
	layer = BELOW_MOB_LAYER
	light_range = 1
	duration = 2 SECONDS

/obj/effect/temp_visual/thunderbolt
	icon_state = "thunderbolt"
	icon = 'icons/effects/32x96.dmi'
	duration = 0.6 SECONDS

/obj/effect/temp_visual/electricity
	icon_state = "electricity3"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/flash
	icon = 'icons/effects/light_overlays/light_128.dmi'
	icon_state = "light"
	pixel_w = -64
	pixel_z = -64
	blend_mode = BLEND_OVERLAY

/obj/effect/temp_visual/flash/Initialize(mapload)
	. = ..()
	set_light(7, 99, "#C5C5FF")

/obj/effect/temp_visual/thunderbolt/fancy

/obj/effect/temp_visual/thunderbolt/fancy/Initialize(mapload, harmless = FALSE)
	new /obj/effect/temp_visual/flash(src)
	// BOOM
	playsound(src, 'sound/effects/lightning_bolt.ogg', 100, TRUE, 15, 1.2)

	for(var/mob/to_shake in range(5, src))
		shake_camera(to_shake, 10, 1)

	if(!harmless)
		explosion(src, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 1, flame_range =  2, silent = TRUE)
	. = ..()
	do_sparks(15, TRUE, src)
