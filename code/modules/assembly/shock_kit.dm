/obj/item/assembly/shock_kit
	name = "electrohelmet assembly"
	desc = "This appears to be made from both an electropack and a helmet."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/radio/electropack/part2 = null
	var/status = 0
	w_class = WEIGHT_CLASS_HUGE
	flags = CONDUCT


/obj/item/assembly/shock_kit/Destroy()
	QDEL_NULL(part1)
	QDEL_NULL(part2)
	return ..()


/obj/item/assembly/shock_kit/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!status)
		return .
	add_fingerprint(user)
	var/drop_loc = drop_location()
	part1.forceMove(drop_loc)
	part2.forceMove(drop_loc)
	part1.master = null
	part2.master = null
	part1 = null
	part2 = null
	qdel(src)


/obj/item/assembly/shock_kit/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	status = !status
	if(status)
		to_chat(user, span_notice("[src] is now ready to be attached to a chair!"))
	else
		to_chat(user, span_notice("[src] is now ready!"))


/obj/item/assembly/shock_kit/attack_self(mob/user)
	part1.attack_self(user, status)
	part2.attack_self(user, status)
	add_fingerprint(user)


/obj/item/assembly/shock_kit/receive_signal()
	if(istype(loc, /obj/structure/chair/e_chair))
		var/obj/structure/chair/e_chair/chair = loc
		chair.shock()

