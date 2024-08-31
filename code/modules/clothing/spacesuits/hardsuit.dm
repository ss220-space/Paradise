//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
    //alt_desc =
	icon_state = "hardsuit0-engineering"
	base_icon_state = "hardsuit"
	item_state = "eng_helm"
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	max_integrity = 300
	allowed = list(/obj/item/flashlight)
	light_power = 1
	light_range = 4
	light_on = FALSE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

	//Species-specific stuff.
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/helmet.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		SPECIES_SKRELL = 'icons/mob/clothing/species/skrell/helmet.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/helmet.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/helmet.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/helmet.dmi'
		)


/obj/item/clothing/head/helmet/space/hardsuit/Initialize(mapload, obj/item/clothing/suit/space/hardsuit/parent)
	. = ..()
	if(!istype(parent))
		stack_trace("Investigate hardsuit helmet ([type]). Initialized without proper suit.")


/obj/item/clothing/head/helmet/space/hardsuit/update_icon_state()
	icon_state = "[base_icon_state][light_on]-[item_color]"


/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	toggle_light()


/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_light(update_buttons = TRUE)
	set_light_on(!light_on)
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item(update_buttons)


/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_HEAD)
		return TRUE


/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message(span_robot("<b>[msg]</b>"), 1)


/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	..()
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")


/obj/item/clothing/head/helmet/space/hardsuit/extinguish_light(force = FALSE)
	if(light_on)
		toggle_light()
		visible_message(span_danger("[src]'s light fades and turns off."))


/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	jetpack_upgradable = TRUE
	light_on = FALSE
	hide_tail_by_species = list(SPECIES_VOX , SPECIES_VULPKANIN , SPECIES_UNATHI, SPECIES_ASHWALKER_BASIC, SPECIES_ASHWALKER_SHAMAN, SPECIES_DRACONOID, SPECIES_TAJARAN)
	species_restricted = list("exclude", SPECIES_WRYN, "lesser form")
	sprite_sheets = list(
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_DRACONOID = 'icons/mob/clothing/species/unathi/suit.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/tajaran/suit.dmi',
		SPECIES_SKRELL = 'icons/mob/clothing/species/skrell/suit.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/suit.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/suit.dmi'
		)


/obj/item/clothing/suit/space/hardsuit/Initialize(mapload)
	. = ..()
	MakeHelmet()


/obj/item/clothing/suit/space/hardsuit/Destroy()
	unequip_helmet()
	helmet = null
	return ..()


/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype || helmet)
		return

	helmet = new helmettype(src, src)
	helmet.update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	RegisterSignal(helmet, COMSIG_ITEM_DROPPED, PROC_REF(on_helmet_dropped))
	RegisterSignal(helmet, COMSIG_ITEM_EQUIPPED, PROC_REF(on_helmet_equipped))
	RegisterSignal(helmet, COMSIG_QDELETING, PROC_REF(on_helmet_destroyed))


/obj/item/clothing/suit/space/hardsuit/proc/on_helmet_dropped()
	SIGNAL_HANDLER

	RemoveHelmet()


/obj/item/clothing/suit/space/hardsuit/proc/on_helmet_equipped(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(slot & ITEM_SLOT_HEAD)
		return
	RemoveHelmet()


/obj/item/clothing/suit/space/hardsuit/proc/on_helmet_destroyed()
	SIGNAL_HANDLER

	RemoveHelmet()
	helmet = null


/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot, initial)
	. = ..()
	RemoveHelmet()


/obj/item/clothing/suit/space/hardsuit/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	RemoveHelmet()


/obj/item/clothing/suit/space/hardsuit/ui_action_click(mob/user, datum/action/action, leftclick)
	ToggleHelmet()


/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_CLOTH_OUTER) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return TRUE


/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()


/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/hardsuit_taser_proof))
		add_fingerprint(user)
		var/obj/item/hardsuit_taser_proof/new_taser_proof = I
		if(user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER) == src)
			to_chat(user, span_warning("You cannot install the upgrade into [src] while wearing it."))
			return .
		if(taser_proof)
			to_chat(user, span_warning("The [name] already has a taser proof upfrage installed."))
			return .
		if(!user.drop_transfer_item_to_loc(new_taser_proof, src))
			return .
		to_chat(user, span_notice("You have successfully installed the taser proof upgrade into [src]."))
		taser_proof = new_taser_proof
		taser_proof.hardsuit = src
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/hardsuit_shield))
		add_fingerprint(user)
		var/obj/item/hardsuit_shield/new_shield = I
		if(user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER) == src)
			to_chat(user, span_warning("You cannot install the upgrade into [src] while wearing it."))
			return .
		var/datum/component/shielded/shielded = GetComponent(/datum/component/shielded)
		if(istype(shielded))
			to_chat(user, span_warning("The [name] already has a shield installed."))
			return .
		if(!user.drop_transfer_item_to_loc(new_shield, src))
			return .
		to_chat(user, span_notice("You have successfully installed the shield upgrade into [src]."))
		new_shield.attach_to_suit(src)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet()
	if(suit_adjusted)
		return RemoveHelmet()
	return EngageHelmet()


