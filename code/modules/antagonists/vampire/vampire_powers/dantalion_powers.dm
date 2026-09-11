/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/V)
	V.subclass.thrall_cap++
	gain_desc = "Теперь вы можете подчинить себе ещё одного гуманоида, вплоть до <b>[V.subclass.thrall_cap]</b> ."

/datum/vampire_passive/increment_thrall_cap/two

/datum/vampire_passive/increment_thrall_cap/three

/datum/action/cooldown/spell/pointed/dantalion_enthrall
	name = "Порабощение"
	desc = "Вы используете значительную часть своей силы, чтобы поработить разум другого гуманоида или оживить своего раба."
	gain_desc = "Вы обрели способность подчинять людей своей воле."
	button_icon_state = "vampire_enthrall"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 1
	cooldown_time = 10 SECONDS
	var/required_blood = 100

/datum/action/cooldown/spell/pointed/dantalion_enthrall/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood, FALSE)
	return handler

/datum/action/cooldown/spell/pointed/dantalion_enthrall/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	var/mob/living/victim = cast_on
	return (..() && can_enthrall(owner, victim)) || (victim.stat == DEAD && isvampirethrall(victim))

/datum/action/cooldown/spell/pointed/dantalion_enthrall/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/target = cast_on
	owner.visible_message(span_warning("[owner] куса[PLUR_ET_YUT(owner)] [target] за шею!"), \
						span_warning("Вы кусаете [target] за шею и впускаете поток силы."))
	to_chat(target, span_warning("Вы чувствуете, как в ваш разум проникают потоки нечистой силы."))

	if(!do_after(owner, 15 SECONDS, target, NONE))
		reset_spell_cooldown()
		to_chat(owner, span_warning("Вы или ваша цель сдвинулись с места."))
		return

	if(isvampirethrall(target))
		var/datum/antagonist/mindslave/thrall/thrall = target.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)
		if(thrall && thrall.master == owner.mind)
			var/turf/turf = get_turf(target)
			playsound(turf, 'sound/magic/staff_healing.ogg', 50, TRUE)

			var/obj/effect/abstract/vampire/target_image = new(turf)
			target_image.add_overlay(target)
			target.forceMove(target_image)

			animate(target_image, pixel_y = 16, time = 2 SECONDS, easing = BOUNCE_EASING|EASE_IN)
			animate(pixel_y = 0, time = 0.5 SECONDS, easing = BOUNCE_EASING|EASE_OUT)
			addtimer(CALLBACK(src, PROC_REF(revive_thrall_step_first), target, target_image, turf, owner, vampire), 1.6 SECONDS)
			return

		to_chat(owner, span_warning("Это не ваш раб."))
		reset_spell_cooldown()
		return

	handle_enthrall(owner, target)
	var/datum/spell_handler/vampire/vamp = custom_handler
	var/blood_cost = vamp.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost

/datum/action/cooldown/spell/pointed/dantalion_enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	. = FALSE
	if(!C)
		CRASH("target was null while trying to vampire enthrall, attacker is [user] [user.key] \ref[user]")

	if(!user.mind.som)
		CRASH("Dantalion Thrall datum ended up null.")

	if(!ishuman(C))
		to_chat(user, span_warning("Вы можете поработить только разумных гуманоидов!"))
		return
	if(C.stat == DEAD)
		if(isvampirethrall(C))
			return // So we won't get any messages when trying to revive our thrall
		C.balloon_alert(user, "цель мертва!")
		return

	if(!C.mind)
		to_chat(user, span_warning("Разум [C.name] не предназначен для порабощения."))
		return

	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.subclass.thrall_cap <= length(user.mind.som.serv))
		to_chat(user, span_warning("У вас не хватит сил, чтобы поработить ещё больше гуманоидов!"))
		return

	if(ismindshielded(C) || isvampire(C) || isvampirethrall(C) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message(span_warning("Похоже, [C] сопротивля[PLUR_ET_YUT(user)]ся захвату!"), \
						span_notice("Вы чувствуете знакомое ощущение в черепе, которое быстро проходит."))
		return

	if(C.mind.isholy)
		C.visible_message(span_warning("Похоже, [C] сопротивля[PLUR_ET_YUT(user)]ся захвату!"), \
						span_notice("Ваша вера в [SSticker.Bible_deity_name] сохранила ваш разум чистым от всякого зла."))
		return

	return TRUE

/datum/action/cooldown/spell/pointed/dantalion_enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	H.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall/new_thrall(user.mind))
	if(jobban_isbanned(H, ROLE_VAMPIRE))
		SSticker.mode.replace_jobbanned_player(H, SPECIAL_ROLE_VAMPIRE_THRALL)
	H.Stun(4 SECONDS)
	user.create_log(CONVERSION_LOG, "vampire enthralled", H)
	H.create_log(CONVERSION_LOG, "was vampire enthralled", user)

