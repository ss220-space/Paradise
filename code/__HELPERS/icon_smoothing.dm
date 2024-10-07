
//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an image associated to it; the tile is then overlayed by these 4 images
	To use this, just set your atom's 'smooth' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'canSmoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (see 'smooth_wall.dmi' for a template) and
	to add the 'SMOOTH_DIAGONAL' flag to the atom's smooth var (in addition to either SMOOTH_TRUE or SMOOTH_MORE).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
	not set properly, the underlay will default to regular floor plating.

	To see an example of a diagonal wall, see '/turf/simulated/wall/shuttle' and its subtypes.
*/

//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define N_NORTH	2
#define N_SOUTH	4
#define N_EAST	16
#define N_WEST	256
#define N_NORTHEAST	32
#define N_NORTHWEST	512
#define N_SOUTHEAST	64
#define N_SOUTHWEST	1024

#define NULLTURF_BORDER 123456789

#define DEFAULT_UNDERLAY_ICON 			'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE 	"plating"
#define DEFAULT_UNDERLAY_IMAGE			image(DEFAULT_UNDERLAY_ICON, DEFAULT_UNDERLAY_ICON_STATE)

GLOBAL_LIST_INIT(adjacent_direction_lookup, generate_adjacent_directions())

/atom/var/smooth = NONE
/atom/var/top_left_corner
/atom/var/top_right_corner
/atom/var/bottom_left_corner
/atom/var/bottom_right_corner
/atom/var/list/canSmoothWith = null
/atom/var/list/smoothing_groups = null
/atom/var/smoothing_junction = null //This starts as null for us to know when it's first set, but after that it will hold a 8-bit mask ranging from 0 to 255.
/turf/var/list/fixed_underlay = null

/proc/generate_adjacent_directions()
	// Have to hold all conventional dir pairs, so we size to the largest
	// We don't HAVE diagonal border objects, so I'm gonna pretend they'll never exist

	// You might be like, lemon, can't we use GLOB.cardinals/GLOB.alldirs here
	// No, they aren't loaded yet. life is pain
	var/list/cardinals = list(NORTH, SOUTH, EAST, WEST)
	var/list/alldirs = cardinals + list(NORTH|EAST, SOUTH|EAST, NORTH|WEST, SOUTH|WEST)
	var/largest_cardinal = max(cardinals)
	var/largest_dir = max(alldirs)

	var/list/direction_map = new /list(largest_cardinal)
	for(var/dir in cardinals)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)
		var/opposite = REVERSE_DIR(dir)
		// Need to encode diagonals here because it's possible, even if it is always false
		var/list/acceptable_adjacents = new /list(largest_dir)
		// Alright, what directions are acceptable to us
		for(var/connectable_dir in (cardinals + NONE))
			// And what border objects INSIDE those directions are alright
			var/list/smoothable_dirs = new /list(largest_cardinal + 1) // + 1 because we need to provide space for NONE to be a valid index
			// None is fine, we want to smooth with things on our own turf
			// We'll do the two dirs to our left and right
			// They connect.. "below" us and on their side
			if(connectable_dir == NONE)
				smoothable_dirs[left] = dir_to_junction(opposite | left)
				smoothable_dirs[right] = dir_to_junction(opposite | right)
			// If it's to our right or left we'll include just the dir matching ours
			// Left edge touches only our left side, and so on
			else if (connectable_dir == left)
				smoothable_dirs[dir] = left
			else if (connectable_dir == right)
				smoothable_dirs[dir] = right
			// If it's straight on we'll include our direction as a link
			// Then include the two edges on the other side as diagonals
			else if(connectable_dir == dir)
				smoothable_dirs[opposite] = dir
				smoothable_dirs[left] = dir_to_junction(dir | left)
				smoothable_dirs[right] = dir_to_junction(dir | right)
			// otherwise, go HOME, I don't want to encode anything for you
			else
				continue
			acceptable_adjacents[connectable_dir + 1] = smoothable_dirs
		direction_map[dir] = acceptable_adjacents
	return direction_map

