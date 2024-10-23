/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	parent_organ_zone = BODY_ZONE_R_ARM
	slot = INTERNAL_ORGAN_R_ARM_DEVICE
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item
	var/sound_on = 'sound/mecha/mechmove03.ogg'
	var/sound_off = 'sound/mecha/mechmove03.ogg'

/obj/item/organ/internal/cyberimp/arm/Initialize()
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)

	update_transform()
	slot = parent_organ_zone + "_device"
	items_list = contents.Copy()

/obj/item/organ/internal/cyberimp/arm/proc/update_transform()
	if(parent_organ_zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	. = ..()
	. += span_notice("[src] is assembled in the [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration.")
	. += span_info("You can use a screwdriver to reassemble it.")

/obj/item/organ/internal/cyberimp/arm/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(parent_organ_zone == BODY_ZONE_R_ARM)
		parent_organ_zone = BODY_ZONE_L_ARM
	else
		parent_organ_zone = BODY_ZONE_R_ARM
	slot = parent_organ_zone + "_device"
	to_chat(user, span_notice("You modify [src] to be installed on the [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	update_transform()

/obj/item/organ/internal/cyberimp/arm/insert(mob/living/carbon/arm_owner, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	var/side = parent_organ_zone == BODY_ZONE_R_ARM ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM
	hand = owner.bodyparts_by_name[side]
	if(hand)
		RegisterSignal(hand, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self)) //If the limb gets an attack-self, open the menu. Only happens when hand is empty
		RegisterSignal(arm_owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.

/obj/item/organ/internal/cyberimp/arm/remove(mob/living/carbon/arm_owner, special = ORGAN_MANIPULATION_DEFAULT)
	Retract()
	if(hand)
		UnregisterSignal(hand, COMSIG_ITEM_ATTACK_SELF)
		UnregisterSignal(arm_owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
	. = ..()

/obj/item/organ/internal/cyberimp/arm/proc/on_item_attack_self()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/obj/item/organ/internal/cyberimp/arm/emag_act()
	return 0

/obj/item/organ/internal/cyberimp/arm/emp_act(severity)
	if(emp_proof)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("[src] is hit by EMP!"))
		// give the owner an idea about why his implant is glitching
		Retract()
	..()

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/internal/cyberimp/arm/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER
	if(!host)
		return //How did we even get here
	var/obj/current_hand = host.hand ? host.get_organ(BODY_ZONE_L_ARM) : host.get_organ(BODY_ZONE_R_ARM)
	if(hand != current_hand)
		return //wrong hand
	if(Retract())
		return COMPONENT_CANCEL_DROP


/obj/item/organ/internal/cyberimp/arm/proc/unexpected_drop()
	SIGNAL_HANDLER

	if(Retract())
		return COMPONENT_ITEM_BLOCK_UNEQUIP


/obj/item/organ/internal/cyberimp/arm/proc/Retract()
	if(!active_item || (active_item in src))
		return FALSE

	owner.visible_message(span_notice("[owner] retracts [active_item] back into [owner.p_their()] [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("[active_item] snaps back into your [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_italics("You hear a short mechanical noise."))

	UnregisterSignal(active_item, COMSIG_ITEM_PRE_UNEQUIP)
	owner.drop_item_ground(active_item, force = TRUE, silent = TRUE)
	active_item.forceMove(src)
	active_item = null
	playsound(get_turf(owner), src.sound_off, 50, TRUE)
	return TRUE

/obj/item/organ/internal/cyberimp/arm/proc/Extend(obj/item/augment)
	if(!(augment in src))
		return

	active_item = augment

	ADD_TRAIT(active_item, TRAIT_NODROP, AUGMENT_TRAIT)
	RegisterSignal(active_item, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(unexpected_drop))
	active_item.resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|UNACIDABLE|ACID_PROOF
	active_item.slot_flags = NONE
	active_item.w_class = WEIGHT_CLASS_HUGE
	active_item.materials = null

	var/arm_slot = (parent_organ_zone == BODY_ZONE_R_ARM ? ITEM_SLOT_HAND_RIGHT : ITEM_SLOT_HAND_LEFT)
	var/obj/item/arm_item = owner.get_item_by_slot(arm_slot)

	if(arm_item)
		if(!owner.drop_item_ground(arm_item))
			to_chat(owner, span_warning("Your [arm_item] interferes with [src]!"))
			return
		else
			to_chat(owner, span_notice("You drop [arm_item] to activate [src]!"))

	if(parent_organ_zone == BODY_ZONE_R_ARM ? !owner.put_in_r_hand(active_item, silent = TRUE) : !owner.put_in_l_hand(active_item, silent = TRUE))
		to_chat(owner, span_warning("Your [src] fails to activate!"))
		return

	// Activate the hand that now holds our item.
	if(parent_organ_zone == BODY_ZONE_R_ARM ? owner.hand : !owner.hand)
		owner.swap_hand()

	owner.visible_message(span_notice("[owner] extends [active_item] from [owner.p_their()] [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("You extend [active_item] from your [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_italics("You hear a short mechanical noise."))
	playsound(get_turf(owner), src.sound_on, 50, 1)

/obj/item/organ/internal/cyberimp/arm/ui_action_click(mob/user, datum/action/action, leftclick)
	if(crit_fail || (!active_item && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	// You can emag the arm-mounted implant by activating it while holding emag in it's hand.
	var/arm_slot = (parent_organ_zone == BODY_ZONE_R_ARM ? ITEM_SLOT_HAND_RIGHT : ITEM_SLOT_HAND_LEFT)
	if(istype(owner.get_item_by_slot(arm_slot), /obj/item/card/emag) && emag_act(owner))
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			radial_menu(owner)
	else
		Retract()

/obj/item/organ/internal/cyberimp/arm/proc/check_menu(var/mob/user)
	return (owner && owner == user && owner.stat != DEAD && (src in owner.internal_organs) && !active_item)

/obj/item/organ/internal/cyberimp/arm/proc/radial_menu(mob/user)
	var/list/choices = list()
	for(var/obj/I in items_list)
		choices["[I.name]"] = image(icon = I.icon, icon_state = I.icon_state)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user))
	if(!check_menu(user))
		return
	var/obj/item/selected
	for(var/obj/item in items_list)
		if(item.name == choice)
			selected = item
			break
	if(istype(selected) && (selected in contents))
		Extend(selected)

/obj/item/organ/internal/cyberimp/arm/gun/emp_act(severity)
	if(emp_proof)
		return
	if(prob(30/severity) && owner && !crit_fail)
		Retract()
		owner.visible_message(span_danger("A loud bang comes from [owner]\'s [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!"))
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, 1)
		to_chat(owner, span_userdanger("You feel an explosion erupt inside your [parent_organ_zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!"))
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		crit_fail = 1
	else // The gun will still discharge anyway.
		..()


/obj/item/organ/internal/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	origin_tech = "materials=4;combat=4;biotech=4;powerstorage=4"
	contents = newlist(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/internal/cyberimp/arm/gun/laser/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/gun/laser/Initialize(mapload)
	. = ..()
	var/obj/item/organ/internal/cyberimp/arm/gun/laser/laserphasergun = locate(/obj/item/gun/energy/laser/mounted) in contents
	laserphasergun.icon = icon //No invisible laser guns kthx
	laserphasergun.icon_state = icon_state

/obj/item/organ/internal/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	origin_tech = "materials=5;combat=5;biotech=4;powerstorage=4"
	contents = newlist(/obj/item/gun/energy/gun/advtaser/mounted)

/obj/item/organ/internal/cyberimp/arm/gun/taser/l
	parent_organ_zone = BODY_ZONE_L_ARM


/obj/item/organ/internal/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm. Contains all neccessary tools."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "utilitybelt")

/obj/item/organ/internal/cyberimp/arm/toolset/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/toolset/emag_act(mob/user)
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		if(user)
			to_chat(user, span_notice("You unlock [src]'s integrated knife!"))
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/arm/atmostoolset
	name = "integrated atmos toolset implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm. Contains all neccessary tools for atmos-techs."
	icon_state = "atmos_arm_implant"
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4"
	contents = newlist(/obj/item/holosign_creator/atmos, /obj/item/rpd, /obj/item/analyzer, /obj/item/destTagger, /obj/item/extinguisher/mini,
		/obj/item/pipe_painter, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/tools.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "rpd")

/obj/item/organ/internal/cyberimp/arm/atmostoolset/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/hacking
	name = "hacking arm implant"
	desc = "A small arm implant containing an advanced screwdriver, wirecutters, and multitool designed for engineers and on-the-field machine modification. Actually legal, despite what the name may make you think."
	origin_tech = "materials=3;engineering=4;biotech=3;powerstorage=4;abductor=3"
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/abductor)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/device.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "hacktool")

/obj/item/organ/internal/cyberimp/arm/hacking/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal, and highly dangerous cybernetic implant that can project a deadly blade of concentrated enregy."
	contents = newlist(/obj/item/melee/energy/blade/hardlight)
	origin_tech = "materials=4;combat=5;biotech=3;powerstorage=2;syndicate=5"

/obj/item/organ/internal/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	contents = newlist(/obj/item/gun/medbeam)
	origin_tech = "materials=5;combat=2;biotech=5;powerstorage=4;syndicate=1"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/chronos.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "chronogun")

/obj/item/organ/internal/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm, that is able to be used as a powerful flash."
	contents = newlist(/obj/item/flash/armimplant)
	origin_tech = "materials=4;combat=3;biotech=4;magnets=4;powerstorage=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/device.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "flash")

/obj/item/organ/internal/cyberimp/arm/flash/Initialize()
	. = ..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/internal/cyberimp/arm/flash/Extend(obj/item/item)
	. = ..()
	active_item.set_light(7, l_on = TRUE)

/obj/item/organ/internal/cyberimp/arm/flash/Retract()
	if(!active_item || (active_item in src))
		return FALSE
	active_item.set_light_on(FALSE)
	return ..()

/obj/item/organ/internal/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	contents = newlist(/obj/item/borg/stun)
	origin_tech = "materials=3;combat=5;biotech=4;powerstorage=4;syndicate=3"

/obj/item/organ/internal/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm"
	contents = newlist(/obj/item/melee/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/flash/armimplant)
	origin_tech = "materials=5;combat=7;biotech=5;powerstorage=5;syndicate=6;programming=5"

/obj/item/organ/internal/cyberimp/arm/combat/New()
	..()
	if(locate(/obj/item/flash/armimplant) in items_list)
		var/obj/item/flash/armimplant/F = locate(/obj/item/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/internal/cyberimp/arm/combat/centcom
	name = "NT specops cybernetics implant"
	desc = "An extremely powerful cybernetic implant that contains combat and utility modules used by NT special forces."
	contents = newlist(/obj/item/gun/energy/pulse/pistol/m1911, /obj/item/door_remote/omni, /obj/item/melee/energy/blade/hardlight, /obj/item/reagent_containers/hypospray/combat/nanites, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/implanter/mindshield, /obj/item/flash/armimplant)
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "m1911"
	emp_proof = 1

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade
	sound_on = 'sound/weapons/wristblades_on.ogg'
	sound_off = 'sound/weapons/wristblades_off.ogg'

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex
	name = "hidden blade implant"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	contents = newlist(/obj/item/melee/mantisblade)
	origin_tech = "materials=6;combat=6;biotech=6;syndicate=4;programming=5;"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/surgery.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "syndie_mantis")
	icon_state = "syndie_mantis"


/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/horlex/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard
	name = "hidden blade implant"
	desc = "A blade designed to be hidden just beneath the skin. The brain is directly linked to this bad boy, allowing it to spring into action."
	contents = newlist(/obj/item/melee/mantisblade/shellguard)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/surgery.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "mantis")
	origin_tech = "materials=6;combat=6;biotech=6;programming=5;"
	icon_state = "mantis"

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/shellguard/l
	parent_organ_zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/emp_act(severity)
	..()

	if(crit_fail || emp_proof)
		return
	crit_fail = TRUE
	Retract()
	addtimer(CALLBACK(src, PROC_REF(reboot)), 10 SECONDS)

/obj/item/organ/internal/cyberimp/arm/toolset/mantisblade/proc/reboot()
	crit_fail = FALSE

/obj/item/organ/internal/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm"
	icon_state = "surgical_arm_implant"
	contents = newlist(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/bonesetter/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/bonegel/augment, /obj/item/FixOVein/augment, /obj/item/surgicaldrill/augment)
	origin_tech = "materials=3;engineering=3;biotech=3;programming=2;magnets=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/storage.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "duffel-med")

/obj/item/organ/internal/cyberimp/arm/surgery/l
	parent_organ_zone = BODY_ZONE_L_ARM
	slot = INTERNAL_ORGAN_L_ARM_DEVICE

/obj/item/organ/internal/cyberimp/arm/janitorial
	name = "janitorial toolset implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm"
	icon_state = "janitor_arm_implant"
	contents = newlist(/obj/item/mop/advanced, /obj/item/soap, /obj/item/lightreplacer, /obj/item/holosign_creator/janitor, /obj/item/melee/flyswatter, /obj/item/reagent_containers/spray/cleaner/safety)
	origin_tech = "materials=3;engineering=4;biotech=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "janibelt")

/obj/item/organ/internal/cyberimp/arm/janitorial/l
	parent_organ_zone = BODY_ZONE_L_ARM
	slot = INTERNAL_ORGAN_L_ARM_DEVICE

/obj/item/organ/internal/cyberimp/arm/botanical
	name = "botanical toolset implant"
	desc = "A set of botanical tools hidden behind a concealed panel on the user's arm"
	icon_state = "botanical_arm_implant"
	contents = newlist(/obj/item/plant_analyzer, /obj/item/cultivator, /obj/item/hatchet, /obj/item/shovel/spade, /obj/item/wirecutters, /obj/item/wrench)
	origin_tech = "materials=3;engineering=4;biotech=3"
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/clothing/belts.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "botanybelt")

/obj/item/organ/internal/cyberimp/arm/botanical/l
	parent_organ_zone = BODY_ZONE_L_ARM
	slot = INTERNAL_ORGAN_L_ARM_DEVICE

// lets make IPCs even *more* vulnerable to EMPs!
/obj/item/organ/internal/cyberimp/arm/power_cord
	species_type = /datum/species/machine
	name = "APC-compatible power adapter implant"
	desc = "An implant commonly installed inside IPCs in order to allow them to easily collect energy from their environment"
	origin_tech = "materials=3;biotech=2;powerstorage=3"
	contents = newlist(/obj/item/apc_powercord)

/obj/item/organ/internal/cyberimp/arm/power_cord/emp_act(severity)
	// To allow repair via nanopaste/screwdriver
	// also so IPCs don't also catch on fire and fall even more apart upon EMP
	if(emp_proof)
		return
	damage = 1
	crit_fail = TRUE

/obj/item/organ/internal/cyberimp/arm/power_cord/surgeryize()
	if(crit_fail && owner)
		to_chat(owner, span_notice("Your [src] feels functional again."))
	crit_fail = FALSE


/obj/item/apc_powercord
	name = "power cable"
	desc = "Insert into a nearby APC to draw power from it."
	icon = 'icons/obj/engines_and_power/power.dmi'
	icon_state = "wire1"
	item_flags = NOBLUDGEON
	var/drawing_power = FALSE

/obj/item/apc_powercord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!isapc(target) || !ishuman(user) || !proximity_flag)
		return ..()
	if(drawing_power)
		to_chat(user, span_warning("You're already charging."))
		return
	user.changeNext_move(attack_speed)
	var/obj/machinery/power/apc/A = target
	var/mob/living/carbon/human/H = user
	if(H.get_int_organ(/obj/item/organ/internal/cell))
		if(A.emagged || A.stat & BROKEN)
			do_sparks(3, 1, A)
			to_chat(H, span_warning("The APC power currents surge erratically, damaging your chassis!"))
			H.adjustFireLoss(10)
		else if(A.cell && A.cell.charge > 0)
			if(H.nutrition >= NUTRITION_LEVEL_WELL_FED)
				to_chat(user, span_warning("You are already fully charged!"))
			else
				INVOKE_ASYNC(src, PROC_REF(powerdraw_loop), A, H)
		else
			to_chat(user, span_warning("There is no charge to draw from that APC."))
	else
		to_chat(user, span_warning("You lack a cell in which to store charge!"))

/obj/item/apc_powercord/proc/powerdraw_loop(obj/machinery/power/apc/A, mob/living/carbon/human/H)
	H.visible_message(span_notice("[H] inserts a power connector into \the [A]."), span_notice("You begin to draw power from \the [A]."))
	drawing_power = TRUE
	while(do_after(H, 1 SECONDS, A))
		if(loc != H)
			to_chat(H, span_warning("You must keep your connector out while charging!"))
			break
		if(A.cell.charge == 0)
			to_chat(H, span_warning("\The [A] has no more charge."))
			break
		A.charging = APC_IS_CHARGING
		if(A.cell.charge >= 500)
			H.adjust_nutrition(50)
			A.cell.charge -= 500
			to_chat(H, span_notice("You siphon off some of the stored charge for your own use."))
		else
			H.adjust_nutrition(A.cell.charge * 0.1)
			A.cell.charge = 0
			to_chat(H, span_notice("You siphon off the last of \the [A]'s charge."))
			break
		if(H.nutrition > NUTRITION_LEVEL_WELL_FED)
			to_chat(H, span_notice("You are now fully charged."))
			break
	H.visible_message(span_notice("[H] unplugs from \the [A]."), span_notice("You unplug from \the [A]."))
	drawing_power = FALSE

/obj/item/organ/internal/cyberimp/arm/telebaton
	name = "telebaton implant"
	desc = "Telescopic baton implant. Does what it says on the tin" // A better description

	contents = newlist(/obj/item/melee/baton)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/items.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "baton")

/obj/item/organ/internal/cyberimp/arm/advmop
	name = "advanced mop implant"
	desc = "Advanced mop implant. Does what it says on the tin" // A better description

	contents = newlist(/obj/item/mop/advanced)
	action_icon = list(/datum/action/item_action/organ_action/toggle = 'icons/obj/janitor.dmi')
	action_icon_state = list(/datum/action/item_action/organ_action/toggle = "advmop")
