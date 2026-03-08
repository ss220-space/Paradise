// This is distinct from /tg/ because of our space management system
// This is overriden in /atom/movable and the parent isn't called if the SMS wants to deal with it's init
/atom/proc/attempt_init(...)
	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			// we were deleted
			return

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Initialization][/atom/proc/Initialize] proc, mostly we run the preloader
 * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
 * result is that the Initialize proc is called.
 *
 */
/atom/New(loc, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)
	. = ..()
	attempt_init(arglist(args))
	if(SSdemo?.initialized)
		SSdemo.mark_new(src)

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for initialization in the base atom/New(),
 * After the map has loaded, then Initialize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initialize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being initialized during
 * the Atom subsystem initialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is initialized then
 * it's false.
 *
 * The mapload argument occupies the same position as loc when Initialize() is called by New().
 * loc will no longer be needed after it passed New(), and thus it is being overwritten
 * with mapload at the end of atom/New() before this proc (atom/Initialize()) is called.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initialized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/proc/Initialize]
 * * [/turf/simulated/space/proc/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	var/list/names = ru_names
	if(names && !GLOB.cached_ru_names[type])
		GLOB.cached_ru_names[type] = names
	ru_names = null

	if(flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags |= INITIALIZED

	SET_PLANE_IMPLICIT(src, plane)

	if(greyscale_config && greyscale_colors)
		update_greyscale()

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if(light_system == STATIC_LIGHT && light_power && light_range)
		update_light()

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_INITIALIZED_ON, src) // Used for poolcontroller / pool to improve performance greatly. However it also open up path to other usage of observer pattern on turfs.

	if(post_init_icon_state)
		icon_state = post_init_icon_state

	SETUP_SMOOTHING()

	ComponentInitialize()
	InitializeAIController()

	if(LAZYLEN(hud_possible))
		hud_possible = string_assoc_list(hud_possible)

	return INITIALIZE_HINT_NORMAL

/**
 * Late Initialization, for code that should run after all atoms have run Initialization
 *
 * To have your LateIntialize proc be called, your atoms [Initialization][/atom/proc/Initialize]
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD] otherwise it will never be called.
 *
 * useful for doing things like finding other machines on GLOB.machines because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Initialization
 * code has been run
 */
/atom/proc/LateInitialize()
	//set waitfor = FALSE
	//SHOULD_CALL_PARENT(FALSE)
	//stack_trace("[src] ([type]) called LateInitialize but has nothing on it!")
	return

// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return
