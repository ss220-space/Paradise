#define EMPOWERED_THRALL_LIMIT 5


/obj/effect/proc_holder/spell/proc/shadowling_check(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(isshadowling(user) && is_shadow(user))
		return TRUE

	if(isshadowlinglesser(user) && is_thrall(user))
		return TRUE

	if(!is_shadow_or_thrall(user))
		to_chat(user, "<span class='warning'>You can't wrap your head around how to do this.</span>")

	else if(is_thrall(user))
		to_chat(user, "<span class='warning'>You aren't powerful enough to do this.</span>")

	else if(is_shadow(user))
		to_chat(user, "<span class='warning'>Your telepathic ability is suppressed. Hatch or use Rapid Re-Hatch first.</span>")

	return FALSE


/**
 * Stuns and mutes a human target, depending on the distance relative to the shadowling.
 */
/obj/effect/proc_holder/spell/shadowling_glare
	name = "Glare"
	desc = "Stuns and mutes a target for a decent duration. Duration depends on the proximity to the target."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	need_active_overlay = TRUE

	action_icon_state = "glare"

	selection_activated_message		= "<span class='notice'>Your prepare to your eyes for a stunning glare! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message 	= "<span class='notice'>Your eyes relax... for now.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/shadowling_glare/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.random_target = TRUE
	T.target_priority = SPELL_TARGET_CLOSEST
	T.max_targets = 1
	T.range = 10
	return T


/obj/effect/proc_holder/spell/shadowling_glare/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_glare/valid_target(mob/living/carbon/human/target, user)
	return !target.stat && !is_shadow_or_thrall(target)


/obj/effect/proc_holder/spell/shadowling_glare/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	user.visible_message("<span class='warning'><b>[user]'s eyes flash a blinding red!</b></span>")
	var/distance = get_dist(target, user)
	if(distance <= 2)
		target.visible_message("<span class='danger'>[target] freezes in place, [target.p_their()] eyes glazing over...</span>", \
			"<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you are mesmerized by [user.p_their()] heavenly beauty...</span>")

		target.Weaken(4 SECONDS)
		target.AdjustSilence(20 SECONDS)
		target.apply_damage(20, STAMINA)
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

	else //Distant glare
		target.Stun(2 SECONDS)
		target.Slowed(10 SECONDS)
		target.AdjustSilence(10 SECONDS)
		to_chat(target, "<span class='userdanger'>A red light flashes across your vision, and your mind tries to resist them.. you are exhausted.. you are not able to speak..</span>")
		target.visible_message("<span class='danger'>[target] freezes in place, [target.p_their()] eyes glazing over...</span>")


/obj/effect/proc_holder/spell/aoe/shadowling_veil
	name = "Veil"
	desc = "Extinguishes most nearby light sources."
	base_cooldown = 15 SECONDS //Short cooldown because people can just turn the lights back on
	clothes_req = FALSE
	var/blacklisted_lights = list(/obj/item/flashlight/flare, /obj/item/flashlight/slime)
	action_icon_state = "veil"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/shadowling_veil/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_veil/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_veil/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'>You silently disable all nearby lights.</span>")
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()


/obj/effect/proc_holder/spell/shadowling_shadow_walk
	name = "Shadow Walk"
	desc = "Phases you into the space between worlds for a short time, allowing movement through walls and invisbility."
	base_cooldown = 30 SECONDS //Used to be twice this, buffed
	clothes_req = FALSE
	phase_allowed = TRUE
	action_icon_state = "shadow_walk"


/obj/effect/proc_holder/spell/shadowling_shadow_walk/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_shadow_walk/cast(list/targets, mob/living/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	playsound(user.loc, 'sound/effects/bamf.ogg', 50, 1)
	user.visible_message("<span class='warning'>[user] vanishes in a puff of black mist!</span>", "<span class='shadowling'>You enter the space between worlds as a passageway.</span>")
	user.SetStunned(0)
	user.SetWeakened(0)
	user.SetKnockdown(0)
	user.incorporeal_move = INCORPOREAL_NORMAL
	user.alpha_set(0, ALPHA_SOURCE_SHADOWLING)
	user.ExtinguishMob()
	user.forceMove(get_turf(user)) //to properly move the mob out of a potential container
	user.pulledby?.stop_pulling()
	user.stop_pulling()

	sleep(4 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message("<span class='warning'>[user] suddenly manifests!</span>", "<span class='shadowling'>The pressure becomes too much and you vacate the interdimensional darkness.</span>")
	user.incorporeal_move = INCORPOREAL_NONE
	user.alpha_set(1, ALPHA_SOURCE_SHADOWLING)
	user.forceMove(get_turf(user))


/obj/effect/proc_holder/spell/shadowling_guise
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	base_cooldown = 120 SECONDS
	clothes_req = FALSE
	action_icon_state = "shadow_walk"
	var/conseal_time = 4 SECONDS


/obj/effect/proc_holder/spell/shadowling_guise/Destroy()
	if(action?.owner)
		reveal(action.owner)
	return ..()


/obj/effect/proc_holder/spell/shadowling_guise/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_guise/cast(list/targets, mob/living/user = usr)
	user.visible_message("<span class='warning'>[user] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
	user.alpha_set(10 / LIGHTING_PLANE_ALPHA_VISIBLE, ALPHA_SOURCE_SHADOW_THRALL)
	addtimer(CALLBACK(src, PROC_REF(reveal), user), conseal_time)


/obj/effect/proc_holder/spell/shadowling_guise/proc/reveal(mob/living/user)
	if(QDELETED(user))
		return

	user.alpha_set(1, ALPHA_SOURCE_SHADOW_THRALL)
	user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")


/obj/effect/proc_holder/spell/shadowling_vision
	name = "Shadowling Darksight"
	desc = "Gives you night and thermal vision."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "darksight"


/obj/effect/proc_holder/spell/shadowling_vision/Destroy()
	action?.owner?.set_vision_override(null)
	return ..()


/obj/effect/proc_holder/spell/shadowling_vision/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_vision/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!istype(user))
		return

	if(!user.vision_type)
		to_chat(user, "<span class='notice'>You shift the nerves in your eyes, allowing you to see in the dark.</span>")
		user.set_vision_override(/datum/vision_override/nightvision)
	else
		to_chat(user, "<span class='notice'>You return your vision to normal.</span>")
		user.set_vision_override(null)


/obj/effect/proc_holder/spell/shadowling_vision/thrall
	desc = "Thrall Darksight"
	desc = "Gives you night vision."


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins
	name = "Icy Veins"
	desc = "Instantly freezes the blood of nearby people, stunning them and causing burn damage."
	base_cooldown = 25 SECONDS
	clothes_req = FALSE
	action_icon_state = "icy_veins"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'>You freeze the nearby air.</span>")
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, TRUE)

	for(var/mob/living/carbon/target in targets)
		if(is_shadow_or_thrall(target))
			to_chat(target, "<span class='danger'>You feel a blast of paralyzingly cold air wrap around you and flow past, but you are unaffected!</span>")
			continue

		to_chat(target, "<span class='userdanger'>A wave of shockingly cold air engulfs you!</span>")
		target.Stun(2 SECONDS)
		target.apply_damage(10, BURN)
		target.adjust_bodytemperature(-200) //Extreme amount of initial cold
		if(target.reagents)
			target.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/shadowling_enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Allows you to enslave a conscious, non-braindead, non-catatonic human to your will. This takes some time to cast."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= "<span class='notice'>Your prepare your mind to entrall a mortal. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	need_active_overlay = TRUE
	var/enthralling = FALSE


/obj/effect/proc_holder/spell/shadowling_enthrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T


/obj/effect/proc_holder/spell/shadowling_enthrall/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(enthralling || user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_enthrall/valid_target(mob/living/carbon/human/target, user)
	return target.key && target.mind && !target.stat && !is_shadow_or_thrall(target) && target.client


/obj/effect/proc_holder/spell/shadowling_enthrall/cast(list/targets, mob/user = usr)

	listclearnulls(SSticker.mode.shadowling_thralls)
	if(!is_shadow(user))
		return

	var/mob/living/carbon/human/target = targets[1]
	if(ismindshielded(target))
		to_chat(user, "<span class='danger'>This target has a mindshield, blocking your powers! You cannot thrall it!</span>")
		return

	enthralling = TRUE
	to_chat(user, "<span class='danger'>This target is valid. You begin the enthralling.</span>")
	to_chat(target, "<span class='userdanger'>[user] stares at you. You feel your head begin to pulse.</span>")

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, "<span class='notice'>You place your hands to [target]'s head...</span>")
				user.visible_message("<span class='warning'>[user] places [user.p_their()] hands onto the sides of [target]'s head!</span>")
			if(2)
				to_chat(user, "<span class='notice'>You begin preparing [target]'s mind as a blank slate...</span>")
				user.visible_message("<span class='warning'>[user]'s palms flare a bright red against [target]'s temples!</span>")
				to_chat(target, "<span class='danger'>A terrible red light floods your mind. You collapse as conscious thought is wiped away.</span>")
				target.Weaken(24 SECONDS)
			if(3)
				to_chat(user, "<span class='notice'>You begin planting the tumor that will control the new thrall...</span>")
				user.visible_message("<span class='warning'>A strange energy passes from [user]'s hands into [target]'s head!</span>")
				to_chat(target, span_boldannounceic("You feel your memories twisting, morphing. A sense of horror dominates your mind."))
		if(!do_after(user, 7.7 SECONDS, target, NONE)) //around 23 seconds total for enthralling
			to_chat(user, "<span class='warning'>The enthralling has been interrupted - your target's mind returns to its previous state.</span>")
			to_chat(target, "<span class='userdanger'>You wrest yourself away from [user]'s hands and compose yourself</span>")
			enthralling = FALSE
			return

		if(QDELETED(target) || QDELETED(user))
			revert_cast(user)
			return

	enthralling = FALSE
	to_chat(user, "<span class='shadowling'>You have enthralled <b>[target]</b>!</span>")
	target.visible_message("<span class='big'>[target] looks to have experienced a revelation!</span>", \
							"<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
	target.setOxyLoss(0) //In case the shadowling was choking them out
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL


/**
 * Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor.
 */
/obj/effect/proc_holder/spell/shadowling_regen_armor
	name = "Rapid Re-Hatch"
	desc = "Re-forms protective chitin that may be lost during cloning or similar processes."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "regen_armor"


/obj/effect/proc_holder/spell/shadowling_regen_armor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_regen_armor/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!is_shadow(user))
		to_chat(user, "<span class='warning'>You must be a shadowling to do this!</span>")
		revert_cast(user)
		return

	if(!istype(user))
		return

	user.visible_message("<span class='warning'>[user]'s skin suddenly bubbles and shifts around [user.p_their()] body!</span>", \
					 "<span class='shadowling'>You regenerate your protective armor and cleanse your form of defects.</span>")
	user.set_species(/datum/species/shadow/ling)
	user.adjustCloneLoss(-(user.getCloneLoss()))
	user.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(user), ITEM_SLOT_CLOTH_INNER)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(user), ITEM_SLOT_FEET)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(user), ITEM_SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(user), ITEM_SLOT_GLOVES)
	user.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(user), ITEM_SLOT_MASK)
	user.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(user), ITEM_SLOT_EYES)


