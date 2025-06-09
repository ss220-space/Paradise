// Camera mob, used by AI camera and blob.

/mob/camera
	name = "camera mob"
	density = FALSE
	move_force = INFINITY
	move_resist = INFINITY
	status_flags = NONE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_ABSTRACT  // No one can see us
	sight = SEE_SELF
	move_on_shuttle = 0

/mob/camera/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_GODMODE, INNATE_TRAIT)

/mob/camera/experience_pressure_difference()
	return

/mob/camera/forceMove(atom/destination)
	var/oldloc = loc
	loc = destination
	Moved(oldloc, NONE)

/mob/camera/move_up()
	set name = "Move Upwards"
	set category = "IC"

	if(zMove(UP, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move upwards."))

/mob/camera/move_down()
	set name = "Move Down"
	set category = "IC"

	if(zMove(DOWN, z_move_flags = ZMOVE_FEEDBACK))
		to_chat(src, span_notice("You move down."))

/mob/camera/zMove(dir, turf/target, z_move_flags = NONE)
	. = ..()
	if(.)
		setLoc(loc)

/mob/camera/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	z_move_flags |= ZMOVE_IGNORE_OBSTACLES  //cameras do not respect these FLOORS you speak so much of
	return ..()
