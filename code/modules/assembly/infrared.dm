/obj/item/assembly/infra
	name = "infrared emitter"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	materials = list(MAT_METAL=1000, MAT_GLASS=500)
	origin_tech = "magnets=2;materials=2"
	bomb_name = "tripwire mine"
	set_dir_on_move = FALSE
	secured = FALSE // toggle_secure()'ed in Initialize() for correct adding to processing_objects, won't work otherwise
	dir = EAST
	var/on = FALSE
	var/visible = TRUE
	var/obj/effect/beam/i_beam/first = null
	var/obj/effect/beam/i_beam/last = null
	var/max_nesting_level = 10
	var/turf/fire_location
	var/emission_cycles = 0
	var/emission_cap = 20


/obj/item/assembly/infra/Initialize(mapload)
	. = ..()
	if(!secured)
		toggle_secure()


/obj/item/assembly/infra/Destroy()
	if(first)
		QDEL_NULL(first)
		last = null
		fire_location = null
	return ..()


/obj/item/assembly/infra/examine(mob/user)
	. = ..()
	. += span_notice("The assembly is [secured ? "secure" : "not secure"]. The infrared trigger is [on ? "on" : "off"].")
	. += span_info("<b>Alt-Click</b> to rotate it.")


/obj/item/assembly/infra/activate()
	if(!..())
		return FALSE//Cooldown check
	on = !on
	update_icon()
	return TRUE


/obj/item/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		START_PROCESSING(SSobj, src)
	else
		on = FALSE
		if(first)
			qdel(first)
		STOP_PROCESSING(SSobj, src)
	update_icon()
	return secured


/// Forces the device to arm no matter its current state.
/obj/item/assembly/infra/proc/arm()
	if(!secured) // Checked because arm() might be called sometime after the object is spawned.
		toggle_secure()
	on = TRUE


/obj/item/assembly/infra/update_overlays()
	. = ..()
	attached_overlays = list()
	if(on)
		. += "infrared_on"
		attached_overlays += "infrared_on"
	holder?.update_icon()


/obj/item/assembly/infra/process()
	var/turf/T = get_turf(src)
	if(first && (!on || !fire_location || fire_location != T || emission_cycles >= emission_cap))
		qdel(first)
		return
	if(!on)
		return
	if(!secured)
		return
	if(first && last)
		last.process()
		emission_cycles++
		return
	if(T)
		fire_location = T
		emission_cycles = 0
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(T)
		I.master = src
		I.set_density(TRUE)
		I.dir = dir
		I.update_icon()
		first = I
		step(I, I.dir)
		if(first)
			I.set_density(FALSE)
			I.vis_spread(visible)
			I.limit = 8
			I.process()


/obj/item/assembly/infra/attack_hand()
	qdel(first)
	..()


/obj/item/assembly/infra/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	qdel(first)


/obj/item/assembly/infra/holder_movement()
	if(!holder)
		return FALSE
	qdel(first)
	return TRUE


/obj/item/assembly/infra/equipped(mob/user, slot, initial)
	qdel(first)
	return ..()


/obj/item/assembly/infra/pickup(mob/user)
	qdel(first)
	return ..()


/obj/item/assembly/infra/proc/trigger_beam(atom/movable/AM)
	var/mob/triggered
	if(AM.throwing?.thrower)
		triggered = AM.throwing.thrower
	else if(ismob(AM))
		triggered = AM
	if(!secured || !on || cooldown > 0)
		return FALSE
	cooldown = 2
	pulse(FALSE, triggered)
	audible_message("[bicon(src)] *beep* *beep*", hearing_distance = 3)
	if(first)
		qdel(first)
	addtimer(CALLBACK(src, PROC_REF(process_cooldown)), 1 SECONDS)


