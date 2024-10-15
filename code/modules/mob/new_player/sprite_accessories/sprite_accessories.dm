/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female, list/full_list)
	if(!istype(L))	L = list()
	if(!istype(male))	male = list()
	if(!istype(female))	female = list()
	if(!istype(full_list))	full_list = list()

	for(var/path in subtypesof(prototype))
		var/datum/sprite_accessory/D = new path()

		if(D.name)
			if(D.fluff)
				full_list[D.name] = D
			else
				L[D.name] = D
				full_list[D.name] = D

			switch(D.unsuitable_gender)
				if(FEMALE)	male[D.name] = D
				if(MALE)	female[D.name] = D
				else
					male[D.name] = D
					female[D.name] = D
	return L

/datum/sprite_accessory
	var/icon				//the icon file the accessory is located in
	var/icon_state			//the icon_state of the accessory
	var/name				//the preview name of the accessory
	var/unsuitable_gender	//Determines if the accessory will be skipped or included in random generations

	// Restrict some styles to specific species
	var/list/species_allowed = list(SPECIES_HUMAN, SPECIES_SLIMEPERSON)
	var/list/sprite_sheets = list() //For accessories common across species but need to use 'fitted' sprites (like underwear). e.g. list(SPECIES_VOX = 'icons/mob/clothing/species/vox/iconfile.dmi')
	var/list/models_allowed = list() //Specifies which, if any, hairstyles or markings can be accessed by which prosthetics. Should equal the manufacturing company name in robolimbs.dm.
	var/list/heads_allowed = null //Specifies which, if any, alt heads a head marking, hairstyle or facial hair style is compatible with.
	var/list/tails_allowed = null //Specifies which, if any, tails a tail marking is compatible with.
	var/list/wings_allowed
	var/marking_location //Specifies which bodypart a body marking is located on.
	var/secondary_theme	//If exists, there's a secondary colour to that hair style and the secondary theme's icon state's suffix is equal to this.
	var/no_sec_colour = FALSE	//If TRUE, prohibit the colouration of the secondary theme.
	var/fluff = 0
	// Whether or not the accessory can be affected by colouration
	var/do_colouration = 1

/* HAIR */

/datum/sprite_accessory/hair
	icon = 'icons/mob/sprite_accessories/human/human_hair.dmi'	  // default icon for all human hair. Override if it doesn't belong to human. Human hair that is shared belongs in human file.
	var/glasses_over //Hair styles with hair that don't overhang the arms of glasses should have glasses_over set to a positive value

/datum/sprite_accessory/hair/bald
	icon = 'icons/mob/human_face.dmi' // Keep bald hair here, as for some reason, putting it elsewhere lead to it being colourable - Also it make sense as it is shared by everyone.
	name = "Bald"
	icon_state = "bald"
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_DIONA, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_SKELETON, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_MOTH)
	glasses_over = 1

/datum/sprite_accessory/facial_hair
	unsuitable_gender = FEMALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)
	icon = 'icons/mob/sprite_accessories/human/human_facial_hair.dmi'
	var/over_hair

/datum/sprite_accessory/hair/fluff
	fluff = 1

/* HEAD ACCESSORY */

/datum/sprite_accessory/head_accessory
	icon = 'icons/mob/clothing/body_accessory.dmi'
	species_allowed = list(SPECIES_UNATHI, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_MACNINEPERSON)
	icon_state = "accessory_none"
	var/over_hair

/datum/sprite_accessory/head_accessory/none
	name = "None"
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_GREY, SPECIES_KIDAN, SPECIES_MACNINEPERSON, SPECIES_TAJARAN, SPECIES_VULPKANIN, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_VOX)
	icon_state = "accessory_none"

/* BODY MARKINGS */

