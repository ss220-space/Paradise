/datum/gear/donor
	donator_tier = 2
	sort_category = "Donor"
	subtype_path = /datum/gear/donor

/datum/gear/donor/can_select(client/cl, job_name, species_name, silent = FALSE)
	if(!..()) // there's no point in being here
		return FALSE

	if(!donator_tier) // why are you here?.. allowed, but
		stack_trace("Item with no donator tier in loadout donor items: [index_name].")
		return TRUE

	if(!cl.prefs) // DB loading, skip this check now
		return TRUE

	if(cl?.donator_level >= donator_tier)
		return TRUE

	if(cl && !silent)
		to_chat(cl, span_warning("Для получения \"[index_name]\" необходим [donator_tier] или более высокий уровень пожертвований."))

	return FALSE


/datum/gear/donor/get_header_tips()
	return "\[Tier [donator_tier]\] "


/datum/gear/donor/ussptracksuit_black
	donator_tier = 1
	cost = 1
	index_name = "track suit (black)"
	path = /obj/item/clothing/under/ussptracksuit_black

/datum/gear/donor/ussptracksuit_white
	donator_tier = 1
	cost = 1
	index_name = "track suit (white)"
	path = /obj/item/clothing/under/ussptracksuit_white

/datum/gear/donor/kittyears
	index_name = "Kitty ears"
	path = /obj/item/clothing/head/kitty

/datum/gear/donor/leather_trenchcoat
	index_name = "Leather Trenchcoat"
	path = /obj/item/clothing/suit/storage/leather_trenchcoat/runner
	donator_tier = 2
	cost = 1

/datum/gear/donor/furgloves
	index_name = "Fur Gloves"
	path = /obj/item/clothing/gloves/furgloves

/datum/gear/donor/furboots
	index_name = "Fur Boots"
	path = /obj/item/clothing/shoes/furboots

/datum/gear/donor/noble_boot
	index_name = "Noble Boots"
	path = /obj/item/clothing/shoes/fluff/noble_boot

/datum/gear/donor/furcape
	index_name = "Fur Cape"
	path = /obj/item/clothing/neck/cloak/furcape

/datum/gear/donor/furcoat
	index_name = "Fur Coat"
	path = /obj/item/clothing/suit/furcoat

/datum/gear/donor/kamina
	index_name = "Spiky Orange-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina

/datum/gear/donor/green
	index_name = "Spiky Green-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina/green

/datum/gear/donor/threedglasses
	index_name = "Threed Glasses"
	path = /obj/item/clothing/glasses/threedglasses

/datum/gear/donor/blacksombrero
	index_name = "Black Sombrero"
	path = /obj/item/clothing/head/fluff/blacksombrero

/datum/gear/donor/guardhelm
	index_name = "Plastic Guard helm"
	path = /obj/item/clothing/head/fluff/guardhelm

/datum/gear/donor/goldtophat
	index_name = "Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat

/datum/gear/donor/goldtophat/red
	index_name = "Red Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/red

/datum/gear/donor/goldtophat/blue
	index_name = "Blue Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/blue

/datum/gear/donor/mushhat
	index_name = "Mushroom Hat"
	path = /obj/item/clothing/head/fluff/mushhat

/datum/gear/donor/furcap
	index_name = "Fur Cap"
	path = /obj/item/clothing/head/furcap

/datum/gear/donor/mouse
	index_name = "Mouse Headband"
	path = /obj/item/clothing/head/kitty/mouse

/datum/gear/donor/fawkes
	index_name = "Guy Fawkes mask"
	path = /obj/item/clothing/mask/face/fawkes

/datum/gear/donor/bigbrother
	index_name = "Spraycan Big Brother"
	path = /obj/item/toy/crayon/spraycan/paintkit/bigbrother

/datum/gear/donor/slavic
	index_name = "Spraycan Slavic"
	path = /obj/item/toy/crayon/spraycan/paintkit/slavic

