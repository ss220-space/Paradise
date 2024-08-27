#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2
#define MIND_DEVICE_MESSAGE 1
#define MIND_DEVICE_CONTROL 2

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "magnets=7;biotech=4;powerstorage=4;abductor=4"
	armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 70, "acid" = 70)
	actions_types = list(/datum/action/item_action/hands_free/activate)
	allowed = list(/obj/item/abductor, /obj/item/melee/baton, /obj/item/gun/energy, /obj/item/restraints/handcuffs)
	var/mode = VEST_STEALTH
	var/stealth_active = 0
	var/combat_cooldown = 10
	var/datum/icon_snapshot/disguise
	var/stealth_armor = list("melee" = 15, "bullet" = 15, "laser" = 15, "energy" = 15, "bomb" = 15, "bio" = 15, "rad" = 15, "fire" = 70, "acid" = 70)
	var/combat_armor = list("melee" = 50, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 50, "bio" = 50, "rad" = 50, "fire" = 90, "acid" = 90)
	sprite_sheets = null

/obj/item/clothing/suit/armor/abductor/vest/Initialize(mapload)
	. = ..()
	stealth_armor = getArmor(arglist(stealth_armor))
	combat_armor = getArmor(arglist(combat_armor))


/obj/item/clothing/suit/armor/abductor/vest/proc/toggle_nodrop()
	var/prev_has = HAS_TRAIT_FROM(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(prev_has)
		REMOVE_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	if(ismob(loc))
		to_chat(loc, span_notice("Your vest is now [prev_has ? "unlocked" : "locked"]."))


/obj/item/clothing/suit/armor/abductor/vest/update_icon_state()
	switch(mode)
		if(VEST_STEALTH)
			icon_state = "vest_stealth"
		if(VEST_COMBAT)
			icon_state = "vest_combat"


/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
	update_icon(UPDATE_ICON_STATE)
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/armor/abductor/vest/item_action_slot_check(slot, mob/user, datum/action/action)
	if(slot == ITEM_SLOT_CLOTH_OUTER) //we only give the mob the ability to activate the vest if he's actually wearing it.
		return TRUE

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(datum/icon_snapshot/entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = 1
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja/cloak(get_turf(M), M.dir)
		M.name_override = disguise.name
		M.icon = disguise.icon
		M.icon_state = disguise.icon_state
		M.cut_overlays()
		M.add_overlay(disguise.overlays)
		M.update_inv_hands()

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = 0
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(M), M.dir)
		M.name_override = null
		M.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/IsReflect()
	DeactivateStealth()
	return 0

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click(mob/user, datum/action/action, leftclick)
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(combat_cooldown != initial(combat_cooldown))
			to_chat(loc, "<span class='warning'>Combat injection is still recharging.</span>")
			return
		var/mob/living/carbon/human/M = loc
		M.adjustStaminaLoss(-75)
		M.SetParalysis(0)
		M.SetStunned(0)
		M.SetWeakened(0)
		M.SetKnockdown(0)
		combat_cooldown = 0
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/vest/process()
	combat_cooldown++
	if(combat_cooldown==initial(combat_cooldown))
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/armor/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.vest == src)
			C.vest = null
			break
	return ..()

/obj/item/abductor
	icon = 'icons/obj/abductor.dmi'

/obj/item/proc/AbductorCheck(user)
	if(isabductor(user))
		return TRUE
	to_chat(user, "<span class='warning'>You can't figure how this works!</span>")
	return FALSE

/obj/item/abductor/proc/ScientistCheck(user)
	if(!AbductorCheck(user))
		return FALSE

	var/mob/living/carbon/human/H = user
	var/datum/species/abductor/S = H.dna.species
	if(S.scientist)
		return TRUE
	to_chat(user, "<span class='warning'>You're not trained to use this!</span>")
	return FALSE

