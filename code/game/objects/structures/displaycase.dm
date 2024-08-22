/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_open"
	desc = "A display case for prized possessions."
	density = TRUE
	anchored = TRUE
	resistance_flags = ACID_PROOF
	armor = list("melee" = 30, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 100)
	max_integrity = 200
	integrity_failure = 50
	var/obj/item/showpiece = null
	var/alert = TRUE
	var/open = FALSE
	var/openable = TRUE
	var/obj/item/access_control/electronics
	var/start_showpiece_type = null //add type for items on display
	var/list/start_showpieces = list() //Takes sublists in the form of list("type" = /obj/item/bikehorn, "trophy_message" = "henk")
	var/trophy_message = ""

/obj/structure/displaycase/Initialize(mapload)
	. = ..()
	if(length(start_showpieces) && !start_showpiece_type)
		var/list/showpiece_entry = pick(start_showpieces)
		if (showpiece_entry && showpiece_entry["type"])
			start_showpiece_type = showpiece_entry["type"]
			if (showpiece_entry["trophy_message"])
				trophy_message = showpiece_entry["trophy_message"]
	if(start_showpiece_type)
		showpiece = new start_showpiece_type (src)
	update_icon(UPDATE_OVERLAYS)

/obj/structure/displaycase/Destroy()
	QDEL_NULL(electronics)
	QDEL_NULL(showpiece)
	return ..()

/obj/structure/displaycase/examine(mob/user)
	. = ..()
	if(alert)
		. += "<span class='notice'>Hooked up with an anti-theft system.</span>"
	if(showpiece)
		. += "<span class='notice'>There's [showpiece] inside.</span>"
	if(trophy_message)
		. += "<span class='notice'>The plaque reads:\n [trophy_message]</span>"

/obj/structure/displaycase/proc/dump()
	if(showpiece)
		showpiece.forceMove(loc)
		showpiece = null

/obj/structure/displaycase/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/displaycase/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		dump()
		if(!disassembled)
			new /obj/item/shard(loc)
			trigger_alarm()
	qdel(src)

/obj/structure/displaycase/obj_break(damage_flag)
	if(!broken && !(obj_flags & NODECONSTRUCT))
		set_density(FALSE)
		broken = 1
		new /obj/item/shard( src.loc )
		playsound(src, "shatter", 70, TRUE)
		update_icon(UPDATE_OVERLAYS)
		trigger_alarm()

/obj/structure/displaycase/proc/trigger_alarm()
	set waitfor = FALSE
	if(alert && is_station_contact(z))
		var/area/alarmed = get_area(src)
		alarmed.burglaralert(src)
		visible_message("<span class='danger'>The burglar alarm goes off!</span>")
		// Play the burglar alarm three times
		for(var/i = 0, i < 4, i++)
			playsound(src, 'sound/machines/burglar_alarm.ogg', 50, 0)
			sleep(74) // 7.4 seconds long


/obj/structure/displaycase/update_overlays()
	. = ..()
	if(broken)
		. += "glassbox_broken"
	if(showpiece)
		var/mutable_appearance/showpiece_overlay = mutable_appearance(showpiece.icon, showpiece.icon_state)
		showpiece_overlay.copy_overlays(showpiece)
		showpiece_overlay.transform *= 0.6
		. += showpiece_overlay
	if(!open && !broken)
		. += "glassbox_closed"


