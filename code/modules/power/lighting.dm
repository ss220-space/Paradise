// The Lighting System
//
// Consists of light fixtures (/obj/machinery/light) and light tube/bulb items (/obj/item/light)

// status values shared between lighting fixtures and items
#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

#define STAGE_EMPTY 1
#define STAGE_WIRED 2
#define STAGE_COMPLETED 3

/**
  * # Light fixture frame
  *
  * Incomplete light tube fixture
  *
  * Becomes a [Light fixture] when completed
  */
/obj/machinery/light_construct
	name = "light fixture frame"
	desc = "A light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-stage1"
	anchored = TRUE
	layer = 5
	max_integrity = 200
	armor = list("melee" = 50, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	/// Construction stage (1 = Empty frame | 2 = Wired frame | 3 = Completed frame)
	var/stage = STAGE_EMPTY
	/// Light bulb type
	var/fixture_type = "tube"
	/// How many metal sheets get given after deconstruction
	var/sheets_refunded = 2
	/// Holder for the completed fixture
	var/obj/machinery/light/newlight = null


/obj/machinery/light_construct/Initialize(mapload, ndir, building)
	. = ..()
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/light_construct/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		switch(stage)
			if(STAGE_EMPTY)
				. += "<span class='notice'>It's an empty frame <b>bolted</b> to the wall. It needs to be <i>wired</i>.</span>"
			if(STAGE_WIRED)
				. += "<span class='notice'>The frame is <b>wired</b>, but the casing's cover is <i>unscrewed</i>.</span>"
			if(STAGE_COMPLETED)
				. += "<span class='notice'>The casing is <b>screwed</b> shut.</span>"


/obj/machinery/light_construct/update_icon_state()
	icon_state = (stage == STAGE_WIRED) ? "[fixture_type]-construct-stage2" : "[fixture_type]-construct-stage1"


/obj/machinery/light_construct/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	switch(stage)
		if(STAGE_EMPTY)
			to_chat(user, "<span class='notice'>You begin to dismantle [src].</span>")
			if(!I.use_tool(src, user, 30, volume = I.tool_volume))
				return
			new /obj/item/stack/sheet/metal(get_turf(loc), sheets_refunded)
			TOOL_DISMANTLE_SUCCESS_MESSAGE
			qdel(src)
		if(STAGE_WIRED)
			to_chat(user, "<span class='warning'>You have to remove the wires first.</span>")
		if(STAGE_COMPLETED)
			to_chat(user, "<span class='warning'>You have to unscrew the case first.</span>")


/obj/machinery/light_construct/wirecutter_act(mob/living/user, obj/item/I)
	if(stage != STAGE_WIRED)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	. = TRUE
	stage = STAGE_EMPTY
	update_icon(UPDATE_ICON_STATE)
	new /obj/item/stack/cable_coil(get_turf(loc), 1, TRUE, COLOR_RED)
	WIRECUTTER_SNIP_MESSAGE


/obj/machinery/light_construct/screwdriver_act(mob/living/user, obj/item/I)
	if(stage != STAGE_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	stage = STAGE_COMPLETED
	user.visible_message(
		span_notice("[user] has closed [src]'s casing."),
		span_notice("You have closed [src]'s casing."),
		span_italics("You hear a screwdriver."),
	)
	switch(fixture_type)
		if("tube")
			newlight = new /obj/machinery/light/built(loc)
		if("bulb")
			newlight = new /obj/machinery/light/small/built(loc)
	newlight.setDir(dir)
	transfer_fingerprints_to(newlight)
	qdel(src)


/obj/machinery/light_construct/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(iscoil(I))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(stage != STAGE_EMPTY)
			to_chat(user, span_warning("You cannot wire [src] right now."))
			return ATTACK_CHAIN_PROCEED
		var/cached_sound = coil.usesound
		if(!coil.use(1))
			to_chat(user, span_warning("You need at least one length of cable to wire [src]."))
			return ATTACK_CHAIN_PROCEED
		stage = STAGE_WIRED
		update_icon(UPDATE_ICON_STATE)
		playsound(loc, cached_sound, 50, TRUE)
		user.visible_message(
			span_notice("[user] has wired [src]."),
			span_notice("You have wired [src]."),
			span_italics("You hear a noise."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/light_construct/blob_act(obj/structure/blob/B)
	if(B && B.loc == loc && !QDELETED(src))
		qdel(src)


/obj/machinery/light_construct/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
	qdel(src)


/**
  * # Small light fixture frame
  *
  * Incomplete light bulb fixture
  *
  * Becomes a [Small light fixture] when completed
  */
/obj/machinery/light_construct/small
	name = "small light fixture frame"
	desc = "A small light fixture under construction."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-stage1"
	anchored = TRUE
	layer = 5
	stage = 1
	fixture_type = "bulb"
	sheets_refunded = 1


/**
  * # Light fixture
  *
  * The standard light tube fixture
  */
/obj/machinery/light
	name = "light fixture"
	icon = 'icons/obj/lighting.dmi'
	base_icon_state = "tube"
	icon_state = "tube1"
	desc = "A lighting fixture."
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	max_integrity = 100
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 20
	power_channel = LIGHT //Lights are calc'd via area so they dont need to be in the machine list
	/// Is the light on or off?
	var/on = FALSE
	/// If the light state has changed since the last 'update()', also update the power requirements
	var/light_state = FALSE
	/// How much power does it use?
	var/static_power_used = 0
	/// Light range (Also used in power calculation)
	var/brightness_range = 8
	/// Light intensity
	var/brightness_power = 1
	/// Light colour when on
	var/brightness_color = "#FFFFFF"
	/// Light fixture status (LIGHT_OK | LIGHT_EMPTY | LIGHT_BURNED | LIGHT_BROKEN)
	var/status = LIGHT_OK
	/// Is the light currently flickering?
	var/flickering = FALSE
	/// Was this light extinguished with an antag ability? Used to ovveride flicker events
	var/extinguished = FALSE

	/// Item type of the light bulb
	var/light_type = /obj/item/light/tube
	/// Type of light bulb that goes into the fixture
	var/fitting = "tube"
	/// How many times has the light been switched on/off? (This is used to calc the probability the light burns out)
	var/switchcount = 0
	/// Is the light rigged to explode?
	var/rigged = FALSE
	/// Materials the light is made of
	var/lightmaterials = list(MAT_GLASS=100)

	/// Currently in night shift mode?
	var/nightshift_enabled = FALSE
	/// Allowed to be switched to night shift mode?
	var/nightshift_allowed = TRUE
	/// Light range when in night shift mode
	var/nightshift_light_range = 8
	/// Light intensity when in night shift mode
	var/nightshift_light_power = 0.45
	/// The colour of the light while it's in night shift mode
	var/nightshift_light_color = "#FFDDCC"
	/// The colour of the light while it's in emergency mode
	var/bulb_emergency_colour = "#FF3232"

	/// If true, the light is in emergency mode
	var/emergency_mode = FALSE
	/// If true, the light swaps over to emergency colour
	var/fire_mode = FALSE
	/// If true, this light cannot ever have an emergency mode
	var/no_emergency = FALSE


/**
  * # Small light fixture
  *
  * The smaller light bulb fixture
  */
/obj/machinery/light/small
	icon_state = "bulb1"
	base_icon_state = "bulb"
	fitting = "bulb"
	brightness_range = 4
	brightness_color = "#a0a080"
	nightshift_light_range = 4
	desc = "A small lighting fixture."
	light_type = /obj/item/light/bulb

/obj/machinery/light/spot
	name = "spotlight"
	fitting = "large tube"
	light_type = /obj/item/light/tube/large
	brightness_range = 12
	brightness_power = 4

/obj/machinery/light/built/Initialize(mapload)
	status = LIGHT_EMPTY
	. = ..()

/obj/machinery/light/small/built/Initialize(mapload)
	status = LIGHT_EMPTY
	. = ..()

// create a new lighting fixture
/obj/machinery/light/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	if(A && !A.requires_power)
		on = TRUE

	if(dir == SOUTH)
		layer = ABOVE_ALL_MOB_LAYER

	LAZYADD(A.lights_cache, src)

	switch(fitting)
		if("tube")
			brightness_range = 8
			if(prob(2))
				break_light_tube(TRUE)
		if("bulb")
			brightness_range = 4
			brightness_color = "#a0a080"
			if(prob(5))
				break_light_tube(TRUE)
	update(FALSE, mapload ? FALSE : TRUE)


/obj/machinery/light/Destroy()
	var/area/A = get_area(src)
	if(A)
		on = FALSE
		LAZYREMOVE(A.lights_cache, src)
	return ..()


/obj/machinery/light/update_icon_state()
	switch(status)
		if(LIGHT_OK)
			if(emergency_mode || fire_mode)
				icon_state = "[base_icon_state]_emergency"
			else
				icon_state = "[base_icon_state][light_range == 0 ? FALSE : on]"
		if(LIGHT_EMPTY)
			icon_state = "[base_icon_state]-empty"
			on = FALSE
		if(LIGHT_BURNED)
			icon_state = "[base_icon_state]-burned"
			on = FALSE
		if(LIGHT_BROKEN)
			icon_state = "[base_icon_state]-broken"
			on = FALSE


/obj/machinery/light/update_overlays()
	. = ..()
	underlays.Cut()

	if(status != LIGHT_OK || !on)
		return
	if(nightshift_enabled || emergency_mode || fire_mode)
		underlays += emissive_appearance(icon, "[base_icon_state]_emergency_lightmask", src)
	else
		underlays += emissive_appearance(icon, "[base_icon_state]_lightmask", src)


/**
  * Updates the light's properties
  *
  * Updates the icon_state, luminosity, colour, and power usage of the light.
  * Also handles rigged light bulbs exploding.
  * Arguments:
  * * trigger - Should this update make the light explode/burn out? (Defaults to TRUE)
  * * play_sound - Will the lightbulb play a sound when it's turned on.
  */
/obj/machinery/light/proc/update(trigger = TRUE, play_sound = TRUE)
	var/area/current_area = get_area(src)
	UnregisterSignal(current_area, COMSIG_AREA_POWER_CHANGE)
	switch(status)
		if(LIGHT_BROKEN, LIGHT_BURNED, LIGHT_EMPTY)
			on = FALSE

	emergency_mode = FALSE
	if(fire_mode)
		set_emergency_lights()

	var/BR = nightshift_enabled ? nightshift_light_range : brightness_range
	var/PO = nightshift_enabled ? nightshift_light_power : brightness_power
	if(on)

		extinguished = FALSE
		var/CO = nightshift_enabled ? nightshift_light_color : brightness_color
		if(color)
			CO = color
		if(emergency_mode)
			BR = brightness_range
			PO = brightness_power
			CO = bulb_emergency_colour

		var/matching = light && BR == light.light_range && PO == light.light_power && CO == light.light_color
		if(!matching)
			switchcount++
			if(rigged)
				if(status == LIGHT_OK && trigger)
					log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")
					explode()
					return
			// Whichever number is smallest gets set as the prob
			// Each spook adds a 0.5% to 1% chance of burnout
			else if(prob(min(40, switchcount / 10)))
				if(status == LIGHT_OK && trigger)
					burnout()

			else
				use_power = ACTIVE_POWER_USE
				set_light(BR, PO, CO, l_on = on)

	else if(!turned_off())
		set_emergency_lights()
	else
		use_power = IDLE_POWER_USE
		set_light(0)

	update_icon()

	active_power_usage = (BR * PO * 10)
	if(on != light_state) // Light was turned on/off, so update the power usage
		light_state = on
		if(on)
			static_power_used = active_power_usage * 2 //20W per unit luminosity
			addStaticPower(static_power_used, CHANNEL_STATIC_LIGHT)
		else
			removeStaticPower(static_power_used, CHANNEL_STATIC_LIGHT)
	else
		if(on && (static_power_used != active_power_usage * 2))
			removeStaticPower(static_power_used, CHANNEL_STATIC_LIGHT)
			static_power_used = active_power_usage * 2
			addStaticPower(static_power_used, CHANNEL_STATIC_LIGHT)

	if(play_sound)
		playsound(src, 'sound/machines/light_on.ogg', 60, TRUE)


/obj/machinery/light/proc/burnout()
	status = LIGHT_BURNED

	visible_message("<span class='boldwarning'>[src] burns out!</span>")
	do_sparks(2, 1, src)

	on = FALSE
	set_light(0)
	update_icon()

// attempt to set the light's on/off status
// will not switch on if broken/burned/empty
/obj/machinery/light/proc/seton(S)
	on = (S && status == LIGHT_OK)
	update()

// examine verb
/obj/machinery/light/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		switch(status)
			if(LIGHT_OK)
				. += "<span class='notice'>It is turned [on ? "on" : "off"].</span>"
			if(LIGHT_EMPTY)
				. += "<span class='notice'>The [fitting] has been removed.</span>"
				. += "<span class='notice'>The casing can be <b>unscrewed</b>.</span>"
			if(LIGHT_BURNED)
				. += "<span class='notice'>The [fitting] is burnt out.</span>"
			if(LIGHT_BROKEN)
				. += "<span class='notice'>The [fitting] has been smashed.</span>"


// attack with item - insert light (if right type), otherwise try to break the light

/obj/machinery/light/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		if(light_hit_check(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	//Light replacer code
	if(istype(I, /obj/item/lightreplacer))
		add_fingerprint(user)
		var/obj/item/lightreplacer/lightreplacer = I
		lightreplacer.ReplaceLight(src, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	// attempt to insert a light
	if(istype(I, /obj/item/light))
		add_fingerprint(user)
		var/obj/item/light/new_light = I
		if(status != LIGHT_EMPTY)
			to_chat(user, span_warning("There is a [fitting] already inserted."))
			return ATTACK_CHAIN_PROCEED
		if(!istype(I, light_type))
			to_chat(user, span_warning("This type of light requires a [fitting]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_light, src))
			return ..()
		to_chat(user, span_notice("You have inserted [new_light] into [src]."))
		status = new_light.status
		switchcount = new_light.switchcount
		rigged = new_light.rigged
		brightness_range = new_light.brightness_range
		brightness_power = new_light.brightness_power
		brightness_color = new_light.brightness_color
		lightmaterials = new_light.materials
		on = has_power()
		update()
		qdel(new_light)
		if(on && rigged)
			log_admin("LOG: Rigged light explosion, last touched by [fingerprintslast]")
			message_admins("LOG: Rigged light explosion, last touched by [fingerprintslast]")
			explode()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(light_hit_check(I, user))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/// Special lights attack handling
/obj/machinery/light/proc/light_hit_check(obj/item/I, mob/living/user)
	if(status == LIGHT_EMPTY)
		if(has_power() && (I.flags & CONDUCT))
			add_fingerprint(user)
			do_sparks(3, 1, src)
			if(prob(75)) // If electrocuted
				electrocute_mob(user, get_area(src), src, rand(0.7, 1), TRUE)
				to_chat(user, span_userdanger("You have been electrocuted by [src]!"))
			else // If not electrocuted
				to_chat(user, span_danger("You stick [I] into the light socket."))
			return TRUE
		return FALSE
	if(status == LIGHT_BROKEN)
		return FALSE
	add_fingerprint(user)
	user.do_attack_animation(src)
	if(prob(1 + I.force * 5))
		user.visible_message(
			span_danger("[user] smashed the light!"),
			span_danger("You hit the light, and it smashes!"),
			span_italics("You hear the tinkle of breaking glass."),
		)
		if(on && (I.flags & CONDUCT) && prob(12))
			electrocute_mob(user, get_area(src), src, 0.3, TRUE)
		break_light_tube()
		return TRUE
	playsound(loc, 'sound/effects/glasshit.ogg', 75, TRUE)
	user.visible_message(
		span_danger("[user] hits the light."),
		span_danger("You hit the light."),
		span_italics("You hear someone hitting a glass."),
	)
	return TRUE


/obj/machinery/light/screwdriver_act(mob/living/user, obj/item/I)
	if(status != LIGHT_EMPTY)
		return TRUE

	I.play_tool_sound(src)
	user.visible_message("<span class='notice'>[user] opens [src]'s casing.</span>", \
		"<span class='notice'>You open [src]'s casing.</span>", "<span class='notice'>You hear a screwdriver.</span>")
	deconstruct()
	return TRUE


/obj/machinery/light/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/obj/machinery/light_construct/newlight = null
		var/cur_stage = 2
		if(!disassembled)
			cur_stage = 1
		switch(fitting)
			if("tube")
				newlight = new /obj/machinery/light_construct(loc)
				newlight.icon_state = "tube-construct-stage2"

			if("bulb")
				newlight = new /obj/machinery/light_construct/small(loc)
				newlight.icon_state = "bulb-construct-stage2"
		newlight.setDir(dir)
		newlight.stage = cur_stage
		if(!disassembled)
			newlight.obj_integrity = newlight.max_integrity * 0.5
			if(status != LIGHT_BROKEN)
				break_light_tube()
			if(status != LIGHT_EMPTY)
				drop_light_tube()
			new /obj/item/stack/cable_coil(loc, 1, "red")
		transfer_fingerprints_to(newlight)
	qdel(src)


/obj/machinery/light/proceed_attack_results(obj/item/I, mob/living/user, params, def_zone)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.) && (status == LIGHT_BROKEN || status == LIGHT_EMPTY) && on && (I.flags & CONDUCT) && prob(12))
		electrocute_mob(user, get_area(src), src, 0.3, TRUE)


/obj/machinery/light/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	if(. && !QDELETED(src))
		if(prob(damage_amount * 5))
			break_light_tube()

/obj/machinery/light/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			switch(status)
				if(LIGHT_EMPTY)
					playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE)
				if(LIGHT_BROKEN)
					playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 90, TRUE)
				else
					playsound(loc, 'sound/effects/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

// returns if the light has power /but/ is manually turned off
// if a light is turned off, it won't activate emergency power
/obj/machinery/light/proc/turned_off()
	var/area/A = get_area(src)
	return !A.lightswitch && A.power_light

// returns whether this light has power
// true if area has power and lightswitch is on
/obj/machinery/light/proc/has_power()
	var/area/A = get_area(src)
	return A.lightswitch && A.power_light

// attempts to set emergency lights
/obj/machinery/light/proc/set_emergency_lights()
	var/area/current_area = get_area(src)
	var/obj/machinery/power/apc/current_apc = current_area.get_apc()
	if(status != LIGHT_OK || !current_apc || flickering || no_emergency)
		emergency_lights_off(current_area, current_apc)
		return
	if(current_apc.emergency_lights || !current_apc.emergency_power)
		emergency_lights_off(current_area, current_apc)
		return
	if(fire_mode)
		set_light(nightshift_light_range, nightshift_light_power, bulb_emergency_colour, l_on = TRUE)
		update_icon()
		return
	emergency_mode = TRUE
	set_light(3, 1.7, bulb_emergency_colour, l_on = TRUE)
	update_icon()
	RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(update), override = TRUE)


/obj/machinery/light/proc/emergency_lights_off(area/current_area, obj/machinery/power/apc/current_apc)
	set_light(0, 0, 0) //you, sir, are off!
	if(current_apc)
		RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(update), override = TRUE)


/obj/machinery/light/flicker(amount = rand(20, 30))
	if(flickering)
		return FALSE

	if(!on || status != LIGHT_OK || emergency_mode)
		return FALSE

	flickering = TRUE
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/machinery/light, flicker_event), amount)

	return TRUE

/**
  * Flicker routine for the light.
  * Called by invoke_async so the parent proc can return immediately.
  */
/obj/machinery/light/proc/flicker_event(amount)
	if(on && status == LIGHT_OK)
		for(var/i = 0; i < amount; i++)
			if(status != LIGHT_OK || extinguished)
				break
			on = FALSE
			update(FALSE, FALSE)
			sleep(rand(1, 3))
			on = (status == LIGHT_OK)
			update(FALSE, FALSE)
			sleep(rand(1, 10))
		on = (status == LIGHT_OK && !extinguished)
		update(FALSE, FALSE)
	flickering = FALSE


// ai attack - toggle emergency lighting
/obj/machinery/light/attack_ai(mob/user)
	no_emergency = !no_emergency
	to_chat(user, "<span class='notice'>Emergency lights for this fixture have been [no_emergency ? "disabled" : "enabled"].</span>")
	update(FALSE)

// attack with hand - remove tube/bulb
// if hands aren't protected and the light is on, burn the player

/obj/machinery/light/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)

	if(status == LIGHT_EMPTY)
		to_chat(user, "<span class='warning'>There is no [fitting] in this light.</span>")
		return

	// make it burn hands if not wearing fire-insulated gloves
	if(on)
		var/prot = 0
		var/mob/living/carbon/human/H = user

		if(istype(H))
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.max_heat_protection_temperature)
					prot = (G.max_heat_protection_temperature > 360)
		else
			prot = 1

		if(prot > 0 || HAS_TRAIT(user, TRAIT_RESIST_HEAT))
			to_chat(user, "<span class='notice'>You remove the light [fitting]</span>")
		else if(HAS_TRAIT(user, TRAIT_TELEKINESIS))
			to_chat(user, "<span class='notice'>You telekinetically remove the light [fitting].</span>")
		else
			if(user.a_intent == INTENT_DISARM || user.a_intent == INTENT_GRAB)
				to_chat(user, "<span class='warning'>You try to remove the light [fitting], but you burn your hand on it!</span>")
				H.apply_damage(5, BURN, def_zone = H.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
				return
			else
				to_chat(user, "<span class='notice'>You try to remove the light [fitting], but it's too hot to touch!</span>")
				return
	else
		to_chat(user, "<span class='notice'>You remove the light [fitting]</span>")
	// create a light tube/bulb item and put it in the user's hand
	drop_light_tube(user)

// break the light and make sparks if was on

/obj/machinery/light/proc/drop_light_tube(mob/user)
	if(status == LIGHT_EMPTY)
		return

	var/obj/item/light/L = new light_type()
	L.status = status
	L.rigged = rigged
	L.brightness_range = brightness_range
	L.brightness_power = brightness_power
	L.brightness_color = brightness_color
	L.materials = lightmaterials

	// light item inherits the switchcount, then zero it
	L.switchcount = switchcount
	switchcount = 0

	L.update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
	L.forceMove(loc)

	if(user) //puts it in our active hand
		L.add_fingerprint(user)
		user.put_in_active_hand(L, ignore_anim = FALSE)

	status = LIGHT_EMPTY
	update(FALSE, FALSE)
	return L


/obj/machinery/light/attack_tk(mob/user)
	if(status == LIGHT_EMPTY)
		to_chat(user, "There is no [fitting] in this light.")
		return

	to_chat(user, "You telekinetically remove the light [fitting].")
	// create a light tube/bulb item and put it in the user's hand
	var/obj/item/light/L = drop_light_tube()
	L.attack_tk(user)

/obj/machinery/light/proc/break_light_tube(skip_sound_and_sparks = FALSE, overloaded = FALSE)
	if(status == LIGHT_EMPTY || status == LIGHT_BROKEN)
		return

	if(!skip_sound_and_sparks)
		if(status == LIGHT_OK || status == LIGHT_BURNED)
			playsound(loc, 'sound/effects/glasshit.ogg', 75, 1)
		if(on || overloaded)
			do_sparks(3, 1, src)
	status = LIGHT_BROKEN
	update()

/obj/machinery/light/proc/fix()
	if(status == LIGHT_OK)
		return
	status = LIGHT_OK
	extinguished = FALSE
	on = TRUE
	update()

/obj/machinery/light/tesla_act(power, explosive = FALSE)
	if(explosive)
		explosion(loc,0,0,0,flame_range = 5, adminlog = 0)
	qdel(src)

// timed process
// use power

// called when area power state changes
/obj/machinery/light/power_change(forced = FALSE)
	var/area/A = get_area(src)
	if(A)
		seton(A.lightswitch && A.power_light)

// called when on fire

/obj/machinery/light/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(prob(max(0, exposed_temperature - 673)))   //0% at <400C, 100% at >500C
		break_light_tube()

// explode the light

/obj/machinery/light/proc/explode()
	var/turf/T = get_turf(loc)
	break_light_tube()	// break it first to give a warning
	sleep(2)
	explosion(T, 0, 0, 2, 2, cause = src)
	qdel(src)


/**
  * # Light item
  *
  * Parent type of light fittings (Light bulbs, light tubes)
  *
  * Will fit into empty [/obj/machinery/light] of the corresponding type
  */
/obj/item/light
	icon = 'icons/obj/lighting.dmi'
	force = 2
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	blocks_emissive = FALSE
	/// Light status (LIGHT_OK | LIGHT_BURNED | LIGHT_BROKEN)
	var/status = LIGHT_OK
	/// How many times has the light been switched on/off?
	var/switchcount = 0
	/// Materials the light is made of
	materials = list(MAT_GLASS=100)
	/// Is the light rigged to explode?
	var/rigged = FALSE
	/// Light range
	var/brightness_range = 2
	/// Light intensity
	var/brightness_power = 1
	/// Light colour
	var/brightness_color = null


/obj/item/light/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, force)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/light/proc/on_entered(datum/source, mob/living/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived) || arrived.incorporeal_move || (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	playsound(loc, 'sound/effects/glass_step.ogg', 50, TRUE)
	if(status == LIGHT_BURNED || status == LIGHT_OK)
		shatter()


/obj/item/light/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 1
	C.stored_comms["metal"] += 1
	qdel(src)
	return TRUE

/**
  * # Light Tube
  *
  * For use in an empty [/obj/machinery/light]
  */
/obj/item/light/tube
	name = "light tube"
	desc = "A replacement light tube."
	icon_state = "ltube"
	base_icon_state = "ltube"
	item_state = "c_tube"
	brightness_range = 8

/obj/item/light/tube/large
	w_class = WEIGHT_CLASS_SMALL
	name = "large light tube"
	brightness_range = 15
	brightness_power = 2

/**
  * # Light Bulb
  *
  * For use in an empty [/obj/machinery/light/small]
  */
/obj/item/light/bulb
	name = "light bulb"
	desc = "A replacement light bulb."
	icon_state = "lbulb"
	base_icon_state = "lbulb"
	item_state = "contvapour"
	brightness_range = 5
	brightness_color = "#a0a080"

/obj/item/light/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	shatter()

/obj/item/light/bulb/fire
	name = "fire bulb"
	desc = "A replacement fire bulb."
	icon_state = "flight"
	base_icon_state = "flight"
	item_state = "egg4"
	brightness_range = 5


/obj/item/light/New()
	..()
	switch(name)
		if("light tube")
			brightness_range = rand(6,9)
		if("light bulb")
			brightness_range = rand(4,6)
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)


