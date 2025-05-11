#define EMPOWERED_THRALL_LIMIT 5


/obj/effect/proc_holder/spell/proc/shadowling_check(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE

	if(isshadowling(user) && is_shadow(user))
		return TRUE

	if(isshadowlinglesser(user) && is_thrall(user))
		return TRUE

	if(!is_shadow_or_thrall(user))
		to_chat(user, "<span class='warning'>Ты не можешь понять, как это сделать.</span>")

	else if(is_thrall(user))
		to_chat(user, "<span class='warning'>Ты недостаточно силен, чтобы сделать это.</span>")

	else if(is_shadow(user))
		to_chat(user, "<span class='warning'>Ваша телепатическая способность подавлена. Сначала сбрось маскировку или используйте Rapid Re-Hatch.</span>")

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

	selection_activated_message		= "<span class='notice'>Ты готов ослепителять взглядом! <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message 	= "<span class='notice'>Ты передумал ослеплять взглядом.</span>"
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

	user.visible_message("<span class='warning'><b>Глаза [user] ослепительно загораются красным!</b></span>")
	var/distance = get_dist(target, user)
	if(distance <= 2)
		target.visible_message("<span class='danger'>[target] замирает на месте, глаза [target.p_their()] выглядят пустыми...</span>", \
			"<span class='userdanger'>Ты ловишь взгялд [user] на себе, и ты заворажён красатой глаз [user.p_their()]...</span>")

		target.Weaken(4 SECONDS)
		target.AdjustSilence(20 SECONDS)
		target.apply_damage(20, STAMINA)
		target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

	else //Distant glare
		target.Stun(2 SECONDS)
		target.Slowed(10 SECONDS)
		target.AdjustSilence(10 SECONDS)
		to_chat(target, "<span class='userdanger'>Красный свет мелькает перед твоимм глазами и твой разум пытается ему сопротивляться... ты истощен... ты не можете говорить.</span>")
		target.visible_message("<span class='danger'>[target] замирает на месте, глаза [target.p_their()] выглядят пустыми...</span>")


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

	to_chat(user, "<span class='shadowling'>Ты тихо перегрузил ближайщие источники света.</span>")
	for(var/turf/T in targets)
		T.extinguish_light()
		for(var/atom/A in T.contents)
			A.extinguish_light()


/obj/effect/proc_holder/spell/shadowling_shadow_walk
	name = "Shadow Walk"
	desc = "На короткое время переносит иебя в пространство между мирами, позволяя проходить сквозь стены и делая невидимым."
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
	user.visible_message("<span class='warning'>[user] исчезает в клубах чёрного дыма!</span>", "<span class='shadowling'>Ты входишь в пространство между мирами.</span>")
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

	user.visible_message("<span class='warning'>[user] внезапно появляется!</span>", "<span class='shadowling'>Давление становится слишком тяжёлым и ты покидаешь межпространственную тьму..</span>")
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
	user.visible_message("<span class='warning'>[user] внезапно исчезает!</span>", "<span class='shadowling'>Ты скрываешься во тьме и тебя становится труднее увидеть..</span>")
	user.alpha_set(standartize_alpha(10), ALPHA_SOURCE_SHADOW_THRALL)
	addtimer(CALLBACK(src, PROC_REF(reveal), user), conseal_time)


/obj/effect/proc_holder/spell/shadowling_guise/proc/reveal(mob/living/user)
	if(QDELETED(user))
		return

	user.alpha_set(1, ALPHA_SOURCE_SHADOW_THRALL)
	user.visible_message("<span class='warning'>[user] появляется из ниоткуда!</span>", "<span class='shadowling'>Тьма улетучивается, делая тебя видимым.</span>")


/obj/effect/proc_holder/spell/shadowling_vision
	name = "Shadowling Darksight"
	desc = "Дарует тебе ночное зрение."
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
		to_chat(user, "<span class='notice'>Ты меняешь расположение нервов в глазах, что позволяет тебе лучше видеть в темноте..</span>") // Да-да блять. Описание просто имба
		user.set_vision_override(/datum/vision_override/nightvision)
	else
		to_chat(user, "<span class='notice'>Ты вернул своё зрение к норме.</span>")
		user.set_vision_override(null)


/obj/effect/proc_holder/spell/shadowling_vision/thrall
	desc = "Thrall Darksight"
	desc = "Дарует тебе возможность видеть в темноте."


/obj/effect/proc_holder/spell/aoe/shadowling_icy_veins
	name = "Icy Veins"
	desc = "Моментально замораживает кровь ближайщих существ, оглушает их и вызывает ожоги."
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

	to_chat(user, "<span class='shadowling'>Ты замораживаешь воздух вокруге.</span>")
	playsound(user.loc, 'sound/effects/ghost2.ogg', 50, TRUE)

	for(var/mob/living/target in targets)
		if(is_shadow_or_thrall(target))
			to_chat(target, "<span class='danger'>Ты чувствуешь, как порыв парализующего холодного воздуха обволакивает тебя и проносится мимо, но ты не чувствуешь никакого воздействия.!</span>")
			continue

		to_chat(target, "<span class='userdanger'>Волна парализующего холодного воздуха охватывает тебя.!</span>")
		target.Stun(2 SECONDS)
		target.apply_damage(10, BURN)
		if(iscarbon(target))
			target.adjust_bodytemperature(-200) //Extreme amount of initial cold
			if(target.reagents)
				target.reagents.add_reagent("frostoil", 15) //Half of a cryosting


/obj/effect/proc_holder/spell/shadowling_enthrall //Turns a target into the shadowling's slave. This overrides all previous loyalties
	name = "Enthrall"
	desc = "Порабощает сознание гуманойдов по твоей воле, они должны быть живыми и активными. Это занимает некоторое время."
	base_cooldown = 3 SECONDS
	clothes_req = FALSE
	action_icon_state = "enthrall"
	selection_activated_message		= "<span class='notice'>Ты готовишь свой разум, чтобы покорить смертного. <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message	= "<span class='notice'>Ты расслабляешь свой разум.</span>"
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
		to_chat(user, "<span class='danger'>Эта цель использует защиту разума, она блокирует твои силы! Ты не можешь поработить это сознание it!</span>")
		return

	enthralling = TRUE
	to_chat(user, "<span class='danger'>Эта цель подойдёт. Ты начинаешь порабощение.</span>")
	to_chat(target, "<span class='userdanger'>[user] пронзает тебя взглядом. Ты чувствуешь, как твоя голова начинает пульсировать.</span>")

	for(var/progress = 0, progress <= 3, progress++)
		switch(progress)
			if(1)
				to_chat(user, "<span class='notice'>Ты положил свои руку на голову [target]...</span>")
				user.visible_message("<span class='warning'>[user] положил руки побокам головы [target]!</span>")
			if(2)
				to_chat(user, "<span class='notice'>Ты начинаешь порабощение [target]...</span>")
				user.visible_message("<span class='warning'>Ладони [user] загораются красным у висков [target]!</span>")
				to_chat(target, "<span class='danger'>Ужасный красный свет заливает твой разум. Ты падаешь в обморок, когда твои желания исчезают..</span>")
				target.Weaken(15 SECONDS)
			if(3)
				to_chat(user, "<span class='notice'>Ты начинаете внедрять опухоль, которая будет контролировать нового раба....</span>")
				user.visible_message("<span class='warning'>Странная энергия переходит из рук [user] в голову [target]!</span>")
				to_chat(target, span_boldannounceic("Ты чувствуешь, как твои воспоминания искажаются, трансформируются. Чувство ужаса овладевает твоим разумом.."))
		if(!do_after(user, 3 SECONDS, target, NONE)) //9 seconds for enthralling
			to_chat(user, "<span class='warning'>Порабощение прервано — разум вашей цели возвращается в норму..</span>")
			to_chat(target, "<span class='userdanger'>Ты вырываешься из хватки [user] и тебе становится лучше</span>")
			enthralling = FALSE
			return

		if(QDELETED(target) || QDELETED(user))
			revert_cast(user)
			return

	enthralling = FALSE
	to_chat(user, "<span class='shadowling'>Ты порабощен <b>[target]</b>!</span>")
	target.visible_message("<span class='big'>[target] выглядит будто ему открылась истина!</span>", \
							"<span class='warning'>False faces all d<b>ark not real not real not--</b></span>")
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
		to_chat(user, "<span class='warning'>Сообщите администрации, что увидели это!</span>")
		revert_cast(user)
		return

	if(!istype(user))
		return

	user.set_species(/datum/species/shadow/ling)
	user.adjustCloneLoss(-(user.getCloneLoss()))
	user.set_vision_override(/datum/vision_override/nightvision) // nighvision withot button
	var/obj/item/organ/internal/cyberimp/eyes/eyes
	eyes = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling(null) // thermal without item
	eyes.insert(user)

	var/thralls = 0
	var/victory_threshold = SSticker.mode.required_thralls
	for(var/mob/living/target in GLOB.alive_mob_list)
		if(is_thrall(target))
			thralls++

	if(!do_after(user, 3 SECONDS, user))
		to_chat(user, "<span class='warning'>Ваша концентрация нарушена.</span>")
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
				to_chat(shadowling, "<span class='shadowling'><i>Ты проецируешь эту силу на остальных тенелингов..</i></span>")
			else
				to_chat(shadowling, "<span class='shadowling'><b>[user.real_name] объединил силу рабов ты можешь вознестись</b></span>")//Tells all the other shadowlings


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

	if(thralls >= CEILING(1 * SSticker.mode.thrall_ratio, 1) && !blind_smoke_acquired)
		blind_smoke_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Blinding Smoke</b> ability. \
			It will create a choking cloud that will blind any non-thralls who enter.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))

	if(thralls >= CEILING(3 * SSticker.mode.thrall_ratio, 1) && !screech_acquired)
		screech_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Sonic Screech</b> ability. This ability will shatter nearby windows and deafen enemies, plus stunning silicon lifeforms.</span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))

	if(thralls >= CEILING(5 * SSticker.mode.thrall_ratio, 1) && !revive_thrall_acquired)
		revive_thrall_acquired = TRUE
		to_chat(user, "<span class='shadowling'><i>The power of your thralls has granted you the <b>Black Recuperation</b> ability. \
			This will, after a short time, bring a dead thrall completely back to life with no bodily defects.</i></span>")
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))

	if(thralls < victory_threshold)
		to_chat(user, "<span class='shadowling'>You do not have the power to ascend. You require [victory_threshold] thralls, but only [thralls] living thralls are present.</span>")

	else if(thralls >= victory_threshold)
		to_chat(user, "<span class='shadowling'><b>You are now powerful enough to ascend. Use the Ascendance ability when you are ready. <i>This will kill all of your thralls.</i></span>")
		to_chat(user, "<span class='shadowling'><b>You may find Ascendance in the Shadowling Evolution tab.</b></span>")

		for(var/mob/shadowling in GLOB.alive_mob_list)
			if(!is_shadow(shadowling))
				continue

			shadowling.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_hatch)
			shadowling.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

			if(shadowling == user)
				to_chat(shadowling, "<span class='shadowling'><i>You project this power to the rest of the shadowlings.</i></span>")
			else
				to_chat(shadowling, "<span class='shadowling'><b>[user.real_name] has coalesced the strength of the thralls. You can draw upon it at any time to ascend. (Shadowling Evolution Tab)</b></span>")//Tells all the other shadowlings


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

	user.visible_message("<span class='warning'>[user] внезапно наклоняется и выпускает облако черного дыма, которое начинает быстро распространяться!</span>")
	to_chat(user, "<span class='deadsay'>Ты выпускаешь огромное облако чёрного дыма.</span>")
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

	user.audible_message("<span class='warning'><b>[user] издает ужасный крик!</b></span>")
	playsound(user.loc, 'sound/effects/screech.ogg', 100, TRUE)

	for(var/turf/turf in targets)
		for(var/mob/target in turf.contents)
			if(is_shadow_or_thrall(target))
				continue

			if(iscarbon(target))
				var/mob/living/carbon/c_mob = target
				to_chat(c_mob, "<span class='danger'><b>Острая боль пронзает голову и путает мысли!</b></span>")
				c_mob.AdjustConfused(20 SECONDS)
				c_mob.AdjustDeaf(6 SECONDS)

			else if(issilicon(target))
				var/mob/living/silicon/robot = target
				to_chat(robot, "<span class='warning'><b>Ошибка $!(@ Ошибка )#^! ПЕРЕГРУЗКА СЕНСЕРОВ \[$(!@#</b></span>")
				robot << 'sound/misc/interference.ogg'
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
	desc = "Оживляет или усиливает раба."
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	action_icon_state = "revive_thrall"
	selection_activated_message		= "<span class='notice'>Ты начинаешь фокусировать свой разум для лечения ран союзников. <b>Используй ЛКМ для применения!</b></span>"
	selection_deactivated_message	= "<span class='notice'>Ты расслабляешь свой разум.</span>"
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
			to_chat(user, "<span class='warning'>[thrall] раб уже усилен.</span>")
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
			to_chat(user, "<span class='warning'>Ты не можешь выпустить столько энергии. Слишком много рабов, наделенных силой.</span>")
			revert_cast(user)
			return

		user.visible_message("<span class='danger'>[user] положил руки на голову [thrall] и красный свет засиял под ней.</span>", \
							"<span class='shadowling'>Ты положил руки на голову [thrall] и начал передавать энергию...</span>")
		to_chat(thrall, "<span class='userdanger'>[user] положил руки на твою голову. Ты чувствуешь наполнение энергией. Не двигайся...</span>")
		if(!do_after(user, 8 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Твоя концентрация ослабевает. Поток энергии рассеивается..</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>Ты выпускаешь огромный запас энергии в [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Красная молния бъёт [thrall] в лицо!</i>"))
		playsound(thrall, 'sound/weapons/egloves.ogg', 50, TRUE)
		playsound(thrall, 'sound/machines/defib_zap.ogg', 50, TRUE)
		user.Beam(thrall, icon_state="red_lightning",icon='icons/effects/effects.dmi',time=1)
		thrall.Weaken(10 SECONDS)
		thrall.visible_message("<span class='warning'><b>[thrall] в припадке, [thrall.p_their()] кожа лица искажаются!</span>", \
										"<span class='userdanger'><i>AAAAAAAAAAAAAAAAAAA-</i></span>")

		sleep(2 SECONDS)
		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		thrall.visible_message("<span class='warning'>[thrall] медленно начинает двигаться, в [thrall.p_their()] не узнаётся старый облик.</span>", \
								"<span class='shadowling'><b>Ты чувствуешь, как сила наполняет тебя. Тебя одарили твои хозяива. Теперь ты походишь на них. Ты сильнее во тьме и ослабиваешь на свету. Кроме того, \
								теперь ты можешь пронзать взглядом и по настоящему перемещаться в тенях.</b></span>")

		thrall.set_species(/datum/species/shadow/ling/lesser)
		thrall.mind.RemoveSpell(/obj/effect/proc_holder/spell/shadowling_guise)
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
		thrall.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))

	else if(thrall.stat == DEAD)
		user.visible_message("<span class='danger'>[user] становится на колени перед [thrall], кладёт руки на [thrall.p_their()] грудь.</span>", \
							"<span class='shadowling'>Ты приседаешь над телом своего раба и начинаешь собирать энергию....</span>")
		thrall.notify_ghost_cloning("Твои хозяева воскрешают тебя! Вернись в свое тело, если хочешь, чтобы тебя вернули к жизни..", source = thrall)
		if(!do_after(user, 3 SECONDS, thrall, NONE))
			to_chat(user, "<span class='warning'>Твоя концентрация ослабевает. Поток энергии исчезает..</span>")
			revert_cast(user)
			return

		if(QDELETED(thrall) || QDELETED(user))
			revert_cast(user)
			return

		to_chat(user, "<span class='shadowling'><b><i>Ты выпускаешь огромный выброс энергии в [thrall]!</b></i></span>")
		user.visible_message(span_boldannounceic("<i>Из рук [user] появляется красная молния и бъёт [thrall] в грудь!</i>"))
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
		thrall.visible_message(span_boldannounceic("[thrall] тяжело дышит, тусклое красное свечение в [thrall.p_their()] глазах."), \
								"<span class='shadowling'><b><i>Ты вернулся. Один из твоих хозяев вывел тебя из тьмы за горизонтом.</b></i></span>")
		playsound(thrall, "bodyfall", 50, TRUE)

	else
		to_chat(user, "<span class='warning'>Цель должна быть активной, чтобы наделить силой, или мертвой, чтобы возродиться.</span>")
		revert_cast(user)


/obj/effect/proc_holder/spell/shadowling_extend_shuttle
	name = "Destroy Engines"
	desc = "Extends the time of the emergency shuttle's arrival by ten minutes using a life force of our enemy. Shuttle will be unable to be recalled. This can only be used once."
	clothes_req = FALSE
	base_cooldown = 3 SECONDS
	selection_activated_message		= "<span class='notice'>You start gathering destructive powers to delay the shuttle. <b>Left-click to cast at a target!</b></span>"
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
	desc = "Моментально разрывает на куски."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	action_icon_state = "annihilate"
	selection_activated_message		= "<span class='notice'>Ты подготавливаешь свой разум к атаке. <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message	= "<span class='notice'>Ты расслабляешь свой разум.</span>"
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
		to_chat(user, "<span class='warning'>Ты вне пространства. Сначала прояви себя.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	playsound(user.loc, 'sound/magic/staff_chaos.ogg', 100, TRUE)

	if(is_shadow(target)) //Used to not work on thralls. Now it does so you can PUNISH THEM LIKE THE WRATHFUL GOD YOU ARE.
		to_chat(user, "<span class='warning'>Уничтожать союзников кажется плохой идеей.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='danger'>[user]'s markings flare as [user.p_they()] gesture[user.p_s()] at [target]!</span>", \
						"<span class='shadowling'>Ты направляешь копьё телекинетической энергии [target].</span>")
	sleep(0.4 SECONDS)

	if(QDELETED(target) || QDELETED(user))
		return

	playsound(target, 'sound/magic/disintegrate.ogg', 100, TRUE)
	target.visible_message("<span class='userdanger'>[target] взрывается!</span>")
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
	selection_activated_message		= "<span class='notice'>Ты подготавливаешь свой разум к порабащению. <b>Left-click to cast at a target!</b></span>"
	selection_deactivated_message	= "<span class='notice'>Ты расслабляешь свой разум.</span>"
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
		to_chat(user, "<span class='warning'>Ты вне пространства. Сначала прояви себя.</span>")
		revert_cast(user)
		return

	var/mob/living/carbon/human/target = targets[1]

	target.vomit(0, VOMIT_BLOOD, distance = 2, message = FALSE)
	playsound(user.loc, 'sound/hallucinations/veryfar_noise.ogg', 50, TRUE)
	to_chat(user, "<span class='shadowling'>Ты мгновено перестраиваешь память и порабошаешь <b>[target]</b>.</span>")
	to_chat(target, "<span class='userdanger'><font size=3>Мучительный боль вонзает в твоём разуме, и--</font></span>")
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
		user.visible_message("<span class='danger'>[user] внезапно исчезает!</span>", \
							"<span class='shadowling'>Ты начинаешь проходить через пространство. Используйте способность снова, чтобы вернуться.</span>")
		user.incorporeal_move = INCORPOREAL_NORMAL
		user.alpha_set(0, ALPHA_SOURCE_SHADOWLING)
	else
		user.visible_message("<span class='danger'>[user] появляется из ниоткуда!</span>", \
							"<span class='shadowling'>Ты вернулся из другого простнратсва.</span>")
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
		to_chat(user, "<span class='warning'>Ты вне пространства. Сначала прояви себя.</span>")
		revert_cast(user)
		return

	user.visible_message("<span class='warning'><b>Большой шар молний появляется из рук [user]!</b></span>", \
						"<span class='shadowling'>Ты создаешь шар молний и выпускаешь его..</span>")
	playsound(user.loc, 'sound/magic/lightningbolt.ogg', 100, TRUE)

	for(var/mob/living/carbon/human/target in targets)
		if(is_shadow_or_thrall(target))
			continue

		to_chat(target, "<span class='userdanger'>Тебя ударила молния!</span>")
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
	var/text = stripped_input(user, "Что ты хочешь сказать всем находящимся рядом и на [station_name()]?.", "Озвучить всем", "")

	if(!text)
		revert_cast(user)
		return

	user.announce(text)

