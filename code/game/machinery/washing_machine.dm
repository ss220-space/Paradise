#define STATE_FULL (1<<0)
#define STATE_OPENED (1<<1)
#define STATE_BLOODY (1<<2)
#define STATE_WORKING (1<<3)
#define STATE_PANEL (1<<4)
#define STATE_HACKED (1<<5)
#define STATE_DISABLED (1<<6)
#define STATE_SHOCKED (1<<7)
#define MAX_WASH_CAPACITY 5

/// Dye registry, add dye colors and their resulting output here if you want the sprite to change instead of just the color.
GLOBAL_LIST_INIT(dye_registry, list(
	DYE_REGISTRY_UNDER = list(
		DYE_RED = /obj/item/clothing/under/color/red,
		DYE_ORANGE = /obj/item/clothing/under/color/orange,
		DYE_YELLOW = /obj/item/clothing/under/color/yellow,
		DYE_GREEN = /obj/item/clothing/under/color/green,
		DYE_BLUE = /obj/item/clothing/under/color/blue,
		DYE_PURPLE = /obj/item/clothing/under/color/lightpurple,
		DYE_BLACK = /obj/item/clothing/under/color/black,
		DYE_WHITE = /obj/item/clothing/under/color/white,
		DYE_RAINBOW = /obj/item/clothing/under/rainbow,
		DYE_MIME = /obj/item/clothing/under/mime,
		DYE_CLOWN = /obj/item/clothing/under/rank/clown,
		DYE_QM = /obj/item/clothing/under/rank/cargo/official,
		DYE_LAW = /obj/item/clothing/under/lawyer/oldman,
		DYE_CAPTAIN = /obj/item/clothing/under/rank/captain,
		DYE_HOP = /obj/item/clothing/under/rank/head_of_personnel,
		DYE_HOS = /obj/item/clothing/under/rank/head_of_security,
		DYE_CE = /obj/item/clothing/under/rank/chief_engineer,
		DYE_RD = /obj/item/clothing/under/rank/research_director,
		DYE_CMO = /obj/item/clothing/under/rank/chief_medical_officer,
		DYE_REDCOAT = /obj/item/clothing/under/redcoat,
		DYE_PRISONER = /obj/item/clothing/under/color/orange/prison,
		DYE_SYNDICATE = /obj/item/clothing/under/syndicate,
		DYE_CENTCOM = /obj/item/clothing/under/rank/centcom_commander,
	),
	DYE_REGISTRY_GLOVES = list(
		DYE_RED = /obj/item/clothing/gloves/color/red,
		DYE_ORANGE = /obj/item/clothing/gloves/color/orange,
		DYE_YELLOW = /obj/item/clothing/gloves/color/yellow,
		DYE_GREEN = /obj/item/clothing/gloves/color/green,
		DYE_BLUE = /obj/item/clothing/gloves/color/blue,
		DYE_PURPLE = /obj/item/clothing/gloves/color/purple,
		DYE_BLACK = /obj/item/clothing/gloves/color/black,
		DYE_WHITE = /obj/item/clothing/gloves/color/white,
		DYE_RAINBOW = /obj/item/clothing/gloves/color/rainbow,
		DYE_MIME = /obj/item/clothing/gloves/color/white,
		DYE_CLOWN = /obj/item/clothing/gloves/color/rainbow,
		DYE_QM = /obj/item/clothing/gloves/color/brown,
		DYE_CAPTAIN = /obj/item/clothing/gloves/color/captain,
		DYE_HOP = /obj/item/clothing/gloves/color/grey,
		DYE_HOS = /obj/item/clothing/gloves/combat,
		DYE_CE = /obj/item/clothing/gloves/color/black,
		DYE_RD = /obj/item/clothing/gloves/color/grey,
		DYE_CMO = /obj/item/clothing/gloves/color/latex/nitrile,
		DYE_REDCOAT = /obj/item/clothing/gloves/color/white,
		DYE_SYNDICATE = /obj/item/clothing/gloves/combat,
		DYE_CENTCOM = /obj/item/clothing/gloves/combat,
	),
	DYE_REGISTRY_BANDANA = list(
		DYE_RED = /obj/item/clothing/mask/bandana/red,
		DYE_ORANGE = /obj/item/clothing/mask/bandana/orange,
		DYE_YELLOW = /obj/item/clothing/mask/bandana/gold,
		DYE_GREEN = /obj/item/clothing/mask/bandana/green,
		DYE_BLUE = /obj/item/clothing/mask/bandana/blue,
		DYE_PURPLE = /obj/item/clothing/mask/bandana/purple,
		DYE_BLACK = /obj/item/clothing/mask/bandana/black,
	),
	DYE_REGISTRY_SHOES = list(
		DYE_RED = /obj/item/clothing/shoes/red,
		DYE_ORANGE = /obj/item/clothing/shoes/orange,
		DYE_YELLOW = /obj/item/clothing/shoes/yellow,
		DYE_GREEN = /obj/item/clothing/shoes/green,
		DYE_BLUE = /obj/item/clothing/shoes/blue,
		DYE_PURPLE = /obj/item/clothing/shoes/purple,
		DYE_BLACK = /obj/item/clothing/shoes/black,
		DYE_WHITE = /obj/item/clothing/shoes/white,
		DYE_RAINBOW = /obj/item/clothing/shoes/rainbow,
		DYE_MIME = /obj/item/clothing/shoes/black,
		DYE_CLOWN = /obj/item/clothing/shoes/rainbow,
		DYE_QM = /obj/item/clothing/shoes/brown,
		DYE_CAPTAIN = /obj/item/clothing/shoes/brown,
		DYE_HOP = /obj/item/clothing/shoes/brown,
		DYE_CE = /obj/item/clothing/shoes/brown,
		DYE_RD = /obj/item/clothing/shoes/brown,
		DYE_CMO = /obj/item/clothing/shoes/brown,
		DYE_SYNDICATE = /obj/item/clothing/shoes/combat,
		DYE_CENTCOM = /obj/item/clothing/shoes/combat,
	),
	DYE_REGISTRY_BEDSHEET = list(
		DYE_RED = /obj/item/bedsheet/red,
		DYE_ORANGE = /obj/item/bedsheet/orange,
		DYE_YELLOW = /obj/item/bedsheet/yellow,
		DYE_GREEN = /obj/item/bedsheet/green,
		DYE_BLUE = /obj/item/bedsheet/blue,
		DYE_PURPLE = /obj/item/bedsheet/purple,
		DYE_BLACK = /obj/item/bedsheet/black,
		DYE_WHITE = /obj/item/bedsheet,
		DYE_RAINBOW = /obj/item/bedsheet/rainbow,
		DYE_MIME = /obj/item/bedsheet/mime,
		DYE_CLOWN = /obj/item/bedsheet/clown,
		DYE_QM = /obj/item/bedsheet/qm,
		DYE_LAW = /obj/item/bedsheet/black,
		DYE_CAPTAIN = /obj/item/bedsheet/captain,
		DYE_HOP = /obj/item/bedsheet/hop,
		DYE_HOS = /obj/item/bedsheet/hos,
		DYE_CE = /obj/item/bedsheet/ce,
		DYE_RD = /obj/item/bedsheet/rd,
		DYE_CMO = /obj/item/bedsheet/cmo,
		DYE_SYNDICATE = /obj/item/bedsheet/syndie,
		DYE_CENTCOM = /obj/item/bedsheet/centcom,
	),
	DYE_REGISTRY_SOFTCAP = list(
		DYE_RED = /obj/item/clothing/head/soft/red,
		DYE_ORANGE = /obj/item/clothing/head/soft/orange,
		DYE_YELLOW = /obj/item/clothing/head/soft/yellow,
		DYE_GREEN = /obj/item/clothing/head/soft/green,
		DYE_BLUE = /obj/item/clothing/head/soft/blue,
		DYE_PURPLE = /obj/item/clothing/head/soft/purple,
		DYE_BLACK = /obj/item/clothing/head/soft/black,
		DYE_RAINBOW = /obj/item/clothing/head/soft/rainbow,
		DYE_MIME = /obj/item/clothing/head/soft/mime,
		DYE_CLOWN = /obj/item/clothing/head/soft/rainbow,
	),
	DYE_REGISTRY_PONCHO = list(
		DYE_RED = /obj/item/clothing/neck/poncho/red,
		DYE_ORANGE = /obj/item/clothing/neck/poncho/orange,
		DYE_YELLOW = /obj/item/clothing/neck/poncho/yellow,
		DYE_GREEN = /obj/item/clothing/neck/poncho/green,
		DYE_BLUE = /obj/item/clothing/neck/poncho/blue,
		DYE_PURPLE = /obj/item/clothing/neck/poncho/purple,
		DYE_BLACK = /obj/item/clothing/neck/poncho/black,
		DYE_WHITE = /obj/item/clothing/neck/poncho/white,
		DYE_RAINBOW = /obj/item/clothing/neck/poncho/rainbow,
		DYE_MIME = /obj/item/clothing/neck/poncho/mime,
		DYE_CLOWN = /obj/item/clothing/neck/poncho/rainbow,
	),
))