/datum/sprite_accessory/body_markings
	icon = 'icons/mob/sprite_accessories/human/human_body_markings.dmi'
	species_allowed = list(SPECIES_UNATHI, SPECIES_TAJARAN, SPECIES_VULPKANIN, SPECIES_MACNINEPERSON, SPECIES_VOX, SPECIES_KIDAN, SPECIES_MOTH)
	icon_state = "accessory_none"
	marking_location = "body"

/datum/sprite_accessory/body_markings/head
	marking_location = "head"
	species_allowed = list()


/datum/sprite_accessory/body_markings/tail
	species_allowed = list()
	icon_state = "accessory_none"
	marking_location = "tail"
	tails_allowed = null

/* ALT HEADS */

/datum/sprite_accessory/alt_heads
	icon = null
	icon_state = null
	species_allowed = null
	var/suffix = null

/datum/sprite_accessory/alt_heads/none
	name = "None"

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list(SPECIES_HUMAN)

/datum/sprite_accessory/skin/human/human_tatt01
	name = "Tatt01 human skin"
	icon_state = "tatt1"

/datum/sprite_accessory/skin/tajaran
	name = "Default tajaran skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_tajaran.dmi'
	species_allowed = list(SPECIES_TAJARAN)

/datum/sprite_accessory/skin/vulpkanin
	name = "Default Vulpkanin skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_vulpkanin.dmi'
	species_allowed = list(SPECIES_VULPKANIN)

/datum/sprite_accessory/skin/unathi
	name = "Default Unathi skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_lizard.dmi'
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/skin/skrell
	name = "Default skrell skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_skrell.dmi'
	species_allowed = list(SPECIES_SKRELL)

///////////////////////////
// Underwear Definitions //
///////////////////////////
/datum/sprite_accessory/underwear
	icon = 'icons/mob/clothing/underwear.dmi'
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	)

	var/allow_change_color = FALSE

/datum/sprite_accessory/underwear/nude
	name = "Nude"
	icon_state = null
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)

/datum/sprite_accessory/underwear/male
	unsuitable_gender = FEMALE

/datum/sprite_accessory/underwear/male/male_striped_alt
	name = "Mens Striped Alt"
	icon_state = "male_stripe_alt"

/datum/sprite_accessory/underwear/male/male_heart
	name = "Mens Hearts"
	icon_state = "male_hearts"

/datum/sprite_accessory/underwear/male/colorized
	allow_change_color = TRUE
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/underwear/male/colorized/mankini
	name = "Mankini"
	icon_state = "male_mankini"

/datum/sprite_accessory/underwear/male/colorized/briefs
	name = "Mens Briefs"
	icon_state = "male_briefs"

/datum/sprite_accessory/underwear/male/colorized/boxers
	name = "Mens Boxers"
	icon_state = "male_boxers"

/datum/sprite_accessory/underwear/male/colorized/stripe
	name = "Mens Stripe"
	icon_state = "male_stripe"

/datum/sprite_accessory/underwear/male/colorized/midway
	name = "Mens Midway"
	icon_state = "male_midway"

/datum/sprite_accessory/underwear/male/colorized/male_kinky
	name = "Mens Kinky"
	icon_state = "male_kinky"

/datum/sprite_accessory/underwear/female
	unsuitable_gender = MALE

/datum/sprite_accessory/underwear/female/female_red_alt
	name = "Ladies Red Alt"
	icon_state = "female_red_alt"
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/underwear.dmi',
	)

/datum/sprite_accessory/underwear/female/female_babydoll
	name = "Ladies Full Grey"
	icon_state = "female_babydoll"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/underwear.dmi',
	)

/datum/sprite_accessory/underwear/female/female_kinky_alt
	name = "Ladies Kinky Alt"
	icon_state = "female_kinky_alt"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/underwear.dmi',
	)

/datum/sprite_accessory/underwear/female/female_kinky_black
	name = "Ladies Kinky Full Black"
	icon_state = "female_kinky_black"

