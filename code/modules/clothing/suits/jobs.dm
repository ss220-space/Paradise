/*
 * Job related
 */
//Paramedic
/obj/item/clothing/suit/storage/paramedic
	name = "paramedic vest"
	desc = "A hazard vest used in the recovery of bodies."
	icon_state = "paramedic-vest"
	item_state = "paramedic-vest"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10, fire = 50, acid = 50)
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/storage/paramedic_jacket
	name = "paramedic jacket"
	desc = "Standard issue paramedic jacket. Not that different from any other work apparel, except for the bright, reflective stripes"
	blood_overlay_type = "armor"
	icon_state = "paramedic_jacket_open"
	item_state = "paramedic_jacket_open"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 10, fire = 50, acid = 50)
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

//Brig Physician
/obj/item/clothing/suit/storage/brigdoc
	name = "brig physician vest"
	desc = "A vest often worn by doctors caring for inmates."
	icon_state = "brigphysician-vest"
	item_state = "brigphysician-vest"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, \
	/obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 50, acid = 50)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Botanist
/obj/item/clothing/suit/apron
	name = "apron"
	desc = "A basic blue apron."
	icon_state = "apron"
	item_state = "apron"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/reagent_containers/spray/plantbgone,/obj/item/plant_analyzer,/obj/item/seeds,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/cultivator,/obj/item/reagent_containers/spray/pestspray,/obj/item/hatchet,/obj/item/storage/bag/plants)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Captain
/obj/item/clothing/suit/captunic
	name = "captain's parade tunic"
	desc = "Worn by a Captain to show their class."
	icon_state = "captunic"
	item_state = "bio_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/disk, /obj/item/stamp, /obj/item/reagent_containers/food/drinks/flask, /obj/item/melee, /obj/item/storage/lockbox/medal, /obj/item/flash, /obj/item/storage/box/matches, /obj/item/lighter, /obj/item/clothing/mask/cigarette, /obj/item/storage/fancy/cigarettes, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/captunic/coat
	name = "captain fur coat"
	desc = "Made of real fur."
	item_state = "cap_coat"
	icon_state = "cap_coat"
	flags_inv_transparent = HIDEJUMPSUIT

/obj/item/clothing/suit/captunic/parade
	name = "captain's parade jacket"
	desc = "Worn by a Captain to show their class."
	icon_state = "cap_jacket_black_open"
	item_state = "cap_jacket_black_open"
	ignore_suitadjust = FALSE
	flags_inv_transparent = HIDEJUMPSUIT
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/captunic/parade/alt
	icon_state = "dress_capjacket_black_open"
	item_state = "dress_capjacket_black_open"

/obj/item/clothing/suit/captunic/jacket
	name = "captain's jacket"
	desc = "Worn by a Captain to show their class."
	icon_state = "cap_jacket_open"
	item_state = "cap_jacket_open"
	ignore_suitadjust = FALSE
	flags_inv_transparent = HIDEJUMPSUIT
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/captunic/bomber
	name = "captain's bomber jacket"
	desc = "Worn by a Captain to show their class."
	icon_state = "bomber_captain_open"
	item_state = "bomber_captain_open"
	ignore_suitadjust = FALSE
	flags_inv_transparent = HIDEJUMPSUIT
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

//Chaplain
/obj/item/clothing/suit/hooded/chaplain_hoodie
	name = "chaplain hoodie"
	desc = "This suit says to you 'hush'!"
	icon_state = "chaplain_hoodie"
	item_state = "chaplain_hoodie"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/hooded/chaplain_hoodie/no_name
	name = "dark hoodie"
	desc = "A dark robe made of thick fabric that looks intimidating"
	hoodtype = /obj/item/clothing/head/hooded/chaplain_hood/no_name

//Chaplain
/obj/item/clothing/suit/hooded/nun
	name = "nun robe"
	desc = "Maximum piety in this star system."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/nun_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Chaplain
/obj/item/clothing/suit/hooded/monk
	name = "monk robe"
	desc = "Wooden board not included."
	icon_state = "monkrobe"
	item_state = "monkrobe"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/monk_hood
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/witchhunter
	name = "witchhunter garb"
	desc = "Dosen't weigh the same a a duck."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

//Chef
/obj/item/clothing/suit/chef
	name = "chef's apron"
	desc = "An apron used by a high class chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list (/obj/item/kitchen/knife)

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Chef
/obj/item/clothing/suit/chef/classic
	name = "classic chef's apron"
	desc = "A basic, dull, white chef's apron."
	icon_state = "apronchef"
	item_state = "apronchef"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list(/obj/item/kitchen/knife)