/obj/item/light/update_icon_state()
	switch(status)
		if(LIGHT_OK)
			icon_state = base_icon_state
		if(LIGHT_BURNED)
			icon_state = "[base_icon_state]-burned"
		if(LIGHT_BROKEN)
			icon_state = "[base_icon_state]-broken"


/obj/item/light/update_desc(updates = ALL)
	. = ..()
	switch(status)
		if(LIGHT_OK)
			desc = "A replacement [name]."
		if(LIGHT_BURNED)
			desc = "A burnt-out [name]."
		if(LIGHT_BROKEN)
			desc = "A broken [name]."


/obj/item/light/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/syringe))
		add_fingerprint(user)
		var/obj/item/reagent_containers/syringe/syringe = I
		if(syringe.mode != 1)	// injecting
			to_chat(user, span_warning("The [syringe.name] should be in inject mode."))
			return ATTACK_CHAIN_PROCEED
		if(!syringe.reagents.total_volume)
			to_chat(user, span_warning("The [syringe.name] is empty."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have injected the solution into [src]."))
		if(syringe.reagents.has_reagent("plasma", 5) || syringe.reagents.has_reagent("plasma_dust", 5))
			rigged = TRUE
			log_admin("LOG: [key_name(user)] injected [src] with plasma, rigging it to explode.")
			message_admins("LOG: [key_name_admin(user)] injected [src] with plasma, rigging it to explode.")
		syringe.reagents.clear_reagents()
		syringe.update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/light/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		shatter()


/obj/item/light/attack_obj(obj/object, mob/living/user, params)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		shatter()


/obj/item/light/proc/shatter()
	. = FALSE
	if(status == LIGHT_OK || status == LIGHT_BURNED)
		visible_message("<span class='warning'>[src] shatters.</span>", "<span class='warning'>You hear a small glass object shatter.</span>")
		status = LIGHT_BROKEN
		force = 5
		sharp = TRUE
		playsound(loc, 'sound/effects/glasshit.ogg', 75, 1)
		update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)
		return TRUE


/obj/item/light/suicide_act(mob/living/carbon/human/user)
	user.visible_message("<span class=suicide>[user] touches [src], burning [user.p_their()] hands off!</span>", "<span class=suicide>You touch [src], burning your hands off!</span>")

	for(var/oname in list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		var/obj/item/organ/external/limb = user.get_organ(oname)
		if(limb)
			limb.droplimb(0, DROPLIMB_BURN)
	return FIRELOSS


/obj/machinery/light/extinguish_light(force = FALSE)
	var/was_on = on
	on = FALSE
	extinguished = TRUE
	emergency_mode = FALSE
	no_emergency = TRUE
	update(FALSE, was_on)
	addtimer(CALLBACK(src, PROC_REF(enable_emergency_lighting)), 5 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(was_on)
		visible_message(span_danger("[src] flickers and falls dark."))


/obj/machinery/light/proc/enable_emergency_lighting()
	visible_message(span_notice("[src]'s emergency lighting flickers back to life."))
	extinguished = FALSE
	no_emergency = FALSE
	update(FALSE)


#undef LIGHT_OK
#undef LIGHT_EMPTY
#undef LIGHT_BROKEN
#undef STAGE_EMPTY
#undef STAGE_WIRED
#undef STAGE_COMPLETED