/obj/machinery/washing_machine
	name = "washing machine"
	desc = "Gets rid of those pesky bloodstains, or your money back!"
	icon = 'icons/obj/machines/washing_machine.dmi'
	icon_state = "machine"
	density = TRUE
	anchored = TRUE
	active_power_usage = 200
	/// Bitflags indicating current machine status
	var/state = NONE
	/// Item used as a colour source
	var/obj/item/color_source
	/// Our sweet wires
	var/datum/wires/washing_machine/wires


/obj/machinery/washing_machine/Initialize(mapload)
	. = ..()
	wires = new(src)
	update_icon(UPDATE_OVERLAYS)


/obj/machinery/washing_machine/Destroy()
	dump_contents(forced = TRUE)
	SStgui.close_uis(wires)
	QDEL_NULL(wires)
	return ..()


/obj/machinery/washing_machine/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	qdel(src)


/// Dumps every movable atom in the machine's contents list
/obj/machinery/washing_machine/proc/dump_contents(forced = FALSE)
	if(!forced && (state & STATE_WORKING))
		return
	var/atom/drop_loc = drop_location()
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_loc)
	color_source = null
	var/toggle_states = NONE
	if(!(state & STATE_OPENED))
		toggle_states |= STATE_OPENED
	if(state & STATE_FULL)
		toggle_states |= STATE_FULL
	if(toggle_states)
		toggle_state(toggle_states)