//Detective
/obj/item/clothing/suit/storage/det_suit
	name = "coat"
	desc = "An 18th-century multi-purpose trenchcoat. Someone who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/reagent_containers/spray/pepper, /obj/item/flashlight, /obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/detective_scanner, /obj/item/taperecorder)
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/det_suit/black
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi'
		)
	icon_state = "detective_black"

//Forensics
/obj/item/clothing/suit/storage/det_suit/forensics
	name = "jacket"
	desc = "A forensics technician jacket."
	item_state = "det_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/suit/storage/det_suit/forensics/red
	name = "red jacket"
	desc = "A red forensics technician jacket."
	icon_state = "forensics_red"

/obj/item/clothing/suit/storage/det_suit/forensics/blue
	name = "blue jacket"
	desc = "A blue forensics technician jacket."
	icon_state = "forensics_blue"

/obj/item/clothing/suit/storage/det_suit/forensics/blaser
	name = "black jacket"
	desc = "A black forensics technician jacket."
	icon_state = "dec_blazer_black"
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_DRASK =  'icons/mob/clothing/species/drask/suit.dmi'
		)

/obj/item/clothing/suit/storage/det_suit/forensics/blaser/brown
	name = "brown jacket"
	desc = "A brown forensics technician jacket."
	icon_state = "dec_blazer_brown"

/obj/item/clothing/suit/storage/det_suit/forensics/blaser/grey
	name = "grey jacket"
	desc = "A grey forensics technician jacket."
	icon_state = "dec_blazer_grey"
//Blueshield
/obj/item/clothing/suit/storage/blueshield
	name = "blueshield coat"
	desc = "NT deluxe ripoff. You finally have your own coat."
	icon_state = "blueshieldcoat"
	item_state = "blueshieldcoat"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite)
	armor = list(melee = 25, bullet = 10, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 45)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/blueshield/srt
	name = "SRT coat"
	desc = "Dark blue armored coat. Excellent defense against most types of damage."
	armor = list(melee = 45, bullet = 35, laser = 35, energy = 20, bomb = 50, rad = 40, fire = 40, acid = 90)

//Engineering
/obj/item/clothing/suit/storage/hazardvest
	name = "hazard vest"
	desc = "A high-visibility vest used in work zones."
	icon_state = "hazard"
	item_state = "hazard"
	blood_overlay_type = "armor"
	allowed = list (/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd)
	resistance_flags = NONE

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)
/obj/item/clothing/suit/storage/hazardvest/beltdonor
	name = "hazard belt"
	desc = "A high-visibility webbing used in work zones. This one comes with premial quality materials."
	icon_state = "hazard_belt"
	item_state = "hazard_belt"

	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi'
		)


/obj/item/clothing/suit/storage/hazardvest/beltdonor/atmos
	name = "atmospherics hazard belt"
	icon_state = "atmos_belt"
	item_state = "atmos_belt"

//Lawyer
/obj/item/clothing/suit/storage/lawyer
	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/lawyer/blackjacket
	name = "black suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_black_open"
	item_state = "suitjacket_black_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/lawyer/bluejacket
	name = "blue suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_blue_open"
	item_state = "suitjacket_blue_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/storage/lawyer/purpjacket
	name = "purple suit jacket"
	desc = "A snappy dress jacket."
	icon_state = "suitjacket_purp"
	item_state = "suitjacket_purp"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/storage/qm
	name = "quartermaster jacket"
	desc = "Comfortable for work cargo jacket with extra pockets."
	icon_state = "qm_jacket_open"
	item_state = "qm_jacket_open"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	flags_inv_transparent = HIDEJUMPSUIT
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/storage/fancy/cigarettes, /obj/item/clothing/mask/cigarette, /obj/item/lighter, /obj/item/rcs, /obj/item/stack/packageWrap, /obj/item/stack/wrapping_paper, /obj/item/destTagger, /obj/item/pen, /obj/item/paper, /obj/item/stamp, /obj/item/qm_quest_tablet)
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Internal Affairs
/obj/item/clothing/suit/storage/internalaffairs
	name = "\improper Internal Affairs jacket"
	desc = "A smooth black jacket."
	icon_state = "ia_jacket_open"
	item_state = "ia_jacket_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

/obj/item/clothing/suit/storage/ntrep
	name = "\improper Nanotrasen Representative jacket"
	desc = "A fancy black jacket; standard issue to Nanotrasen Representatives."
	icon_state = "ntrep"
	item_state = "ntrep"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Medical
