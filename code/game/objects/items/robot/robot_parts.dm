/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	var/list/part = null
	var/sabotaged = 0 //Emagging limbs can have repercussions when installed as prosthetics.
	var/model_info = "Unbranded"
	dir = SOUTH

/obj/item/robot_parts/New(newloc, model)
	..(newloc)
	if(model_info && model)
		model_info = model
		var/datum/robolimb/R = GLOB.all_robolimbs[model]
		if(R)
			name = "[R.company] [initial(name)]"
			desc = "[R.desc]"
			if(icon_exists(R.icon, icon_state))
				icon = R.icon
	else
		name = "robot [initial(name)]"

	AddComponent(/datum/component/surgery_initiator/limb, forced_surgery = /datum/surgery/attach_robotic_limb)

/obj/item/robot_parts/attack_self(mob/user)
	var/choice = tgui_input_list(user, "Select the company appearance for this limb", "Limb Company Selection", GLOB.selectable_robolimbs)
	if(!choice)
		return
	if(loc != user)
		return
	model_info = choice
	to_chat(usr, "<span class='notice'>You change the company limb model to [choice].</span>")

/obj/item/robot_parts/l_arm
	name = "left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_arm"
	part = list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)

/obj/item/robot_parts/r_arm
	name = "right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_arm"
	part = list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)

/obj/item/robot_parts/l_leg
	name = "left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "l_leg"
	part = list(BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT)

/obj/item/robot_parts/r_leg
	name = "right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	icon_state = "r_leg"
	part = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)

/obj/item/robot_parts/chest
	name = "torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	icon_state = "chest"
	part = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_CHEST)
	var/wired = FALSE
	var/obj/item/stock_parts/cell/cell = null

/obj/item/robot_parts/chest/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/robot_parts/head
	name = "head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	icon_state = "head"
	part = list(BODY_ZONE_HEAD)
	var/obj/item/flash/flash1 = null
	var/obj/item/flash/flash2 = null

/obj/item/robot_parts/head/Destroy()
	QDEL_NULL(flash1)
	QDEL_NULL(flash2)
	return ..()

/obj/item/robot_parts/robot_suit
	name = "endoskeleton"
	desc = "A complex metal backbone with standard limb sockets and pseudomuscle anchors."
	icon_state = "robo_suit"
	model_info = null
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null

	var/created_name = ""
	var/mob/living/silicon/ai/forced_ai
	var/locomotion = 1
	var/lawsync = 1
	var/aisync = 1
	var/panel_locked = 1

/obj/item/robot_parts/robot_suit/New()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/robot_parts/robot_suit/Destroy()
	QDEL_NULL(l_arm)
	QDEL_NULL(r_arm)
	QDEL_NULL(l_leg)
	QDEL_NULL(r_leg)
	QDEL_NULL(chest)
	QDEL_NULL(head)
	forced_ai = null
	return ..()

/obj/item/robot_parts/robot_suit/attack_self(mob/user)
	return

/obj/item/robot_parts/robot_suit/update_overlays()
	. = ..()
	if(l_arm)
		. += "l_arm+o"
	if(r_arm)
		. += "r_arm+o"
	if(chest)
		. += "chest+o"
	if(l_leg)
		. += "l_leg+o"
	if(r_leg)
		. += "r_leg+o"
	if(head)
		. += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(l_arm && r_arm)
		if(l_leg && r_leg)
			if(chest && head)
				SSblackbox.record_feedback("amount", "cyborg_frames_built", 1)
				return 1
	return 0


/obj/item/robot_parts/robot_suit/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!check_completion())
		to_chat(user, span_warning("The endoskeleton must be assembled before debugging can begin!"))
		return .
	Interact(user)


