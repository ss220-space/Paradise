// Падежи русского языка
#define NOMINATIVE 1 // Именительный: кто это? Клоун и ассистуха
#define GENITIVE 2 // Родительный: откусить кусок от кого? От клоуна и ассистухи
#define DATIVE 3 // Дательный: дать полный доступ кому? Клоуну и ассистухе
#define ACCUSATIVE 4 // Винительный: обвинить кого? Клоуна и ассистуху
#define INSTRUMENTAL 5 // Творительный: возить по полу кем? Клоуном и ассистухой
#define PREPOSITIONAL 6 // Предложный: прохладная история о ком? О клоуне и об ассистухе

/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND
	var/level = 2
	var/flags = NONE
	var/flags_2 = NONE
	var/list/fingerprints
	var/list/fingerprints_time
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/list/blood_DNA
	var/blood_color
	var/last_bumped = 0
	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.
	var/simulated = TRUE //filter for actions - used by lighting overlays
	var/atom_say_verb = "says"
	var/bubble_icon = "default" ///what icon the mob uses for speechbubbles
	var/bubble_emote_icon = "emote" ///what icon the mob uses for emotebubbles
	var/dont_save = FALSE // For atoms that are temporary by necessity - like lighting overlays

	/// pass_flags that we are. If any of this matches a pass_flag on a moving thing, by default, we let them through.
	var/pass_flags_self = NONE
	/// Things we can pass through while moving. If any of this matches the thing we're trying to pass's [pass_flags_self], then we can pass through.
	var/pass_flags = NONE

	///Chemistry.
	var/container_type = NONE
	var/datum/reagents/reagents = null

	///Default pixel x shifting for the atom's icon.
	var/base_pixel_x = 0
	///Default pixel y shifting for the atom's icon.
	var/base_pixel_y = 0

	//This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list
	//HUD images that this atom can provide.
	var/list/hud_possible

	//Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	//Detective Work, used for the duplicate data points kept in the scanners
	var/list/original_atom

	//Detective Work, used for allowing a given atom to leave its fibers on stuff. Allowed by default
	var/can_leave_fibers = TRUE

	var/allow_spin = TRUE //Set this to 1 for a _target_ that is being thrown at; if an atom has this set to 1 then atoms thrown AT it will not spin; currently used for the singularity. -Fox

	var/admin_spawned = FALSE	//was this spawned by an admin? used for stat tracking stuff.

	var/initialized = FALSE

	///overlays managed by [update_overlays][/atom/proc/update_overlays] to prevent removing overlays that weren't added by the same proc. Single items are stored on their own, not in a list.
	var/list/managed_overlays

	var/list/atom_colours	 //used to store the different colors on an atom
						//its inherent color, the colored paint applied on it, special color effect etc...

	/// Last name used to calculate a color for the chatmessage overlays. Used for caching.
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays. Used for caching.
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened
	/// Список склонений названия атома. Пример заполнения в любом наследнике атома
	/// ru_names = list(NOMINATIVE = "челюсти жизни", GENITIVE = "челюстей жизни", DATIVE = "челюстям жизни", ACCUSATIVE = "челюсти жизни", INSTRUMENTAL = "челюстями жизни", PREPOSITIONAL = "челюстях жизни")
	var/list/ru_names
	// Can it be drained of energy by ninja?
	var/drain_act_protected = FALSE
	///Used for changing icon states for different base sprites.
	var/base_icon_state

	var/tts_seed = "Arthas"

/atom/New(loc, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)
	. = ..()
	attempt_init(arglist(args))

// This is distinct from /tg/ because of our space management system
// This is overriden in /atom/movable and the parent isn't called if the SMS wants to deal with it's init
/atom/proc/attempt_init(...)
	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			// we were deleted
			return

//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize

/atom/proc/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(initialized)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	initialized = TRUE

	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if(light_power && light_range)
		update_light()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guranteed to be on afterwards anyways.

	if(loc)
		loc.InitializedOn(src) // Used for poolcontroller / pool to improve performance greatly. However it also open up path to other usage of observer pattern on turfs.

	ComponentInitialize()

	return INITIALIZE_HINT_NORMAL

//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	return

// Put your AddComponent() calls here
/atom/proc/ComponentInitialize()
	return

/atom/proc/InitializedOn(atom/A) // Proc for when something is initialized on a atom - Optional to call. Useful for observer pattern etc.
	return

/atom/proc/onCentcom()
	. = FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!is_admin_level(T.z))//if not, don't bother
		return

	//check for centcomm shuttles
	for(var/centcom_shuttle in list("emergency", "pod1", "pod2", "pod3", "pod4", "ferry"))
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(centcom_shuttle)
		if(T in M.areaInstance)
			return TRUE

	//finally check for centcom itself
	return istype(T.loc, /area/centcom)

