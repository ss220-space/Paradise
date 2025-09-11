#define PARTICLE_LEFT 1
#define PARTICLE_CENTER 2
#define PARTICLE_RIGHT 3
#define EMITTER 1
#define POWER_BOX 2
#define FUEL_CHAMBER 3
#define END_CAP 4
/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This part controls the density of the particles."
	icon = 'icons/obj/engines_and_power/particle_accelerator.dmi'
	icon_state = "control_box"
	reference = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	construction_state = 0
	active = FALSE
	dir = 1
	var/strength_upper_limit = 2
	var/interface_control = 1
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = TRUE
	var/parts = null
	var/datum/wires/particle_acc/control_box/wires = null
	/// Layout of the particle accelerator. Used by the UI
	var/list/layout = list(
		list(list("name" = "EM Containment Grid Left", "icon_state" = "emitter_right", "status" = "Not In Position", "dir" = 1), list("name" = "Blank1", "icon_state" = "blank", "status" = "good", "dir" = 1), list("name" = "Blank2", "icon_state" = "blank", "status" = "good", "dir" = 1), list("name" = "Blank3", "icon_state" = "blank", "status" = "good", "dir" = 1)),
		list(list("name" = "EM Containment Grid Center", "icon_state" = "emitter_center", "status" = "Not In Position", "dir" = 1), list("name" = "Particle Focusing EM Lens", "icon_state" = "power_box", "status" = "Not In Position", "dir" = 1), list("name" = "EM Acceleration Chamber", "icon_state" = "fuel_chamber", "status" = "Not In Position", "dir" = 1), list("name" = "Alpha Particle Generation Array", "icon_state" = "end_cap", "status" = "Not In Position", "dir" = 1)),
		list(list("name" = "EM Containment Grid Right", "icon_state" = "emitter_left", "status" = "Not In Position", "dir" = 1), list("name" = "Blank4", "icon_state" = "blank", "status" = "good", "dir" = 1), list("name" = "Blank5", "icon_state" = "blank", "status" = "good", "dir" = 1), list("name" = "Blank6", "icon_state" = "blank", "status" = "good", "dir" = 1)))
	/// The expected orientation of the accelerator this is trying to link. In text form so the UI can use it
	var/dir_text

/obj/machinery/particle_accelerator/control_box/Initialize(mapload)
	. = ..()
	wires = new(src)
	connected_parts = list()
	update_icon(UPDATE_ICON_STATE)
	use_log = list()

/obj/machinery/particle_accelerator/control_box/Destroy()
	SStgui.close_uis(wires)
	if(active)
		toggle_power()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/attack_ghost(user as mob)
	return attack_hand(user)

/obj/machinery/particle_accelerator/control_box/attack_hand(mob/user as mob)
	if(..())
		return TRUE

	add_fingerprint(user)
	if(construction_state >= 3)
		ui_interact(user)
	else if(construction_state == 2) // Wires exposed
		wires.Interact(user)

/obj/machinery/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/I)
	if(construction_state != 2) // Wires exposed
		return
	wires.Interact(user)
	return TRUE

/obj/machinery/particle_accelerator/control_box/update_state()
	if(construction_state < 3)
		use_power = NO_POWER_USE
		assembled = FALSE
		active = FALSE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_icon(UPDATE_ICON_STATE)
		connected_parts = list()
		return

	if(part_scan())
		return

	use_power = IDLE_POWER_USE
	active = FALSE
	connected_parts = list()


/obj/machinery/particle_accelerator/control_box/update_icon_state()
	if(active)
		icon_state = "[reference]p[strength]"
		return

	if(stat & NOPOWER)
		icon_state = "[reference]w"
		return

	if(use_power && assembled)
		icon_state = "[reference]p"
		return

	switch(construction_state)
		if(0)
			icon_state = "[reference]"
		if(1)
			icon_state = "[reference]"
		if(2)
			icon_state = "[reference]w"
		else
			icon_state = "[reference]c"



/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/obj/structure/particle_accelerator/part in connected_parts)
		part.strength = strength
		part.update_icon(UPDATE_ICON_STATE)

