/datum/martial_art/theforce
	name = "The Force"
	has_explaination_verb = TRUE
	var/attack_sword_delimb_chance = 30
	var/attack_double_sword_delimb_chance = 60
	var/throw_sword_delimb_chance = 50
	var/lightning_base_cooldown = 60 SECONDS
	var/lightning_cooldown = 0

	var/obj/effect/proc_holder/spell/summon_sword/summon_sword_spell
	var/obj/effect/proc_holder/spell/force_lightning/force_lightning_spell

/datum/martial_art/theforce/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	if(..())
		//gives telekinesis gene
		H.dna?.SetSEValue(GLOB.teleblock, 0xFFF)
		genemutcheck(H, GLOB.teleblock, null, MUTCHK_FORCED)
		H.update_mutations()

		//force spells
		summon_sword_spell = new
		force_lightning_spell = new
		H.AddSpell(summon_sword_spell)
		H.AddSpell(force_lightning_spell)


/datum/martial_art/theforce/RangedAttack(atom/A, mob/living/carbon/human/owner, params)
	switch(owner.a_intent)
		if(INTENT_DISARM)
			if(!force_lightning_spell.cooldown_handler.is_on_cooldown())
				var/temp = force_lightning_spell.lethal
				force_lightning_spell.lethal = FALSE
				force_lightning_spell.InterceptClickOn(owner, null, A)
				force_lightning_spell.lethal = temp
				// force_lightning_spell.lightning(A, owner, FALSE)
				// force_lightning_spell.cooldown_handler.start_recharge()

		if(INTENT_GRAB)
			var/mob/living/carbon/human/victim = A
			if(victim && get_dist(owner, victim) <= 4)
				var/obj/item/grab/force/G = victim.grabbedby(owner, grab_type = /obj/item/grab/force)
				G.state = GRAB_PASSIVE
				victim.LoseBreath(10 SECONDS)

		if(INTENT_HARM)
			if(!force_lightning_spell.cooldown_handler.is_on_cooldown())
				var/temp = force_lightning_spell.lethal
				force_lightning_spell.lethal = TRUE
				force_lightning_spell.InterceptClickOn(owner, null, A)
				force_lightning_spell.lethal = temp
				//force_lightning_spell.lightning(A, owner, TRUE)
				//force_lightning_spell.cooldown_handler.start_recharge()


/obj/effect/proc_holder/spell/summon_sword
	name = "Force Pull"
	desc = ""
	base_cooldown = 2 SECONDS //30 SECONDS
	clothes_req = FALSE
	action_icon_state = "summon_sword"
	action_background_icon_state = "bg_default"
	sound = 'sound/magic/the force/pull.mp3'


/obj/effect/proc_holder/spell/summon_sword/playMagSound()
	playsound(get_turf(usr), sound, 50)


/obj/effect/proc_holder/spell/summon_sword/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_sword/cast(targets, mob/user = usr)
	var/obj/item/sword
	for(var/obj/item/I in view(user))
		if(is_type_in_list(I, list(/obj/item/melee/energy/sword, /obj/item/twohanded/dualsaber)))
			sword = I

	if(!sword)
		return

	if(sword.loc == user)
		user.drop_item_ground(sword)
	if(sword.loc == user.loc)
		sword.forceMove(get_turf(user))

	if(!user.restrained())
		user.put_in_active_hand(sword)
		return

	sword.throw_at(user, 7, sword.throw_speed)

/obj/effect/proc_holder/spell/force_lightning
	name = "Force Lightning"
	desc = ""
	base_cooldown = 2 SECONDS //30 SECONDS
	clothes_req = FALSE

	selection_activated_message = span_notice("Click on or near a target to cast the spell.")
	selection_deactivated_message = span_notice("You stop casting your spell.")

	action_icon_state = "lightning"
	action_background_icon_state = "bg_default"
	need_active_overlay = TRUE

	var/lethal = FALSE


/obj/effect/proc_holder/spell/force_lightning/AltClick(mob/user)
	lethal = !lethal
	action.background_icon_state =  lethal ? "bg_demon" : "bg_default"
	action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/force_lightning/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.selection_type = SPELL_SELECTION_RANGE
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/force_lightning/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, span_notice("No target found in range."))
		return

	var/mob/living/carbon/human/target = locate() in targets
	lightning(target, user, lethal)


/obj/effect/proc_holder/spell/force_lightning/proc/lightning(atom/target, mob/living/carbon/human/user, lethal)
	playsound(user.loc, 'sound/magic/the force/lightning.mp3', 40, 1)

	var/atom/beam_from = user
	var/atom/target_atom = target

	for(var/i in 0 to 3)
		beam_from.Beam(target_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 6)
		if(isliving(target_atom))
			var/mob/living/L = target_atom
			if(lethal)
				add_attack_logs(user, L, "electrocuted with the force")
				L.electrocute_act(40)
			else
				add_attack_logs(user, L, "shocked and weakened with the force")
				L.Weaken(5 SECONDS)
			playsound(L.loc, pick('sound/magic/the force/lightninghit1.mp3', 'sound/magic/the force/lightninghit2.mp3', 'sound/magic/the force/lightninghit3.mp3'), 40, 1)

		var/list/next_shocked = list()
		for(var/atom/movable/AM in orange(3, target_atom))
			if(AM == user || istype(AM, /obj/effect) || isobserver(AM))
				continue
			next_shocked.Add(AM)

		beam_from = target_atom
		target_atom = pick(next_shocked)
		next_shocked.Cut()

