/obj/machinery/pipedispenser
	name = "Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"
	density = TRUE
	anchored = TRUE
	var/wait = 0

/obj/machinery/pipedispenser/attack_hand(mob/user)
	if(..())
		return 1

	interact(user)

/obj/machinery/pipedispenser/attack_ghost(mob/user)
	interact(user)

/obj/machinery/pipedispenser/interact(mob/user)
	var/dat = {"<meta charset="UTF-8">
<b>Regular pipes:</b><BR>
<a href='byond://?src=[UID()];make=0;dir=1'>Pipe</A><BR>
<a href='byond://?src=[UID()];make=1;dir=5'>Bent Pipe</A><BR>
<a href='byond://?src=[UID()];make=5;dir=1'>Manifold</A><BR>
<a href='byond://?src=[UID()];make=8;dir=1'>Manual Valve</A><BR>
<a href='byond://?src=[UID()];make=35;dir=1'>Digital Valve</A><BR>
<a href='byond://?src=[UID()];make=20;dir=1'>Pipe Cap</A><BR>
<a href='byond://?src=[UID()];make=19;dir=1'>4-Way Manifold</A><BR>
<a href='byond://?src=[UID()];make=18;dir=1'>Manual T-Valve</A><BR>
<a href='byond://?src=[UID()];make=38;dir=1'>Digital T-Valve</A><BR>
<b>Supply pipes:</b><BR>
<a href='byond://?src=[UID()];make=24;dir=1'>Pipe</A><BR>
<a href='byond://?src=[UID()];make=25;dir=5'>Bent Pipe</A><BR>
<a href='byond://?src=[UID()];make=28;dir=1'>Manifold</A><BR>
<a href='byond://?src=[UID()];make=32;dir=1'>Pipe Cap</A><BR>
<a href='byond://?src=[UID()];make=30;dir=1'>4-Way Manifold</A><BR>
<b>Scrubbers pipes:</b><BR>
<a href='byond://?src=[UID()];make=26;dir=1'>Pipe</A><BR>
<a href='byond://?src=[UID()];make=27;dir=5'>Bent Pipe</A><BR>
<a href='byond://?src=[UID()];make=29;dir=1'>Manifold</A><BR>
<a href='byond://?src=[UID()];make=33;dir=1'>Pipe Cap</A><BR>
<a href='byond://?src=[UID()];make=31;dir=1'>4-Way Manifold</A><BR>
<b>Devices:</b><BR>
<a href='byond://?src=[UID()];make=23;dir=1'>Universal Pipe Adapter</A><BR>
<a href='byond://?src=[UID()];make=4;dir=1'>Connector</A><BR>
<a href='byond://?src=[UID()];make=7;dir=1'>Unary Vent</A><BR>
<a href='byond://?src=[UID()];make=9;dir=1'>Gas Pump</A><BR>
<a href='byond://?src=[UID()];make=15;dir=1'>Passive Gate</A><BR>
<a href='byond://?src=[UID()];make=16;dir=1'>Volume Pump</A><BR>
<a href='byond://?src=[UID()];make=10;dir=1'>Scrubber</A><BR>
<a href='byond://?src=[UID()];makemeter=1'>Meter</A><BR>
<a href='byond://?src=[UID()];makegsensor=1'>Gas Sensor</A><BR>
<a href='byond://?src=[UID()];make=13;dir=1'>Gas Filter</A><BR>
<a href='byond://?src=[UID()];make=14;dir=1'>Gas Mixer</A><BR>
<a href='byond://?src=[UID()];make=34;dir=1'>Air Injector</A><BR>
<a href='byond://?src=[UID()];make=36;dir=1'>Dual-Port Vent Pump</A><BR>
<a href='byond://?src=[UID()];make=37;dir=1'>Passive Vent</A><BR>
<b>Heat exchange:</b><BR>
<a href='byond://?src=[UID()];make=2;dir=1'>Pipe</A><BR>
<a href='byond://?src=[UID()];make=3;dir=5'>Bent Pipe</A><BR>
<a href='byond://?src=[UID()];make=6;dir=1'>Junction</A><BR>
<a href='byond://?src=[UID()];make=17;dir=1'>Heat Exchanger</A><BR>
<b>Insulated pipes:</b><BR>
<a href='byond://?src=[UID()];make=11;dir=1'>Pipe</A><BR>
<a href='byond://?src=[UID()];make=12;dir=5'>Bent Pipe</A><BR>

"}
//What number the make points to is in the define # at the top of construction.dm in same folder
//which for some reason couldn't just be left defined, so it could be used here, top kek

	var/datum/browser/popup = new(user, "pipedispenser", name, 400, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "pipedispenser")


/obj/machinery/pipedispenser/Topic(href, href_list)
	if(..() || !anchored)
		return

	usr.set_machine(src)
	add_fingerprint(usr)

	if(world.time < wait + 4)
		return
	wait = world.time
	if(href_list["make"])
		var/p_type = text2num(href_list["make"])
		var/p_dir = text2num(href_list["dir"])
		var/obj/item/pipe/P = new (loc, pipe_type=p_type, dir=p_dir)
		P.update()
		P.add_fingerprint(usr)
	if(href_list["makemeter"])
		new /obj/item/pipe_meter(loc)
	if(href_list["makegsensor"])
		new /obj/item/pipe_gsensor(loc)
	return TRUE


/obj/machinery/pipedispenser/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/prev_state = anchored
	to_chat(user, span_notice("You begin to [anchored ? "un" : ""]fasten [src] [anchored ? "from" : "to"] the floor..."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || anchored != prev_state)
		return .
	set_anchored(!anchored)
	if(anchored)
		stat &= ~MAINT
		user.visible_message(
			span_notice("[user] fastens [src]."),
			span_notice("You have fastened [src]. Now it can dispense pipes."),
			span_italics("You hear ratchet."),
		)
	else
		stat |= MAINT
		user.visible_message(
			span_notice("[user] unfastens [src]."),
			span_notice("You have unfastened [src]. Now it can be pulled somewhere else."),
			span_italics("You hear ratchet."),
		)


/obj/machinery/pipedispenser/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/pipe) || istype(I, /obj/item/pipe_meter) || istype(I, /obj/item/pipe_gsensor))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		to_chat(user, span_notice("You put [I] back to [src]."))
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/pipedispenser/disposal
	name = "Disposal Pipe Dispenser"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "pipe_d"

