/obj/machinery/computer/camera_advanced
	name = "advanced camera console"
	desc = "Used to access the various cameras on the station."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	var/mob/camera/aiEye/remote/eyeobj
	var/mob/living/carbon/human/current_user = null
	var/list/networks = list("SS13")
	var/datum/action/innate/camera_off/off_action = new
	var/datum/action/innate/camera_jump/jump_action = new
	var/datum/action/innate/camera_multiz_up/move_up_action = new
	var/datum/action/innate/camera_multiz_down/move_down_action = new
	var/list/actions = list()

/obj/machinery/computer/camera_advanced/proc/CreateEye()
	eyeobj = new()
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/proc/GrantActions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.Grant(user)
		actions += off_action

	if(jump_action)
		jump_action.target = user
		jump_action.Grant(user)
		actions += jump_action

	if(move_up_action)
		move_up_action.target = user
		move_up_action.Grant(user)
		actions += move_up_action

	if(move_down_action)
		move_down_action.target = user
		move_down_action.Grant(user)
		actions += move_down_action

/obj/machinery/computer/camera_advanced/proc/remove_eye_control(mob/living/user)
	if(!user)
		return
	for(var/V in actions)
		var/datum/action/A = V
		A.Remove(user)
	actions.Cut()
	if(user.client)
		user.reset_perspective(null)
		eyeobj.RemoveImages()
	eyeobj.eye_user = null
	user.remote_control = null

	current_user = null
	user.unset_machine()
	for(var/atom/movable/screen/plane_master/plane_static in user.hud_used?.get_true_plane_masters(CAMERA_STATIC_PLANE))
		plane_static.hide_plane(user)
	playsound(src, 'sound/machines/terminal_off.ogg', 25, 0)

/obj/machinery/computer/camera_advanced/check_eye(mob/user)
	if((stat & (NOPOWER|BROKEN)) || (!Adjacent(user) && !user.has_unlimited_silicon_privilege) || !user.has_vision() || user.incapacitated())
		user.unset_machine()

/obj/machinery/computer/camera_advanced/Destroy()
	if(current_user)
		current_user.unset_machine()
	QDEL_NULL(eyeobj)
	QDEL_LIST(actions)
	return ..()

/obj/machinery/computer/camera_advanced/on_unset_machine(mob/M)
	if(M == current_user)
		remove_eye_control(M)

/obj/machinery/computer/camera_advanced/attack_hand(mob/user)
	if(current_user)
		to_chat(user, "The console is already in use!")
		return
	if(!iscarbon(user))
		return
	if(..())
		return
	user.set_machine(src)

	if(!eyeobj)
		CreateEye()

	if(!eyeobj.eye_initialized)
		var/turf/camera_location
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			if(!C.can_use())
				continue
			if(C.network&networks)
				camera_location = get_turf(C)
				break
		if(camera_location)
			eyeobj.eye_initialized = 1
			give_eye_control(user)
			eyeobj.setLoc(camera_location)
		else
			// An abberant case - silent failure is obnoxious
			to_chat(user, span_warning("ERROR: No linked and active camera network found."))
			user.unset_machine()
	else
		give_eye_control(user)
		eyeobj.setLoc(get_turf(eyeobj.loc))


/obj/machinery/computer/camera_advanced/proc/give_eye_control(mob/user)
	GrantActions(user)
	current_user = user
	eyeobj.eye_user = user
	eyeobj.name = "Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	// Who passes control like this god I hate static code
	for(var/atom/movable/screen/plane_master/plane_static in user.hud_used?.get_true_plane_masters(CAMERA_STATIC_PLANE))
		plane_static.unhide_plane(user)

/mob/camera/aiEye/remote
	name = "Inactive Camera Eye"
	icon_state = "remote"
	var/sprint = 10
	var/cooldown = 0
	var/acceleration = 0
	var/mob/living/carbon/human/eye_user = null
	var/obj/machinery/computer/camera_advanced/origin
	var/eye_initialized = 0
	var/visible_icon = 0
	var/image/user_image = null
	ai_detector_visible = FALSE // Abductors dont trigger the Ai Detector

/mob/camera/aiEye/remote/Destroy()
	eye_user = null
	origin = null
	return ..()

