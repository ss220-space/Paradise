#define EMPOWERED_THRALL_LIMIT 5


/obj/effect/proc_holder/spell/proc/shadowling_check(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(isshadowling(user) && is_shadow(user))
		return TRUE

	if(isshadowlinglesser(user) && is_thrall(user))
		return TRUE

	if(!is_shadow_or_thrall(user))
		to_chat(user, span_warning("Вы не можете понять, как это сделать."))

	else if(is_thrall(user))
		to_chat(user, span_warning("Вы недостаточно сильны, чтобы сделать это."))

	else if(is_shadow(user))
		to_chat(user, span_warning("Ваши телепатические способности подавлены. Сначала сбрось маскировку или используйте Rapid Re-Hatch."))

	return FALSE


/**
 * Stuns and mutes a human target, depending on the distance relative to the shadowling.
 */
/obj/effect/proc_holder/spell/shadowling_glare
	name = "Glare"
	desc = "Оглушает и заглушает цель на приличную продолжительность. Продолжительность зависит от близости к цели."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	need_active_overlay = TRUE

	action_icon_state = "glare"

	selection_activated_message		= span_notice("Вы приготовились к тому, что ваши глаза станут ослепительно яркими! <b>ЛКМ по цели, чтобы применить!</b>")
	selection_deactivated_message 	= span_notice("Ваши глаза расслабляются... пока что.")
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

	user.visible_message(span_warning("<b>Глаза [user] вспыхивают ослепительно красным светом!</b>"))
	var/distance = get_dist(target, user)
	if(distance <= 2)
		target.visible_message(span_danger("[target] застывает на месте, [genderize_ru(target.gender,"его","её","его","их")] глаза стекленеют..."), \
								span_userdanger("Ваш взгляд насильно притягивается к глазам [user], и вы пленяетесь их неописуемой красотой..."))

		target.Weaken(4 SECONDS)
		target.AdjustSilence(20 SECONDS)
		target.apply_damage(20, STAMINA)
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

	else //Distant glare
		target.Stun(2 SECONDS)
		target.Slowed(10 SECONDS)
		target.AdjustSilence(10 SECONDS)
		to_chat(target, span_userdanger("Красный свет вспыхивает перед глазами, и разум пытается противостоять ему... Вы обессилены... Вы не в состоянии говорить..."))
		target.visible_message(span_danger("[target] застывает на месте, [genderize_ru(target.gender,"его","её","его","их")] глаза стекленеют..."))


/obj/effect/proc_holder/spell/aoe/shadowling_veil
	name = "Veil"
	desc = "Гасит большинство близлежащих источников света."
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

	to_chat(user, span_shadowling("Вы бесшумно отключаете все ближайшие источники света."))
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()


/obj/effect/proc_holder/spell/shadowling_shadow_walk
	name = "Shadow Walk"
	desc = "На короткое время переносит вас в пространство между мирами, позволяя проходить сквозь стены и делая невидимым."
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
	// mech supress escape
	if(HAS_TRAIT_FROM(user, TRAIT_IMMOBILIZED, MECH_SUPRESSED_TRAIT))
		user.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
	user.visible_message(span_warning("[user] исчезает в клубах черного тумана!"), \
						span_shadowling("Вы входите в пространство между мирами через небольшой проход."))
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

	user.visible_message(span_warning("[user] внезапно появляется!"), \
						span_shadowling("Давление становится слишком велико, и вы покидаете межпространственную тьму."))
	user.incorporeal_move = INCORPOREAL_NONE
	user.alpha_set(1, ALPHA_SOURCE_SHADOWLING)
	user.forceMove(get_turf(user))


/obj/effect/proc_holder/spell/shadowling_guise
	name = "Guise"
	desc = "Окутывает твой силует тенями, делая тебя менее заметным."
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
	user.visible_message(span_warning("[user] внезапно исчезает!"), \
						span_shadowling("Вы окутываете себя тьмой, и вас становится трудно разглядеть."))
	user.alpha_set(standartize_alpha(10), ALPHA_SOURCE_SHADOW_THRALL)
	addtimer(CALLBACK(src, PROC_REF(reveal), user), conseal_time)


/obj/effect/proc_holder/spell/shadowling_guise/proc/reveal(mob/living/user)
	if(QDELETED(user))
		return

	user.alpha_set(1, ALPHA_SOURCE_SHADOW_THRALL)
	user.visible_message(span_warning("[user] появляется из ниоткуда!"), \
						span_shadowling("Ваша теневая маскировка исчезает."))


/obj/effect/proc_holder/spell/shadowling_vision
	name = "Shadowling Darksight"
	desc = "Дарует вам ночное зрение."
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
		to_chat(user, span_notice("Вы изменяете положение нервных волокон в глазах, что позволяет вам видеть в темноте."))
		user.set_vision_override(/datum/vision_override/nightvision)
	else
		to_chat(user, span_notice("Вы возвращаете нормальное зрение."))
		user.set_vision_override(null)


/obj/effect/proc_holder/spell/shadowling_vision/thrall
	desc = "Thrall Darksight"
	desc = "Дарует вам возможность видеть в темноте."


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins
	name = "Icy Veins"
	desc = "Моментально замораживает кровь ближайших существ, оглушает их и наносит термические повреждения."
	base_cooldown = 25 SECONDS
	clothes_req = FALSE
	action_icon_state = "icy_veins"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/can_cast(mob/living/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.incorporeal_move == INCORPOREAL_NORMAL)
		return FALSE
	. = ..()


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, span_shadowling("Вы замораживаете воздух поблизости."))
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, TRUE)

	for(var/mob/living/target in targets)
		if(is_shadow_or_thrall(target))
			to_chat(target, span_danger("Вы чувствуете, как порыв холодного воздуха обволакивает вас и проносится мимо, но вас это не затрагивает!"))
			continue

		to_chat(target, span_userdanger("Вас накрывает волна невероятно холодного воздуха!"))
		target.Stun(2 SECONDS)
		target.apply_damage(10, BURN)
		if(iscarbon(target))
			target.adjust_bodytemperature(-200) //Extreme amount of initial cold
			if(target.reagents)
				target.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/shadowling_enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Порабощает сознание гуманойдов вашей воле, они должны быть живыми и активными. Это занимает некоторое время."
	base_cooldown = 3 SECONDS
	clothes_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= span_notice("Вы готовите свой разум к тому, чтобы проникнуть в чужое сознание. <b>ЛКМ по цели, чтобы применить!</b>")
	selection_deactivated_message	= span_notice("Ваш разум расслабляется.")
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
		to_chat(user, span_danger("У этой цели есть щит разума, блокирующий ваши силы! Вы не можете подчинить его!"))
		return

	enthralling = TRUE
	to_chat(user, span_danger("Эта цель верна. Вы начинаете процесс подчинения."))
	to_chat(target, span_userdanger("[user] смотр[pluralize_ru(user.gender,"ит","ят")] на вас. Вы чувствуете, что ваша голова начинает пульсировать."))

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, span_notice("Вы прикладываете ладони к голове [target]..."))
				user.visible_message(span_warning("[user] прикладыва[pluralize_ru(user.gender,"ет","ют")] свои ладони к голове [target]"))
			if(2)
				to_chat(user, span_notice("Вы начинаете обрабатывать разум [target] до состояния чистого листа..."))
				user.visible_message(span_warning("Ладони [user] вспыхивают ярко-красным светом на висках [target]!"))
				to_chat(target, span_danger("Ужасный красный свет заливает ваш разум. Вы падаете, когда ваше сознание стирается."))
				target.Weaken(24 SECONDS)
			if(3)
				to_chat(user, span_notice("Вы начинаете выращивать опухоль, которая будет контролировать нового раба..."))
				user.visible_message(span_warning("Странная энергия исходит из рук [user] в голову [target]"))
				to_chat(target, span_boldannounceic("Вы чувствуете, как ваши воспоминания искажаются, деформируются. Чувство ужаса овладевает вашим сознанием."))
		if(!do_after(user, 3 SECONDS, target, NONE)) // 9 seconds for enthralling
			to_chat(user, span_warning("Порабощение было прервано — разум вашей цели возвращается в прежнее состояние."))
			to_chat(target, span_userdanger("Вы вырываетесь из цепких рук [user] и приходите в себя."))
			enthralling = FALSE
			return

		if(QDELETED(target) || QDELETED(user))
			revert_cast(user)
			return

	enthralling = FALSE
	to_chat(user, span_shadowling("Вы подчинили себе <b>[target]</b>!"))
	target.visible_message(span_big("[target], похоже, испытал[genderize_ru(target.gender,"","а","о","и")] откровение!"), \
							span_warning("Фальшивые лица все <b>ТЁМНЫЕ не настоящие, не настоящие, не настоящие</b>!!!"))
	target.setOxyLoss(0) //In case the shadowling was choking them out
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL


