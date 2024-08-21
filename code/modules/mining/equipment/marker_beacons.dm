/*****************Marker Beacons**************************/
GLOBAL_LIST_INIT(marker_beacon_colors, list(
"Random" = FALSE, //not a true color, will pick a random color
"Burgundy" = LIGHT_COLOR_FLARE,
"Bronze" = LIGHT_COLOR_ORANGE,
"Yellow" = LIGHT_COLOR_YELLOW,
"Lime" = LIGHT_COLOR_SLIME_LAMP,
"Olive" = LIGHT_COLOR_GREEN,
"Jade" = LIGHT_COLOR_BLUEGREEN,
"Teal" = LIGHT_COLOR_LIGHT_CYAN,
"Cerulean" = LIGHT_COLOR_BLUE,
"Indigo" = LIGHT_COLOR_DARK_BLUE,
"Purple" = LIGHT_COLOR_PURPLE,
"Violet" = LIGHT_COLOR_LAVENDER,
"Fuchsia" = LIGHT_COLOR_PINK))

/obj/item/stack/marker_beacon
	name = "marker beacon"
	singular_name = "marker beacon"
	desc = "Prism-brand path illumination devices. Used by miners to mark paths and warn of danger."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "marker"
	armor = list("melee" = 50, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 25, "acid" = 0)
	max_integrity = 50
	merge_type = /obj/item/stack/marker_beacon
	max_amount = 100
	var/picked_color = "random"

/obj/item/stack/marker_beacon/ten //miners start with 10 of these
	amount = 10

/obj/item/stack/marker_beacon/thirty //and they're bought in stacks of 1, 10, or 30
	amount = 30

/obj/item/stack/marker_beacon/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/stack/marker_beacon/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use in-hand to place a [singular_name].</span>"
	. += "<span class='notice'>Alt-click to select a color. Current color is [picked_color].</span>"

/obj/item/stack/marker_beacon/update_icon_state()
	icon_state = "[initial(icon_state)][lowertext(picked_color)]"

/obj/item/stack/marker_beacon/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You need more space to place a [singular_name] here.</span>")
		return
	if(locate(/obj/structure/marker_beacon) in user.loc)
		to_chat(user, "<span class='warning'>There is already a [singular_name] here.</span>")
		return
	if(use(1))
		to_chat(user, "<span class='notice'>You activate and anchor [amount ? "a":"the"] [singular_name] in place.</span>")
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		var/obj/structure/marker_beacon/M = new(user.loc, picked_color)
		transfer_fingerprints_to(M)

/obj/item/stack/marker_beacon/AltClick(mob/living/user)
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	var/input_color = tgui_input_list(user, "Choose a color.", "Beacon Color", GLOB.marker_beacon_colors)
	if(!istype(user) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	if(input_color)
		picked_color = input_color
		update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon
	name = "marker beacon"
	desc = "A Prism-brand path illumination device. It is anchored in place and glowing steadily."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "marker"
	layer = BELOW_OPEN_DOOR_LAYER
	armor = list("melee" = 50, "bullet" = 75, "laser" = 75, "energy" = 75, "bomb" = 25, "bio" = 100, "rad" = 100, "fire" = 25, "acid" = 0)
	max_integrity = 50
	anchored = TRUE
	light_range = 2
	light_power = 3
	var/remove_speed = 15
	var/picked_color

/obj/structure/marker_beacon/Initialize(mapload, set_color)
	. = ..()
	picked_color = set_color
	update_state()

/obj/structure/marker_beacon/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/obj/item/stack/marker_beacon/M = new(loc)
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
	qdel(src)

/obj/structure/marker_beacon/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to select a color. Current color is [picked_color].</span>"


/obj/structure/marker_beacon/update_icon_state()
	while(!picked_color || !GLOB.marker_beacon_colors[picked_color])
		picked_color = pick(GLOB.marker_beacon_colors)
	icon_state = "[initial(icon_state)][lowertext(picked_color)]-on"


/obj/structure/marker_beacon/proc/update_state()
	update_icon(UPDATE_ICON_STATE)
	set_light(light_range, light_power, GLOB.marker_beacon_colors[picked_color])


/obj/structure/marker_beacon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	to_chat(user, "<span class='notice'>You start picking [src] up...</span>")
	if(do_after(user, remove_speed, src))
		var/obj/item/stack/marker_beacon/M = new(drop_location())
		M.picked_color = picked_color
		M.update_icon(UPDATE_ICON_STATE)
		transfer_fingerprints_to(M)
		user.put_in_hands(M, ignore_anim = FALSE)
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)


/obj/structure/marker_beacon/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/marker_beacon) && I != src)
		add_fingerprint(user)
		var/obj/item/stack/marker_beacon/beacon = I
		if(beacon.amount >= beacon.max_amount)
			to_chat(user, span_warning("The [name] is full."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You start picking [src] up..."))
		if(!do_after(user, remove_speed, src) || beacon.amount >= beacon.max_amount)
			return ATTACK_CHAIN_PROCEED
		beacon.add(1)
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/marker_beacon/AltClick(mob/living/user)
	..()
	if(!istype(user) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	var/input_color = tgui_input_list(user, "Choose a color.", "Beacon Color", GLOB.marker_beacon_colors)
	if(!istype(user) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || ui_status(user, GLOB.physical_state) != UI_INTERACTIVE)
		return
	if(input_color)
		picked_color = input_color
		update_state()
