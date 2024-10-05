/datum/gear/donor
	var/donator_tier = 2
	sort_category = "Donor"
	subtype_path = /datum/gear/donor

/datum/gear/donor/can_select(client/cl, job_name, species_name, silent = FALSE)
	if(!..()) // there's no point in being here
		return FALSE

	if(!donator_tier) // why are you here?.. allowed, but
		stack_trace("Item with no donator tier in loadout donor items: [display_name].")
		return TRUE

	if(!cl.prefs) // DB loading, skip this check now
		return TRUE

	if(cl?.donator_level >= donator_tier)
		return TRUE

	if(cl && !silent)
		to_chat(cl, span_warning("Для получения \"[display_name]\" необходим [donator_tier] или более высокий уровень пожертвований."))

	return FALSE


/datum/gear/donor/get_header_tips()
	return "\[Tier [donator_tier]\] "


/datum/gear/donor/ussptracksuit_black
	donator_tier = 1
	cost = 1
	display_name = "track suit (black)"
	path = /obj/item/clothing/under/ussptracksuit_black

/datum/gear/donor/ussptracksuit_white
	donator_tier = 1
	cost = 1
	display_name = "track suit (white)"
	path = /obj/item/clothing/under/ussptracksuit_white

/datum/gear/donor/kittyears
	display_name = "Kitty ears"
	path = /obj/item/clothing/head/kitty

/datum/gear/donor/leather_trenchcoat
	display_name = "Leather Trenchcoat"
	path = /obj/item/clothing/suit/storage/leather_trenchcoat/runner
	donator_tier = 2
	cost = 1

/datum/gear/donor/furgloves
	display_name = "Fur Gloves"
	path = /obj/item/clothing/gloves/furgloves

/datum/gear/donor/furboots
	display_name = "Fur Boots"
	path = /obj/item/clothing/shoes/furboots

/datum/gear/donor/noble_boot
	display_name = "Noble Boots"
	path = /obj/item/clothing/shoes/fluff/noble_boot

/datum/gear/donor/furcape
	display_name = "Fur Cape"
	path = /obj/item/clothing/neck/cloak/furcape

/datum/gear/donor/furcoat
	display_name = "Fur Coat"
	path = /obj/item/clothing/suit/furcoat

/datum/gear/donor/kamina
	display_name = "Spiky Orange-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina

/datum/gear/donor/green
	display_name = "Spiky Green-tinted Shades"
	path = /obj/item/clothing/glasses/fluff/kamina/green

/datum/gear/donor/threedglasses
	display_name = "Threed Glasses"
	path = /obj/item/clothing/glasses/threedglasses

/datum/gear/donor/blacksombrero
	display_name = "Black Sombrero"
	path = /obj/item/clothing/head/fluff/blacksombrero

/datum/gear/donor/guardhelm
	display_name = "Plastic Guard helm"
	path = /obj/item/clothing/head/fluff/guardhelm

/datum/gear/donor/goldtophat
	display_name = "Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat

/datum/gear/donor/goldtophat/red
	display_name = "Red Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/red

/datum/gear/donor/goldtophat/blue
	display_name = "Blue Gold-trimmed Top Hat"
	path = /obj/item/clothing/head/fluff/goldtophat/blue

/datum/gear/donor/mushhat
	display_name = "Mushroom Hat"
	path = /obj/item/clothing/head/fluff/mushhat

/datum/gear/donor/furcap
	display_name = "Fur Cap"
	path = /obj/item/clothing/head/furcap

/datum/gear/donor/mouse
	display_name = "Mouse Headband"
	path = /obj/item/clothing/head/kitty/mouse

/datum/gear/donor/fawkes
	display_name = "Guy Fawkes mask"
	path = /obj/item/clothing/mask/face/fawkes

/datum/gear/donor/bigbrother
	display_name = "Spraycan Big Brother"
	path = /obj/item/toy/crayon/spraycan/paintkit/bigbrother

