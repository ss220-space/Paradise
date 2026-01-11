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

/datum/station_trait/deathrattle_department
	name = "Один из отделов с имплантом \"предсмертного отзвука\""// too long
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	abstract_type = /datum/station_trait/deathrattle_department
	blacklist = list(/datum/station_trait/deathrattle_all)

	var/department_to_apply_to
	var/department_name = "department"
	var/ru_department_name = "обыкновенного отдела"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_department/New()
	. = ..()
	deathrattle_group = new("[department_name] group")
	blacklist += subtypesof(/datum/station_trait/deathrattle_department) - type //All but ourselves
	report_message = "Все членам [ru_department_name] были установлены экспериментальные импланты, уведомляющие о смерти других носителей данного импланта."
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/deathrattle_department/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned)
	SIGNAL_HANDLER

	if(!(job.department = department_to_apply_to))
		return

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE)

/datum/station_trait/deathrattle_department/service
	name = "Отдел сервиса с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_SERVICE
	department_name = "Service"
	ru_department_name = "отдела сервиса"

/datum/station_trait/deathrattle_department/cargo
	name = "Отдел снабжения с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_SUPPLY
	department_name = "Cargo"
	ru_department_name = "отдела снабжения"

/datum/station_trait/deathrattle_department/engineering
	name = "Инженерный отдел с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_ENGINEERING
	department_name = "Engineering"
	ru_department_name = "инженерного отдела"

/datum/station_trait/deathrattle_department/command
	name = "Отдел командования с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_COMMAND
	department_name = "Command"
	ru_department_name = "отдела командования"

/datum/station_trait/deathrattle_department/science
	name = "Исследовательский отдел с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_SCIENCE
	department_name = "Science"
	ru_department_name = "исследовательского отдела"

/datum/station_trait/deathrattle_department/security
	name = "ОЗА с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_SECURITY
	department_name = "Security"
	ru_department_name = "отдела защиты активов"

/datum/station_trait/deathrattle_department/medical
	name = "Медицинский отдел с имплантом \"предсмертного отзвука\""
	weight = 1
	department_to_apply_to = STATION_DEPARTMENT_MEDICAL
	department_name = "Medical"
	ru_department_name = "медицинского отдела"

/datum/station_trait/deathrattle_all
	name = "Принудительная установка импланта \"предсмертного отзвука\""
	report_message = "Всему экипажу на объекте был установлен имплант, который сообщает в случае, если кто-то погибнет."
	show_in_report = TRUE
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_all/New()
	. = ..()
	deathrattle_group = new("station group")
	blacklist = subtypesof(/datum/station_trait/deathrattle_department)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/deathrattle_all/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)

/datum/station_trait/cybernetic_revolution
	name = "Расцвет кибернетики"
	report_message = "Новая мода на повальную аугментацию дошла и до вашего объекта, как мы слышали. Судя по медицинским записям, каждый член экипажа установил себе кибернетический имплант."
	show_in_report = TRUE
	weight = 1
	trait_to_give = STATION_TRAIT_CYBERNETIC_REVOLUTION
	/// List of all job types with the cybernetics they should receive.
	var/static/list/job_to_cybernetic = list(
		/datum/job/civilian = /obj/item/organ/internal/heart/cybernetic, //real cardiac
		/datum/job/head_of_staff/chief_engineer = /obj/item/organ/internal/cyberimp/arm/hacking,
		/datum/job/engineering/engineer = /obj/item/organ/internal/cyberimp/arm/toolset,
		/datum/job/engineering/atmos = /obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/datum/job/engineering/mechanic = /obj/item/organ/internal/cyberimp/eyes/shield,
		/datum/job/head_of_staff/cmo = /obj/item/organ/internal/cyberimp/arm/medibeam,
		/datum/job/medical/doctor = /obj/item/organ/internal/cyberimp/arm/surgery,
		/datum/job/medical/coroner = /obj/item/organ/internal/liver/cybernetic,
		/datum/job/medical/chemist = /obj/item/organ/internal/cyberimp/eyes/hud/science,
		/datum/job/medical/geneticist = /obj/item/organ/internal/kidneys/cybernetic,
		/datum/job/medical/virologist = /obj/item/organ/internal/lungs/cybernetic,
		/datum/job/medical/psychiatrist = /obj/item/organ/internal/cyberimp/eyes/hud/medical,
		/datum/job/medical/paramedic = /obj/item/organ/internal/cyberimp/arm/medibeam,
		/datum/job/head_of_staff/rd = /obj/item/organ/internal/cyberimp/brain/bci,
		/datum/job/science/scientist = /obj/item/organ/internal/ears/cybernetic,
		/datum/job/science/roboticist = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic,
		/datum/job/head_of_staff/hos = /obj/item/organ/internal/cyberimp/eyes/thermals,
		/datum/job/security/warden = /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/security/detective = /obj/item/organ/internal/lungs/cybernetic/upgraded,
		/datum/job/security/officer = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/security/brigdoc = /obj/item/organ/internal/cyberimp/arm/surgery,
		/datum/job/security/pilot = /obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/datum/job/head_of_staff/hop = /obj/item/organ/internal/eyes/cybernetic,
		/datum/job/service/bartender = /obj/item/organ/internal/liver/cybernetic,
		/datum/job/service/chef = /obj/item/organ/internal/cyberimp/chest/nutriment/plus,
		/datum/job/service/botanist = /obj/item/organ/internal/cyberimp/chest/nutriment,
		/datum/job/service/clown = /obj/item/organ/internal/cyberimp/brain/anti_stun, //honk
		/datum/job/service/mime = /obj/item/organ/internal/heart/cybernetic,
		/datum/job/service/janitor = /obj/item/organ/internal/cyberimp/arm/janitorial,
		/datum/job/service/librarian = /obj/item/organ/internal/cyberimp/eyes/meson,
		/datum/job/service/chaplain = /obj/item/organ/internal/cyberimp/brain/anti_drop,
		/datum/job/service/explorer = /obj/item/organ/internal/heart/cybernetic,
		/datum/job/captain = /obj/item/organ/internal/heart/cybernetic/upgraded,
		/datum/job/head_of_staff/nanotrasenrep = /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/blueshield = /obj/item/organ/internal/cyberimp/arm/flash,
		/datum/job/head_of_staff/judge = /obj/item/organ/internal/heart/cybernetic/upgraded,
		/datum/job/lawyer =  /obj/item/organ/internal/cyberimp/eyes/hud/security,
		/datum/job/head_of_staff/qm =  /obj/item/organ/internal/liver/cybernetic,
		/datum/job/supply/cargo_tech = /obj/item/organ/internal/heart/cybernetic,
		/datum/job/supply/mining = /obj/item/organ/internal/cyberimp/eyes/meson,
		/datum/job/supply/mining_medic = /obj/item/organ/internal/cyberimp/arm/surgery,
	)

