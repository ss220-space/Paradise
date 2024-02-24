/obj/item/implanter
	name = "bio-chip implanter"
	desc = "A sterile automatic bio-chip injector."
	icon = 'icons/obj/implants.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	toolspeed = 1
	/// Path thats will be transformed into object on Initialize()
	var/obj/item/implant/imp


/obj/item/implanter/Initialize(mapload)
	. = ..()
	if(ispath(imp, /obj/item/implant))
		imp = new imp(src)
	update_state()


/obj/item/implanter/Destroy()
	QDEL_NULL(imp)
	return ..()


/obj/item/implanter/proc/update_state()
	origin_tech = imp ? imp.origin_tech : initial(origin_tech)
	update_icon(UPDATE_ICON_STATE)


/obj/item/implanter/update_icon_state()
	icon_state = "implanter[imp ? "1" : "0"]"


/obj/item/implanter/attack(mob/living/carbon/target, mob/user)
	if(!iscarbon(target))
		return
	if(user && imp)
		if(target != user)
			target.visible_message(span_warning("[user] is attempting to bio-chip [target]."))

		var/turf/target_turf = get_turf(target)
		if(target_turf && (target == user || do_after(user, 5 SECONDS * toolspeed * gettoolspeedmod(user), target = target)))
			if(!QDELETED(user) && !QDELETED(target) && !QDELETED(src) && !QDELETED(imp) && get_turf(target) == target_turf && imp.implant(target, user))
				if(user == target)
					to_chat(user, span_notice("You bio-chip yourself."))
				else
					target.visible_message("[user] has implanted [target].", span_notice("[user] bio-chips you."))
				imp = null
				update_state()


/obj/item/implanter/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
	else
		return ..()