/**
 * Resets a shadowling's species to normal, removes genetic defects, and re-equips their armor.
 */
/obj/effect/proc_holder/spell/shadowling_regen_armor
	name = "Rapid Re-Hatch"
	desc = "Восстанавливает ваше обличие, подпитываясь рабами усиляет тебя."
	base_cooldown = 3 SECONDS
	clothes_req = FALSE
	action_icon_state = "regen_armor"
	var/blind_smoke_acquired
	var/screech_acquired
	var/null_charge_acquired
	var/revive_thrall_acquired


/obj/effect/proc_holder/spell/shadowling_regen_armor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_regen_armor/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!is_shadow(user))
		to_chat(user, span_warning("Чтобы сделать это, нужно быть тенеморфом!"))
		revert_cast(user)
		return

	if(!istype(user))
		return

	user.visible_message(span_warning("Кожа [user] начинает пузыриться и перемещаться по телу!"), \
					 span_shadowling("Вы восстанавливаете свою броню и очищаете свою форму от дефектов."))
	user.set_species(/datum/species/shadow/ling)
	user.adjustCloneLoss(-(user.getCloneLoss()))
	user.set_vision_override(/datum/vision_override/nightvision) // nighvision withot button
	var/obj/item/organ/internal/cyberimp/eyes/eyes
	eyes = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling(null) // thermal without item
	eyes.insert(user)

	var/thralls = get_thralls()
	var/victory_threshold = SSticker.mode.required_thralls

	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, span_warning("Ваша концентрация нарушена."))
		return

	if(QDELETED(user))
		return

	if(thralls >= CEILING(1 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))

	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))

	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))

	if(thralls >= victory_threshold)
		for(var/mob/shadowling in GLOB.alive_mob_list)
			if(!is_shadow(shadowling))
				continue

			shadowling.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
			shadowling.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

			if(shadowling == user)
				to_chat(shadowling, span_shadowling("<i>Ты проецируешь эту силу на остальных тенелингов..</i>"))
			else
				to_chat(shadowling, span_shadowling("<b>[user.real_name] объединил силу рабов ты можешь вознестись</b>")) //Tells all the other shadowlings