/obj/item/assembly/infra/interact(mob/user)//TODO: change this this to the wire control panel
	if(!secured)
		return
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8"><TT><B>Infrared Laser</B>
				<B>Status</B>: [on ? "<a href='byond://?src=[UID()];state=0'>On</A>" : "<a href='byond://?src=[UID()];state=1'>Off</A>"]<BR>
				<B>Visibility</B>: [visible ? "<a href='byond://?src=[UID()];visible=0'>Visible</A>" : "<a href='byond://?src=[UID()];visible=1'>Invisible</A>"]<BR>
				<B>Current Direction</B>: <a href='byond://?src=[UID()];rotate=1'>[capitalize(dir2text(dir))]</A><BR>
				</TT>
				<BR><BR><a href='byond://?src=[UID()];refresh=1'>Refresh</A>
				<BR><BR><a href='byond://?src=[UID()];close=1'>Close</A>"}
	var/datum/browser/popup = new(user, "infra", name, 400, 400, src)
	popup.set_content(dat)
	popup.open()


/obj/item/assembly/infra/Topic(href, href_list)
	..()
	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED) || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return
	if(href_list["state"])
		on = !(on)
		update_icon()
	if(href_list["visible"])
		visible = !(visible)
		if(first)
			first.vis_spread(visible)
	if(href_list["rotate"])
		rotate(usr)
	if(href_list["close"])
		usr << browse(null, "window=infra")
		return
	if(usr)
		attack_self(usr)


/obj/item/assembly/infra/AltClick(mob/user)
	if(!Adjacent(user))
		return ..()
	rotate(user)


/obj/item/assembly/infra/verb/rotate_verb()
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	rotate(usr)


/obj/item/assembly/infra/proc/rotate(mob/living/user = usr)
	if(!isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	dir = turn(dir, 90)

	if(user.machine == src)
		interact(user)

	if(first)
		qdel(first)


/obj/item/assembly/infra/armed/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(delayed_arm)), 0.3 SECONDS)


/obj/item/assembly/infra/armed/proc/delayed_arm()
	if(holder?.master)
		dir = holder.master.dir
	arm()


/obj/item/assembly/infra/armed/stealth
	visible = FALSE


/***************************IBeam*********************************/

/obj/effect/beam/i_beam
	name = "i beam"
	icon = 'icons/obj/weapons/projectiles.dmi'
	icon_state = "ibeam"
	var/obj/effect/beam/i_beam/next = null
	var/obj/effect/beam/i_beam/previous = null
	var/obj/item/assembly/infra/master = null
	var/limit = null
	var/visible = FALSE
	var/left = null
	var/life_cycles = 0
	var/life_cap = 20
	anchored = TRUE
	pass_flags_self = LETPASSTHROW
	pass_flags = PASSTABLE|PASSGLASS|PASSGRILLE|PASSFENCE


/obj/effect/beam/i_beam/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/beam/i_beam/Destroy()
	if(master && master.first == src)
		master.first = null
	QDEL_NULL(next)
	if(previous)
		previous.next = null
		master?.last = previous
	return ..()


/obj/effect/beam/i_beam/proc/hit(atom/movable/AM)
	master?.trigger_beam(AM)
	qdel(src)


/obj/effect/beam/i_beam/proc/vis_spread(new_visibility)
	visible = new_visibility
	if(next)
		next.vis_spread(new_visibility)


/obj/effect/beam/i_beam/update_icon_state()
	transform = turn(matrix(), dir2angle(dir))


/obj/effect/beam/i_beam/process()
	life_cycles++
	if(loc.density || !master || life_cycles >= life_cap)
		qdel(src)
		return
	if(left > 0)
		left--
	if(left < 1 && !visible)
		invisibility = INVISIBILITY_ABSTRACT
	else
		invisibility = 0

	if(!next && (limit > 0))
		var/obj/effect/beam/i_beam/I = new /obj/effect/beam/i_beam(loc)
		I.master = master
		I.set_density(TRUE)
		I.dir = dir
		I.update_icon()
		I.previous = src
		next = I
		step(I, I.dir)
		if(next)
			I.set_density(FALSE)
			I.vis_spread(visible)
			I.limit = limit - 1
			master.last = I
			I.process()


/obj/effect/beam/i_beam/Bump(atom/bumped_atom)
	qdel(src)


/obj/effect/beam/i_beam/Bumped(atom/movable/moving_atom)
	. = ..()
	hit(moving_atom)


/obj/effect/beam/i_beam/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isobj(arrived) && !isliving(arrived))
		return

	if(iseffect(arrived))
		return

	INVOKE_ASYNC(src, PROC_REF(hit), arrived)