/obj/machinery/particle_accelerator/control_box/proc/add_strength(s)
	if(!assembled)
		return
	strength++
	if(strength > strength_upper_limit)
		strength = strength_upper_limit
	else
		message_admins("PA Control Computer increased to [strength] by [key_name_admin(usr)] in [ADMIN_COORDJMP(src)]")
		add_game_logs("increased PA Control Computer to [strength] in [COORD(src)]", usr)
		investigate_log("increased to <span style='color: red;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
		use_log += text("\[[time_stamp()]\] <span style='color: red;'>[usr.name] ([key_name(usr)]) has increased the PA Control Computer to [strength].</span>")

		investigate_log("increased to <span style='color: red;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
	strength_change()

/obj/machinery/particle_accelerator/control_box/proc/remove_strength(s)
	if(!assembled)
		return

	strength--
	if(strength < 0)
		strength = 0
	else
		message_admins("PA Control Computer decreased to [strength] by [key_name_admin(usr)] in [ADMIN_COORDJMP(src)]")
		add_game_logs("decreased PA Control Computer to [strength] in [COORD(src)]", usr)
		investigate_log("decreased to <span style='color: green;'>[strength]</span> by [key_name_log(usr)]", INVESTIGATE_ENGINE)
		use_log += text("\[[time_stamp()]\] <span style='color: orange;'>[usr.name] ([key_name(usr)]) has decreased the PA Control Computer to [strength].</span>")

	strength_change()

/obj/machinery/particle_accelerator/control_box/power_change(forced = FALSE)
	..()
	if(stat & NOPOWER)
		active = 0
		use_power = NO_POWER_USE
	else if(!stat && construction_state <= 3)
		use_power = IDLE_POWER_USE
	update_icon(UPDATE_ICON_STATE)

	if(!((stat & NOPOWER) || (!stat && construction_state <= 3))) //Only update the part icons if something's changed (i.e. any of the above condition sets are met).
		return

	for(var/obj/structure/particle_accelerator/part in connected_parts)
		part.strength = null
		part.powered = FALSE
		part.update_icon(UPDATE_ICON_STATE)


/obj/machinery/particle_accelerator/control_box/process()
	if(!active)
		return
	//a part is missing!
	if(length(connected_parts) < 6)
		investigate_log("lost a connected part; It <span style='color: red;>powered down</span>.", INVESTIGATE_ENGINE)
		toggle_power()
		return
	//emit some particles
	for(var/obj/structure/particle_accelerator/particle_emitter/emitter in connected_parts)
		if(!emitter)
			continue
		emitter.emit_particle(strength)


/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	dir_text = null
	var/turf/turf
	for(var/obj/structure/particle_accelerator/fuel_chamber/fuel in orange(1, src))
		dir = fuel.dir
		turf = fuel.loc

	if(!turf)
		return FALSE

	dir_text = dir2text(dir) // Only set dir_text if we found an EM acceleration chamber
	connected_parts = list()
	var/tally = 0
	var/ldir = turn(dir, -90)
	var/rdir = turn(dir, 90)
	var/odir = turn(dir, 180)

	if(check_part(turf, /obj/structure/particle_accelerator/fuel_chamber, PARTICLE_CENTER, FUEL_CHAMBER))
		tally++
		layout[PARTICLE_CENTER][FUEL_CHAMBER]["status"] = "good"

	turf = get_step(turf, odir)
	if(check_part(turf, /obj/structure/particle_accelerator/end_cap, PARTICLE_CENTER, END_CAP))
		tally++
		layout[PARTICLE_CENTER][END_CAP]["status"] = "good"
	turf = get_step(turf, dir)
	turf = get_step(turf, dir)
	if(check_part(turf, /obj/structure/particle_accelerator/power_box, PARTICLE_CENTER, POWER_BOX))
		tally++
		layout[PARTICLE_CENTER][POWER_BOX]["status"] = "good"
	turf = get_step(turf, dir)
	if(check_part(turf, /obj/structure/particle_accelerator/particle_emitter/center, PARTICLE_CENTER, EMITTER))
		tally++
		layout[PARTICLE_CENTER][EMITTER]["status"] = "good"
	turf = get_step(turf, ldir)
	if(check_part(turf, /obj/structure/particle_accelerator/particle_emitter/left, PARTICLE_LEFT, EMITTER))
		tally++
		layout[PARTICLE_LEFT][EMITTER]["status"] = "good"
	turf = get_step(turf, rdir)
	turf = get_step(turf, rdir)
	if(check_part(turf, /obj/structure/particle_accelerator/particle_emitter/right, PARTICLE_RIGHT, EMITTER))
		tally++
		layout[PARTICLE_RIGHT][EMITTER]["status"] = "good"
	if(tally >= 6)
		assembled = TRUE
		return TRUE
	else
		assembled = FALSE
		return FALSE


/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/checked_turf, type, column, row)
	if(!(checked_turf) || !(type))
		return FALSE

	var/obj/structure/particle_accelerator/accelerator = locate(/obj/structure/particle_accelerator) in checked_turf
	if (!istype(accelerator, type))
		layout[column][row]["status"] = "Not In Position"
		layout[column][row]["dir"] = dir
		return

	if (!accelerator.connect_master(src))
		if (accelerator)
			layout[column][row]["status"] = "Wrong Orientation"
			layout[column][row]["dir"] = accelerator.dir
			layout[column][row]["icon_state"] = accelerator.icon_state
		return

	if (!accelerator.report_ready(src))
		if (accelerator)
			layout[column][row]["status"] = "Incomplete"
			layout[column][row]["dir"] = accelerator.dir
			layout[column][row]["icon_state"] = accelerator.icon_state
		return

	connected_parts |= accelerator
	return TRUE


/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active?"<span style='color: red;'>ON</span>":"<span style='color: green;'>OFF</span>"] by [usr ? key_name_log(usr) : "outside forces"]", INVESTIGATE_ENGINE)
	if(active)
		message_admins("PA Control Computer turned ON by [key_name_admin(usr)]", ATKLOG_FEW)
		add_game_logs("turned ON PA Control Computer in [COORD(src)]", usr)
		use_log += text("\[[time_stamp()]\] <span style='color: red;'>[key_name(usr)] has turned on the PA Control Computer.</pan>")
	if(active)
		use_power = ACTIVE_POWER_USE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = strength
			part.powered = TRUE
			part.update_icon(UPDATE_ICON_STATE)
	else
		use_power = IDLE_POWER_USE
		for(var/obj/structure/particle_accelerator/part in connected_parts)
			part.strength = null
			part.powered = FALSE
			part.update_icon(UPDATE_ICON_STATE)
	return TRUE