/datum/sprite_accessory/underwear/female/female_neko_black
	name = "Ladies Neko Black"
	icon_state = "neko_female_black"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/underwear/female/colorized
	allow_change_color = TRUE
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/underwear/female/colorized/neko_female
	name = "Ladies Neko"
	icon_state = "neko_female"

/datum/sprite_accessory/underwear/female/colorized/swimhalter_female
	name = "Ladies Swimhalter"
	icon_state = "swimhalter_female"

/datum/sprite_accessory/underwear/female/colorized/female_stripless
	name = "Ladies Stripless"
	icon_state = "female_stripless"

/datum/sprite_accessory/underwear/female/colorized/female_sport
	name = "Ladies Sport"
	icon_state = "female_sport"

/datum/sprite_accessory/underwear/female/colorized/female_bralette
	name = "Ladies Bralette"
	icon_state = "female_bralette"

/datum/sprite_accessory/underwear/female/colorized/female_bikini
	name = "Ladies Bikini"
	icon_state = "female_bikini"

/datum/sprite_accessory/underwear/female/colorized/female_thong
	name = "Ladies Thong"
	icon_state = "thong_female"

////////////////////////////
// Undershirt Definitions //
////////////////////////////
/datum/sprite_accessory/undershirt
	icon = 'icons/mob/clothing/underwear.dmi'
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	)
	var/allow_change_color = FALSE

/datum/sprite_accessory/undershirt/nude
	name = "Nude"
	icon_state = null
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)

//plain color shirts
/datum/sprite_accessory/undershirt/shirt_colorized
	name = "Colorized Shirt"
	icon_state = "shirt"
	allow_change_color = TRUE
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/undershirt/shirt_colorized/turtleneck
	name = "Turtleneck"
	icon_state = "turtleneck"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/undershirt/shirt_colorized/sweater
	name = "Sweater"
	icon_state = "sweater"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/undershirt/shirt_colorized/female
	name = "Female Colorized Shirt"
	icon_state = "female_shirt"
	unsuitable_gender = MALE

/datum/sprite_accessory/undershirt/shirt_colorized/female/female_cuttedshirt
	name = "Female Colorized Cutted Shirt"
	icon_state = "female_cuttedshirt"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/undershirt/shirt_colorized/female/female_longslevshirt
	name = "Female Colorized Long Sleeve Shirt"
	icon_state = "female_longslevshirt"
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

//end plain color shirts

//graphic shirts
/datum/sprite_accessory/undershirt/shirt_heart
	name = "Heart Shirt"
	icon_state = "shirt_heart"

/datum/sprite_accessory/undershirt/shirt_corgi
	name = "Corgi Shirt"
	icon_state = "shirt_corgi"

/datum/sprite_accessory/undershirt/shirt_clown
	name = "Clown Shirt"
	icon_state = "shirt_clown"

/datum/sprite_accessory/undershirt/shirt_alien
	name = "Alien Shirt"
	icon_state = "shirt_alien"

/datum/sprite_accessory/undershirt/shirt_jack
	name = "Union Jack Shirt"
	icon_state = "shirt_jack"

/datum/sprite_accessory/undershirt/love_nt
	name = "I Love NT Shirt"
	icon_state = "shirt_lovent"

/datum/sprite_accessory/undershirt/peace
	name = "Peace Shirt"
	icon_state = "shirt_peace"

/datum/sprite_accessory/undershirt/mondmondjaja
	name = "Band Shirt"
	icon_state = "shirt_band"

/datum/sprite_accessory/undershirt/pacman
	name = "Pogoman Shirt"
	icon_state = "shirt_pogoman"

/datum/sprite_accessory/undershirt/shirt_ss13
	name = "SS13 Shirt"
	icon_state = "shirt_ss13"

/datum/sprite_accessory/undershirt/shirt_question
	name = "Question Mark Shirt"
	icon_state = "shirt_question"

