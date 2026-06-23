/obj/item/clothing/under/vox/jumpsuit
	name = "vox jumpsuit"
	desc = "Рабочая одежда вокса."
	icon_state = "vox-jumpsuit"
	item_color = "vox-jumpsuit"
	item_state = "syndicate-black"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/jumpsuit/red
	name = "vox work jumpsuit"
	icon_state = "vox-jumpsuit_red"
	item_color = "vox-jumpsuit_red"

/obj/item/clothing/under/vox/jumpsuit/teal
	name = "vox teal jumpsuit"
	icon_state = "vox-jumpsuit_teal"
	item_color = "vox-jumpsuit_teal"

/obj/item/clothing/under/vox/jumpsuit/blue
	name = "vox blue jumpsuit"
	icon_state = "vox-jumpsuit_blue"
	item_color = "vox-jumpsuit_blue"

/obj/item/clothing/under/vox/jumpsuit/green
	name = "vox green jumpsuit"
	icon_state = "vox-jumpsuit_green"
	item_color = "vox-jumpsuit_green"

/obj/item/clothing/under/vox/jumpsuit/yellow
	name = "vox yellow jumpsuit"
	icon_state = "vox-jumpsuit_yellow"
	item_color = "vox-jumpsuit_yellow"

/obj/item/clothing/under/vox/jumpsuit/purple
	name = "vox purple jumpsuit"
	icon_state = "vox-jumpsuit_purple"
	item_color = "vox-jumpsuit_purple"

/obj/item/clothing/under/vox
	name = "ripped jumpsuit"
	desc = "A jumpsuit that looks like it's been shredded by some talons. Who could wear this now?"
	has_sensor = 0
	icon = 'icons/obj/clothing/species/vox/uniforms.dmi'
	icon_state = "vgrey"
	item_state = "vgrey"
	item_color = "vgrey"
	species_restricted = list(SPECIES_VOX)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
	)

/obj/item/clothing/under/vox/vox_casual
	name = "alien clothing"
	desc = "This doesn't look very comfortable."
	icon_state = "vox-casual-1"
	item_color = "vox-casual-1"
	item_state = "vox-casual-1"
	body_parts_covered = LEGS

/obj/item/clothing/under/vox/vox_robes //This will be invisible on Armalis for lack of a proper sprite. They wear a carapace suit anyway, and this is more just to let them use IDs and such.
	name = "alien robes"
	desc = "Weird and flowing!"
	icon_state = "vox-casual-2"
	item_color = "vox-casual-2"
	item_state = "vox-casual-2"
	species_restricted = list(SPECIES_VOX,SPECIES_VOX_ARMALIS)
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/suit.dmi',
	)

/datum/gear/racial/vox_jumpsuit
	index_name = "vox work jumpsuit"
	description = "These loose clothes are optimized for the labors of the lower castes onboard the arkships. Large openings in the top allow for breathability while the pants are durable yet flexible enough to not restrict movement."
	path = /obj/item/clothing/under/vox/jumpsuit
	slot = ITEM_SLOT_CLOTH_INNER

/datum/gear/racial/vox_jumpsuit/red
	index_name = "vox red jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/red

/datum/gear/racial/vox_jumpsuit/teal
	index_name = "vox teal jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/teal

/datum/gear/racial/vox_jumpsuit/blue
	index_name = "vox blue jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/blue

/datum/gear/racial/vox_jumpsuit/green
	index_name = "vox green jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/green

/datum/gear/racial/vox_jumpsuit/yellow
	index_name = "vox yellow jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/yellow

/datum/gear/racial/vox_jumpsuit/purple
	index_name = "vox purple jumpsuit"
	path = /obj/item/clothing/under/vox/jumpsuit/purple
