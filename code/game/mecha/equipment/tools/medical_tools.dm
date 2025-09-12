// Sleeper, and Syringe gun

/obj/item/mecha_parts/mecha_equipment/medical

/obj/item/mecha_parts/mecha_equipment/medical/New()
	..()
	START_PROCESSING(SSobj, src)


/obj/item/mecha_parts/mecha_equipment/medical/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/medical) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/attach_act(obj/mecha/M)
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/get_reagent_data(list/datum/reagent/reagent_list)
	. = list()
	if(!length(reagent_list))
		return

	for(var/datum/reagent/reagent as anything in reagent_list)
		. += list(list("name" = reagent.name, "id" = reagent.id, "volume" = round(reagent.volume, 0.01)))

/obj/item/mecha_parts/mecha_equipment/medical/detach_act()
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper
	name = "mounted sleeper"
	desc = "Equipment for medical exosuits. A mounted sleeper that stabilizes patients and can inject reagents in the exosuit's reserves."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "sleeper"
	origin_tech = "engineering=3;biotech=3;plasmatech=2"
	energy_drain = 20
	range = MECHA_MELEE
	equip_cooldown = 2 SECONDS
	var/mob/living/carbon/patient = null
	var/inject_amount = 10
	salvageable = FALSE
	/// List of reagents IDs, which will use touch reaction instead of ingest, upon injecting the patient.
	var/static/list/reagent_ingest_blacklist = list(
		/datum/reagent/medicine/styptic_powder,
		/datum/reagent/medicine/silver_sulfadiazine,
		/datum/reagent/medicine/synthflesh
	)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/AllowDrop()
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/Exit(atom/movable/leaving, atom/newLoc)
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/action(mob/living/carbon/target)
	if(!action_checks(target))
		return FALSE
	if(!istype(target))
		return FALSE
	if(!patient_insertion_check(target))
		return FALSE
	if(get_dist(chassis, target) > 1)
		occupant_message(span_warning("[target] слишком далеко для погрузки."))
		return FALSE
	occupant_message(span_notice("You start putting [target] into [src]..."))
	chassis.visible_message(span_warning("[chassis] starts putting [target] into \the [src]."))
	if(!do_after_cooldown(target))
		return FALSE
	if(!patient_insertion_check(target))
		return FALSE
	target.forceMove(src)
	patient = target
	START_PROCESSING(SSobj, src)
	occupant_message(span_notice("[target] successfully loaded into [src]. Life support functions engaged."))
	chassis.visible_message(span_warning("[chassis] loads [target] into [src]."))

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/patient_insertion_check(mob/living/carbon/target)
	if(target.buckled)
		occupant_message(span_warning("[target] will not fit into the sleeper because [target.p_they()] [target.p_are()] buckled to [target.buckled]!"))
		return FALSE
	if(target.has_buckled_mobs())
		occupant_message(span_warning("[target] will not fit into the sleeper because of the creatures attached to it!"))
		return FALSE
	if(patient)
		occupant_message(span_warning("The sleeper is already occupied!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/go_out(force)
	if(!action_checks(src) && !force)	// Patiens always can leave this cage.
		return FALSE
	if(!patient)
		return FALSE
	patient.forceMove(get_turf(src))
	occupant_message("[patient] ejected. Life support functions disabled.")
	STOP_PROCESSING(SSobj, src)
	patient = null

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/can_detach()
	if(patient)
		occupant_message(span_warning("Unable to detach [src] - equipment occupied!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/get_snowflake_data()
	var/list/data = list("snowflake_id" = MECHA_SNOWFLAKE_ID_SLEEPER)

	if(isnull(patient))
		return data

	var/patient_state
	switch(patient.stat)
		if(CONSCIOUS)
			patient_state = "Conscious"
		if(UNCONSCIOUS)
			patient_state = "Unconscious"
		if(DEAD)
			patient_state = "*Dead*"
		else
			patient_state = "Unknown"

	var/core_temp = ""
	if(ishuman(patient))
		var/mob/living/carbon/human/humi = patient
		core_temp = humi.bodytemperature-T0C

	data["patient"] = list(
		"patient_name" = patient.name,
		"patient_health" = patient.health/patient.maxHealth,
		"patient_state" = patient_state,
		"core_temp" = core_temp,
		"brute_loss" = patient.getBruteLoss(),
		"burn_loss" = patient.getFireLoss(),
		"toxin_loss" = patient.getToxLoss(),
		"oxygen_loss" = patient.getOxyLoss(),
	)

	data["contained_reagents"] = get_reagent_data(patient.reagents.reagent_list)
	data["has_brain_damage"] = patient.getBrainLoss() != 0
	data["has_clone_damage"] = patient.getCloneLoss() != 0

	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/shooter = locate(/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun) in chassis
	if(shooter)
		data["injectible_reagents"] = get_reagent_data(shooter.reagents.reagent_list)

	return data

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/handle_ui_act(action, list/params)
	if(action == "eject")
		go_out()
		return TRUE

	var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/shooter = locate() in chassis
	if(!shooter)
		return FALSE

	if(action == "inject_reagent")
		var/datum/reagent/medication = shooter.reagents.has_reagent(params["reagent"])
		if(!medication)
			return FALSE
		inject_reagent(medication, shooter)

	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/proc/inject_reagent(datum/reagent/R, obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/SG)
	if(!action_checks(src))
		return FALSE

	if(!R || !patient || !SG || !(SG in chassis.equipment))
		return

	var/to_inject = min(R.volume, inject_amount)
	if(to_inject)
		occupant_message("Applying [to_inject] units of [R.name] to [patient].")
		add_attack_logs(chassis.occupant, patient, "Injected with [name] containing [R], transferred [to_inject] units", R.harmless ? ATKLOG_ALMOSTALL : null)
		var/datum/reagents/chosen_reagent = new(to_inject)
		chosen_reagent.add_reagent(R.id, to_inject)
		SG.reagents.remove_reagent(R.id, to_inject, TRUE)
		var/fraction = min(inject_amount / to_inject, 1)
		var/method = REAGENT_INGEST
		for(var/r_type in reagent_ingest_blacklist)
			if(istype(R, r_type))
				method = REAGENT_TOUCH
				break

		chosen_reagent.reaction(patient, method, fraction)
		chosen_reagent.trans_to(patient, to_inject)
		start_cooldown()

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/container_resist()
	go_out(TRUE)

/obj/item/mecha_parts/mecha_equipment/medical/sleeper/process()
	if(..())
		return
	if(!chassis.has_charge(energy_drain))
		set_ready_state(TRUE)
		occupant_message("[src] deactivated - no power.")
		STOP_PROCESSING(SSobj, src)
		return
	var/mob/living/carbon/M = patient
	if(!M)
		return
	if(M.health > 0)
		M.adjustOxyLoss(-1)
	M.AdjustStunned(-8 SECONDS)
	M.AdjustWeakened(-8 SECONDS)
	if(M.reagents.get_reagent_amount("epinephrine") < 5)
		M.reagents.add_reagent("epinephrine", 5)
	chassis.use_power(energy_drain)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun
	name = "exosuit syringe gun"
	desc = "Equipment for medical exosuits. A chem synthesizer with syringe gun. Reagents inside are held in stasis, so no reactions will occur."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "syringegun"
	var/list/syringes
	var/list/known_reagents
	var/list/processed_reagents
	var/max_syringes = 10
	var/max_volume = 75 //max reagent volume
	var/synth_speed = 5 //[num] reagent units per cycle
	energy_drain = 10
	var/emagged = FALSE
	/// Toggler for alternative "analyze reagents" mode.
	var/mode = FIRE_SYRINGE_MODE
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 1 SECONDS
	origin_tech = "materials=3;biotech=4;magnets=4"

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/New()
	..()
	create_reagents(max_volume)
	reagents.set_reacting(FALSE)
	syringes = new
	known_reagents = list("epinephrine" = "Эпинефрин", "charcoal" = "Активированный уголь")
	processed_reagents = new

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/detach_act()
	STOP_PROCESSING(SSobj, src)
	if(istype(loc, /obj/mecha/medical/odysseus))
		var/obj/mecha/medical/odysseus/O = loc
		for(var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade/S in O.equipment)
			S.detach()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/critfail()
	..()
	if(reagents)
		reagents.set_reacting(TRUE)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/medical) || istype(M, /obj/mecha/combat/lockersyndie))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/get_snowflake_data()
	var/list/analyzed_reagents = list() // we need to make this list because .tsk wont map over an indexed array

	for(var/i = 1 to known_reagents.len)
		var/enabled = FALSE
		if(known_reagents[i] in processed_reagents)
			enabled = TRUE
		analyzed_reagents += list((list("name" = known_reagents[i], "enabled" = enabled)))

	var/list/data = list(
		"snowflake_id" = MECHA_SNOWFLAKE_ID_SYRINGE,
		"mode" = mode == FIRE_SYRINGE_MODE ? "Launch" : "Analyze",
		"mode_label" = "Action",
		"syringe" = LAZYLEN(syringes),
		"max_syringe" = max_syringes,
		"reagents" = reagents.total_volume,
		"total_reagents" = reagents.maximum_volume,
		"analyzed_reagents" = analyzed_reagents,
		"contained_reagents" =  get_reagent_data(reagents.reagent_list)
	)

	return data

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/synthesize(reagent)
	if(processed_reagents.len >= synth_speed)
		occupant_message("Достигнут максимум одновременных реагентов.")
		return

	if(!reagent || !(reagent in known_reagents))
		occupant_message("ОШИБКА. Неизвестный реагент.")
		return

	processed_reagents += reagent

	if(processed_reagents.len != 1)
		return

	START_PROCESSING(SSobj, src)
	occupant_message("Реагенты синтезируются.")

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/handle_ui_act(action, list/params)
	switch(action)
		if("change_mode")
			mode = !mode
			return TRUE
		if("purge_all")
			reagents.clear_reagents()
			return TRUE
		if("purge_reagent")
			reagents.del_reagent(params["reagent"])
			return TRUE
		if("toggle_reagent" )
			var/switch_reagent = params["reagent"]
			if(switch_reagent in processed_reagents)
				processed_reagents -= switch_reagent
			else
				synthesize(switch_reagent)
			return TRUE

	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/action(atom/movable/target)
	if(!action_checks(target))
		return FALSE
	if(istype(target, /obj/item/reagent_containers/syringe) || isstorage(target))
		if(get_dist(src, target) < 2)
			for(var/obj/structure/D in target.loc)//Basic level check for structures in the way (Like grilles and windows)
				if(!(D.CanPass(target, get_dir(D, loc))))
					occupant_message("Unable to load syringe.")
					return FALSE
			for(var/obj/machinery/door/D in target.loc)//Checks for doors
				if(!(D.CanPass(target, get_dir(D, loc))))
					occupant_message("Unable to load syringe.")
					return FALSE
			return start_syringe_loading(target)
	if(mode == ANALYZE_SYRINGE_MODE)
		return analyze_reagents(target)
	if(!is_faced_target(target))
		return FALSE
	if(!syringes.len)
		occupant_message(span_alert("No syringes loaded."))
		return FALSE
	if(reagents.total_volume<=0)
		occupant_message(span_alert("No available reagents to load syringe with."))
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/obj/item/reagent_containers/syringe/mechsyringe = syringes[1]
	mechsyringe.forceMove(get_turf(chassis))
	reagents.trans_to(mechsyringe, min(mechsyringe.volume, reagents.total_volume))
	syringes -= mechsyringe
	mechsyringe.icon = 'icons/obj/chemical.dmi'
	mechsyringe.icon_state = "syringeproj"
	playsound(chassis, 'sound/items/syringeproj.ogg', 50, TRUE)
	start_cooldown()
	INVOKE_ASYNC(src, PROC_REF(async_syringe_gun_action), mechsyringe, target_turf)


/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/async_syringe_gun_action(obj/item/reagent_containers/syringe/mechsyringe, turf/target_turf)
	var/mob/originaloccupant = chassis.occupant
	var/original_target_zone = originaloccupant.zone_selected
	src = null //if src is deleted, still process the syringe
	var/max_range = 6
	for(var/i=0, i<max_range, i++)
		if(!mechsyringe)
			break
		if(!step_towards(mechsyringe, target_turf))
			break

		var/list/mobs = new
		for(var/mob/living/carbon/M in mechsyringe.loc)
			mobs += M
		var/mob/living/carbon/M = safepick(mobs)
		if(M)
			var/R
			mechsyringe.visible_message(span_danger("[M] was hit by the syringe!"))
			if(M.can_inject(originaloccupant, TRUE, original_target_zone))
				if(mechsyringe.reagents)
					for(var/datum/reagent/A in mechsyringe.reagents.reagent_list)
						R += A.id + " ("
						R += num2text(A.volume) + "),"
				add_attack_logs(originaloccupant, M, "Shot with [src] containing [R], transferred [mechsyringe.reagents.total_volume] units")
				mechsyringe.reagents.reaction(M, REAGENT_INGEST)
				mechsyringe.reagents.trans_to(M, mechsyringe.reagents.total_volume)
				M.take_organ_damage(2)
			break
		else if(mechsyringe.loc == target_turf)
			break
		sleep(1)

	if(mechsyringe)
		// Revert the syringe icon to normal one once it stops flying.
		mechsyringe.icon_state = initial(mechsyringe.icon_state)
		mechsyringe.icon = initial(mechsyringe.icon)
		mechsyringe.update_icon()

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		user.visible_message(span_warning("Sparks fly out of the [src]!</span>"), span_notice("You short out the safeties on[src]."))
		playsound(loc, 'sound/effects/sparks4.ogg', 50, TRUE)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/load_syringe(obj/item/reagent_containers/syringe/syringe)
	if(syringes.len >= max_syringes)
		occupant_message("The [src] syringe chamber is full.")
		return FALSE
	syringe.reagents.trans_to(src, syringe.reagents.total_volume)
	syringe.forceMove(src)
	syringes += syringe
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/start_syringe_loading(obj/item/ammunition)
	var/lock_n_load = 0
	if(istype(ammunition, /obj/item/reagent_containers/syringe))
		if(!load_syringe(ammunition))
			return FALSE
	else
		var/obj/item/storage/storage = ammunition
		for(var/obj/item/reagent_containers/syringe/syringe in storage.contents)
			if(!load_syringe(syringe))
				break
			lock_n_load ++
		if(!lock_n_load)
			return FALSE
	occupant_message("Syringe[lock_n_load > 1 ? "s (x[lock_n_load])" : ""] loaded.")
	start_cooldown()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/analyze_reagents(atom/A)
	if(get_dist(src, A) >= 4)
		occupant_message("The object is too far away.")
		return FALSE
	if(!A.reagents || istype(A,/mob))
		occupant_message(span_alert("No reagent info gained from [A]."))
		return FALSE
	occupant_message("Analyzing reagents...")
	for(var/datum/reagent/R in A.reagents.reagent_list)
		if((emagged && (R.id in strings("chemistry_tools.json", "traitor_poison_bottle")) || R.can_synth) && add_known_reagent(R.id, R.name))
			occupant_message("Reagent analyzed, identified as [R.name] and added to database.")
	occupant_message("Analyzis complete.")

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/proc/add_known_reagent(r_id,r_name)
	if(!(r_id in known_reagents))
		known_reagents += r_id
		known_reagents[r_id] = r_name
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/process()
	if(..())
		return
	if(!processed_reagents.len || reagents.total_volume >= reagents.maximum_volume || !chassis.has_charge(energy_drain))
		occupant_message(span_alert("Синтезирование реагентов остановлено."))
		processed_reagents.len = 0
		STOP_PROCESSING(SSobj, src)
		return
	var/amount = synth_speed / processed_reagents.len
	for(var/reagent in processed_reagents)
		reagents.add_reagent(reagent,amount)
		chassis.use_power(energy_drain)

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade
	name = "additional system for the reproduction of reagents"
	desc = "Upgrade for the syringe gun. Increases synthesis speed and maximum capacity of reagents. Requires installation of the syringe gun system."
	icon = 'icons/obj/mecha/mecha_equipment.dmi'
	icon_state = "beaker_upgrade"
	origin_tech = "materials=5;engineering=5;biotech=6"
	energy_drain = 10
	selectable = MODULE_SELECTABLE_NONE
	var/improv_max_volume = 300
	var/imrov_synth_speed = 20

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade/can_attach(obj/mecha/M)
	if(..())
		for(var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/S in M.equipment)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade/attach_act(obj/mecha/M)
	for(var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/S in chassis.equipment)
		S.max_volume = improv_max_volume
		S.synth_speed = imrov_synth_speed
		S.reagents.maximum_volume = improv_max_volume

/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun_upgrade/detach_act()
	for(var/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun/S in chassis.equipment)
		S.max_volume = initial(S.max_volume)
		S.synth_speed = initial(S.synth_speed)
		S.reagents.maximum_volume = S.max_volume

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw
	name = "rescue jaw"
	desc = "Emergency rescue jaws, designed to help first responders reach their patients. Opens doors and removes obstacles."
	icon_state = "mecha_clamp"	//can work, might use a blue resprite later but I think it works for now
	origin_tech = "materials=2;engineering=2"	//kind of sad, but identical to jaws of life
	equip_cooldown = 1.5 SECONDS
	energy_drain = 10
	var/dam_force = 20


/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/action(atom/target)
	if(!action_checks(target))
		return FALSE
	if(isobj(target))
		if(!istype(target, /obj/machinery/door))//early return if we're not trying to open a door
			return FALSE
		set_ready_state(FALSE)
		var/obj/machinery/door/D = target	//the door we want to open
		D.try_to_crowbar(chassis.occupant, src)//use the door's crowbar function
		set_ready_state(TRUE)
	else if(isliving(target))	//interact with living beings
		var/mob/living/M = target
		if(chassis.occupant.a_intent == INTENT_HARM)//the patented, medical rescue claw is incapable of doing harm. Worry not.
			target.visible_message(span_notice("[chassis] gently boops [target] on the nose, its hydraulics hissing as safety overrides slow a brutal punch down at the last second."), \
								span_notice("[chassis] gently boops [target] on the nose, its hydraulics hissing as safety overrides slow a brutal punch down at the last second."))
		else
			push_aside(chassis, M)//out of the way, I have people to save!
			occupant_message(span_notice("You gently push [target] out of the way."))
			chassis.visible_message(span_notice("[chassis] gently pushes [target] out of the way."))
		start_cooldown()

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/proc/push_aside(obj/mecha/M, mob/living/L)
	switch(get_dir(M, L))
		if(NORTH, SOUTH)
			if(prob(50))
				step(L, WEST)
			else
				step(L, EAST)
		if(WEST, EAST)
			if(prob(50))
				step(L, NORTH)
			else
				step(L, SOUTH)

/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw/can_attach(obj/mecha/M)
	if(istype(M, /obj/mecha/medical) || istype(M, /obj/mecha/working/ripley/firefighter) || istype(M, /obj/mecha/combat/lockersyndie))	//Odys or firefighters or syndielocker
		if(M.equipment.len < M.max_equip)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/medical/beamgun
	name = "Medical Beamgun"
	desc = "Передает целебные наниты своим сфокусированным лучом прямо из вашего уютного меха. Не скрещивайте лучи!"
	icon_state = "mech_beamgun"
	origin_tech = "bluespace=6;biotech=6;powerstorage=6"
	equip_cooldown = 1.5 SECONDS
	energy_drain = 50
	range = MECHA_MELEE | MECHA_RANGED
	var/obj/item/gun/medbeam/mech/mbeam

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/get_ru_names()
	return list(
		NOMINATIVE = "Медицинская Лучпушка",
		GENITIVE = "Медицинской Лучпушки",
		DATIVE = "Медицинской Лучпушке",
		ACCUSATIVE = "Медицинскую Лучпушку",
		INSTRUMENTAL = "Медицинской Лучпушкой",
		PREPOSITIONAL = "Медицинская Лучпушке"
	)

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/Initialize(mapload)
	. = ..()
	mbeam = new(src)

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/Destroy(force)
	QDEL_NULL(mbeam)
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/process()
	. = ..()

	if(.)
		return TRUE

	if(!chassis.use_power(energy_drain))
		set_ready_state(TRUE)
		occupant_message("[src] deactivated - no power.")
		return TRUE

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/action(mob/target)
	if(!mbeam.process_fire(target, loc))
		STOP_PROCESSING(SSobj, src)
		return

	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/detach()
	STOP_PROCESSING(SSobj, src)
	mbeam.LoseTarget()
	return ..()

/obj/item/mecha_parts/mecha_equipment/medical/beamgun/handle_occupant_exit()
	. = ..()
	mbeam.LoseTarget()