/proc/dir_to_junction(dir)
	switch(dir)
		if(NORTH)
			return NORTH_JUNCTION
		if(SOUTH)
			return SOUTH_JUNCTION
		if(WEST)
			return WEST_JUNCTION
		if(EAST)
			return EAST_JUNCTION
		if(NORTHWEST)
			return NORTHWEST_JUNCTION
		if(NORTHEAST)
			return NORTHEAST_JUNCTION
		if(SOUTHEAST)
			return SOUTHEAST_JUNCTION
		if(SOUTHWEST)
			return SOUTHWEST_JUNCTION
		else
			return NONE

/proc/calculate_adjacencies(atom/A)
	if(!A.loc)
		return 0

	var/adjacencies = 0

	var/atom/movable/AM
	if(ismovable(A))
		AM = A
		if(AM.can_be_unanchored && !AM.anchored)
			return 0

	for(var/direction in GLOB.cardinal)
		AM = find_type_in_direction(A, direction)
		if(AM == NULLTURF_BORDER)
			if((A.smooth & SMOOTH_BORDER))
				adjacencies |= 1 << direction
		else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
			adjacencies |= 1 << direction

	if(adjacencies & N_NORTH)
		if(adjacencies & N_WEST)
			AM = find_type_in_direction(A, NORTHWEST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_NORTHWEST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_NORTHWEST
		if(adjacencies & N_EAST)
			AM = find_type_in_direction(A, NORTHEAST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_NORTHEAST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_NORTHEAST

	if(adjacencies & N_SOUTH)
		if(adjacencies & N_WEST)
			AM = find_type_in_direction(A, SOUTHWEST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_SOUTHWEST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_SOUTHWEST
		if(adjacencies & N_EAST)
			AM = find_type_in_direction(A, SOUTHEAST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_SOUTHEAST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_SOUTHEAST

	return adjacencies

/// Are two atoms border adjacent, takes a border object, something to compare against, and the direction between A and B
/// Returns the way in which the first thing is adjacent to the second
#define CAN_DIAGONAL_SMOOTH(border_obj, target, direction) (\
	(target.smooth & SMOOTH_BORDER_OBJECT) ? \
		GLOB.adjacent_direction_lookup[border_obj.dir][direction + 1]?[target.dir] : \
		(GLOB.adjacent_direction_lookup[border_obj.dir][direction + 1]) ? REVERSE_DIR(direction) : NONE \
	)

//do not use, use queue_smooth(atom)
/proc/smooth_icon(atom/A)
	if(!A || !A.smooth || !A.z)
		return
	if(QDELETED(A))
		return
	if(A.smooth & (SMOOTH_TRUE | SMOOTH_MORE))
		var/adjacencies = calculate_adjacencies(A)

		if(A.smooth & SMOOTH_DIAGONAL)
			A.diagonal_smooth(adjacencies)
		else
			cardinal_smooth(A, adjacencies)

	else if(A.smooth & SMOOTH_BITMASK)
		A.bitmask_smooth()
	if(isturf(A))
		SSdemo.mark_turf(A)

/atom/proc/bitmask_smooth()
	var/new_junction = NONE

	// cache for sanic speed
	var/canSmoothWith = src.canSmoothWith

	var/smooth_border = (smooth & SMOOTH_BORDER)
	var/smooth_obj = (smooth & SMOOTH_OBJ)
	var/border_object_smoothing = (smooth & SMOOTH_BORDER_OBJECT)

	// Did you know you can pass defines into other defines? very handy, lets take advantage of it here to allow 0 cost variation
	#define SEARCH_ADJ_IN_DIR(direction, direction_flag, ADJ_FOUND, WORLD_BORDER, BORDER_CHECK) \
		do { \
			var/turf/neighbor = get_step(src, direction); \
			if(neighbor && ##BORDER_CHECK(neighbor, direction)) { \
				var/neighbor_smoothing_groups = neighbor.smoothing_groups; \
				if(neighbor_smoothing_groups) { \
					for(var/target in canSmoothWith) { \
						if(canSmoothWith[target] & neighbor_smoothing_groups[target]) { \
							##ADJ_FOUND(neighbor, direction, direction_flag); \
						} \
					} \
				} \
				if(smooth_obj) { \
					for(var/atom/movable/thing as anything in neighbor) { \
						var/thing_smoothing_groups = thing.smoothing_groups; \
						if(!thing.anchored || isnull(thing_smoothing_groups) || !##BORDER_CHECK(thing, direction)) { \
							continue; \
						}; \
						for(var/target in canSmoothWith) { \
							if(canSmoothWith[target] & thing_smoothing_groups[target]) { \
								##ADJ_FOUND(thing, direction, direction_flag); \
							} \
						} \
					} \
				} \
			} else if (smooth_border) { \
				##WORLD_BORDER(null, direction, direction_flag); \
			} \
		} while(FALSE) \

	#define BITMASK_FOUND(target, direction, direction_flag) \
		new_junction |= direction_flag; \
		break set_adj_in_dir; \
	/// Check that non border objects use to smooth against border objects
	/// Returns true if the smooth is acceptable, FALSE otherwise
	#define BITMASK_ON_BORDER_CHECK(target, direction) (!(target.smooth & SMOOTH_BORDER_OBJECT) || CAN_DIAGONAL_SMOOTH(target, src, REVERSE_DIR(direction)))

	#define BORDER_FOUND(target, direction, direction_flag) new_junction |= CAN_DIAGONAL_SMOOTH(src, target, direction)
	// Border objects require an object as context, so we need a dummy. I'm sorry
	#define WORLD_BORDER_FOUND(target, direction, direction_flag) \
		var/static/atom/dummy; \
		if(!dummy) { \
			dummy = new(); \
			dummy.smooth &= ~SMOOTH_BORDER_OBJECT; \
		} \
		BORDER_FOUND(dummy, direction, direction_flag);
	// Handle handle border on border checks. no-op, we handle this check inside CAN_DIAGONAL_SMOOTH
	#define BORDER_ON_BORDER_CHECK(target, direction) (TRUE)

	// We're building 2 different types of smoothing searches here
	// One for standard bitmask smoothing (We provide a label so our macro can eary exit, as it wants to do)
	#define SET_ADJ_IN_DIR(direction, direction_flag) do { set_adj_in_dir: { SEARCH_ADJ_IN_DIR(direction, direction_flag, BITMASK_FOUND, BITMASK_FOUND, BITMASK_ON_BORDER_CHECK) }} while(FALSE)
	// and another for border object work (Doesn't early exit because we can hit more then one direction by checking the same turf)
	#define SET_BORDER_ADJ_IN_DIR(direction) SEARCH_ADJ_IN_DIR(direction, direction, BORDER_FOUND, WORLD_BORDER_FOUND, BORDER_ON_BORDER_CHECK)

	// Let's go over all our cardinals
	if(border_object_smoothing)
		SET_BORDER_ADJ_IN_DIR(NORTH)
		SET_BORDER_ADJ_IN_DIR(SOUTH)
		SET_BORDER_ADJ_IN_DIR(EAST)
		SET_BORDER_ADJ_IN_DIR(WEST)
		// We want to check against stuff in our own turf
		SET_BORDER_ADJ_IN_DIR(NONE)
		// Border objects don't do diagonals, so GO HOME
		set_smoothed_icon_state(new_junction)
		return

	SET_ADJ_IN_DIR(NORTH, NORTH)
	SET_ADJ_IN_DIR(SOUTH, SOUTH)
	SET_ADJ_IN_DIR(EAST, EAST)
	SET_ADJ_IN_DIR(WEST, WEST)

	// If there's nothing going on already
	if(!(new_junction & (NORTH|SOUTH)) || !(new_junction & (EAST|WEST)))
		set_smoothed_icon_state(new_junction)
		return

	if(new_junction & NORTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHWEST, NORTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHEAST, NORTHEAST_JUNCTION)

	if(new_junction & SOUTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHWEST, SOUTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHEAST, SOUTHEAST_JUNCTION)

	set_smoothed_icon_state(new_junction)

	#undef SET_BORDER_ADJ_IN_DIR
	#undef SET_ADJ_IN_DIR
	#undef BORDER_ON_BORDER_CHECK
	#undef WORLD_BORDER_FOUND
	#undef BORDER_FOUND
	#undef BITMASK_ON_BORDER_CHECK
	#undef BITMASK_FOUND
	#undef SEARCH_ADJ_IN_DIR

/atom/proc/set_smoothed_icon_state(new_junction)
	. = smoothing_junction
	smoothing_junction = new_junction
	icon_state = "[base_icon_state]-[smoothing_junction]"

/turf/simulated/wall/set_smoothed_icon_state(new_junction)
	// Avoid calling ..() here to avoid setting icon_state twice, which is expensive given how hot this proc is
	var/old_junction = smoothing_junction
	smoothing_junction = new_junction

	if (!(smooth & SMOOTH_DIAGONAL_CORNERS))
		icon_state = "[base_icon_state]-[smoothing_junction]"
		return

	switch(new_junction)
		if(
			NORTH_JUNCTION|WEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION,
			NORTH_JUNCTION|WEST_JUNCTION|NORTHWEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION|NORTHEAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION|SOUTHWEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION|SOUTHEAST_JUNCTION,
		)
			icon_state = "[base_icon_state]-[smoothing_junction]-d"
			if(new_junction == old_junction || fixed_underlay) // Mutable underlays?
				return

			var/junction_dir = reverse_ndir(smoothing_junction)
			var/turned_adjacency = REVERSE_DIR(junction_dir)
			var/turf/neighbor_turf = get_step(src, turned_adjacency & (NORTH|SOUTH))
			var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
			if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
				neighbor_turf = get_step(src, turned_adjacency & (EAST|WEST))

				if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
					neighbor_turf = get_step(src, turned_adjacency)

					if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
						if(!get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency)) //if all else fails, ask our own turf
							underlay_appearance.icon = DEFAULT_UNDERLAY_ICON
							underlay_appearance.icon_state = DEFAULT_UNDERLAY_ICON_STATE
			underlays += underlay_appearance
		else
			icon_state = "[base_icon_state]-[smoothing_junction]"


/atom/proc/diagonal_smooth(adjacencies)
	switch(adjacencies)
		if(N_NORTH|N_WEST)
			replace_smooth_overlays("d-se","d-se-0")
		if(N_NORTH|N_EAST)
			replace_smooth_overlays("d-sw","d-sw-0")
		if(N_SOUTH|N_WEST)
			replace_smooth_overlays("d-ne","d-ne-0")
		if(N_SOUTH|N_EAST)
			replace_smooth_overlays("d-nw","d-nw-0")

		if(N_NORTH|N_WEST|N_NORTHWEST)
			replace_smooth_overlays("d-se","d-se-1")
		if(N_NORTH|N_EAST|N_NORTHEAST)
			replace_smooth_overlays("d-sw","d-sw-1")
		if(N_SOUTH|N_WEST|N_SOUTHWEST)
			replace_smooth_overlays("d-ne","d-ne-1")
		if(N_SOUTH|N_EAST|N_SOUTHEAST)
			replace_smooth_overlays("d-nw","d-nw-1")

		else
			cardinal_smooth(src, adjacencies)
			return

	icon_state = ""
	return adjacencies

//only walls should have a need to handle underlays
/turf/simulated/wall/diagonal_smooth(adjacencies)
	adjacencies = reverse_ndir(..())
	if(adjacencies)
		// Drop posters which were previously placed on this wall.
		for(var/obj/structure/sign/poster/P in src)
			P.roll_and_drop(src)

/proc/cardinal_smooth(atom/A, adjacencies)
	//NW CORNER
	var/nw = "1-i"
	if((adjacencies & N_NORTH) && (adjacencies & N_WEST))
		if(adjacencies & N_NORTHWEST)
			nw = "1-f"
		else
			nw = "1-nw"
	else
		if(adjacencies & N_NORTH)
			nw = "1-n"
		else if(adjacencies & N_WEST)
			nw = "1-w"

	//NE CORNER
	var/ne = "2-i"
	if((adjacencies & N_NORTH) && (adjacencies & N_EAST))
		if(adjacencies & N_NORTHEAST)
			ne = "2-f"
		else
			ne = "2-ne"
	else
		if(adjacencies & N_NORTH)
			ne = "2-n"
		else if(adjacencies & N_EAST)
			ne = "2-e"

	//SW CORNER
	var/sw = "3-i"
	if((adjacencies & N_SOUTH) && (adjacencies & N_WEST))
		if(adjacencies & N_SOUTHWEST)
			sw = "3-f"
		else
			sw = "3-sw"
	else
		if(adjacencies & N_SOUTH)
			sw = "3-s"
		else if(adjacencies & N_WEST)
			sw = "3-w"

	//SE CORNER
	var/se = "4-i"
	if((adjacencies & N_SOUTH) && (adjacencies & N_EAST))
		if(adjacencies & N_SOUTHEAST)
			se = "4-f"
		else
			se = "4-se"
	else
		if(adjacencies & N_SOUTH)
			se = "4-s"
		else if(adjacencies & N_EAST)
			se = "4-e"

	var/list/New = list()

	if(A.top_left_corner != nw)
		A.cut_overlay(A.top_left_corner)
		A.top_left_corner = nw
		New += nw

	if(A.top_right_corner != ne)
		A.cut_overlay(A.top_right_corner)
		A.top_right_corner = ne
		New += ne

	if(A.bottom_right_corner != sw)
		A.cut_overlay(A.bottom_right_corner)
		A.bottom_right_corner = sw
		New += sw

	if(A.bottom_left_corner != se)
		A.cut_overlay(A.bottom_left_corner)
		A.bottom_left_corner = se
		New += se

	if(New.len)
		A.add_overlay(New)


/proc/find_type_in_direction(atom/source, direction)
	var/turf/target_turf = get_step(source, direction)
	if(!target_turf)
		return NULLTURF_BORDER

	if(source.canSmoothWith)
		var/atom/A
		if(source.smooth & SMOOTH_MORE)
			for(var/a_type in source.canSmoothWith)
				if( istype(target_turf, a_type) )
					return target_turf
				A = locate(a_type) in target_turf
				if(A)
					return A
			return null

		for(var/a_type in source.canSmoothWith)
			if(a_type == target_turf.type)
				return target_turf
			A = locate(a_type) in target_turf
			if(A && A.type == a_type)
				return A
		return null
	else
		if(isturf(source))
			return source.type == target_turf.type ? target_turf : null
		var/atom/A = locate(source.type) in target_turf
		return A && A.type == source.type ? A : null

//Icon smoothing helpers

/proc/smooth_zlevel(var/zlevel, now = FALSE)
	var/list/away_turfs = block(1, 1, zlevel, world.maxx, world.maxy, zlevel)
	for(var/V in away_turfs)
		var/turf/T = V
		if(T.smooth)
			if(now)
				smooth_icon(T)
			else
				queue_smooth(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				if(now)
					smooth_icon(A)
				else
					queue_smooth(A)

/atom/proc/clear_smooth_overlays()
	cut_overlay(top_left_corner)
	top_left_corner = null
	cut_overlay(top_right_corner)
	top_right_corner = null
	cut_overlay(bottom_right_corner)
	bottom_right_corner = null
	cut_overlay(bottom_left_corner)
	bottom_left_corner = null

/atom/proc/replace_smooth_overlays(nw, ne, sw, se)
	clear_smooth_overlays()
	var/list/O = list()
	top_left_corner = nw
	O += nw
	top_right_corner = ne
	O += ne
	bottom_left_corner = sw
	O += sw
	bottom_right_corner = se
	O += se

	add_overlay(O)

/proc/reverse_ndir(ndir)
	switch(ndir)
		if(NORTH_JUNCTION)
			return NORTH
		if(SOUTH_JUNCTION)
			return SOUTH
		if(WEST_JUNCTION)
			return WEST
		if(EAST_JUNCTION)
			return EAST
		if(NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTHEAST_JUNCTION)
			return SOUTHEAST
		if(SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(NORTH_JUNCTION | WEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION)
			return SOUTHEAST
		if(NORTH_JUNCTION | WEST_JUNCTION | NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION | NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION | SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION | SOUTHEAST_JUNCTION)
			return SOUTHEAST
		else
			return NONE

//SSicon_smooth
/proc/queue_smooth_neighbors(atom/A)
	for(var/V in orange(1,A))
		var/atom/T = V
		if(T.smooth)
			queue_smooth(T)

//SSicon_smooth
/proc/queue_smooth(atom/A)
	if(SSicon_smooth && A.smooth & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		SSicon_smooth.smooth_queue[A] = A
		SSicon_smooth.can_fire = 1

//Example smooth wall
/turf/simulated/wall/smooth
	name = "smooth wall"
	icon = 'icons/turf/smooth_wall.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE|SMOOTH_DIAGONAL|SMOOTH_BORDER
	canSmoothWith = null
