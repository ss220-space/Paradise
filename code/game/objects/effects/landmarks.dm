/obj/effect/landmark
	name = "landmark"
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "standart"
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/landmark/Initialize(mapload)
	. = ..()
	set_tag()
	GLOB.landmarks_list += src

/obj/effect/landmark/Destroy()
	GLOB.landmarks_list -= src
	tag = null
	return ..()

/obj/effect/landmark/proc/set_tag()
	tag = "landmark*[name]"

/obj/effect/landmark/ex_act()
	return

/obj/effect/landmark/singularity_pull()
	return

/obj/effect/landmark/singularity_act()
	return

/// There should only be one of these, in the lobby art area
/obj/effect/landmark/newplayer_start
	name = "start"

// Must be immediate because players will join before SSatom initializes everything.
INITIALIZE_IMMEDIATE(/obj/effect/landmark/newplayer_start)

/obj/effect/landmark/newplayer_start/Initialize(mapload)
	. = ..()
	GLOB.newplayer_start += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/spawner
	var/spawner_list

/obj/effect/landmark/spawner/Initialize(mapload)
	. = ..()
	if(!spawner_list)
		return

	spawner_list += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/lightsout
	name = "Electrical Storm Epicentre"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "lightsout"

/obj/effect/landmark/marauder_entry
	name = "Marauder Entry"
	icon_state = "marauder"

/obj/effect/landmark/marauder_exit
	name = "Marauder Exit"
	icon_state = "marauder"

/obj/effect/landmark/observer_start
	name = "Observer-Start"
	icon_state = "observer_start"

/obj/effect/landmark/awaystart
	name = "awaystart"

// Without this away missions break
INITIALIZE_IMMEDIATE(/obj/effect/landmark/awaystart)

/obj/effect/landmark/awaystart/Initialize(mapload)
	GLOB.awaydestinations.Add(src)
	return ..()

// MARK: SPAWNER
/obj/effect/landmark/spawner/wizard
	name = "wizard"
	icon_state = "wizard"

/obj/effect/landmark/spawner/wizard/Initialize(mapload)
	spawner_list = GLOB.wizardstart
	return ..()

/obj/effect/landmark/spawner/prisonwarp
	name = "prisonwarp"

/obj/effect/landmark/spawner/prisonwarp/Initialize(mapload)
	spawner_list = GLOB.prisonwarp
	return ..()

/obj/effect/landmark/spawner/syndieprisonwarp
	name = "syndieprisonwarp"

/obj/effect/landmark/spawner/syndieprisonwarp/Initialize(mapload)
	spawner_list = GLOB.syndieprisonwarp
	return ..()

/obj/effect/landmark/spawner/prisonsecuritywarp
	name = "prisonsecuritywarp"

/obj/effect/landmark/spawner/prisonsecuritywarp/Initialize(mapload)
	spawner_list = GLOB.prisonsecuritywarp
	return ..()

/obj/effect/landmark/spawner/tdome1
	name = "tdome1"

/obj/effect/landmark/spawner/tdome1/Initialize(mapload)
	spawner_list = GLOB.tdome1
	return ..()

/obj/effect/landmark/spawner/tdome2
	name = "tdome2"

/obj/effect/landmark/spawner/tdome2/Initialize(mapload)
	spawner_list = GLOB.tdome2
	return ..()

/obj/effect/landmark/spawner/tdomeadmin
	name = "tdomeadmin"

/obj/effect/landmark/spawner/tdomeadmin/Initialize(mapload)
	spawner_list = GLOB.tdomeadmin
	return ..()

/obj/effect/landmark/spawner/tdomeobserve
	name = "tdomeobserve"

/obj/effect/landmark/spawner/tdomeobserve/Initialize(mapload)
	spawner_list = GLOB.tdomeobserve
	return ..()

/obj/effect/landmark/spawner/aroomwarp
	name = "aroomwarp"

/obj/effect/landmark/spawner/aroomwarp/Initialize(mapload)
	spawner_list = GLOB.aroomwarp
	return ..()