/obj/item/abductor/gizmo
	name = "science tool"
	desc = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	icon_state = "gizmo_scan"
	item_state = "gizmo"
	origin_tech = "engineering=7;magnets=4;bluespace=4;abductor=3"
	var/mode = GIZMO_SCAN
	var/mob/living/marked = null
	var/obj/machinery/abductor/console/console


/obj/item/abductor/gizmo/update_icon_state()
	switch(mode)
		if(GIZMO_SCAN)
			icon_state = "gizmo_scan"
		if(GIZMO_MARK)
			icon_state = "gizmo_mark"


/obj/item/abductor/gizmo/attack_self(mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, "<span class='warning'>The device is not linked to a console!</span>")
		return

	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
	else
		mode = GIZMO_SCAN
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "<span class='notice'>You switch the device to [mode==GIZMO_SCAN? "SCAN": "MARK"] MODE</span>")


/obj/item/abductor/gizmo/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ScientistCheck(user))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	if(!console)
		to_chat(user, span_warning("The device is not linked to console!"))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK

	. = ATTACK_CHAIN_PROCEED_SUCCESS

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)


/obj/item/abductor/gizmo/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		return
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, "<span class='warning'>The device is not linked to console!</span>")
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		console.AddSnapshot(target)
		to_chat(user, "<span class='notice'>You scan [target] and add [target.p_them()] to the database.</span>")

/obj/item/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	if(marked == target)
		to_chat(user, "<span class='warning'>This specimen is already marked!</span>")
		return
	if(ishuman(target))
		if(isabductor(target))
			marked = target
			to_chat(user, "<span class='notice'>You mark [target] for future retrieval.</span>")
		else
			prepare(target,user)
	else
		prepare(target,user)

/obj/item/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user)>1)
		to_chat(user, "<span class='warning'>You need to be next to the specimen to prepare it for transport!</span>")
		return
	to_chat(user, "<span class='notice'>You begin preparing [target] for transport...</span>")
	if(do_after(user, 10 SECONDS, target))
		marked = target
		to_chat(user, "<span class='notice'>You finish preparing [target] for transport.</span>")

/obj/item/abductor/gizmo/Destroy()
	if(console)
		console.gizmo = null
	return ..()


/obj/item/abductor/silencer
	name = "abductor silencer"
	desc = "A compact device used to shut down communications equipment."
	icon_state = "silencer"
	item_state = "silencer"
	origin_tech = "materials=4;programming=7;abductor=3"


/obj/item/abductor/silencer/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!isgrey(user) && !AbductorCheck(user))
		return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	radio_off(target, user)


/obj/item/abductor/silencer/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)
		return
	if(!isgrey(user) && !AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/abductor/silencer/proc/radio_off(atom/target, mob/living/user)
	if(!(user in (viewers(7, target))))
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2,targloc))
		if(M == user)
			continue
		to_chat(user, "<span class='notice'>You silence [M]'s radio devices.</span>")
		radio_off_mob(M)

/obj/item/abductor/silencer/proc/radio_off_mob(mob/living/carbon/human/M)
	var/list/all_items = M.GetAllContents()

	for(var/obj/I in all_items)
		if(isradio(I))
			var/obj/item/radio/R = I
			R.listening = 0 // Prevents the radio from buzzing due to the EMP, preserving possible stealthiness.
			R.emp_act(1)

/obj/item/abductor/mind_device
	name = "mental interface device"
	desc = "A dual-mode tool for directly communicating with sentient brains. It can be used to send a direct message to a target, or to send a command to a test subject with a charged gland."
	icon_state = "mind_device_message"
	item_state = "silencer"
	var/mode = MIND_DEVICE_MESSAGE


/obj/item/abductor/mind_device/update_icon_state()
	switch(mode)
		if(MIND_DEVICE_MESSAGE)
			icon_state = "mind_device_message"
		if(MIND_DEVICE_CONTROL)
			icon_state = "mind_device_control"


