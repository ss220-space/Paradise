/obj/item/organ/internal/liver/skrell
	species_type = /datum/species/skrell
	name = "skrell liver"
	icon = 'icons/obj/species_organs/skrell.dmi'
	alcohol_intensity = 4

/obj/item/organ/internal/liver/skrell/on_life()
	. = ..()
	var/datum/reagent/alcohol = locate(/datum/reagent/consumable/ethanol) in owner.reagents.reagent_list
	if(alcohol)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_traumatized())
			owner.adjustToxLoss(5)
		internal_receive_damage(1)


/obj/item/organ/internal/headpocket
	species_type = /datum/species/skrell
	name = "headpocket"
	desc = "Allows Skrell to hide tiny objects within their head tentacles."
	icon = 'icons/obj/species_organs/skrell.dmi'
	icon_state = "skrell_headpocket"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ_zone = BODY_ZONE_HEAD
	slot = INTERNAL_ORGAN_HEADPOCKET
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/obj/item/storage/internal/pocket

/obj/item/organ/internal/headpocket/New()
	..()
	pocket = new /obj/item/storage/internal(src)
	pocket.storage_slots = 1
	// Allow adjacency calculation to work properly
	loc = owner
	// Fit only pocket sized items
	pocket.max_w_class = WEIGHT_CLASS_SMALL
	pocket.max_combined_w_class = 2

/obj/item/organ/internal/headpocket/on_life()
	..()
	var/obj/item/organ/external/head/head = owner.get_organ(BODY_ZONE_HEAD)
	if(pocket.contents.len && !findtextEx(head.h_style, "Tentacles"))
		owner.visible_message(span_notice("Something falls from [owner]'s head!"),
													span_notice("Something falls from your head!"))
		empty_contents()

/obj/item/organ/internal/headpocket/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!loc)
		loc = owner
	pocket.MouseDrop(owner)

/obj/item/organ/internal/headpocket/on_owner_death()
	empty_contents()

/obj/item/organ/internal/headpocket/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	empty_contents()
	. = ..()

/obj/item/organ/internal/headpocket/proc/empty_contents()
	for(var/obj/item/I in pocket.contents)
		pocket.remove_from_storage(I, get_turf(owner))

/obj/item/organ/internal/headpocket/proc/get_contents()
	return pocket.contents

/obj/item/organ/internal/headpocket/emp_act(severity)
	pocket.emp_act(severity)
	..()

/obj/item/organ/internal/headpocket/hear_talk(mob/living/M as mob, list/message_pieces)
	pocket.hear_talk(M, message_pieces)
	..()

/obj/item/organ/internal/headpocket/hear_message(mob/living/M as mob, msg)
	pocket.hear_message(M, msg)
	..()

/obj/item/organ/internal/heart/skrell
	species_type = /datum/species/skrell
	name = "skrell heart"
	desc = "A stream lined heart."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/brain/skrell
	species_type = /datum/species/skrell
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "A brain with a odd division in the middle."
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/skrell.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/skrell
	species_type = /datum/species/skrell
	name = "skrell lungs"
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/kidneys/skrell
	species_type = /datum/species/skrell
	name = "skrell kidneys"
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "The smallest kidneys you have ever seen, it probably doesn't even work."

/obj/item/organ/internal/eyes/skrell
	species_type = /datum/species/skrell
	see_in_dark = 5
	can_see_food = TRUE
	name = "skrell eyeballs"
	icon = 'icons/obj/species_organs/skrell.dmi'