/obj/effect/landmark/spawner/blob
	name = "blobstart"
	icon_state = "blobstart"

/obj/effect/landmark/spawner/blob/Initialize(mapload)
	spawner_list = GLOB.blobstart
	return ..()

/obj/effect/landmark/spawner/xeno
	name = "xeno_spawn"
	icon_state = "xeno_spawn"

/obj/effect/landmark/spawner/xeno/Initialize(mapload)
	spawner_list = GLOB.xeno_spawn
	return ..()

/obj/effect/landmark/spawner/ninjastart
	name = "ninjastart"
	icon_state = "ninjastart"

/obj/effect/landmark/spawner/ninjastart/Initialize(mapload)
	spawner_list = GLOB.ninjastart
	return ..()

/obj/effect/landmark/spawner/ninja_teleport
	name = "ninja_teleport"
	icon_state = "ninja_teleport"

/obj/effect/landmark/spawner/ninja_teleport/Initialize(mapload)
	spawner_list = GLOB.ninja_teleport
	return ..()

/obj/effect/landmark/spawner/carp
	name = "carpspawn"
	icon_state = "carpspawn"

/obj/effect/landmark/spawner/carp/Initialize(mapload)
	spawner_list = GLOB.carplist
	return ..()

/obj/effect/landmark/spawner/raider_spawn
	name = "voxstart"

/obj/effect/landmark/spawner/raider_spawn/Initialize(mapload)
	spawner_list = GLOB.raider_spawn
	return ..()

/obj/effect/landmark/spawner/ertdirector
	name = "ERT Director"
	icon_state = "ERT Director"

/obj/effect/landmark/spawner/ertdirector/Initialize(mapload)
	spawner_list = GLOB.ertdirector
	return ..()

/obj/effect/landmark/spawner/ert
	name = "Response Team"
	icon_state = "Response_Team"

/obj/effect/landmark/spawner/ert/Initialize(mapload)
	spawner_list = GLOB.emergencyresponseteamspawn
	return ..()

/obj/effect/landmark/spawner/syndie
	name = "Syndicate-Spawn"
	icon_state = "snukeop_spawn"

/obj/effect/landmark/spawner/syndie/Initialize(mapload)
	spawner_list = GLOB.nukespawn
	return ..()

/obj/effect/landmark/spawner/syndicateofficer
	name = "Syndicate Officer"

/obj/effect/landmark/spawner/syndicateofficer/Initialize(mapload)
	spawner_list = GLOB.syndicateofficer
	return ..()

/obj/effect/landmark/spawner/team1
	name = "team1"
	icon_state = "GREEN"

/obj/effect/landmark/spawner/team1/Initialize(mapload)
	spawner_list = GLOB.battle_teams_spawns[JOB_TITLE_TEAM1]
	return ..()

/obj/effect/landmark/spawner/team2
	name = "team2"
	icon_state = "BLUE"

/obj/effect/landmark/spawner/team2/Initialize(mapload)
	spawner_list = GLOB.battle_teams_spawns[JOB_TITLE_TEAM2]
	return ..()

/obj/effect/landmark/spawner/team3
	name = "team3"
	icon_state = "RED"

/obj/effect/landmark/spawner/team3/Initialize(mapload)
	spawner_list = GLOB.battle_teams_spawns[JOB_TITLE_TEAM3]
	return ..()

/obj/effect/landmark/spawner/airdrop
	name = "airdrop"
	icon_state = "airdrop"

/obj/effect/landmark/spawner/airdrop/Initialize(mapload)
	spawner_list = GLOB.airdrops_points
	return ..()

/obj/effect/landmark/spawner/captain
	name = "captain body"
	icon_state = "captain"

/obj/effect/landmark/spawner/captain/Initialize(mapload)
	spawner_list = GLOB.captain_body_spawns
	return ..()

/obj/effect/landmark/spawner/armory
	name = "armory body"
	icon_state = "armory"

/obj/effect/landmark/spawner/armory/Initialize(mapload)
	spawner_list = GLOB.armory_body_spawns
	return ..()

