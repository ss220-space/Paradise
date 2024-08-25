/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = CONDUCT
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 10

	var/secured = FALSE
	var/obj/item/assembly/a_left = null
	var/obj/item/assembly/a_right = null


/obj/item/assembly_holder/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/assembly_holder/Destroy()
	if(a_left)
		a_left.holder = null
	if(a_right)
		a_right.holder = null
	return ..()


/obj/item/assembly_holder/proc/attach(obj/item/D, obj/item/D2, mob/user)
	if(!D || !D2)
		return FALSE
	if(!isassembly(D) || !isassembly(D2))
		return FALSE
	var/obj/item/assembly/A1 = D
	var/obj/item/assembly/A2 = D2
	if(A1.secured || A2.secured)
		return FALSE
	if(!A1.remove_item_from_storage(src))
		if(user && A1.loc == user && !user.can_unEquip(A1))
			return FALSE
	if(!A2.remove_item_from_storage(src))
		if(user && A2.loc == user && !user.can_unEquip(A2))
			return FALSE
	if(A1.loc == user)
		user.temporarily_remove_item_from_inventory(A1)
	if(A2.loc == user)
		user.temporarily_remove_item_from_inventory(A2)
	A1.forceMove(src)
	A2.forceMove(src)
	A1.holder = src
	A2.holder = src
	a_left = A1
	a_right = A2
	if(has_prox_sensors())
		AddComponent(/datum/component/proximity_monitor)
	name = "[A1.name]-[A2.name] assembly"
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/item/assembly_holder/proc/has_prox_sensors()
	if(isprox(a_left) || isprox(a_right))
		return TRUE
	return FALSE


/obj/item/assembly_holder/proc/process_activation(obj/D, normal = TRUE, special = TRUE, mob/user)
	if(!D)
		return FALSE
	if(normal && a_right && a_left)
		if(a_right != D)
			a_right.pulsed()
		if(a_left != D)
			a_left.pulsed()
	if(master)
		var/datum/signal/signal = new
		signal.source = src
		signal.user = user
		master.receive_signal(signal)
	return TRUE


/obj/item/assembly_holder/update_overlays()
	. = ..()
	if(a_left)
		. += "[a_left.icon_state]_left"
		for(var/O in a_left.attached_overlays)
			. += "[O]_l"
	if(a_right)
		. += "[a_right.icon_state]_right"
		for(var/O in a_right.attached_overlays)
			. += "[O]_r"
	master?.update_icon()


/obj/item/assembly_holder/examine(mob/user)
	. = ..()
	if(in_range(src, user))
		if(secured)
			. += span_notice("[src] can be attached!")
		else
			. += span_notice("[src] need to be secured!")


/obj/item/assembly_holder/HasProximity(atom/movable/AM)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)


/obj/item/assembly_holder/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(assembly_crossed), arrived, old_loc)


/obj/item/assembly_holder/proc/assembly_crossed(atom/movable/crossed, atom/old_loc)
	if(a_left)
		a_left.assembly_crossed(crossed, old_loc)
	if(a_right)
		a_right.assembly_crossed(crossed, old_loc)


/obj/item/assembly_holder/on_found(mob/finder)
	if(a_left)
		a_left.on_found(finder)
	if(a_right)
		a_right.on_found(finder)


/obj/item/assembly_holder/hear_talk(mob/living/M, list/message_pieces)
	if(a_left)
		a_left.hear_talk(M, message_pieces)
	if(a_right)
		a_right.hear_talk(M, message_pieces)


/obj/item/assembly_holder/hear_message(mob/living/M, msg)
	if(a_left)
		a_left.hear_message(M, msg)
	if(a_right)
		a_right.hear_message(M, msg)


/obj/item/assembly_holder/proc/process_movement(mob/user) // infrared beams and prox sensors
	if(a_left && a_right)
		a_left.holder_movement(user)
		a_right.holder_movement(user)


/obj/item/assembly_holder/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	process_movement()


/obj/item/assembly_holder/pickup(mob/user)
	. = ..()
	process_movement(user)


/obj/item/assembly_holder/Bump(atom/bumped_atom)
	. = ..()
	if(. || !ismob(bumped_atom))
		return .
	process_movement(bumped_atom)


/obj/item/assembly_holder/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum) // called when a throw stops
	..()
	var/triggered
	if(throwing?.thrower)
		triggered = throwing.thrower
	process_movement(triggered)


/obj/item/assembly_holder/attack_hand(mob/user)//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(a_left && a_right)
		a_left.holder_movement(user)
		a_right.holder_movement(user)
	..()


/obj/item/assembly_holder/screwdriver_act(mob/user, obj/item/I)
	if(!a_left || !a_right)
		to_chat(user, span_warning("BUG:Assembly part missing, please report this!"))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	a_left.toggle_secure()
	a_right.toggle_secure()
	secured = !secured
	if(secured)
		to_chat(user, span_notice("[src] can now be attached!"))
	else
		to_chat(user, span_notice("[src] can now be taken apart!"))
	update_icon()


/obj/item/assembly_holder/attack_self(mob/user)
	add_fingerprint(user)
	if(secured)
		if(!a_left || !a_right)
			to_chat(user, span_warning("Assembly part missing!"))
			return
		if(istype(a_left, a_right.type)) // If they are the same type it causes issues due to window code
			switch(tgui_alert(user, "Which side would you like to use?", "Choose", list("Left", "Right")))
				if("Left")
					a_left.attack_self(user)
				if("Right")
					a_right.attack_self(user)
			return
		else
			a_left.attack_self(user)
			a_right.attack_self(user)
	else
		var/turf/T = get_turf(src)
		if(!T)
			return FALSE
		if(a_left)
			a_left.holder = null
			a_left.forceMove(T)
			user.put_in_hands(a_left, ignore_anim = FALSE)
		if(a_right)
			a_right.holder = null
			a_right.forceMove(T)
			user.put_in_hands(a_left, ignore_anim = FALSE)
		qdel(src)