/datum/gear/donor/slavic
	display_name = "Spraycan Slavic"
	path = /obj/item/toy/crayon/spraycan/paintkit/slavic

/datum/gear/donor/id_decal_silver
	display_name = "Silver ID Decal"
	path = /obj/item/id_decal/silver
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_prisoner
	display_name = "Prisoner ID Decal"
	path = /obj/item/id_decal/prisoner
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_emag
	display_name = "Emag ID Decal"
	path = /obj/item/id_decal/emag
	donator_tier = 3
	cost = 1

/datum/gear/donor/id_decal_gold
	display_name = "Gold ID Decal"
	path = /obj/item/id_decal/gold
	donator_tier = 4
	cost = 1

/datum/gear/donor/zippolghtr
	display_name = "Zippo lighter"
	path = /obj/item/lighter/zippo
	donator_tier = 1
	cost = 1

/datum/gear/donor/strip
	subtype_path = /datum/gear/donor/strip
	subtype_cost_overlap = FALSE

/datum/gear/donor/strip/cap
	display_name = "strip, Captain"
	path = /obj/item/clothing/accessory/head_strip
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CAPTAIN)

/datum/gear/donor/strip/rd
	display_name = "strip, Research Director"
	path = /obj/item/clothing/accessory/head_strip/rd
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_RD)

/datum/gear/donor/strip/ce
	display_name = "strip, Chief Engineer"
	path = /obj/item/clothing/accessory/head_strip/ce
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/donor/strip/t4ce
	display_name = "strip, Grand Chief Engineer"
	path = /obj/item/clothing/accessory/head_strip/t4ce
	donator_tier = 4
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF)

/datum/gear/donor/strip/cmo
	display_name = "strip, Chief Medical Officer"
	path = /obj/item/clothing/accessory/head_strip/cmo
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CMO)

/datum/gear/donor/strip/hop
	display_name = "strip, Head of Personnel"
	path = /obj/item/clothing/accessory/head_strip/hop
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_HOP)

/datum/gear/donor/strip/hos
	display_name = "strip, Head of Security"
	path = /obj/item/clothing/accessory/head_strip/hos
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_HOS)

/datum/gear/donor/strip/qm
	display_name = "strip, Quartermaster"
	path = /obj/item/clothing/accessory/head_strip/qm
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_QUARTERMASTER)

/datum/gear/donor/strip/clown
	display_name = "strip, Clown"
	path = /obj/item/clothing/accessory/head_strip/clown
	donator_tier = 2
	cost = 1
	allowed_roles = list(JOB_TITLE_CLOWN)

/datum/gear/donor/strip/bs
	display_name = "strip, Blueshield"
	path = /obj/item/clothing/accessory/head_strip/bs
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_BLUESHIELD)

/datum/gear/donor/strip/ntr
	display_name = "strip, NanoTrasen Representative"
	path = /obj/item/clothing/accessory/head_strip/ntr
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_REPRESENTATIVE)

/datum/gear/donor/heartglasses
	display_name = "heart-shaped glasses, color"
	path = /obj/item/clothing/glasses/heart
	donator_tier = 3
	cost = 1
	slot = ITEM_SLOT_EYES

/datum/gear/donor/heartglasses/New()
	..()
	gear_tweaks += new /datum/gear_tweak/color(parent = src)

/datum/gear/donor/night_dress
	display_name = "night dress, select"
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
	display_name = "strip, Great fellow"
	path = /obj/item/clothing/accessory/head_strip/cheese_badge
	donator_tier = 4
	cost = 1
	allowed_roles = list(JOB_TITLE_CAPTAIN, JOB_TITLE_QUARTERMASTER, JOB_TITLE_RD, JOB_TITLE_HOS, JOB_TITLE_HOP, JOB_TITLE_CMO, JOB_TITLE_CHIEF, JOB_TITLE_REPRESENTATIVE, JOB_TITLE_JUDGE)