/atom/proc/onSyndieBase()
	. = FALSE
	var/turf/T = get_turf(src)
	if(!T)
		return

	if(!is_admin_level(T.z))//if not, don't bother
		return

	if(istype(T.loc, /area/shuttle/syndicate_elite) || istype(T.loc, /area/syndicate_mothership))
		return TRUE

/atom/Destroy()
	if(alternate_appearances)
		for(var/aakey in alternate_appearances)
			var/datum/alternate_appearance/AA = alternate_appearances[aakey]
			qdel(AA)
		alternate_appearances = null

	QDEL_NULL(reagents)
	invisibility = INVISIBILITY_ABSTRACT
	LAZYCLEARLIST(overlays)

	QDEL_NULL(light)

	return ..()

//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir


/atom/proc/set_angle(degrees)
	var/matrix/M = matrix()
	M.Turn(degrees)
	// If we aint 0, make it NN transform
	if(degrees)
		appearance_flags |= PIXEL_SCALE
	transform = M


/*
	Sets the atom's pixel locations based on the atom's `dir` variable, and what pixel offset arguments are passed into it
	If no arguments are supplied, `pixel_x` or `pixel_y` will be set to 0
	Used primarily for when players attach mountable frames to walls (APC frame, fire alarm frame, etc.)
*/
/atom/proc/set_pixel_offsets_from_dir(pixel_north = 0, pixel_south = 0, pixel_east = 0, pixel_west = 0)
	switch(dir)
		if(NORTH)
			pixel_y = pixel_north
		if(SOUTH)
			pixel_y = pixel_south
		if(EAST)
			pixel_x = pixel_east
		if(WEST)
			pixel_x = pixel_west
		if(NORTHEAST)
			pixel_y = pixel_north
			pixel_x = pixel_east
		if(NORTHWEST)
			pixel_y = pixel_north
			pixel_x = pixel_west
		if(SOUTHEAST)
			pixel_y = pixel_south
			pixel_x = pixel_east
		if(SOUTHWEST)
			pixel_y = pixel_south
			pixel_x = pixel_west

///Handle melee attack by a mech
/atom/proc/mech_melee_attack(obj/mecha/M)
	return

/atom/proc/CheckParts(list/parts_list)
	for(var/A in parts_list)
		if(istype(A, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(A)
			reagents.conditional_update()
		else if(istype(A, /atom/movable))
			var/atom/movable/M = A
			if(istype(M.loc, /mob/living))
				var/mob/living/L = M.loc
				L.drop_item_ground(M)
			M.forceMove(src)

/atom/proc/assume_air(datum/gas_mixture/giver)
	qdel(giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

///Return the air if we can analyze it
/atom/proc/return_analyzable_air()
	return null

/atom/proc/check_eye(mob/user)
	return

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(atom/movable/moving_atom)
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, moving_atom)
	return

/// Convenience proc to see if a container is open for chemistry handling
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/// Is this atom injectable into other atoms
/atom/proc/is_injectable(mob/user, allowmobs = TRUE)
	return reagents && (container_type & (INJECTABLE|REFILLABLE))

/// Can we draw from this atom with an injectable atom
/atom/proc/is_drawable(mob/user, allowmobs = TRUE)
	return reagents && (container_type & (DRAWABLE|DRAINABLE))

/// Can this atoms reagents be refilled
/atom/proc/is_refillable()
	return reagents && (container_type & REFILLABLE)

/// Is this atom drainable of reagents
/atom/proc/is_drainable()
	return reagents && (container_type & DRAINABLE)

/atom/proc/HasProximity(atom/movable/AM)
	return

/atom/proc/emp_act(severity)
	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)

//amount of water acting : temperature of water in kelvin : object that called it (for shennagins)
/atom/proc/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	return TRUE

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	SEND_SIGNAL(src, COMSIG_ATOM_BULLET_ACT, P, def_zone)
	. = P.on_hit(src, 0, def_zone)

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return TRUE
	else if(src in container)
		return TRUE
	return FALSE

/*
 *	atom/proc/search_contents_for(path, list/filter_path = null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path, list/filter_path = null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path, filter_path)
	return found


//All atoms
/atom/proc/examine(mob/user, infix = "", suffix = "")
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src][infix]."
	if(src.blood_DNA && !istype(src, /obj/effect/decal))
		if(gender == PLURAL)
			f_name = "some "
		else
			f_name = "a "
		if(blood_color != "#030303")
			f_name += "<span class='danger'>blood-stained</span> [name][infix]!"
		else
			f_name += "oil-stained [name][infix]."
	. = list("[bicon(src)] That's [f_name] [suffix]")
	if(desc)
		. += desc

	if(reagents)
		if(container_type & TRANSPARENT)
			. += "<span class='notice'>It contains:</span>"
			if(reagents.reagent_list.len)
				if(user.can_see_reagents()) //Show each individual reagent
					for(var/I in reagents.reagent_list)
						var/datum/reagent/R = I
						. += "<span class='notice'>[R.volume] units of [R.name]</span>"
				else //Otherwise, just show the total volume
					if(reagents && reagents.reagent_list.len)
						. += "<span class='notice'>[reagents.total_volume] units of various reagents.</span>"
			else
				. += "<span class='notice'>Nothing.</span>"
		else if(container_type & AMOUNT_VISIBLE)
			if(reagents.total_volume)
				. += "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>"
			else
				. += "<span class='danger'>It's empty.</span>"

	//Detailed description
	var/descriptions
	if(get_description_info())
		descriptions += "<a href='?src=[UID()];description_info=`'>\[Справка\]</a> "
	if(get_description_antag())
		if(isAntag(user) || isobserver(user))
			descriptions += "<a href='?src=[UID()];description_antag=`'>\[Антагонист\]</a> "
	if(get_description_fluff())
		descriptions += "<a href='?src=[UID()];description_fluff=`'>\[Забавная информация\]</a>"

	if(descriptions)
		. += descriptions

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)


/**
 * Updates the appearence of the icon
 *
 * Mostly delegates to update_name, update_desc, and update_icon
 *
 * Arguments:
 * - updates: A set of bitflags dictating what should be updated. Defaults to [ALL]
 */
/atom/proc/update_appearance(updates = ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	/// Signal sent should the appearance be updated. This is more broad if listening to a more specific signal doesn't cut it
	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_APPEARANCE, updates)
	if(updates & UPDATE_NAME)
		update_name(updates)
	if(updates & UPDATE_DESC)
		update_desc(updates)
	if(updates & UPDATE_ICON)
		update_icon(updates)


/// Updates the name of the atom
/atom/proc/update_name(updates = ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_NAME, updates)


/// Updates the description of the atom
/atom/proc/update_desc(updates = ALL)
	SHOULD_CALL_PARENT(TRUE)
	return SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_DESC, updates)


