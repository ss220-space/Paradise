#define INTERCOM_BUILD_NO_CIRCUIT 0
#define INTERCOM_BUILD_CIRCUIT 1
#define INTERCOM_BUILD_WIRED 2
#define INTERCOM_BUILD_SECURED 3


/obj/item/radio/intercom
	name = "station intercom (General)"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = TRUE
	w_class = WEIGHT_CLASS_BULKY
	canhear_range = 2
	flags = CONDUCT
	blocks_emissive = FALSE
	var/circuitry_installed = TRUE
	/// Current buildstage of the object
	var/buildstage = INTERCOM_BUILD_NO_CIRCUIT
	dog_fashion = null


/obj/item/radio/intercom/custom
	name = "station intercom (Custom)"
	broadcasting = 0
	listening = 0

/obj/item/radio/intercom/interrogation
	name = "station intercom (Interrogation)"
	frequency  = AIRLOCK_FREQ

/obj/item/radio/intercom/private
	name = "station intercom (Private)"
	frequency = AI_FREQ

/obj/item/radio/intercom/command
	name = "station intercom (Command)"
	frequency = COMM_FREQ

/obj/item/radio/intercom/specops
	name = "\improper Special Operations intercom"
	frequency = ERT_FREQ

/obj/item/radio/intercom/department
	canhear_range = 5
	broadcasting = 0
	listening = 1

/obj/item/radio/intercom/department/medbay
	name = "station intercom (Medbay)"
	frequency = MED_I_FREQ

/obj/item/radio/intercom/department/security
	name = "station intercom (Security)"
	frequency = SEC_I_FREQ


/obj/item/radio/intercom/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	src.buildstage = buildstage
	if(buildstage)
		update_operating_status()
	else
		if(direction)
			setDir(direction)
			set_pixel_offsets_from_dir(28, -28, 28, -28)
		b_stat = TRUE
		on = FALSE
	GLOB.global_intercoms.Add(src)
	update_icon()


/obj/item/radio/intercom/department/medbay/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	internal_channels = GLOB.default_medbay_channels.Copy()


/obj/item/radio/intercom/department/security/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(SEC_I_FREQ) = list(ACCESS_SECURITY),
	)


/obj/item/radio/intercom/syndicate
	name = "illicit intercom"
	desc = "Talk through this. Evilly"
	frequency = SYND_FREQ
	syndiekey = new /obj/item/encryptionkey/syndicate/nukeops


/obj/item/radio/intercom/syndicate/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	internal_channels[num2text(SYND_FREQ)] = list(ACCESS_SYNDICATE)
	internal_channels[num2text(SYND_TAIPAN_FREQ)] = list(ACCESS_SYNDICATE)


/obj/item/radio/intercom/pirate
	name = "pirate radio intercom"
	desc = "You wouldn't steal a space shuttle. Piracy. It's a crime!"


/obj/item/radio/intercom/pirate/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	internal_channels.Cut()
	internal_channels = list(
		num2text(PUB_FREQ) = list(),
		num2text(AI_FREQ)  = list(),
		num2text(COMM_FREQ)= list(),
		num2text(ENG_FREQ) = list(),
		num2text(MED_FREQ) = list(),
		num2text(MED_I_FREQ)=list(),
		num2text(SEC_FREQ) = list(),
		num2text(SEC_I_FREQ)=list(),
		num2text(SCI_FREQ) = list(),
		num2text(SUP_FREQ) = list(),
		num2text(SRV_FREQ) = list()
	)

/obj/item/radio/intercom/Destroy()
	GLOB.global_intercoms.Remove(src)
	return ..()

/obj/item/radio/intercom/attack_ai(mob/user)
	add_hiddenprint(user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/attack_hand(mob/user)
	add_fingerprint(user)
	attack_self(user)

/obj/item/radio/intercom/receive_range(freq, level)
	if(!is_listening())
		return -1
	if(!(0 in level))
		var/turf/position = get_turf(src)
		// TODO: Integrate radio with the space manager
		if(isnull(position) || !(position.z in level))
			return -1
	if(freq in SSradio.ANTAG_FREQS)
		if(!(syndiekey))
			return -1//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/radio/intercom/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/tape_roll)) //eww
		return ATTACK_CHAIN_BLOCKED_ALL

	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(buildstage)
		if(INTERCOM_BUILD_NO_CIRCUIT)
			if(!istype(I, /obj/item/intercom_electronics))
				return ..()
			add_fingerprint(user)
			playsound(loc, I.usesound, 50, TRUE)
			to_chat(user, span_notice("You start to add a circuit board to the frame..."))
			if(!do_after(user, 1 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || buildstage != INTERCOM_BUILD_NO_CIRCUIT)
				return ATTACK_CHAIN_PROCEED
			if(!user.drop_transfer_item_to_loc(I, src))
				return ATTACK_CHAIN_PROCEED
			to_chat(user, span_notice("You insert a circuit board into the frame."))
			buildstage = INTERCOM_BUILD_CIRCUIT
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(INTERCOM_BUILD_CIRCUIT)
			if(!iscoil(I))
				return ..()
			add_fingerprint(user)
			var/obj/item/stack/cable_coil/coil = I
			if(coil.get_amount() < 5)
				to_chat(user, span_warning("You need five lengths of cable to wire the frame."))
				return ATTACK_CHAIN_PROCEED
			playsound(loc, coil.usesound, 50, TRUE)
			to_chat(user, span_notice("You start to add cables to the frame..."))
			if(!do_after(user, 2 SECONDS * coil.toolspeed, src, category = DA_CAT_TOOL) || buildstage != INTERCOM_BUILD_CIRCUIT || QDELETED(coil))
				return ATTACK_CHAIN_PROCEED
			if(!coil.use(5))
				to_chat(user, span_warning("At some point during construction you lost some cable. Make sure you have five lengths before trying again."))
				return ATTACK_CHAIN_PROCEED
			to_chat(user, span_notice("You added cables to the frame."))
			buildstage = INTERCOM_BUILD_WIRED
			return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/radio/intercom/crowbar_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_CIRCUIT)
		return FALSE
	. = TRUE
	to_chat(user,  span_notice("You begin removing the electronics..."))
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_CIRCUIT)
		return .
	new /obj/item/intercom_electronics(drop_location())
	to_chat(user,  span_notice("The circuit board pops out!"))
	buildstage = INTERCOM_BUILD_NO_CIRCUIT


