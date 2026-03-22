//contractor hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/contractor
	name = "Contractor hardsuit helmet"
	desc = "A top-tier syndicate helmet, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit0-contractor"
	item_state = "contractor_helm"
	item_color = "contractor"
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 35, BIO = 100, FIRE = 50, ACID = 90)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/suit/space/hardsuit/contractor
	name = "Contractor hardsuit"
	desc = "A top-tier syndicate hardsuit, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit-contractor"
	item_state = "contractor_hardsuit"
	item_color = "contractor"
	armor = list(MELEE = 40, BULLET = 50, LASER = 30, ENERGY = 30, BOMB = 35, BIO = 100, FIRE = 50, ACID = 90)
	slowdown = 0
	w_class = WEIGHT_CLASS_NORMAL
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/contractor
	jetpack = /obj/item/tank/jetpack/suit
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/advanced/chameleon_upgrade,
		//datum/action/item_action/advanced/hook_upgrade,
	)
	//working as ninja hook, deleted when droped
	var/obj/item/gun/magic/contractor_hook/scorpion
	var/disguise = FALSE

/obj/item/clothing/suit/space/hardsuit/contractor/Destroy()
	. = ..()
	QDEL_NULL(scorpion)

/obj/item/clothing/suit/space/hardsuit/contractor/ui_action_click(mob/user, datum/action/action, leftclick)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
			return TRUE
		if(/datum/action/item_action/advanced/chameleon_upgrade)
			toggle_chameleon()
			return TRUE
	return FALSE

/obj/item/clothing/suit/space/hardsuit/contractor/proc/update_suit()
	var/mob/living/carbon/human/H = src.loc
	H.update_worn_head()
	H.update_worn_oversuit()

//agent version disguised as engi hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/contractor/agent
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	description_antag = "Шлем хардсьюта-хамелеона, замаскированный изначально под инженерный шлем."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	item_color = "engineering"
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/suit/space/hardsuit/contractor/agent
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	description_antag = "Хардсьют-хамелеон, замаскированный изначально под инженерный хардсьют. Красный — предатель!"
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/contractor/agent

/datum/action/item_action/advanced/chameleon_upgrade
	name = "Advanced hardsuit chameleon module"
	desc = "An advanced version of chameleon tech, allowing you to disguise your hardsuit, giving you the opportunity to walk in full view of security and personnel without any difficulties."
	charge_type = ADV_ACTION_TYPE_TOGGLE
	button_icon_state = "chameleon"

/obj/item/clothing/suit/space/hardsuit/contractor/proc/toggle_chameleon()
	if(disguise)
		disguise = FALSE
		disable_chameleon()
		usr.visible_message(span_warning("[usr] changes the look of his hardsuit!"), span_notice("Turning off the disguise.."))
		return
	var/list/choices = list(
		"EVA" = image(icon = 'icons/mob/clothing/contractor.dmi', icon_state = "EVA"),
		"Mining Hardsuit" = image(icon = 'icons/mob/clothing/contractor.dmi', icon_state = "mining"),
		"Medical Hardsuit" = image(icon = 'icons/mob/clothing/contractor.dmi', icon_state = "medical"),
		"Security Hardsuit" = image(icon = 'icons/mob/clothing/contractor.dmi', icon_state = "security"),
		"Engineering Hardsuit" = image(icon = 'icons/mob/clothing/contractor.dmi', icon_state = "engineering")
	)
	var/selected_chameleon = show_radial_menu(usr, loc, choices, require_near = TRUE)
	switch(selected_chameleon)
		if("EVA")
			src.name = "EVA suit"
			src.icon_state = "spacenew"
			src.desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
			helmet.name = "EVA helmet"
			helmet.desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
			helmet.icon_state = "spacenew"
			helmet.item_color = "medical"
		if("Mining Hardsuit")
			src.name = "mining hardsuit"
			src.icon_state = "hardsuit-mining"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
			helmet.name = "mining hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
			helmet.icon_state = "hardsuit0-mining"
			helmet.item_color = "mining"
		if("Medical Hardsuit")
			src.name = "medical hardsuit"
			src.icon_state = "hardsuit-medical"
			src.desc = "A special suit designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
			helmet.name = "medical hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
			helmet.icon_state = "hardsuit0-medical"
			helmet.item_color = "medical"
		if("Security Hardsuit")
			src.name = "security hardsuit"
			src.icon_state = "hardsuit-sec"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
			helmet.name = "security hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
			helmet.icon_state = "hardsuit0-sec"
			helmet.item_color = "sec"
		if("Engineering Hardsuit")
			src.name = "engineering hardsuit"
			src.icon_state = "hardsuit-engineering"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
			helmet.name = "engineering hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
			helmet.icon_state = "hardsuit0-engineering"
			helmet.item_color = "engineering"
		else
			return
	to_chat(usr, span_notice("Turning on the disguise.."))
	sleep(25)
	usr.visible_message(span_warning("[usr] changes the look of his hardsuit!"), span_notice("[selected_chameleon] selected."))
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, TRUE)
	update_suit()
	disguise = TRUE

/obj/item/clothing/suit/space/hardsuit/contractor/proc/disable_chameleon()
	src.name = initial(name)
	src.icon_state = initial(src.icon_state)
	src.desc = initial(src.desc)
	helmet.name = initial(helmet.name)
	helmet.desc = initial(helmet.desc)
	helmet.icon_state = initial(helmet.icon_state)
	helmet.item_color = initial(helmet.item_color)
	update_suit()

/obj/item/clothing/suit/space/hardsuit/contractor/emp_act(severity)
	. = ..()
	if(disguise)
		usr.visible_message(span_warning("[usr] disguise is falling off!"), span_notice("Chameleon module overloading! Shutting down..."))
		disguise = FALSE
		disable_chameleon()