/datum/action/cooldown/spell/pointed/dantalion_enthrall/proc/revive_thrall_step_first(mob/living/target, obj/effect/abstract/vampire/target_image, turf/location, mob/living/user, datum/antagonist/vampire/vampire)
	if(QDELETED(target) || QDELETED(target_image))
		return
	target.revive()
	target.update_revive()
	new /obj/effect/temp_visual/cult/sparks(location)
	// Start the second stage after 0.5 seconds, when the animation is completely finished
	addtimer(CALLBACK(src, PROC_REF(revive_thrall_step_second), target, target_image, location, user, vampire), 0.5 SECONDS)

/// Second stage: return the thrall to the tile and complete the ritual
/datum/action/cooldown/spell/pointed/dantalion_enthrall/proc/revive_thrall_step_second(mob/living/target, obj/effect/abstract/vampire/target_image, turf/location, mob/living/user, datum/antagonist/vampire/vampire)
	if(QDELETED(target) || QDELETED(target_image))
		return
	target.forceMove(location)
	qdel(target_image)

	var/datum/spell_handler/vampire/vamp = custom_handler
	var/blood_cost = vamp.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost
	user.create_log(CONVERSION_LOG, "revived thrall", target)
	target.create_log(CONVERSION_LOG, "was revived by vampire master", user)

/datum/action/cooldown/spell/dantalion_thrall_commune
	name = "Телепатическая связь"
	desc = "Общайтесь со своими рабами с помощью блюспейс-телепатии."
	gain_desc = "Вы обрели способность общаться со своими рабами на расстоянии."
	button_icon_state = "vamp_communication"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 2 SECONDS

/datum/action/cooldown/spell/dantalion_thrall_commune/proc/choose_targets(mob/user) // Returns the vampire and their thralls. If user is a thrall then it will look up their master's network
	var/list/mob/living/targets = list()
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire) // if the user is a vampire

	if(!V)
		for(var/datum/mind/M in user.mind.som.masters) // if the user is a thrall
			V = M.has_antag_datum(/datum/antagonist/vampire)
			if(V)
				break

	if(!V)
		return

	if(!V.owner.som) // I hate som
		stack_trace("Dantalion Thrall datum ended up null.")
		return

	for(var/datum/mind/thrall in V.owner.som.serv)
		targets += thrall.current

	targets += V.owner.current
	return targets

/datum/action/cooldown/spell/dantalion_thrall_commune/cast(atom/cast_on)
	. = ..()
	var/input = tgui_input_text(owner, "Введите сообщение для передачи другим рабам", "Сообщение рабам")
	if(!input)
		reset_spell_cooldown()
		return

	// if admins give this to a non vampire/thrall it is not my problem
	var/is_thrall = isvampirethrall(owner)
	var/title = is_thrall ? "(Раб Вампира) [owner.real_name]" : span_dantalion(span_fontsize3("(Мастер Вампир) [owner.real_name]"))
	var/message = is_thrall ? span_dantalion("[input]") : span_dantalion(span_fontsize3(span_bold("[input]")))
	var/list/targets = choose_targets(owner)
	for(var/mob/player in targets)
		to_chat(player, span_gamesay("<i>Рабская телепатия, [span_name("[title]")] телепатезирует, [message]<i>"))

	for(var/mob/ghost in GLOB.dead_mob_list)
		to_chat(ghost, span_gamesay("([ghost_follow_link(owner, ghost)]) <i>Рабская телепатия, [span_name("[title]")] телепатезирует, [message]<i>"))

	log_say("(DANTALION) [input]", owner)
	owner.create_log(SAY_LOG, "(DANTALION) [input]")

/datum/action/cooldown/spell/pointed/pacify
	name = "Умиротворение"
	desc = "Временно умиротворяет цель, делая её неспособной причинить вред. Возможно использовать сквозь стены."
	gain_desc = "Вы обрели способность умиротворять агрессивные порывы гуманоида, не позволяя ему причинить кому-либо физический вред."
	button_icon_state = "pacify"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	var/required_blood = 10

/datum/action/cooldown/spell/pointed/pacify/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/pacify/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/pacify/cast(atom/cast_on)
	. = ..()
	var/sound/sound = sound('sound/magic/cult_spell.ogg')
	sound.volume = 30
	SEND_SOUND(owner, sound)
	var/mob/living/carbon/human/target = cast_on
	if(!target.affects_vampire(owner))
		to_chat(owner, span_warning("Вы чувствуете, что ваша способность не произвела никакого эффекта!"))
		return

	to_chat(target, span_notice("Вы вдруг почувствовали себя очень спокойно..."))
	SEND_SOUND(target, sound('sound/hallucinations/i_see_you1.ogg'))
	target.apply_status_effect(STATUS_EFFECT_PACIFIED, owner) // we wont to see, whom we already pacify

