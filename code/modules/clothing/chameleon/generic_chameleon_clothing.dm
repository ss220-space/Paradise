#define BREAK_CHAMELEON_ACTION(item) \
do { \
	var/datum/action/item_action/chameleon/change/_action = locate() in item.actions; \
	_action?.emp_randomise(INFINITY); \
} while(FALSE)


// Cham jumpsuit
/obj/item/clothing/under/chameleon
	name = "black jumpsuit"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/jumpsuit)


/obj/item/clothing/under/chameleon/broken


/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


/obj/item/clothing/under/plasmaman/chameleon
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	sensor_mode = SENSOR_OFF
	resistance_flags = NONE
	random_sensor = FALSE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	actions_types = list(/datum/action/item_action/chameleon/change/jumpsuit)


/obj/item/clothing/under/plasmaman/chameleon/broken


/obj/item/clothing/under/plasmaman/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham suit
/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/suit)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/suit.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/suit.dmi',
	)


/obj/item/clothing/suit/chameleon/broken


/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham glasses
/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/glasses)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi',
	)


/obj/item/clothing/glasses/chameleon/broken


/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


/obj/item/clothing/glasses/chameleon/thermal
	origin_tech = "magnets=3;syndicate=2"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
	prescription_upgradable = TRUE


/obj/item/clothing/glasses/chameleon/meson
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE


/obj/item/clothing/glasses/hud/security/chameleon
	flash_protect = 1
	actions_types = list(/datum/action/item_action/chameleon/change/glasses)


/obj/item/clothing/glasses/hud/security/chameleon/broken


/obj/item/clothing/glasses/hud/security/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham gloves
/obj/item/clothing/gloves/chameleon
	name = "insulated gloves"
	desc = "These gloves will protect the wearer from electric shock."
	icon_state = "yellow"
	item_state = "ygloves"
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/gloves)


/obj/item/clothing/gloves/chameleon/broken


/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham hat
/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"
	resistance_flags = NONE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/hat)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/head.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/head.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/head.dmi',
	)


/obj/item/clothing/head/chameleon/broken


/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


/obj/item/clothing/head/helmet/space/plasmaman/chameleon
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 100, "rad" = 0, "fire" = 100, "acid" = 100)
	actions_types = list(/datum/action/item_action/chameleon/change/hat)


/obj/item/clothing/head/helmet/space/plasmaman/chameleon/broken


/obj/item/clothing/head/helmet/space/plasmaman/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham mask
/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	item_state = "gas_alt"
	resistance_flags = NONE
	armor = list("melee" = 5, "bullet" = 5, "laser" = 5, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	clothing_flags = AIRTIGHT|BLOCK_GAS_SMOKE_EFFECT
	flags_inv = HIDEHEADSETS|HIDEGLASSES|HIDENAME
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES|MASKCOVERSMOUTH
	actions_types = list(/datum/action/item_action/chameleon/change/mask)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/mask.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/mask.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/mask.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/mask.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/mask.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/mask.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/mask.dmi',
	)
	var/obj/item/voice_changer/voice_changer


/obj/item/clothing/mask/chameleon/Initialize(mapload)
	. = ..()
	voice_changer = new(src)


/obj/item/clothing/mask/chameleon/Destroy()
	QDEL_NULL(voice_changer)
	return ..()


/obj/item/clothing/mask/chameleon/broken


/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham shoes
/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	desc = "A pair of black shoes."
	icon_state = "black"
	item_color = "black"
	permeability_coefficient = 0.05
	resistance_flags = NONE
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	actions_types = list(/datum/action/item_action/chameleon/change/shoes)


/obj/item/clothing/shoes/chameleon/broken


/obj/item/clothing/shoes/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


/obj/item/clothing/shoes/chameleon/noslip
	clothing_traits = list(TRAIT_NO_SLIP_WATER)


/obj/item/clothing/shoes/chameleon/noslip/broken


/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham backpack
/obj/item/storage/backpack/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/backpack)


/obj/item/storage/backpack/chameleon/broken


/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham belt
/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	actions_types = list(/datum/action/item_action/chameleon/change/belt)


/obj/item/storage/belt/chameleon/broken


/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham headset
/obj/item/radio/headset/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/headset)


/obj/item/radio/headset/chameleon/broken


/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham PDA
/obj/item/pda/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/pda)


/obj/item/pda/chameleon/broken


/obj/item/pda/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham Stamp
/obj/item/stamp/chameleon
	actions_types = list(/datum/action/item_action/chameleon/change/stamp)


/obj/item/stamp/chameleon/broken


/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


// Cham neck-thing
/obj/item/clothing/neck/chameleon
	name = "black scarf"
	desc = "A black scarf from cloth."
	icon_state = "blackscarf"
	resistance_flags = NONE
	actions_types = list(/datum/action/item_action/chameleon/change/neck)


/obj/item/clothing/neck/chameleon/broken


/obj/item/clothing/neck/chameleon/broken/Initialize(mapload)
	. = ..()
	BREAK_CHAMELEON_ACTION(src)


#undef BREAK_CHAMELEON_ACTION

