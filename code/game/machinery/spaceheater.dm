/obj/machinery/space_heater
	density = TRUE
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos.dmi'
	icon_state = "sheater_off"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	max_integrity = 250
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 80, ACID = 10)
	var/obj/item/stock_parts/cell/cell
	var/on = 0
	var/open = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000

/obj/machinery/space_heater/get_cell()
	return cell

/obj/machinery/space_heater/Initialize(mapload)
	. = ..()
	if(ispath(cell))
		cell = new cell(src)
	update_icon()

	var/static/list/tool_behaviors = list(
		TOOL_SCREWDRIVER = list(
			SCREENTIP_CONTEXT_LMB = "Открыть/закрыть люк",
		),

		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Закрепить",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/machinery/space_heater/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/space_heater/update_icon_state()
	icon_state = "sheater_[on ? "on" : "off"]"

/obj/machinery/space_heater/update_overlays()
	. = ..()
	if(open)
		. += "sheater_open"

/obj/machinery/space_heater/examine(mob/user)
	. = ..()
	. += span_notice("The heater is [on ? "on" : "off"] and the hatch is [open ? "open" : "closed"].")
	if(open)
		. += span_notice("The power cell is [cell ? "installed" : "missing"].")
	else
		. += span_notice("The charge meter reads [cell ? round(cell.percent(),1) : 0]%.")

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(iscell(I))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("The hatch must be open to insert a power cell."))
			return ATTACK_CHAIN_PROCEED
		if(cell)
			to_chat(user, "There is already a power cell inside.")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		user.visible_message(
			span_notice("[user] inserts a power cell into [src]."),
			span_notice("You insert the power cell into [src]."),
		)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/space_heater/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	open = !open
	if(open)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
	update_icon()
	if(!open && user.machine == src)
		close_window(user, "spaceheater")
		user.unset_machine()

/obj/machinery/space_heater/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user as mob)
	if(open)
		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<a href='byond://?src=[UID()];op=cellremove'>Installed</a><br>"
		else
			dat += "<a href='byond://?src=[UID()];op=cellinstall'>Removed</a><br>"

		dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<br><br>"

		dat += "Set Temperature: "

		dat += "<a href='byond://?src=[UID()];op=temp;val=-5'>-</a>"

		dat += " [set_temperature]&deg;C "
		dat += "<a href='byond://?src=[UID()];op=temp;val=5'>+</a><br>"

		user.set_machine(src)
		var/datum/browser/popup = new(user, "spaceheater", "Space Heater Control Panel")
		popup.set_content("<tt>[dat]</tt>")
		popup.open(TRUE)
		onclose(user, "spaceheater")

	else
		on = !on
		user.visible_message(span_notice("[user] switches [on ? "on" : "off"] [src]."),span_notice("You switch [on ? "on" : "off"] [src]."))
		update_icon()
	return

/obj/machinery/space_heater/Topic(href, href_list)
	if(..())
		return 1
	if((in_range(src, usr) && isturf(src.loc)) || (issilicon(usr)))
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 20-90 degC
				set_temperature = dd_range(0, 90, set_temperature + value)

			if("cellremove")
				if(open && cell && !usr.get_active_hand())
					cell.update_icon()
					cell.forceMove_turf()
					usr.put_in_hands(cell, ignore_anim = FALSE)
					cell.add_fingerprint(usr)
					cell = null
					usr.visible_message(span_notice("[usr] removes the power cell from [src]."), span_notice("You remove the power cell from [src]."))

			if("cellinstall")
				if(open && !cell)
					var/obj/item/stock_parts/cell/C = usr.get_active_hand()
					if(istype(C))
						usr.drop_transfer_item_to_loc(C, src)
						cell = C
						C.add_fingerprint(usr)

						usr.visible_message(span_notice("[usr] inserts a power cell into [src]."), span_notice("You insert the power cell into [src]."))

		updateDialog()
	else
		close_window(usr, "spaceheater")
		usr.unset_machine()
	return

/obj/machinery/space_heater/process()
	var/datum/milla_safe/space_heater_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/space_heater_process

/datum/milla_safe/space_heater_process/on_run(obj/machinery/space_heater/heater)
	if(!heater.on)
		return

	if(!heater.cell || heater.cell.charge <= 0)
		heater.on = FALSE
		heater.update_icon()
		return

	var/turf/simulated/L = get_turf(heater)

	if(!istype(L))
		return

	var/datum/gas_mixture/env = get_turf_air(L)

	if(env.temperature() == heater.set_temperature + T0C)
		return

	var/transfer_moles = 0.25 * env.total_moles()

	var/datum/gas_mixture/removed = env.remove(transfer_moles)

	if(!removed)
		return

	var/heat_capacity = removed.heat_capacity()

	if(heat_capacity)
		if(removed.temperature() < heater.set_temperature + T0C)
			removed.set_temperature(min(removed.temperature() + heater.heating_power / heat_capacity, 1000))
		else
			removed.set_temperature(max(removed.temperature() - heater.heating_power / heat_capacity, TCMB))
		heater.cell.use(heater.heating_power / 20000)
	env.merge(removed)
