/datum/experimentor_result_handler
	/// The name as seen in the UI
	var/name
	/// The FontAwesome icon for the UI
	var/fa_icon
	/// Which scan type triggers this reaction
	var/scantype
	/// Message to display when the experiment begins
	var/start_message_template
	/// The probability of the experiment reaching critical state
	var/critical_prob
	/// The probability of the experiment with relic object
	var/relic_prob = EFFECT_PROB_VERYLOW
	/// Message to display when the critical state triggers
	var/critical_message_template
	/// The span for the visible message
	var/start_message_type = MSG_TYPE_NOTICE
	/// This reaction handler has bespoke handing
	var/is_special = FALSE

/datum/experimentor_result_handler/proc/execute(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/final_message = replacetext(start_message_template, "%ITEM%", exp_on)
	machine.show_start_message(final_message, start_message_type)
	handle_malfunctions(machine, exp_on)

	if(QDELETED(exp_on))
		return

	if(isrelic(exp_on))
		var/result = handle_relic(machine, exp_on)
		if(!result)
			machine.fail_experiment()
		return

	var/critical = machine.is_critical_reaction(exp_on)
	if(critical && prob(critical_prob))
		handle_critical(machine, exp_on)
		return

/datum/experimentor_result_handler/proc/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	if(critical_message_template)
		var/final_critical_message = replacetext(critical_message_template, "%ITEM%", exp_on)
		machine.visible_message(span_notice(final_critical_message))

/datum/experimentor_result_handler/proc/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	return

/datum/experimentor_result_handler/proc/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(!prob(relic_prob * malf_chance))
		return FALSE

	return TRUE

/// Pokes the object
/datum/experimentor_result_handler/scan/poke
	name = "Poke"
	fa_icon = "hand"
	scantype = SCANTYPE_POKE
	start_message_template = "prods at %ITEM% with mechanical arms."
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM% is gripped in just the right way, enhancing its focus."

/datum/experimentor_result_handler/scan/poke/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	machine.critical_malfunction_counter++
	machine.RefreshParts()

/datum/experimentor_result_handler/scan/poke/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions and destroys [exp_on], lashing its arms out at nearby people!"))
		for(var/mob/living/nearby_mob in oview(1, machine))
			nearby_mob.apply_damage(15, BRUTE, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
			machine.investigate_log("Experimentor dealt minor brute to [nearby_mob].", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions!"))
		machine.run_experiment(SCANTYPE_OBLITERATE)
		return

	if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, throwing the [exp_on]!"))
		var/mob/living/target = locate() in oview(7, machine)
		if(!target)
			return
		var/obj/item/throwing = machine.loaded_item
		machine.investigate_log("Experimentor has thrown [machine.loaded_item] at [key_name(target)]", INVESTIGATE_EXPERIMENTOR)
		machine.item_eject()
		if(throwing)
			throwing.throw_at(target, 10, 1)
		return

/datum/experimentor_result_handler/scan/poke/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()

	if(!.)
		return

	machine.visible_message(span_warning("The [exp_on] begins to vibrate!"))
	playsound(machine, 'sound/effects/supermatter.ogg', 50, 3, -1)
	machine.item_eject()
	var/turf/spawn_location = get_turf(exp_on)
	do_smoke(range = 1, holder = machine, location = spawn_location)
	var/obj/item/relict_production/strange_teleporter/teleporter = new (spawn_location)
	teleporter.icon_state = exp_on.icon_state
	qdel(exp_on)

/// Infuses it with radiation
/datum/experimentor_result_handler/scan/irradiate
	name = "Irradiate"
	fa_icon = "radiation"
	scantype = SCANTYPE_IRRADIATE
	start_message_template = "reflects radioactive rays at %ITEM%!"
	start_message_type = MSG_TYPE_DANGER
	critical_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM% has activated an unknown subroutine!"

/datum/experimentor_result_handler/scan/irradiate/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	machine.clone_object_start()
	machine.item_eject()

/datum/experimentor_result_handler/scan/irradiate/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, melting [exp_on] and leaking radiation!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		for(var/mob/living/mob in oview(1, src))
			mob.apply_effect(25, IRRADIATE)
		QDEL_NULL(machine.loaded_item)
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, spewing toxic waste!"))
		for(var/turf/location in oview(1, machine))
			if(location.density)
				continue

			if(!prob(EFFECT_PROB_VERYHIGH))
				continue

			if(locate(/obj/effect/decal/cleanable/greenglow) in location)
				continue

			new /obj/effect/decal/cleanable/greenglow/filled(location)

		QDEL_NULL(machine.loaded_item)
		return

	if(!prob(EFFECT_PROB_MEDIUM * malf_chance))
		return

	var/savedName = "[exp_on]"
	QDEL_NULL(machine.loaded_item)
	var/new_path = pick_weight_classic(machine.valid_items)
	machine.loaded_item = new new_path(machine)
	machine.visible_message(span_warning("[machine] malfunctions, transforming [savedName] into [machine.loaded_item]!"))
	machine.investigate_log("Experimentor has transformed [savedName] into [machine.loaded_item]", INVESTIGATE_EXPERIMENTOR)

	if(istype(machine.loaded_item, /obj/item/grenade/chem_grenade))
		var/obj/item/grenade/chem_grenade/chem_grenade = machine.loaded_item
		chem_grenade.prime()

	machine.item_eject()

/datum/experimentor_result_handler/scan/irradiate/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()

	if(!.)
		return

	machine.visible_message(span_warning("The [exp_on] has activated an unknown subroutine!"))
	machine.clone_next = TRUE
	QDEL_NULL(machine.loaded_item)

/// Fills the chamber with gas
/datum/experimentor_result_handler/scan/gas
	name = "Gas"
	fa_icon = "cloud"
	scantype = SCANTYPE_GAS
	start_message_template = "fills its chamber with gas, %ITEM% included."
	start_message_type = MSG_TYPE_WARNING
	critical_prob = EFFECT_PROB_LOW
	relic_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM% achieves the perfect mix!"

/datum/experimentor_result_handler/scan/gas/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	new /obj/item/stack/sheet/mineral/plasma(get_turf(pick(oview(1, machine))))

/datum/experimentor_result_handler/scan/gas/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()
	var/chosenchem

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] destroys [exp_on], leaking dangerous gas!"))
		chosenchem = pick(
			/datum/reagent/carbon,
			/datum/reagent/radium,
			/datum/reagent/toxin,
			/datum/reagent/consumable/condensedcapsaicin,
			/datum/reagent/psilocybin,
			/datum/reagent/space_drugs,
			/datum/reagent/consumable/ethanol,
			/datum/reagent/consumable/ethanol/beepsky_smash,
		)
		do_chem_smoke(range = 2, holder = machine, location = get_turf(machine), reagent_type = chosenchem, reagent_volume = 375)
		machine.investigate_log("Experimentor has released [chosenchem] smoke.", INVESTIGATE_EXPERIMENTOR)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)
		return

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s chemical chamber has sprung a leak!"))
		chosenchem = pick(
			/datum/reagent/aslimetoxin,
			/datum/reagent/nanomachines,
			/datum/reagent/acid,
		)
		do_chem_smoke(range = 2, holder = machine, location = get_turf(machine), reagent_type = chosenchem, reagent_volume = 375)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)
		machine.warn_admins(usr, "[chosenchem] smoke")
		machine.investigate_log("Experimentor has released <font color='red'>[chosenchem]</font> smoke!", INVESTIGATE_EXPERIMENTOR)
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, spewing harmless gas."))
		do_smoke(range = 1, holder = machine, location = get_turf(machine))
		return

	if(!prob(EFFECT_PROB_MEDIUM * malf_chance))
		return

	machine.visible_message(span_warning("[machine] melts [exp_on], ionizing the air around it!"))
	empulse(get_turf(machine), 4, 6, cause = machine)
	machine.investigate_log("Experimentor has generated an Electromagnetic Pulse.", INVESTIGATE_EXPERIMENTOR)
	QDEL_NULL(machine.loaded_item)