/obj/item/clothing/suit/storage/fr_jacket
	name = "first responder jacket"
	desc = "A high-visibility jacket worn by medical first responders."
	icon_state = "fr_jacket_open"
	item_state = "fr_jacket_open"
	blood_overlay_type = "armor"
	allowed = list(/obj/item/stack/medical, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/reagent_containers/syringe,
	/obj/item/healthanalyzer, /obj/item/flashlight, /obj/item/radio, /obj/item/tank/internals/emergency_oxygen,/obj/item/rad_laser)
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi'
		)

//Suspenders
/obj/item/clothing/suit/suspenders
	name = "suspenders"
	desc = "Two braids to support your jeans. Weared by noire-detectives. Or skinheads. Now comes in any color!"
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "suspenders"
	blood_overlay_type = "armor" //it's the less thing that I can put here
	var/paintable = TRUE

	sprite_sheets = list(
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi'
		)


/obj/item/clothing/suit/suspenders/Initialize(mapload)
	. = ..()
	if(!color && paintable)
		color = "#a30e22"
	update_icon(UPDATE_OVERLAYS)


/obj/item/clothing/suit/suspenders/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/crayon/spraycan))
		var/obj/item/toy/crayon/spraycan/can = I
		if(!paintable)
			to_chat(user, span_warning("You cannot paint [src]."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		to_chat(user, span_notice("You paint [src]."))
		playsound(user.loc, 'sound/effects/spray.ogg', 20, TRUE)
		color = can.colour
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()


/obj/item/clothing/suit/suspenders/update_overlays()
	. = ..()
	if(color)
		var/mutable_appearance/suspenders_overlay = mutable_appearance(icon='icons/obj/clothing/belts.dmi', icon_state = "suspenders_overlay")
		. += suspenders_overlay
		var/mutable_appearance/suspenders_clips = mutable_appearance(icon='icons/obj/clothing/belts.dmi', icon_state = "suspenders_clips", appearance_flags = RESET_COLOR)
		. += suspenders_clips


/obj/item/clothing/suit/suspenders/nodrop


/obj/item/clothing/suit/suspenders/nodrop/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


// Surgeon
/obj/item/clothing/suit/apron/surgical
	name = "surgical apron"
	desc = "A sterile blue surgical apron."
	icon_state = "surgical"
	item_state = "surgical"
	allowed = list(/obj/item/scalpel, /obj/item/surgical_drapes, /obj/item/cautery, /obj/item/hemostat, /obj/item/retractor)

/obj/item/clothing/suit/hop_jacket
	name = "head of personnel's jacket"
	desc = "This is the head of personnel jacket"
	icon_state = "suitjacket_hop_open"
	item_state = "suitjacket_hop_open"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS
	ignore_suitadjust = FALSE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

/obj/item/clothing/suit/hop_jacket/female
	icon_state = "suitjacket_hop_fem_open"
	item_state = "suitjacket_hop_fem_open"

//Culinary Artist
/obj/item/clothing/suit/storage/chefbluza
	name = "deluxe chef suit"
	desc = "Well made expensive chief suit"
	icon_state = "bluza"
	item_state = "bluza"
	allowed = list(/obj/item/kitchen/utensil,/obj/item/kitchen/knife,/obj/item/kitchen/rollingpin,/obj/item/kitchen/mould,/obj/item/kitchen/sushimat,/obj/item/kitchen/cutter,/obj/item/assembly/mousetrap,/obj/item/reagent_containers/spray/pestspray,/obj/item/reagent_containers/food/drinks/flask,/obj/item/reagent_containers/food/drinks/drinkingglass,/obj/item/reagent_containers/food/drinks/bottle,/obj/item/reagent_containers/food/drinks/cans,/obj/item/reagent_containers/food/drinks/shaker,/obj/item/reagent_containers/food/snacks,/obj/item/reagent_containers/food/condiment,/obj/item/reagent_containers/glass/beaker,/obj/item/radio)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 5, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0, fire = 10, acid = 10)

// Cargotech
/obj/item/clothing/suit/storage/cargotech
	name = "cargo overalls"
	desc = "Durable and reliable overalls for the introduction of physical work and labor."
	icon_state = "overalls_cargo"
	item_state = "overalls_cargo"
	allowed = list(/obj/item/flashlight, /obj/item/t_scanner, /obj/item/tank/internals/emergency_oxygen, /obj/item/rcd, /obj/item/rpd, /obj/item/storage/fancy/cigarettes, /obj/item/clothing/mask/cigarette, /obj/item/lighter, /obj/item/rcs, /obj/item/stack/packageWrap, /obj/item/stack/wrapping_paper, /obj/item/destTagger, /obj/item/pen, /obj/item/paper, /obj/item/stamp, /obj/item/qm_quest_tablet)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 30, acid = 30)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
		)