/datum/action/cooldown/spell/pointed/switch_places
	name = "Подпространственный обмен"
	desc = "Поменяйтесь местами с целью. Также замедляет жертву и вызывает у нее галлюцинации. Невозможно использовать сквозь стены."
	gain_desc = "Вы получили возможность меняться местами с выбранным существом."
	button_icon_state = "subspace_swap"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 10 SECONDS
	var/required_blood = 15

/datum/action/cooldown/spell/pointed/switch_places/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/switch_places/is_valid_target(atom/cast_on)
	return ..() && isliving(cast_on) && !isAI(cast_on)

/datum/action/cooldown/spell/pointed/switch_places/cast(atom/cast_on)
	. = ..()
	var/mob/living/target = cast_on
	var/turf/user_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	target.forceMove(user_turf)
	owner.forceMove(target_turf)
	var/sound/sound = sound('sound/magic/mindswap.ogg')
	sound.volume = 30
	SEND_SOUND(owner, sound)

	if(target.affects_vampire(owner))
		target.Slowed(4 SECONDS)
		SEND_SOUND(target, sound('sound/hallucinations/behind_you1.ogg'))
		target.flash_eyes(2, TRUE, affect_silicon = TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion(user_turf, target, duration = 15 SECONDS, skip_nearby = FALSE)

/datum/action/cooldown/spell/dantalion_decoy
	name = "Приманка"
	desc = "На короткое время станьте невидимым и создайте иллюзию для обмана, чтобы провести свою жертву."
	gain_desc = "Вы получили способность становиться невидимым и создавать обманные иллюзии."
	button_icon_state = "decoy"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	cooldown_time = 20 SECONDS
	var/duration = 6 SECONDS
	var/required_blood = 30

/datum/action/cooldown/spell/dantalion_decoy/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/dantalion_decoy/cast(atom/cast_on)
	. = ..()
	var/user_turf = get_turf(owner)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(user_turf)
	E.Copy_Parent(owner, duration, 20)
	E.GiveTarget(owner) //so it starts running right away
	E.Goto(owner, E.move_to_delay, E.minimum_distance)
	owner.make_invisible()
	playsound(user_turf, 'sound/hallucinations/look_up1.ogg', 50, TRUE)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, reset_visibility)), duration)

/datum/action/cooldown/spell/aoe/rally_thralls
	name = "Сплотить рабов"
	desc = "Снимает все обездвиживающие эффекты с находящихся рядом с вами рабов."
	gain_desc = "Вы получили способность снимать все обездвиживающие эффекты с ближайших рабов."
	button_icon_state = "thralls_up"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 30 SECONDS
	aoe_radius = /datum/aoe_targeting/vamp_thralls
	var/required_blood = 25

/datum/action/cooldown/spell/aoe/rally_thralls/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/aoe/rally_thralls/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/H = victim
	var/image/I = image('icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
	playsound(H, 'sound/magic/staff_healing.ogg', 50)
	H.remove_CC()
	H.add_overlay(I)
	addtimer(CALLBACK(H, TYPE_PROC_REF(/atom, cut_overlay), I), 6 SECONDS) // this makes it obvious who your thralls are for a while.

/datum/action/cooldown/spell/share_damage
	name = "Кровавые узы"
	desc = "Создает сеть между вами и ближайшими рабами, которая равномерно распределяет весь получаемый урон."
	gain_desc = "Вы получили способность распределять урон между вами и вашими рабами."
	button_icon_state = "blood_bond"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/required_blood = 5

/datum/action/cooldown/spell/share_damage/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/share_damage/cast(atom/cast_on)
	. = ..()
	var/datum/status_effect/thrall_net/T = owner.has_status_effect(STATUS_EFFECT_THRALL_NET)
	if(!T)
		var/mob/living/caster = owner
		caster.apply_status_effect(STATUS_EFFECT_THRALL_NET, owner.mind.has_antag_datum(/datum/antagonist/vampire))
		return
	qdel(T)

/datum/action/cooldown/spell/aoe/hysteria
	name = "Массовая истерия"
	desc = "Накладывает мощную иллюзию, заставляющую всех, кто находится поблизости, воспринимать окружающих как случайных животных после кратковременного ослепления. Также замедляет пострадавших."
	gain_desc = "Вы получили способность заставлять всех, кто находится рядом, воспринимать окружающих как случайных животных после кратковременного ослепления."
	button_icon_state = "hysteria"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	aoe_radius = 8
	cooldown_time = 60 SECONDS
	targeting_type = /datum/aoe_targeting/human_affects_vamp
	var/required_blood = 25

/datum/action/cooldown/spell/aoe/hysteria/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/target = victim
	SEND_SOUND(target, sound('sound/hallucinations/over_here1.ogg'))
	target.Slowed(4 SECONDS)
	target.flash_eyes(2, TRUE) // flash to give them a second to lose track of who is who
	new /obj/effect/hallucination/delusion(get_turf(owner), target, skip_nearby = FALSE)