/obj/machinery/particle_accelerator/control_box/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/particle_accelerator/control_box/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticleAccelerator", name)
		ui.open()

/obj/machinery/particle_accelerator/control_box/ui_data(mob/user)
	var/list/data = list()
	var/list/ui_col_1 = list()
	var/list/ui_col_2 = list()
	var/list/ui_col_3 = list()
	part_scan()
	if(dir != NORTH || dir == WEST)
		ui_col_1 = layout[PARTICLE_RIGHT]
		ui_col_2 = layout[PARTICLE_CENTER]
		ui_col_3 = layout[PARTICLE_LEFT]
	else
		var/len = length(layout[PARTICLE_CENTER])
		for(var/i in 0 to (len - 1))
			ui_col_1.Add(list(layout[PARTICLE_RIGHT][len - i]))
			ui_col_2.Add(list(layout[PARTICLE_CENTER][len - i]))
			ui_col_3.Add(list(layout[PARTICLE_LEFT][len - i]))

	data["assembled"] = assembled
	data["power"] = active
	data["strength"] = strength
	data["max_strength"] = strength_upper_limit
	data["layout_1"] = ui_col_1
	data["layout_2"] = ui_col_2
	data["layout_3"] = ui_col_3
	data["orientation"] = dir_text ? dir_text : FALSE
	data["icon"] = icon
	return data

/obj/machinery/particle_accelerator/control_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	if(!interface_control)
		to_chat(usr, "<span class='error'>ERROR: Request timed out. Check wire contacts.</span>")
		return

	switch(action)
		if("power")
			if(wires.is_cut(WIRE_PARTICLE_POWER))
				return
			toggle_power()
			. = TRUE
		if("scan")
			part_scan()
			. = TRUE
		if("add_strength")
			if(wires.is_cut(WIRE_PARTICLE_STRENGTH))
				return
			add_strength()
			. = TRUE
		if("remove_strength")
			if(wires.is_cut(WIRE_PARTICLE_STRENGTH))
				return
			remove_strength()
			. = TRUE

	if(.)
		update_icon()

#undef PARTICLE_LEFT
#undef PARTICLE_CENTER
#undef PARTICLE_RIGHT
#undef EMITTER
#undef POWER_BOX
#undef FUEL_CHAMBER
#undef END_CAP
