/datum/anomaly_gen_datum
	/// The name of the anomaly visible during generation.
	var/anomaly_type = "Вы не должны это видеть. Пишите баг-репорт."
	/// Object that create anomaly in the place of spawning.
	var/anomaly = /obj/effect/old_anomaly
	/// The charge required to create this anomaly.
	var/req_energy
	/// The type of raw material required to generate the anomaly.
	var/req_item = "-"

/datum/anomaly_gen_datum/proc/is_req_item(obj/item/item)
	return FALSE

/datum/anomaly_gen_datum/proc/get_useful(list/obj/item/containment)
	var/list/useful = list()
	for(var/item in containment)
		if(!is_req_item(item))
			continue

		useful.Add(item)

	return useful

// If not enough, always return empty list.
/datum/anomaly_gen_datum/proc/get_used(list/obj/item/containment)
	var/list/useful = get_useful(containment)
	if(!useful.len)
		return list()

	return list(useful[1])

/datum/anomaly_gen_datum/proc/is_ok_in_range(turf/center, range)
	if(!center)
		return FALSE

	for(var/turf/T in range(center, range))
		if(!issimulatedturf(T) || !T.is_safe())
			return FALSE

	return TRUE

/datum/anomaly_gen_datum/proc/is_possible_turf(turf/T)
	return !is_ok_in_range(T, 2)

/datum/anomaly_gen_datum/proc/generate(list/containment, obj/item/radio/beacon/beacon, range = 100, use_items = TRUE)
	var/list/used = list()
	if(use_items)
		used = get_used(containment)
		if(!used.len && req_item != "-")
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
	for(var/item in used)
		containment.Remove(item)
		qdel(used[item])

	new anomaly(T)
	return TRUE


//==================================== TIER 1 ===========================================

/datum/anomaly_gen_datum/tier1
	req_energy = 1e6

/datum/anomaly_gen_datum/tier1/pyroclastic
	anomaly_type = "малая атмосферная"
	anomaly = /obj/effect/anomaly/atmospheric/tier1

/datum/anomaly_gen_datum/tier1/bluespace
	anomaly_type = "малая блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier1

/datum/anomaly_gen_datum/tier1/vortex
	anomaly_type = "малая вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier1

/datum/anomaly_gen_datum/tier1/gravitational
	anomaly_type = "малая гравитационная"
	anomaly = /obj/effect/anomaly/gravitational/tier1

/datum/anomaly_gen_datum/tier1/energetic
	anomaly_type = "малая энергетическая"
	anomaly = /obj/effect/anomaly/energetic/tier1

//==================================== TIER 2 ===========================================

/datum/anomaly_gen_datum/tier2
	req_energy = 1e7

/datum/anomaly_gen_datum/tier2/pyroclastic
	anomaly_type = "атмосферная"
	anomaly = /obj/effect/anomaly/atmospheric/tier2
	req_item = "Ядро малой атмосферной аноамлии"

/datum/anomaly_gen_datum/tier2/pyroclastic/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/atmospheric/tier1)


/datum/anomaly_gen_datum/tier2/bluespace
	anomaly_type = "блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier2
	req_item = "Ядро малой блюспейс аномалии"

/datum/anomaly_gen_datum/tier2/bluespace/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/bluespace/tier1)


/datum/anomaly_gen_datum/tier2/vortex
	anomaly_type = "вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier2
	req_item = "Ядро малой вихревой аномалии"

/datum/anomaly_gen_datum/tier2/vortex/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/vortex/tier1)


/datum/anomaly_gen_datum/tier2/gravitational
	anomaly_type = "гравитационная"
	anomaly = /obj/effect/anomaly/gravitational/tier2
	req_item = "Ядро малой гравитационной аномалии"

/datum/anomaly_gen_datum/tier2/gravitational/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/gravitational/tier1)


/datum/anomaly_gen_datum/tier2/energetic
	anomaly_type = "энергетическая"
	anomaly = /obj/effect/anomaly/energetic/tier2
	req_item = "Ядро малой энергетической аномалии"

/datum/anomaly_gen_datum/tier2/energetic/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/energetic/tier1)


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
	anomaly = /obj/effect/anomaly/atmospheric/tier3
	req_item = "Два ядра атмосферных аномалий"

/datum/anomaly_gen_datum/tier3/pyroclastic/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/atmospheric/tier2)


/datum/anomaly_gen_datum/tier3/bluespace
	anomaly_type = "большая блюспейс"
	anomaly = /obj/effect/anomaly/bluespace/tier3
	req_item = "Два ядра блюспейс аномалий"

/datum/anomaly_gen_datum/tier3/bluespace/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/bluespace/tier2)


/datum/anomaly_gen_datum/tier3/vortex
	anomaly_type = "большая вихревая"
	anomaly = /obj/effect/anomaly/vortex/tier3
	req_item = "Два ядра вихревых аномалий"

/datum/anomaly_gen_datum/tier3/vortex/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/vortex/tier2)


/datum/anomaly_gen_datum/tier3/gravitational
	anomaly_type = "большая гравитационная"
	anomaly = /obj/effect/anomaly/gravitational/tier3
	req_item = "Два ядра гравитационных аномалий"

/datum/anomaly_gen_datum/tier3/gravitational/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/gravitational/tier2)


/datum/anomaly_gen_datum/tier3/energetic
	anomaly_type = "большая энергетическая"
	anomaly = /obj/effect/anomaly/energetic/tier3
	req_item = "Два ядра энергетических аномалий"

/datum/anomaly_gen_datum/tier3/energetic/is_req_item(obj/item/item)
	return istype(item, /obj/item/assembly/signaler/core/energetic/tier2)
