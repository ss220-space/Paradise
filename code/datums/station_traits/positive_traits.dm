#define PARTY_COOLDOWN_LENGTH_MIN (4 MINUTES) //5-10
#define PARTY_COOLDOWN_LENGTH_MAX (8 MINUTES)

/datum/station_trait/lucky_winner
	name = "Бесплатная пицца"
	report_message = "Ваша станция победила в еженедельной лотерее по выдаче бесплатной пиццы. Ожидайте прибытие пода с пиццой каждые несколько минут."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	trait_processes = TRUE
	COOLDOWN_DECLARE(party_cooldown)
	/// List of areas to drop pizza
	var/static/list/bar_areas = list(
		/area/crew_quarters/bar/atrium,
		/area/crew_quarters/serviceyard,
	)
	force = 1

/datum/station_trait/lucky_winner/on_round_start()
	. = ..()
	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

/datum/station_trait/lucky_winner/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

	var/choosen_areas = list()
	for(var/area/bar_area as anything in GLOB.areas)
		if(is_type_in_list(bar_area, bar_areas))
			choosen_areas += bar_area

	var/normal_turfs = list()
	for(var/area/area_to_drop in choosen_areas)
		for(var/list/zlevel_turfs as anything in area_to_drop.get_zlevel_turf_lists())
			for(var/turf/current_turf as anything in zlevel_turfs)
				if(iswallturf(current_turf))
					continue
				normal_turfs += current_turf

	var/choosen_turf = pick(normal_turfs)


	var/obj/structure/closet/supplypod/pod = new /obj/structure/closet/supplypod/podspawn()

	var/pizza_type_to_spawn = pick(list(
		/obj/item/pizzabox/margherita,
		/obj/item/pizzabox/mushroom,
		/obj/item/pizzabox/meat,
		/obj/item/pizzabox/vegetable,
		/obj/item/pizzabox/hawaiian,
	))
	new pizza_type_to_spawn(pod)

	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/drinks/cans/beer(pod)

	new /obj/effect/pod_landingzone(choosen_turf, pod)

#undef PARTY_COOLDOWN_LENGTH_MIN
#undef PARTY_COOLDOWN_LENGTH_MAX
