/datum/unit_test/room_test/heretic_rituals

/datum/unit_test/room_test/heretic_rituals/Run()
	var/obj/effect/decal/heretic_rune/big/our_rune = allocate(/obj/effect/decal/heretic_rune/big)
	var/mob/living/carbon/human/our_heretic = allocate(/mob/living/carbon/human)

	our_rune.forceMove(run_loc_floor_bottom_left)
	our_heretic.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z))

	var/list/blacklist_typecache = typecacheof(list(
		/datum/heretic_knowledge/limited_amount/summon,
		/datum/heretic_knowledge/ultimate,
		/datum/heretic_knowledge/hunt_and_sacrifice,
		/datum/heretic_knowledge/codex_morbus,
	))
	var/list/all_ritual_knowledge = list()

	for(var/knowledge_type in typesof(/datum/heretic_knowledge))
		if(is_type_in_typecache(knowledge_type, blacklist_typecache))
			continue

		var/datum/heretic_knowledge/instantiated_knowledge = new knowledge_type()
		if(!LAZYLEN(instantiated_knowledge.required_atoms) || !LAZYLEN(instantiated_knowledge.result_atoms))
			qdel(instantiated_knowledge)
			continue

		if(ritual_consumes_living(instantiated_knowledge.required_atoms))
			qdel(instantiated_knowledge)
			continue

		all_ritual_knowledge += instantiated_knowledge

	for(var/datum/heretic_knowledge/knowledge as anything in all_ritual_knowledge)
		for(var/atom/movable/stale in range(1, our_heretic))
			if(stale == our_heretic || stale == our_rune)
				continue
			qdel(stale)

		if(!knowledge.recipe_snowflake_check(our_heretic, list(), list(), get_turf(our_rune)))
			continue

		var/list/created_atoms = list()
		for(var/ritual_item_path in knowledge.required_atoms)
			var/amount_to_create = knowledge.required_atoms[ritual_item_path]
			if(islist(ritual_item_path))
				ritual_item_path = pick(ritual_item_path)
			for(var/i in 1 to amount_to_create)
				var/obj/item/item = new ritual_item_path(get_turf(our_heretic))
				if(isitem(item))
					item.item_flags &= ~ABSTRACT
				if(istype(item, /obj/item/candle))
					var/obj/item/candle/candle = item
					candle.light()
				created_atoms += item

		if(!our_rune.do_ritual(our_heretic, knowledge))
			for(var/atom/leftover as anything in created_atoms)
				created_atoms -= leftover
				qdel(leftover)
			TEST_FAIL("Heretic rituals: ([knowledge.type]) Despite having all required atoms present, the ritual failed to transmute.")
			continue

		var/list/atom/movable/nearby_atoms = range(1, our_heretic)
		nearby_atoms -= our_heretic
		nearby_atoms -= our_rune

		for(var/result_item_path in knowledge.result_atoms)
			var/atom/result = locate(result_item_path) in nearby_atoms
			if(!result)
				TEST_FAIL("Heretic rituals: ([knowledge.type]) Despite successfully completing the ritual, a resulting atom could not be found ([result_item_path])")
				continue
			nearby_atoms -= result
			qdel(result)

		for(var/atom/thing as anything in nearby_atoms)
			if(!ismovable(thing))
				continue
			if(isitem(thing))
				var/obj/item/item = thing
				if(item.item_flags & ABSTRACT)
					continue
			if(istype(thing, /obj/effect/decal/cleanable))
				continue
			TEST_FAIL("Heretic rituals: ([knowledge.type]) After completing the ritual, there were non-result atoms remaining on the rune. ([thing] - [thing.type])")
			nearby_atoms -= thing
			qdel(thing)

	QDEL_LIST(all_ritual_knowledge)

/// Returns TRUE if any required atom of the given requirements list is a living mob type.
/datum/unit_test/room_test/heretic_rituals/proc/ritual_consumes_living(list/required_atoms)
	for(var/req_type in required_atoms)
		if(islist(req_type))
			for(var/sub_type in req_type)
				if(ispath(sub_type, /mob/living))
					return TRUE
			continue
		if(ispath(req_type, /mob/living))
			return TRUE
	return FALSE