/mob/camera/aiEye/remote/update_remote_sight(mob/living/user)
	user.set_invis_see(SEE_INVISIBLE_LIVING) //can't see ghosts through cameras
	set_sight(SEE_TURFS)
	user.nightvision = 2
	return 1

/mob/camera/aiEye/remote/RemoveImages()
	..()
	if(visible_icon)
		var/client/C = GetViewerClient()
		if(C)
			C.images -= user_image

/mob/camera/aiEye/remote/GetViewerClient()
	if(eye_user)
		return eye_user.client
	return null

/mob/camera/aiEye/remote/setLoc(turf/destination, force_update = FALSE)
	if(eye_user)
		if(!isturf(eye_user.loc) || !destination)
			return
		abstract_move(destination)

		if(use_static)
			GLOB.cameranet.visibility(src, GetViewerClient())
		if(visible_icon)
			if(eye_user.client)
				eye_user.client.images -= user_image
				user_image = image(icon,loc,icon_state,FLY_LAYER)
				SET_PLANE(user_image, ABOVE_GAME_PLANE, destination)
				eye_user.client.images += user_image

/mob/camera/aiEye/remote/relaymove(mob/user,direct)
	if(world.time < last_movement)
		return
	last_movement = world.time + 0.5 // cap to 20fps

	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/T = get_turf(get_step_multiz(src, direct))
		if(T && can_move(T, user))
			src.setLoc(T)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/mob/camera/aiEye/remote/proc/can_move(turf/target_turf, mob/user)
	var/dir = get_dir_multiz(get_turf(src), target_turf)
	if(dir & (UP|DOWN))
		if(!can_z_move(null, get_turf(src), target_turf, ZMOVE_INCAPACITATED_CHECKS | ZMOVE_FEEDBACK, user))
			return FALSE
	return TRUE

/datum/action/innate/camera_off
	name = "End Camera View"
	button_icon_state = "camera_off"

/datum/action/innate/camera_off/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/console = remote_eye.origin
	console.remove_eye_control(target)

/datum/action/innate/camera_jump
	name = "Jump To Camera"
	button_icon_state = "camera_jump"

/datum/action/innate/camera_jump/Activate()
	if(!target || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/obj/machinery/computer/camera_advanced/origin = remote_eye.origin

	var/list/L = list()

	for(var/obj/machinery/camera/cam in GLOB.cameranet.cameras)
		L.Add(cam)

	camera_sort(L)

	var/list/T = list()

	for(var/obj/machinery/camera/netcam in L)
		var/list/tempnetwork = netcam.network&origin.networks
		if(tempnetwork.len)
			T[text("[][]", netcam.c_tag, (netcam.can_use() ? null : " (Deactivated)"))] = netcam


	playsound(origin, 'sound/machines/terminal_prompt.ogg', 25, 0)
	var/camera = tgui_input_list(target, "Choose which camera you want to view", "Cameras", T)
	var/obj/machinery/camera/final = T[camera]
	playsound(origin, "terminal_type", 25, 0)
	if(final)
		playsound(origin, 'sound/machines/terminal_prompt_confirm.ogg', 25, 0)
		remote_eye.setLoc(get_turf(final))
		C.overlay_fullscreen("flash", /atom/movable/screen/fullscreen/flash/noise)
		C.clear_fullscreen("flash", 3) //Shorter flash than normal since it's an ~~advanced~~ console!
	else
		playsound(origin, 'sound/machines/terminal_prompt_deny.ogg', 25, 0)

/datum/action/innate/camera_multiz_up
	name = "Move up a floor"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "move_up"

/datum/action/innate/camera_multiz_up/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(UP))
		to_chat(owner, span_notice("You move upwards."))
	else
		to_chat(owner, span_notice("You couldn't move upwards!"))

/datum/action/innate/camera_multiz_down
	name = "Move down a floor"
	button_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "move_down"

/datum/action/innate/camera_multiz_down/Activate()
	if(!owner || !isliving(owner))
		return
	var/mob/camera/aiEye/remote/remote_eye = owner.remote_control
	if(remote_eye.zMove(DOWN))
		to_chat(owner, span_notice("You move downwards."))
	else
		to_chat(owner, span_notice("You couldn't move downwards!"))
