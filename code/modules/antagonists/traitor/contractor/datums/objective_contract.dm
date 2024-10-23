/**
  * # Contract Objective
  *
  * Describes the target to kidnap and the extraction area of a [/datum/syndicate_contract].
  */
/datum/objective/contract
	// Settings
	/// Jobs that cannot be the kidnapping target.
	var/static/list/forbidden_jobs = list(
		JOB_TITLE_CAPTAIN,
	)
	/// Static whitelist of area names that can be used as an extraction zone, structured by difficulty.
	/// An area's difficulty should be measured in how crowded it generally is, how out of the way it is and so on.
	/// Outdoor or invalid areas are filtered out.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => list(<area name>)
	var/static/list/possible_zone_names = list(
		EXTRACTION_DIFFICULTY_EASY = list(
			// Rooms
			"Arrival Commercial West Hallway",
			"Arrival Additional West Hallway", //the most unvisited hallways, used only for explorers and if traders arrives
			"Alternate Construction Area",
			"Barber Shop",
			"Trading area",
			"Abandoned Casino",
			"Abandoned Banya",
			"Hangar Expedition",
			"Abandoned Tradiders Room",
			"Old Restaurant",
			"Abandoned Detective's Office",
			"Escape Shuttle Hallway Podbay",
			"Theatre",
			"Garden",
			"Old Garden",
			"Incinerator",
			"Locker Room",
			"Locker Toilets",
			"Maintenance Bar",
			"Medical Secondary Storage",
			"Mechanic Workshop",
			"West Emergency Storage",
			"Psych Room",
			"Toxins Launch Room",
			"Toxins Mixing Room",
			"Turbine",
			"Virology",
			"Waste Disposal",
			"Abandoned Escape Shuttle Hallway",
			"Abandoned Library",
			"RnD Restroom",
			"Abandoned Teleporter",
			// Maintenance
			"South-West Solar Maintenance",
			"South-East Solar Maintenance",
			"Arrivals North Maintenance",
			"Bar Maintenance",
			"Cargo Maintenance",
			"Dormitory Maintenance",
			"Electrical Maintenance",
			"EVA Maintenance",
			"Engineering Maintenance",
			"North-West Maintenance",
			"North-West Solar Maintenance",
			"North-East Solar Maintenance",
			"Genetics Maintenance",
			"Locker Room Maintenance",
			"Medbay Maintenance",
			"Science Maintenance",
			"North Maintenance",
			"East Maintenance",
			"Virology Maintenance",
			"Virology Maintenance Construction Area",
			"Research Maintenance",
		),
		EXTRACTION_DIFFICULTY_MEDIUM = list(
			// Rooms
			"Mr Chang's", //new location on delta makes it unvisited enough
			"Research Testing Chamber",
			"Custodial Closet",
			"South Primary Hallway",
			"Atmospherics",
			"Hangаr Bay",
			"Arcade",
			"Assembly Line",
			"Auxiliary Tool Storage",
			"Break Room",
			"Blueshield's Office",
			"Cargo Bay",
			"Chapel",
			"Chapel Office",
			"Clown's Office",
			"Construction Area",
			"Courtroom",
			"Dormitory Toilets",
			"Engineering",
			"Engineering Control Room",
			"Escape Shuttle Hallway",
			"Experimentation Lab",
			"Holodeck Alpha",
			"Hydroponics",
			"Library",
			"Mime's Office",
			"Mining Dock",
			"Morgue",
			"Office Supplies",
			"Pet Store",
			"Primary Tool Storage",
			"Research Division",
			"Security Checkpoint",
			"Technical Storage",
			"Teleporter",
			"Toxins Storage",
			"Vacant Office",
			"Research Testing Lab",
			"Xenobiology Lab",
			// Maintenance
			"Atmospherics Maintenance",
			"Bridge Maintenance",
		),
		EXTRACTION_DIFFICULTY_HARD = list(
			// No AI Chamber because I'm not that sadistic.
			// Most Bridge areas are excluded because of they'd be basically impossible. So are Brig areas.
			"AI Satellite Antechamber",
			"AI Satellite Atmospherics",
			"AI Satellite Service",
			"AI Satellite Hallway",
			"Bar",
			"Cargo Delivery",
			"Delivery Office",
			"Cargo Office",
			"Central Primary Hallway",
			"Chemistry",
			"Chief Engineer's office",
			"Chief Medical Officer's office",
			"Cloning Lab",
			"Cryogenics",
			"Dorms",
			"Engineering Equipment Storage",
			"Engineering Foyer",
			"EVA Storage",
			"Gateway",
			"Genetics Lab",
			"Gravity Generator",
			"Head of Personnel's Office",
			"Heads of Staff Meeting Room",
			"Kitchen", // Chef CQC is no joke.
			"Mech Bay",
			"Medbay",
			"Medbay Reception",
			"Medical Storage",
			"Medical Treatment Center",
			"Medbay Patient Ward",
			"Messaging Server Room",
			"Server Room",
			"Nanotrasen Representative's Office",
			"Paramedic",
			"West Primary Hallway",
			"Quartermaster's Office",
			"Research Director's Office",
			"Research and Development",
			"Robotics Lab",
			"Surgery 1",
			"Surgery 2",
			"Telecoms Central Compartment",
			"Secure Storage",
			"Arrivals Lounge",
			"Atrium",
			"Service Yard",
			"RnD North Hallway",
			"Engineering Hardsuit Storage",
		),
	)
	// Variables
	/// The designated area where the kidnapee must be extracted to complete the objective.
	var/area/extraction_zone = null
	/// The contract's difficulty. Determines the reward on completion.
	var/chosen_difficulty = EXTRACTION_DIFFICULTY_EASY
	/// Associated lazy list of areas the contractor can pick from and extract the kidnapee there.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => /area
	var/list/area/candidate_zones = null
	/// List of people who cannot be selected as contract target.
	var/list/datum/mind/target_blacklist = null
	/// Static list that is basically [/datum/objective/contract/var/possible_zone_names] but with area names replaced by /area objects if available.
	var/static/list/possible_zones = null
	/// The owning [/datum/syndicatce_contract].
	var/datum/syndicate_contract/owning_contract = null
	/// Name fixer regex because area names have rogue characters sometimes.
	var/static/regex/name_fixer = regex("(\[a-z0-9 \\'\]+)$", "ig")