/// Updates the icon of the atom
/atom/proc/update_icon(updates = ALL)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE
	if(updates == NONE)	// NONE is being sent on purpose, and thus no signal should be sent.
		return .

	updates &= ~SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON, updates)

	if(updates & UPDATE_ICON_STATE)
		update_icon_state()
		SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON_STATE)
		. |= UPDATE_ICON_STATE

	if(updates & UPDATE_OVERLAYS)
		var/list/new_overlays = update_overlays()
		SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, new_overlays)

		// Ok, so its rather this or required inheritance in every [update_overlays()]
		var/emissive_block = get_emissive_block()
		if(emissive_block)
			// Emissive block should always go at the beginning of the list
			new_overlays.Insert(1, emissive_block)

		var/nulls = 0
		for(var/i in 1 to length(new_overlays))
			var/atom/maybe_not_an_atom = new_overlays[i]
			if(isnull(maybe_not_an_atom))
				nulls++
				continue
			if(istext(maybe_not_an_atom) || isicon(maybe_not_an_atom))
				continue
			new_overlays[i] = maybe_not_an_atom.appearance
		if(nulls)
			for(var/i in 1 to nulls)
				new_overlays -= null

		var/identical = FALSE
		var/new_length = length(new_overlays)
		if(!managed_overlays && !new_length)
			identical = TRUE
		else if(!islist(managed_overlays))
			if(new_length == 1 && managed_overlays == new_overlays[1])
				identical = TRUE
		else if(length(managed_overlays) == new_length)
			identical = TRUE
			for(var/i in 1 to length(managed_overlays))
				if(managed_overlays[i] != new_overlays[i])
					identical = FALSE
					break

		if(!identical)
			var/full_control = FALSE
			if(managed_overlays)
				full_control = length(overlays) == (islist(managed_overlays) ? length(managed_overlays) : 1)
				if(full_control)
					overlays = null
				else
					cut_overlay(managed_overlays)

			switch(length(new_overlays))
				if(0)
					managed_overlays = null
				if(1)
					add_overlay(new_overlays)
					managed_overlays = new_overlays[1]
				else
					add_overlay(new_overlays)
					managed_overlays = new_overlays

		. |= UPDATE_OVERLAYS

	. |= SEND_SIGNAL(src, COMSIG_ATOM_UPDATED_ICON, updates, .)


/// Updates the icon state of the atom
/atom/proc/update_icon_state()
	return


/// Updates the overlays of the atom. It has to return a list of overlays if it can't call the parent to create one. The list can contain anything that would be valid for the add_overlay proc: Images, mutable appearances, icon states...
/atom/proc/update_overlays()
	RETURN_TYPE(/list)
	. = list()


/// Updates atom's emissive block if present.
/atom/proc/get_emissive_block()
	return


