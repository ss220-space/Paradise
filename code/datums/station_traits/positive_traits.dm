#define PARTY_COOLDOWN_LENGTH_MIN (4 MINUTES)
#define PARTY_COOLDOWN_LENGTH_MAX (8 MINUTES)

/datum/station_trait/lucky_winner
	name = "Бесплатная пицца"
	report_message = "Ваш объект победил в еженедельной лотерее по выдаче бесплатной пиццы. Ожидайте прибытия капсулы с пиццей каждые несколько минут."
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

/datum/station_trait/galactic_grant
	name = "Галактический грант"
	report_message = "Ваш объект был выбран для получения специального гранта. На счёт отдела снабжения было направлено дополнительное финансирование."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5

/datum/station_trait/galactic_grant/on_round_start()
	. = ..()
	var/datum/money_account/cargo_money_account = GLOB.department_accounts[STATION_DEPARTMENT_SUPPLY]
	cargo_money_account.phantom_credit(rand(5000, 10000))
	SSshuttle.points += rand(50, 100)

/datum/station_trait/premium_internals_box
	name = "Премиальные экстренные коробки"
	report_message = "Все экстренные коробки членов экипажа были дополнены различными предметами."
	show_in_report = TRUE
	weight = 5
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/glowsticks
	name = "Светящиеся палочки"
	report_message = "На складах корпорации появился переизбыток светящихся палочек, поэтому мы разбросали их по техническим туннелям вашей станции."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 2

/datum/station_trait/glowsticks/on_round_start()
	. = ..()

	INVOKE_ASYNC(src, PROC_REF(light_this_place))

/datum/station_trait/glowsticks/proc/light_this_place()
	var/list/glowsticks = list(
		/obj/item/flashlight/flare/glowstick/pink,
		/obj/item/flashlight/flare/glowstick/yellow,
		/obj/item/flashlight/flare/glowstick/orange,
		/obj/item/flashlight/flare/glowstick/blue,
		/obj/item/flashlight/flare/glowstick/red,
	)
	for(var/area/maintenance/maint in GLOB.areas)
		var/list/turfs = get_area_turfs(maint)
		for(var/i in 1 to round(length(turfs) * 0.115))
			CHECK_TICK
			var/turf/simulated/chosen = pick_n_take(turfs)
			if(!istype(chosen))
				continue
			if(iswallturf(chosen))
				continue
			var/skip_this = FALSE
			for(var/atom/movable/mov as anything in chosen) //stop glowing sticks from spawning on windows
				if(mov.density && !(mov.pass_flags_self & LETPASSTHROW))
					skip_this = TRUE
					break
			if(skip_this)
				continue
			var/stick_type = pick(glowsticks)
			var/obj/item/flashlight/flare/glowstick/stick = new stick_type(chosen)
			///we want a wider range, otherwise they'd all burn out in about 20 minutes.
			stick.turn_on()

/datum/station_trait/strong_supply_lines
	name = "Улучшенное снабжение"
	report_message = "В вашем секторе налажена галактическая торговля, от чего цены на все заказы в отделе снабжения снижены."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 2
	blacklist = list(/datum/station_trait/distant_supply_lines)

/datum/station_trait/strong_supply_lines/on_round_start()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		pack.cost *= 0.8

/datum/station_trait/filled_maint
	name = "Захламлённые технические туннели"
	report_message = "Прошлый экипаж объекта оставил гораздо больше своих личных вещей в технических туннелях."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 2
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT
	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Ускоренный шаттл снабжения"
	report_message = "Из-за близкого расположения вашего объекта к \"АКН Трурль\" шаттлу поставок потребуется гораздо меньше времени на перелёты. Шаттл эвакуации это не затронет."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5