/obj/effect/landmark/spawner/bubblegum_arena
	name = "bubblegum_arena_human"
	icon_state = "awaystart"

/obj/effect/landmark/spawner/bubblegum
	name = "bubblegum_arena_bubblegum"
	icon_state = "bubblegumjumpscare"

/obj/effect/landmark/spawner/bubblegum_exit
	name = "bubblegum_arena_exit"
	icon_state = "bubblegumjumpscare"

/obj/effect/landmark/spawner/honk_squad
	name = "HONKsquad"
	icon_state = "HONKsquad"

/obj/effect/landmark/spawner/death_squard
	name = "Commando"
	icon_state = "death_squard"

/obj/effect/landmark/spawner/syndicate_infiltrator
	name = "Syndicate-Infiltrator"
	icon_state = "syndicate_team"

/obj/effect/landmark/spawner/syndicate_commando
	name = "Syndicate-Commando"
	icon_state = "syndicate_team"

/obj/effect/landmark/spawner/free_golem
	name = "Free Golem Spawn Point"
	icon_state = "free_golem"

/obj/effect/landmark/spawner/soltrader
	name = "traderstart_sol"
	icon_state = "traderstart_sol"

/obj/effect/landmark/spawner/holocarp
	name = "Holocarp Spawn"
	icon_state = "carpspawn"

/obj/effect/landmark/spawner/revenant
	name = "revenantspawn"
	icon_state = "revenantspawn"

/obj/effect/landmark/spawner/tripai
	name = "tripai"
	icon_state = "tripai"

/obj/effect/landmark/spawner/nuclear_bomb
	name = "Nuclear-Bomb"
	icon_state = "nuclear_bomb"

/obj/effect/landmark/spawner/teleport_scroll
	name = "Teleport-Scroll"
	icon_state = "teleport_scroll"

/obj/effect/landmark/spawner/commando_manual
	name = "Commando_Manual"
	icon_state = "codes"

/obj/effect/landmark/spawner/nuke_code
	name = "nukecode"
	icon_state = "codes"

// MARK: LATE
/obj/effect/landmark/spawner/late
	icon_state = "Late"

/obj/effect/landmark/spawner/late/crew
	name = "Late Join Crew"

/obj/effect/landmark/spawner/late/crew/Initialize(mapload)
	spawner_list = GLOB.latejoin
	return ..()

/obj/effect/landmark/spawner/late/cryo
	name = "Late Join Cryo"

/obj/effect/landmark/spawner/late/cryo/Initialize(mapload)
	spawner_list = GLOB.latejoin_cryo
	return ..()

/obj/effect/landmark/spawner/late/cyborg
	name = "Late Join Cyborg"
	icon_state = "LateBorg"

/obj/effect/landmark/spawner/late/cyborg/Initialize(mapload)
	spawner_list = GLOB.latejoin_cyborg
	return ..()

/obj/effect/landmark/spawner/late/gateway
	name = "Late Join Gateway"
	icon_state = "awaystart"

/obj/effect/landmark/spawner/late/gateway/Initialize(mapload)
	spawner_list = GLOB.latejoin_gateway
	return ..()

/obj/effect/landmark/spawner/late/prisoner
	name = "Late Join Prisoner"
	icon_state = "LatePrisoner"

/obj/effect/landmark/spawner/late/prisoner/Initialize(mapload)
	spawner_list = GLOB.latejoin_prisoner
	return ..()

// MARK: START
/obj/effect/landmark/start
	name = "start"
	layer = MOB_LAYER

/obj/effect/landmark/start/Initialize(mapload)
	. = ..()
	GLOB.start_landmarks_list += src
	if(name != "start")
		tag = "start*[name]"

/obj/effect/landmark/start/Destroy()
	GLOB.start_landmarks_list -= src
	tag = null
	return ..()

/obj/effect/landmark/start/civilian
	name = JOB_TITLE_CIVILIAN
	icon_state = "Assistant"

