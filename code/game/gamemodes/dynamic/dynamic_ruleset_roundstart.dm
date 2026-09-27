/datum/dynamic_ruleset/roundstart
	repeatable = TRUE
	var/solo = FALSE

/datum/dynamic_ruleset/roundstart/traitor
	name = "Traitors"
	config_tag = "roundstart traitor"
	antag_role = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_TRAITOR
	weight = 10
	min_pop = 5
	max_antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/traitor/assign_role(datum/mind/candidate)
	var/datum/antagonist/traitor/new_antag = new
	new_antag.contractor_pending = new(candidate)
	addtimer(CALLBACK(candidate, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(1 SECONDS, 10 SECONDS))

/datum/dynamic_ruleset/roundstart/changeling
	name = "Changelings"
	config_tag = "roundstart changeling"
	antag_role = ROLE_CHANGELING
	special_role = SPECIAL_ROLE_CHANGELING
	protected_species = SPECIES_BLOCKED_FOR_CHANGELING
	weight = 5
	min_pop = 15
	max_antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/changeling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/changeling)

/datum/dynamic_ruleset/roundstart/vampire
	name = "Vampires"
	config_tag = "roundstart vampire"
	antag_role = ROLE_VAMPIRE
	special_role = SPECIAL_ROLE_VAMPIRE
	protected_species = SPECIES_BLOCKED_FOR_VAMPIRE
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 5
	min_pop = 15
	max_antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/vampire/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/vampire/new_vampire)

/datum/dynamic_ruleset/roundstart/thief
	name = "Thieves"
	config_tag = "roundstart thief"
	antag_role = ROLE_THIEF
	special_role = SPECIAL_ROLE_THIEF
	preferred_species = list(SPECIES_VOX = 4)
	weight = 6
	min_pop = 5
	max_antag_cap = list("denominator" = 29)

/datum/dynamic_ruleset/roundstart/thief/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/thief)

/datum/dynamic_ruleset/roundstart/heretic
	name = "Heretics"
	config_tag = "roundstart heretic"
	antag_role = ROLE_HERETIC
	special_role = SPECIAL_ROLE_HERETIC
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN)
	weight = 5
	min_pop = 30
	max_antag_cap = list("denominator" = 24)

/datum/dynamic_ruleset/roundstart/heretic/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/heretic)

/datum/dynamic_ruleset/roundstart/hijacker
	name = "Hijacker"
	config_tag = "roundstart hijacker"
	antag_role = ROLE_HIJACKER
	special_role = SPECIAL_ROLE_TRAITOR
	weight = 4
	min_pop = 20
	max_antag_cap = 1

/datum/dynamic_ruleset/roundstart/hijacker/assign_role(datum/mind/candidate)
	var/datum/antagonist/traitor/hijacker = new
	hijacker.is_hijacker = TRUE
	hijacker.contractor_pending = new(candidate)
	addtimer(CALLBACK(candidate, TYPE_PROC_REF(/datum/mind, add_antag_datum), hijacker), rand(1 SECONDS, 10 SECONDS))

/datum/dynamic_ruleset/roundstart/prisoner
	name = "Escaping Prisoners"
	config_tag = "roundstart prisoner"
	antag_role = ROLE_ESCAPING_PRISONER
	special_role = SPECIAL_ROLE_ESCAPING_PRISONER
	required_job_rank = JOB_TITLE_PRISONER
	weight = 4
	min_pop = 15
	max_antag_cap = ROLE_PRISONERS_MAX_COUNT

/datum/dynamic_ruleset/roundstart/prisoner/prepare_for_role(datum/mind/candidate)
	SSjobs.forced_occupations[candidate] = JOB_TITLE_PRISONER

/datum/dynamic_ruleset/roundstart/prisoner/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/traitor/prisoner)

/datum/dynamic_ruleset/roundstart/malf_ai
	name = "Malfunctioning AI"
	config_tag = "roundstart malf ai"
	antag_role = ROLE_MALF_AI
	special_role = SPECIAL_ROLE_MALFAI
	required_job_rank = JOB_TITLE_AI
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	max_antag_cap = 1
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/malf_ai/can_be_selected()
	return CONFIG_GET(flag/allow_ai)

/datum/dynamic_ruleset/roundstart/malf_ai/prepare_for_role(datum/mind/candidate)
	SSjobs.forced_occupations[candidate] = JOB_TITLE_AI

/datum/dynamic_ruleset/roundstart/malf_ai/assign_role(datum/mind/candidate)
	addtimer(CALLBACK(candidate, TYPE_PROC_REF(/datum/mind, add_antag_datum), /datum/antagonist/malf_ai), rand(1 SECONDS, 10 SECONDS))

