//special torch lamps

#define TORCH_OK 0
#define TORCH_EMPTY 1
#define TORCH_OFF 2
#define TORCH_BURNED 3

/obj/item/mounted/frame/torch_holder
	name = "torch holder"
	desc = "Used for building lights in medieval castles."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch_holder_item"
	mount_reqs = list("simfloor")

/obj/item/mounted/frame/torch_holder/do_build(turf/on_wall, mob/user)
	to_chat(user, "You begin attaching [src] to \the [on_wall].")
	playsound(get_turf(src), 'sound/machines/click.ogg', 75, 1)
	var/constrdir = user.dir
	var/constrloc = get_turf(user)
	if(!do_after(user, 20, target = on_wall))
		return
	var/obj/machinery/torch_holder/built/torch = new(constrloc)
	torch.dir = constrdir
	torch.fingerprints = src.fingerprints
	torch.fingerprintshidden = src.fingerprintshidden
	torch.fingerprintslast = src.fingerprintslast

	user.visible_message("[user] attaches \the [src] to \the [on_wall].", \
		"You attach \the [src] to \the [on_wall].")
	qdel(src)

/obj/machinery/torch_holder
	name = "torch holder"
	desc = "A fancy looking torch holder."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "torch_holder"
	var/obj/item/flashlight/flare/torch/fakel
	/// For mapping. Ancient torches can't be taken away and they are infinite
	var/ancient = FALSE
	/// Light range when on. Standart torch is brighter, this is for mapping reason.
	var/brightness_range = 4
	/// Light colour when on
	var/brightness_color = "#FA9632"
	/// Light power when on
	var/brightness_power = 1
	/// Torch holder status (TORCH_OK | TORCH_EMPTY | TORCH_OFF | TORCH_BURNED)
	var/status = TORCH_OK
	///Fuel consumption
	var/fuel = 0
	///New torch related stuff
	var/fuel_lower = 0
	var/fuel_upp = 0

/obj/machinery/torch_holder/Initialize(mapload) //mapping version, preloaded with torch
	. = ..()
	fakel = new(src)
	fuel = fakel.fuel
	update_icon()
	update_light_state()
	START_PROCESSING(SSobj, src)


/obj/machinery/torch_holder/Destroy()
	. = ..()
	QDEL_NULL(fakel)
	STOP_PROCESSING(SSobj, src)

/obj/machinery/torch_holder/examine(mob/user)
	. = ..()
	. += "<span class='notice'>"
	if(in_range(user, src))
		switch(status)
			if(TORCH_OK)
				. += "[fakel] is burning brightly."
			if(TORCH_EMPTY)
				. += "[fakel] has been removed."
			if(TORCH_OFF)
				. += "[fakel] isn't lit."
			if(TORCH_BURNED)
				. += "[fakel] is burnt out"
	. += "</span>"

/obj/machinery/torch_holder/process()
	if(ancient)
		return
	if(status != TORCH_OK)
		return
	fuel = max(fuel - 1, 0)
	if(!fuel)
		burnout()
		STOP_PROCESSING(SSobj, src)

/obj/machinery/torch_holder/proc/update_light_state() //I can't make it better..
	switch(status)
		if(TORCH_OFF, TORCH_BURNED, TORCH_EMPTY)
			set_light(0)
			return
		else
			light_range = brightness_range
			light_power = brightness_power
			light_color = brightness_color
			update_light()


/obj/machinery/torch_holder/proc/burnout()
	if(ancient)
		return
	if(!fuel) //double check
		status = TORCH_BURNED
		update_light_state()
		update_icon()
	else
		return


/obj/machinery/torch_holder/update_icon(UPDATE_OVERLAYS)
	if(ancient)
		return
	overlays.Cut()
	switch(status)		// set overlays
		if(TORCH_OK)
			overlays += "torch_overlay"
		if(TORCH_OFF, TORCH_BURNED)
			overlays += "torch_overlay_not_light"
		if(TORCH_EMPTY)
			overlays += ""

