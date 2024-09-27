/datum/gear/racial
	sort_category = "Racial"
	subtype_path = /datum/gear/racial
	cost = 1
	var/list/whitelisted_species

/datum/gear/racial/can_select(client/cl, job_name, species_name, silent = FALSE)
	if(!..()) // there's no point in being here.
		return FALSE

	if(!LAZYLEN(whitelisted_species)) // why are we here? allowed, but
		stack_trace("Item with no racial list in loadout racial items: [display_name].")
		return TRUE

	if(!species_name) // skip
		return TRUE

	if(species_name in whitelisted_species) // check species whitelist
		return TRUE

	if(cl && !silent)
		to_chat(cl, span_warning("Ваш вид не подходит для того, чтобы использовать \"[display_name]\"!"))

	return FALSE


/datum/gear/racial/get_header_tips()
	return "\[Species: [english_list(whitelisted_species)]\] "


/datum/gear/racial/taj
	display_name = "embroidered veil"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races."
	path = /obj/item/clothing/glasses/tajblind
	slot = ITEM_SLOT_EYES
	whitelisted_species = list(SPECIES_TAJARAN)

/datum/gear/racial/taj/job
	subtype_path = /datum/gear/racial/taj/job
	subtype_cost_overlap = FALSE
	cost = 2

/datum/gear/racial/taj/job/bot
	display_name = "veil, blooming"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built botanical HUD."
	path = /obj/item/clothing/glasses/hud/hydroponic/tajblind
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/racial/taj/job/sec
	display_name = "veil, sleek"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)

/datum/gear/racial/taj/job/iaa
	display_name = "veil, sleek(read-only)"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built security HUD."
	path = /obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/racial/taj/job/med
	display_name = "veil, lightweight"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built medical HUD."
	path = /obj/item/clothing/glasses/hud/health/tajblind
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BRIGDOC, JOB_TITLE_CORONER)

/datum/gear/racial/taj/job/sci
	display_name = "veil, hi-tech"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built science goggles"
	path = /obj/item/clothing/glasses/tajblind/sci
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST)

/datum/gear/racial/taj/job/eng
	display_name = "veil, industrial"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners and welding shields."
	path = /obj/item/clothing/glasses/tajblind/eng
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)

/datum/gear/racial/taj/job/cargo
	display_name = "veil, khaki"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built optical meson scanners."
	path = /obj/item/clothing/glasses/tajblind/cargo
	allowed_roles = list(JOB_TITLE_QUARTERMASTER, JOB_TITLE_CARGOTECH)

/datum/gear/racial/taj/job/diag
	display_name = "veil, diagnostic"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built diagnostic HUD."
	path = /obj/item/clothing/glasses/hud/diagnostic/tajblind
	allowed_roles = list(JOB_TITLE_ROBOTICIST, JOB_TITLE_RD)

/datum/gear/racial/taj/job/skills
	display_name = "veil, skills"
	description = "A common traditional nano-fiber veil worn by many Tajaran, It is rare and offensive to see it on other races. This one has an in-built skills HUD."
	path = /obj/item/clothing/glasses/hud/skills/tajblind
	allowed_roles = list(JOB_TITLE_HOP, JOB_TITLE_CAPTAIN)


