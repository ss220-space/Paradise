/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats."
	icon = 'icons/obj/coatrack.dmi'
	icon_state = "coatrack0"
	density = 1
	anchored = 1
	var/obj/item/clothing/suit/coat
	var/static/list/allowed = list(
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/suit/storage/blueshield,
		/obj/item/clothing/suit/leathercoat,
		/obj/item/clothing/suit/browntrenchcoat,
	)



/obj/structure/coatrack/Initialize(mapload)
	. = ..()
	icon_state = "coatrack[rand(0, 1)]"

/obj/structure/coatrack/attack_hand(mob/living/user)
	if(coat)
		add_fingerprint(user)
		user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src].")
		coat.forceMove_turf()
		user.put_in_active_hand(coat, ignore_anim = FALSE)
		coat = null
		update_icon(UPDATE_OVERLAYS)

/obj/structure/coatrack/attackby(obj/item/W, mob/living/user, params)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(W,T))
			can_hang = TRUE
			continue

	if(can_hang && !coat)
		add_fingerprint(user)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src].")
		coat = W
		user.drop_transfer_item_to_loc(W, src)
		update_icon(UPDATE_OVERLAYS)
	else
		return ..()

/obj/structure/coatrack/CanPass(atom/movable/mover, turf/target, height=0)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(mover,T))
			can_hang = TRUE
			continue

	if(can_hang && !coat)
		visible_message("[mover] lands on \the [src].")
		coat = mover
		coat.loc = src
		update_icon(UPDATE_OVERLAYS)
		return 0
	else
		return ..()


/obj/structure/coatrack/update_overlays()
	. = ..()

	if(!coat)
		return

	var/static/list/type2overlay = list(
		/obj/item/clothing/suit/storage/labcoat/cmo = "coat_cmo",
		/obj/item/clothing/suit/storage/labcoat/mad = "coat_mad",
		/obj/item/clothing/suit/storage/labcoat/genetics = "coat_gen",
		/obj/item/clothing/suit/storage/labcoat/chemist = "coat_chem",
		/obj/item/clothing/suit/storage/labcoat/virologist = "coat_vir",
		/obj/item/clothing/suit/storage/labcoat/science = "coat_sci",
		/obj/item/clothing/suit/storage/labcoat/mortician = "coat_mor",
		/obj/item/clothing/suit/storage/labcoat = "coat_lab",
		/obj/item/clothing/suit/storage/blueshield = "coat_det",
		/obj/item/clothing/suit/browntrenchcoat = "coat_brtrench",
		/obj/item/clothing/suit/leathercoat = "coat_leather",
	)

	var/coat_found = FALSE
	for(var/path in type2overlay)
		if(coat.type == path)	// we need to check type explicitly
			. += type2overlay[path]
			coat_found = TRUE
			break

	if(!coat_found)
		. += "coat_lab"


/obj/structure/coatrack/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/coatrack/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 10)

/obj/structure/coatrack/deconstruct(disassembled = FALSE)
	var/mat_drop = 2
	if(disassembled)
		mat_drop = 10
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	if(coat)
		coat.loc = get_turf(src)
		coat = null
	..()