/obj/effect/landmark/start/prisoner
	name = JOB_TITLE_PRISONER
	icon_state = "Prisoner"

/obj/effect/landmark/start/chief_engineer
	name = JOB_TITLE_CHIEF_ENGINEER
	icon_state = "CE"

/obj/effect/landmark/start/engineer
	name = JOB_TITLE_ENGINEER
	icon_state = "Engi"

/obj/effect/landmark/start/trainee_engineer
	name = JOB_TITLE_ENGINEER_TRAINEE
	icon_state = "Trainee_Engi"

/obj/effect/landmark/start/atmospheric
	name = JOB_TITLE_ATMOSTECH
	icon_state = "Atmos"

/obj/effect/landmark/start/mechanic
	name = JOB_TITLE_SPACEPOD_TECHNICIAN
	icon_state = "Mechanic"

/obj/effect/landmark/start/cmo
	name = JOB_TITLE_CMO
	icon_state = "CMO"

/obj/effect/landmark/start/doctor
	name = JOB_TITLE_DOCTOR
	icon_state = "MD"

/obj/effect/landmark/start/intern
	name = JOB_TITLE_MEDICAL_INTERN
	icon_state = "Intern"

/obj/effect/landmark/start/coroner
	name = JOB_TITLE_CORONER
	icon_state = "Coroner"

/obj/effect/landmark/start/chemist
	name = JOB_TITLE_CHEMIST
	icon_state = "Chemist"

/obj/effect/landmark/start/geneticist
	name = JOB_TITLE_GENETICIST
	icon_state = "Genetics"

/obj/effect/landmark/start/virologist
	name = JOB_TITLE_VIROLOGIST
	icon_state = "Viro"

/obj/effect/landmark/start/psychiatrist
	name = JOB_TITLE_PSYCHIATRIST
	icon_state = "Psych"

/obj/effect/landmark/start/paramedic
	name = JOB_TITLE_PARAMEDIC
	icon_state = "Paramed"

/obj/effect/landmark/start/research_director
	name = JOB_TITLE_RD
	icon_state = "RD"

/obj/effect/landmark/start/scientist
	name = JOB_TITLE_SCIENTIST
	icon_state = "Sci"

/obj/effect/landmark/start/student_sientist
	name = JOB_TITLE_SCIENCE_STUDENT
	icon_state = "Student_Sci"

/obj/effect/landmark/start/roboticist
	name = JOB_TITLE_ROBOTICIST
	icon_state = "Robo"

/obj/effect/landmark/start/head_of_security
	name = JOB_TITLE_HOS
	icon_state = "HoS"

/obj/effect/landmark/start/warden
	name = JOB_TITLE_WARDEN
	icon_state = "Warden"

/obj/effect/landmark/start/detective
	name = JOB_TITLE_DETECTIVE
	icon_state = "Det"

/obj/effect/landmark/start/security_officer
	name = JOB_TITLE_OFFICER
	icon_state = "Sec"

/obj/effect/landmark/start/brig_physician
	name = JOB_TITLE_BRIGDOC
	icon_state = "Brig_MD"

/obj/effect/landmark/start/security_pod_pilot
	name = JOB_TITLE_PILOT
	icon_state = "Security_Pod"

/obj/effect/landmark/start/ai
	name = JOB_TITLE_AI
	icon_state = "AI"

/obj/effect/landmark/start/cyborg
	name = JOB_TITLE_CYBORG
	icon_state = "Borg"

/obj/effect/landmark/start/captain
	name = JOB_TITLE_CAPTAIN
	icon_state = "Cap"

/obj/effect/landmark/start/hop
	name = JOB_TITLE_HOP
	icon_state = "HoP"

/obj/effect/landmark/start/nanotrasen_rep
	name = JOB_TITLE_REPRESENTATIVE
	icon_state = "NTR"

/obj/effect/landmark/start/blueshield
	name = JOB_TITLE_BLUESHIELD
	icon_state = "BS"

/obj/effect/landmark/start/magistrate
	name = JOB_TITLE_MAGISTRATE
	icon_state = "Magi"

