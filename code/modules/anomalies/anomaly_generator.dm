/obj/machinery/power/anomaly_generator
	name = "генератор аномалий"
	desc = "Необычного вида машина, разработанная на основе эксперементальной технологии, предназначенная для \
			генерации аномалий."
	ru_names = list(
		NOMINATIVE = "генератор аномалий", \
		GENITIVE = "генератора аномалий", \
		DATIVE = "генератору аномалий", \
		ACCUSATIVE = "генератор аномалий", \
		INSTRUMENTAL = "генератором аномалий", \
		PREPOSITIONAL = "генераторе аномалий"
	)
	gender = MALE
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/anomaly/anomaly_stuff.dmi'
	icon_state = "generator_on"
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	max_integrity = 200
	integrity_failure = 100
	resistance_flags = FIRE_PROOF | ACID_PROOF
	processing_flags = START_PROCESSING_MANUALLY

	/// Usage of energy from powernet.
	var/powernet_usage = 0
	/// Selected anomaly tier.
	var/selected_tier = TIER1
	/// Selected anomaly type.
	var/selected_type = ANOMALY_TYPE_RANDOM

	/// Current generator charge.
	var/charge = 0
	/// Last charge per second.
	var/last_charge = 0
	/// List of items placed inside.
	var/list/obj/item/assembly/signaler/core/containment = list()

	/// The maximum number of items that can be in the anomaly generator.
	var/containment_limit = 2
	/// The radius at which anomalies will be generated.
	var/creating_range = 15
	/// The speed with which energy will be collected.
	var/speed = 1e4

	/// A beacon located inside the anomaly generator.
	var/obj/item/radio/beacon/beacon
	/// The beacon selected as a place for generating anomalies.
	var/obj/item/radio/beacon/selected_beacon
	/// Current anomaly generator datum.
	var/datum/anomaly_gen_datum/cur_anomaly

	/// If true, generator will collect charge from connected wire node.
	var/use_powernet = TRUE
	/// If true, generator will collect charge from SMESes in 3*3.
	var/use_smeses = TRUE
	/// If true, generator will collect charge from apcs in this area.
	var/use_apcs = TRUE

	/// Sound cooldown
	COOLDOWN_DECLARE(sound_cooldown)

/obj/machinery/power/anomaly_generator/New()
	..()
	beacon = new(src)
	selected_beacon = beacon
	component_parts = list()
	component_parts += new /obj/item/circuitboard/anomaly_generator
	component_parts += new /obj/item/stock_parts/matter_bin
	component_parts += new /obj/item/stock_parts/matter_bin
	component_parts += new /obj/item/stock_parts/manipulator
	component_parts += new /obj/item/stock_parts/capacitor
	component_parts += new /obj/item/stock_parts/capacitor
	RefreshParts()

/obj/machinery/power/anomaly_generator/upgraded/New()
	..()
	LAZYCLEARLIST(component_parts)
	component_parts = list()
	component_parts += new /obj/item/circuitboard/anomaly_generator
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace
	component_parts += new /obj/item/stock_parts/matter_bin/bluespace
	component_parts += new /obj/item/stock_parts/manipulator/femto
	component_parts += new /obj/item/stock_parts/capacitor/quadratic
	component_parts += new /obj/item/stock_parts/capacitor/quadratic
	RefreshParts()

/obj/machinery/power/anomaly_generator/Initialize(mapload)
	. = ..()
	powernet = find_powernet()

/obj/machinery/power/anomaly_generator/Destroy()
	qdel(beacon)
	qdel(cur_anomaly)
	for(var/obj/O as anything in containment)
		O.forceMove(loc)

	containment = null
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/machinery/power/anomaly_generator/RefreshParts()
	containment_limit = 0
	for(var/obj/item/stock_parts/matter_bin/matter_bin in component_parts)
		containment_limit += matter_bin.rating

	while(containment.len > containment_limit)
		eject(pick(containment))

	creating_range = 25
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		creating_range /= manipulator.rating

	// 2 tier 1 = 10000 (100 sec, ~17 min, ~83 min); 2 tier 4 = 1280000 (1 sec, 8 sec, 39 sec).
	speed = 1e4
	for(var/obj/item/stock_parts/capacitor/capacitor in component_parts)
		speed *= capacitor.rating * capacitor.rating

/obj/machinery/power/anomaly_generator/update_icon(updates = ALL)
	icon_state = "generator_[stat & NOPOWER ? "off" : "on"]"
	return ..()