/**
 * Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount.
 */
/obj/effect/proc_holder/spell/shadowling_collective_mind
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	base_cooldown = 30 SECONDS //30 second cooldown to prevent spam
	clothes_req = FALSE
	var/blind_smoke_acquired
	var/screech_acquired
	var/null_charge_acquired
	var/revive_thrall_acquired
	action_icon_state = "collective_mind"


/obj/effect/proc_holder/spell/shadowling_collective_mind/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_collective_mind/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_collective_mind/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='shadowling'><b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b></span>")

	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	for(var/mob/living/target in GLOB.alive_mob_list)
		if(is_thrall(target))
			thralls++
			to_chat(target, "<span class='shadowling'>You feel hooks sink into your mind and pull.</span>")

	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, "<span class='warning'>Your concentration has been broken. The mental hooks you have sent out now retract into your mind.</span>")
		return

	if(QDELETED(user))
		return

	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))

	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. \
			It will create a choking cloud that will blind any non-thralls who enter.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))

	if(thralls >= CEILING(7 * SSticker.mode.thrall_ratio, 1) && !null_charge_acquired)
		null_charge_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Null Charge</b> ability. This ability will drain an APC's contents to the void, preventing it from recharging \
			or sending power until repaired.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_null_charge(null))

	if(thralls >= CEILING(9 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. \
			This will, after a short time, bring a dead thrall completely back to life with no bodily defects.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

	else if(thralls >= victory_threshold)
		to_chat(user, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>")
		to_chat(user, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")

		for(var/mob/check in GLOB.alive_mob_list)
			if(!is_shadow(check))
				continue

			check.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_collective_mind)
			check.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
			check.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

			if(check == user)
				to_chat(check, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
			else
				to_chat(check, "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>")//Tells all the other shadowlings


/obj/effect/proc_holder/spell/shadowling_blindness_smoke
	name = "Blindness Smoke"
	desc = "Spews a cloud of smoke which will blind enemies."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "black_smoke"


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_blindness_smoke/cast(list/targets, mob/user = usr) //Extremely hacky
	if(!shadowling_check(user))
		revert_cast(user)
		return

	user.visible_message("<span class='warning'>[user] suddenly bends over and coughs out a cloud of black smoke, which begins to spread rapidly!</span>")
	to_chat(user, "<span class='deadsay'>You regurgitate a vast cloud of blinding smoke.</span>")
	playsound(user, 'sound/effects/bamf.ogg', 50, TRUE)
	var/datum/reagents/reagents_list = new (1000)
	reagents_list.add_reagent("blindness_smoke", 810)
	var/datum/effect_system/smoke_spread/chem/chem_smoke = new
	chem_smoke.set_up(reagents_list, user.loc, TRUE)
	chem_smoke.start(4)


/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "odd black liquid"
	id = "blindness_smoke"
	description = "<::ERROR::> CANNOT ANALYZE REAGENT <::ERROR::>"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 250 * REAGENTS_METABOLISM //still lel


/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!is_shadow_or_thrall(M))
		to_chat(M, "<span class='warning'><b>You breathe in the black smoke, and your eyes burn horribly!</b></span>")
		M.EyeBlind(10 SECONDS)
		if(prob(25))
			M.visible_message("<b>[M]</b> claws at [M.p_their()] eyes!")
			M.Stun(4 SECONDS)
	else
		to_chat(M, "<span class='notice'><b>You breathe in the black smoke, and you feel revitalized!</b></span>")
		update_flags |= M.heal_organ_damage(10, 10, updating_health = FALSE)
		update_flags |= M.adjustOxyLoss(-10, FALSE)
		update_flags |= M.adjustToxLoss(-10, FALSE)
	return ..() | update_flags


/obj/effect/proc_holder/spell/aoe/shadowling_screech
	name = "Sonic Screech"
	desc = "Deafens, stuns, and confuses nearby people. Also shatters windows."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "screech"
	aoe_range = 7


/obj/effect/proc_holder/spell/aoe/shadowling_screech/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_screech/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_screech/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	user.audible_message("<span class='warning'><b>[user] lets out a horrible scream!</b></span>")
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/turf/turf in targets)
		for(var/mob/target in turf.contents)
			if(is_shadow_or_thrall(target))
				continue

			if(iscarbon(target))
				var/mob/living/carbon/c_mob = target
				to_chat(c_mob, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				c_mob.AdjustConfused(20 SECONDS)
				c_mob.AdjustDeaf(6 SECONDS)

			else if(issilicon(target))
				var/mob/living/silicon/robot = target
				to_chat(robot, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				robot << 'sound/misc/interference.ogg'
				playsound(robot, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				do_sparks(5, 1, robot)
				robot.Weaken(12 SECONDS)

		for(var/obj/structure/window/window in turf.contents)
			window.take_damage(rand(80, 100))


/obj/effect/proc_holder/spell/shadowling_null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	action_icon_state = "null_charge"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/shadowling_null_charge/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 0
	T.range = 1
	T.allowed_type = /obj/machinery/power/apc
	return T


/obj/effect/proc_holder/spell/shadowling_null_charge/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_null_charge/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	var/obj/machinery/power/apc/target_apc = targets[1]
	if(!target_apc)
		to_chat(user, "<span class='warning'>You must stand next to an APC to drain it!</span>")
		revert_cast(user)
		return

	if(target_apc.cell?.charge <= 0)
		to_chat(user, "<span class='warning'>APC must have a power to drain!</span>")
		revert_cast(user)
		return

	target_apc.operating = FALSE
	target_apc.update()
	target_apc.update_icon()
	target_apc.visible_message("<span class='warning'>The [target_apc] flickers and begins to grow dark.</span>")

	to_chat(user, "<span class='shadowling'>You dim the APC's screen and carefully begin siphoning its power into the void.</span>")
	if(!do_after(user, 20 SECONDS, target_apc))
		//Whoops!  The APC's powers back on
		to_chat(user, "<span class='shadowling'>Your concentration breaks and the APC suddenly repowers!</span>")
		target_apc.operating = TRUE
		target_apc.update()
		target_apc.update_icon()
		target_apc.visible_message("<span class='warning'>The [target_apc] begins glowing brightly!</span>")
	else
		//We did it!
		to_chat(user, "<span class='shadowling'>You sent the APC's power to the void while overloading all it's lights!</span>")
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = FALSE //Won't recharge either until an someone hits the button
		target_apc.charging = APC_NOT_CHARGING
		target_apc.null_charge()
		target_apc.update_icon()


/obj/effect/proc_holder/spell/shadowling_revive_thrall
	name = "Black Recuperation"
	desc = "Revives or empowers a thrall."
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	action_icon_state = "revive_thrall"
	selection_activated_message		= "<span class='notice'>You start focusing your powers on mending wounds of allies. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	need_active_overlay = TRUE
	/// Whether the EMPOWERED_THRALL_LIMIT limit is ignored or not
	var/ignore_prer = FALSE


/obj/effect/proc_holder/spell/shadowling_revive_thrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = -1
	T.range = 1
	return T


/obj/effect/proc_holder/spell/shadowling_revive_thrall/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_revive_thrall/valid_target(mob/living/carbon/human/target, user)
	return is_thrall(target)


/obj/effect/proc_holder/spell/shadowling_revive_thrall/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/thrall = targets[1]
	if(thrall.stat == CONSCIOUS)
		if(isshadowlinglesser(thrall))
			to_chat(user, "<span class='warning'>[thrall] is already empowered.</span>")
			revert_cast(user)
			return

		var/empowered_thralls = 0
		for(var/datum/mind/thrall_mind in SSticker.mode.shadowling_thralls)
			if(!ishuman(thrall_mind.current))
				continue

			var/mob/living/carbon/human/h_mob = thrall_mind.current
			if(isshadowlinglesser(h_mob))
				empowered_thralls++

		if(empowered_thralls >= EMPOWERED_THRALL_LIMIT && !ignore_prer)
			to_chat(user, "<span class='warning'>You cannot spare this much energy. There are too many empowered thralls.</span>")
			revert_cast(user)
			return

		user.visible_message("<span class='danger'>[user] places [user.p_their()] hands over [thrall]'s face, red light shining from beneath.</span>", \
							"<span class='shadowling'>You place your hands on [thrall]'s face and begin gathering energy...</span>")
		to_chat(thrall, "<span class='userdanger'>[user] places [user.p_their()] hands over your face. You feel energy gathering. Stand still...</span>")
		if(!do_after(user, 8 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Red lightning surges into [thrall]'s face!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		thrall.Weaken(10 SECONDS)
		thrall.visible_message("<span class='warning'><b>[thrall] collapses, [thrall.p_their()] skin and face distorting!</span>", \
										"<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAAGH-</i></span>")

		sleep(2 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.visible_message("<span class='warning'>[thrall] slowly rises, no longer recognizable as human.</span>", \
								"<span class='shadowling'><b>You feel new power flow into you. You have been gifted by your masters. You now closely resemble them. You are empowered in darkness but wither slowly in light. In addition, \
								you now have glare and true shadow walk.</b></span>")

		thrall.set_species(/datum/species/shadow/ling/lesser)
		thrall.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_guise)
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))

	else if(thrall.stat == DEAD)
		user.visible_message("<span class='danger'>[user] kneels over [thrall], placing [user.p_their()] hands on [thrall.p_their()] chest.</span>", \
							"<span class='shadowling'>You crouch over the body of your thrall and begin gathering energy...</span>")
		thrall.notify_ghost_cloning("Your masters are resuscitating you! Re-enter your corpse if you wish to be brought to life.", source = thrall)
		if(!do_after(user, 3 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Your concentration snaps. The flow of energy ebbs.</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>You release a massive surge of power into [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Red lightning surges from [user]'s hands into [thrall]'s chest!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)

		sleep(1 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.revive()
		thrall.update_revive()
		thrall.Weaken(8 SECONDS)
		thrall.emote("gasp")
		thrall.visible_message(span_boldannounceic("[thrall] heaves in breath, dim red light shining in [thrall.p_their()] eyes."), \
								"<span class='shadowling'><b><i>You have returned. One of your masters has brought you from the darkness beyond.</b></i></span>")
		playsound(thrall, "bodyfall", 50, TRUE)

	else
		to_chat(user, "<span class='warning'>The target must be awake to empower or dead to revive.</span>")
		revert_cast(user)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by ten minutes using a life force of our enemy. Shuttle will be unable to be recalled. This can only be used once."
	clothes_req = FALSE
	base_cooldown = 60 SECONDS
	selection_activated_message		= "<span class='notice'>You start gathering destructive powers to delay the shuttle. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	action_icon_state = "extend_shuttle"
	need_active_overlay = TRUE
	var/global/extend_limit_pressed = FALSE


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = -1
	T.range = 1
	return T


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/valid_target(mob/living/carbon/human/target, user)
	return !target.stat && !is_shadow_or_thrall(target)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	if(!shadowling_check(user))
		return FALSE

	if(extend_limit_pressed)
		to_chat(user, "<span class='warning'>Shuttle was already delayed.</span>")
		return FALSE

	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		to_chat(user, "<span class='warning'>The shuttle must be inbound only to the station.</span>")
		return FALSE

	user.visible_message("<span class='warning'>[user]'s eyes flash a bright red!</span>", \
						"<span class='notice'>You begin to draw [target]'s life force.</span>")
	target.visible_message("<span class='warning'>[target]'s face falls slack, [target.p_their()] jaw slightly distending.</span>", \
						span_boldannounceic("You are suddenly transported... far, far away..."))
	extend_limit_pressed = TRUE

	if(!do_after(user, 15 SECONDS, target, max_interact_count = 1))
		extend_limit_pressed = FALSE
		to_chat(target, "<span class='warning'>You are snapped back to reality, your haze dissipating!</span>")
		to_chat(user, "<span class='warning'>You have been interrupted. The draw has failed.</span>")
		return

	if(QDELETED(target) || QDELETED(user))
		revert_cast(user)
		return

	to_chat(user, "<span class='notice'>You project [target]'s life force toward the approaching shuttle, extending its arrival duration!</span>")
	target.visible_message("<span class='warning'>[target]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing.</span>", \
						"<span class='warning'><b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all...</span>")
	target.death()
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timer = SSshuttle.emergency.timeLeft(1) + 10 MINUTES
		GLOB.event_announcement.Announce("Крупный системный сбой на борту эвакуационного шаттла. Это увеличит время прибытия примерно на 10 минут, шаттл не может быть отозван.", "Системный сбой.", 'sound/misc/notice1.ogg')
		SSshuttle.emergency.setTimer(timer)
		SSshuttle.emergency.canRecall = FALSE
	user.mind.RemoveSpell(src)	//Can only be used once!


// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/ascendant_annihilate
	name = "Annihilate"
	desc = "Gibs someone instantly."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "annihilate"
	selection_activated_message		= "<span class='notice'>You start thinking about gibs. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/ascendant_annihilate/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 1
	T.range = 7
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/ascendant_annihilate/cast(list/targets, mob/user = usr)
	var/mob/living/simple_animal/ascendant_shadowling/ascendant = user
	if(ascendant.phasing)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	playsound(user.loc, 'sound/magic/staff_chaos.ogg', 100, TRUE)

	if(is_shadow(target)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Making an ally explode seems unwise.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='danger'>[user]'s markings flare as [user.p_they()] gesture[user.p_s()] at [target]!</span>", \
						"<span class='shadowling'>You direct a lance of telekinetic energy at [target].</span>")
	sleep(0.4 SECONDS)

	if(QDELETED(target) || QDELETED(user))
		return

	playsound(target, 'sound/magic/disintegrate.ogg', 100, TRUE)
	target.visible_message("<span class='userdanger'>[target] explodes!</span>")
	target.gib()


/obj/effect/proc_holder/spell/shadowling_revive_thrall/ascendant
	name = "Black will"
	desc = "Empower your faithful thrall or revives"
	base_cooldown = 0
	ignore_prer = TRUE
	human_req = FALSE

/obj/effect/proc_holder/spell/ascendant_hypnosis
	name = "Hypnosis"
	desc = "Instantly enthralls a human."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= "<span class='notice'>You start preparing to mindwash over a mortal mind. <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Your mind relaxes.</span>"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/ascendant_hypnosis/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.click_radius = 0
	T.range = 7
	return T


/obj/effect/proc_holder/spell/ascendant_hypnosis/valid_target(mob/living/carbon/human/target, user)
	return !is_shadow_or_thrall(target) && target.ckey && target.mind && !target.stat


/obj/effect/proc_holder/spell/ascendant_hypnosis/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(user.phasing)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	target.vomit(0, VOMIT_BLOOD, distance = 2, message = FALSE)
	playsound(user.loc, 'sound/hallucinations/veryfar_noise.ogg', 50, TRUE)
	to_chat(user, "<span class='shadowling'>You instantly rearrange <b>[target]</b>'s memories, hyptonitizing [target.p_them()] into a thrall.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>An agonizing spike of pain drives into your mind, and--</font></span>")
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	target.add_language(LANGUAGE_HIVE_SHADOWLING)



/obj/effect/proc_holder/spell/ascendant_phase_shift
	name = "Phase Shift"
	desc = "Phases you into the space between worlds at will, allowing you to move through walls and become invisible."
	base_cooldown = 1.5 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "shadow_walk"


/obj/effect/proc_holder/spell/ascendant_phase_shift/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ascendant_phase_shift/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(!istype(user))
		return

	user.phasing = !user.phasing

	if(user.phasing)
		user.visible_message("<span class='danger'>[user] suddenly vanishes!</span>", \
							"<span class='shadowling'>You begin phasing through planes of existence. Use the ability again to return.</span>")
		user.incorporeal_move = INCORPOREAL_NORMAL
		user.alpha_set(0, ALPHA_SOURCE_SHADOWLING)
	else
		user.visible_message("<span class='danger'>[user] suddenly appears from nowhere!</span>", \
							"<span class='shadowling'>You return from the space between worlds.</span>")
		user.incorporeal_move = INCORPOREAL_NONE
		user.alpha_set(1, ALPHA_SOURCE_SHADOWLING)


/obj/effect/proc_holder/spell/aoe/ascendant_storm
	name = "Lightning Storm"
	desc = "Shocks everyone nearby."
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "lightning_storm"
	aoe_range = 6


/obj/effect/proc_holder/spell/aoe/ascendant_storm/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/ascendant_storm/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	if(!istype(user))
		return FALSE

	if(user.phasing)
		to_chat(user, "<span class='warning'>You are not in the same plane of existence. Unphase first.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='warning'><b>A massive ball of lightning appears in [user]'s hands and flares out!</b></span>", \
						"<span class='shadowling'>You conjure a ball of lightning and release it.</span>")
	playsound(user.loc, 'sound/magic/lightningbolt.ogg', 100, TRUE)

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			continue

		to_chat(target, "<span class='userdanger'>You are struck by a bolt of lightning!</span>")
		playsound(target, 'sound/magic/lightningshock.ogg', 50, 1)
		target.Weaken(16 SECONDS)
		target.take_organ_damage(0, 50)
		user.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)


/obj/effect/proc_holder/spell/ascendant_transmit
	name = "Ascendant Broadcast"
	desc = "Sends a message to the whole wide world."
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "transmit"


/obj/effect/proc_holder/spell/ascendant_transmit/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ascendant_transmit/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	var/text = stripped_input(user, "What do you want to say to everything on and near [station_name()]?.", "Transmit to World", "")

	if(!text)
		revert_cast(user)
		return

	user.announce(text)

