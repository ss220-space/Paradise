//- Are all the floors with or without air, as they should be? (regular or airless)
//- Does the area have an APC?
//- Does the area have an Air Alarm?
//- Does the area have a Request Console?
//- Does the area have lights?
//- Does the area have a light switch?
//- Does the area have enough intercoms?
//- Does the area have enough security cameras? (Use the 'Camera Range Display' verb under Debug)
//- Is the area connected to the scrubbers air loop?
//- Is the area connected to the vent air loop? (vent pumps)
//- Is everything wired properly?
//- Does the area have a fire alarm and firedoors?
//- Do all pod doors work properly?
//- Are accesses set properly on doors, pod buttons, etc.
//- Are all items placed properly? (not below vents, scrubbers, tables)
//- Does the disposal system work properly from all the disposal units in this room and all the units, the pipes of which pass through this room?
//- Check for any misplaced or stacked piece of pipe (air and disposal)
//- Check for any misplaced or stacked piece of wire
//- Identify how hard it is to break into the area and where the weak points are
//- Check if the area has too much empty space. If so, make it smaller and replace the rest with maintenance tunnels.

/obj/effect/debugging/marker
	icon = 'icons/area/areas.dmi'
	icon_state = "yellow"

/obj/effect/debugging/marker/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	return FALSE

ADMIN_VERB_VISIBILITY(camera_view, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(camera_view, R_DEBUG, "Camera Range Display", "Shows the range of cameras on the station.", ADMIN_CATEGORY_MAPPING)
	var/static/camera_range_display_status = FALSE
	camera_range_display_status = !camera_range_display_status

	for(var/obj/effect/debugging/marker/M in world)
		qdel(M)

	if(camera_range_display_status)
		for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
			for(var/turf/T in orange(7, C))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if(!(F in view(7, C.loc)))
					qdel(F)

	BLACKBOX_LOG_ADMIN_VERB("Show Camera Range")

ADMIN_VERB_VISIBILITY(sec_camera_report, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(sec_camera_report, R_DEBUG, "Camera Report", "Get a printout of all camera issues.", ADMIN_CATEGORY_MAPPING)
	var/list/obj/machinery/camera/CL = list()

	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras)
		CL += C

	var/output = {"<b>CAMERA ANOMALIES REPORT</b><hr>
<b>The following anomalies have been detected. The ones in red need immediate attention: Some of those in black may be intentional.</b><br><ul>"}

	for(var/obj/machinery/camera/C1 in CL)
		for(var/obj/machinery/camera/C2 in CL)
			if(C1 != C2)
				if(C1.c_tag == C2.c_tag)
					output += "<li><font color='red'>c_tag match for sec. cameras at [ADMIN_VERBOSEJMP(C1)] and [ADMIN_VERBOSEJMP(C2)] - c_tag is [C1.c_tag]</font></li>"
				if(C1.loc == C2.loc && C1.dir == C2.dir && C1.pixel_x == C2.pixel_x && C1.pixel_y == C2.pixel_y)
					output += "<li><font color='red'>FULLY overlapping sec. cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [C1.network] and [C2.network]</font></li>"
				if(C1.loc == C2.loc)
					output += "<li>overlapping sec. cameras at [ADMIN_VERBOSEJMP(C1)] Networks: [C1.network] and [C2.network]</font></li>"
		var/turf/T = get_step(C1,turn(C1.dir,180))
		if(!T || !isturf(T) || !T.density)
			if(!(locate(/obj/structure/grille,T)))
				var/window_check = 0
				for(var/obj/structure/window/W in T)
					if(W.dir == turn(C1.dir,180) || W.fulltile)
						window_check = 1
						break
				if(!window_check)
					output += "<li><font color='red'>Camera not connected to wall at [ADMIN_VERBOSEJMP(C1)] Network: [C1.network]</color></li>"

	output += "</ul>"
	var/datum/browser/popup = new(user, "airreport", "CAMERA ANOMALIES REPORT", 1000, 500)
	popup.set_content(output)
	popup.open(FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Show Camera Report")

ADMIN_VERB_VISIBILITY(intercom_view, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(intercom_view, R_DEBUG, "Intercom Range Display", "Shows the range of intercoms on the station.", ADMIN_CATEGORY_MAPPING)
	var/static/intercom_range_display_status = FALSE
	intercom_range_display_status = !intercom_range_display_status

	for(var/obj/effect/debugging/marker/marker in world)
		qdel(marker)

	if(intercom_range_display_status)
		for(var/obj/item/radio/intercom/I in GLOB.global_radios)
			for(var/turf/T in orange(7, I))
				var/obj/effect/debugging/marker/F = new/obj/effect/debugging/marker(T)
				if(!(F in view(7, I.loc)))
					qdel(F)
	BLACKBOX_LOG_ADMIN_VERB("Show Intercom Range")

ADMIN_VERB_VISIBILITY(count_objects_on_z_level, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(count_objects_on_z_level, R_DEBUG, "Count Objects On Z-Level", "Counts the number of objects of a certain type on a specific z-level.", ADMIN_CATEGORY_MAPPING)
	var/level = tgui_input_text(user, "Which z-level?", "Level?")
	if(!level)
		return
	var/num_level = text2num(level)
	if(!num_level)
		return
	if(!isnum(num_level))
		return

	var/type_text = tgui_input_text(user, "Which type path?","Path?")
	if(!type_text)
		return
	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0
	var/list/atom/atom_list = list()
	for(var/atom/A in world)
		if(istype(A,type_path))
			var/atom/B = A
			while(!(isturf(B.loc)))
				if(B?.loc)
					B = B.loc
				else
					break
			if(B)
				if(B.z == num_level)
					count++
					atom_list += A

	to_chat(world, "There are [count] objects of type [type_path] on z-level [num_level].", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Count Objects Zlevel")

ADMIN_VERB_VISIBILITY(count_objects_all, ADMIN_VERB_VISIBLITY_FLAG_MAPPING_DEBUG)
ADMIN_VERB(count_objects_all, R_DEBUG, "Count Objects All", "Counts the number of objects of a certain type in the game world.", ADMIN_CATEGORY_MAPPING)
	var/type_text = tgui_input_text(user, "Which type path?", "")
	if(!type_text)
		return

	var/type_path = text2path(type_text)
	if(!type_path)
		return

	var/count = 0
	for(var/atom/A in world)
		if(istype(A,type_path))
			count++

	to_chat(world, "There are [count] objects of type [type_path] in the game world.", confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Count Objects All")