/datum/gear/donor/id_decal_silver
	index_name = "Silver ID Decal"
	path = /obj/item/id_decal/silver
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_prisoner
	index_name = "Prisoner ID Decal"
	path = /obj/item/id_decal/prisoner
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_emag
	index_name = "Emag ID Decal"
	path = /obj/item/id_decal/emag
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_gold
	index_name = "Gold ID Decal"
	path = /obj/item/id_decal/gold
	donator_tier = 4
	cost = 1

/datum/gear/donor/zippolghtr
	index_name = "Zippo lighter"
	path = /obj/item/lighter/zippo
	donator_tier = 1
	cost = 1

/datum/gear/donor/strip
	subtype_path = /datum/gear/donor/strip
	subtype_cost_overlap = FALSE

/datum/gear/donor/strip/cap
	index_name = "strip, Captain"
	path = /obj/item/clothing/accessory/head_strip
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CAPTAIN)

/datum/gear/donor/strip/rd
	index_name = "strip, Research Director"
	path = /obj/item/clothing/accessory/head_strip/rd
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_RD)

/datum/gear/donor/strip/ce
	index_name = "strip, Chief Engineer"
	path = /obj/item/clothing/accessory/head_strip/ce
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/donor/strip/t4ce
	index_name = "strip, Grand Chief Engineer"
	path = /obj/item/clothing/accessory/head_strip/t4ce
	donator_tier = 4
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/donor/strip/cmo
	index_name = "strip, Chief Medical Officer"
	path = /obj/item/clothing/accessory/head_strip/cmo
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/donor/strip/hop
	index_name = "strip, Head of Personnel"
	path = /obj/item/clothing/accessory/head_strip/hop
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_HOP)

/datum/gear/donor/strip/hos
	index_name = "strip, Head of Security"
	path = /obj/item/clothing/accessory/head_strip/hos
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/donor/strip/qm
	index_name = "strip, Quartermaster"
	path = /obj/item/clothing/accessory/head_strip/qm
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/donor/strip/clown
	index_name = "strip, Clown"
	path = /obj/item/clothing/accessory/head_strip/clown
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CLOWN)

/datum/gear/donor/strip/bs
	index_name = "strip, Blueshield"
	path = /obj/item/clothing/accessory/head_strip/bs
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_BLUESHIELD)

/datum/gear/donor/strip/ntr
	index_name = "strip, NanoTrasen Representative"
	path = /obj/item/clothing/accessory/head_strip/ntr
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/donor/strip/syndi
	index_name = "strip, Syndicate"
	path = /obj/item/clothing/accessory/head_strip/syndicate
	donator_tier = 3
	cost = 1

/datum/gear/donor/strip/comrad
	index_name = "strip, SSSP"
	path = /obj/item/clothing/accessory/head_strip/comrad
	donator_tier = 3
	cost = 1

/datum/gear/donor/strip/federal
	index_name = "strip, TSF"
	path = /obj/item/clothing/accessory/head_strip/federal
	donator_tier = 3
	cost = 1

/datum/gear/donor/strip/greytide
	index_name = "strip, GreyTide"
	path = /obj/item/clothing/accessory/head_strip/greytide
	donator_tier = 3
	cost = 1

/datum/gear/donor/heartglasses
	index_name = "heart-shaped glasses, color"
	path = /obj/item/clothing/glasses/heart
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES

/datum/gear/donor/heartglasses/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/donor/heart_meson
	index_name = "Heart Meson Glasses"
	path = /obj/item/clothing/glasses/meson/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ATMOSTECH, JOB_TITLE_MECHANIC, JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC, JOB_TITLE_CAPTAIN, JOB_TITLE_ENGINEER_TRAINEE)

/datum/gear/donor/heart_science
	index_name = "Heart Science Glasses"
	path = /obj/item/clothing/glasses/science/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_SCIENTIST, JOB_TITLE_ROBOTICIST, JOB_TITLE_RD, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST, JOB_TITLE_SCIENTIST_STUDENT)

/datum/gear/donor/heart_health
	index_name = "Heart Medical Glasses"
	path = /obj/item/clothing/glasses/hud/health/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_CMO, JOB_TITLE_INTERN, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_BLUESHIELD, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_CORONER)

