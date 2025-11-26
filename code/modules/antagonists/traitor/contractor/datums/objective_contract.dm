/**
 * # Contract Objective
 *
 * Describes the target to kidnap and the extraction area of a [/datum/syndicate_contract].
 */
/datum/objective/contract
	antag_menu_name = "Контракт"
	// Settings
	/// Jobs that cannot be the kidnapping target.
	var/static/list/forbidden_jobs = list(
		JOB_TITLE_CAPTAIN,
	)
	/// Whitelist of /area types that can be used as extraction zones, grouped by difficulty.
	/// An area's difficulty should be measured in how crowded it generally is, how out of the way it is and so on.
	/// Outdoor or invalid areas are filtered out.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => list(/area/type/path)
	var/static/list/possible_zone_types = list(
		EXTRACTION_DIFFICULTY_EASY = list(
			// Rooms
			/area/hallway/secondary/entry/commercial,
			/area/hallway/secondary/entry/additional,
			/area/maintenance/consarea,
			/area/civilian/barber,
			/area/maintenance/trading,
			/area/maintenance/casino,
			/area/maintenance/banya,
			/area/engineering/mechanic_workshop/expedition,
			/area/crew_quarters/trading,
			/area/maintenance/kitchen,
			/area/maintenance/detectives_office,
			/area/escapepodbay,
			/area/crew_quarters/theatre,
			/area/hallway/secondary/garden,
			/area/maintenance/garden,
			/area/maintenance/incinerator,
			/area/crew_quarters/locker,
			/area/crew_quarters/locker/locker_toilet,
			/area/maintenance/bar,
			/area/medical/cmostore,
			/area/engineering/mechanic_workshop,
			/area/storage/emergency2,
			/area/medical/psych,
			/area/toxins/launch,
			/area/toxins/mixing,
			/area/maintenance/turbine,
			/area/medical/virology,
			/area/maintenance/disposal,
			/area/hallway/secondary/exit/maint,
			/area/maintenance/library,
			/area/medical/research/restroom,
			/area/teleporter/abandoned,
			// Maintenance
			/area/maintenance/portsolar,
			/area/maintenance/starboardsolar,
			/area/maintenance/fsmaint2,
			/area/maintenance/apmaint,
			/area/maintenance/fsmaint,
			/area/maintenance/electrical,
			/area/maintenance/engineering,
			/area/maintenance/fpmaint,
			/area/maintenance/auxsolarport,
			/area/maintenance/auxsolarstarboard,
			/area/maintenance/genetics,
			/area/maintenance/asmaint,
			/area/maintenance/asmaint2,
			/area/maintenance/fore,
			/area/maintenance/starboard,
			/area/maintenance/asmaint4,
			/area/maintenance/asmaint3б
		),
		EXTRACTION_DIFFICULTY_MEDIUM = list(
			// Rooms
			/area/crew_quarters/mrchangs,
			/area/toxins/test_chamber,
			/area/janitor,
			/area/hallway/primary/aft,
			/area/atmos,
			/area/engineering/mechanic_workshop/hangar,
			/area/crew_quarters/arcade,
			/area/assembly/assembly_line,
			/area/storage/tools,
			/area/crew_quarters/cafeteria,
			/area/blueshield,
			/area/quartermaster/storage,
			/area/chapel/main,
			/area/chapel/office,
			/area/clownoffice,
			/area/construction,
			/area/crew_quarters/courtroom,
			/area/crew_quarters/toilet,
			/area/engineering,
			/area/engineering/controlroom,
			/area/hallway/secondary/exit,
			/area/toxins/explab_chamber,
			/area/holodeck/alphadeck,
			/area/hydroponics,
			/area/library,
			/area/mimeoffice,
			/area/quartermaster/miningdock,
			/area/medical/morgue,
			/area/storage/office,
			/area/civilian/pet_store,
			/area/storage/primary,
			/area/toxins/lab,
			/area/security/checkpoint,
			/area/storage/tech,
			/area/teleporter,
			/area/toxins/storage,
			/area/civilian/vacantoffice,
			/area/toxins/misc_lab,
			/area/toxins/xenobiology,
			// Maintenance
			/area/maintenance/atmospherics,
			/area/maintenance/maintcentral,
		),
		EXTRACTION_DIFFICULTY_HARD = list(
			/area/turret_protected/aisat_interior,
			/area/aisat/atmospherics,
			/area/turret_protected/aisat_interior/secondary,
			/area/aisat/aihallway,
			/area/crew_quarters/bar,
			/area/quartermaster/delivery,
			/area/quartermaster/sorting,
			/area/quartermaster/office,
			/area/hallway/primary/central,
			/area/medical/chemistry,
			/area/crew_quarters/chief,
			/area/medical/cmo,
			/area/medical/cloning,
			/area/medical/cryo,
			/area/crew_quarters/dorms,
			/area/engineering/equipmentstorage,
			/area/engineering/break_room,
			/area/storage/eva,
			/area/gateway,
			/area/medical/genetics,
			/area/engineering/gravitygenerator,
			/area/crew_quarters/heads,
			/area/bridge/meeting_room,
			/area/crew_quarters/kitchen,
			/area/assembly/chargebay,
			/area/medical/medbay,
			/area/medical/reception,
			/area/medical/biostorage,
			/area/medical/sleeper,
			/area/medical/ward,
			/area/server,
			/area/toxins/server,
			/area/ntrep,
			/area/medical/paramedic,
			/area/hallway/primary/port,
			/area/quartermaster/qm,
			/area/toxins/rdoffice,
			/area/toxins/lab,
			/area/assembly/robotics,
			/area/medical/surgery/north,
			/area/medical/surgery/south,
			/area/tcommsat/chamber,
			/area/storage/secure,
			/area/hallway/secondary/entry/lounge,
			/area/crew_quarters/bar/atrium,
			/area/crew_quarters/serviceyard,
			/area/medical/research/nhallway,
			/area/engineering/hardsuitstorage,
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
	/// The owning [/datum/syndicatce_contract].
	var/datum/syndicate_contract/owning_contract = null

/datum/objective/contract/New(contract)
	owning_contract = contract

	if(!candidate_zones)
		candidate_zones = list(null, null, null)

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
	var/list/allowed_types = possible_zone_types[difficulty]
	if(!allowed_types || !allowed_types.len)
		return

	var/area_type = pick(allowed_types)

	// Находим реальную зону этого типа на станции (любую)
	var/area/real_zone = locate(area_type) in GLOB.areas
	if(!real_zone)
		// Если такой зоны нет на карте — попробуем найти подтип
		for(var/area/A in GLOB.areas)
			if(istype(A, area_type) && !A.outdoors && is_station_level(A.z))
				real_zone = A
				break

	candidate_zones[difficulty] = real_zone

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
	if(!A)
		return FALSE

	extraction_zone = A
	chosen_difficulty = difficulty
	explanation_text = "Похитьте [S.target_name] любым способом и экспортируйте его в локацию \"[A.map_name]\" с помощью аплинка. По завершении контракта вы заработаете [S.reward_tc[difficulty]] телекристалл[DECL_CREDIT(S.reward_tc[difficulty])] и [S.reward_credits] кредит[DECL_CREDIT(S.reward_credits)]. Награда будет значительно уменьшена, если ваша цель окажется мёртвой."
	return TRUE

/**
 * Returns whether the extraction process can be started.
 *
 * Arguments:
 * * requester - The person trying to call the extraction.
 */
/datum/objective/contract/proc/can_start_extraction_process(mob/living/carbon/human/requester)
	return get_area(requester) == extraction_zone && get_area(target.current) == extraction_zone