/atom/Topic(href, href_list)
	. = ..()
	if(.)
		return TRUE
	if(href_list["description_info"])
		to_chat(usr, "<div class='examine'><span class='info'>[get_description_info()]</span></div>")
		return TRUE
	if(href_list["description_antag"])
		to_chat(usr, "<div class='examine'><span class='syndradio'>[get_description_antag()]</span></div>")
		return TRUE
	if(href_list["description_fluff"])
		to_chat(usr, "<div class='examine'><span class='notice'>[get_description_fluff()]</span></div>")
		return TRUE

/atom/proc/relaymove()
	return

/atom/proc/ex_act()
	return

/atom/proc/blob_act(obj/structure/blob/B)
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)

/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_FIRE_ACT, exposed_temperature, exposed_volume)
	if(reagents)
		reagents.temperature_reagents(exposed_temperature)

/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)


// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return

//Check if the multitool has an item in its data buffer
/atom/proc/multitool_check_buffer(user, silent = FALSE)
	if(!silent)
		to_chat(user, "<span class='warning'>[src] has no data buffer!</span>")
	return FALSE

/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return

/atom/proc/emag_act(mob/user)
	SEND_SIGNAL(src, COMSIG_ATOM_EMAG_ACT, user)

/atom/proc/unemag()
	return
	
/atom/proc/cmag_act(mob/user)
	return


/**
 * Special treatment of [/datum/emote/living/carbon/human/fart].
 * Returning `TRUE` will stop emote execution.
 *
 * Arguments:
 * * user - mob who used the emote.
 */
/atom/proc/fart_act(mob/living/user)
	return FALSE


/atom/proc/rpd_act()
	return

/atom/proc/rpd_blocksusage()
	// Atoms that return TRUE prevent RPDs placing any kind of pipes on their turf.
	return FALSE

// Wrapper, called by an RCD
/atom/proc/rcd_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	if(rcd_mode == RCD_MODE_DECON)
		return rcd_deconstruct_act(user, our_rcd)
	return rcd_construct_act(user, our_rcd, rcd_mode)

/atom/proc/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	return RCD_NO_ACT

/atom/proc/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	return RCD_NO_ACT


/atom/proc/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(density && !has_gravity(AM)) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, PROC_REF(hitby_react), AM), 2)


/// This proc applies special effects of a carbon mob hitting something, be it a wall, structure, or window. You can set mob_hurt to false to avoid double dipping through subtypes if returning ..()
/atom/proc/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt = FALSE, self_hurt = FALSE)
	return


/atom/proc/hitby_react(atom/movable/AM)
	if(AM && isturf(AM.loc))
		step(AM, turn(AM.dir, 180))


/*
 * Base proc, terribly named but it's all over the code so who cares I guess right?
 *
 * Returns FALSE by default, if a child returns TRUE it is implied that the atom has in
 * some way done a spooky thing. Current usage is so that Boo knows if it needs to cool
 * down or not, but this could be expanded upon if you were a bad enough dude.
 */
/atom/proc/get_spooked()
	return FALSE

/**
	Base proc, intended to be overriden.

	This should only be called from one place: inside the slippery component.
	Called after a human mob slips on this atom.

	If you want the person who slipped to have something special done to them, put it here.
*/
/atom/proc/after_slip(mob/living/carbon/human/H)
	return

/atom/proc/add_hiddenprint(mob/living/M)
	if(isnull(M))
		return
	if(isnull(M.key))
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna))
			return FALSE
		if(H.gloves)
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []", H.real_name, H.key)
				fingerprintslast = H.ckey
			return FALSE
		if(!fingerprints)
			if(fingerprintslast != H.ckey)
				//Add the list if it does not exist.
				if(!fingerprintshidden)
					fingerprintshidden = list()
				fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []", H.real_name, H.key)
				fingerprintslast = H.ckey
			return TRUE
	else
		if(fingerprintslast != M.ckey)
			//Add the list if it does not exist.
			if(!fingerprintshidden)
				fingerprintshidden = list()
			fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []", M.real_name, M.key)
			fingerprintslast = M.ckey
	return