/**
 * Lets a shadowling bring together their thralls' strength, granting new abilities and a headcount.
 */
/obj/effect/proc_holder/spell/shadowling_collective_mind
	name = "Collective Hivemind"
	desc = "Gathers the power of all of your thralls and compares it to what is needed for ascendance. Also gains you new abilities."
	base_cooldown = 3 SECONDS
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

/proc/get_thralls()
	var/thralls = 0
	for(var/mob/living/target in GLOB.alive_mob_list)
		if(!is_thrall(target) || target.mind.madeby_sentience_potion)
			continue

		thralls++
		to_chat(target, span_shadowling("You feel hooks sink into your mind and pull."))

	return thralls

/obj/effect/proc_holder/spell/shadowling_collective_mind/cast(list/targets, mob/user = usr)
	if(!shadowling_check(user))
		revert_cast(user)
		return

	to_chat(user, span_shadowling("<b>You focus your telepathic energies abound, harnessing and drawing together the strength of your thralls.</b>"))

	var/thralls = get_thralls()
	var/victory_threshold = SSticker.mode.required_thralls

	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, span_warning("Your concentration has been broken. The mental hooks you have sent out now retract into your mind."))
		return

	if(QDELETED(user))
		return

	if(thralls >= CEILING(1 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. \
			It will create a choking cloud that will blind any non-thralls who enter.</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))

	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Null Charge</b> ability. This ability will drain an APC's contents to the void, preventing it from recharging or sending power until repaired.</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))

	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		to_chat(user, span_shadowling("<i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. \
			This will, after a short time, bring a dead thrall completely back to life with no bodily defects.</i>"))
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, span_shadowling("You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present."))

	else if(thralls >= victory_threshold)
		to_chat(user, span_shadowling("<b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i>"))
		to_chat(user, span_shadowling("<b>You may find Ascendance in the Shadowling Evolution tab.</b>"))

		for(var/mob/shadowling in GLOB.alive_mob_list)
			if(!is_shadow(shadowling))
				continue

			shadowling.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
			shadowling.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

			if(shadowling == user)
				to_chat(shadowling, span_shadowling("<i>You project this power to the rest of the shadowlings.</i>"))
			else
				to_chat(shadowling, span_shadowling("<b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b>"))//Tells all the other shadowlings