/obj/machinery/washing_machine/examine(mob/user)
	. = ..()
	if(state & STATE_PANEL)
		. += span_notice("Its wires are exposed.")
	if(state & STATE_BLOODY)
		. += span_notice("Cleaning is highly advised.")
	if(state & (STATE_DISABLED|STATE_HACKED))
		. += span_warning("The red light on the panel is blinking...")
	if(!(state & (STATE_OPENED|STATE_WORKING)) && (state & STATE_FULL))
		. += span_info("<b>Alt-click</b> to start the washing cycle.")


/obj/machinery/washing_machine/process(seconds_per_tick)
	if(!(state & STATE_WORKING))
		animate(src, transform = matrix(), time = 0.2 SECONDS)
		return PROCESS_KILL
	if(anchored)
		if(SPT_PROB(30, seconds_per_tick))
			var/matrix/animatrix = new(transform)
			animatrix.Translate(rand(-1, 1), rand(0, 1))
			animate(src, transform = animatrix, time = 0.1 SECONDS)
			animate(transform = matrix(), time = 0.1 SECONDS)
	else
		if(SPT_PROB(15, seconds_per_tick))
			step(src, pick(GLOB.cardinal))
		var/matrix/animatrix = new(transform)
		animatrix.Translate(rand(-3, 3), rand(-1, 3))
		animate(src, transform = animatrix, time = 0.1 SECONDS)
		animate(transform = matrix(), time = 0.1 SECONDS)


/obj/machinery/washing_machine/relaymove(mob/living/user, direction)
	container_resist(user)


/obj/machinery/washing_machine/container_resist(mob/living/user)
	if(!(state & STATE_WORKING))
		add_fingerprint(user)
		dump_contents()


/**
 * Toggles machine bitflag for `state` variable and calls icon update.
 *
 * Arguments:
 * * new_state - Bitflag, adds/removes new state
 */
/obj/machinery/washing_machine/proc/toggle_state(new_state)
	. = state
	state ^= new_state
	if(. != state)
		update_icon(UPDATE_OVERLAYS)


