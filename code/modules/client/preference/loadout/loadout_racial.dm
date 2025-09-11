/datum/gear/racial
	sort_category = "Расовое"
	subtype_path = /datum/gear/racial
	cost = 1
	var/list/whitelisted_species

/datum/gear/racial/can_select(client/cl, job_name, species_name, silent = FALSE)
	if(!..()) // there's no point in being here.
		return FALSE

	if(!LAZYLEN(whitelisted_species)) // why are we here? allowed, but
		stack_trace("Item with no racial list in loadout racial items: [index_name].")
		return TRUE

	if(!species_name) // skip
		return TRUE

	if(species_name in whitelisted_species) // check species whitelist
		return TRUE

	if(cl && !silent)
		to_chat(cl, span_warning("\"[capitalize(display_name)]\" недоступно для вашей расы!"))

	return FALSE


/datum/gear/racial/get_header_tips()
	return "\[Раса: [russian_list(whitelisted_species)]\] "


// TAJARAN //

/datum/gear/racial/taj
	index_name = "embroidered veil"
	path = /obj/item/clothing/glasses/tajblind
	slot = ITEM_SLOT_EYES
	whitelisted_species = list(SPECIES_TAJARAN)

/datum/gear/racial/taj/job
	subtype_path = /datum/gear/racial/taj/job
	subtype_cost_overlap = FALSE
	cost = 2

/datum/gear/racial/taj/job/bot
	index_name = "veil, blooming"
	path = /obj/item/clothing/glasses/hud/hydroponic/tajblind
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/racial/taj/job/sec
	index_name = "veil, sleek"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)

/datum/gear/racial/taj/job/iaa
	index_name = "veil, sleek(read-only)"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/racial/taj/job/med
	index_name = "veil, lightweight"
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER)

/datum/gear/racial/taj/job/sci
	index_name = "veil, hi-tech"
	path = /obj/item/clothing/glasses/tajblind/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST)

/datum/gear/racial/taj/job/eng
	index_name = "veil, industrial"
	path = /obj/item/clothing/glasses/tajblind/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)

/datum/gear/racial/taj/job/cargo
	index_name = "veil, khaki"
	path = /obj/item/clothing/glasses/tajblind/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/racial/taj/job/diag
	index_name = "veil, diagnostic"
	path = /obj/item/clothing/glasses/hud/diagnostic/tajblind
	allowed_roles = list(JOB_TITLE_ROBOTICIST, JOB_TITLE_RD)

/datum/gear/racial/taj/job/skills
	index_name = "veil, skills"
	path = /obj/item/clothing/glasses/hud/skills/tajblind
	allowed_roles = list(JOB_TITLE_HOP, JOB_TITLE_CAPTAIN)


// GREY //

/datum/gear/racial/language_chip
	index_name = "selected language chip"
	path = /obj/item/translator_chip/sol
	whitelisted_species = list(SPECIES_GREY)


/datum/gear/racial/language_chip/New()
	. = ..()

	var/list/available_chips = list()
	for(var/obj/item/translator_chip/chip as anything in subtypesof(/obj/item/translator_chip))
		available_chips[chip.stored_language_rus] = chip

	gear_tweaks += new /datum/gear_tweak/path(available_chips, src)


// HUMAN //

/datum/gear/racial/satan
	index_name = "Satanic clothes"
	path = /obj/item/clothing/under/satan
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/seccie
	index_name = "seccie clothes"
	path = /obj/item/clothing/under/tchaikowsky/sechighwaist
	whitelisted_species = list(SPECIES_HUMAN)
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)

/datum/gear/racial/highwaistpants
	index_name = "high waist pants"
	path = /obj/item/clothing/under/tchaikowsky/highwaistpants
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/eveningdress
	index_name = "evening dress"
	path = /obj/item/clothing/under/tchaikowsky/evening_dress
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/eveningdress/New()
	..()
	var/list/eveningdresses = list(/obj/item/clothing/under/tchaikowsky/evening_dress,
						   /obj/item/clothing/under/tchaikowsky/evening_dress/cyan)
	gear_tweaks += new /datum/gear_tweak/path(eveningdresses, src, TRUE)

/datum/gear/racial/formaldress
	index_name = "formal dress"
	path = /obj/item/clothing/under/tchaikowsky/dress
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/formaldress/New()
	..()
	var/list/formdresses = list(/obj/item/clothing/under/tchaikowsky/dress,
							/obj/item/clothing/under/tchaikowsky/dress/black)
	gear_tweaks += new /datum/gear_tweak/path(formdresses, src, TRUE)

/datum/gear/racial/baseball
	index_name = "baseball uniform"
	path = /obj/item/clothing/under/tchaikowsky/baseball
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/baseball/New()
	..()
	var/list/baseballuniform = list(/obj/item/clothing/under/tchaikowsky/baseball,
								/obj/item/clothing/under/tchaikowsky/baseball/brown)
	gear_tweaks += new /datum/gear_tweak/path(baseballuniform, src, TRUE)

/datum/gear/racial/baseballcap
	index_name = "baseball cap"
	path = /obj/item/clothing/head/tchaikowsky/baseballcap
	whitelisted_species = list(SPECIES_HUMAN)

/datum/gear/racial/baseballcap/New()
	..()
	var/list/baseballcap = list(/obj/item/clothing/head/tchaikowsky/baseballcap,
							/obj/item/clothing/head/tchaikowsky/baseballcap/brown)
	gear_tweaks += new /datum/gear_tweak/path(baseballcap, src, TRUE)