/obj/effect/proc_holder/spell/shadowling_blindness_smoke
	name = "Blindness Smoke"
	desc = "Выпускает облако чёрного дыма, которое лечит рабов."
	base_cooldown = 30 SECONDS
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

	user.visible_message(span_warning("[user] внезапно наклоняется и выкашливает облако черного дыма, которое начинает быстро распространяться!"))
	to_chat(user, span_deadsay("Вы изрыгаете огромное облако слепящего дыма."))
	playsound(user, 'sound/effects/bamf.ogg', 50, TRUE)
	var/datum/reagents/reagents_list = new (1000)
	reagents_list.add_reagent("blindness_smoke", 810)
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	smoke.set_up(range = 3, location = user.loc, carry = reagents_list, silent = TRUE)
	smoke.start()


/datum/reagent/shadowling_blindness_smoke //Blinds non-shadowlings, heals shadowlings/thralls
	name = "Странная чёрная жидкость"
	id = "blindness_smoke"
	description = "ЗАПИСЬ В БАЗЕ ДАННЫХ ОТСУТСТВУЕТ"
	color = "#000000" //Complete black (RGB: 0, 0, 0)
	metabolization_rate = 250 * REAGENTS_METABOLISM //still lel


/datum/reagent/shadowling_blindness_smoke/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!is_shadow_or_thrall(M))
		to_chat(M, span_warning("Вы вдыхаете чёрный дым, и ваши глаза ужасно горят!"))
		M.EyeBlind(10 SECONDS)
		if(prob(25))
			M.visible_message(span_warning("[M] яростно тр[pluralize_ru(M.gender, "ёт", "ут")] свои глаза!"))
			M.Stun(4 SECONDS)
	else
		to_chat(M, span_notice("Вы вдыхаете чёрный дым и чувствуете лёгкость!"))
		update_flags |= M.heal_organ_damage(10, 10, updating_health = FALSE)
		update_flags |= M.adjustOxyLoss(-10, FALSE)
		update_flags |= M.adjustToxLoss(-10, FALSE)
	return ..() | update_flags