/datum/gear/donor/heart_diagnostic
	index_name = "Heart Diagnostic Glasses"
	path = /obj/item/clothing/glasses/hud/diagnostic/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/donor/heart_security
	index_name = "Heart Security Glasses"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_DETECTIVE, JOB_TITLE_PILOT, JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_BLUESHIELD, JOB_TITLE_JUDGE, JOB_TITLE_OFFICER)

/datum/gear/donor/heartsec_read
	index_name = "Heart Security Glasses"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/heart/read_only
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/donor/heart_hydroponic
	index_name = "Heart Hydroponic Glasses"
	path = /obj/item/clothing/glasses/hud/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_BOTANIST)

/datum/gear/donor/heart_skills
	index_name = "Heart Skills Glasses"
	path = /obj/item/clothing/glasses/hud/skills/heart
	donator_tier = 4
	cost = 2
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_BLUESHIELD, JOB_TITLE_HOP)

/datum/gear/donor/visor_security
	display_name = "Security Visor"
	index_name = "Optical Security Visor"
	path = /obj/item/clothing/glasses/hud/security/sunglasses/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_DETECTIVE, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)

/datum/gear/donor/visor_medical
	display_name = "Medical Optical Visor"
	index_name = "Optical Medical Visor"
	path = /obj/item/clothing/glasses/hud/health/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_CORONER, JOB_TITLE_CHEMIST, JOB_TITLE_GENETICIST, JOB_TITLE_VIROLOGIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_BRIGDOC)

/datum/gear/donor/visor_science
	display_name = "Scince Optical Visor"
	index_name = "Optical Science Visor"
	path = /obj/item/clothing/glasses/science/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_SCIENTIST, JOB_TITLE_RD, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST, JOB_TITLE_GENETICIST, JOB_TITLE_CHEMIST)

/datum/gear/donor/visor_diagnostic
	display_name = "Diagnostic Optical Visor"
	index_name = "Optical Diagnostic Visor"
	path = /obj/item/clothing/glasses/hud/diagnostic/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_ROBOTICIST)

/datum/gear/donor/visor_meson
	display_name = "Meson Optical Visor"
	index_name = "Optical Meson Visor"
	path = /obj/item/clothing/glasses/meson/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_ATMOSTECH, JOB_TITLE_MECHANIC, JOB_TITLE_QUARTERMASTER, JOB_TITLE_MINER, JOB_TITLE_MINING_MEDIC)

/datum/gear/donor/visor_skill
	display_name = "Skill Optical Visor"
	index_name = "Optical Skill Visor"
	path = /obj/item/clothing/glasses/hud/skills/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE, JOB_TITLE_BLUESHIELD, JOB_TITLE_HOP, JOB_TITLE_CAPTAIN)

/datum/gear/donor/visor_hydroponic
	display_name = "Hydroponic Optical Visor"
	index_name = "Optical Hydroponic Visor"
	path = /obj/item/clothing/glasses/hud/hydroponic/visor
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES
	allowed_roles = list(JOB_TITLE_BOTANIST)

/datum/gear/donor/night_dress
	index_name = "night dress, select"
	display_name = "night dress"
	description = "A classic night dress."
	cost = 1
	donator_tier = 3
	path = /obj/item/clothing/under/night_dress

/datum/gear/donor/night_dress/New()
	..()
	var/list/skirts = list("black" = /obj/item/clothing/under/night_dress,
							"darkred" = /obj/item/clothing/under/night_dress/darkred,
							"red" = /obj/item/clothing/under/night_dress/red,
							"silver" = /obj/item/clothing/under/night_dress/silver,
							"white" = /obj/item/clothing/under/night_dress/white,)
	gear_tweaks += new /datum/gear_tweak/path(skirts, src)

/datum/gear/donor/strip/cheese_badge
	index_name = "strip, Great fellow"
	path = /obj/item/clothing/accessory/head_strip/cheese_badge
	donator_tier = 4
	cost = 1
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_QUARTERMASTER, JOB_TITLE_RD, JOB_TITLE_HOS, JOB_TITLE_HOP, JOB_TITLE_CMO, JOB_TITLE_CHIEF, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_JUDGE)

/datum/gear/donor/smile_pin
	index_name = "smiling pin"
	path = /obj/item/clothing/accessory/medal/smile
	donator_tier = 4
	cost = 1