/obj/item/abductor/mind_device/attack_self(mob/user)
	if(!ScientistCheck(user))
		return

	if(mode == MIND_DEVICE_MESSAGE)
		mode = MIND_DEVICE_CONTROL
	else
		mode = MIND_DEVICE_MESSAGE
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, "<span class='notice'>You switch the device to [mode == MIND_DEVICE_MESSAGE ? "TRANSMISSION" : "COMMAND"] MODE</span>")

/obj/item/abductor/mind_device/afterattack(atom/target, mob/living/user, flag, params)
	if(!ScientistCheck(user))
		return

	switch(mode)
		if(MIND_DEVICE_CONTROL)
			mind_control(target, user)
		if(MIND_DEVICE_MESSAGE)
			mind_message(target, user)

/obj/item/abductor/mind_device/proc/mind_control(atom/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/organ/internal/heart/gland/G = C.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(!istype(G))
			to_chat(user, "<span class='warning'>Your target does not have an experimental gland!</span>")
			return
		if(!G.mind_control_uses)
			to_chat(user, "<span class='warning'>Your target's gland is spent!</span>")
			return
		if(G.active_mind_control)
			to_chat(user, "<span class='warning'>Your target is already under a mind-controlling influence!</span>")
			return

		var/command = tgui_input_text(user, "Enter the command for your target to follow. Uses Left: [G.mind_control_uses], Duration: [DisplayTimeText(G.mind_control_duration)]", "Enter command")

		if(!command)
			return

		if(QDELETED(user) || user.get_active_hand() != src || loc != user)
			return

		if(QDELETED(G))
			return

		G.mind_control(command, user)
		to_chat(user, "<span class='notice'>You send the command to your target.</span>")

/obj/item/abductor/mind_device/proc/mind_message(atom/target, mob/living/user)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(user, "<span class='warning'>Your target is dead!</span>")
			return
		var/message = tgui_input_text(user, "Write a message to send to your target's brain.", "Enter message")
		if(!message)
			return
		if(QDELETED(L) || L.stat == DEAD)
			return

		to_chat(L, "<span class='italics'>You hear a voice in your head saying: </span><span class='abductor'>[message]</span>")
		to_chat(user, "<span class='notice'>You send the message to your target.</span>")
		add_say_logs(user, message, L, "Mind device")

/obj/item/gun/energy/alien
	name = "alien pistol"
	desc = "A complicated gun that fires bursts of high-intensity radiation."
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	restricted_species = list(/datum/species/abductor)
	icon_state = "alienpistol"
	item_state = "alienpistol"
	origin_tech = "combat=4;magnets=7;powerstorage=3;abductor=3"
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/paper/abductor
	name = "Dissection Guide"
	icon_state = "alienpaper_words"
	info = {"<b>Dissection for Dummies</b><br>
<br>
 1.Acquire fresh specimen.<br>
 2.Put the specimen on operating table.<br>
 3.Apply scalpel to the chest, preparing for experimental dissection.<br>
 4.Apply scalpel to specimen's torso.<br>
 5.Clamp bleeders on specimen's torso with a hemostat.<br>
 6.Retract skin of specimen's torso with a retractor.<br>
 7.Saw through the specimen's torso with a saw.<br>
 8.Apply retractor again to specimen's torso.<br>
 9.Search through the specimen's torso with your hands to remove any superfluous organs.<br>
 10.Insert replacement gland (Retrieve one from gland storage).<br>
 11.Apply bone gel to mend the ribcage.<br>
 12.Use the bone setter to finish mending the ribcage.<br>
 13.Apply bone gel to mend the ribcage once more.<br>
 14.Cauterize the patient's torso with a cautery.<br>
 15.Consider dressing the specimen back to not disturb the habitat.<br>
 16.Put the specimen in the experiment machinery.<br>
 17.Choose one of the machine options. The target will be analyzed and teleported to the selected drop-off point.<br>
 18.You will receive one supply credit, and the subject will be counted towards your quota.<br>
<br>
Congratulations! You are now trained for invasive xenobiology research!"}

/obj/item/paper/abductor/update_icon_state()
	return

/obj/item/paper/abductor/AltClick()
	return


#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/melee/baton/abductor
	name = "advanced baton"
	desc = "A quad-mode baton used for incapacitation and restraining of specimens."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wonderprodStun"
	item_state = "wonderprod"
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "materials=4;combat=4;biotech=7;abductor=4"
	force = 7
	affect_cyborgs = TRUE
	affect_bots = TRUE
	cooldown = 0 SECONDS
	stamina_damage = 0
	knockdown_time = 14 SECONDS
	allows_stun_in_harm = TRUE
	on_stun_sound = 'sound/weapons/egloves.ogg'
	actions_types = list(/datum/action/item_action/toggle_mode)
	var/mode = BATON_STUN


/obj/item/melee/baton/abductor/get_stun_description(mob/living/target, mob/living/user)
	return // chat messages are handled in their own procs.


/obj/item/melee/baton/abductor/get_cyborg_stun_description(mob/living/target, mob/living/user)
	return // same as above.


/obj/item/melee/baton/abductor/attack_self(mob/living/user)
	. = ..()
	toggle(user)


/obj/item/melee/baton/abductor/proc/toggle(mob/living/user = usr)
	if(!AbductorCheck(user))
		return
	mode = (mode + 1) % BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "stunning"
		if(BATON_SLEEP)
			txt = "sleep inducement"
		if(BATON_CUFF)
			txt = "restraining"
		if(BATON_PROBE)
			txt = "probing"

	var/is_stun_mode = (mode == BATON_STUN)
	var/is_stun_or_sleep = (mode == BATON_STUN) || (mode == BATON_SLEEP)

	affect_cyborgs = is_stun_mode
	affect_bots = is_stun_mode
	log_stun_attack = is_stun_mode // other modes have their own log entries.
	skip_harm_attack = !is_stun_or_sleep
	stun_animation = is_stun_or_sleep
	on_stun_sound = is_stun_or_sleep ? 'sound/weapons/egloves.ogg' : null

	to_chat(user, span_notice("You switch the baton to [txt] mode."))
	update_icon(UPDATE_ICON_STATE)


/obj/item/melee/baton/abductor/update_icon_state()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/melee/baton/abductor/examine(mob/user)
	. = ..()
	if(!AbductorCheck(user))
		return .
	switch(mode)
		if(BATON_STUN)
			. += span_warning("The baton is in stun mode.")
		if(BATON_SLEEP)
			. += span_warning("The baton is in sleep inducement mode.")
		if(BATON_CUFF)
			. += span_warning("The baton is in restraining mode.")
		if(BATON_PROBE)
			. += span_warning("The baton is in probing mode.")


/obj/item/melee/baton/abductor/baton_attack(mob/target, mob/living/user)
	if(!AbductorCheck(user))
		return BATON_ATTACK_DONE
	return ..()


/obj/item/melee/baton/abductor/baton_effect(mob/living/carbon/target, mob/living/user, stun_override)
	switch(mode)
		if(BATON_STUN)
			StunAttack(target, user)
		if(BATON_SLEEP)
			SleepAttack(target,user)
		if(BATON_CUFF)
			CuffAttack(target,user)
		if(BATON_PROBE)
			ProbeAttack(target,user)


/obj/item/melee/baton/abductor/proc/StunAttack(mob/living/carbon/target, mob/living/user)
	target.visible_message(
		span_danger("[user] stuns [target] with [src]!"),
		span_userdanger("[user] stuns you with [src]!"),
	)
	target.AdjustJitter(40 SECONDS, bound_upper = 40 SECONDS)
	target.AdjustStuttering(16 SECONDS, bound_upper = 16 SECONDS)
	target.AdjustConfused(10 SECONDS, bound_upper = 10 SECONDS)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	if(iscarbon(target))
		target.shock_internal_organs(33)
	target.Weaken(knockdown_time)


/obj/item/melee/baton/abductor/proc/SleepAttack(mob/living/target, mob/living/user)
	if(target.incapacitated(INC_IGNORE_RESTRAINED|INC_IGNORE_GRABBED))
		target.visible_message(
			span_danger("[user] induces sleep in [target] with [src]!"),
			span_userdanger("You suddenly feel very drowsy!"),
		)
		playsound(src, on_stun_sound, 50, TRUE, -1)
		target.Sleeping(2 MINUTES)
		add_attack_logs(user, target, "put to sleep with [src]")
	else
		target.AdjustDrowsy(2 SECONDS)
		to_chat(user, span_warning("Sleep inducement works fully only on stunned specimens! "))
		target.visible_message(
			span_danger("[user] tried to induce sleep in [target] with [src]!"),
			span_userdanger("You suddenly feel drowsy!"),
		)


/obj/item/melee/baton/abductor/proc/CuffAttack(mob/living/carbon/target, mob/living/user)
	if(!iscarbon(target))
		return
	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		to_chat(user, span_warning("[target] has no hands!"))
		return
	if(target.handcuffed)
		to_chat(user, span_warning("[target] is already handcuffed!"))
		return
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	target.visible_message(
		span_danger("[user] begins restraining [target] with [src]!"),
		span_userdanger("[user] begins shaping an energy field around your hands!"),
	)
	if(do_after(user, 3 SECONDS, target, NONE))
		if(target.handcuffed || !target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
			return
		target.apply_restraints(new /obj/item/restraints/handcuffs/cable/zipties/used(null), ITEM_SLOT_HANDCUFFED, TRUE)
		to_chat(user, span_notice("You restrain [target]."))
		add_attack_logs(user, target, "handcuffed ([src])")
	else
		to_chat(user, span_warning("You fail to restrain [target]!"))


/obj/item/melee/baton/abductor/proc/ProbeAttack(mob/living/carbon/human/target, mob/living/user)
	target.visible_message(
		span_danger("[user] probes [target] with [src]!"),
		span_userdanger("[user] probes you!"),
	)

	var/species = span_warning("Unknown species")
	var/helptext = span_warning("Species unsuitable for experiments.")

	if(ishuman(target))
		species = span_notice("<b>[target.dna.species.name]</b>")
		if(ischangeling(target))
			species = span_warning("Changeling lifeform")
		if(target.get_int_organ(/obj/item/organ/internal/heart/gland))
			helptext = span_warning("Experimental gland detected!")
		else
			if(target.get_organ_slot(INTERNAL_ORGAN_HEART))
				helptext = span_notice("Subject suitable for experiments.")
			else
				helptext = span_warning("Subject unsuitable for experiments.")

	to_chat(user, "[span_notice("Probing result:")] [species]")
	to_chat(user, "[helptext]")

#undef BATON_STUN
#undef BATON_SLEEP
#undef BATON_CUFF
#undef BATON_PROBE
#undef BATON_MODES


/obj/item/restraints/handcuffs/energy
	name = "hard-light energy field"
	desc = "A hard-light field restraining the hands."
	icon_state = "cuff_white" // Needs sprite
	breakouttime = 450
	trashtype = /obj/item/restraints/handcuffs/energy/used
	origin_tech = "materials=4;magnets=5;abductor=2"

/obj/item/restraints/handcuffs/energy/used
	desc = "energy discharge"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/energy/used/dropped(mob/user, slot, silent = FALSE)
	user.visible_message("<span class='danger'>[src] restraining [user] breaks in a discharge of energy!</span>", \
							"<span class='userdanger'>[src] restraining [user] breaks in a discharge of energy!</span>")
	do_sparks(4, 0, user.loc)
	. = ..()


/obj/item/radio/headset/abductor
	name = "alien headset"
	desc = "An advanced alien headset designed to monitor communications of human space stations. Why does it have a microphone? No one knows."
	item_flags = BANGPROTECT_MINOR
	origin_tech = "magnets=2;abductor=3"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "abductor_headset"
	item_state = "abductor_headset"
	ks2type = /obj/item/encryptionkey/heads/captain

/obj/item/radio/headset/abductor/New()
	..()
	make_syndie()

/obj/item/radio/headset/abductor/screwdriver_act()
	return// Stops humans from disassembling abductor headsets.

/obj/item/scalpel/alien
	name = "alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/hemostat/alien
	name = "alien hemostat"
	desc = "You've never seen this before."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/retractor/alien
	name = "alien retractor"
	desc = "You're not sure if you want the veil pulled back."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/circular_saw/alien
	name = "alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet?"
	icon = 'icons/obj/abductor.dmi'
	item_state = "alien_saw"
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/surgicaldrill/alien
	name = "alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/cautery/alien
	name = "alien cautery"
	desc = "Why would bloodless aliens have a tool to stop bleeding? Unless..."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonegel/alien
	name = "alien bone gel"
	desc = "It smells like duct tape."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/FixOVein/alien
	name = "alien FixOVein"
	desc = "Bloodless aliens would totally know how to stop internal bleeding...right?"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonesetter/alien
	name = "alien bone setter"
	desc = "You're not sure you want to know whether or not aliens have bones."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style. Prevents digital tracking."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	blockTracking = 1
	origin_tech = "materials=7;magnets=4;abductor=3"
	flags_inv = HIDEMASK|HIDEHEADSETS|HIDEGLASSES|HIDENAME|HIDEHAIR
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES

// Operating Table / Beds / Lockers

/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from earth. Could aliens be stealing our technology?"
	icon = 'icons/obj/abductor.dmi'
	buildstacktype = /obj/item/stack/sheet/mineral/abductor
	icon_state = "bed"

/obj/structure/table_frame/abductor
	name = "alien table frame"
	desc = "A sturdy table frame made from alien alloy."
	icon_state = "alien_frame"
	framestack = /obj/item/stack/sheet/mineral/abductor
	framestackamount = 1
	density = TRUE


/obj/structure/table_frame/abductor/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/alien_material = istype(I, /obj/item/stack/sheet/mineral/abductor)
	if(alien_material || istype(I, /obj/item/stack/sheet/mineral/silver))
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/mineral = I
		if(mineral.get_amount() < 1)
			to_chat(user, span_warning("You need one sheet of [mineral] to do this!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You start adding [mineral] to [src]..."))
		if(!do_after(user, 5 SECONDS * mineral.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(mineral) || !mineral.use(1))
			return ATTACK_CHAIN_PROCEED
		var/obj/new_table
		if(alien_material)
			new_table = new /obj/structure/table/abductor(loc)
		else
			new_table = new /obj/machinery/optable/abductor(loc)
		to_chat(user, span_notice("You have completed the construction of [new_table]."))
		transfer_fingerprints_to(new_table)
		new_table.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/smooth_structures/alien_table.dmi'
	icon_state = "alien_table"
	can_be_flipped = FALSE
	buildstack = /obj/item/stack/sheet/mineral/abductor
	framestack = /obj/item/stack/sheet/mineral/abductor
	buildstackamount = 1
	framestackamount = 1
	base_icon_state = "alien_table"
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_TABLES
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_TABLES
	frame = /obj/structure/table_frame/abductor


/obj/machinery/optable/abductor
	name = "alien operating table"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "bed"
	no_icon_updates = 1 //no icon updates for this; it's static.
	injected_reagents = list("corazone","spaceacillin")
	reagent_target_amount = 31 //the patient needs at least 30u of spaceacillin to prevent necrotization.
	inject_amount = 10

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	material_drop = /obj/item/stack/sheet/mineral/abductor
	material_drop_amount = 1

/obj/structure/door_assembly/door_assembly_abductor
	name = "alien airlock assembly"
	icon = 'icons/obj/doors/airlocks/abductor/abductor_airlock.dmi'
	base_name = "alien airlock"
	overlays_file = 'icons/obj/doors/airlocks/abductor/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/abductor
	material_type = /obj/item/stack/sheet/mineral/abductor
	noglass = TRUE

/obj/item/reagent_containers/applicator/abductor
	name = "alien mender"
	desc = "Hidden behind a high-tech look is a time-tested mechanism"
	origin_tech = "materials=2;biotech=3;abductor=2"
	icon_state = "alien_mender_empty"
	item_state = "alien_mender"
	icon = 'icons/obj/abductor.dmi'
	emagged = TRUE
	ignore_flags = TRUE
	var/base_icon = "alien_mender_brute"

/obj/item/reagent_containers/applicator/abductor/update_icon_state()
	var/reag_pct = round((reagents.total_volume / volume) * 100)
	switch(reag_pct)
		if(51 to 100)
			icon_state = "[base_icon]_full[applying ? "_active" : ""]"
		if(1 to 50)
			icon_state = "[base_icon][applying ? "_active" : ""]"
		if(0)
			icon_state = "alien_mender_empty"

/obj/item/reagent_containers/applicator/abductor/brute
	name = "alien brute mender"
	base_icon = "alien_mender_brute"
	list_reagents = list("styptic_powder" = 200)

/obj/item/reagent_containers/applicator/abductor/burn
	name = "alien burn mender"
	base_icon = "alien_mender_burn"
	list_reagents = list("silver_sulfadiazine" = 200)

/obj/item/reagent_containers/glass/bottle/abductor
	name = "alien bottle"
	desc = "A durable bottle, made from alien alloy"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=4"
	icon_state = "alien_bottle"
	item_state = "alien_bottle"
	volume = 50

/obj/item/reagent_containers/glass/bottle/abductor/rezadone
	name = "rezadone bottle"
	list_reagents = list("rezadone" = 50)

/obj/item/reagent_containers/glass/bottle/abductor/epinephrine
	name = "epinephrine bottle"
	list_reagents = list("epinephrine" = 50)

/obj/item/reagent_containers/glass/bottle/abductor/salgu
	name = "saline-glucose solution bottle"
	list_reagents = list("salglu_solution" = 50)

/obj/item/reagent_containers/glass/bottle/abductor/oculine
	name = "oculine bottle"
	list_reagents = list("oculine" = 50)

/obj/item/reagent_containers/glass/bottle/abductor/pen_acid
	name = "pentetic acid bottle"
	list_reagents = list("pen_acid" = 50)

/obj/item/healthanalyzer/abductor
	name = "alien health analyzer"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=4;biotech=4;abductor=2"
	advanced = TRUE
	icon_state = "alien_hscanner"
	item_state = "alien_hscanner"
	desc = "Why its interface looks so familiar?"

/obj/item/storage/firstaid_abductor
	name = "alien medkit"
	desc = "Kit that contains some advanced alien medicine. Keep it away from alien-kids"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien_medkit"
	item_state = "alien_medkit"
	throw_speed = 2
	throw_range = 8

/obj/item/storage/firstaid_abductor/populate_contents()
	new /obj/item/reagent_containers/applicator/abductor/brute(src)
	new /obj/item/reagent_containers/applicator/abductor/burn(src)
	new /obj/item/reagent_containers/glass/bottle/abductor/rezadone(src)
	new /obj/item/reagent_containers/glass/bottle/abductor/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/abductor/salgu(src)
	new /obj/item/reagent_containers/glass/bottle/abductor/oculine(src)
	new /obj/item/reagent_containers/glass/bottle/abductor/pen_acid(src)

/obj/item/clothing/gloves/abductor_agent
	desc = "These gloves seems to protect the wearer from electric shock."
	name = "high-tech insulated gloves"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gloves_agent"
	item_state = "abductor_gloves_agent"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = NONE

/obj/item/clothing/gloves/abductor_science
	name = "high-tech science gloves"
	desc = "High-tech sterile gloves that are stronger than latex."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gloves_science"
	item_state = "abductor_gloves_science"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	resistance_flags = NONE