/obj/effect/landmark/start/lawyer
	name = JOB_TITLE_LAWYER
	icon_state = "IAA"

/obj/effect/landmark/start/bartender
	name = JOB_TITLE_BARTENDER
	icon_state = "Bartender"

/obj/effect/landmark/start/chef
	name = JOB_TITLE_CHEF
	icon_state = "Chef"

/obj/effect/landmark/start/botanist
	name = JOB_TITLE_BOTANIST
	icon_state = "Botanist"

/obj/effect/landmark/start/quartermaster
	name = JOB_TITLE_QUARTERMASTER
	icon_state = "QM"

/obj/effect/landmark/start/cargo_technician
	name = JOB_TITLE_CARGOTECH
	icon_state = "Cargo_Tech"

/obj/effect/landmark/start/shaft_miner
	name = JOB_TITLE_MINER
	icon_state = "Miner"

/obj/effect/landmark/start/mining_medic
	name = JOB_TITLE_MINING_MEDIC
	icon_state = "Mining_medic"

/obj/effect/landmark/start/clown
	name = JOB_TITLE_CLOWN
	icon_state = "Clown"

/obj/effect/landmark/start/mime
	name = JOB_TITLE_MIME
	icon_state = "Mime"

/obj/effect/landmark/start/janitor
	name = JOB_TITLE_JANITOR
	icon_state = "Jani"

/obj/effect/landmark/start/librarian
	name = JOB_TITLE_LIBRARIAN
	icon_state = "Librarian"

/obj/effect/landmark/start/chaplain
	name = JOB_TITLE_CHAPLAIN
	icon_state = "Chap"

// MARK: COSTUME
/// Costume spawner, selects a random subclass and disappears
/obj/effect/landmark/costume/random/Initialize(mapload)
	. = ..()
	var/list/options = (typesof(/obj/effect/landmark/costume) - /obj/effect/landmark/costume/random)
	var/pick_option = options[rand(1, length(options))]
	new pick_option(loc)
	return INITIALIZE_HINT_QDEL

