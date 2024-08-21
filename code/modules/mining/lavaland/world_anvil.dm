/obj/structure/world_anvil
	name = "World Anvil"
	desc = "An anvil that is connected through lava reservoirs to the core of lavaland. Whoever was using this last was creating something powerful."
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	climbable = TRUE
	pass_flags = LETPASSTHROW
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// What is currently forging in source
	var/atom/movable/forging
	var/forge_charges = 0
	var/obj/item/gps/internal

/obj/item/gps/internal/world_anvil
	icon_state = null
	gpstag = "Tempered Signal"
	desc = "An ancient anvil rests at this location."
	invisibility = 100

/obj/structure/world_anvil/Initialize()
	. = ..()
	GLOB.anvils += src
	internal = new /obj/item/gps/internal/world_anvil(src)

/obj/structure/world_anvil/Destroy()
	QDEL_NULL(internal)
	GLOB.anvils -= src
	. = ..()

/obj/structure/world_anvil/update_icon_state()
	icon_state = forge_charges > 0 ? "anvil_a" : "anvil"


/obj/structure/world_anvil/update_overlays()
	. = ..()
	if(forging)
		. += forging.appearance


/obj/structure/world_anvil/proc/update_state()
	update_icon()
	if(forge_charges > 0)
		set_light(4,1,LIGHT_COLOR_ORANGE, l_on = TRUE)
	else
		set_light_on(FALSE)


/obj/structure/world_anvil/examine(mob/user)
	. = ..()
	. += span_info("It currently has [forge_charges] forge[forge_charges != 1 ? "s" : ""] remaining.")


/obj/structure/world_anvil/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	add_fingerprint(user)
	if(istype(I, /obj/item/twohanded/required/gibtonite))
		var/obj/item/twohanded/required/gibtonite/gibtonite = I
		if(forging)
			to_chat(user, span_warning("Someone is already using the World Anvil!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(gibtonite, src))
			return ..()
		forge_charges = forge_charges + gibtonite.quality
		to_chat(user, span_notice("You have placed the gibtonite on the World Anvil, and watch as the gibtonite melts into it. The World Anvil is now heated enough for <b>[forge_charges]</b> forge[forge_charges > 1 ? "s" : ""]."))
		qdel(gibtonite)
		update_state()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/gem/amber))
		var/obj/item/gem/amber/gem = I
		if(forging)
			to_chat(user, span_warning("Someone is already using the World Anvil!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(gem, src))
			return ..()
		forge_charges += 3
		to_chat(user, span_notice("You have placed the draconic amber on the World Anvil, and watch as amber melts into it. The World Anvil is now heated enough for [forge_charges] forge[forge_charges > 1 ? "s" : ""]."))
		qdel(gem)
		update_state()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(forge_charges <= 0)
		to_chat(user, span_warning("The World Anvil is not hot enough to be usable!"))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/magmite))
		if(forging)
			to_chat(user, span_warning("Someone is already using the World Anvil!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		forging = I
		update_icon(UPDATE_OVERLAYS)
		var/atom/drop_loc = drop_location()
		playsound(loc, 'sound/effects/anvil_start.ogg', 50)
		if(!do_after(user, 7 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop forging."), category = DA_CAT_TOOL))
			forging = null
			I.forceMove(drop_loc)
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED
		forging = null
		to_chat(user, span_notice("You have carefully forged the rough plasma magmite into plasma magmite upgrade parts."))
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		var/obj/item/magmite_parts/parts = new(drop_loc)
		parts.add_fingerprint(user)
		qdel(I)
		forge_charges--
		update_state()
		if(forge_charges <= 0)
			visible_message(span_info("The World Anvil cools down."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/magmite_parts))
		var/obj/item/magmite_parts/parts = I
		if(!parts.inert)
			to_chat(user, span_warning("The magmite upgrade parts are already glowing and usable!"))
			return ATTACK_CHAIN_PROCEED
		if(forging)
			to_chat(user, span_warning("Someone is already using the World Anvil!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(parts, src))
			return ..()
		forging = parts
		update_icon(UPDATE_OVERLAYS)
		var/atom/drop_loc = drop_location()
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		if(!do_after(user, 3 SECONDS, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop forging."), category = DA_CAT_TOOL))
			forging = null
			parts.forceMove(drop_loc)
			update_icon(UPDATE_OVERLAYS)
			return ATTACK_CHAIN_PROCEED
		forging = null
		to_chat(user, span_notice("You have successfully reheat the magmite upgrade parts. They are now glowing and usable again."))
		playsound(loc, 'sound/effects/anvil_end.ogg', 50)
		parts.forceMove(drop_loc)
		parts.restore()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	to_chat(user, span_warning("You have no idea what to forge with [I]!"))
	return ATTACK_CHAIN_PROCEED

