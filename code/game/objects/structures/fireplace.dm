#define LOG_BURN_TIMER 150
#define PAPER_BURN_TIMER 5
#define MAXIMUM_BURN_TIMER 3000

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone brick fireplace."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	density = FALSE
	anchored = TRUE
	pixel_x = -16
	resistance_flags = FIRE_PROOF
	layer = BELOW_MOB_LAYER
	max_integrity = 300
	var/lit = FALSE

	var/fuel_added = 0
	var/flame_expiry_timer

/obj/structure/fireplace/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()


/obj/structure/fireplace/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/wood))
		add_fingerprint(user)
		var/obj/item/stack/sheet/wood/wood = I
		var/space_remaining = MAXIMUM_BURN_TIMER - burn_time_remaining()
		var/space_for_logs = round(space_remaining / LOG_BURN_TIMER)
		if(space_for_logs < 1)
			to_chat(user, span_warning("You cannot add any more wood to [src]!"))
			return ATTACK_CHAIN_PROCEED
		var/logs_used = min(space_for_logs, wood.amount)
		if(!wood.use(logs_used))
			return ATTACK_CHAIN_PROCEED
		adjust_fuel_timer(LOG_BURN_TIMER * logs_used)
		user.visible_message(
			span_notice("[user] tosses some wood into [src]."),
			span_notice("You add some fuel to [src]."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/paper_bin))
		var/obj/item/paper_bin/paper_bin = I
		if(!user.drop_transfer_item_to_loc(paper_bin, src))
			return ..()
		add_fingerprint(user)
		user.visible_message(
			span_notice("[user] throws [paper_bin] into [src]."),
			span_notice("You add [paper_bin] to [src]."),
		)
		adjust_fuel_timer(PAPER_BURN_TIMER * paper_bin.amount)
		qdel(paper_bin)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/paper_bundle  = I
		if(!user.drop_transfer_item_to_loc(paper_bundle, src))
			return ..()
		add_fingerprint(user)
		user.visible_message(
			span_notice("[user] throws [paper_bundle] into [src]."),
			span_notice("You add [paper_bundle] to [src]."),
		)
		adjust_fuel_timer(PAPER_BURN_TIMER * paper_bundle.amount)
		qdel(paper_bundle)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paper))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		user.visible_message(
			span_notice("[user] throws [I] into [src]."),
			span_notice("You throw [I] into [src]."),
		)
		adjust_fuel_timer(PAPER_BURN_TIMER)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!is_hot(I))
		return ..()

	add_fingerprint(user)

	if(lit)
		to_chat(user, span_warning("It's already lit!"))
		return ATTACK_CHAIN_PROCEED

	if(!fuel_added)
		to_chat(user, span_warning("The [name] needs some fuel to burn!"))
		return ATTACK_CHAIN_PROCEED

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	user.visible_message(
		span_notice("[user] lights [src] with [I]."),
		span_notice("You have lit [src] with [I]."),
	)
	ignite()


/obj/structure/fireplace/update_desc(updates = ALL)
	. = ..()
	desc = lit ? "A large stone brick fireplace, warm and cozy." : initial(desc)


/obj/structure/fireplace/update_overlays()
	. = ..()

	if(!lit)
		return

	var/firepower

	switch(burn_time_remaining())
		if(0 to 500)
			firepower = "fireplace_fire0"
		if(501 to 1000)
			firepower = "fireplace_fire1"
		if(1001 to 1500)
			firepower = "fireplace_fire2"
		if(1501 to 2000)
			firepower = "fireplace_fire3"
		if(2001 to MAXIMUM_BURN_TIMER)
			firepower = "fireplace_fire4"

	. += "[firepower]"
	. += "fireplace_glow"


/obj/structure/fireplace/proc/adjust_light()
	if(!lit)
		set_light_on(FALSE)
		return

	switch(burn_time_remaining())
		if(0 to 500)
			set_light(1, ,"#ffb366")
		if(501 to 1000)
			set_light(2, ,"#ffb366")
		if(1001 to 1500)
			set_light(3, ,"#ffb366")
		if(1501 to 2000)
			set_light(4, ,"#ffb366")
		if(2001 to MAXIMUM_BURN_TIMER)
			set_light(6, ,"#ffb366")


/obj/structure/fireplace/process(seconds_per_tick)
	if(!lit)
		return
	if(world.time > flame_expiry_timer)
		put_out()
		return

	playsound(src, 'sound/effects/comfyfire.ogg',40,FALSE, FALSE, TRUE)
	var/turf/T = get_turf(src)
	T.hotspot_expose(700, 2.5 * seconds_per_tick)
	update_icon(UPDATE_OVERLAYS)
	adjust_light()


/obj/structure/fireplace/extinguish()
	. = ..()
	if(lit)
		var/fuel = burn_time_remaining()
		flame_expiry_timer = 0
		put_out()
		adjust_fuel_timer(fuel)


/obj/structure/fireplace/proc/adjust_fuel_timer(amount)
	if(lit)
		flame_expiry_timer += amount
		if(burn_time_remaining() < MAXIMUM_BURN_TIMER)
			flame_expiry_timer = world.time + MAXIMUM_BURN_TIMER
	else
		fuel_added = clamp(fuel_added + amount, 0, MAXIMUM_BURN_TIMER)


/obj/structure/fireplace/proc/burn_time_remaining()
	if(lit)
		return max(0, flame_expiry_timer - world.time)
	else
		return max(0, fuel_added)


/obj/structure/fireplace/proc/ignite()
	lit = TRUE
	flame_expiry_timer = world.time + fuel_added
	fuel_added = 0
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	adjust_light()


/obj/structure/fireplace/proc/put_out()
	lit = FALSE
	update_appearance(UPDATE_OVERLAYS|UPDATE_DESC)
	adjust_light()


#undef LOG_BURN_TIMER
#undef PAPER_BURN_TIMER
#undef MAXIMUM_BURN_TIMER