/obj/item/robot_parts/robot_suit/attackby(obj/item/I, mob/living/user, params)
	if(is_pen(I))
		to_chat(user, span_warning("You need to use a multitool to rename [src]!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal) && !l_arm && !r_arm && !l_leg && !r_leg && !chest && !head)
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!metal.use(1))
			to_chat(user, span_warning("You need one sheet of metal to continue construction."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/ed209_assembly/ed209_assembly = new(drop_location())
		qdel(src)
		to_chat(user, span_notice("You armed the robot frame"))
		user.put_in_hands(ed209_assembly, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/l_leg))
		add_fingerprint(user)
		if(l_leg)
			to_chat(user, span_warning("The [l_leg.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		l_leg = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/r_leg))
		add_fingerprint(user)
		if(r_leg)
			to_chat(user, span_warning("The [r_leg.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		r_leg = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/l_arm))
		add_fingerprint(user)
		if(l_arm)
			to_chat(user, span_warning("The [l_arm.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		l_arm = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/r_arm))
		add_fingerprint(user)
		if(r_arm)
			to_chat(user, span_warning("The [r_arm.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		r_arm = I
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/chest))
		add_fingerprint(user)
		if(chest)
			to_chat(user, span_warning("The [chest.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/robot_parts/chest/new_chest = I
		if(!new_chest.wired)
			to_chat(user, span_warning("You need to attach wires to the [new_chest.name] first."))
			return ATTACK_CHAIN_PROCEED
		if(!new_chest.cell)
			to_chat(user, span_warning("You need to attach a cell to the [new_chest.name] first."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_chest, src))
			return ..()
		chest = new_chest
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/robot_parts/head))
		add_fingerprint(user)
		if(head)
			to_chat(user, span_warning("The [head.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/robot_parts/head/new_head = I
		if(!new_head.flash1 || !new_head.flash2)
			to_chat(user, span_warning("You need to attach two flashes to the [new_head.name] first."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_head, src))
			return ..()
		head = new_head
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!istype(I, /obj/item/mmi))
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_fingerprint(user)
	var/obj/item/mmi/new_mmi = I
	if(!check_completion())
		to_chat(user, span_warning("The MMI must go in after everything else!"))
		return .

	if(new_mmi.clock && !isclocker(user))
		to_chat(user, span_danger("An overwhelming feeling of dread comes over you as you attempt to put the soul vessel into the frame."))
		user.Confused(20 SECONDS)
		user.Jitter(12 SECONDS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!isturf(loc))
		to_chat(user, span_warning("You can't put [new_mmi] in, the frame has to be standing on the ground to be perfectly precise."))
		return .

	if(!new_mmi.brainmob)
		to_chat(user, span_warning("Sticking an empty [new_mmi.name] into the frame would sort of defeat the purpose."))
		return .

	if(!new_mmi.brainmob.key)
		var/ghost_can_reenter = FALSE
		if(new_mmi.brainmob.mind)
			for(var/mob/dead/observer/observer in GLOB.player_list)
				if(observer.can_reenter_corpse && observer.mind == new_mmi.brainmob.mind)
					ghost_can_reenter = TRUE
					if(new_mmi.next_possible_ghost_ping < world.time)
						observer.notify_cloning("Somebody is trying to borg you! Re-enter your corpse if you want to be borged!", 'sound/voice/liveagain.ogg', src)
						new_mmi.next_possible_ghost_ping = world.time + 30 SECONDS // Avoid spam
					break
		if(ghost_can_reenter)
			to_chat(user, span_warning("The [new_mmi.name] is currently inactive. Try again later."))
		else
			to_chat(user, span_warning("The [new_mmi.name] is completely unresponsive; there's no point to use it."))
		return .

	if(jobban_isbanned(new_mmi.brainmob, JOB_TITLE_CYBORG) || jobban_isbanned(new_mmi.brainmob, "nonhumandept"))
		to_chat(user, span_warning("This [new_mmi.name] is not fit to serve as a cyborg!"))
		return .

	if(new_mmi.brainmob.stat == DEAD)
		to_chat(user, span_warning("Sticking a dead [new_mmi.name] into the frame would sort of defeat the purpose."))
		return .

	if(new_mmi.brainmob.mind in SSticker.mode.head_revolutionaries)
		to_chat(user, span_warning("The frame's firmware lets out a shrill sound, and flashes 'Abnormal Memory Engram'. It refuses to accept [new_mmi]."))
		return .

	var/datum/ai_laws/laws_to_give
	if(!aisync)
		lawsync = FALSE

	if(sabotaged)
		aisync = FALSE
		lawsync = FALSE

	if(new_mmi.syndiemmi)
		aisync = FALSE
		lawsync = FALSE
		laws_to_give = new /datum/ai_laws/syndicate_override

	if(new_mmi.syndicate)	// ffs
		aisync = FALSE
		lawsync = FALSE
		laws_to_give = new /datum/ai_laws/syndicate_override

	if(new_mmi.ninja)
		aisync = FALSE
		lawsync = FALSE
		laws_to_give = new /datum/ai_laws/ninja_override

	if(new_mmi.clock)
		aisync = FALSE
		lawsync = FALSE
		laws_to_give = new /datum/ai_laws/ratvar

	var/mob/living/silicon/robot/new_borg = new(loc, syndie = sabotaged, unfinished = TRUE, ai_to_sync_to = forced_ai, connect_to_AI = aisync)
	if(QDELETED(new_borg))	// somehow??? jesus fucking christ
		return .

	if(!user.drop_transfer_item_to_loc(new_mmi, src))
		return ..()

	. = ATTACK_CHAIN_BLOCKED_ALL

	var/datum/job_objective/make_cyborg/task = user.mind.findJobTask(/datum/job_objective/make_cyborg)
	if(istype(task))
		task.unit_completed()

	new_borg.invisibility = 0
	new_mmi.forceMove(new_borg) //Should fix cybros run time erroring when blown up. It got deleted before, along with the frame.
	//Transfer debug settings to new mob
	new_borg.custom_name = created_name
	new_borg.rename_character(new_borg.real_name, new_borg.get_default_name())
	new_borg.locked = panel_locked

	if(laws_to_give)
		new_borg.laws = laws_to_give
	else if(!lawsync)
		new_borg.lawupdate = FALSE
		new_borg.make_laws()

	new_mmi.brainmob.mind.transfer_to(new_borg)

	SSticker?.score?.save_silicon_laws(new_borg, user, "robot construction", log_all_laws = TRUE)

	if(new_borg.mind?.special_role)
		new_borg.mind.store_memory("As a cyborg, you must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead.")
		to_chat(new_borg, span_userdanger("You have been robotized!"))
		to_chat(new_borg, span_danger("You must obey your silicon laws and master AI above all else. Your objectives will consider you to be dead."))

	new_borg.job = JOB_TITLE_CYBORG

	chest.cell.forceMove(new_borg)
	new_borg.cell = chest.cell
	chest.cell = null
	// Since we "magically" installed a cell, we also have to update the correct component.
	var/datum/robot_component/cell_component = new_borg.components["power cell"]
	cell_component.wrapped = new_borg.cell
	cell_component.installed = TRUE
	new_borg.mmi = new_mmi
	new_borg.Namepick()

	SSblackbox.record_feedback("amount", "cyborg_birth", 1)

	forceMove(new_borg)
	new_borg.robot_suit = src

	if(new_borg.mmi.clock) // so robots created from vessel have magic
		new_borg.UnlinkSelf()
		SSticker.mode.add_clock_actions(new_borg.mind)

	if(!locomotion)
		new_borg.set_lockcharge(TRUE)
		to_chat(new_borg, span_warning("Error: Servo motors unresponsive."))


/obj/item/robot_parts/robot_suit/proc/Interact(mob/user)
			var/t1 = "Designation: <a href='byond://?src=[UID()];Name=1'>[(created_name ? "[created_name]" : "Default Cyborg")]</a><br>\n"
			t1 += "Master AI: <a href='byond://?src=[UID()];Master=1'>[(forced_ai ? "[forced_ai.name]" : "Automatic")]</a><br><br>\n"

			t1 += "LawSync Port: <a href='byond://?src=[UID()];Law=1'>[(lawsync ? "Open" : "Closed")]</a><br>\n"
			t1 += "AI Connection Port: <a href='byond://?src=[UID()];AI=1'>[(aisync ? "Open" : "Closed")]</a><br>\n"
			t1 += "Servo Motor Functions: <a href='byond://?src=[UID()];Loco=1'>[(locomotion ? "Unlocked" : "Locked")]</a><br>\n"
			t1 += "Panel Lock: <a href='byond://?src=[UID()];Panel=1'>[(panel_locked ? "Engaged" : "Disengaged")]</a><br>\n"
			var/datum/browser/popup = new(user, "robotdebug", "Cyborg Boot Debug", 310, 220)
			popup.set_content(t1)
			popup.open()

/obj/item/robot_parts/robot_suit/Topic(href, href_list)
	var/mob/living/living_user = usr
	if(living_user.incapacitated() || !Adjacent(living_user))
		return
	var/obj/item/item_in_hand = living_user.get_active_hand()
	if(item_in_hand.tool_behaviour != TOOL_MULTITOOL)
		to_chat(living_user, "<span class='warning'>You need a multitool!</span>")
		return

	if(href_list["Name"])
		var/new_name = reject_bad_name(input(usr, "Enter new designation. Set to blank to reset to default.", "Cyborg Debug", created_name),1)
		if(!in_range(src, usr) && loc != usr)
			return
		if(new_name)
			created_name = new_name
		else
			created_name = ""

	else if(href_list["Master"])
		if(!sabotaged)
			forced_ai = select_active_ai(usr)
		if(!forced_ai)
			to_chat(usr, "<span class='error'>No active AIs detected.</span>")

	else if(href_list["Law"])
		lawsync = !lawsync
	else if(href_list["AI"])
		aisync = !aisync
	else if(href_list["Loco"])
		locomotion = !locomotion
	else if(href_list["Panel"])
		panel_locked = !panel_locked

	add_fingerprint(usr)
	Interact(usr)
	return


/obj/item/robot_parts/chest/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("The [cell.name] is already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cell = I
		to_chat(user, span_notice("You insert the cell."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/cable_coil))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(wired)
			to_chat(user, span_warning("You have already wired [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!coil.use(1))
			to_chat(user, span_warning("You need more cable for this."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You wired [src]."))
		wired = TRUE
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/robot_parts/head/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/flash))
		add_fingerprint(user)
		if(isrobot(user))
			to_chat(user, span_warning("How do you propose to do that?"))
			return ATTACK_CHAIN_PROCEED
		if(flash1 && flash2)
			to_chat(user, span_warning("Both flashes are already installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		if(flash1)
			flash2 = I
		else
			flash1 = I
		to_chat(user, span_notice("You insert the flash into the eye socket."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stock_parts/manipulator))
		add_fingerprint(user)
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		new /mob/living/simple_animal/spiderbot(drop_location())
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/robot_parts/emag_act(mob/user)
	if(sabotaged)
		if(user)
			to_chat(user, "<span class='warning'>[src] is already sabotaged!</span>")
	else
		add_attack_logs(user, src, "emagged")
		if(user)
			to_chat(user, "<span class='warning'>You slide the emag into the dataport on [src] and short out the safeties.</span>")
		sabotaged = 1
