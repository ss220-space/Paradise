/*
		Donator Loadout for Patreon
*/

//mushroom hat
/obj/item/clothing/head/fluff/mushhat
	name = "Mushroom Hat"
	desc = "A horrifying display of Nanotrasen's ruthless pursuit in being the forefront of fashion. Or genocide."
	icon_state = "mushhat"
	item_state = "mushhat"
	flags = BLOCKHAIR

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

//gold top hat and recolours
/obj/item/clothing/head/fluff/goldtophat
	name = "Gold-trimmed Top Hat"
	desc = "Poshness incarnate."
	icon_state = "goldtophat"
	item_state = "goldtophat"

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)


/obj/item/clothing/head/fluff/goldtophat/blue
	name = "Gold-trimmed Blue Top Hat"
	desc = "Poshness incarnate. With blue."
	icon_state = "goldtophatblue"
	item_state = "goldtophatblue"

/obj/item/clothing/head/fluff/goldtophat/red
	name = "Gold-trimmed Red Top Hat"
	desc = "Poshness incarnate. With red."
	icon_state = "goldtophatred"
	item_state = "goldtophatred"

//medieval guard helm
/obj/item/clothing/head/fluff/guardhelm
	name = "Plastic Guard helm"
	desc = "A plastic re-creation of a medieval-era headwear worn by extremely bored recruits of the local army. Kintergarden only."
	icon_state = "guardhelm"
	item_state = "guardhelm"
	flags = BLOCKHAIR

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

//black sombrero
/obj/item/clothing/head/fluff/blacksombrero
	name = "Black sombrero"
	desc = "A rare identifying hat of the infamous ancient renegade gang known as 'El Loco Pocos'"
	icon_state = "blacksombrero"
	item_state = "blacksombrero"
	flags = BLOCKHAIR

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

/obj/item/clothing/head/fluff/belkan
	name = "TSF ace beret"
	desc = "A black beret, decorated with triangular insignia of 2nd Solaris Fighter Squadron, worn by it's ace Damien Hawkins, known as Duke."
	icon_state = "beret_belkan"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	resistance_flags = FIRE_PROOF
	species_exception = list(/datum/species/golem,/datum/species/vox,/datum/species/skrell,/datum/species/tajaran,/datum/species/unathi,/datum/species/machine,/datum/species/vulpkanin,/datum/species/kidan,/datum/species/wryn,/datum/species/plasmaman,/datum/species/skeleton,/datum/species/shadow,/datum/species/shadow/ling,/datum/species/slime,/datum/species/grey,/datum/species/drask,/datum/species/diona,/datum/species/nucleation,)