#define WASHER_OVERLAY_CLOSED 1
#define WASHER_OVERLAY_CLOSED_FULL 2
#define WASHER_OVERLAY_CLOSED_BLOODY 3
#define WASHER_OVERLAY_OPENED 4
#define WASHER_OVERLAY_OPENED_FULL 5
#define WASHER_OVERLAY_OPENED_BLOODY 6
#define WASHER_OVERLAY_WORKING 7
#define WASHER_OVERLAY_WORKING_BLOODY 8
#define WASHER_OVERLAY_PANEL 9

/obj/machinery/washing_machine/update_overlays()
	. = ..()

	var/static/list/washer_overlays
	if(isnull(washer_overlays))
		washer_overlays = list(
			iconstate2appearance(icon, "closed"),
			iconstate2appearance(icon, "closed_full"),
			iconstate2appearance(icon, "closed_bloody"),
			iconstate2appearance(icon, "opened"),
			iconstate2appearance(icon, "opened_full"),
			iconstate2appearance(icon, "opened_bloody"),
			iconstate2appearance(icon, "working"),
			iconstate2appearance(icon, "working_bloody"),
			iconstate2appearance(icon, "panel"),
		)

	if(state & STATE_PANEL)
		. += washer_overlays[WASHER_OVERLAY_PANEL]

	if(state & STATE_WORKING)
		. += washer_overlays[WASHER_OVERLAY_CLOSED]
		if(state & STATE_BLOODY)
			. += washer_overlays[WASHER_OVERLAY_WORKING_BLOODY]
		else
			. += washer_overlays[WASHER_OVERLAY_WORKING]
		return .

	if(state & STATE_OPENED)
		. += washer_overlays[WASHER_OVERLAY_OPENED]
		if(state & STATE_BLOODY)
			. += washer_overlays[WASHER_OVERLAY_OPENED_BLOODY]
		else if(state & STATE_FULL)
			. += washer_overlays[WASHER_OVERLAY_OPENED_FULL]
		return .

	. += washer_overlays[WASHER_OVERLAY_CLOSED]
	if(state & STATE_BLOODY)
		. += washer_overlays[WASHER_OVERLAY_CLOSED_BLOODY]
	else if(state & STATE_FULL)
		. += washer_overlays[WASHER_OVERLAY_CLOSED_FULL]

#undef WASHER_OVERLAY_CLOSED
#undef WASHER_OVERLAY_CLOSED_FULL
#undef WASHER_OVERLAY_CLOSED_BLOODY
#undef WASHER_OVERLAY_OPENED
#undef WASHER_OVERLAY_OPENED_FULL
#undef WASHER_OVERLAY_OPENED_BLOODY
#undef WASHER_OVERLAY_WORKING
#undef WASHER_OVERLAY_WORKING_BLOODY
#undef WASHER_OVERLAY_PANEL


/obj/machinery/washing_machine/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(state & STATE_WORKING)
		to_chat(user, span_warning("[src] is working!"))
		return .
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	toggle_state(STATE_PANEL)
	if(state & STATE_PANEL)
		panel_open = TRUE
		to_chat(user, span_notice("You open the maintenance panel of [src]."))
	else
		panel_open = FALSE
		to_chat(user, span_notice("You close the maintenance panel of [src]."))


/obj/machinery/washing_machine/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(state & STATE_WORKING)
		to_chat(user, span_warning("[src] is working!"))
		return .
	if(state & STATE_PANEL)
		to_chat(user, span_warning("Close the maintenance panel first!"))
		return .
	default_unfasten_wrench(user, I, 5 SECONDS)


/obj/machinery/washing_machine/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(state & STATE_WORKING)
		to_chat(user, span_warning("[src] is working!"))
		return .
	if(!(state & STATE_PANEL))
		to_chat(user, span_warning("Open the maintenance panel first!"))
		return .
	if(!I.use_tool(src, user, 0, volume = 0))
		return .
	wires.Interact(user)


/obj/machinery/washing_machine/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(state & STATE_WORKING)
		to_chat(user, span_warning("[src] is working!"))
		return .
	if(!(state & STATE_PANEL))
		to_chat(user, span_warning("Open the maintenance panel first!"))
		return .
	if(!I.use_tool(src, user, 0, volume = 0))
		return .
	wires.Interact(user)


