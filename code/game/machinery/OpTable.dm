/obj/machinery/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/patient
	var/obj/machinery/computer/operating/computer
	var/no_icon_updates = FALSE //set this to TRUE if you don't want the icons ever changing
	var/list/injected_reagents = list()
	var/reagent_target_amount = 1
	var/inject_amount = 1

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/Destroy()
	if(computer)
		computer.table = null
		computer = null
	patient = null
	return ..()


/obj/machinery/optable/MouseDrop_T(atom/movable/O, mob/user, params)
	if(!ishuman(user) && !isrobot(user)) //Only Humanoids and Cyborgs can put things on this table
		return
	if(!check_table()) //If the Operating Table is occupied, you cannot put someone else on it
		return
	if(user.buckled || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //Is the person trying to use the table incapacitated or restrained?
		return
	if(!ismob(O) || !iscarbon(O)) //Only Mobs and Carbons can go on this table (no syptic patches please)
		return
	add_fingerprint(user)
	take_patient(O, user)
	return TRUE

/**
  * Updates the `patient` var to be the mob occupying the table
  */
/obj/machinery/optable/proc/update_patient()
	var/mob/living/carbon/patient_carbon = locate(/mob/living/carbon, loc)
	if(patient_carbon && patient_carbon.body_position == LYING_DOWN)
		patient = patient_carbon
	else
		patient = null
	if(!no_icon_updates)
		update_icon(UPDATE_ICON_STATE)


/obj/machinery/optable/update_icon_state()
	icon_state = "table2-[(patient && patient.pulse) ? "active" : "idle"]"


/obj/machinery/optable/process()
	update_patient()
	if(LAZYLEN(injected_reagents))
		for(var/mob/living/carbon/C in get_turf(src))
			var/datum/reagents/R = C.reagents
			for(var/chemical in injected_reagents)
				R.check_and_add(chemical,reagent_target_amount,inject_amount)

/obj/machinery/optable/proc/take_patient(mob/living/carbon/new_patient, mob/living/carbon/user)
	var/turf/table_turf = get_turf(src)
	if(!table_turf.CanPass(new_patient, table_turf))
		return FALSE

	if(new_patient == user)
		user.visible_message("[user] climbs on the operating table.","You climb on the operating table.")
	else
		visible_message(span_alert("[new_patient] has been laid on the operating table by [user]."))
	if(user.pulling == new_patient)
		user.stop_pulling()
	new_patient.forceMove(loc)
	new_patient.set_resting(TRUE, instant = TRUE)
	if(new_patient.s_active) //Close the container opened
		new_patient.s_active.close(new_patient)
	add_fingerprint(user)
	update_patient()

/obj/machinery/optable/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(!iscarbon(grabbed_thing))
		return .
	add_fingerprint(grabber)
	take_patient(grabbed_thing, grabber)


/obj/machinery/optable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		user.balloon_alert(user, "разобрано")
		new /obj/item/stack/sheet/plasteel(loc, 5)
		qdel(src)

/obj/machinery/optable/proc/check_table()
	update_patient()
	if(patient != null)
		balloon_alert(usr, span_notice("уже занято!"))
		return FALSE
	else
		return TRUE
