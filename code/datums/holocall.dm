#define CAN_HEAR_MASTERS (1<<0)
#define CAN_HEAR_ACTIVE_HOLOCALLS (1<<1)
#define CAN_HEAR_RECORD_MODE (1<<2)
#define CAN_HEAR_ALL_FLAGS (CAN_HEAR_MASTERS|CAN_HEAR_ACTIVE_HOLOCALLS|CAN_HEAR_RECORD_MODE)

/mob/camera/aiEye/remote/holo/setLoc(turf/destination, force_update = FALSE)
	. = ..()
	var/obj/machinery/hologram/holopad/H = origin
	H?.move_hologram(eye_user, loc)
	ai_detector_visible = FALSE // Holocalls dont trigger the Ai Detector

//this datum manages it's own references

/datum/holocall
	var/mob/living/user	//the one that called
	var/obj/machinery/hologram/holopad/calling_holopad	//the one that sent the call
	var/obj/machinery/hologram/holopad/connected_holopad	//the one that answered the call (may be null)
	var/list/dialed_holopads	//all things called, will be cleared out to just connected_holopad once answered

	var/mob/camera/aiEye/remote/holo/eye	//user's eye, once connected
	var/obj/effect/overlay/holo_pad_hologram/hologram	//user's hologram, once connected
	var/datum/action/innate/end_holocall/hangup	//hangup action

	var/call_start_time

//creates a holocall made by `requester` from `calling_pad` to `callees`
/datum/holocall/New(mob/living/requester, obj/machinery/hologram/holopad/calling_pad, list/callees)
	call_start_time = world.time
	user = requester
	calling_pad.outgoing_call = src
	calling_holopad = calling_pad
	dialed_holopads = list()

	for(var/obj/machinery/hologram/holopad/connected_holopad as anything in callees)
		if(!QDELETED(connected_holopad) && !(connected_holopad.stat & NOPOWER) && connected_holopad.anchored)
			dialed_holopads += connected_holopad
			var/area/area = get_area(connected_holopad)
			connected_holopad.set_holocall(src)
			connected_holopad.atom_say("[area] голопад звонит: входящий вызов от [requester]!")

	if(!length(dialed_holopads))
		calling_holopad.atom_say("Сбой соединения.")
		qdel(src)
		return

//cleans up ALL references :)
/datum/holocall/Destroy()
	QDEL_NULL(hangup)

	var/user_good = !QDELETED(user)
	if(user_good)
		user.reset_perspective()
		user.remote_control = null

	if(!QDELETED(eye))
		eye.RemoveImages()
		QDEL_NULL(eye)

	if(connected_holopad && !QDELETED(hologram))
		hologram = null
		connected_holopad.clear_holo(user)

	user = null

	//Hologram survived holopad destro
	if(!QDELETED(hologram))
		hologram.HC = null
		QDEL_NULL(hologram)

	for(var/obj/machinery/hologram/holopad/dialed_holopad as anything in dialed_holopads)
		dialed_holopad.set_holocall(src, FALSE)
	dialed_holopads.Cut()

	if(calling_holopad)//if the call is answered, then calling_holopad wont be in dialed_holopads and thus wont have set_holocall(src, FALSE) called
		calling_holopad.outgoing_call = null
		calling_holopad.SetLightsAndPower()
		calling_holopad = null
	if(connected_holopad)
		connected_holopad.SetLightsAndPower()
		connected_holopad = null
	return ..()

//Gracefully disconnects a holopad `H` from a call. Pads not in the call are ignored. Notifies participants of the disconnection
/datum/holocall/proc/Disconnect(obj/machinery/hologram/holopad/H)
	if(H == connected_holopad)
		var/area/A = get_area(connected_holopad)
		calling_holopad.atom_say("[A] голопад не отвечает.")
	else if(H == calling_holopad && connected_holopad)
		connected_holopad.atom_say("[user] не отвечает.")

	user.unset_machine(H)
	if(istype(hangup))
		hangup.Remove(user)

	ConnectionFailure(H, TRUE)