//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(isnull(M))
		return
	if(isnull(M.key))
		return
	if(ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if(FINGERPRINTS in M.mutations)
			if(fingerprintslast != M.key)
				fingerprintshidden += "(Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
				fingerprintslast = M.key
			return FALSE		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M
		if(!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
		H.check_dna()

		//Check if the gloves (if any) hide fingerprints
		if(H.gloves)
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = TRUE

		//Now, deal with gloves.
		if(!ignoregloves)
			if(H.gloves && H.gloves != src)
				if(fingerprintslast != H.ckey)
					fingerprintshidden += text("\[[]\](Wearing gloves). Real name: [], Key: []", time_stamp(), H.real_name, H.key)
					fingerprintslast = H.ckey
				H.gloves.add_fingerprint(M)
				return FALSE

		//More adminstuffz
		if(fingerprintslast != H.ckey)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []", time_stamp(), H.real_name, H.key)
			fingerprintslast = H.ckey

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		if(!fingerprints_time)
			fingerprints_time = list()

		//Hash this shit.
		var/full_print = H.get_full_print()

		// Add the fingerprints
		fingerprints[full_print] = full_print
		fingerprints_time += "[station_time_timestamp()] — [full_print]"
		if(fingerprints_time.len > 20)
			fingerprints_time -= fingerprints_time[1]

		return TRUE
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.ckey)
			fingerprintshidden += text("\[[]\]Real name: [], Key: []", time_stamp(), M.real_name, M.key)
			fingerprintslast = M.ckey

	return

/atom/proc/transfer_fingerprints_to(atom/A)
	// Make sure everything are lists.
	if(!islist(A.fingerprints))
		A.fingerprints = list()
	if(!islist(A.fingerprintshidden))
		A.fingerprintshidden = list()
	if(!islist(A.fingerprints_time))
		A.fingerprints_time = list()

	if(!islist(fingerprints))
		fingerprints = list()
	if(!islist(fingerprintshidden))
		fingerprintshidden = list()
	if(!islist(fingerprints_time))
		fingerprints_time = list()

	// Transfer
	if(fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprints_time)
		A.fingerprints_time |= fingerprints_time.Copy()
	if(fingerprintshidden)
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin
	A.fingerprintslast = fingerprintslast

/**
* Proc thats checks if mobs can leave fingerprints and fibers on the atom
*/
/atom/proc/has_prints()
	return FALSE

GLOBAL_LIST_EMPTY(blood_splatter_icons)

//returns the mob's dna info as a list, to be inserted in an object's blood_DNA list
/mob/living/proc/get_blood_dna_list()
	if(get_blood_id() != "blood")
		return
	return list("ANIMAL DNA" = "Y-")

/mob/living/carbon/get_blood_dna_list()
	var/static/list/acceptable_blood = list("blood", "cryoxadone", "slimejelly")
	var/check_blood = get_blood_id()
	if(!check_blood || !(check_blood in acceptable_blood))
		return
	var/list/blood_dna = list()
	if(dna)
		blood_dna[dna.unique_enzymes] = dna.blood_type
	else
		blood_dna["UNKNOWN DNA"] = "X*"
	return blood_dna

/mob/living/carbon/alien/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return FALSE
	return transfer_blood_dna(new_blood_dna)

/obj/effect/decal/cleanable/blood/splatter/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data)
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

/obj/effect/decal/cleanable/blood/footprints/transfer_mob_blood_dna(mob/living/L)
	..(L)
	var/list/b_data = L.get_blood_data(L.get_blood_id())
	if(b_data)
		basecolor = b_data["blood_color"]
	else
		basecolor = "#A10808"
	update_icon()

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!blood_dna || !length(blood_dna))
		return FALSE
	LAZYINITLIST(blood_DNA)
	var/old_length = length(blood_DNA)
	blood_DNA |= blood_dna
	return length(blood_DNA) > old_length	//some new blood DNA was added


//to add blood from a mob onto something, and transfer their dna info
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return FALSE
	var/bloodcolor = "#A10808"
	var/list/b_data = M.get_blood_data(M.get_blood_id())
	if(b_data)
		bloodcolor = b_data["blood_color"]

	return add_blood(blood_dna, bloodcolor)

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna, color)
	return FALSE

/obj/add_blood(list/blood_dna, color)
	return transfer_blood_dna(blood_dna)

/obj/item/add_blood(list/blood_dna, color)
	var/blood_count = !blood_DNA ? 0 : length(blood_DNA)
	if(!..())
		return FALSE
	blood_color = color // update the blood color
	if(!blood_count)//apply the blood-splatter overlay if it isn't already in there
		add_blood_overlay()
	return TRUE //we applied blood to the item

/obj/item/clothing/gloves/add_blood(list/blood_dna, color)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood(list/blood_dna, color)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	B.basecolor = color
	return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood(list/blood_dna, color)
	if(wear_suit)
		wear_suit.add_blood(blood_dna, color)
		wear_suit.blood_color = color
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(blood_dna, color)
		w_uniform.blood_color = color
		update_inv_w_uniform()
	if(head)
		head.add_blood(blood_dna, color)
		head.blood_color = color
		update_inv_head()
	if(glasses)
		glasses.add_blood(blood_dna, color)
		glasses.blood_color = color
		update_inv_glasses()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna, color)
		G.blood_color = color
		verbs += /mob/living/carbon/human/proc/bloody_doodle
	else
		hand_blood_color = color
		bloody_hands = rand(2, 4)
		transfer_blood_dna(blood_dna)
		verbs += /mob/living/carbon/human/proc/bloody_doodle

	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE


/obj/item/proc/add_blood_overlay()
	if(initial(icon) && initial(icon_state))
		var/list/params = GLOB.blood_splatter_icons["[blood_color]"]
		if(!params)
			params = layering_filter(icon = icon('icons/effects/blood.dmi', "itemblood"), color = blood_color, blend_mode = BLEND_INSET_OVERLAY)
			GLOB.blood_splatter_icons["[blood_color]"] = params
		add_filter("blood_splatter", 1, params)


/atom/proc/clean_blood()
	germ_level = 0
	if(islist(blood_DNA))
		blood_DNA = null
		return TRUE

/obj/effect/decal/cleanable/blood/clean_blood()
	return // While this seems nonsensical, clean_blood isn't supposed to be used like this on a blood decal.


/obj/item/clean_blood()
	. = ..()
	if(.)
		if(initial(icon) && initial(icon_state))
			remove_filter("blood_splatter")

/obj/item/clothing/gloves/clean_blood()
	. = ..()
	if(.)
		transfer_blood = 0

/obj/item/clothing/shoes/clean_blood()
	..()
	bloody_shoes = list(BLOOD_STATE_HUMAN = 0, BLOOD_STATE_XENO = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/mob/living/carbon/human/clean_blood(clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	if(w_uniform && !(wear_suit && wear_suit.flags_inv & HIDEJUMPSUIT))
		if(w_uniform.clean_blood())
			update_inv_w_uniform()
	if(gloves && !(wear_suit && wear_suit.flags_inv & HIDEGLOVES))
		if(gloves.clean_blood())
			update_inv_gloves()
			gloves.germ_level = 0
			clean_hands = FALSE
	if(shoes && !(wear_suit && wear_suit.flags_inv & HIDESHOES))
		if(shoes.clean_blood())
			update_inv_shoes()
			clean_feet = FALSE
	if(s_store && !(wear_suit && wear_suit.flags_inv & HIDESUITSTORAGE))
		if(s_store.clean_blood())
			update_inv_s_store()
	if(lip_style && !(head && head.flags_inv & HIDEMASK))
		lip_style = null
		update_body()
	if(glasses && !(wear_mask && wear_mask.flags_inv & HIDEGLASSES))
		if(glasses.clean_blood())
			update_inv_glasses()
	if(l_ear && !(wear_mask && wear_mask.flags_inv & HIDEHEADSETS))
		if(l_ear.clean_blood())
			update_inv_ears()
	if(r_ear && !(wear_mask && wear_mask.flags_inv & HIDEHEADSETS))
		if(r_ear.clean_blood())
			update_inv_ears()
	if(belt)
		if(belt.clean_blood())
			update_inv_belt()
	if(neck)
		if(neck.clean_blood())
			update_inv_neck()
	..(clean_hands, clean_mask, clean_feet)
	update_icons()	//apply the now updated overlays to the mob

/atom/proc/add_vomit_floor(toxvomit = FALSE, green = FALSE)
	playsound(src, 'sound/effects/splat.ogg', 50, TRUE)
	if(!isspaceturf(src))
		var/type = green ? /obj/effect/decal/cleanable/vomit/green : /obj/effect/decal/cleanable/vomit
		var/vomit_reagent = green ? "green_vomit" : "vomit"
		for(var/obj/effect/decal/cleanable/vomit/V in get_turf(src))
			if(V.type == type)
				V.reagents.add_reagent(vomit_reagent, 5)
				return

		var/obj/effect/decal/cleanable/vomit/this = new type(src)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1, 4)]"

/atom/proc/get_global_map_pos()
	if(!islist(GLOB.global_map) || isemptylist(GLOB.global_map))
		return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x in 1 to GLOB.global_map.len)
		y_arr = GLOB.global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	to_chat(world, "X = [cur_x]; Y = [cur_y]")
	if(cur_x && cur_y)
		return list("x" = cur_x, "y" = cur_y)
	else
		return null

// Used to provide overlays when using this atom as a viewing focus
// (cameras, locker tint, etc.)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return

//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	user.sync_lighting_plane_alpha()
	return

/atom/proc/isinspace()
	if(isspaceturf(get_turf(src)))
		return TRUE
	else
		return FALSE

/atom/proc/handle_fall()
	return

/atom/proc/singularity_act()
	return

/atom/proc/singularity_pull(obj/singularity/S, current_size)
	SEND_SIGNAL(src, COMSIG_ATOM_SING_PULL, S, current_size)

/**
  * Respond to acid being used on our atom
  *
  * Default behaviour is to send COMSIG_ATOM_ACID_ACT and return
  */
/atom/proc/acid_act(acidpwr, acid_volume)
	SEND_SIGNAL(src, COMSIG_ATOM_ACID_ACT, acidpwr, acid_volume)

/atom/proc/narsie_act()
	return