/datum/objective/contract/New(contract)
	owning_contract = contract
	// Init static variable
	if(!possible_zones)
		// Compute the list of all zones by their name first
		var/list/all_areas_by_name = list()
		for(var/area/A in GLOB.areas)
			if(A.outdoors || !is_station_level(A.z))
				continue
			var/i = findtext(A.map_name, name_fixer)
			if(i)
				var/clean_name = copytext(A.map_name, i)
				clean_name = replacetext(clean_name, "\\", "")
				all_areas_by_name[clean_name] = A

		possible_zones = list()
		for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
			var/list/difficulty_areas = list()
			for(var/area_name in possible_zone_names[difficulty])
				var/area/A = all_areas_by_name[area_name]
				if(!A)
					continue
				difficulty_areas += A
			possible_zones += list(difficulty_areas)
	// Select zones
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		pick_candidate_zone(difficulty)
	return ..()

/datum/objective/contract/is_invalid_target(datum/mind/possible_target)
	if((possible_target.assigned_role in forbidden_jobs) || (target_blacklist && (possible_target in target_blacklist)))
		return TARGET_INVALID_BLACKLISTED
	return ..()

/datum/objective/contract/on_target_cryo()
	if(owning_contract.status in list(CONTRACT_STATUS_COMPLETED, CONTRACT_STATUS_FAILED))
		return
	// We pick the target ourselves so we don't want the default behaviour.
	owning_contract.invalidate()

/**
  * Assigns a randomly selected zone to the contract's selectable zone at the given difficulty.
  *
  * Arguments:
  * * difficulty - The difficulty to assign.
  */
/datum/objective/contract/proc/pick_candidate_zone(difficulty = EXTRACTION_DIFFICULTY_EASY)
	if(!candidate_zones)
		candidate_zones = list(null, null, null)
	candidate_zones[difficulty] = pick(possible_zones[difficulty])

/**
  * Updates the objective's information with the given difficulty.
  *
  * Arguments:
  * * difficulty - The chosen difficulty.
  * * S - The parent [/datum/syndicate_contract].
  */
/datum/objective/contract/proc/choose_difficulty(difficulty = EXTRACTION_DIFFICULTY_EASY, datum/syndicate_contract/S)
	. = FALSE
	if(!ISINDEXSAFE(candidate_zones, difficulty))
		return

	var/area/A = candidate_zones[difficulty]
	extraction_zone = A
	chosen_difficulty = difficulty
	explanation_text = "Kidnap [S.target_name] by any means and extract them in [A.map_name] using your Contractor Uplink. You will earn [S.reward_tc[difficulty]] telecrystals and [S.reward_credits] credits upon completion. Your reward will be severely reduced if your target is dead."
	return TRUE

/**
  * Returns whether the extraction process can be started.
  *
  * Arguments:
  * * caller - The person trying to call the extraction.
  */
/datum/objective/contract/proc/can_start_extraction_process(mob/living/carbon/human/caller)
	return get_area(caller) == extraction_zone && get_area(target.current) == extraction_zone