/obj/effect/proc_holder/spell/aoe/shadowling_screech
	name = "Sonic Screech"
	desc = "Оглушает и сбивает с толку находящихся рядом гуманойдов, а также разбивает окна."
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

	user.audible_message(span_warning("<b>[user] изда[pluralize_ru(user.gender,"ет","ют")] ужасный крик!</b>"))
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/turf/turf in targets)
		for(var/mob/target in turf.contents)
			if(is_shadow_or_thrall(target))
				continue

			if(iscarbon(target))
				var/mob/living/carbon/c_mob = target
				to_chat(c_mob, span_danger("<b>Острая боль пронзает голову и путает мысли!</b>"))
				c_mob.AdjustConfused(20 SECONDS)
				c_mob.AdjustDeaf(6 SECONDS)

			else if(issilicon(target))
				var/mob/living/silicon/robot = target
				to_chat(robot, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! ПЕРЕГРУЗКА СЕНСЕРОВ \[$(!@#</b>"))
				SEND_SOUND(robot, sound('sound/misc/interference.ogg'))
				playsound(robot, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
				do_sparks(5, 1, robot)
				robot.Weaken(12 SECONDS)

		for(var/obj/structure/window/window in turf.contents)
			window.take_damage(rand(80, 100))


/obj/effect/proc_holder/spell/shadowling_null_charge
	name = "Null Charge"
	desc = "Empties an APC, preventing it from recharging until fixed."
	base_cooldown = 3 SECONDS
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
		to_chat(user, span_warning("You must stand next to an APC to drain it!"))
		revert_cast(user)
		return

	if(target_apc.cell?.charge <= 0)
		to_chat(user, span_warning("APC must have a power to drain!"))
		revert_cast(user)
		return

	target_apc.operating = FALSE
	target_apc.update()
	target_apc.update_icon()
	target_apc.visible_message(span_warning("The [target_apc] flickers and begins to grow dark."))

	to_chat(user, span_shadowling("You dim the APC's screen and carefully begin siphoning its power into the void."))
	if(!do_after(user, 20 SECONDS, target_apc))
		//Whoops!  The APC's powers back on
		to_chat(user, span_shadowling("Your concentration breaks and the APC suddenly repowers!"))
		target_apc.operating = TRUE
		target_apc.update()
		target_apc.update_icon()
		target_apc.visible_message(span_warning("The [target_apc] begins glowing brightly!"))
	else
		//We did it!
		to_chat(user, span_shadowling("You sent the APC's power to the void while overloading all it's lights!"))
		target_apc.cell?.charge = 0	//Sent to the shadow realm
		target_apc.chargemode = FALSE //Won't recharge either until an someone hits the button
		target_apc.charging = APC_NOT_CHARGING
		target_apc.null_charge()
		target_apc.update_icon()


/obj/effect/proc_holder/spell/shadowling_revive_thrall
	name = "Black Recuperation"
	desc = "Оживляет или усиливает раба."
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	action_icon_state = "revive_thrall"
	selection_activated_message		= span_notice("Вы начинаете направлять свои силы на заживление ран ваших союзников. ")
	selection_deactivated_message	= span_notice("Ваш разум расслабляется.")
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
			to_chat(user, span_warning("[thrall] уже наделен силой."))
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
			to_chat(user, span_warning("Вы не можете тратить столько энергии. Слишком много наделенных силой рабов."))
			revert_cast(user)
			return

		user.visible_message(span_danger("[user] клад[pluralize_ru(user.gender,"ет","ут")] свои руки, из под которых светится красный свет, на лицо [thrall]."), \
							span_shadowling("Вы кладете ладони на лицо [thrall] и начинаете наполнять [genderize_ru(thrall.gender,"его","её","его","их")] энергией..."))
		to_chat(thrall, span_userdanger("[user] положил[genderize_ru(user.gender,"","а","о","и")] свои ладони на ваше лицо. Вы чувствуете, как в вас собирается энергия. Стойте спокойно..."))
		if(!do_after(user, 8 SECONDS, thrall, NONE))
			to_chat(user, span_warning("Ваша концентрация нарушается. Поток энергии ослабевает."))
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, span_shadowling("<b><i>Вы высвобождаете мощный заряд энергии в [thrall]!</b></i>"))
		user.visible_message(span_boldannounceic("<i>В лицо [thrall] бьет красная молния!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		thrall.Weaken(10 SECONDS)
		thrall.visible_message(span_warning("<b>[thrall] падает, [genderize_ru(thrall.gender,"его","её","его","их")] кожа лица деформируются!"), \
								span_userdanger("<i>АААААААААААААААХХ</i>"))

		sleep(2 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.visible_message(span_warning("[thrall] медленно поднима[pluralize_ru(thrall.gender,"ет","ют")]ся, переставая быть похожим[pluralize_ru(thrall.gender,"","и")] на гуманоида."), \
								span_shadowling("<b>Вы чувствуете, как в вас вливается новая сила. Вы получили дар от своих хозяев. Теперь вы очень похожи на них. Вы обретаете силу во тьме, но медленно увядаете при свете. Кроме того, теперь вы обладаете способностью использовать ослепляющий взгляд и ходить в тени.</b>"))

		thrall.set_species(/datum/species/shadow/ling/lesser)
		thrall.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_guise)
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))

	else if(thrall.stat == DEAD)
		user.visible_message(span_danger("[user] опуска[pluralize_ru(user.gender,"ет","ют")]ся на колени над [thrall], кладя свои ладони на [genderize_ru(thrall.gender,"его","её","его","их")] грудь."), \
							span_shadowling("Вы склоняетесь над телом своего раба и начинаете накапливать энергию..."))
		thrall.notify_ghost_cloning("Ваши хозяева возрождают вас! Если вы хотите оживить свой труп, войдите в него заново.", source = thrall)
		if(!do_after(user, 3 SECONDS, thrall, NONE))
			to_chat(user, span_warning("Ваша концентрация нарушается. Поток энергии ослабевает."))
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, span_shadowling("<b><i>Вы высвобождаете мощный заряд энергии в [thrall]!</b></i>"))
		user.visible_message(span_boldannounceic("<i>Красная молния устремляется из рук [user] в грудь [thrall]!</i>"))
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
		thrall.visible_message(span_boldannounceic("[thrall] тяжело дышит, в [genderize_ru(thrall.gender,"его","её","его","их")] глазах сияет тусклый красный свет."), \
								span_shadowling("<b><i>Вы вернулись. Один из ваших хозяев привел вас из потусторонней тьмы.</b></i>"))
		playsound(thrall, "bodyfall", 50, TRUE)

	else
		to_chat(user, span_warning("Цель должна быть активна, чтобы наделить ее силой, или мертва, чтобы ее оживить."))
		revert_cast(user)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by ten minutes using a life force of our enemy. Shuttle will be unable to be recalled. This can only be used once."
	clothes_req = FALSE
	base_cooldown = 3 SECONDS
	selection_activated_message		= span_notice("Вы начинаете накапливать силы, чтобы задержать шаттл. <b>ЛКМ по цели, чтобы применить!</b>")
	selection_deactivated_message	= span_notice("Ваш разум расслабляется.")
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
		to_chat(user, span_warning("Shuttle was already delayed."))
		return FALSE

	if(SSshuttle.emergency.mode != SHUTTLE_CALL)
		to_chat(user, span_warning("The shuttle must be inbound only to the station."))
		return FALSE

	user.visible_message(span_warning("[user]'s eyes flash a bright red!"), \
						span_notice("You begin to draw [target]'s life force."))
	target.visible_message(span_warning("[target]'s face falls slack, [target.p_their()] jaw slightly distending."), \
						span_boldannounceic("You are suddenly transported... far, far away..."))
	extend_limit_pressed = TRUE

	if(!do_after(user, 15 SECONDS, target, max_interact_count = 1))
		extend_limit_pressed = FALSE
		to_chat(target, span_warning("You are snapped back to reality, your haze dissipating!"))
		to_chat(user, span_warning("You have been interrupted. The draw has failed."))
		return

	if(QDELETED(target) || QDELETED(user))
		revert_cast(user)
		return

	to_chat(user, span_notice("You project [target]'s life force toward the approaching shuttle, extending its arrival duration!"))
	target.visible_message(span_warning("[target]'s eyes suddenly flare red. They proceed to collapse on the floor, not breathing."), \
						span_warning("<b>...speeding by... ...pretty blue glow... ...touch it... ...no glow now... ...no light... ...nothing at all..."))
	target.death()
	if(SSshuttle.emergency.mode == SHUTTLE_CALL)
		var/timer = SSshuttle.emergency.timeLeft(1) + 10 MINUTES
		GLOB.major_announcement.announce("Крупный системный сбой на борту эвакуационного шаттла. Это увеличит время прибытия примерно на 10 минут, шаттл не может быть отозван.",
										ANNOUNCE_SYSERROR_RU,
										'sound/misc/notice1.ogg'
		)
		SSshuttle.emergency.setTimer(timer)
		SSshuttle.emergency.canRecall = FALSE
	user.mind.RemoveSpell(src)	//Can only be used once!


// ASCENDANT ABILITIES BEYOND THIS POINT //

/obj/effect/proc_holder/spell/ascendant_annihilate
	name = "Annihilate"
	desc = "Моментально разрывает на куски."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "annihilate"
	selection_activated_message		= span_notice("Вы готовите свой разум к разрушительной атаке. <b>ЛКМ по цели, чтобы применить!</b>")
	selection_deactivated_message	= span_notice("Ваш разум расслабляется.")
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
		to_chat(user, span_warning("Вы вне пространства. Сначала проявите себя."))
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	playsound(user.loc, 'sound/magic/staff_chaos.ogg', 100, TRUE)

	if(is_shadow(target)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, span_warning("Making an ally explode seems unwise."))
		revert_cast(user)
		return

	user.visible_message(span_danger("Метки [user] вспыхивают, когда [genderize_ru(user.gender,"он","она","оно","они")] дела[pluralize_ru(user.gender,"ет","ют")] жест в [target]!"), \
						span_shadowling("Вы направляете копьё телекинетической энергии в [target]."))
	sleep(0.4 SECONDS)

	if(QDELETED(target) || QDELETED(user))
		return

	playsound(target, 'sound/magic/disintegrate.ogg', 100, TRUE)
	target.visible_message(span_userdanger("[target] взрывается!"))
	target.gib()


/obj/effect/proc_holder/spell/shadowling_revive_thrall/ascendant
	name = "Black will"
	desc = "Дарует силу твоему рабу или оживляет его"
	base_cooldown = 0
	ignore_prer = TRUE
	human_req = FALSE

/obj/effect/proc_holder/spell/ascendant_hypnosis
	name = "Hypnosis"
	desc = "Моментально подчиняет гуманойда."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= span_notice("Вы готовите свой разум к тому, чтобы промыть чужое сознание. <b>ЛКМ по цели, чтобы применить!</b>")
	selection_deactivated_message	= span_notice("Ваш разум расслабляется.")
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
		to_chat(user, span_warning("Вы вне пространства. Сначала проявите себя."))
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	target.vomit(0, VOMIT_BLOOD, distance = 2, message = FALSE)
	playsound(user.loc, 'sound/hallucinations/veryfar_noise.ogg', 50, TRUE)
	to_chat(user, span_shadowling("Вы мгновенно изменяете воспоминания <b>[target]</b>, превращая [genderize_ru(target.gender,"его","её","его","их")] в раба"))
	to_chat(target, span_userdanger(span_fontsize3("Волна мучительной боли проникает в ваше сознание, и...")))
	SSticker.mode.add_thrall(target.mind)
	target.mind.special_role = SPECIAL_ROLE_SHADOWLING_THRALL
	target.add_language(LANGUAGE_HIVE_SHADOWLING)



/obj/effect/proc_holder/spell/ascendant_phase_shift
	name = "Phase Shift"
	desc = "Перемещает тебя в пространство между мирами по твоему желанию, позволяя тебе проходить сквозь стены и становиться невидимым."
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
		user.visible_message(span_danger("[user] внезапно исчезает!"), \
							span_shadowling("Вы начинаете перемещаться сквозь пространство. Используйте способность еще раз, чтобы вернуться."))
		user.incorporeal_move = INCORPOREAL_NORMAL
		user.alpha_set(0, ALPHA_SOURCE_SHADOWLING)
	else
		user.visible_message(span_danger("[user] внезапно появля[pluralize_ru(user.gender,"ет","ют")]ся из ниоткуда!"), \
							span_shadowling("Вы возвращаетесь из пространства между мирами."))
		user.incorporeal_move = INCORPOREAL_NONE
		user.alpha_set(1, ALPHA_SOURCE_SHADOWLING)


/obj/effect/proc_holder/spell/aoe/ascendant_storm
	name = "Lightning Storm"
	desc = "Оглушает окружающих."
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
		to_chat(user, span_warning("Вы вне пространства. Сначала проявите себя."))
		revert_cast(user)
		return

	user.visible_message(span_warning("<b>В руках [user] возникает и разгорается огромная шаровая молния!</b>"), \
						span_shadowling("Вы создаете шаровую молнию и выпускаете ее."))
	playsound(user.loc, 'sound/magic/lightningbolt.ogg', 100, TRUE)

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			continue

		to_chat(target, span_userdanger("Вас поражает молния!"))
		playsound(target, 'sound/magic/lightningshock.ogg', 50, 1)
		target.Weaken(16 SECONDS)
		target.take_organ_damage(0, 50)
		user.Beam(target,icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)


/obj/effect/proc_holder/spell/ascendant_transmit
	name = "Ascendant Broadcast"
	desc = "Посылает сообщение всем вокруг."
	base_cooldown = 20 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "transmit"


/obj/effect/proc_holder/spell/ascendant_transmit/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ascendant_transmit/cast(list/targets, mob/living/simple_animal/ascendant_shadowling/user = usr)
	var/text = tgui_input_text(user, "Что ты хочешь сказать всем находящимся рядом и на [station_name()]?.", "Озвучить всем", "")

	if(!text)
		revert_cast(user)
		return

	user.announce(text)