/obj/machinery/power/anomaly_generator/attackby(obj/item/item, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(exchange_parts(user, item))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!iscore(item))
		return ..()

	if(user.drop_transfer_item_to_loc(item, src))
		add_fingerprint(user)
		user.visible_message(span_warning("[user] поместил[genderize_ru(user.gender, "", "а", "о", "и")] [item.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."), \
					span_warning("Вы поместили [item.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		containment.Add(item)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/machinery/power/anomaly_generator/proc/buzz()
	if(!COOLDOWN_FINISHED(src, sound_cooldown))
		return

	playsound(src, 'sound/machines/buzz-sigh.ogg', 40)
	COOLDOWN_START(src, sound_cooldown, 0.5 SECONDS)

/obj/machinery/power/anomaly_generator/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	add_fingerprint(usr)

	. = TRUE
	switch(action)
		if("choose_type")
			var/type = params["type"]
			selected_type = type

		if("choose_tier")
			var/tier = params["tier"]
			selected_tier = tier

		if("generate")
			generate()

		if("eject_all")
			while(containment.len)
				eject(containment[1])

		if("stop")
			cur_anomaly = null
			atom_say("Создание аномалии прекращено.", FALSE)
			buzz()

		if("toggle_apcs")
			use_apcs = !use_apcs

		if("toggle_smeses")
			use_smeses = !use_smeses

		if("toggle_powernet")
			use_powernet = !use_powernet

		if("beakon")
			var/list/options = list()
			for(var/obj/item/radio/beacon/beacon in GLOB.beacons)
				var/turf/T = get_turf(beacon)
				if(!T)
					continue

				if(!is_teleport_allowed(T.z) && !beacon.cc_beacon)
					continue

				if(beacon.syndicate || is_taipan(beacon.z) && beacon != beacon)
					continue

				options["[T.loc.name]"] = beacon

			var/obj/item/radio/beacon/choice = options[tgui_input_list(ui.user, "Выберите маячок для создания аномалии.", "Выбор маячка", options)]
			if (choice == null)
				choice = beacon;

			selected_beacon = choice

		else
			. = FALSE

/obj/machinery/power/anomaly_generator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/anomaly_generator/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/power/anomaly_generator/attack_hand(mob/user)
	if(..())
		return TRUE

	ui_interact(user)

/obj/machinery/power/anomaly_generator/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/power/anomaly_generator/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AnomalyGenerator", "Генератор аномалий")
		ui.open()

/obj/machinery/power/anomaly_generator/ui_data(mob/user)
	var/list/data = list()
	data["type"] = selected_type
	data["tier"] = selected_tier
	data["req_energy"] = get_req_energy()
	data["req_item"] = get_req_items()
	data["anomaly_type"] = get_anomaly_type()
	data["charge"] = charge
	data["generating"] = cur_anomaly != null
	data["use_acps"] = use_apcs
	data["use_smeses"] = use_smeses
	data["use_powernet"] = use_powernet
	data["has_powernet"] = powernet != null
	data["last_charge"] = last_charge
	return data

/obj/machinery/power/anomaly_generator/ui_static_data(mob/user)
	var/list/data = list()
	return data

/obj/machinery/power/anomaly_generator/proc/eject(obj/item/item, mob/living/carbon/human/user)
	if(!(item in containment))
		return

	if(!user?.put_in_hands(item, ignore_anim = FALSE))
		item.forceMove(get_turf(src))

	containment.Remove(item)

/obj/machinery/power/anomaly_generator/proc/get_req_energy()
	var/mult
	if(selected_type == ANOMALY_TYPE_RANDOM)
		mult = selected_tier == 1 ? 0.3 : 3
	else
		mult = 1 + GLOB.created_anomalies[selected_type] / 2

	switch(selected_tier)
		if("1")
			return (/datum/anomaly_gen_datum/tier1::req_energy) * mult
		if("2")
			return (/datum/anomaly_gen_datum/tier2::req_energy) * mult
		if("3")
			return (/datum/anomaly_gen_datum/tier3::req_energy) * mult

/obj/machinery/power/anomaly_generator/proc/get_req_items()
	if(selected_type == ANOMALY_TYPE_RANDOM)
		return "-"

	var/datum/anomaly_gen_datum/anomaly = GLOB.anomaly_types["[selected_tier]"][selected_type]
	return anomaly::req_item

/obj/machinery/power/anomaly_generator/proc/get_anomaly_type()
	if(selected_type == ANOMALY_TYPE_RANDOM)
		return "случайная"

	var/datum/anomaly_gen_datum/anomaly = GLOB.anomaly_types["[selected_tier]"][selected_type]
	return anomaly::anomaly_type

/obj/machinery/power/anomaly_generator/proc/generate()
	var/datum/anomaly_gen_datum/anomaly
	if(selected_type == ANOMALY_TYPE_RANDOM)
		var/anomaly_datum_type = GLOB.anomaly_types[selected_tier][pick(GLOB.anomaly_types[selected_tier])]
		anomaly = new anomaly_datum_type
		atom_say("Сбор энергии начался. Текущая цель: [selected_type == ANOMALY_TYPE_RANDOM ? "RANDOM" : anomaly.anomaly_type].", FALSE)
		cur_anomaly = anomaly
		START_PROCESSING(SSprocessing, src)
		return

	var/anomaly_datum_type = GLOB.anomaly_types["[selected_tier]"][selected_type]
	anomaly = new anomaly_datum_type
	var/list/possible_used = anomaly.get_used(containment)
	if(!possible_used.len && anomaly.req_item != "-")
		buzz()
		atom_say("Недостаточно ресурсов!", FALSE)
		return

	atom_say("Сбор энергии начался. Текущая цель: [selected_type == ANOMALY_TYPE_RANDOM ? "RANDOM" : anomaly.anomaly_type].", FALSE)
	cur_anomaly = anomaly
	START_PROCESSING(SSprocessing, src)

/obj/machinery/power/anomaly_generator/process()
	if((stat & BROKEN) || !cur_anomaly)
		STOP_PROCESSING(SSprocessing, src)

	if(charge >= get_req_energy())
		finish_generation()
		cur_anomaly = null
		STOP_PROCESSING(SSprocessing, src)

	if(stat & NOPOWER)
		return

	var/going_to_use = min(speed, get_req_energy() - charge)
	var/was_charge = charge

	//			POWERNET
	if(use_powernet && powernet)
		add_load(-powernet_usage)
		var/used_charge = min(going_to_use, surplus())
		powernet_usage = used_charge
		add_load(powernet_usage)
		charge += used_charge
		going_to_use -= used_charge

	//			SMES
	if(use_smeses)
		for(var/obj/machinery/power/smes/smes in range(2, src))
			var/used_charge = max(0, min(going_to_use, min(smes.charge * 0.05, smes.output_level)))
			smes.output_used += used_charge
			smes.charge -= used_charge
			charge += used_charge
			going_to_use -= used_charge

	//			APC
	var/area/area = get_area(src)
	if(use_apcs && area)
		// It won't use more power than was prepared for equipment.
		for(var/obj/machinery/power/apc/apc in area?.apc)
			if(!apc.cell)
				continue

			if(!apc.is_channel_on(EQUIP))
				continue

			var/min_charge_border = apc.is_channel_force_on(EQUIP) ? 0 : 1250
			var/used_charge = min(apc.cell.charge - min_charge_border, going_to_use)
			apc.cell.charge -= used_charge
			charge += used_charge
			going_to_use -= used_charge

	last_charge = charge - was_charge

/obj/machinery/power/anomaly_generator/proc/finish_generation()
	if(!cur_anomaly.generate(containment, selected_beacon, creating_range, selected_type != ANOMALY_TYPE_RANDOM))
		atom_say("Создание аномалии провалилось.", FALSE)
		buzz()
		return

	atom_say("Была создана [cur_anomaly.anomaly_type] аномалия.", FALSE)
	playsound(src, 'sound/machines/ping.ogg', 50, 1, -1) // A rare call, let it be without CD.

/obj/machinery/power/anomaly_generator/upgraded/admin
	desc = "Необычного вида машина, разработанная на основе эксперементальной технологии, предназначенная для \
			генерации аномалий. В данной модели были использованы секретные разработки NanoTrasen."

/obj/machinery/power/anomaly_generator/wrench_act(mob/living/user, obj/item/item)
	default_unfasten_wrench(user, item)
	powernet = find_powernet()
	return TRUE

/obj/machinery/power/anomaly_generator/screwdriver_act(mob/user, obj/item/item)
	return default_deconstruction_screwdriver(user, icon_state, icon_state, item)

/obj/machinery/power/anomaly_generator/crowbar_act(mob/user, obj/item/item)
	return default_deconstruction_crowbar(user, item)

/obj/machinery/power/anomaly_generator/upgraded/admin/get_req_energy()
	return 0
