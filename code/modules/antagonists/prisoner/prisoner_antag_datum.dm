// Prisoner antag datum
/datum/antagonist/traitor/prisoner
	name = "Escaping Prisoner"
	job_rank = ROLE_ESCAPING_PRISONER
	special_role = SPECIAL_ROLE_ESCAPING_PRISONER
	antag_hud_name = "hudprisonerantag"
	syndicate_antag_hud_name = "hudprisonerantag"
	antag_hud_type = ANTAG_HUD_PRISONER_TRAITOR
	wiki_page_name = "Escaping Prisoner"
	russian_wiki_name = "Бунтовщики"
	antag_menu_name = "Бунтовщик"
	give_uplink = FALSE
	antag_sound = "sound/ambience/antag/prisonbreak.ogg"

/datum/antagonist/traitor/prisoner/give_objectives()
	// Objective #1: Escape from prison
	add_objective(/datum/objective/prison_escape)
	// Objective #2: Kill one person
	add_objective(/datum/objective/maroon)

/datum/antagonist/traitor/prisoner/finalize_antag()
	. = ..()
	give_prisoner_items()

/datum/antagonist/traitor/prisoner/proc/give_prisoner_items()
	var/mob/living/carbon/human/traitor_mob = owner.current
	var/item_type = pick(/obj/item/kitchen/knife/glassshiv, /obj/item/clothing/gloves/knuckles, /obj/item/clothing/glasses/sunglasses, /obj/item/crowbar)
	var/prisoner_item = new item_type(traitor_mob.loc)
	traitor_mob.equip_to_slot_if_possible(prisoner_item, ITEM_SLOT_POCKET_LEFT, qdel_on_fail = TRUE)
