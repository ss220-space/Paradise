/obj/machinery/quantum_server/proc/on_template_loaded(datum/lazy_template/source, list/created_atoms)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_LAZY_TEMPLATE_LOADED)

	for(var/thing in created_atoms)
		if(ismegafauna(thing))
			var/mob/living/simple_animal/hostile/megafauna/boss = thing
			boss.make_virtual_megafauna()
			continue

		if(isliving(thing))
			mutation_candidate_refs += WEAKREF(thing)
			continue

		if(istype(thing, /obj/machinery/suit_storage_unit))
			var/obj/machinery/suit_storage_unit/storage = thing
			storage.locked = FALSE

/obj/machinery/quantum_server/proc/on_goal_turf_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(emagged && isliving(arrived))
		var/mob/living/creature = arrived
		if(!creature.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch))
			return

		var/obj/machinery/byteforge/escape_forge = get_random_nearby_forge()
		if(escape_forge)
			INVOKE_ASYNC(src, PROC_REF(station_spawn), creature, escape_forge)
		return

	if(!istype(arrived, /obj/structure/closet/crate/secure/bitrunning/encrypted) && !istype(arrived, /obj/item/storage/lockbox/bitrunning/encrypted))
		return

	var/obj/machinery/byteforge/chosen_forge = get_random_nearby_forge()
	if(isnull(chosen_forge))
		return

	if(istype(arrived, /obj/item/storage/lockbox/bitrunning/encrypted))
		generate_secondary_loot(arrived, chosen_forge)
		return

	generate_loot(arrived, chosen_forge)

/obj/machinery/quantum_server/proc/on_goal_turf_examined(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("Под вашим взглядом пол едва заметно пульсирует потоками закодированных данных.")
	examine_text += span_notice("Похоже, это часть площадки, куда сдают зашифрованные контейнеры.")

/obj/machinery/quantum_server/proc/on_threat_created(datum/source, mob/living/threat)
	SIGNAL_HANDLER

	add_threats(threat)
