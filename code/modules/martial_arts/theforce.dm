/datum/martial_art/theforce
	name = "The Force"
	weight = 7
	has_dirslash = FALSE
	has_explaination_verb = TRUE
	var/attack_sword_delimb_chance = 30
	var/attack_double_sword_delimb_chance = 60
	var/throw_sword_delimb_chance = 50

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
				force_lightning_spell.targeting.InterceptClickOn(owner, null, A, force_lightning_spell)
				force_lightning_spell.lethal = temp

		if(INTENT_GRAB)
			var/mob/living/carbon/human/victim = A
			if(istype(victim))
				if(get_dist(owner, victim) <= 4)
					var/obj/item/grab/force/G = victim.grabbedby(owner, grab_type = /obj/item/grab/force)
					G.state = GRAB_PASSIVE
					victim.LoseBreath(10 SECONDS)
				else
					to_chat(owner, span_danger("You can't reach that target!"))

		if(INTENT_HARM)
			if(!force_lightning_spell.cooldown_handler.is_on_cooldown())
				var/temp = force_lightning_spell.lethal
				force_lightning_spell.lethal = TRUE
				force_lightning_spell.targeting.InterceptClickOn(owner, null, A, force_lightning_spell)
				force_lightning_spell.lethal = temp


/obj/effect/proc_holder/spell/summon_sword
	name = "Force Pull"
	desc = ""
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "summon_sword"
	action_background_icon_state = "bg_default"
	sound = 'sound/magic/theforce/pull.ogg'


/obj/effect/proc_holder/spell/summon_sword/playMagSound()
	playsound(get_turf(usr), sound, 50)


/obj/effect/proc_holder/spell/summon_sword/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_sword/cast(targets, mob/user = usr)
	var/obj/item/sword
	for(var/obj/item/I in view(user))
		if(istype(I, /obj/item/twohanded/dualsaber/toy))
			continue
		if(is_type_in_list(I, list(/obj/item/melee/energy/sword, /obj/item/twohanded/dualsaber)))
			sword = I
			break

	if(!sword)
		cooldown_handler.start_recharge(cooldown_handler.recharge_duration * 0.1)
		return

	if(sword.loc == user)
		user.drop_item_ground(sword)
	if(sword.loc == user.loc)
		sword.forceMove(get_turf(user))

	if(!user.restrained() && sword.loc == user.loc)
		user.put_in_hands(sword)
		return

	sword.throw_at(user, 7, 3)

/obj/effect/proc_holder/spell/force_lightning
	name = "Force Lightning"
	desc = ""
	base_cooldown = 30 SECONDS
	clothes_req = FALSE

	selection_activated_message = span_notice("Click on or near a target to cast the spell.")
	selection_deactivated_message = span_notice("You stop casting your spell.")

	action_icon_state = "lightning"
	action_background_icon_state = "bg_default"
	need_active_overlay = TRUE

	sound = 'sound/magic/theforce/lightning.ogg'

	/// damaging/stunning lightning switch
	var/lethal = FALSE
	/// mostly visual effect for showing how many times the lightning will be reflected in other atoms
	var/lightning_count = 4


/obj/effect/proc_holder/spell/force_lightning/AltClick(mob/user)
	lethal = !lethal
	action.background_icon_state =  lethal ? "bg_demon" : "bg_default"
	action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/force_lightning/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /mob/living
	T.selection_type = SPELL_SELECTION_RANGE
	T.try_auto_target = FALSE
	return T


/obj/effect/proc_holder/spell/force_lightning/cast(list/targets, mob/user = usr)
	var/atom/beam_from = user
	var/atom/target_atom = pick(targets)

	for(var/i in 1 to lightning_count)
		beam_from.Beam(target_atom, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 6)
		if(isliving(target_atom))
			var/mob/living/L = target_atom
			if(lethal)
				add_attack_logs(user, L, "electrocuted with the force")
				L.electrocute_act(40)
			else
				add_attack_logs(user, L, "shocked and weakened with the force")
				L.Weaken(5 SECONDS)
			playsound(L.loc, pick('sound/magic/theforce/lightninghit1.ogg', 'sound/magic/theforce/lightninghit2.ogg', 'sound/magic/theforce/lightninghit3.ogg'), 40, TRUE)

		var/list/next_shocked = list()
		for(var/atom/movable/AM in orange(3, target_atom))
			if(AM == user || istype(AM, /obj/effect) || isobserver(AM))
				continue
			next_shocked.Add(AM)

		beam_from = target_atom
		target_atom = pick(next_shocked)
		next_shocked.Cut()


/datum/martial_art/theforce/explaination_header(user)
	return to_chat(user, "<b><i>Да пребудет с тобой [span_cult("Сила!")]</b></i>")


// Put below the combos in the explaination text
/datum/martial_art/theforce/explaination_footer(user)
	to_chat(user, span_notice("<b>Активные способности</b>"))
	to_chat(user, "[span_notice("Force grab")]: Вы можете схватить противника на расстоянии 3 клеток от вас, начав душить его при помощи Силы")
	to_chat(user, "[span_notice("Esword throw")]: Броски обычного и сдвоенного светового меча имеют шанс 50% отрубить конечность, если попадут в неё. 25% для головы.")
	to_chat(user, "[span_notice("Esword mastery")]: Ваши удары световым мечом имеют 30% шанс отрубить конечность. 60% для двойного меча")
	to_chat(user, "[span_notice("Esword Pull")]: Притягивает к вам световой меч, если он находится в видимости. Важно: из рук или из тела противника так вынуть его не получится")
	to_chat(user, "[span_notice("Force lightning")]: Выпускает в противника молнию. Имеет два режима, которые можно менять альт кликом по иконке способности. Первый режим: оглушающая молния, не наносящая вреда. Так же можно использовать её в режиме дизарма по удалённой клетке. Второй режим: электризует жертву, нанося ей 40 ожогов. Так же можно использовать её в режиме харм по удалённой клетке. От второго режима жертву может защитить изоляция от электричества")

	return

/datum/martial_art/theforce/explaination_notice(user)
	return