/datum/station_trait/cybernetic_revolution/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/cybernetic_type = job_to_cybernetic[job.type]
	if(!cybernetic_type)
		if(isAI(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	var/obj/item/organ/internal/cybernetic = new cybernetic_type()
	cybernetic.insert(spawned)

/datum/station_trait/medbot_mania
	name = "Модифицированные медботы"
	report_message = "Все медботы на вашем объекте, включая новособранных, получили улучшение ПО. Ожидайте более качественную работу."
	show_in_report = TRUE
	weight = 5
	trait_type = STATION_TRAIT_POSITIVE
	trait_to_give = STATION_TRAIT_MEDBOT_MANIA

/datum/station_trait/random_event_weight_modifier/tradeship
	name = "Торговое партнёрство"
	report_message = "Корпорация \"Нанотрейзен\" заключила торговое соглашение с ТСФ. Ожидайте скорого прибытия их коммерческого шаттла."
	show_in_report = TRUE
	weight = 5
	trait_type = STATION_TRAIT_POSITIVE
	event_names = list("Торговцы")
	event_severity = /datum/event_container/moderate
	weight_multiplier = 20 // you should be really unlucky

/datum/station_trait/upgraded_armory
	name = "Улучшенная оружейная"
	report_message = "Укрепленная оружейная на вашем объекте получила улучшения, туды были доставлены редкие экземпляры. Однако цены на заказ нового снаряжения будут повышены."
	show_in_report = TRUE
	weight = 2
	trait_type = STATION_TRAIT_POSITIVE
	trait_to_give = STATION_TRAIT_UPGRADED_ARMORY

/datum/station_trait/upgraded_armory/on_round_start()
	. = ..()
	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		if(get_supply_group_name(pack.group) != "Безопасность") //fuck
			continue
		pack.cost *= 1.5

	INVOKE_ASYNC(src, PROC_REF(upgrade_armory))

/datum/station_trait/upgraded_armory/proc/upgrade_armory()
	for(var/area/security/securearmory/armory in GLOB.areas)
		for(var/list/zlevel_turfs as anything in armory.get_zlevel_turf_lists())
			for(var/turf/current_turf as anything in zlevel_turfs)
				for(var/obj/current_thing as anything in current_turf.contents)

					if(istype(current_thing, /obj/item/shield/riot))
						new /obj/item/shield/riot/tele(current_thing.loc)
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/machinery/suit_storage_unit/security))
						new /obj/machinery/suit_storage_unit/security/warden(current_thing.loc)
						qdel(current_thing)
						continue

					if(istype(current_thing, /obj/item/gun/energy/gun))
						new /obj/item/gun/energy/gun/pdw9(current_thing.loc)
						qdel(current_thing)
						continue

				CHECK_TICK