//Allow you to drag-drop disposal pipes into it
/obj/machinery/pipedispenser/disposal/MouseDrop_T(obj/structure/disposalconstruct/pipe, mob/user, params)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(!istype(pipe) || get_dist(user, src) > 1 || get_dist(src, pipe) > 1 )
		return

	if(pipe.anchored)
		return

	qdel(pipe)
	return TRUE

/obj/machinery/pipedispenser/disposal/attack_hand(mob/user)
	if(..())
		return

	interact(user)

/obj/machinery/pipedispenser/disposal/attack_ghost(mob/user)
	interact(user)

/obj/machinery/pipedispenser/disposal/interact(mob/user)
	var/dat = {"<meta charset="UTF-8"><b>Disposal Pipes</b><br><br>
<a href='byond://?src=[UID()];dmake=100'>Pipe</A><BR>
<a href='byond://?src=[UID()];dmake=101'>Bent Pipe</A><BR>
<a href='byond://?src=[UID()];dmake=102'>Junction</A><BR>
<a href='byond://?src=[UID()];dmake=104'>Y-Junction</A><BR>
<a href='byond://?src=[UID()];dmake=105'>Trunk</A><BR>
<a href='byond://?src=[UID()];dmake=106'>Bin</A><BR>
<a href='byond://?src=[UID()];dmake=107'>Outlet</A><BR>
<a href='byond://?src=[UID()];dmake=108'>Chute</A><BR>
<a href='byond://?src=[UID()];dmake=113'>Rotator</A><BR>
<a href='byond://?src=[UID()];dmake=111'>Multi-Z Up</A><BR>
<a href='byond://?src=[UID()];dmake=112'>Multi-Z Down</A><BR>
"}

	var/datum/browser/popup = new(user, "pipedispenser", name, 400, 400)
	popup.set_content(dat)
	popup.open()


/obj/machinery/pipedispenser/disposal/Topic(href, href_list)
	if(!..())
		return
	if(href_list["dmake"])
		var/obj/structure/disposalconstruct/construct = new(loc, text2num(href_list["dmake"]))
		to_chat(usr, span_notice("[src] dispenses the [construct.pipename]!"))