/atom/proc/ratvar_act()
	return

/atom/proc/handle_ricochet(obj/item/projectile/P)
	return

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	return

/atom/proc/atom_say(message)
	if(!message)
		return
	var/message_tts = message
	message = replace_characters(message, list("+"))

	var/list/speech_bubble_hearers = list()
	for(var/mob/M in get_mobs_in_view(7, src))
		M.show_message("<span class='game say'><span class='name'>[src]</span> [atom_say_verb], \"[message]\"</span>", 2, null, 1)
		if(M.client)
			speech_bubble_hearers += M.client

			if(!M.can_hear() || M.stat == UNCONSCIOUS)
				continue

			if(M.client.prefs.toggles2 & PREFTOGGLE_2_RUNECHAT)
				M.create_chat_message(src, message, FALSE, TRUE)

			var/effect = SOUND_EFFECT_RADIO
			var/traits = TTS_TRAIT_RATE_MEDIUM
			INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, src, M, message_tts, tts_seed, TRUE, effect, traits)

	if(length(speech_bubble_hearers))
		var/image/I = image('icons/mob/talk.dmi', src, "[bubble_icon][say_test(message)]", FLY_LAYER)
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, I, speech_bubble_hearers, 30)

/atom/proc/select_voice(mob/user, silent_target = FALSE, override = FALSE)
	if(!ismob(src) && !user)
		return null
	var/tts_test_str = "Так звучит мой голос."

	var/tts_seeds
	if(user && (check_rights(R_ADMIN, 0, user) || override))
		tts_seeds = SStts.tts_seeds_names
	else
		tts_seeds = SStts.get_available_seeds(src)

	var/new_tts_seed = tgui_input_list(user || src, "Choose your preferred voice:", "Character Preference", tts_seeds, tts_seed)
	if(!new_tts_seed)
		new_tts_seed = tts_seed
	if(!silent_target && ismob(src) && src != user)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, src, tts_test_str, new_tts_seed, FALSE)
	if(user)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, user, tts_test_str, new_tts_seed, FALSE)
	return new_tts_seed

/atom/proc/change_voice(mob/user, override = FALSE)
	set waitfor = FALSE
	var/new_tts_seed = select_voice(user, override = override)
	if(!new_tts_seed)
		return null
	return update_tts_seed(new_tts_seed)

/atom/proc/update_tts_seed(new_tts_seed)
	tts_seed = new_tts_seed
	return new_tts_seed

/atom/proc/speech_bubble(bubble_state = "", bubble_loc = src, list/bubble_recipients = list())
	return

/atom/vv_edit_var(var_name, var_value)
	if(!GLOB.debug2)
		admin_spawned = TRUE
	. = ..()
	switch(var_name)
		if("light_power", "light_range", "light_color")
			update_light()
		if("color")
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)


/atom/vv_get_dropdown()
	. = ..()
	var/turf/curturf = get_turf(src)
	if(curturf)
		.["Jump to turf"] = "?_src_=holder;adminplayerobservecoodjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	.["Add reagent"] = "?_src_=vars;addreagent=[UID()]"
	.["Trigger explosion"] = "?_src_=vars;explode=[UID()]"
	.["Trigger EM pulse"] = "?_src_=vars;emp=[UID()]"

/atom/proc/AllowDrop()
	return FALSE

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : get_turf(L)

/atom/Entered(atom/movable/AM, atom/oldLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldLoc)

