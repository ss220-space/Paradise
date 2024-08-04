#define POINT_TIME (2.5 SECONDS)
#define BUBBLE_TIME (4 SECONDS)


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
		create_point_bubble(pointed_atom)
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
 * pointed_atom - the atom at which being pointed
 */
/atom/movable/proc/create_point_bubble(atom/pointed_atom, include_arrow = TRUE)
	var/obj/effect/thought_bubble_effect = new

	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		thought_bubble_image,
		layer = POINT_LAYER,
		offset_spokesman = src,
		plane = POINT_PLANE,
		appearance_flags = KEEP_APART,
	)

	var/mutable_appearance/pointed_atom_appearance = new(pointed_atom.appearance)
	pointed_atom_appearance.blend_mode = BLEND_INSET_OVERLAY
	pointed_atom_appearance.plane = FLOAT_PLANE
	pointed_atom_appearance.layer = FLOAT_LAYER
	pointed_atom_appearance.pixel_x = 0
	pointed_atom_appearance.pixel_y = 0
	thought_bubble.overlays += pointed_atom_appearance

	var/hover_outline_index = pointed_atom.get_filter("hover_outline")
	if (!isnull(hover_outline_index))
		pointed_atom_appearance.filters.Cut(hover_outline_index, hover_outline_index + 1)

	thought_bubble.pixel_x = 16
	thought_bubble.pixel_y = 32
	thought_bubble.alpha = 200

	if(include_arrow)
		var/mutable_appearance/point_visual = mutable_appearance(
			'icons/mob/screen_gen.dmi',
			"arrow",
			thought_bubble.layer + 0.01
		)

		point_visual.pixel_y = 7
		thought_bubble.overlays += point_visual

	// vis_contents is used to preserve mouse opacity
	thought_bubble_effect.appearance = thought_bubble
	vis_contents += thought_bubble_effect
	LAZYADD(update_on_z, thought_bubble_effect)
	addtimer(CALLBACK(src, PROC_REF(clear_point_bubble), thought_bubble_effect), BUBBLE_TIME)

	thought_bubble_effect.alpha = 0
	animate(thought_bubble_effect, alpha = 255, time = 0.5 SECONDS, easing = EASE_OUT)
	animate(alpha = 255, time = BUBBLE_TIME - 1 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)


/atom/movable/proc/clear_point_bubble(obj/effect/thought_bubble)
	LAZYREMOVE(update_on_z, thought_bubble)
	qdel(thought_bubble)

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
	set category = "IC"

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