/obj/machinery/washing_machine/emag_act(mob/user)
	if(emagged)
		return
	emagged = TRUE
	if(!wires.is_cut(WIRE_WASHER_HACK))
		wires.cut(WIRE_WASHER_HACK)
	do_sparks(3, 0, src)
	add_attack_logs(user, src, "emagged")
	. = ..()


/obj/machinery/washing_machine/unemag()
	if(!emagged)
		return
	emagged = FALSE
	if(wires.is_cut(WIRE_WASHER_HACK))
		wires.cut(WIRE_WASHER_HACK)


/obj/machinery/washing_machine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return .

	if(!generic_check(user, states_to_ignore = STATE_BLOODY|STATE_DISABLED|STATE_OPENED|STATE_FULL))
		return .

	if((state & STATE_SHOCKED) && shock(user, 60))
		return .

	if(state & STATE_OPENED)
		if(state & STATE_BLOODY)
			to_chat(user, span_warning("[src] needs to be cleaned first!"))
			return .
		toggle_state(STATE_OPENED)
		return .

	dump_contents()


/obj/machinery/washing_machine/clean_blood()
	. = ..()
	if(!(state & STATE_BLOODY))
		return .
	if(state & STATE_OPENED)
		if(usr)
			to_chat(usr, span_notice("You have completely cleaned [src]."))
		toggle_state(STATE_BLOODY)
	else
		if(usr)
			to_chat(usr, span_warning("Open [src]'s hatch first!"))


/obj/machinery/washing_machine/attackby(obj/item/I, mob/user, params)
	var/is_mob_holder = istype(I, /obj/item/holder)
	if(!(state & STATE_OPENED) || user.a_intent == INTENT_HARM || istype(I, /obj/item/card/emag) || istype(I, /obj/item/soap) || (!(state & STATE_HACKED) && is_mob_holder))
		return ..()

	add_fingerprint(user)
	if(state & STATE_BLOODY)
		to_chat(user, span_warning("[src] needs to be cleaned first!"))
		return ATTACK_CHAIN_PROCEED

	var/contents_len = length(contents)
	if((contents_len + (is_mob_holder ? length(I.contents) : 0)) >= MAX_WASH_CAPACITY)
		to_chat(user, span_warning("[src] is full!"))
		return ATTACK_CHAIN_PROCEED

	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()

	if(is_mob_holder)
		for(var/mob/living/simple_animal/pet in I.contents)
			pet.forceMove(src)
		if(!QDELETED(I))
			qdel(I)
	else
		if(I.dye_color)
			color_source = I

	if(!contents_len)
		toggle_state(STATE_FULL)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/machinery/washing_machine/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !(state & STATE_OPENED) || !(state & STATE_HACKED) || !isanimal(grabbed_thing))
		return .
	var/contents_len = length(contents)
	add_fingerprint(grabber)
	grabbed_thing.forceMove(src)
	if(!contents_len)
		toggle_state(STATE_FULL)


/// All generic checks with feedback for the user
/obj/machinery/washing_machine/proc/generic_check(mob/living/user, states_to_ignore)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You cannot do that right now!"))
		return FALSE
	if(!(states_to_ignore & STATE_WORKING) && (state & STATE_WORKING))
		to_chat(user, span_warning("[src] is working!"))
		return FALSE
	if(!(states_to_ignore & STATE_OPENED) && (state & STATE_OPENED))
		to_chat(user, span_warning("Close the hatch first!"))
		return FALSE
	if(!(states_to_ignore & STATE_FULL) && !(state & STATE_FULL))
		to_chat(user, span_warning("[src] has no items to wash!"))
		return FALSE
	if(!(states_to_ignore & STATE_PANEL) && (state & STATE_PANEL))
		to_chat(user, span_warning("Close the maintenance panel first!"))
		return FALSE
	if(!(states_to_ignore & STATE_BLOODY) && (state & STATE_BLOODY))
		to_chat(user, span_warning("[src] needs to be cleaned first!"))
		return FALSE
	if(!(states_to_ignore & STATE_DISABLED) && (state & STATE_DISABLED))
		to_chat(user, span_warning("[src] is malfunctioning!"))
		return FALSE
	return TRUE


/obj/machinery/washing_machine/attack_ai(mob/user)
	turn_on(user)


