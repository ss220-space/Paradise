//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos


/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie


/obj/structure/toilet/Initialize(mapload)
	. = ..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/Destroy()
	swirlie = null
	return ..()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(5)
		return

	if(cistern && !open)
		if(!contents.len)
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			add_fingerprint(user)
			if(ishuman(user))
				I.forceMove_turf()
				user.put_in_hands(I, ignore_anim = FALSE)
			else
				I.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You find [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	add_fingerprint(user)
	open = !open
	update_icon()


/obj/structure/toilet/update_icon_state()
	icon_state = "toilet[open][cistern]"
	if(!anchored)
		pixel_x = 0
		pixel_y = 0
		layer = OBJ_LAYER
	else
		if(dir == SOUTH)
			pixel_x = 0
			pixel_y = 8
		if(dir == NORTH)
			pixel_x = 0
			pixel_y = -8
			layer = FLY_LAYER


/obj/structure/toilet/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	var/mob/living/victim = grabbed_thing
	if(victim.loc != get_turf(src))
		to_chat(grabber, span_warning("[victim] needs to be on [src]!"))
		return .
	add_fingerprint(grabber)
	if(open && !swirlie)
		victim.visible_message(
			span_danger("[grabber] starts to give [victim] a swirlie!"),
			span_userdanger("[grabber] starts to give you a swirlie..."),
		)
		swirlie = victim
		if(do_after(grabber, 3 SECONDS, src, NONE) && grabber.pulling == victim)
			victim.visible_message(
				span_danger("[grabber] gives [victim] a swirlie!"),
				span_userdanger("[grabber] gives [victim] a swirlie!"),
				span_italics("You hear a toilet flushing."),
			)
			if(!victim.internal)
				victim.adjustOxyLoss(5)
		swirlie = null
	else
		playsound(loc, 'sound/effects/bang.ogg', 25, TRUE)
		victim.visible_message(
			span_danger("[grabber] slams [victim.name] into [src]!"),
			span_userdanger("[grabber] slams you into [src]!"),
		)
		victim.adjustBruteLoss(5)


/obj/structure/toilet/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/reagent_containers))
		add_fingerprint(user)
		if(!open)
			to_chat(user, span_warning("You cannot fill [I] from [src] while its closed."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/reagent_containers/container = I
		if(!container.is_refillable())
			to_chat(user, span_warning("The [container.name] is not refillable."))
			return ATTACK_CHAIN_PROCEED
		if(container.reagents.holder_full())
			to_chat(user, span_warning("The [container.name] is full.."))
			return ATTACK_CHAIN_PROCEED
		container.reagents.add_reagent("toiletwater", min(container.volume - container.reagents.total_volume, container.amount_per_transfer_from_this))
		to_chat(user, span_notice("You fill [container] from [src]. Gross."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(cistern)
		add_fingerprint(user)
		stash_goods(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/toilet/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>")
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
		cistern = !cistern
		update_icon()


/obj/structure/toilet/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/choices = list()
	if(cistern)
		choices += "Stash"
	if(anchored)
		choices += "Disconnect"
	else
		choices += "Connect"
		choices += "Rotate"

	var/response = tgui_input_list(user, "What do you want to do?", "[src]", choices)
	if(!Adjacent(user) || !response)	//moved away or cancelled
		return
	switch(response)
		if("Stash")
			stash_goods(I, user)
		if("Disconnect")
			user.visible_message("<span class='notice'>[user] starts disconnecting [src].</span>", "<span class='notice'>You begin disconnecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || !anchored)
					return
				user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
				set_anchored(FALSE)
		if("Connect")
			user.visible_message("<span class='notice'>[user] starts connecting [src].</span>", "<span class='notice'>You begin connecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || anchored)
					return
				user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
				set_anchored(TRUE)
		if("Rotate")
			var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
			var/selected = input(user,"Select a direction for the connector.", "Connector Direction") in dir_choices
			dir = dir_choices[selected]
	update_icon()

/obj/structure/toilet/proc/stash_goods(obj/item/I, mob/user)
	if(!I)
		return
	if(I.w_class > WEIGHT_CLASS_NORMAL) // if item size > 3
		to_chat(user, "<span class='warning'>[I] does not fit!</span>")
		return
	if(w_items + I.w_class > WEIGHT_CLASS_HUGE) // if item size > 5
		to_chat(user, "<span class='warning'>The cistern is full!</span>")
		return
	if(!user.drop_transfer_item_to_loc(I, src))
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in the cistern!</span>")
		return
	w_items += I.w_class
	to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if(secret_type)
		var/obj/item/secret = new secret_type(src)
		secret.desc += " It's a secret!"
		w_items += secret.w_class


/obj/structure/toilet/cancollectmapitems // this toilet made specially for map editor, collects objects on same turf at map loading
	// as well as closets do. regular toilet can't do this. has the same restrictions for objects like regular toilet has.
	// собирает в себя предметы на своём атоме при загрузки карты, сделано специально для редактора карт, обычный так не может.

/obj/structure/toilet/cancollectmapitems/Initialize(mapload)
	. = ..()
	for(var/obj/item/I in loc)
		if(w_items > WEIGHT_CLASS_HUGE) //if items summary size >= 5 , stop collecting
			break
		if(I.w_class > WEIGHT_CLASS_NORMAL) // if item size > 3 , skip the item, get the next
			continue
		if(I.w_class + w_items <= WEIGHT_CLASS_HUGE) // if items summary size <= than 5 , add item in contents
			w_items += I.w_class
			I.forceMove(src)


/obj/structure/toilet/golden_toilet
	name = "Золотой унитаз"
	desc = "Поговаривают, что 7 веков назад у каждого арабского шейха был такой унитаз. Им явно кто-то пользовался..."
	icon_state = "gold_toilet00"

/obj/structure/toilet/golden_toilet/update_icon_state()
	. = ..()
	icon_state = "gold_toilet[open][cistern]"

/obj/structure/toilet/captain_toilet
	name = "Унитаз Капитана"
	desc = "Престижное седалище для престижной персоны. Судя по форме, был идеально подготовлен под седальное место Капитана."
	icon_state = "captain_toilet00"

/obj/structure/toilet/captain_toilet/update_icon_state()
	. = ..()
	icon_state = "captain_toilet[open][cistern]"

/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE


/obj/structure/urinal/grab_attack(mob/living/grabber, atom/movable/grabbed_thing)
	. = TRUE
	if(grabber.grab_state < GRAB_AGGRESSIVE || !isliving(grabbed_thing))
		return .
	var/mob/living/victim = grabbed_thing
	if(victim.loc != get_turf(src))
		to_chat(grabber, span_warning("[victim] needs to be on [src]!"))
		return .
	add_fingerprint(grabber)
	playsound(loc, 'sound/effects/bang.ogg', 25, TRUE)
	victim.visible_message(
		span_danger("[grabber] slams [victim.name] into [src]!"),
		span_userdanger("[grabber] slams you into [src]!"),
	)
	victim.adjustBruteLoss(8)


/obj/structure/urinal/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		user.visible_message("<span class='notice'>[user] begins disconnecting [src]...</span>", "<span class='notice'>You begin to disconnect [src]...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!loc || !anchored)
				return
			user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
			set_anchored(FALSE)
			pixel_x = 0
			pixel_y = 0
	else
		user.visible_message("<span class='notice'>[user] begins connecting [src]...</span>", "<span class='notice'>You begin to connect [src]...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!loc || anchored)
				return
			user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
			set_anchored(TRUE)
			pixel_x = 0
			pixel_y = 32


#define SHOWER_FREEZING "freezing"
#define SHOWER_NORMAL "normal"
#define SHOWER_BOILING "boiling"

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	///Is the shower on or off?
	var/on = FALSE
	///What temperature the shower reagents are set to.
	var/current_temperature = SHOWER_NORMAL
	///What sound will be played on loop when the shower is on and pouring water.
	var/datum/looping_sound/showering/soundloop


/obj/machinery/shower/Initialize(mapload, newdir = SOUTH, building = FALSE)
	. = ..()
	soundloop = new(list(src), FALSE)
	if(building)
		setDir(newdir)
		pixel_x = 0
		pixel_y = 0
		switch(dir)
			if(SOUTH)
				pixel_y = 16
			if(NORTH)
				pixel_y = -5
				layer = FLY_LAYER
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	var/obj/effect/mist/mist = locate() in loc
	if(!QDELETED(mist))
		QDEL_IN(mist, 25 SECONDS)
	return ..()

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


/obj/machinery/shower/attack_hand(mob/user)
	on = !on
	update_icon()
	handle_mist()
	add_fingerprint(user)
	if(on)
		START_PROCESSING(SSmachines, src)
		process()
		soundloop.start()
	else
		soundloop.stop()
		var/turf/simulated/source_turf = loc
		if(istype(source_turf) && !source_turf.density)
			source_turf.MakeSlippery(TURF_WET_WATER, min_wet_time = 5 SECONDS, wet_time_to_add = 1 SECONDS)


/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/analyzer))
		add_fingerprint(user)
		to_chat(user, span_notice("The water temperature seems to be [current_temperature]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/machinery/shower/wrench_act(mob/user, obj/item/I)
	to_chat(user, span_notice("You begin to adjust the temperature valve with [I]."))
	if(I.use_tool(src, user, 5 SECONDS))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message(
			span_notice("[user] adjusts the shower with [I]."),
			span_notice("You adjust [src] to [current_temperature] temperature."),
		)
		add_hiddenprint(user)
	handle_mist()
	return TRUE


/obj/machinery/shower/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(on)
		to_chat(user, span_warning("Turn [src] off before you attempt to cut it loose."))
		return
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message(
		span_notice("[user] begins slicing [src] free..."),
		span_notice("You begin slicing [src] free..."),
		span_italics("You hear welding."),
	)
	if(I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume))
		user.visible_message(
			span_notice("[user] cuts [src] loose!"),
			span_notice("You cut [src] loose!>"),
		)
		var/obj/item/mounted/shower/shower = new /obj/item/mounted/shower(get_turf(user))
		transfer_prints_to(shower, TRUE)
		qdel(src)


/obj/machinery/shower/update_overlays()
	. = ..()
	if(on)
		. += image(icon, icon_state = "water", layer = ABOVE_MOB_LAYER, dir = src.dir)


/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, PROC_REF(make_mist)), 5 SECONDS)

	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		addtimer(CALLBACK(src, PROC_REF(clear_mist)), 25 SECONDS)


/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		new /obj/effect/mist(loc)


/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)


/obj/machinery/shower/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(on)
		wash(arrived)


/obj/machinery/shower/proc/convertHeat()
	switch(current_temperature)
		if(SHOWER_BOILING)
			return 340.15
		if(SHOWER_NORMAL)
			return 310.15
		if(SHOWER_FREEZING)
			return 230.15


//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/target)
	if(!on)
		return

	if(isitem(target))
		var/obj/item/item = target
		item.extinguish()

	target.water_act(100, convertHeat(), src)

	if(isliving(target))
		var/mob/living/l_target = target
		l_target.ExtinguishMob()
		l_target.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
		to_chat(l_target, span_warning("You've been drenched in water!"))

	target.clean_blood()


/obj/machinery/shower/process()
	if(on)
		if(isturf(loc))
			var/turf/tile = loc
			tile.water_act(100, convertHeat(), src)
			tile.clean_blood()
			for(var/obj/effect/effect in tile)
				if(effect.is_cleanable())
					qdel(effect)
		for(var/thing in loc)
			wash(thing)
	else
		on = FALSE
		soundloop.stop()
		handle_mist()
		update_icon(UPDATE_OVERLAYS)


/obj/machinery/shower/proc/check_heat(mob/M)
	if(current_temperature == SHOWER_NORMAL)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(current_temperature == SHOWER_FREEZING)
			//C.bodytemperature = max(80, C.bodytemperature - 80)
			to_chat(C, "<span class='warning'>The water is freezing!</span>")

		else if(current_temperature == SHOWER_BOILING)
			//C.bodytemperature = min(500, C.bodytemperature + 35)
			C.adjustFireLoss(5)
			to_chat(C, "<span class='danger'>The water is searing!</span>")

#undef SHOWER_FREEZING
#undef SHOWER_NORMAL
#undef SHOWER_BOILING


/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	honk_sounds = list('sound/items/squeaktoy.ogg' = 1)
	attack_verb = list("quacked", "squeaked")

/obj/item/bikehorn/rubberducky/captain
	name = "уточка-капитан"
	desc = "Капитан всех уточек на этой станции. Крайне важная и престижная уточка. Выпущены в ограниченных экземплярах и только для капитанов. Ценная находка для коллекционеров."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "captain_rubberducky"
	item_state = "captain_rubberducky"

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = 0 	//Something's being washed at the moment
	var/can_move = 1	//if the sink can be disconnected and moved
	var/can_rotate = 1	//if the sink can be rotated to face alternate directions

/obj/structure/sink/attack_hand(mob/user as mob)
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] isn't connected, wrench it into position first!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
		if(user.hand)
			temp = H.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return

	if(busy)
		to_chat(user, "<span class='notice'>Someone's already washing here.</span>")
		return
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = 0
	if(selected_area in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES))
		washing_face = 1
	user.visible_message("<span class='notice'>[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = 1

	if(!do_after(user, 4 SECONDS, src))
		busy = 0
		return

	add_fingerprint(user)

	busy = 0

	user.visible_message("<span class='notice'>[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.regenerate_icons()
			H.AdjustDrowsy(-rand(4 SECONDS, 6 SECONDS)) //Washing your face wakes you up if you're falling asleep
	else
		user.clean_blood()


/obj/structure/sink/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)

	if(!anchored)
		to_chat(user, span_warning("The [name] isn't connected, wrench it into position first."))
		return ATTACK_CHAIN_PROCEED

	if(busy)
		to_chat(user, span_warning("Someone's already washing here."))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	busy = TRUE
	var/wateract = I.wash(user, src)
	busy = FALSE
	if(wateract)
		I.water_act(20, COLD_WATER_TEMPERATURE, src)


/obj/structure/sink/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/choices = list()
	if(anchored)
		choices += "Wash"
		if(can_move)
			choices += "Disconnect"
	else
		choices += "Connect"
		if(can_rotate)
			choices += "Rotate"

	var/response = tgui_input_list(user, "What do you want to do?", "[src]", choices)
	if(!Adjacent(user) || !response)	//moved away or cancelled
		return
	switch(response)
		if("Wash")
			busy = 1
			var/wateract = 0
			wateract = (I.wash(user, src))
			busy = 0
			if(wateract)
				I.water_act(20, COLD_WATER_TEMPERATURE, src)
		if("Disconnect")
			user.visible_message("<span class='notice'>[user] starts disconnecting [src].</span>", "<span class='notice'>You begin disconnecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || !anchored)
					return
				user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
				set_anchored(FALSE)
		if("Connect")
			user.visible_message("<span class='notice'>[user] starts connecting [src].</span>", "<span class='notice'>You begin connecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || anchored)
					return
				user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
				set_anchored(TRUE)
		if("Rotate")
			var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
			var/selected = input(user, "Select a direction for the connector.", "Connector Direction") in dir_choices
			dir = dir_choices[selected]
	update_icon(UPDATE_ICON_STATE)

/obj/structure/sink/update_icon_state()
	layer = OBJ_LAYER
	if(!anchored)
		pixel_x = 0
		pixel_y = 0
	else
		//the following code will probably want to be updated in the future to be less reliant on hardcoded offsets based on the can_move/can_rotate values
		if(!can_move)		//puddles
			return
		if(!can_rotate)		//kitchen sinks
			pixel_x = 0
			pixel_y = 28
			return
		else				//normal sinks
			if(dir == NORTH || dir == SOUTH)
				pixel_x = 0
				pixel_y = (dir == NORTH) ? -5 : 30
				if(dir == NORTH)
					layer = FLY_LAYER
			else
				pixel_x = (dir == EAST) ? 12 : -12
				pixel_y = 0


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"
	can_rotate = 0


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
	icon_state = "puddle"
	can_move = 0
	can_rotate = 0
	resistance_flags = UNACIDABLE


/obj/structure/sink/puddle/attack_hand(mob/user)
	flick("puddle-splash", src)
	return ..()


/obj/structure/sink/puddle/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/shovel))
		user.visible_message(
			span_notice("[user] starts to remove [src] with [I]."),
			span_notice("You start to remove [src]..."),
		)
		I.play_tool_sound(src, 100)
		flick("puddle-splash", src)
		if(!do_after(user, 5 SECONDS, src, category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		I.play_tool_sound(src, 100)
		user.visible_message(
			span_notice("[user] removed [src] with [I]."),
			span_notice("You removed [src]."),
		)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


//////////////////////////////////
//		Bathroom Fixture Items	//
//////////////////////////////////


/obj/item/mounted/shower
	name = "shower fixture"
	desc = "A self-adhering shower fixture. Simply stick to a wall, no plumber needed!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	item_state = "buildpipe"

/obj/item/mounted/shower/try_build(turf/on_wall, mob/user, proximity_flag)
	//overriding this because we don't care about other items on the wall, but still need to do adjacent checks
	if(!on_wall || !user)
		return
	if(proximity_flag != 1) //if we aren't next to the wall
		return
	if(!(get_dir(on_wall, user) in GLOB.cardinal))
		to_chat(user, "<span class='warning'>You need to be standing next to a wall to place \the [src].</span>")
		return
	return 1

/obj/item/mounted/shower/do_build(turf/on_wall, mob/user)
	var/obj/machinery/shower/S = new(get_turf(user), get_dir(on_wall, user), TRUE)
	transfer_fingerprints_to(S)
	qdel(src)


/obj/item/bathroom_parts
	name = "toilet in a box"
	desc = "An entire toilet in a box, straight from Space Sweden. It has an unpronounceable name."
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebox"
	w_class = WEIGHT_CLASS_BULKY
	var/result = /obj/structure/toilet
	var/result_name = "toilet"

/obj/item/bathroom_parts/urinal
	name = "urinal in a box"
	result = /obj/structure/urinal
	result_name = "urinal"

/obj/item/bathroom_parts/sink
	name = "sink in a box"
	result = /obj/structure/sink
	result_name = "sink"

/obj/item/bathroom_parts/New()
	..()
	desc = "An entire [result_name] in a box, straight from Space Sweden. It has an [pick("unpronounceable", "overly accented", "entirely gibberish", "oddly normal-sounding")] name."

/obj/item/bathroom_parts/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		to_chat(user, "<span class='warning'>You can't build that here!</span>")
		return
	if(result in T.contents)
		to_chat(user, "<span class='warning'>There's already \an [result_name] here.</span>")
		return
	user.visible_message("<span class='notice'>[user] begins assembling a new [result_name].</span>", "<span class='notice'>You begin assembling a new [result_name].</span>")
	if(do_after(user, 3 SECONDS, user))
		user.visible_message("<span class='notice'>[user] finishes building a new [result_name]!</span>", "<span class='notice'>You finish building a new [result_name]!</span>")
		var/obj/structure/S = new result(T)
		S.set_anchored(FALSE)
		S.dir = user.dir
		S.update_icon(UPDATE_ICON_STATE)
		user.temporarily_remove_item_from_inventory(src, force = TRUE)
		qdel(src)
		if(prob(50))
			new /obj/item/stack/sheet/cardboard(T)