/datum/dynamic_ruleset/roundstart/blood_cult
	name = "Blood Cult"
	config_tag = "roundstart blood cult"
	antag_role = ROLE_CULTIST
	special_role = SPECIAL_ROLE_CULTIST
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 3
	max_antag_cap = list("denominator" = CULT_PLAYER_PER_CULTIST, "offset" = 2)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/blood_cult/prepare_execution(population_size)
	. = ..()
	if(!.)
		return
	var/datum/team/blood_cult/cult_team = create_antag_team(/datum/team/blood_cult)
	cult_team.sets_round_result = TRUE
	cult_team.ghost_summons = floor(population_size / GHOST_SUMMONS_PER_READY)

/datum/dynamic_ruleset/roundstart/blood_cult/execute()
	var/datum/team/blood_cult/cult_team = get_blood_cult_team()
	cult_team.cult_objs.setup()
	. = ..()
	cult_team.cult_threshold_check()
	addtimer(CALLBACK(cult_team, TYPE_PROC_REF(/datum/team/blood_cult, cult_threshold_check)), 2 MINUTES)

/datum/dynamic_ruleset/roundstart/blood_cult/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/cult)
	SSticker.mode.equip_cultist(candidate.current)
	get_blood_cult_team().cult_objs.study(candidate.current)

/datum/dynamic_ruleset/roundstart/clockwork_cult
	name = "Clockwork Cult"
	config_tag = "roundstart clockwork cult"
	antag_role = ROLE_CLOCKER
	special_role = SPECIAL_ROLE_CLOCKER
	blacklisted_roles = list(JOB_TITLE_CHAPLAIN, JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 3
	max_antag_cap = list("denominator" = RATVAR_PLAYER_PER_CULTIST, "offset" = 2)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/clockwork_cult/prepare_execution(population_size)
	. = ..()
	if(!.)
		return
	var/datum/team/clockwork_cult/clock_team = create_antag_team(/datum/team/clockwork_cult)
	clock_team.sets_round_result = TRUE

/datum/dynamic_ruleset/roundstart/clockwork_cult/execute()
	var/datum/team/clockwork_cult/clock_team = get_clockwork_cult_team()
	clock_team.clocker_objs.setup()
	. = ..()
	clock_team.clockwork_threshold_check()
	addtimer(CALLBACK(clock_team, TYPE_PROC_REF(/datum/team/clockwork_cult, clockwork_threshold_check)), 2 MINUTES)

/datum/dynamic_ruleset/roundstart/clockwork_cult/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/clockwork)
	SSticker.mode.equip_clocker(candidate.current)
	get_clockwork_cult_team().clocker_objs.study(candidate.current)

/datum/dynamic_ruleset/roundstart/revolution
	name = "Revolution"
	config_tag = "roundstart revolution"
	antag_role = ROLE_REV
	special_role = SPECIAL_ROLE_HEAD_REV
	blacklisted_roles = list(JOB_TITLE_LAWYER)
	always_protect_roles = TRUE
	ruleset_flags = RULESET_HIGH_IMPACT
	min_pop = 20
	max_antag_cap = MAX_HEAD_REVOLUTIONARIES
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/revolution/execute()
	var/list/datum/mind/heads = SSticker.mode.get_living_heads()
	var/list/datum/mind/sec = SSticker.mode.get_living_sec()
	var/weighted_score = clamp(round(length(heads) - ((8 - length(sec)) / 3)), 1, MAX_HEAD_REVOLUTIONARIES)
	while(weighted_score < length(selected_minds))
		var/datum/mind/demoted = pick(selected_minds)
		demoted.special_role = null
		selected_minds -= demoted
	return ..()

/datum/dynamic_ruleset/roundstart/revolution/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/rev/head)

/datum/dynamic_ruleset/roundstart/shadowling
	name = "Shadowlings"
	config_tag = "roundstart shadowling"
	antag_role = ROLE_SHADOWLING
	special_role = SPECIAL_ROLE_SHADOWLING
	blacklisted_roles = list(JOB_TITLE_LAWYER)
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 3
	max_antag_cap = list("denominator" = 14, "offset" = 0)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/shadowling/prepare_execution(population_size)
	. = ..()
	if(!.)
		return
	var/datum/team/shadowling/shadowlings = get_shadowling_team()
	shadowlings.sets_round_result = TRUE

/datum/dynamic_ruleset/roundstart/shadowling/assign_role(datum/mind/candidate)
	candidate.add_antag_datum(/datum/antagonist/shadowling)

