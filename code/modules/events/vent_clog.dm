/datum/event/vent_clog
	startWhen		= 5
	endWhen			= 35
	var/interval	= 2
	var/list/vents  = list()

/datum/event/vent_clog/announce()
	GLOB.minor_announcement.announce(
		message = "Зафиксирован скачок обратного давления в системе вытяжных труб. Возможен выброс содержимого.",
		new_title = "Атмосферная тревога.",
		new_sound = 'sound/AI/scrubbers.ogg'
	)

/datum/event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/unary/vent_scrubber/temp_vent in SSmachines.get_by_type(/obj/machinery/atmospherics/unary/vent_scrubber))
		var/turf/vent_turf = get_turf(temp_vent)
		if(vent_turf && is_station_level(vent_turf.z) && !temp_vent.welded && !vent_turf.is_blocked_turf_ignore_climbable())
			if(length(temp_vent.parent.other_atmosmch) > 50)
				vents += temp_vent

/datum/event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/machinery/atmospherics/unary/vent_scrubber/vent = pick_n_take(vents)

		if(!vent || vent.welded)
			endWhen++
			return

		var/list/gunk = list(/datum/reagent/water,/datum/reagent/carbon,/datum/reagent/consumable/flour,/datum/reagent/radium,/datum/reagent/toxin,/datum/reagent/space_cleaner,/datum/reagent/consumable/nutriment,/datum/reagent/consumable/condensedcapsaicin,/datum/reagent/psilocybin,/datum/reagent/lube,
							/datum/reagent/glyphosate/atrazine,/datum/reagent/consumable/drink/banana,/datum/reagent/medicine/charcoal,/datum/reagent/space_drugs,/datum/reagent/methamphetamine,/datum/reagent/holywater,/datum/reagent/consumable/ethanol,/datum/reagent/consumable/hot_coco,/datum/reagent/acid/facid,
							/datum/reagent/blood,/datum/reagent/medicine/morphine,/datum/reagent/medicine/ether,/datum/reagent/fluorine,/datum/reagent/medicine/mutadone,/datum/reagent/mutagen,/datum/reagent/medicine/hydrocodone,/datum/reagent/fuel,
							/datum/reagent/medicine/haloperidol,/datum/reagent/lsd,/datum/reagent/medicine/syndicate_nanites,/datum/reagent/lipolicide,/datum/reagent/consumable/frostoil,/datum/reagent/medicine/salglu_solution,/datum/reagent/consumable/ethanol/beepsky_smash,
							/datum/reagent/medicine/omnizine, /datum/reagent/amanitin, /datum/reagent/consumable/ethanol/neurotoxin, /datum/reagent/medicine/synaptizine, /datum/reagent/rotatium)
		var/datum/reagents/R = new (2500)
		R.my_atom = vent
		R.add_reagent(pick(gunk), 2450)

		var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
		smoke.set_up(range = 3, location = vent, carry = R, silent = TRUE)
		playsound(vent.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
		smoke.start()
		add_game_logs("Smoke at [COORD(vent)] spread including [R.reagent_list]")
		qdel(R)