/obj/machinery/washing_machine/AltClick(mob/user)
	if(Adjacent(user) && generic_check(user))
		turn_on(user)


/obj/machinery/washing_machine/verb/start()
	set name = "Start Washing"
	set category = "Object"
	set src in oview(1)

	if(generic_check(usr))
		turn_on(usr)


/// Engages washing cycle
/obj/machinery/washing_machine/proc/turn_on(mob/user)
	if(state & (STATE_WORKING|STATE_OPENED|STATE_BLOODY|STATE_PANEL|STATE_DISABLED) || !(state & STATE_FULL))
		return FALSE
	if((state & STATE_SHOCKED) && user && !issilicon(user) && shock(user, 100))
		return FALSE
	var/toggle_states = STATE_WORKING
	if(locate(/mob/living/simple_animal, contents))
		toggle_states |= STATE_BLOODY
	toggle_state(toggle_states)
	playsound(loc, 'sound/machines/terminal_button08.ogg', 50, TRUE)
	use_power = ACTIVE_POWER_USE
	addtimer(CALLBACK(src, PROC_REF(wash_cycle_end)), 20 SECONDS)
	START_PROCESSING(SSfastprocess, src)
	return TRUE


/// Ending of the machine wash cycle
/obj/machinery/washing_machine/proc/wash_cycle_end()
	for(var/atom/movable/thing as anything in contents)
		thing.clean_blood()
		thing.machine_wash(src)

	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	QDEL_NULL(color_source)
	use_power = IDLE_POWER_USE
	toggle_state(STATE_WORKING)


/obj/machinery/washing_machine/proc/pulsed_callback(wire_check, state_check)
	if(!wires.is_cut(wire_check) && (state & state_check))
		toggle_state(state_check)


/// What happens to this object when washed inside a washing machine
/atom/movable/proc/machine_wash(obj/machinery/washing_machine/washer)
	return


/obj/item/stack/sheet/hairlesshide/machine_wash(obj/machinery/washing_machine/washer)
	new /obj/item/stack/sheet/wetleather(washer, amount)
	qdel(src)


/mob/living/simple_animal/machine_wash(obj/machinery/washing_machine/washer)
	investigate_log("has been gibbed by a washing machine.", INVESTIGATE_DEATHS)
	gib()


/obj/item/machine_wash(obj/machinery/washing_machine/washer)
	if(washer.color_source)
		dye_item(washer.color_source.dye_color)


/obj/item/clothing/shoes/orange/machine_wash(obj/machinery/washing_machine/washer)
	if(shackles)
		shackles.forceMove(washer)
		set_shackles(null)
	. = ..()


/obj/item/proc/dye_item(dye_color, dye_key_override)
	var/dye_key_selector = dye_key_override ? dye_key_override : dying_key
	if(undyeable)
		return FALSE
	if(!dye_key_selector)
		return FALSE
	if(!GLOB.dye_registry[dye_key_selector])
		stack_trace("Item just tried to be dyed with an invalid registry key: [dye_key_selector]")
		return FALSE
	var/obj/item/target_type = GLOB.dye_registry[dye_key_selector][dye_color]
	if(!target_type)
		return FALSE

	name = initial(target_type.name)
	desc = "[initial(target_type.desc)] The colors are a bit dodgy."

	icon = initial(target_type.icon)
	icon_state = initial(target_type.icon_state)
	item_state = initial(target_type.item_state)
	item_color = initial(target_type.item_color)

	lefthand_file = initial(target_type.lefthand_file)
	righthand_file = initial(target_type.righthand_file)

	if(initial(target_type.sprite_sheets) || initial(target_type.onmob_sheets))
		// Sprites-related variables are lists, which can not be retrieved using initial(). As such, we need to instantiate the target_type.
		var/obj/item/dummy = new target_type(null)
		sprite_sheets = dummy.sprite_sheets
		onmob_sheets = dummy.onmob_sheets
		qdel(dummy)

	update_appearance()
	return target_type //successfully "appearance copy" dyed something; returns the target type as a hacky way of extending


#undef STATE_FULL
#undef STATE_OPENED
#undef STATE_BLOODY
#undef STATE_WORKING
#undef STATE_PANEL
#undef STATE_HACKED
#undef STATE_DISABLED
#undef STATE_SHOCKED
#undef MAX_WASH_CAPACITY