/datum/dynamic_ruleset/roundstart/blob
	name = "Blobs"
	config_tag = "roundstart blob"
	antag_role = ROLE_BLOB
	special_role = SPECIAL_ROLE_BLOB
	protected_species = BLOB_RESTRICTED_SPECIES
	ruleset_flags = RULESET_HIGH_IMPACT
	min_pop = 30
	max_antag_cap = list("denominator" = BLOB_PLAYERS_PER_CORE, "offset" = 0)
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/blob/assign_role(datum/mind/candidate)
	var/datum_type = candidate.get_blob_infected_type()
	var/datum/antagonist/blob_infected/blob_datum = new datum_type()
	blob_datum.need_new_blob = TRUE
	blob_datum.time_to_burst_hight = TIME_TO_BURST_HIGHT
	blob_datum.time_to_burst_low = TIME_TO_BURST_LOW
	candidate.add_antag_datum(blob_datum)

/datum/dynamic_ruleset/roundstart/wizard
	name = "Wizard"
	config_tag = "roundstart wizard"
	antag_role = ROLE_WIZARD
	special_role = SPECIAL_ROLE_WIZARD
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 20
	max_antag_cap = 1
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/wizard/can_be_selected()
	return length(GLOB.wizardstart)

/datum/dynamic_ruleset/roundstart/wizard/prepare_for_role(datum/mind/candidate)
	candidate.assigned_role = SPECIAL_ROLE_WIZARD
	candidate.offstation_role = TRUE
	candidate.set_original_mob(candidate.current)
	candidate.current.forceMove(pick(GLOB.wizardstart))

/datum/dynamic_ruleset/roundstart/wizard/assign_role(datum/mind/candidate)
	SSticker.mode.forge_wizard_objectives(candidate)
	SSticker.mode.equip_wizard(candidate.current)
	INVOKE_ASYNC(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, name_wizard), candidate.current)
	candidate.add_antag_datum(/datum/antagonist/wizard)

/datum/dynamic_ruleset/roundstart/nuclear
	name = "Nuclear Operatives"
	config_tag = "roundstart nuclear"
	antag_role = ROLE_OPERATIVE
	special_role = SPECIAL_ROLE_NUKEOPS
	ruleset_flags = RULESET_HIGH_IMPACT
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 30
	min_antag_cap = 2
	max_antag_cap = NUKERS_COUNT
	repeatable = FALSE
	var/spawn_index = 1

/datum/dynamic_ruleset/roundstart/nuclear/can_be_selected()
	return length(GLOB.nukespawn)

/datum/dynamic_ruleset/roundstart/nuclear/prepare_for_role(datum/mind/candidate)
	candidate.assigned_role = SPECIAL_ROLE_NUKEOPS

/datum/dynamic_ruleset/roundstart/nuclear/create_execute_args()
	return list(create_antag_team(/datum/team/nuclear_team))

/datum/dynamic_ruleset/roundstart/nuclear/execute()
	. = ..()
	var/datum/team/nuclear_team/team = GLOB.antagonist_teams[/datum/team/nuclear_team]
	team?.scale_telecrystals()

/datum/dynamic_ruleset/roundstart/nuclear/assign_role(datum/mind/candidate, datum/team/nuclear_team/team)
	candidate.current.forceMove(GLOB.nukespawn[spawn_index])
	spawn_index = (spawn_index % length(GLOB.nukespawn)) + 1
	create_syndicate(candidate)
	team.add_member(candidate)
	var/datum/antagonist/nuclear_operative/operative = candidate.has_antag_datum(/datum/antagonist/nuclear_operative)
	operative.equip()

/datum/dynamic_ruleset/roundstart/space_ninja
	name = "Space Ninja"
	config_tag = "roundstart space ninja"
	antag_role = ROLE_NINJA
	special_role = SPECIAL_ROLE_SPACE_NINJA
	weight = alist(
		DYNAMIC_TIER_LOW = 0,
		DYNAMIC_TIER_LOWMEDIUM = 1,
		DYNAMIC_TIER_MEDIUMHIGH = 3,
		DYNAMIC_TIER_HIGH = 3,
	)
	min_pop = 25
	max_antag_cap = 1
	repeatable = FALSE

/datum/dynamic_ruleset/roundstart/space_ninja/can_be_selected()
	return length(GLOB.ninjastart)

/datum/dynamic_ruleset/roundstart/space_ninja/prepare_for_role(datum/mind/candidate)
	candidate.assigned_role = SPECIAL_ROLE_SPACE_NINJA
	candidate.offstation_role = TRUE
	candidate.set_original_mob(candidate.current)
	candidate.current.forceMove(pick(GLOB.ninjastart))

/datum/dynamic_ruleset/roundstart/space_ninja/assign_role(datum/mind/candidate)
	var/datum/antagonist/ninja/ninja_datum = new
	ninja_datum.change_species(candidate.current)
	candidate.add_antag_datum(ninja_datum)