/datum/gear/donor/backpack_hiking
	donator_tier = 3
	cost = 1
	index_name = "backpack, Fancy Hiking Pack"
	path = /obj/item/storage/backpack/fluff/hiking

/datum/gear/donor/backpack_brew
	donator_tier = 3
	cost = 1
	index_name = "backpack, The brew"
	path = /obj/item/storage/backpack/fluff/thebrew

/datum/gear/donor/backpack_cat
	donator_tier = 3
	cost = 1
	index_name = "backpack, CatPack"
	path = /obj/item/storage/backpack/fluff/ssscratches_back

/datum/gear/donor/backpack_voxcaster
	donator_tier = 3
	cost = 1
	index_name = "backpack, Voxcaster"
	path = /obj/item/storage/backpack/fluff/krich_back

/datum/gear/donor/backpack_syndi
	donator_tier = 3
	cost = 1
	index_name = "backpack, Military Satchel"
	path = /obj/item/storage/backpack/fluff/syndiesatchel

/datum/gear/donor/spacecloak
	donator_tier = 3
	cost = 1
	index_name = "Space cloak"
	path = /obj/item/clothing/neck/cloak/spacecloak

/datum/gear/donor/golden_wheelchair
	donator_tier = 4
	cost = 1
	index_name = "Golden wheelchair paintkit"
	path = /obj/item/fluff/rapid_wheelchair_kit

/datum/gear/donor/hazardbelt
	index_name = "hazard vest alt"
	path = /obj/item/clothing/suit/storage/hazardvest/beltdonor
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER)

/datum/gear/donor/atmosbelt
	index_name = "hazard vest alt (atmos)"
	path = /obj/item/clothing/suit/storage/hazardvest/beltdonor/atmos
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/donor/beaver
	index_name = "Beaver Plushie"
	path = /obj/item/toy/plushie/beaver
	donator_tier = 3
	cost = 1

/datum/gear/donor/earring_NT
	index_name = "Earrings NT"
	path = /obj/item/clothing/ears/earrings/Nt
	donator_tier = 3
	cost = 1

/datum/gear/donor/hijab
	donator_tier = 1
	cost = 1
	index_name = "hijab"
	path = /obj/item/clothing/suit/hooded/hijab

/datum/gear/donor/steampunkdress
	donator_tier = 1
	cost = 1
	index_name = "victorian blue-white dress"
	path = /obj/item/clothing/under/steampunkdress

/datum/gear/donor/plaidhoodie_green
	donator_tier = 1
	cost = 1
	index_name = "Plaid hoodie, green"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_green

/datum/gear/donor/plaidhoodie_white
	donator_tier = 1
	cost = 1
	index_name = "Plaid hoodie, white"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_white

/datum/gear/donor/plaidhoodie_red
	donator_tier = 1
	cost = 1
	index_name = "Plaid hoodie, red"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_red

/datum/gear/donor/plaidhoodie_yellow
	donator_tier = 1
	cost = 1
	index_name = "Plaid hoodie, yellow"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_yellow

/datum/gear/donor/blackcoat
	donator_tier = 2
	cost = 2
	index_name = "Black Coat"
	path = /obj/item/clothing/suit/blackcoat

/datum/gear/donor/pda_beer
	index_name = "PDA case \"BEER\""
	path = /obj/item/pda_case/beer
	donator_tier = 1
	cost = 1

/datum/gear/donor/maid
	donator_tier = 2
	cost = 1
	index_name = "Short maid costume"
	path = /obj/item/clothing/under/maid/short

/datum/gear/donor/rdplushie
	donator_tier = 3
	cost = 1
	index_name = "RD doll"
	path = /obj/item/toy/plushie/rdplushie

/datum/gear/donor/gsbplushie
	donator_tier = 3
	cost = 1
	index_name = "GSBussy doll"
	path = /obj/item/toy/plushie/gsbplushie

/datum/gear/donor/backpack_shitsec
	donator_tier = 3
	cost = 1
	index_name = "backpack of justice"
	path = /obj/item/storage/backpack/justice
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT)
