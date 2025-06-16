/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	item_chair = null
	anchored = TRUE
	var/obj/item/assembly/shock_kit/part
	var/last_time = 0
	var/delay_time = 5 SECONDS
	var/shocking = FALSE


/obj/structure/chair/e_chair/Initialize(mapload, obj/item/assembly/shock_kit/sk)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

	if(sk)
		part = sk

	if(isnull(part)) //This e-chair was not custom built
		part = new(src)
		var/obj/item/clothing/head/helmet/part1 = new(part)
		var/obj/item/radio/electropack/part2 = new(part)
		part2.set_frequency(1445)
		part2.code = 6
		part2.master = part
		part.part1 = part1
		part.part2 = part2


/obj/structure/chair/e_chair/Destroy()
	if(part)
		QDEL_NULL(part)
	return ..()


/obj/structure/chair/e_chair/rotate()
	if(..())
		update_icon(UPDATE_OVERLAYS)


/obj/structure/chair/e_chair/update_icon_state()
	icon_state = "echair[shocking]"


/obj/structure/chair/e_chair/update_overlays()
	. = ..()
	. += image(icon, icon_state = "echair_over", layer = ABOVE_MOB_LAYER, dir = src.dir)
	if(shocking)
		. += image(icon, icon_state = "echair_shock", layer = ABOVE_MOB_LAYER)


/obj/structure/chair/e_chair/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/obj/structure/chair/new_chair = new(loc)
	new_chair.setDir(dir)
	transfer_fingerprints_to(new_chair)
	new_chair.add_fingerprint(user)
	part.forceMove(loc)
	part.master = null
	part = null
	qdel(src)


/obj/structure/chair/e_chair/examine(mob/user)
	. = ..()
	. += span_warning("You can <b>Alt-Shift-Click</b> [src] to activate it.")


/obj/structure/chair/e_chair/AltShiftClick(mob/living/user)
	if(!Adjacent(user))
		return ..()
	shock(user)


/obj/structure/chair/e_chair/verb/activate_e_chair()
	set name = "Activate Electric Chair"
	set category = "Object"
	set src in oview(1)

	shock(usr)


/obj/structure/chair/e_chair/proc/shock(mob/living/user)
	if(isliving(user) && (user.incapacitated() || !isAI(user) && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		return

	// special power handling
	var/area/our_area = get_area(src)
	if(!our_area || !our_area.powered(EQUIP))
		return

	if(last_time + delay_time > world.time)
		if(user)
			to_chat(user, span_warning("[src] is not ready yet!"))
		return
	last_time = world.time
	our_area.use_power(5000, EQUIP)
	our_area.update_icon(UPDATE_ICON_STATE)

	if(user)
		to_chat(user, span_notice("You activate [src]."))

	shocking = TRUE
	update_icon()
	do_sparks(12, 1, src)
	visible_message(span_danger("The electric chair went off!"))
	addtimer(CALLBACK(src, PROC_REF(reset_echair)), delay_time, TIMER_DELETE_ME)

	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.electrocute_act(110, "электрического стула")
			to_chat(buckled_mob, span_userdanger("You feel a deep shock course through your body!"))
			addtimer(CALLBACK(buckled_mob, TYPE_PROC_REF(/mob/living, electrocute_act), 110, "электрического стула"), 0.1 SECONDS, TIMER_DELETE_ME)


/obj/structure/chair/e_chair/proc/reset_echair()
	shocking = FALSE
	update_icon()