/obj/item/clothing/suit/space/hardsuit/proc/EngageHelmet()
	var/mob/living/carbon/human/wearer = loc
	if(suit_adjusted || !ishuman(wearer))
		return FALSE
	if(wearer.wear_suit != src)
		to_chat(wearer, span_warning("You must be wearing [src] to engage the helmet!"))
		return FALSE
	if(!helmet)
		to_chat(wearer, span_warning("[src] has no helmet anymore!"))
		return FALSE
	if(wearer.head)
		to_chat(wearer, span_warning("You're already wearing something on your head!"))
		return FALSE
	if(taser_proof?.ert_mindshield_locked)
		if(isertmindshielded(wearer))
			to_chat(wearer, span_notice("Access granted, identity verified..."))
		else
			to_chat(wearer, span_warning("Access denied. The user is not identified!"))
			return FALSE
	if(!wearer.equip_to_slot_if_possible(helmet, ITEM_SLOT_HEAD, initial = TRUE))
		return FALSE
	. = TRUE
	suit_adjusted = TRUE
	playsound(wearer, 'sound/items/rig_deploy.ogg', 110, TRUE)
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	to_chat(wearer, span_notice("You engage the helmet on [src]."))
	wearer.update_inv_wear_suit()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet()
	unequip_helmet()
	if(!suit_adjusted)
		return FALSE
	. = TRUE
	suit_adjusted = FALSE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	playsound(loc, 'sound/items/rig_retract.ogg', 110, TRUE)
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/clothing/suit/space/hardsuit/proc/unequip_helmet()
	if(!helmet || helmet.loc == src)
		return
	var/mob/living/carbon/human/wearer = helmet.loc
	if(!ishuman(wearer))
		helmet.forceMove(src)
		return
	wearer.transfer_item_to_loc(helmet, src, force = TRUE, silent = TRUE)
	wearer.update_inv_wear_suit()


//Engineering hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	item_color = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	resistance_flags = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	dog_fashion = /datum/dog_fashion/back/hardsuit

//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmos"
	item_state = "atmos_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75)
	item_color = "atmos"
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmos"
	item_state = "atmos_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	dog_fashion = null

//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90)
	item_color = "white"
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	icon_state = "hardsuit-white"
	item_state = "ce_hardsuit"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit
	dog_fashion = null

//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75)
	item_color = "mining"
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	light_range = 7

/obj/item/clothing/suit/space/hardsuit/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	icon_state = "hardsuit-mining"
	item_state = "mining_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining

//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndi"
	item_state = "syndie_helm"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	item_color = "syndi"
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEGLASSES|HIDENAME|HIDETAIL
	visor_clothing_flags = STOPSPRESSUREDMAGE
	var/combat_rad = 50


/obj/item/clothing/head/helmet/space/hardsuit/syndi/Destroy()
	linkedsuit = null
	return ..()


/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[item_color]"


/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_name(updates = ALL)
	. = ..()
	name = "[initial(name)][on ? "" : " (combat)"]"


/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][on ? "" : alt_desc]"


/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user)
	adjust_headgear(user)


/obj/item/clothing/head/helmet/space/hardsuit/syndi/adjust_headgear(mob/living/carbon/human/user, toggle = TRUE)
	if(user && !isturf(user.loc))
		to_chat(user, span_warning("You cannot toggle your helmet while in [user.loc]!" ))
		return
	if(toggle)
		on = !on
		if(on != light_on)
			toggle_light(update_buttons = FALSE)
	if(user)
		to_chat(user, span_notice("You switch your hardsuit to [on ? "EVA mode, sacrificing speed for space protection." : "combat mode and can now run at full speed."]"))
		playsound(loc, 'sound/items/rig_deploy.ogg', 110, TRUE)
	if(on)
		clothing_flags |= visor_clothing_flags
		flags_cover |= (HEADCOVERSEYES|HEADCOVERSMOUTH)
		flags_inv |= visor_flags_inv
		flags_inv_transparent |= visor_flags_inv_transparent
		cold_protection |= HEAD
		armor.rad = 100
	else
		clothing_flags &= ~visor_clothing_flags
		flags_cover &= ~(HEADCOVERSEYES|HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		flags_inv_transparent &= ~visor_flags_inv_transparent
		cold_protection &= ~HEAD
		armor.rad = combat_rad
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	user?.update_head(src, toggle_off = !on)
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()
	update_linked_hardsuit(toggle)


/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/update_linked_hardsuit(toggle = TRUE)
	if(!linkedsuit)
		return

	if(toggle)
		linkedsuit.on = !linkedsuit.on

	if(linkedsuit.on)
		linkedsuit.slowdown = 1
		linkedsuit.clothing_flags |= STOPSPRESSUREDMAGE
		linkedsuit.cold_protection |= (UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL)
		linkedsuit.armor.rad = 100
	else
		linkedsuit.slowdown = 0
		linkedsuit.clothing_flags &= ~STOPSPRESSUREDMAGE
		linkedsuit.cold_protection &= ~(UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL)
		linkedsuit.armor.rad = combat_rad

	linkedsuit.update_appearance(UPDATE_ICON_STATE|UPDATE_NAME|UPDATE_DESC)
	linkedsuit.update_equipped_item()


/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndi"
	item_state = "syndie_hardsuit"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	item_color = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle_hardsuit_mode)

	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit


/obj/item/clothing/suit/space/hardsuit/syndi/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/head/helmet/space/hardsuit/syndi/our_helmet = helmet
	our_helmet?.linkedsuit = src
	our_helmet?.adjust_headgear(toggle = FALSE)


/obj/item/clothing/suit/space/hardsuit/syndi/update_icon_state()
	icon_state = "hardsuit[on]-[item_color]"


/obj/item/clothing/suit/space/hardsuit/syndi/update_name(updates = ALL)
	. = ..()
	name = "[initial(name)][on ? "" : " (combat)"]"


/obj/item/clothing/suit/space/hardsuit/syndi/update_desc(updates = ALL)
	. = ..()
	desc = "[initial(desc)][on ? "" : alt_desc]"


/obj/item/clothing/suit/space/hardsuit/syndi/EngageHelmet()
	. = ..()
	if(. && on && !light_on)
		helmet.toggle_light()


//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 40, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	item_color = "syndielite"
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	combat_rad = 70

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode."
	icon_state = "hardsuit0-syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 40, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	item_color = "syndielite"
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/comms
	name = "Comms Officer elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. This one has contractor style."
	icon_state = "hardsuit0-commsoff"
	item_color = "commsoff"
/obj/item/clothing/suit/space/hardsuit/syndi/elite/comms
	name = "Comms Officer elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. This one has contractor style."
	icon_state = "hardsuit0-commsoff"
	item_color = "commsoff"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/comms

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/med
	name = "Elite medical syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet. This one is made special for medics."
	icon_state = "hardsuit0-smedelite"
	item_state = "hardsuit0-smedelite"
	item_color = "smedelite"

/obj/item/clothing/suit/space/hardsuit/syndi/elite/med
	name = "Elite medical syndicate hardsuit helmet"
	desc = "An elite version of the syndicate hardsuit. This one is made special for medics."
	icon_state = "hardsuit0-smedelite"
	item_state = "hardsuit0-smedelite"
	item_color = "smedelite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/med

//Strike team hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst
	icon_state = "hardsuit0-sst"
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 40, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100) //Almost as good as DS gear, but unlike DS can switch to combat for mobility
	item_color = "sst"
	combat_rad = 100

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst
	icon_state = "hardsuit0-sst"
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 40, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100)
	item_color = "sst"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst

/obj/item/clothing/suit/space/hardsuit/syndi/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit."
	icon_state = "freedom"
	item_state = "freedom"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/syndi/freedom/update_icon_state()
	return

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom/update_icon_state()
	return

//Soviet hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/soviet
	name = "\improper Soviet hardsuit helmet"
	desc = "A military hardsuit helmet bearing the red star of the U.S.S.P."
	icon_state = "hardsuit0-soviet"
	item_state = "hardsuit0-soviet"
	item_color = "soviet"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)

/obj/item/clothing/suit/space/hardsuit/soviet
	name = "\improper Soviet hardsuit"
	desc = "A soviet military hardsuit designed for maximum speed and mobility. Proudly displays the U.S.S.P flag on the chest."
	icon_state = "hardsuit-soviet"
	item_state = "hardsuit-soviet"
	species_restricted = list(SPECIES_HUMAN, SPECIES_SLIMEPERSON, SPECIES_SKELETON, SPECIES_NUCLEATION, SPECIES_MACNINEPERSON, SPECIES_KIDAN, SPECIES_PLASMAMAN)  // Until the xenos textures are created
	slowdown = 0.5
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit helmet"
	desc = "A military hardsuit helmet with a red command stripe."
	icon_state = "hardsuit0-soviet-commander"
	item_state = "hardsuit0-soviet-commander"
	item_color = "soviet-commander"

/obj/item/clothing/suit/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit"
	desc = "A soviet military command hardsuit designed for maximum speed and mobility."
	icon_state = "hardsuit-soviet-commander"
	item_state = "hardsuit-soviet-commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet/commander

