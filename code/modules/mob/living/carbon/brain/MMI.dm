/obj/item/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = WEIGHT_CLASS_NORMAL
	origin_tech = "biotech=3"
	origin_tech = "biotech=2;programming=3;engineering=2"
	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.
	var/alien = FALSE
	var/clock = 0
	var/syndiemmi = 0 //Whether or not this is a Syndicate MMI
	var/syndicate = 0 //Used to replace standart modules with the syndicate modules in module pick proc
	var/ninja = FALSE //Like the syndicate, it is necessary to select modules.
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/obj/item/organ/internal/brain/held_brain = null // This is so MMI's aren't brainscrubber 9000's
	var/mob/living/silicon/robot/robot = null//Appears unused.
	var/obj/mecha/mecha = null//This does not appear to be used outside of reference in mecha.dm.
// I'm using this for mechs giving MMIs HUDs now

	var/obj/item/radio/radio = null // For use with the radio MMI upgrade
	var/datum/action/generic/configure_mmi_radio/radio_action = null

	// Used for cases when mmi or one of it's children commits suicide.
	// Needed to fix a rather insane bug when a posibrain/robotic brain commits suicide
	var/dead_icon = "mmi_dead"

	/// Time at which the ghost belonging to the mind in the mmi can be pinged again to be borged
	var/next_possible_ghost_ping


/obj/item/mmi/update_icon_state()
	if(held_brain)
		icon = held_brain.mmi_icon
		icon_state = held_brain.mmi_icon_state
	else
		icon = initial(icon)
		icon_state = initial(icon_state)


/obj/item/mmi/update_name(updates = ALL)
	. = ..()
	if(brainmob)
		if(alien)
			name = "Man-Machine Interface: Alien - [brainmob.real_name]"
		else
			name = "Man-Machine Interface: [brainmob.real_name]"
	else
		name = initial(name)


/obj/item/mmi/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/organ/internal/brain)) //Time to stick a brain in it --NEO
		add_fingerprint(user)
		var/obj/item/organ/internal/brain/brain = I
		if(brainmob)
			to_chat(user, span_warning("The [name] is already occupied."))
			return ATTACK_CHAIN_PROCEED

		if(istype(brain, /obj/item/organ/internal/brain/crystal))
			to_chat(user, span_warning("This brain is too malformed to be able to use with the [src]."))
			return ATTACK_CHAIN_PROCEED

		if(istype(brain, /obj/item/organ/internal/brain/golem))
			to_chat(user, span_warning("You cannot find a way to plug [brain] into [src]."))
			return ATTACK_CHAIN_PROCEED

		if(!brain.brainmob)
			to_chat(user, span_warning("You aren't sure where this brain came from, but you're pretty sure it's useless."))
			return ATTACK_CHAIN_PROCEED

		if(held_brain)
			to_chat(user, span_userdanger("Somehow, this MMI still has a brain in it. Report this to the bug tracker."))
			log_runtime(EXCEPTION("[user] tried to stick a [brain.name] into [src] in [get_area(src)], but the held brain variable wasn't cleared"), src)
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(brain, src))
			return ATTACK_CHAIN_PROCEED

		user.visible_message(
			span_notice("[user] has sticked [brain] into [src]."),
			span_notice("You have sticked [brain] into [src]."),
		)
		brainmob = brain.brainmob
		brain.brainmob = null
		brainmob.container = src
		brainmob.forceMove(src)
		brainmob.set_stat(CONSCIOUS)
		brainmob.set_invis_see(initial(brainmob.see_invisible))
		held_brain = brain
		alien = istype(brain, /obj/item/organ/internal/brain/xeno)
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
		if(radio_action)
			radio_action.UpdateButtonIcon()
		SSblackbox.record_feedback("amount", "mmis_filled", 1)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mmi_radio_upgrade))
		add_fingerprint(user)
		if(radio)
			to_chat(user, span_warning("The [name] already has a radio installed."))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts to install [I] into [src]."),
			span_notice("You start to install [I] into [src]..."),
		)
		if(!do_after(user, 2 SECONDS, src) || radio)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has installed [I] into [src]."),
			span_notice("You have installed [I] into [src]."),
		)
		if(brainmob)
			to_chat(brainmob, span_notice("MMI radio capability installed."))
		install_radio()
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	// Maybe later add encryption key support, but that's a pain in the neck atm
	if(brainmob)
		I.attack(brainmob, user, params)//Oh noooeeeee
		// Brainmobs can take damage, but they can't actually die. Maybe should fix.
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/mmi/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(!radio)
		to_chat(user, "<span class='warning'>There is no radio in [src]!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins to uninstall the radio from [src]...</span>", \
							 "<span class='notice'>You start to uninstall the radio from [src]...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || !radio)
		return
	uninstall_radio()
	new /obj/item/mmi_radio_upgrade(get_turf(src))
	user.visible_message("<span class='warning'>[user] uninstalls the radio from [src].</span>", \
						 "<span class='notice'>You uninstall the radio from [src].</span>")


/obj/item/mmi/attack_self(mob/user)
	if(!brainmob)
		to_chat(user, "<span class='warning'>You upend the MMI, but there's nothing in it.</span>")
	else
		to_chat(user, "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>")
		dropbrain(get_turf(user))


/obj/item/mmi/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.container = src

	if(!istype(H.dna.species) || isnull(H.dna.species.return_organ(INTERNAL_ORGAN_BRAIN))) // Diona/buggy people
		held_brain = new(src)
	else // We have a species, and it has a brain
		var/brain_path = H.dna.species.return_organ(INTERNAL_ORGAN_BRAIN)
		if(!ispath(brain_path, /obj/item/organ/internal/brain))
			brain_path = /obj/item/organ/internal/brain
		held_brain = new brain_path(src) // Slime people will keep their slimy brains this way
	held_brain.dna = brainmob.dna.Clone()
	held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"
	brainmob.update_sight()
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)