/obj/machinery/torch_holder/attackby(obj/item/W, mob/user, params)
	if(ancient)
		return
	user.changeNext_move(CLICK_CD_MELEE) // This is an ugly hack and I hate it forever
	if(istype(W, /obj/item/flashlight/flare/torch))
		var/obj/item/flashlight/flare/torch/T = W
		if(status != TORCH_EMPTY)
			if(status == TORCH_OFF && T.on)
				to_chat(user, span_notice("You ignite [src] with [T]!"))
				status = TORCH_OK
				update_icon()

				brightness_range = T.light_range
				brightness_power = T.light_power
				brightness_color = T.light_color

				update_light_state()
				START_PROCESSING(SSobj, src)
				return
			else
				to_chat(user, span_warning("There is already [fakel] inserted."))
				return
		else
			add_fingerprint(user)
			if(!T.fuel)
				to_chat(user, span_warning("[T] is already burned out!"))
				return
			to_chat(user, span_notice("You insert [T]."))
			if(!T.on)
				status = TORCH_OFF
			else
				status = TORCH_OK
				START_PROCESSING(SSobj, src)

		brightness_range = T.light_range
		brightness_power = T.light_power
		brightness_color = T.light_color

		fuel = T.fuel
		fuel_lower = T.fuel_lower
		fuel_upp = T.fuel_upp
		update_icon()
		update_light_state()

		user.drop_transfer_item_to_loc(T, src)	//drop the item to update overlays and such
		qdel(T)

/obj/machinery/torch_holder/attack_hand(mob/user)
	if(ancient)
		to_chat(user, span_warning("It seems the torch is chained to the holder, you can't remove it!"))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == TORCH_EMPTY)
		to_chat(user, span_warning("There is nothing in this [src]."))
		return
	// make it burn hands if not wearing fire-insulated gloves
	if(status == TORCH_OK)
		var/prot = 0
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || (HEATRES in user.mutations))
			to_chat(user, span_notice("You remove [fakel]."))
		else if(TK in user.mutations)
			to_chat(user, span_notice("You telekinetically remove [fakel]."))
		else
			if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_GRAB)
				to_chat(user, span_warning("You try to remove [fakel], but burn your hand on it!"))
				var/obj/item/organ/external/affecting = H.get_organ(user.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				if(affecting.receive_damage(0, 5)) // 5 burn damage
					H.UpdateDamageIcon()
				H.updatehealth()
				return
			else
				to_chat(user, span_warning("You try to remove [fakel], but it's too hot to touch!"))
				return
	else
		to_chat(user, span_notice("You remove [fakel]."))
	drop_fakel(user)

/obj/machinery/torch_holder/proc/drop_fakel(mob/user)
	var/obj/item/flashlight/flare/torch/L = new(src)
	if(status == TORCH_OK)
		L.attack_self(user)//forcing it to light up and start processing
	L.fuel = fuel

	L.light_range = brightness_range	//all this shitcode
	L.light_power = brightness_power	//is necessary for
	L.light_color = brightness_color	//remembering colored
	L.update_light()					//torches after droping (there isn't any coloured torches in game)

	L.update_brightness()

	L.forceMove(loc)
	if(user) //puts it in our active hand
		L.add_fingerprint(user)
		user.put_in_active_hand(L, ignore_anim = FALSE)

	status = TORCH_EMPTY
	update_icon()
	update_light_state()
	return L

/obj/machinery/torch_holder/mapping
	name = "ancient torch holder"
	icon_state = "torch_holder_complete"
	ancient = TRUE

/obj/machinery/torch_holder/mapping/Initialize(mapload)
	. = ..()
	fuel = INFINITY


/obj/machinery/torch_holder/built/Initialize(mapload)
	status = TORCH_EMPTY
	STOP_PROCESSING(SSobj, src)
	..()

/obj/machinery/torch_holder/extinguish_light(force = FALSE)
	if(force)
		fuel = 0
		visible_message(span_danger("[src] burns up rapidly!"))
	else
		visible_message(span_danger("[src] dims slightly before scattering the shadows around it."))

#undef TORCH_OK
#undef TORCH_EMPTY
#undef TORCH_OFF
#undef TORCH_BURNED