//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	item_color = "medical"
	flash_protect = FLASH_PROTECTION_NONE
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/suit/space/hardsuit/medical
	name = "medical hardsuit"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
	icon_state = "hardsuit-medical"
	item_state = "medical_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical,/obj/item/rad_laser)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5

//Security
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	item_color = "sec"

/obj/item/clothing/head/helmet/space/hardsuit/security/warden
	name = "warden's hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-warden"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30,"energy" = 20, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 85)
	item_color = "warden"

/obj/item/clothing/suit/space/hardsuit/security/warden
	name = "warden's hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-warden"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30,"energy" = 20, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 85)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/warden

/obj/item/clothing/suit/space/hardsuit/security
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-sec"
	item_state = "sec_hardsuit"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	armor = list("melee" = 45, "bullet" = 25, "laser" = 30, "energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	item_color = "hos"

/obj/item/clothing/suit/space/hardsuit/security/hos
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-hos"
	armor = list("melee" = 45, "bullet" = 25, "laser" = 30, "energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/security/brigmed
	name = "brig physician's hardsuit helmet"
	desc = "Improved medical hardsuit helmet with an additional layer of armor."
	icon_state = "hardsuit0-brigmed"
	armor = list("melee" = 30, "bullet" = 10, "laser" = 20, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	item_color = "brigmed"
	flash_protect = FLASH_PROTECTION_NONE
	examine_extensions = EXAMINE_HUD_SCIENCE

/obj/item/clothing/suit/space/hardsuit/security/brigmed
	name = "brig physician's hardsuit"
	desc = "Improved medical hardsuit with an additional layer of armor."
	icon_state = "hardsuit-brigmed"
	item_state = "hardsuit-brigmed"
	armor = list("melee" = 30, "bullet" = 10, "laser" = 20, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/brigmed
	slowdown = 0.5

//Blueshield hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/blueshield
	name = "blueshield's hardsuit helmet"
	desc = "A special bulky helmet worn by the Blueshield Lieutenant. Has blue highlights and Blueshield`s sign on the chest plate. Heavy armoured, space ready and fire resistant."
	icon_state = "hardsuit0-blueshield"
	item_state = "hardsuit0-blueshield"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 80)
	item_color = "blueshield"

/obj/item/clothing/suit/space/hardsuit/blueshield
	name = "blueshield's hardsuit"
	desc = "A special bulky suit worn by the Blueshield Lieutenant. Has blue highlights and Blueshield`s sign on the chest plate. Heavy armoured, space ready and fire resistant."
	icon_state = "hardsuit-blueshield"
	item_state = "hardsuit-blueshield"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 80)
	item_color = "blueshield"
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/blueshield
	jetpack = /obj/item/tank/jetpack/suit

//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "Research Director Hardsuit Helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	item_state = "rd"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80)
	item_color = "rd"
	examine_extensions = EXAMINE_HUD_SCIENCE
	var/explosion_detection_dist = 40


/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/living/carbon/human/user, slot, initial = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		GLOB.doppler_arrays += src //Needed to sense the kabooms


/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		GLOB.doppler_arrays -= src


/obj/item/clothing/head/helmet/space/hardsuit/rd/proc/sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	var/turf/T = get_turf(src)
	var/dx = abs(x0 - T.x)
	var/dy = abs(y0 - T.y)
	var/distance = 40
	if(T.z != z0)
		return
	if(dx > dy)
		distance = dx
	else
		distance = dy
	if(distance > explosion_detection_dist)
		return
	display_visor_message("Explosion detected! Epicenter radius: [devastation_range], Outer radius: [heavy_impact_range], Shockwave radius: [light_impact_range]")

/obj/item/clothing/suit/space/hardsuit/rd
	name = "Research Director Hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	icon_state = "hardsuit-rd"
	item_state = "hardsuit-rd"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd
	jetpack = /obj/item/tank/jetpack/suit

//Singuloth armor
/obj/item/clothing/head/helmet/space/hardsuit/singuloth
	name = "singuloth knight's helmet"
	desc = "This is an adamantium helmet from the chapter of the Singuloth Knights. It shines with a holy aura."
	icon_state = "hardsuit0-singuloth"
	item_state = "singuloth_helm"
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 95, acid = 95)
	item_color = "singuloth"
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/singuloth
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	icon_state = "hardsuit-singuloth"
	item_state = "singuloth_hardsuit"
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 95, acid = 95)
	clothing_flags = STOPSPRESSUREDMAGE
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/singuloth
	sprite_sheets = null

//Battlemage Hardsuit — code\modules\clothing\suits\wiz_robe.dm
//Deathsquad Hardsuit — code\modules\clothing\spacesuits\ert.dm
//Prototype RIG Hardsuit — code\modules\awaymissions\mission_code\ruins\oldstation.dm
//Contractor Hardsuit - code\modules\antagonists\traitor\contractor\items\contractor_hardsuit.dm