/obj/item/radio/intercom/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_WIRED)
		return ..()
	. = TRUE
	if(!I.use_tool(src, user, 1 SECONDS, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_WIRED)
		return
	on = TRUE
	b_stat = FALSE
	buildstage = INTERCOM_BUILD_SECURED
	to_chat(user, span_notice("You secure the electronics!"))
	update_icon()
	update_operating_status()
	for(var/i = 1 to 5)
		wires.on_cut(i, TRUE)


/obj/item/radio/intercom/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_WIRED || b_stat || wires.is_all_cut())
		return ..()
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	WIRECUTTER_SNIP_MESSAGE
	new /obj/item/stack/cable_coil(drop_location(), 5)
	on = FALSE
	b_stat = TRUE
	buildstage = INTERCOM_BUILD_CIRCUIT
	update_icon()
	update_operating_status(FALSE)


/obj/item/radio/intercom/welder_act(mob/user, obj/item/I)
	if(buildstage != INTERCOM_BUILD_NO_CIRCUIT)
		return FALSE
	. = TRUE
	if(!I.tool_use_check(user, 3))
		return .
	to_chat(user, span_notice("You start slicing [src] from the wall..."))
	if(!I.use_tool(src, user, 1 SECONDS, amount = 3, volume = I.tool_volume) || buildstage != INTERCOM_BUILD_NO_CIRCUIT)
		return .
	to_chat(user,  span_notice("You cut [src] free from the wall!"))
	new /obj/item/mounted/frame/intercom(drop_location())
	qdel(src)


/obj/item/radio/intercom/update_icon_state()
	if(!circuitry_installed)
		icon_state="intercom-frame"
		return
	icon_state = "intercom[!on?"-p":""][b_stat ? "-open":""]"

/obj/item/radio/intercom/update_overlays()
	. = ..()
	underlays.Cut()
	if(on && buildstage == INTERCOM_BUILD_SECURED)
		underlays += emissive_appearance(icon, "intercom_lightmask", src)

/obj/item/radio/intercom/proc/update_operating_status(on = TRUE)
	var/area/current_area = get_area(src)
	if(!current_area)
		return
	if(on)
		RegisterSignal(current_area, COMSIG_AREA_POWER_CHANGE, PROC_REF(AreaPowerCheck))
	else
		UnregisterSignal(current_area, COMSIG_AREA_POWER_CHANGE)

/**
  * Proc called whenever the intercom's area loses or gains power. Responsible for setting the `on` variable and calling `update_icon()`.
  *
  * Normally called after the intercom's area recieves the `COMSIG_AREA_POWER_CHANGE` signal, but it can also be called directly.
  * Arguments:
  *
  * source - the area that just had a power change.
  */
/obj/item/radio/intercom/proc/AreaPowerCheck(datum/source)
	var/area/current_area = get_area(src)
	if(!current_area)
		on = FALSE
	else
		on = current_area.powered(EQUIP) // set "on" to the equipment power status of our area.
	update_icon()

/obj/item/intercom_electronics
	name = "intercom electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/radio/intercom/locked
	freqlock = TRUE

/obj/item/radio/intercom/locked/ai_private
	name = "\improper AI intercom"
	frequency = AI_FREQ

/obj/item/radio/intercom/locked/confessional
	name = "confessional intercom"
	frequency = 1480

/obj/item/radio/intercom/locked/prison
	name = "\improper prison intercom"
	desc = "Talk through this. It looks like it has been modified to not broadcast."


/obj/item/radio/intercom/locked/prison/Initialize(mapload, direction, buildstage = INTERCOM_BUILD_SECURED)
	. = ..()
	wires.cut(WIRE_RADIO_TRANSMIT)


#undef INTERCOM_BUILD_NO_CIRCUIT
#undef INTERCOM_BUILD_CIRCUIT
#undef INTERCOM_BUILD_WIRED
#undef INTERCOM_BUILD_SECURED

