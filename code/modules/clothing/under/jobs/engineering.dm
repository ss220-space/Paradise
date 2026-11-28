//Contains: Engineering department jumpsuits
/obj/item/clothing/under/rank/engineering
	icon = 'icons/obj/clothing/uniforms/engineering.dmi'
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 60, ACID = 20)
	resistance_flags = NONE
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/rank/engineering/chief_engineer
	desc = "It's a high visibility jumpsuit given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpsuit"
	icon_state = "chief"
	item_state = "chief"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 40)


/obj/item/clothing/under/rank/engineering/chief_engineer/skirt
	desc = "It's a high visibility jumpskirt given to those engineers insane enough to achieve the rank of \"Chief engineer\". It has minor radiation shielding."
	name = "chief engineer's jumpskirt"
	icon_state = "chieff"
	item_color = "chieff"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/atmospheric_technician
	desc = "It's a jumpsuit worn by atmospheric technicians."
	name = "atmospheric technician's jumpsuit"
	icon_state = "atmos"
	item_state = "atmos_suit"
	item_color = "atmos"

/obj/item/clothing/under/rank/engineering/atmospheric_technician/skirt
	desc = "It's a jumpskirt worn by atmospheric technicians."
	name = "atmospheric technician's jumpskirt"
	icon_state = "atmosf"
	item_color = "atmosf"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/engineer
	desc = "It's an orange high visibility jumpsuit worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpsuit"
	icon_state = "engine"
	item_state = "engi_suit"
	item_color = "engine"

/obj/item/clothing/under/rank/engineering/engineer/sensor
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/rank/engineering/trainee
	name = "engineer trainee jumpsuit"
	icon_state = "trainee"
	item_color = "trainee"

/obj/item/clothing/under/rank/engineering/trainee/skirt
	name = "engineer trainee jumpskirt"
	icon_state = "traineef"
	item_color = "traineef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/trainee/assistant
	name = "engineer assistant jumpsuit"
	icon_state = "eng_ass"
	item_color = "eng_ass"

/obj/item/clothing/under/rank/engineering/trainee/assistant/skirt
	name = "engineer assistant jumpskirt"
	icon_state = "eng_ass_f"
	item_color = "eng_ass_f"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/rank/engineering/engineer/skirt
	desc = "It's an orange high visibility jumpskirt worn by engineers. It has minor radiation shielding."
	name = "engineer's jumpskirt"
	icon_state = "enginef"
	item_color = "enginef"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

