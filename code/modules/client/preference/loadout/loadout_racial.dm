/datum/gear/racial
	sort_category = "Racial"
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
		to_chat(cl, span_warning("Ваш вид не подходит для того, чтобы использовать \"[index_name]\"!"))

	return FALSE


/datum/gear/racial/get_header_tips()
	return "\[Species: [english_list(whitelisted_species)]\] "


 // TAJARAN //

/datum/gear/racial/taj
	index_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	slot = ITEM_SLOT_EYES
	whitelisted_species = list(SPECIES_TAJARAN)

/datum/gear/racial/taj/job
	subtype_path = /datum/gear/racial/taj/job
	subtype_cost_overlap = FALSE
	cost = 2

/datum/gear/racial/taj/job/bot
	index_name = "veil, blooming"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built botanical HUD."
	path = /obj/item/clothing/glasses/hud/hydroponic/tajblind
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/racial/taj/job/sec
	index_name = "veil, sleek"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)

/datum/gear/racial/taj/job/iaa
	index_name = "veil, sleek(read-only)"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/racial/taj/job/med
	index_name = "veil, lightweight"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER)

/datum/gear/racial/taj/job/sci
	index_name = "veil, hi-tech"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built science goggles"
	path = /obj/item/clothing/glasses/tajblind/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST)

/datum/gear/racial/taj/job/eng
	index_name = "veil, industrial"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners and welding shields."
	path = /obj/item/clothing/glasses/tajblind/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)

/datum/gear/racial/taj/job/cargo
	index_name = "veil, khaki"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners."
	path = /obj/item/clothing/glasses/tajblind/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/racial/taj/job/diag
	index_name = "veil, diagnostic"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built diagnostic HUD."
	path = /obj/item/clothing/glasses/hud/diagnostic/tajblind
	allowed_roles = list(JOB_TITLE_ROBOTICIST, JOB_TITLE_RD)

/datum/gear/racial/taj/job/skills
	index_name = "veil, skills"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built skills HUD."
	path = /obj/item/clothing/glasses/hud/skills/tajblind
	allowed_roles = list(JOB_TITLE_HOP, JOB_TITLE_CAPTAIN)


// GREY //

/datum/gear/racial/language_chip
	index_name = "selected language chip"
	description = "Крошечный чип-переводчик с индикатором, содержащий в себе один из языков. Разработан греями, устанавливается в импланты-переводчики."
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