/obj/structure/displaycase/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(I.GetID() || is_pda(I))
		if(!openable)
			return ..()
		add_fingerprint(user)
		if(broken)
			to_chat(user, span_warning("The [name] is broken."))
			return ATTACK_CHAIN_PROCEED
		if(!allowed(user))
			to_chat(user, span_warning("Access denied!"))
			return ATTACK_CHAIN_PROCEED
		toggle_lock(user)
		to_chat(user, span_notice("You [open ? "open" : "close"] [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/sheet/glass) && broken)
		add_fingerprint(user)
		var/obj/item/stack/sheet/glass/glass = I
		if(glass.get_amount() < 2)
			to_chat(user, span_warning("You need two glass sheets to fix the case!"))
			return ATTACK_CHAIN_PROCEED
		glass.play_tool_sound(src)
		to_chat(user, span_notice("You start replacing [src]'s glass panel..."))
		if(!do_after(user, 2 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || !broken || QDELETED(glass))
			return ATTACK_CHAIN_PROCEED
		if(!glass.use(2))
			to_chat(user, span_warning("At some point during construction you lost some glass. Make sure you have two sheets before trying again."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You replace [src]'s glass panel."))
		broken = FALSE
		obj_integrity = max_integrity
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(!(I.item_flags & ABSTRACT))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("You should open [src] first!"))
			return ATTACK_CHAIN_PROCEED
		if(showpiece)
			to_chat(user, span_warning("The [name] is already displays [showpiece]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You put [I] on the display."))
		showpiece = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/displaycase/crowbar_act(mob/user, obj/item/I) //Only applies to the lab cage and player made display cases
	if(alert || !openable)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(broken)
		if(showpiece)
			to_chat(user, "<span class='notice'>Remove the displayed object first.</span>")
		if(I.use_tool(src, user, 0, volume = I.tool_volume))
			to_chat(user, "<span class='notice'>You remove the destroyed case</span>")
			qdel(src)
	else
		to_chat(user, "<span class='notice'>You start to [open ? "close":"open"] [src].</span>")
		if(!I.use_tool(src, user, 20, volume = I.tool_volume))
			return
		to_chat(user,  "<span class='notice'>You [open ? "close":"open"] [src].</span>")
		toggle_lock(user)

/obj/structure/displaycase/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(default_welder_repair(user, I))
		broken = FALSE

/obj/structure/displaycase/proc/toggle_lock(mob/user)
	open = !open
	update_icon(UPDATE_OVERLAYS)

/obj/structure/displaycase/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(showpiece && (broken || open))
		to_chat(user, "<span class='notice'>You deactivate the hover field built into the case.</span>")
		dump()
		add_fingerprint(user)
		update_icon(UPDATE_OVERLAYS)
		return
	else
	    //prevents remote "kicks" with TK
		if(!Adjacent(user))
			return
		add_fingerprint(user)
		user.visible_message("<span class='danger'>[user] kicks the display case.</span>")
		user.do_attack_animation(src, ATTACK_EFFECT_KICK)
		take_damage(2)

/obj/structure/displaycase_chassis
	anchored = TRUE
	density = FALSE
	name = "display case chassis"
	desc = "The wooden base of a display case."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox_chassis"
	var/obj/item/access_control/electronics


/obj/structure/displaycase_chassis/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/access_control))
		add_fingerprint(user)
		var/obj/item/access_control/control = I
		if(electronics)
			to_chat(user, span_warning("There is already [electronics] installed."))
			return ATTACK_CHAIN_PROCEED
		if(control.emagged)
			to_chat(user, span_warning("The [control.name] is broken."))
			return ATTACK_CHAIN_PROCEED
		control.play_tool_sound(src)
		to_chat(user, span_notice("You start installing [control] into [src]..."))
		if(!do_after(user, 3 SECONDS * control.toolspeed, src, category = DA_CAT_TOOL) || electronics || control.emagged)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(control, src))
			return ..()
		to_chat(user, span_notice("You have installed [control] into [src]."))
		electronics = control
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/glass))
		add_fingerprint(user)
		var/obj/item/stack/sheet/glass/glass = I
		if(glass.get_amount() < 10)
			to_chat(user, span_warning("You need ten glass sheets to do this!"))
			return ATTACK_CHAIN_PROCEED
		glass.play_tool_sound(src)
		to_chat(user, span_notice("You start adding [glass] to [src]..."))
		if(!do_after(user, 2 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(glass))
			return ATTACK_CHAIN_PROCEED
		if(!glass.use(10))
			to_chat(user, span_warning("At some point during construction you lost some glass. Make sure you have ten sheets before trying again."))
			return ATTACK_CHAIN_PROCEED
		var/obj/structure/displaycase/display = new(loc)
		transfer_fingerprints_to(display)
		display.add_fingerprint(user)
		if(electronics)
			electronics.forceMove(display)
			display.electronics = electronics
			display.req_access = electronics.selected_accesses
			display.check_one_access = electronics.one_access
			electronics = null
		to_chat(user, span_notice("You have finished the construction of [display]."))
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/displaycase_chassis/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(!I.use_tool(src, user, 30, volume = I.tool_volume))
		return
	TOOL_DISMANTLE_SUCCESS_MESSAGE
	new /obj/item/stack/sheet/wood(get_turf(src), 5)
	if(electronics)
		electronics.forceMove(loc)
		electronics = null
	qdel(src)

//The lab cage and captains display case do not spawn with electronics, which is why req_access is needed.
/obj/structure/displaycase/captain
	alert = TRUE
	start_showpiece_type = /obj/item/gun/energy/laser/captain
	req_access = list(ACCESS_CAPTAIN)

/obj/structure/displaycase/labcage
	name = "lab cage"
	desc = "A glass lab container for storing interesting creatures."
	start_showpiece_type = /obj/item/clothing/mask/facehugger/lamarr
	req_access = list(ACCESS_RD)

/obj/structure/displaycase/stechkin
	name = "officer's display case"
	desc = "A display case containing a humble stechkin pistol. Never forget your roots."
	start_showpiece_type = /obj/item/gun/projectile/automatic/pistol
	req_access = list(ACCESS_SYNDICATE_COMMAND)

/obj/structure/displaycase/dartgun
	name = "Display case"
	desc = "A display case containing a dartgun. One of the favourite weapons of infamous Vox Raiders!"
	start_showpiece_type = /obj/item/gun/dartgun
	req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
