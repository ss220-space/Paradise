/datum/anomaly_gen_datum
	/// The name of the anomaly visible during generation.
	var/anomaly_type = "Вы не должны это видеть. Пишите баг-репорт."
	/// Object that create anomaly in the place of spawning.
	var/anomaly = /obj/effect/old_anomaly
	/// The charge required to create this anomaly.
	var/req_energy
	/// The type of raw material required to generate the anomaly.
	var/req_item = "Плюшевая игрушка акулы"

/datum/anomaly_gen_datum/proc/is_req_item(obj/item/I)
	return FALSE

/datum/anomaly_gen_datum/proc/get_useful(list/obj/item/containment)
	var/list/useful = list()
	for(var/I in containment)
		if(!is_req_item(I))
			continue

		useful.Add(I)

	return useful

// If not enough, always return empty list.
/datum/anomaly_gen_datum/proc/get_used(list/obj/item/containment)
	var/list/useful = get_useful(containment)
	if(!useful.len)
		return list()

	return list(useful[1])

/datum/anomaly_gen_datum/proc/is_ok_in_range(turf/center, range)
	if(!center)
		return

	for(var/turf/T in range(center, range))
		if(!T.is_safe())
			return FALSE

		// Не забыть добавить проверку на наличие других аномалий.
	return TRUE

/datum/anomaly_gen_datum/proc/is_possible_turf(turf/T)
	return !is_ok_in_range(T, 2)

/datum/anomaly_gen_datum/proc/generate(list/containment, obj/item/radio/beacon/beacon, range = 100, use_items = TRUE)
	var/list/used = list()
	if(use_items)
		used = get_used(containment)
		if(!used.len)
			return FALSE

	var/turf/choosen
	for(var/i = 0; i < 100; ++i)
		var/turf/bturf = get_turf(beacon)
		var/try_x = bturf.x + rand(-range, range)
		var/try_y = bturf.y + rand(-range, range)
		try_x = clamp(try_x, 1, world.maxx)
		try_y = clamp(try_y, 1, world.maxy)

		var/turf/option = get_turf(locate(try_x, try_y, bturf.z))
		if(is_possible_turf(option))
			choosen = option
			break

	if(!choosen)
		return FALSE

	return spawn_anomaly(choosen, used, containment)

/datum/anomaly_gen_datum/proc/spawn_anomaly(turf/T, list/used, list/containment)
	for(var/I in used)
		containment.Remove(I)
		qdel(used[I])

	new anomaly(T)
	return TRUE


//==================================== TIER 1 ===========================================

/datum/anomaly_gen_datum/tier1
	req_energy = 1e6

/datum/anomaly_gen_datum/tier1/pyroclastic
	anomaly_type = "малая атмосферная"
	anomaly = /obj/effect/anomaly/pyro/tier1
	req_item = "Балон"

/datum/anomaly_gen_datum/tier1/pyroclastic/is_req_item(obj/item/I)
	return istype(I, /obj/item/tank/internals)


/datum/anomaly_gen_datum/tier1/bluespace
	anomaly_type = "малая блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier1
	req_item = "Блюспейс кристалл"

/datum/anomaly_gen_datum/tier1/bluespace/is_req_item(obj/item/I)
	return istype(I, /obj/item/stack/sheet/bluespace_crystal)


/datum/anomaly_gen_datum/tier1/vortex
	anomaly_type = "малая вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier1
	req_item = "Контейнер с жидкой темной материей"

/datum/anomaly_gen_datum/tier1/vortex/is_req_item(obj/item/I)
	return istype(I, /obj/item/reagent_containers/glass)


/datum/anomaly_gen_datum/tier1/grav
	anomaly_type = "малая гравитационная"
	anomaly = /obj/effect/anomaly/grav/tier1
	req_item = "Лист урана"

/datum/anomaly_gen_datum/tier1/grav/is_req_item(obj/item/I)
	return istype(I, /obj/item/stack/sheet/mineral/uranium)


/datum/anomaly_gen_datum/tier1/flux
	anomaly_type = "малая энергетическая"
	anomaly = /obj/effect/anomaly/flux/tier1
	req_item = "Что угодно обладающее энергией"

/datum/anomaly_gen_datum/tier1/flux/is_req_item(obj/item/I)
	return istype(I, /obj/item/stock_parts/cell) || get_cell_from(I)


//==================================== TIER 2 ===========================================

/datum/anomaly_gen_datum/tier2
	req_energy = 1e7

/datum/anomaly_gen_datum/tier2/pyroclastic
	anomaly_type = "атмосферная"
	anomaly = /obj/effect/anomaly/pyro/tier2
	req_item = "Ядро малой атмосферной аноамлии"

/datum/anomaly_gen_datum/tier2/pyroclastic/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier1/pyro)


/datum/anomaly_gen_datum/tier2/bluespace
	anomaly_type = "блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier2
	req_item = "Ядро малой блюспейс аномалии"

/datum/anomaly_gen_datum/tier2/bluespace/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier1/bluespace)


/datum/anomaly_gen_datum/tier2/vortex
	anomaly_type = "вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier2
	req_item = "Ядро малой вихревой аномалии"

/datum/anomaly_gen_datum/tier2/vortex/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier1/vortex)


/datum/anomaly_gen_datum/tier2/grav
	anomaly_type = "гравитационная"
	anomaly = /obj/effect/anomaly/grav/tier2
	req_item = "Ядро малой гравитационной аномалии"

/datum/anomaly_gen_datum/tier2/grav/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier1/grav)


/datum/anomaly_gen_datum/tier2/flux
	anomaly_type = "энергетическая"
	anomaly = /obj/effect/anomaly/flux/tier2
	req_item = "Ядро малой энергетической аномалии"

/datum/anomaly_gen_datum/tier2/flux/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier1/flux)


//==================================== TIER 3 ===========================================

/datum/anomaly_gen_datum/tier3
	req_energy = 5e7

/datum/anomaly_gen_datum/tier3/get_used(list/obj/item/containment)
	var/list/useful = get_useful(containment)
	if(useful.len < 2)
		return list()

	return list(useful[1], useful[2])

/datum/anomaly_gen_datum/tier3/pyroclastic
	anomaly_type = "большая атмосферная"
	anomaly = /obj/effect/anomaly/pyro/tier3
	req_item = "Два ядра атмосферных аномалий"

/datum/anomaly_gen_datum/tier3/pyroclastic/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier2/pyro)


/datum/anomaly_gen_datum/tier3/bluespace
	anomaly_type = "большая блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier3
	req_item = "Два ядра блюспейс аномалий"

/datum/anomaly_gen_datum/tier2/bluespace/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier2/bluespace)


/datum/anomaly_gen_datum/tier3/vortex
	anomaly_type = "большая вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier3
	req_item = "Два ядра вихревых аномалий"

/datum/anomaly_gen_datum/tier3/vortex/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier2/vortex)


/datum/anomaly_gen_datum/tier3/grav
	anomaly_type = "большая гравитационная"
	anomaly = /obj/effect/anomaly/grav/tier3
	req_item = "Два ядра гравитационных аномалий"

/datum/anomaly_gen_datum/tier3/grav/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier2/grav)


/datum/anomaly_gen_datum/tier3/flux
	anomaly_type = "большая энергетическая"
	anomaly = /obj/effect/anomaly/flux/tier3
	req_item = "Два ядра энергетических аномалий"

/datum/anomaly_gen_datum/tier3/flux/is_req_item(obj/item/I)
	return istype(I, /obj/item/assembly/signaler/anomaly/tier2/flux)
