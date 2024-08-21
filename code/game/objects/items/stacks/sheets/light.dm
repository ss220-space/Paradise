/obj/item/stack/light_w
	name = "wired glass tiles"
	gender = PLURAL
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	flags = CONDUCT
	max_amount = 60


/obj/item/stack/light_w/wirecutter_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	var/atom/drop_loc = drop_location()
	if(!use(1))
		return .
	var/obj/item/stack/cable_coil/coil = new(drop_loc, 5)
	coil.add_fingerprint(user)
	var/obj/item/stack/sheet/glass/glass = new(drop_loc)
	glass.add_fingerprint(user)


/obj/item/stack/light_w/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < 1)
			to_chat(user, span_warning("There is not enough [metal.name] sheets."))
			return ATTACK_CHAIN_PROCEED
		if(get_amount() < 1)
			to_chat(user, span_warning("There is not enough [name]."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/stack/tile/light/light = new(drop_location())
		to_chat(user, span_notice("You finished [light.name] construction."))
		light.add_fingerprint(user)
		metal.use(1)
		use(1)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