//Forcefully disconnects a holopad `disconnected_holopad` from a call. Pads not in the call are ignored.
/datum/holocall/proc/ConnectionFailure(obj/machinery/hologram/holopad/disconnected_holopad, graceful = FALSE)
	if(disconnected_holopad == connected_holopad || disconnected_holopad == calling_holopad)
		if(!graceful && disconnected_holopad != calling_holopad)
			calling_holopad.atom_say("Сбой соединения.")
		qdel(src)
		return

	disconnected_holopad.set_holocall(src, FALSE)

	dialed_holopads -= disconnected_holopad
	if(!length(dialed_holopads))
		if(graceful)
			calling_holopad.atom_say("Вызов отклонён.")
		qdel(src)

//Answers a call made to a holopad `answering_holopad` which cannot be the calling holopad. Pads not in the call are ignored
/datum/holocall/proc/Answer(obj/machinery/hologram/holopad/answering_holopad)
	if(answering_holopad == calling_holopad)
		return

	if(!(answering_holopad in dialed_holopads))
		return

	if(connected_holopad)
		return

	for(var/other_dialed_holopad in dialed_holopads)
		if(other_dialed_holopad == answering_holopad)
			continue
		Disconnect(other_dialed_holopad)

	for(var/datum/holocall/previously_answered_holocall as anything in answering_holopad.holo_calls)//disconnect the other holocalls answering_holopad is occupied with
		if(previously_answered_holocall != src)
			previously_answered_holocall.Disconnect(answering_holopad)

	connected_holopad = answering_holopad

	if(!Check())
		return

	hologram = answering_holopad.activate_holo(user)
	hologram.HC = src

	user.unset_machine(answering_holopad)
	//eyeobj code is horrid, this is the best copypasta I could make
	eye = new()
	eye.origin = answering_holopad
	eye.eye_initialized = TRUE
	eye.eye_user = user
	eye.name = "Camera Eye ([user.name])"
	user.remote_control = eye
	user.reset_perspective(eye)
	eye.setLoc(get_turf(answering_holopad))

	hangup = new(eye,src)
	hangup.Grant(user)
	playsound(answering_holopad, 'sound/machines/ping.ogg', 100)
	answering_holopad.atom_say("Соединение установлено.")

//Checks the validity of a holocall and qdels itself if it's not. Returns TRUE if valid, FALSE otherwise
/datum/holocall/proc/Check()
	for(var/obj/machinery/hologram/holopad/dialed_holopad as anything in dialed_holopads)
		if((dialed_holopad.stat & NOPOWER) || !dialed_holopad.anchored)
			ConnectionFailure(dialed_holopad)

	if(QDELETED(src))
		return FALSE

	. = !QDELETED(user) && !user.incapacitated() && !QDELETED(calling_holopad) && !(calling_holopad.stat & NOPOWER) && user.loc == calling_holopad.loc

	if(.)
		if(!connected_holopad)
			. = world.time < (call_start_time + HOLOPAD_MAX_DIAL_TIME)
			if(!.)
				calling_holopad.atom_say("Ответ не получен.")
				calling_holopad.temp = ""

	else if(!.)
		qdel(src)

/datum/action/innate/end_holocall
	name = "Закончить звонок"
	button_icon_state = "camera_off"
	var/datum/holocall/hcall

/datum/action/innate/end_holocall/New(Target, datum/holocall/HC)
	..()
	hcall = HC

/datum/action/innate/end_holocall/Activate()
	hcall.Disconnect(hcall.calling_holopad)

#undef CAN_HEAR_MASTERS
#undef CAN_HEAR_ACTIVE_HOLOCALLS
#undef CAN_HEAR_RECORD_MODE
#undef CAN_HEAR_ALL_FLAGS
