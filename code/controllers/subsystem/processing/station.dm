PROCESSING_SUBSYSTEM_DEF(station)
	name = "Station"
	ss_flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 5 SECONDS

	///A list of currently active station traits
	var/list/station_traits = list()
	///Assoc list of trait type || assoc list of traits with weighted value. Used for picking traits from a specific category.
	var/alist/selectable_traits_by_types = alist(STATION_TRAIT_POSITIVE = list(), STATION_TRAIT_NEUTRAL = list(), STATION_TRAIT_NEGATIVE = list())
	///Currently active announcer. Starts as a type but gets initialized after traits are selected
	var/datum/centcom_announcer/announcer = /datum/centcom_announcer/default
	///A list of trait roles that should be protected from antag
	var/list/antag_protected_roles = list()
	///A list of trait roles that should never be able to roll antag
	var/list/antag_restricted_roles = list()

/datum/controller/subsystem/processing/station/Initialize()
	#ifndef UNIT_TESTS
	SetupTraits()
	#endif
	announcer = new announcer() //Initialize the station's announcer datum
	SSparallax.post_station_setup() //Apply station effects that parallax might have
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/station/Recover()
	station_traits = SSstation.station_traits
	selectable_traits_by_types = SSstation.selectable_traits_by_types
	announcer = SSstation.announcer
	antag_protected_roles = SSstation.antag_protected_roles
	antag_restricted_roles = SSstation.antag_restricted_roles
	..()

///Rolls for the amount of traits and adds them to the traits list
/datum/controller/subsystem/processing/station/proc/SetupTraits()
	if(CONFIG_GET(flag/forbid_station_traits))
		return

	if(fexists(FUTURE_STATION_TRAITS_FILE))
		var/forced_traits_contents = file2text(FUTURE_STATION_TRAITS_FILE)
		fdel(FUTURE_STATION_TRAITS_FILE)

		var/list/forced_traits_text_paths = json_decode(forced_traits_contents)
		forced_traits_text_paths = SANITIZE_LIST(forced_traits_text_paths)

		for(var/trait_text_path in forced_traits_text_paths)
			var/station_trait_path = text2path(trait_text_path)
			if(!ispath(station_trait_path, /datum/station_trait) || station_trait_path == /datum/station_trait)
				var/message = "Invalid station trait path [station_trait_path] was requested in the future station traits!"
				log_game(message)
				message_admins(message)
				continue
			setup_trait(station_trait_path)
		return

	for(var/datum/station_trait/trait_typepath as anything in valid_subtypesof(/datum/station_trait))
		// If forced, (probably debugging), just set it up now, keep it out of the pool.
		if(trait_typepath.force)
			setup_trait(trait_typepath)
			continue

		if(!(trait_typepath.trait_flags & STATION_TRAIT_PLANETARY) && SSmapping.is_planetary()) // we're on a planet but we can't do planet ;_;
			continue

		if(!(trait_typepath.trait_flags & STATION_TRAIT_SPACE_BOUND) && !SSmapping.is_planetary()) //we're in space but we can't do space ;_;
			continue

		if(!(trait_typepath.trait_flags & STATION_TRAIT_REQUIRES_AI) && !CONFIG_GET(flag/allow_ai)) //can't have AI traits without AI
			continue

		selectable_traits_by_types[trait_typepath.trait_type][trait_typepath] = trait_typepath.weight

// Most of the traits depend on some kind of station feature that FAST_LOAD map lacks, so for now,
// to avoid inconvenience with runtimes and until we maybe have better map for testing,
// FAST_LOAD disables random station traits from generation. You still can force them though.
#ifdef FAST_LOAD
	return
#endif

	var/positive_trait_budget = text2num(pick_weight_classic(CONFIG_GET(keyed_list/positive_station_traits)))
	var/neutral_trait_budget = text2num(pick_weight_classic(CONFIG_GET(keyed_list/neutral_station_traits)))
	var/negative_trait_budget = text2num(pick_weight_classic(CONFIG_GET(keyed_list/negative_station_traits)))

#ifdef MAP_TESTS
	positive_trait_budget = 0
	neutral_trait_budget = 0
	negative_trait_budget = 0
#endif

	pick_traits(STATION_TRAIT_POSITIVE, positive_trait_budget)
	pick_traits(STATION_TRAIT_NEUTRAL, neutral_trait_budget)
	pick_traits(STATION_TRAIT_NEGATIVE, negative_trait_budget)

/**
 * Picks traits of a specific category (e.g. bad or good), initializes them, adds them to the list of traits,
 * then removes them from possible traits as to not roll twice and subtracts their cost from the budget.
 * All until the whole budget is spent or no more traits can be picked with it.
 */
/datum/controller/subsystem/processing/station/proc/pick_traits(trait_sign, budget)
	if(!budget)
		return

	///A list of traits of the same trait sign
	var/list/selectable_traits = selectable_traits_by_types[trait_sign]
	while(budget)
		///Remove any station trait with a cost bigger than the budget
		for(var/datum/station_trait/proto_trait as anything in selectable_traits.Copy())
			if(initial(proto_trait.cost) > budget)
				selectable_traits -= proto_trait
		///We have spare budget but no trait that can be bought with what's left of it
		if(!length(selectable_traits))
			return
		//Rolls from the table for the specific trait type
		var/datum/station_trait/trait_type = pick_weight_classic(selectable_traits)
		selectable_traits -= trait_type
		budget -= initial(trait_type.cost)
		setup_trait(trait_type)

///Creates a given trait of a specific type, while also removing any blacklisted ones from the future pool.
/datum/controller/subsystem/processing/station/proc/setup_trait(datum/station_trait/trait_type)
	if(locate(trait_type) in station_traits)
		return
	var/datum/station_trait/trait_instance = new trait_type()
	station_traits += trait_instance
	log_game("Station Trait: [trait_instance.name] chosen for this round.")
	if(!trait_instance.blacklist)
		return
	for(var/i in trait_instance.blacklist)
		var/datum/station_trait/trait_to_remove = i
		selectable_traits_by_types[initial(trait_to_remove.trait_type)] -= trait_to_remove