// SUBCLASSES. Spawn a bunch of items and disappear likewise.
/obj/effect/landmark/costume/chicken/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/chickensuit(loc)
	new /obj/item/clothing/head/chicken(loc)
	new /obj/item/reagent_containers/food/snacks/egg(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/gladiator/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/gladiator(loc)
	new /obj/item/clothing/head/helmet/gladiator(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/madscientist/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/suit/storage/labcoat/mad(loc)
	new /obj/item/clothing/glasses/gglasses(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/elpresidente/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/gimmick/rank/captain/suit(loc)
	new /obj/item/clothing/head/flatcap(loc)
	new /obj/item/clothing/mask/cigarette/cigar/havana(loc)
	new /obj/item/clothing/shoes/jackboots(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/nyangirl/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/schoolgirl(loc)
	new /obj/item/clothing/head/kitty(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/maid/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/blackskirt(loc)
	var/choice = pick(
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/rabbitears,
	)
	new choice(loc)
	new /obj/item/clothing/glasses/sunglasses/blindfold/black(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/butler/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wcoat(loc)
	new /obj/item/clothing/under/suit_jacket(loc)
	new /obj/item/clothing/head/that(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/scratch/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/gloves/color/white(loc)
	new /obj/item/clothing/shoes/color/white(loc)
	new /obj/item/clothing/under/scratch(loc)
	if(prob(30))
		new /obj/item/clothing/head/cueball(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/highlander/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/kilt(loc)
	new /obj/item/clothing/head/beret(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/prig/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wcoat(loc)
	new /obj/item/clothing/glasses/monocle(loc)
	var/choice= pick(
		/obj/item/clothing/head/bowlerhat,
		/obj/item/clothing/head/that,
	)
	new choice(loc)
	new /obj/item/clothing/shoes/color/black(loc)
	new /obj/item/cane(loc)
	new /obj/item/clothing/under/sl_suit(loc)
	new /obj/item/clothing/mask/fakemoustache(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/plaguedoctor/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/bio_suit/plaguedoctorsuit(loc)
	new /obj/item/clothing/head/plaguedoctorhat(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/nightowl/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/owl(loc)
	new /obj/item/clothing/mask/gas/owl_mask(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/waiter/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/waiter(loc)
	var/choice= pick(
		/obj/item/clothing/head/kitty,
		/obj/item/clothing/head/rabbitears,
	)
	new choice(loc)
	new /obj/item/clothing/suit/apron(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/pirate/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/pirate(loc)
	new /obj/item/clothing/suit/pirate_black(loc)
	var/choice = pick(
		/obj/item/clothing/head/pirate,
		/obj/item/clothing/head/bandana,
	)
	new choice(loc)
	new /obj/item/clothing/glasses/eyepatch(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/commie/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/soviet(loc)
	new /obj/item/clothing/head/ushanka(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/imperium_monk/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/imperium_monk(loc)
	if(prob(25))
		new /obj/item/clothing/mask/gas/cyborg(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/holiday_priest/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/holidaypriest(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/marisawizard/fake/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/head/wizard/marisa/fake(loc)
	new /obj/item/clothing/suit/wizrobe/marisa/fake(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/cutewitch/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/under/sundress(loc)
	new /obj/item/clothing/head/witchwig(loc)
	new /obj/item/twohanded/staff/broom(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/fakewizard/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/wizrobe/fake(loc)
	new /obj/item/clothing/head/wizard/fake(loc)
	new /obj/item/twohanded/staff/(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexyclown/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/mask/gas/clown_hat/sexy(loc)
	new /obj/item/clothing/under/rank/clown/sexy(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/costume/sexymime/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/mask/gas/mime/sexy(loc)
	new /obj/item/clothing/under/sexymime(loc)
	return INITIALIZE_HINT_QDEL

// MARK: RUIN
/obj/effect/landmark/ruin
	var/datum/map_template/ruin/ruin_template

/obj/effect/landmark/ruin/Initialize(mapload, my_ruin_template)
	. = ..()
	name = "ruin_[length(GLOB.ruin_landmarks) + 1]"
	ruin_template = my_ruin_template
	GLOB.ruin_landmarks |= src

/obj/effect/landmark/ruin/Destroy()
	GLOB.ruin_landmarks -= src
	ruin_template = null
	return ..()

// MARK: OVERRIDE (shit)
/obj/effect/landmark/start_override
	name = "start_override"
	icon_state = "start_override"
	var/datum/outfit/connected_outfit = null

/obj/effect/landmark/start_override/Initialize(mapload)
	. = ..()
	GLOB.start_override += loc
	if(connected_outfit) // It should be before, because of qdel.
		GLOB.start_override_outfit = connected_outfit

/obj/effect/landmark/start_override/Destroy()
	connected_outfit = null
	return ..()

/obj/effect/landmark/start_override/Click(location, control, params)
	. = ..()
	var/list/paths = subtypesof(/datum/outfit)
	for(var/datum/outfit/outfit as anything in paths)
		if(!outfit.can_be_admin_equipped)
			return

		paths[initial(outfit.name)] = outfit

	paths["Одежда выбранной игроком профессии"] = null
	var/selected_outfit = tgui_input_list(usr, "Выберите набор вещей, с которым будут появляться все новые игроки.", "Выбор одежды", paths)
	if(isnull(selected_outfit))
		return

	to_chat(usr, span_boldmessage("Набор вещей, с которым будут появляться все новые игроки обновлен."))
	GLOB.start_override_outfit = new paths[selected_outfit]

/obj/effect/landmark/start_override/prisoner
	connected_outfit = /datum/outfit/job/assistant/prisoner

// MARK: Game tests
/// Marks the bottom left of the testing zone.
/obj/effect/landmark/game_test/bottom_left_corner
	name = "game test zone bottom left"

/// Marks the top right of the testing zone.
/obj/effect/landmark/game_test/top_right_corner
	name = "game test zone top right"
