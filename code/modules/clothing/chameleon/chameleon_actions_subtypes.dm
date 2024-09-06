// Neck-thing
/datum/action/item_action/chameleon/change/neck
	chameleon_name = "Neck Accessory"
	chameleon_type = /obj/item/clothing/neck


// Stamp
/datum/action/item_action/chameleon/change/stamp
	chameleon_name = "Stamp"
	chameleon_type = /obj/item/stamp

/datum/action/item_action/chameleon/change/stamp/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/stamp/syndicate/taipan), only_root_path = TRUE)


// PDA
/datum/action/item_action/chameleon/change/pda
	chameleon_name = "PDA"
	chameleon_type = /obj/item/pda


/datum/action/item_action/chameleon/change/pda/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(/obj/item/pda/heads), only_root_path = TRUE)


/datum/action/item_action/chameleon/change/pda/update_look(obj/item/picked_item)
	. = ..()
	var/obj/item/pda/agent_pda = target
	var/obj/item/card/id/id_card = owner.get_id_card()
	if(id_card)
		agent_pda.custom_name = "PDA-[id_card.registered_name]"
		if(!agent_pda.fakejob)
			agent_pda.fakejob = id_card.assignment
	else
		agent_pda.custom_name = null

	agent_pda.chameleon_skin = picked_item
	agent_pda.update_appearance()

	if(!ismob(agent_pda.loc))
		UpdateButtonIcon()


/datum/action/item_action/chameleon/change/pda/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	var/obj/item/pda/agent_pda = target
	agent_pda.fakejob = null
	return ..()


/datum/action/item_action/chameleon/change/pda/select_look(mob/user)
	var/obj/item/pda/agent_pda = target
	agent_pda.fakejob = null
	return ..()


/datum/action/item_action/chameleon/change/pda/apply_job_data(datum/job/job_datum)
	var/obj/item/pda/agent_pda = target
	agent_pda.fakejob = job_datum.title


// Headset
/datum/action/item_action/chameleon/change/headset
	chameleon_name = "Headset"
	chameleon_type = /obj/item/radio/headset


// Belt
/datum/action/item_action/chameleon/change/belt
	chameleon_name = "Belt"
	chameleon_type = /obj/item/storage/belt


// Backpack
/datum/action/item_action/chameleon/change/backpack
	chameleon_name = "Backpack"
	chameleon_type = /obj/item/storage/backpack


// Shoes
/datum/action/item_action/chameleon/change/shoes
	chameleon_name = "Shoes"
	chameleon_type = /obj/item/clothing/shoes


// Mask
/datum/action/item_action/chameleon/change/mask
	chameleon_name = "Mask"
	chameleon_type = /obj/item/clothing/mask


// Hat
/datum/action/item_action/chameleon/change/hat
	chameleon_name = "Hat"
	chameleon_type = /obj/item/clothing/head


/datum/action/item_action/chameleon/change/hat/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/clothing/head/helmet/changeling,
		/obj/item/clothing/head/helmet/space/changeling,
	), only_root_path = TRUE)


// Gloves
/datum/action/item_action/chameleon/change/gloves
	chameleon_name = "Gloves"
	chameleon_type = /obj/item/clothing/gloves


/datum/action/item_action/chameleon/change/gloves/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/clothing/gloves,
		/obj/item/clothing/gloves/color,
	), only_root_path = TRUE)


// Glasses
/datum/action/item_action/chameleon/change/glasses
	chameleon_name = "Glasses"
	chameleon_type = /obj/item/clothing/glasses


/datum/action/item_action/chameleon/change/glasses/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/clothing/glasses/chameleon,
		/obj/item/clothing/glasses/hud/security/chameleon,
	))


// Suit
/datum/action/item_action/chameleon/change/suit
	chameleon_name = "Suit"
	chameleon_type = /obj/item/clothing/suit


/datum/action/item_action/chameleon/change/suit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/clothing/suit/armor/abductor,
		/obj/item/clothing/suit/armor/changeling,
		/obj/item/clothing/suit/space/changeling,
	), only_root_path = TRUE)


/datum/action/item_action/chameleon/change/suit/apply_outfit(datum/outfit/applying_from, list/all_items_to_apply)
	. = ..()
	if(!.)
		return .
	if(ispath(applying_from.suit, /obj/item/clothing/suit/hooded))
		// If we're appling a hooded suit, and wearing a cham hat, make it a hood
		var/obj/item/clothing/suit/hooded/hooded = applying_from.suit
		var/datum/action/item_action/chameleon/change/hat/hood_action = locate() in owner?.actions
		hood_action?.update_look(initial(hooded.hoodtype))
	else if(ispath(applying_from.suit, /obj/item/clothing/suit/space/hardsuit))
		// Same thing with hardsuit's helmet
		var/obj/item/clothing/suit/space/hardsuit/hardsuit = applying_from.suit
		var/datum/action/item_action/chameleon/change/hat/hardsuit_action = locate() in owner?.actions
		hardsuit_action?.update_look(initial(hardsuit.helmettype))


// Jumpsuit
/datum/action/item_action/chameleon/change/jumpsuit
	chameleon_name = "Jumpsuit"
	chameleon_type = /obj/item/clothing/under


/datum/action/item_action/chameleon/change/jumpsuit/initialize_blacklist()
	. = ..()
	chameleon_blacklist |= typecacheof(list(
		/obj/item/clothing/under,
		/obj/item/clothing/under/color,
		/obj/item/clothing/under/rank,
	), only_root_path = TRUE)