/atom/Exit(atom/movable/AM, atom/newLoc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newLoc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE

/atom/Exited(atom/movable/AM, atom/newLoc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newLoc)

/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()

/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()

/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return


/** Call this when you want to present a renaming prompt to the user.

	It's a simple proc, but handles annoying edge cases such as forgetting to add a "cancel" button,
	or being able to rename stuff remotely.

	Arguments:
	* user - the renamer.
	* implement - the tool doing the renaming (usually, a pen).
	* use_prefix - whether the new name should follow the format of "thing - user-given label" or
		if we allow to change the name completely arbitrarily.
	* actually_rename - whether we want to really change the `src.name`, or if we want to do everything *except* that.
	* prompt - a custom "what do you want rename this thing to be?" prompt shown in the inpit box.

	Returns: Either null if the renaming was aborted, or the user-provided sanitized string.
 **/
/atom/proc/rename_interactive(mob/user, obj/implement = null, use_prefix = TRUE,
		actually_rename = TRUE, prompt = null)
	// Sanity check that the user can, indeed, rename the thing.
	// This, sadly, means you can't rename things with a telekinetic pen, but that's
	// too much of a hassle to make work nicely.
	if((implement && implement.loc != user) || !in_range(src, user) || user.incapacitated(ignore_lying = TRUE))
		return null

	var/prefix = ""
	if(use_prefix)
		prefix = "[initial(name)] - "

	var/default_value
	if(!use_prefix)
		default_value = name
	else if(findtext(name, prefix) != 0)
		default_value = copytext_char(name, length_char(prefix) + 1)
	else
		// Either the thing has a non-conforming name due to being set in the map
		// OR (much more likely) the thing is unlabeled yet.
		default_value = ""
	if(!prompt)
		prompt = "What would you like the label on [src] to be?"

	var/t = input(user, prompt, "Renaming [src]", default_value)  as text | null
	if(isnull(t))
		// user pressed Cancel
		return null

	// Things could have changed between when `input` is called and when it returns.
	if(!user)
		return null
	else if(implement && implement.loc != user)
		to_chat(user, "<span class='warning'>You no longer have the pen to rename [src].</span>")
		return null
	else if(!in_range(src, user))
		to_chat(user, "<span class='warning'>You cannot rename [src] from here.</span>")
		return null
	else if (user.incapacitated(ignore_lying = TRUE))
		to_chat(user, "<span class='warning'>You cannot rename [src] in your current state.</span>")
		return null


	t = sanitize(copytext_char(t, 1, MAX_NAME_LEN))

	// Logging
	var/logged_name = initial(name)
	if(t)
		logged_name = "[use_prefix ? "[prefix][t]" : t]"
	investigate_log("[key_name(user)] ([ADMIN_FLW(user,"FLW")]) renamed \"[src]\" ([ADMIN_VV(src, "VV")]) as \"[logged_name]\".", INVESTIGATE_RENAME)

	if(actually_rename)
		if(t == "")
			name = "[initial(name)]"
		else
			name = "[prefix][t]"
	return t


/*
	Setter for the `density` variable.
	Arguments:
	* new_value - the new density you would want it to set.
	Returns: Either null if identical to existing density, or the new density if different.
*/
/atom/proc/set_density(new_value)
	if(density == new_value)
		return
	. = density
	density = new_value

// Процедура выбора правильного падежа для любого предмета,если у него указан словарь «ru_names», примерно такой:
// ru_names = list(NOMINATIVE = "челюсти жизни", GENITIVE = "челюстей жизни", DATIVE = "челюстям жизни", ACCUSATIVE = "челюсти жизни", INSTRUMENTAL = "челюстями жизни", PREPOSITIONAL = "челюстях жизни")
/atom/proc/declent_ru(case_id, list/ru_names_override)
	var/list/list_to_use = ru_names_override || ru_names
	if(length(list_to_use))
		return list_to_use[case_id] || name
	return name


//OOP
/atom/proc/update_pipe_vision()
	return


/**
 * This proc is used for telling whether something can pass by this atom in a given direction, for use by the pathfinding system.
 *
 * Trying to generate one long path across the station will call this proc on every single object on every single tile that we're seeing if we can move through, likely
 * multiple times per tile since we're likely checking if we can access said tile from multiple directions, so keep these as lightweight as possible.
 *
 * For turfs this will only be used if pathing_pass_method is TURF_PATHING_PASS_PROC
 *
 * Arguments:
 * * ID- An ID card representing what access we have (and thus if we can open things like airlocks or windows to pass through them). The ID card's physical location does not matter, just the reference
 * * to_dir- What direction we're trying to move in, relevant for things like directional windows that only block movement in certain directions
 * * caller- The movable we're checking pass flags for, if we're making any such checks
 * * no_id: When true, doors with public access will count as impassible
 **/
/atom/proc/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
	if(caller && (caller.pass_flags & pass_flags_self))
		return TRUE
	. = !density


/atom/proc/get_examine_time()	// Used only in /mob/living/carbon/human and /mob/living/simple_animal/hostile/morph
	return 0 SECONDS


/atom/proc/get_visible_gender()	// Used only in /mob/living/carbon/human and /mob/living/simple_animal/hostile/morph
	return gender


/// Whether the mover object can avoid being blocked by this atom, while arriving from (or leaving through) the border_dir.
/atom/proc/CanPass(atom/movable/mover, border_dir)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	if(SEND_SIGNAL(src, COMSIG_ATOM_TRIED_PASS, mover, border_dir) & COMSIG_COMPONENT_PERMIT_PASSAGE)
		return TRUE
	//if(mover.movement_type & PHASING)
	//	return TRUE
	. = CanAllowThrough(mover, border_dir)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, REVERSE_DIR(border_dir), .)


/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, border_dir)
	SHOULD_CALL_PARENT(TRUE)
	if(mover.pass_flags == PASSEVERYTHING)
		return TRUE
	if(mover.pass_flags & pass_flags_self)
		return TRUE
	if(mover.throwing && (pass_flags_self & LETPASSTHROW))
		return TRUE
	return !density


/// Returns true or false to allow the mover to exit turf with src
/atom/proc/CanExit(atom/movable/mover, moving_direction)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return TRUE