/datum/sprite_accessory/undershirt/shirt_skull
	name = "Skull Shirt"
	icon_state = "shirt_skull"

/datum/sprite_accessory/undershirt/shirt_commie
	name = "Communist Shirt"
	icon_state = "shirt_commie"

/datum/sprite_accessory/undershirt/shirt_nano
	name = "Nanotrasen Shirt"
	icon_state = "shirt_nano"

/datum/sprite_accessory/undershirt/shirt_meat
	name = "Meat Shirt"
	icon_state = "shirt_meat"

/datum/sprite_accessory/undershirt/shirt_tiedie
	name = "Tiedie Shirt"
	icon_state = "shirt_tiedie"

/datum/sprite_accessory/undershirt/blue_striped
	name = "Striped Blue Shirt"
	icon_state = "shirt_bluestripe"

/datum/sprite_accessory/undershirt/brightblue_striped
	name = "Striped Bright Blue Shirt"
	icon_state = "shirt_brightbluestripe"
//end graphic shirts

//short sleeved
/datum/sprite_accessory/undershirt/short_colorized
	name = "Short-sleeved Shirt"
	icon_state = "short"
	allow_change_color = TRUE
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)
//end short sleeved

//polo shirts
/datum/sprite_accessory/undershirt/polo_blue
	name = "Blue Polo Shirt"
	icon_state = "polo_blue"

/datum/sprite_accessory/undershirt/polo_red
	name = "Red Polo Shirt"
	icon_state = "polo_red"

/datum/sprite_accessory/undershirt/polo_greyelllow
	name = "Grey-Yellow Polo Shirt"
	icon_state = "polo_greyellow"
//end polo shirts

//sport shirts
/datum/sprite_accessory/undershirt/sport_green
	name = "Green Sports Shirt"
	icon_state = "sport_green"

/datum/sprite_accessory/undershirt/sport_red
	name = "Red Sports Shirt"
	icon_state = "sport_red"

/datum/sprite_accessory/undershirt/sport_blue
	name = "Blue Sports Shirt"
	icon_state = "sport_blue"

/datum/sprite_accessory/undershirt/jersey_red
	name = "Red Jersey"
	icon_state = "jersey_red"

/datum/sprite_accessory/undershirt/jersey_blue
	name = "Blue Jersey"
	icon_state = "jersey_blue"
//end sport shirts

//tanktops
/datum/sprite_accessory/undershirt/tank_top_colorize
	name = "Female Crop-Top"
	icon_state = "tank_top"
	unsuitable_gender = MALE
	allow_change_color = TRUE

/datum/sprite_accessory/undershirt/tank_whitetop
	name = "White Crop-Top"
	icon_state = "tank_whitetop"
	unsuitable_gender = MALE

/datum/sprite_accessory/undershirt/tank_midriff
	name = "Mid Tank-Top"
	icon_state = "tank_midriff_female"
	unsuitable_gender = MALE
	allow_change_color = TRUE
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_GREY = 'icons/mob/clothing/species/grey/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRASK = 'icons/mob/clothing/species/drask/underwear.dmi'
	)

/datum/sprite_accessory/undershirt/tank_colorized
	name = "Colorized Tank-Top"
	icon_state = "tank"
	allow_change_color = TRUE

/datum/sprite_accessory/undershirt/tank_black_alt
	name = "Full Black Tank-Top"
	icon_state = "tank_black"

/datum/sprite_accessory/undershirt/tank_fire
	name = "Fire Tank-Top"
	icon_state = "tank_fire"

/datum/sprite_accessory/undershirt/tank_stripes
	name = "Striped Tank-Top"
	icon_state = "tank_stripes"
//end tanktops

