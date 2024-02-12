/obj/spacepod
	//Action datums
	var/datum/action/innate/pod/pod_eject/eject_action = new
	var/datum/action/innate/pod/pod_toggle_internals/internals_action = new
	var/datum/action/innate/pod/pod_toggle_lights/lights_action = new
	var/datum/action/innate/pod/pod_fire/fire_action = new
	var/datum/action/innate/pod/pod_lock/lock_action = new
	var/datum/action/innate/pod/pod_remote_door/door_action = new
	var/datum/action/innate/pod/pod_unload/unload_action = new
	var/datum/action/innate/pod/pod_check_seat/seat_action = new

/obj/spacepod/proc/GrantActions(mob/living/user, pilot = FALSE)
	eject_action.Grant(user, src)
	if(pilot)
		internals_action.Grant(user, src)
		lights_action.Grant(user, src)
		door_action.Grant(user, src)
		if(equipment_system.lock_system)
			lock_action.Grant(user, src)
		if(equipment_system.weapon_system)
			fire_action.Grant(user, src)
		if(equipment_system.cargo_system)
			unload_action.Grant(user, src)
	seat_action.Grant(user, src)

/obj/spacepod/proc/RemoveActions(mob/living/user, pilot = FALSE)
	eject_action.Remove(user)
	if(pilot)
		internals_action.Remove(user)
		lights_action.Remove(user)
		door_action.Remove(user)
		if(equipment_system.lock_system)
			lock_action.Remove(user)
		if(equipment_system.weapon_system)
			fire_action.Remove(user)
		if(equipment_system.cargo_system)
			unload_action.Remove(user)
	seat_action.Remove(user)

/datum/action/innate/pod
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_spacepod.dmi'
	var/obj/spacepod/pod
	var/list/mob/owners = list()

/datum/action/innate/pod/Grant(mob/living/L, obj/spacepod/P)
	if(P)
		pod = P
	owners += L
	. = ..()

/datum/action/innate/pod/Remove(mob/user)
	. = ..()
	owners -= user

/datum/action/innate/pod/Destroy()
	pod = null
	return ..()

/datum/action/innate/pod/pod_eject
	name = "Exit Pod"
	button_icon_state = "pod_eject"

/datum/action/innate/pod/pod_eject/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return

	pod.occupant_sanity_check()

	if(user.restrained())
		to_chat(user, span_notice("You attempt to stumble out of [pod]. This will take two minutes."))
		if(pod.pilot)
			to_chat(pod.pilot, span_warning("[user] is trying to escape [pod]."))
		if(!do_after(user, 2 MINUTES, target = pod))
			return

	if(user == pod.pilot)
		pod.eject_pilot()
		to_chat(user, span_notice("You climb out of [pod]."))
	if(user in pod.passengers)
		pod.eject_passenger(user)
		to_chat(user, span_notice("You climb out of [pod]."))
	user.update_gravity(user.mob_has_gravity())


/datum/action/innate/pod/pod_toggle_internals
	name = "Toggle internal airtank usage"
	button_icon_state = "pod_internals_on"

/datum/action/innate/pod/pod_toggle_internals/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	pod.use_internal_tank = !pod.use_internal_tank
	button_icon_state = "pod_internals_[pod.use_internal_tank ? "on" : "off"]"
	to_chat(user, span_notice("Now taking air from [pod.use_internal_tank?"internal airtank":"environment"]."))


/datum/action/innate/pod/pod_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "pod_lights_off"

/datum/action/innate/pod/pod_toggle_lights/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	pod.lightsToggle()
	button_icon_state = "pod_lights_[pod.lights ? "on" : "off"]"


/datum/action/innate/pod/pod_lock
	name = "Lock Doors"
	button_icon_state = "pod_lock_off"

/datum/action/innate/pod/pod_lock/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	if(!pod.equipment_system.lock_system)
		to_chat(user, span_warning("[pod] has no locking mechanism."))
		pod.unlocked = TRUE //Should never be false without a lock, but if it somehow happens, that will force an unlock.
		return
	pod.unlocked = !pod.unlocked
	to_chat(user, span_warning("You [pod.unlocked ? "unlock" : "lock"] the doors."))
	button_icon_state = "pod_lock_[pod.unlocked ? "off" : "on"]"


/datum/action/innate/pod/pod_remote_door
	name = "Toggle Nearby Pod Doors"
	button_icon_state = "pod_remote_open"

/datum/action/innate/pod/pod_remote_door/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	for(var/obj/machinery/door/poddoor/multi_tile/P in orange(3, pod))
		var/mob/living/carbon/human/L = user
		if(P.check_access(L.get_active_hand()) || P.check_access(L.wear_id))
			if(P.density)
				P.open()
				return
			else
				P.close()
				return
		for(var/mob/living/carbon/human/O in pod.passengers)
			if(P.check_access(O.get_active_hand()) || P.check_access(O.wear_id))
				if(P.density)
					P.open()
					return
				else
					P.close()
					return
		to_chat(user, span_warning("Access denied."))
		return

	to_chat(user, span_warning("You are not close to any pod doors."))


/datum/action/innate/pod/pod_fire
	name = "Fire Pod Weapons"
	button_icon_state = "pod_fire"

/datum/action/innate/pod/pod_fire/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	if(!pod.equipment_system.weapon_system)
		to_chat(user, span_warning("[pod] has no weapons!"))
		return
	pod.equipment_system.weapon_system.fire_weapons()


/datum/action/innate/pod/pod_unload
	name = "Unload Cargo"
	button_icon_state = "pod_unload"

/datum/action/innate/pod/pod_unload/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	if(!pod.equipment_system.cargo_system)
		to_chat(user, span_warning("[pod] has no cargo system!"))
		return
	pod.equipment_system.cargo_system.unload()

/datum/action/innate/pod/pod_check_seat
	name = "Check under Seat"
	button_icon_state = "pod_seat"

/datum/action/innate/pod/pod_check_seat/Activate()
	var/mob/living/user = usr
	if(!owners || !pod || !istype(user) || !(user in pod))
		return
	if(user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
	to_chat(user, span_notice("You start rooting around under the seat for lost items"))
	if(!do_after(user, 40, target = pod))
		to_chat(user, span_notice("You decide against searching the [pod]"))
		return
	var/obj/badlist = list(pod.internal_tank, pod.cargo_hold, pod.pilot, pod.battery) + pod.passengers + pod.equipment_system.installed_modules
	var/list/true_contents = pod.contents - badlist
	if(!length(true_contents))
		to_chat(user, span_notice("You fail to find anything of value."))
		return
	var/obj/I = pick(true_contents)
	if(!user.put_in_any_hand_if_possible(I))
		to_chat(user, span_notice("You think you saw something shiny, but you can't reach it!"))
		return
	pod.contents -= I
	to_chat(user, span_notice("You find a [I] [pick("under the seat", "under the console", "in the maintenance access")]!"))

