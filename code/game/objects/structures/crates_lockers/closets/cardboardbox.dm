/obj/structure/closet/cardboard
	name = "large cardboard box"
	desc = "Just a box..."
	icon = 'icons/obj/cardboard_boxes.dmi'
	icon_state = "cardboard"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	integrity_failure = 0
	open_sound = 'sound/machines/cardboard_box.ogg'
	close_sound = 'sound/machines/cardboard_box.ogg'
	open_sound_volume = 35
	close_sound_volume = 35
	material_drop = /obj/item/stack/sheet/cardboard
	no_overlays = TRUE
	var/decal = ""
	var/amt = 4
	var/move_delay = FALSE
	var/egged = 0
	/// How fast a mob can move inside this box.
	var/move_speed_multiplier = 1


/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(!istype(user) || opened || move_delay || user.incapacitated() || !isturf(loc) || !has_gravity(loc))
		return
	move_delay = TRUE
	var/oldloc = loc
	step(src, direction)
	// By default, while inside a box, we move at walk speed times the speed multipler of the box.
	var/delay = CONFIG_GET(number/walk_speed) * move_speed_multiplier
	if(direction & (direction - 1))
		delay *= SQRT_2 // Moving diagonal counts as moving 2 tiles, we need to slow them down accordingly.
	if(oldloc != loc)
		addtimer(VARSET_CALLBACK(src, move_delay, FALSE), delay)
	else
		move_delay = FALSE


/obj/structure/closet/cardboard/open()
	if(opened || !can_open())
		return FALSE
	if(!egged)
		var/mob/living/Snake = null
		for(var/mob/living/L in src.contents)
			Snake = L
			break
		if(Snake)
			var/list/alerted = viewers(7,src)
			if(alerted)
				for(var/mob/living/L in alerted)
					if(!L.stat)
						L.do_alert_animation(L)
						egged = 1
				SEND_SOUND(alerted, sound('sound/machines/chime.ogg'))
	return ..()

/mob/living/proc/do_alert_animation(atom/A)
	var/image/I
	I = image('icons/obj/cardboard_boxes.dmi', A, "cardboard_special", A.layer+1)
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I,viewing,8)
	I.alpha = 0
	animate(I, pixel_z = 32, alpha = 255, time = 5, easing = ELASTIC_EASING)

/obj/structure/closet/cardboard/welder_act()
	return

/obj/structure/closet/cardboard/attackby(obj/item/W as obj, mob/user as mob, params)
	if(src.opened)
		if(W.tool_behaviour == TOOL_WIRECUTTER)
			var/obj/item/wirecutters/WC = W
			new /obj/item/stack/sheet/cardboard(src.loc, amt)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WC].</span>", 3, "You hear cutting.", 2)
			qdel(src)
			return
		if(istype(W, /obj/item/toy/crayon/spraycan))
			var/obj/item/toy/crayon/spraycan/can = W
			if(can.capped)
				to_chat(user, span_warning("You need to toggle cap off before repainting."))
				return
			var/decalselection = tgui_input_list(user, "Please select a decal", "Paint box", list("Atmospherics", "Bartender", "Barber", "Blueshield",	"Brig Physician", "Captain",
			"Cargo", "Chief Engineer",	"Chaplain",	"Chef", "Chemist", "Civilian", "Clown", "CMO", "Coroner", "Detective", "Engineering", "Genetics", "HOP",
			"HOS", "Hydroponics", "Internal Affairs Agent", "Janitor",	"Magistrate", "Mechanic", "Medical", "Mime", "Mining", "NT Representative", "Paramedic", "Pod Pilot",
			"Prisoner",	"Research Director", "Security", "Syndicate", "Therapist", "Virology", "Warden", "Xenobiology"))
			if(!decalselection)
				return
			if(user.incapacitated())
				to_chat(user, "You're in no condition to perform this action.")
				return
			if(W != user.get_active_hand())
				to_chat(user, "You must be holding the pen to perform this action.")
				return
			if(!Adjacent(user))
				to_chat(user, "You have moved too far away from the cardboard box.")
				return
			add_fingerprint(user)
			decalselection = replacetext(decalselection, " ", "_")
			decalselection = lowertext(decalselection)
			decal = decalselection

			update_icon()

/obj/structure/closet/cardboard/update_icon_state() //Not deriving, because of different logic.
	if(!opened)
		if(decal)
			icon_state = "cardboard_" + decal
		else
			icon_state = "cardboard"
	else
		if(decal)
			icon_state = "cardboard_open_" + decal
		else
			icon_state = "cardboard_open"


/obj/structure/closet/cardboard/update_overlays()
	. = list()