//I made this proc as a way to have a brainmob be transferred to any created brain, and to solve the
//problem i was having with alien/nonalien brain drops.
/obj/item/mmi/proc/dropbrain(var/turf/dropspot)
	if(isnull(held_brain))
		log_runtime(EXCEPTION("[src] at [loc] attempted to drop brain without a contained brain in [get_area(src)]."), src)
		to_chat(brainmob, "<span class='userdanger'>Your MMI did not contain a brain! We'll make a new one for you, but you'd best report this to the bugtracker!</span>")
		held_brain = new(dropspot) // Let's not ruin someone's round because of something dumb -- Crazylemon
		held_brain.dna = brainmob.dna.Clone()
		held_brain.name = "\the [brainmob.name]'s [initial(held_brain.name)]"

	brainmob.container = null//Reset brainmob mmi var.
	brainmob.forceMove(held_brain) //Throw mob into brain.
	GLOB.respawnable_list += brainmob
	GLOB.alive_mob_list -= brainmob//Get outta here
	held_brain.brainmob = brainmob//Set the brain to use the brainmob
	held_brain.brainmob.cancel_camera()
	brainmob = null//Set mmi brainmob var to null
	held_brain.forceMove(dropspot)
	held_brain = null
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)


/obj/item/mmi/examine(mob/user)
	. = ..()
	if(radio)
		. += "<span class='notice'>A radio is installed on [src].</span>"

/obj/item/mmi/proc/install_radio()
	radio = new(src)
	radio.broadcasting = TRUE
	radio_action = new(radio, src)
	if(brainmob && brainmob.loc == src)
		radio_action.Grant(brainmob)

/obj/item/mmi/proc/uninstall_radio()
	QDEL_NULL(radio)
	QDEL_NULL(radio_action)


/obj/item/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()

/obj/item/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	QDEL_NULL(brainmob)
	QDEL_NULL(held_brain)
	QDEL_NULL(radio)
	QDEL_NULL(radio_action)
	return ..()

// These two procs are important for when an MMI pilots a mech
// (Brainmob "enters/leaves" the MMI when piloting)
// Also neatly handles basically every case where a brain
// is inserted or removed from an MMI
/obj/item/mmi/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(radio && isbrain(arrived))
		radio_action.Grant(arrived)

/obj/item/mmi/Exited(atom/movable/departed, atom/newLoc)
	. = ..()
	if(radio && isbrain(departed))
		radio_action.Remove(departed)

/obj/item/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs created with it, but doesn't fit in Nanotrasen AI cores."
	origin_tech = "biotech=4;programming=4;syndicate=2"
	syndiemmi = 1


/obj/item/mmi/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	if(!brainmob)
		return FALSE
	if(!parent)
		log_debug("Attempting to insert into a null parent!")
		return FALSE
	if(target.get_organ_slot(INTERNAL_ORGAN_BRAIN))	// one brain at a time
		return FALSE
	var/obj/item/organ/internal/brain/mmi_holder/holder = new
	holder.parent_organ_zone = parent.limb_zone
	forceMove(holder)
	holder.stored_mmi = src
	holder.update_from_mmi()
	if(brainmob && brainmob.mind)
		brainmob.mind.transfer_to(target)
	holder.insert(target)
	return TRUE


// As a synthetic, the only limit on visibility is view range
/obj/item/mmi/contents_ui_distance(src_object, mob/living/user)
	. = ..()
	if((src_object in view(user.client)) && get_dist(src_object, src) <= user.client.maxview())
		return UI_INTERACTIVE	// interactive (green visibility)
	return user.shared_living_ui_distance()
