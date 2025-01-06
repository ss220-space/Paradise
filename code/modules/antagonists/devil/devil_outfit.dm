/datum/outfit/devil_lawyer
	name = "Devil Lawyer"
	uniform = /obj/item/clothing/under/lawyer/black
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack
	l_hand = /obj/item/storage/briefcase
	l_pocket = /obj/item/pen
	l_ear = /obj/item/radio/headset
	id = /obj/item/card/id

/datum/outfit/devil_lawyer/post_equip(mob/living/carbon/human/human, visualsOnly = FALSE)
	var/obj/item/card/id/id = human.wear_id
    
	if(!istype(id) || id.assignment) // either doesn't have a card, or the card is already written to
		return

	var/name_to_use = human.real_name
	var/datum/antagonist/devil/devilinfo = human.mind?.has_antag_datum(/datum/antagonist/devil)

	if(devilinfo)
		name_to_use = devilinfo.info.truename // Having hell create an ID for you causes its risks

	id.name = "[name_to_use]'s ID Card (Lawyer)"
	id.registered_name = name_to_use
	id.assignment = "Lawyer"
	id.rank = id.assignment
	id.age = human.age
	id.sex = capitalize(human.gender)
	id.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	id.photo = get_id_photo(human)