///////////////////////
// Socks Definitions //
///////////////////////
/datum/sprite_accessory/socks
	icon = 'icons/mob/clothing/underwear.dmi'
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)
	sprite_sheets = list(
	SPECIES_VOX = 'icons/mob/clothing/species/vox/underwear.dmi',
	SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/underwear.dmi',
	SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/underwear.dmi')

/datum/sprite_accessory/socks/nude
	name = "Nude"
	icon_state = null
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_DIONA, SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_KIDAN, SPECIES_GREY, SPECIES_PLASMAMAN, SPECIES_MACNINEPERSON, SPECIES_SKRELL, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_DRASK, SPECIES_VOX, SPECIES_MOTH)

/datum/sprite_accessory/socks/white_norm
	name = "Normal White"
	icon_state = "white_norm"

/datum/sprite_accessory/socks/black_norm
	name = "Normal Black"
	icon_state = "black_norm"

/datum/sprite_accessory/socks/white_short
	name = "Short White"
	icon_state = "white_short"

/datum/sprite_accessory/socks/black_short
	name = "Short Black"
	icon_state = "black_short"

/datum/sprite_accessory/socks/white_knee
	name = "Knee-high White"
	icon_state = "white_knee"

/datum/sprite_accessory/socks/black_knee
	name = "Knee-high Black"
	icon_state = "black_knee"

/datum/sprite_accessory/socks/thin_knee
	name = "Knee-high Thin"
	icon_state = "thin_knee"
	unsuitable_gender = MALE

/datum/sprite_accessory/socks/striped_norm
	name = "Normal Striped"
	icon_state = "striped_norm"

/datum/sprite_accessory/socks/striped_knee
	name = "Knee-high Striped"
	icon_state = "striped_knee"

/datum/sprite_accessory/socks/rainbow_knee
	name = "Knee-high Rainbow"
	icon_state = "rainbow_knee"

/datum/sprite_accessory/socks/white_thigh
	name = "Thigh-high White"
	icon_state = "white_thigh"

/datum/sprite_accessory/socks/black_thigh
	name = "Thigh-high Black"
	icon_state = "black_thigh"

/datum/sprite_accessory/socks/thin_thigh
	name = "Thigh-high Thin"
	icon_state = "thin_thigh"
	unsuitable_gender = MALE

/datum/sprite_accessory/socks/striped_thigh
	name = "Thigh-high Striped"
	icon_state = "striped_thigh"

/datum/sprite_accessory/socks/rainbow_thigh
	name = "Thigh-high Rainbow"
	icon_state = "rainbow_thigh"

/datum/sprite_accessory/socks/pantyhose
	name = "Pantyhose"
	icon_state = "pantyhose"
	unsuitable_gender = MALE

/datum/sprite_accessory/socks/black_fishnet
	name = "Black Fishnet"
	icon_state = "black_fishnet"

/* HAIR GRADIENT */

/datum/sprite_accessory/hair_gradient
	icon = 'icons/mob/hair_gradients.dmi'

/datum/sprite_accessory/hair_gradient/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/hair_gradient/fadeup
	name = "Fade Up"
	icon_state = "fadeup"

/datum/sprite_accessory/hair_gradient/fadedown
	name = "Fade Down"
	icon_state = "fadedown"

/datum/sprite_accessory/hair_gradient/vertical_split
	name = "Vertical Split"
	icon_state = "vsplit"

/datum/sprite_accessory/hair_gradient/_split
	name = "Horizontal Split"
	icon_state = "bottomflat"

/datum/sprite_accessory/hair_gradient/reflected
	name = "Reflected"
	icon_state = "reflected_high"

/datum/sprite_accessory/hair_gradient/reflected_inverse
	name = "Reflected Inverse"
	icon_state = "reflected_inverse_high"

/datum/sprite_accessory/hair_gradient/wavy
	name = "Wavy"
	icon_state = "wavy"

/datum/sprite_accessory/hair_gradient/long_fade_up
	name = "Long Fade Up"
	icon_state = "long_fade_up"

/datum/sprite_accessory/hair_gradient/long_fade_down
	name = "Long Fade Down"
	icon_state = "long_fade_down"