/datum/gear/donor/smile_pin
	display_name = "smiling pin"
	path = /obj/item/clothing/accessory/medal/smile
	donator_tier = 4
	cost = 1

/datum/gear/donor/backpack_hiking
	donator_tier = 3
	cost = 1
	display_name = "backpack, Fancy Hiking Pack"
	path = /obj/item/storage/backpack/fluff/hiking

/datum/gear/donor/backpack_brew
	donator_tier = 3
	cost = 1
	display_name = "backpack, The brew"
	path = /obj/item/storage/backpack/fluff/thebrew

/datum/gear/donor/backpack_cat
	donator_tier = 3
	cost = 1
	display_name = "backpack, CatPack"
	path = /obj/item/storage/backpack/fluff/ssscratches_back

/datum/gear/donor/backpack_voxcaster
	donator_tier = 3
	cost = 1
	display_name = "backpack, Voxcaster"
	path = /obj/item/storage/backpack/fluff/krich_back

/datum/gear/donor/backpack_syndi
	donator_tier = 3
	cost = 1
	display_name = "backpack, Military Satchel"
	path = /obj/item/storage/backpack/fluff/syndiesatchel

/datum/gear/donor/spacecloak
	donator_tier = 3
	cost = 1
	display_name = "Space cloak"
	path = /obj/item/clothing/neck/cloak/spacecloak

/datum/gear/donor/golden_wheelchair
	donator_tier = 4
	cost = 1
	display_name = "Golden wheelchair paintkit"
	path = /obj/item/fluff/rapid_wheelchair_kit

/datum/gear/donor/hazardbelt
	display_name = "hazard vest alt"
	path = /obj/item/clothing/suit/storage/hazardvest/beltdonor
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER)

/datum/gear/donor/atmosbelt
	display_name = "hazard vest alt (atmos)"
	path = /obj/item/clothing/suit/storage/hazardvest/beltdonor/atmos
	donator_tier = 3
	cost = 1
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ATMOSTECH)

/datum/gear/donor/beaver
	display_name = "Beaver Plushie"
	path = /obj/item/toy/plushie/beaver
	donator_tier = 3
	cost = 1

/datum/gear/donor/hijab
	donator_tier = 1
	cost = 1
	display_name = "hijab"
	path = /obj/item/clothing/suit/hooded/hijab

/datum/gear/donor/steampunkdress
	donator_tier = 1
	cost = 1
	display_name = "victorian blue-white dress"
	path = /obj/item/clothing/under/steampunkdress

/datum/gear/donor/plaidhoodie_green
	donator_tier = 1
	cost = 1
	display_name = "Plaid hoodie, green"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_green

/datum/gear/donor/plaidhoodie_white
	donator_tier = 1
	cost = 1
	display_name = "Plaid hoodie, white"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_white

/datum/gear/donor/plaidhoodie_red
	donator_tier = 1
	cost = 1
	display_name = "Plaid hoodie, red"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_red

/datum/gear/donor/plaidhoodie_yellow
	donator_tier = 1
	cost = 1
	display_name = "Plaid hoodie, yellow"
	path = /obj/item/clothing/suit/hoodie/plaidhoodie_yellow

/datum/gear/donor/blackcoat
	donator_tier = 2
	cost = 2
	display_name = "Black Coat"
	path = /obj/item/clothing/suit/blackcoat

/datum/gear/donor/pda_beer
	display_name = "PDA case \"BEER\""
	path = /obj/item/pda_case/beer
	donator_tier = 1
	cost = 1

/datum/gear/donor/maid
	donator_tier = 2
	cost = 1
	display_name = "Short maid costume"
	path = /obj/item/clothing/under/maid/short

/datum/gear/donor/rdplushie
	donator_tier = 3
	cost = 1
	display_name = "RD doll"
	path = /obj/item/toy/plushie/rdplushie

