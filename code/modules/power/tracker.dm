//Solar tracker

//Machine that tracks the sun and reports it's direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "Устройство, управляющее углом наклона солнечных панелей в зависимости от направления солнечного света."
	ru_names = list(
		NOMINATIVE = "солнечный датчик",
		GENITIVE = "солнечного датчика",
		DATIVE = "солнечному датчику",
		ACCUSATIVE = "солнечный датчик",
		INSTRUMENTAL = "солнечным датчиком",
		PREPOSITIONAL = "солнечном датчке"
	)
	gender = MALE
	icon = 'icons/obj/engines_and_power/solar_panels.dmi'
	icon_state = "solar_tracker"
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 250
	integrity_failure = 50

	var/id = 0
	var/sun_angle = 0		// sun angle as set by sun datum
	var/obj/machinery/power/solar_control/control = null

/obj/machinery/power/tracker/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	Make(S)
	connect_to_network()

/obj/machinery/power/tracker/Destroy()
	unset_control() //remove from control computer
	return ..()

//set the control of the tracker to a given computer if closer than SOLAR_MAX_DIST
/obj/machinery/power/tracker/proc/set_control(obj/machinery/power/solar_control/SC)
	if(SC && (get_dist(src, SC) > SOLAR_MAX_DIST))
		return FALSE
	control = SC
	SC.connected_tracker = src
	return TRUE

//set the control of the tracker to null and removes it from the previous control computer if needed
/obj/machinery/power/tracker/proc/unset_control()
	if(control)
		control.connected_tracker = null
	control = null

/obj/machinery/power/tracker/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.tracker = TRUE
		S.set_anchored(TRUE)
	S.forceMove(src)
	update_icon()

//updates the tracker icon and the facing angle for the control computer
/obj/machinery/power/tracker/proc/modify_angle(angle)
	sun_angle = angle

	//set icon dir to show sun illumination
	setDir(turn(NORTH, -angle - 22.5))	// 22.5 deg bias ensures, e.g. 67.5-112.5 is EAST

	if(powernet && (powernet == control.powernet)) //update if we're still in the same powernet
		control.cdir = angle

/obj/machinery/power/tracker/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	playsound(loc, 'sound/machines/click.ogg', 50, TRUE)
	balloon_alert(user, "демонтаж...")
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] снимать стекло с [declent_ru(GENITIVE)]."),
		span_notice("Вы начинаете снимать стекло с [declent_ru(GENITIVE)]...")
	)
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		user.visible_message(
			span_notice("[user] снима[pluralize_ru(user.gender, "ет", "ют")] стекло с [declent_ru(GENITIVE)]."),
			span_notice("Вы снимаете стекло с [declent_ru(GENITIVE)].")
		)
		deconstruct(TRUE)


/obj/machinery/power/tracker/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(obj_flags & NODECONSTRUCT))
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		stat |= BROKEN
		unset_control()

/obj/machinery/power/tracker/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(stat & BROKEN)
		else
			playsound(src, SFX_SHATTER, 70, TRUE)
			new /obj/item/shard(loc)
			new /obj/item/shard(loc)
	qdel(src)

// Tracker Electronic

/obj/item/tracker_electronics

	name = "tracker electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=2;programming=1"
