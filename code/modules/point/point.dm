#define POINT_TIME (2.5 SECONDS)
#define BUBBLE_TIME (3 SECONDS)


/**
 * Point at an atom
 *
 * Intended to enable and standardise the pointing animation for all atoms
 *
 * Not intended as a replacement for the mob verb
 */
/atom/movable/proc/point_at(atom/pointed_atom)
	var/turf/source_turf = loc
	if(!isturf(source_turf))
		return

	if((pointed_atom in src) || (pointed_atom.loc in src))
		create_point_bubble_from_atom(pointed_atom)
		SEND_SIGNAL(src, COMSIG_MOB_POINTED, pointed_atom)
		return

	var/turf/pointed_turf = get_turf(pointed_atom)
	if(!pointed_turf)
		return

	SEND_SIGNAL(src, COMSIG_MOB_POINTED, pointed_atom)
	var/obj/visual = new /obj/effect/temp_visual/point(source_turf, invisibility)
	animate(visual, pixel_x = (pointed_turf.x - source_turf.x) * world.icon_size + pointed_atom.pixel_x, pixel_y = (pointed_turf.y - source_turf.y) * world.icon_size + pointed_atom.pixel_y, time = 0.5 SECONDS, easing = QUAD_EASING)


/**
 * Create a bubble pointing at a particular icon and icon state.
 * See args for create_point_bubble_from_atom.
 */
/atom/movable/proc/create_point_bubble(mutable_appearance/pointed_atom_appearance, include_arrow = TRUE)
	var/obj/effect/thought_bubble_effect = new

	pointed_atom_appearance.layer = POINT_LAYER
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0

	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		thought_bubble_image,
		layer = POINT_LAYER,
		appearance_flags = KEEP_APART,
	)

	thought_bubble.overlays += pointed_atom_appearance

	thought_bubble.pixel_x = 16
	thought_bubble.pixel_y = 32
	thought_bubble.alpha = 200
	thought_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	if(include_arrow)
		var/mutable_appearance/point_visual = mutable_appearance(
			'icons/mob/screen_gen.dmi',
			"arrow",
			layer = thought_bubble.layer,
		)
		point_visual.pixel_y = 7
		thought_bubble.overlays += point_visual
		thought_bubble.plane = POINT_PLANE

	// vis_contents is used to preserve mouse opacity
	thought_bubble_effect.appearance = thought_bubble
	vis_contents += thought_bubble_effect

	thought_bubble_effect.alpha = 0
	animate(thought_bubble_effect, alpha = 255, time = 0.5 SECONDS, easing = EASE_OUT)
	animate(alpha = 255, time = BUBBLE_TIME)
	animate(alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)

	QDEL_IN(thought_bubble_effect, BUBBLE_TIME + 1 SECONDS)


/**
 * Create a point bubble towards a given item.
 *
 * Arguments:
 * * pointed_atom - Atom to show in the bubble.
 * * include_arrow - If true, show an arrow pointing downwards.
 */
/atom/movable/proc/create_point_bubble_from_atom(atom/pointed_atom, include_arrow = TRUE)
	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)

	var/hover_outline_index = pointed_atom.get_filter("hover_outline")
	if(!isnull(hover_outline_index))
		pointed_atom_appearance.filters.Cut(hover_outline_index, hover_outline_index + 1)

	create_point_bubble(pointed_atom_appearance, include_arrow)


/**
 * Create a point bubble towards a given item, from an icon/icon state.
 *
 * Arguments:
 * * icon - Icon source for the bubble's icon.
 * * icon_state - Icon state for the bubble's icon.
 * * include_arrow - If true, show an arrow pointing downwards.
 */
/atom/movable/proc/create_point_bubble_from_icons(icon, icon_state, include_arrow = TRUE)
	var/mutable_appearance/pointed_atom_appearance = mutable_appearance(
		icon,
		icon_state,
	)
	create_point_bubble(pointed_atom_appearance, include_arrow)


/**
 * See above, this uses an uninstantiated path.
 */
/atom/movable/proc/create_point_bubble_from_path(atom/pointed_atom_path, include_arrow = TRUE)
	create_point_bubble_from_icons(initial(pointed_atom_path.icon), initial(pointed_atom_path.icon_state), include_arrow)


/obj/effect/temp_visual/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = POINT_LAYER
	plane = POINT_PLANE
	duration = POINT_TIME
	randomdir = FALSE


/obj/effect/temp_visual/point/Initialize(mapload, set_invis = 0)
	. = ..()
	invisibility = set_invis


/**
 * Point at an atom
 *
 * mob verbs are faster than object verbs. See
 * [this byond forum post](https://secure.byond.com/forum/?post=1326139&page=2#comment8198716)
 * for why this isn't atom/verb/pointed()
 *
 * note: ghosts can point, this is intended
 *
 * visible_message will handle invisibility properly
 *
 * Be noted, that this verb also serves as placeholder for "Object" tab.
 *
 * Removing it causes interface update lags with appearing/disappearing "Object"
 * tab when walking nearby "Object"-verbed things
 */
/mob/verb/pointed(atom/target as mob|obj|turf in view(client.view, src))
	set name = "Point To"
	set category = "Object"

	if(next_move >= world.time || !Master.current_runlevel) //No usage until subsystems initialized properly.
		return

	if(istype(target, /obj/effect/temp_visual/point))
		return

	changeNext_move(CLICK_CD_POINT)

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_pointed), target))


/**
 * Possibly delayed verb that finishes the pointing process starting in [/mob/verb/pointed()].
 * Either called immediately or in the tick after pointed() was called, as per the [DEFAULT_QUEUE_OR_CALL_VERB()] macro.
 */
/mob/proc/run_pointed(atom/target)
	if(target.loc in src) // Object is inside a container on the mob. It's not part of the verb's list since it's not in view and requires middle clicking.
		point_at(target)
		return TRUE

	if(client && !(target in view(client.maxview(), src)))
		return FALSE

	point_at(target)

	return TRUE


#undef POINT_TIME
#undef BUBBLE_TIME

