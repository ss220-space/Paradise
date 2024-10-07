/// The cooldown between visual alert animations.
#define SNAKE_ALERT_COOLDOWN (10 SECONDS)

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
	can_be_emaged = FALSE
	/// Current cardboard look provided by spray can painting.
	var/current_decal = ""
	/// How fast a mob can move inside this box.
	var/move_speed_multiplier = 1
	/// The cooldown timestamp used for alert animations.
	COOLDOWN_DECLARE(recently_alerted_cd)
	/// The cooldown timestamp used for movement.
	COOLDOWN_DECLARE(recently_moved_cd)


/obj/structure/closet/cardboard/relaymove(mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, recently_moved_cd) || !istype(user) || opened || user.incapacitated() || !isturf(loc) || !has_gravity())
		return
	var/turf/next_step = get_step(src, direction)
	if(!next_step)
		return

	// By default, while inside a box, we move at walk speed
	var/delay = CONFIG_GET(number/movedelay/walk_delay)
	// Also species speed mod is considered
	if(user.dna?.species.speed_mod)
		delay += user.dna.species.speed_mod
	// And finally the multipler of the box is applied
	delay *= move_speed_multiplier

	. = Move(next_step, direction)
	if(. && ISDIAGONALDIR(direction))
		delay *= sqrt(2)

	set_glide_size(DELAY_TO_GLIDE_SIZE(delay))
	COOLDOWN_START(src, recently_moved_cd, delay)


/obj/structure/closet/cardboard/open()
	if(opened || !can_open())
		return FALSE

	if(!COOLDOWN_FINISHED(src, recently_alerted_cd))
		return ..()

	var/list/viewing_clients = list()
	var/list/mobs_in_contents = list()
	for(var/mob/living/SNAKE in contents)
		if(SNAKE.client)
			viewing_clients += SNAKE.client
			mobs_in_contents += SNAKE

	if(!length(viewing_clients))
		return ..()

	var/list/all_viewers = viewers(src)
	var/list/conscious_viewers = list()
	for(var/mob/viewer as anything in all_viewers)
		if(viewer.client)
			viewing_clients += viewer.client
		if(!viewer.stat)
			conscious_viewers += viewer

	if(!length(conscious_viewers))
		return ..()

	COOLDOWN_START(src, recently_alerted_cd, SNAKE_ALERT_COOLDOWN)
	var/list/no_visual_alerts = (all_viewers - conscious_viewers) + mobs_in_contents
	for(var/mob/viewer as anything in (all_viewers + mobs_in_contents))
		viewer.playsound_local(viewer, 'sound/machines/chime.ogg', 25, FALSE)
		if(!(viewer in no_visual_alerts))
			do_alert_animation(viewer, viewing_clients)

	return ..()


/obj/structure/closet/cardboard/welder_act(mob/living/user, obj/item/I)
	return


/obj/structure/closet/cardboard/wirecutter_act(mob/living/user, obj/item/I)
	if(!opened)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return .
	new /obj/item/stack/sheet/cardboard(loc, 4)
	user.visible_message(
		span_notice("[src] has been cut apart by [user] with [I]"),
		span_notice("You cut [src] apart."),
		span_italics("You hear cutting."),
	)
	qdel(src)


/obj/structure/closet/cardboard/attackby(obj/item/I, mob/user, params)
	if(!opened || !istype(I, /obj/item/toy/crayon/spraycan))
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_fingerprint(user)
	var/obj/item/toy/crayon/spraycan/can = I
	if(can.capped)
		to_chat(user, span_warning("You need to toggle the cap off before repainting."))
		return .

	var/static/list/decal_collection = list(
		"Atmospherics", "Bartender", "Barber",
		"Blueshield", "Brig Physician", "Captain",
		"Cargo", "Chief Engineer",	"Chaplain",
		"Chef", "Chemist", "Civilian",
		"Clown", "CMO", "Coroner",
		"Detective", "Engineering", "Genetics",
		"HOP", "HOS", "Hydroponics",
		"Internal Affairs Agent", "Janitor", "Magistrate",
		"Mechanic", "Medical", "Mime",
		"Mining", "NT Representative", "Paramedic",
		"Pod Pilot", "Prisoner", "Research Director",
		"Security", "Syndicate", "Therapist",
		"Virology", "Warden", "Xenobiology",
	)
	var/new_decal = tgui_input_list(user, "Please select a decal", "Paint box", decal_collection)
	if(!new_decal)
		return .
	if(user.incapacitated())
		to_chat(user, span_warning("You're in no condition to perform this action."))
		return .
	if(can != user.get_active_hand())
		to_chat(user, span_warning("You must be holding [can] to perform this action."))
		return .
	if(!Adjacent(user))
		to_chat(user, span_warning("You have moved too far away from [src]."))
		return .
	new_decal = lowertext(replacetext(new_decal, " ", "_"))
	if(new_decal == current_decal)
		to_chat(user, span_warning("It looks like [src] is already painted this way."))
		return .

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	current_decal = new_decal
	update_icon()


/obj/structure/closet/cardboard/update_icon_state() //Not deriving, because of different logic.
	if(!opened)
		if(current_decal)
			icon_state = "cardboard_[current_decal]"
		else
			icon_state = "cardboard"
	else
		if(current_decal)
			icon_state = "cardboard_open_[current_decal]"
		else
			icon_state = "cardboard_open"


/obj/structure/closet/cardboard/update_overlays()
	. = list()


/proc/do_alert_animation(atom/source, list/passed_clients)
	if(!passed_clients)
		passed_clients = list()
		for(var/mob/viewer as anything in viewers(source))
			if(viewer.client)
				passed_clients += viewer.client
	var/image/image = image('icons/obj/cardboard_boxes.dmi', source, "cardboard_special", source.layer + 0.01)
	SET_PLANE_EXPLICIT(image, ABOVE_LIGHTING_PLANE, source)
	image.alpha = 0
	flick_overlay(image, passed_clients, 1.5 SECONDS)
	animate(image, pixel_z = 32, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	animate(alpha = 0, time = 0.3 SECONDS)


#undef SNAKE_ALERT_COOLDOWN

