/proc/cmp_numeric_dsc(a, b)
	return b - a

/proc/cmp_numeric_asc(a, b)
	return a - b

/proc/cmp_text_asc(a, b)
	return sorttext(b, a)

/proc/cmp_text_dsc(a, b)
	return sorttext(a, b)

/proc/cmp_embed_text_asc(a, b)
	if(isdatum(a))
		a = UID_of(a)
	if(isdatum(b))
		b = UID_of(b)
	return sorttext("[b]", "[a]")

/proc/cmp_embed_text_dsc(a, b)
	if(isdatum(a))
		a = UID_of(a)
	if(isdatum(b))
		b = UID_of(b)
	return sorttext("[a]", "[b]")

/proc/cmp_list_len_asc(list/a, list/b)
	return length(a) - length(b)

/proc/cmp_list_len_dsc(list/a, list/b)
	return length(b) - length(a)

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

/proc/cmp_init_name_asc(atom/a, atom/b)
	return sorttext(initial(b.name), initial(a.name))

/// Datum cmp with vars is always slower than a specialist cmp proc, use your judgement.
/proc/cmp_datum_numeric_asc(datum/a, datum/b, variable)
	return cmp_numeric_asc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_numeric_dsc(datum/a, datum/b, variable)
	return cmp_numeric_dsc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_text_asc(datum/a, datum/b, variable)
	return sorttext(b.vars[variable], a.vars[variable])

/proc/cmp_datum_text_dsc(datum/a, datum/b, variable)
	return sorttext(a.vars[variable], b.vars[variable])

/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)

/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)

/proc/cmp_subsystem_init(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return a.init_order - b.init_order

/proc/cmp_subsystem_init_stage(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return initial(a.init_stage) - initial(b.init_stage)

/proc/cmp_subsystem_display(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return sorttext(b.name, a.name)

/proc/cmp_subsystem_priority(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return a.priority - b.priority

/proc/cmp_filter_data_priority(list/a, list/b)
	return a["priority"] - b["priority"]

/proc/cmp_timer(datum/timedevent/a, datum/timedevent/b)
	return a.timeToRun - b.timeToRun

/proc/cmp_ruincost_priority(datum/map_template/ruin/a, datum/map_template/ruin/b)
	return initial(a.cost) - initial(b.cost)

/proc/cmp_qdel_item_time(datum/qdel_item/a, datum/qdel_item/b)
	. = b.hard_delete_time - a.hard_delete_time
	if(!.)
		. = b.destroy_time - a.destroy_time
	if(!.)
		. = b.failures - a.failures
	if(!.)
		. = b.qdels - a.qdels

/proc/cmp_generic_stat_item_time(list/a, list/b)
	. = b[STAT_ENTRY_TIME] - a[STAT_ENTRY_TIME]
	if(!.)
		. = b[STAT_ENTRY_COUNT] - a[STAT_ENTRY_COUNT]

/proc/cmp_atom_layer_asc(atom/a, atom/b)
	if(a.plane != b.plane)
		return a.plane - b.plane
	else
		return a.layer - b.layer

/proc/cmp_reagents_asc(datum/reagent/a, datum/reagent/b)
	return sorttext(initial(b.name), initial(a.name))

/proc/cmp_typepaths_asc(a, b)
	return sorttext("[b]","[a]")

/proc/cmp_num_string_asc(a, b)
	return text2num(a) - text2num(b)

/proc/cmp_mob_realname_dsc(mob/a, mob/b)
	return sorttext(a.real_name, b.real_name)

/// Orders by integrated circuit weight
/proc/cmp_port_order_asc(datum/port/compare1, datum/port/compare2)
	return compare1.order - compare2.order

/**
 * Sorts crafting recipe requirements before the crafting recipe is inserted into GLOB.crafting_recipes
 *
 * Prioritises [/datum/reagent] to ensure reagent requirements are always processed first when crafting.
 * This prevents any reagent_containers from being consumed before the reagents they contain, which can
 * lead to runtimes and item duplication when it happens.
 */
/proc/cmp_crafting_req_priority(a, b)
	var/lhs
	var/rhs

	lhs = ispath(a, /datum/reagent) ? 0 : 1
	rhs = ispath(b, /datum/reagent) ? 0 : 1

	return lhs - rhs

/// Passed a list of assoc lists, sorts them by the list's "name" keys.
/proc/cmp_assoc_list_name(list/a, list/b)
	return sorttext(b["name"], a["name"])

/// Orders vending products by their price
/proc/cmp_vending_prices(datum/data/vending_product/a, datum/data/vending_product/b)
	return b.price - a.price

/proc/cmp_item_vending_prices(obj/item/a, obj/item/b)
	return b.custom_price - a.custom_price

/// Orders cameras by their `c_tag` ascending
/proc/cmp_camera_ctag_asc(obj/machinery/camera/a, obj/machinery/camera/b)
	return sorttext(b.c_tag, a.c_tag)

/proc/cmp_sheet_list(list/a, list/b)
	return a["value"] - b["value"]

/proc/cmp_deathmatch_mods(datum/deathmatch_modifier/a, datum/deathmatch_modifier/b)
	return sorttext(b.name, a.name)