/datum/experimentor_result_handler/scan/gas/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()

	if(!.)
		return

	machine.visible_message("[exp_on] achieves the perfect mix!")
	playsound(machine, 'sound/effects/supermatter.ogg', 50, 3, -1)
	machine.item_eject()
	var/turf/spawn_location = get_turf(exp_on)
	do_smoke(range = 1, holder = machine, location = spawn_location)
	new /obj/item/relict_production/perfect_mix(spawn_location)
	qdel(exp_on)

/// Heats the object
/datum/experimentor_result_handler/scan/heat
	name = "Heat"
	fa_icon = "fire"
	scantype = SCANTYPE_HEAT
	start_message_template = "raises %ITEM%'s temperature."
	critical_prob = EFFECT_PROB_LOW
	relic_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s emergency coolant system gives off a small ding!"

/datum/experimentor_result_handler/scan/heat/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	playsound(machine, 'sound/machines/ding.ogg', 50, TRUE)
	var/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/coffee/experimentor/heat/cup = new (get_turf(pick(oview(1, machine))))
	machine.investigate_log("Experimentor has made a cup of [cup.selected_reagent] coffee.", INVESTIGATE_EXPERIMENTOR)

/datum/experimentor_result_handler/scan/heat/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		var/turf/start = get_turf(machine)
		var/mob/target_mob = locate(/mob/living) in view(machine, 3)
		var/turf/target_turf = get_turf(target_mob)

		if(!target_turf)
			return

		machine.visible_message(span_danger("[machine] dangerously overheats, launching a flaming fuel orb!"))
		machine.investigate_log("Experimentor has launched a <font color='red'>fireball</font> at [target_mob]!", INVESTIGATE_EXPERIMENTOR)
		var/obj/projectile/magic/fireball/fireball = new (start)
		fireball.preparePixelProjectile(target_turf, start)
		fireball.fire()
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, melting [exp_on] and releasing a burst of flame!"))
		explosion(machine, devastation_range = -1, heavy_impact_range = 0, light_impact_range = 0, adminlog = FALSE, ignorecap = FALSE, flame_range = 2, cause = "Experimentor Fire")
		machine.investigate_log("Experimentor started a fire.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)
		return

	if(prob(EFFECT_PROB_MEDIUM * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, melting [exp_on] and leaking hot air!"))
		var/datum/milla_safe/experimentor_temperature/milla = new()
		milla.invoke_async(machine, 100000, 1000)
		machine.investigate_log("Experimentor has released hot air.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)
		return

	if(!prob(EFFECT_PROB_MEDIUM * malf_chance))
		return

	machine.visible_message(span_warning("[machine] malfunctions, activating its emergency coolant systems!"))
	do_smoke(range = 1, holder = machine, location = get_turf(machine))
	for(var/mob/living/nearby_mob in oview(1, machine))
		nearby_mob.apply_damage(5, BURN, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST))
		machine.investigate_log("Experimentor has dealt minor burn damage to [key_name(nearby_mob)]", INVESTIGATE_EXPERIMENTOR)
	machine.item_eject()

/datum/experimentor_result_handler/scan/heat/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()

	if(!.)
		return

	machine.visible_message("[exp_on] begins to shake, and in the distance the sound of rampaging animals arises!")
	playsound(machine, 'sound/effects/supermatter.ogg', 50, 3, -1)
	machine.item_eject()
	var/turf/spawn_location = get_turf(exp_on)
	do_smoke(range = 1, holder = machine, location = spawn_location)
	var/obj/item/relict_production/pet_spray/relic = new (get_turf(spawn_location))
	relic.icon_state = exp_on.icon_state
	qdel(exp_on)

/// Cools the object
/datum/experimentor_result_handler/scan/cold
	name = "Freeze"
	fa_icon = "snowflake"
	scantype = SCANTYPE_COLD
	start_message_template = "lowers %ITEM%'s temperature."
	critical_prob = EFFECT_PROB_LOW
	relic_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s emergency coolant system gives off a small ding!"

/datum/experimentor_result_handler/scan/cold/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	playsound(machine, 'sound/machines/ding.ogg', 50, TRUE)
	var/obj/item/reagent_containers/food/drinks/cups/coffee_cup/small/coffee/experimentor/cold/cup = new (get_turf(pick(oview(1, machine))))
	machine.investigate_log("Experimentor has made a cup of [cup.selected_reagent] coffee.", INVESTIGATE_EXPERIMENTOR)

/datum/experimentor_result_handler/scan/cold/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine] malfunctions, shattering [exp_on] and releasing a dangerous cloud of coolant!"))
		do_chem_smoke(range = 2, holder = machine, location = get_turf(machine), reagent_type = /datum/reagent/consumable/frostoil, reagent_volume = 375)
		machine.investigate_log("Experimentor has released frostoil gas.", INVESTIGATE_EXPERIMENTOR)
		playsound(machine, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		QDEL_NULL(machine.loaded_item)
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_warning("[machine] malfunctions, shattering [exp_on] and leaking cold air!"))
		var/datum/milla_safe/experimentor_temperature/milla = new()
		milla.invoke_async(machine, -75000, 1000, TCMB)
		machine.investigate_log("Experimentor has released cold air.", INVESTIGATE_EXPERIMENTOR)
		QDEL_NULL(machine.loaded_item)
		return

	if(!prob(EFFECT_PROB_MEDIUM * malf_chance))
		return

	machine.visible_message(span_warning("[machine] malfunctions, releasing a flurry of chilly air as [exp_on] pops out!"))
	do_smoke(range = 1, holder = machine, location = get_turf(machine), smoke_type = /datum/effect_system/fluid_spread/smoke/freezing)
	var/datum/effect_system/fluid_spread/smoke/freezing/smoke = new
	smoke.set_up(range = 1, holder = machine, location = get_turf(machine))
	smoke.start()
	machine.item_eject()

/datum/milla_safe/experimentor_temperature

/datum/milla_safe/experimentor_temperature/on_run(obj/machinery/r_n_d/experimentor/experimentor, delta, min_new_temp)
	var/turf/location = get_turf(experimentor)
	var/datum/gas_mixture/env = get_turf_air(location)

	var/transfer_moles = 0.25 * env.total_moles()
	var/datum/gas_mixture/removed = env.remove(transfer_moles)
	if(removed)
		var/heat_capacity = removed.heat_capacity()
		if(heat_capacity == 0 || heat_capacity == null)
			heat_capacity = 1
		removed.set_temperature(max(min_new_temp, (removed.temperature() * heat_capacity + delta) / heat_capacity))
	env.merge(removed)

/datum/experimentor_result_handler/scan/cold/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()

	if(!.)
		return

	machine.visible_message("[exp_on] emits a loud pop!")
	playsound(machine, 'sound/effects/supermatter.ogg', 50, 3, -1)
	machine.item_eject()
	var/turf/spawn_location = get_turf(exp_on)
	do_smoke(range = 1, holder = machine, location = spawn_location)
	var/obj/item/relict_production/rapid_dupe/relic = new (get_turf(spawn_location))
	relic.icon_state = exp_on.icon_state
	qdel(exp_on)

/// Crushes the object
/datum/experimentor_result_handler/scan/obliterate
	name = "Obliterate"
	fa_icon = "trash"
	scantype = SCANTYPE_OBLITERATE
	start_message_template = "activates the crushing mechanism, %ITEM% is destroyed!"
	start_message_type = MSG_TYPE_WARNING
	critical_prob = EFFECT_PROB_LOW
	relic_prob = EFFECT_PROB_LOW
	critical_message_template = "%ITEM%'s crushing mechanism slowly and smoothly descends, flattening the %ITEM%!"

/datum/experimentor_result_handler/scan/obliterate/handle_critical(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	..()
	new /obj/item/stack/sheet/plasteel(get_turf(pick(oview(1, machine))))

/datum/experimentor_result_handler/scan/obliterate/handle_malfunctions(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/malf_chance = machine.get_malfunction_chance()

	var/obj/machinery/r_n_d/protolathe/linked_lathe = machine.linked_console.linked_lathe

	if(linked_lathe)
		var/datum/component/material_container/linked_materials = linked_lathe.GetComponent(/datum/component/material_container)
		for(var/material in exp_on.materials)
			linked_materials.insert_amount(min((linked_materials.max_amount - linked_materials.total_amount), (exp_on.materials[material])), material)

	if(prob(EFFECT_PROB_VERYLOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s crusher goes way too many levels too high, crushing right through space-time!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		machine.investigate_log("Experimentor has triggered the 'throw things' reaction.", INVESTIGATE_EXPERIMENTOR)

		for(var/atom/movable/atom_movable in oview(7, machine))
			if(!atom_movable.anchored)
				atom_movable.throw_at(machine, 10, 1)
		return

	if(prob(EFFECT_PROB_LOW * malf_chance))
		machine.visible_message(span_danger("[machine]'s crusher goes one level too high, crushing right into space-time!"))
		playsound(machine, 'sound/effects/supermatter.ogg', 50, TRUE, -3)
		machine.investigate_log("Experimentor has triggered the 'minor throw things' reaction.", INVESTIGATE_EXPERIMENTOR)

		var/list/throw_at = list()
		for(var/atom/movable/atom_movable in oview(7, machine))
			if(!atom_movable.anchored)
				throw_at.Add(atom_movable)

		for(var/counter in 1 to throw_at.len)
			var/atom/movable/cast = throw_at[counter]
			cast.throw_at(pick(throw_at), 10, 1)
		return

	QDEL_NULL(machine.loaded_item)

/datum/experimentor_result_handler/scan/obliterate/handle_relic(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	. = ..()
	if(!.)
		return

	machine.visible_message(span_warning("[src]'s crushing mechanism slowly and smoothly descends, flattening the [exp_on]!"))
	machine.item_eject()
	machine.critical_malfunction_counter++
	var/static/list/obj/item/stack/sheet/mineral/minreals
	if(!minreals)
		minreals = list(
			/obj/item/stack/sheet/mineral/diamond,
			/obj/item/stack/sheet/mineral/gold,
			/obj/item/stack/sheet/glass,
			/obj/item/stack/sheet/metal,
			/obj/item/stack/sheet/mineral/plasma,
			/obj/item/stack/sheet/mineral/silver,
			/obj/item/stack/sheet/mineral/titanium,
			/obj/item/stack/sheet/mineral/uranium,
			/obj/item/stack/sheet/mineral/tranquillite,
			/obj/item/stack/sheet/mineral/bananium
		)
	// Plastinium and abductor alloy are alloys, not processed ores.
	for(var/i in 1 to 3)
		var/material_type = pick(minreals)
		var/obj/item/stack/sheet/mineral/material = new material_type(get_turf(exp_on))
		material.amount = 10
	qdel(exp_on)

/// Experiment failure
/datum/experimentor_result_handler/fail
	start_message_type = MSG_TYPE_WARNING
	is_special = TRUE

/datum/experimentor_result_handler/fail/execute(obj/machinery/r_n_d/experimentor/machine, obj/item/exp_on)
	var/a = pick("rumbles", "shakes", "vibrates", "shudders", "honks")
	var/b = pick("crushes", "spins", "viscerates", "smashes", "insults")
	machine.visible_message(span_warning("[exp_on] [a], and [b], the experiment was a failure."))
