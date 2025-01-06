/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/V)
	V.subclass.thrall_cap++
	gain_desc = "Теперь вы можете подчинить себе еще одного гуманоида, вплоть до <b>[V.subclass.thrall_cap]</b> ."


/datum/vampire_passive/increment_thrall_cap/two


/datum/vampire_passive/increment_thrall_cap/three


/obj/effect/proc_holder/spell/vampire/enthrall
	name = "Порабощение"
	desc = "Вы используете значительную часть своей силы, чтобы поработить разум другого гуманоида."
	gain_desc = "Вы обрели способность подчинять людей своей воле."
	action_icon_state = "vampire_enthrall"
	need_active_overlay = TRUE
	required_blood = 150
	deduct_blood_on_cast = FALSE


/obj/effect/proc_holder/spell/vampire/enthrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 1
	T.click_radius = 0
	return T


/obj/effect/proc_holder/spell/vampire/enthrall/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/target = targets[1]
	user.visible_message(span_warning("[user] куса[pluralize_ru(user.gender, "ет", "ют")] [target] за шею!"), \
						span_warning("Вы кусаете [target] за шею и впускаете поток силы."))
	to_chat(target, span_warning("Вы чувствуете, как в ваш разум проникают потоки нечистой силы."))
	if(do_after(user, 15 SECONDS, target, NONE))
		if(can_enthrall(user, target))
			handle_enthrall(user, target)
			var/datum/spell_handler/vampire/V = custom_handler
			var/blood_cost = V.calculate_blood_cost(vampire)
			vampire.bloodusable -= blood_cost //we take the blood after enthralling, not before
	else
		revert_cast(user)
		to_chat(user, span_warning("Вы или ваша цель сдвинулись с места."))


/obj/effect/proc_holder/spell/vampire/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	. = FALSE
	if(!C)
		CRASH("target was null while trying to vampire enthrall, attacker is [user] [user.key] \ref[user]")

	if(!user.mind.som)
		CRASH("Dantalion Thrall datum ended up null.")

	if(!ishuman(C))
		to_chat(user, span_warning("Вы можете поработить только разумных гуманоидов!"))
		return

	if(!C.mind)
		to_chat(user, span_warning("Разум [C.name] не предназначен для порабощения."))
		return

	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.subclass.thrall_cap <= length(user.mind.som.serv))
		to_chat(user, span_warning("У вас не хватит сил, чтобы поработить ещё больше гуманоидов!"))
		return

	if(ismindshielded(C) || isvampire(C) || isvampirethrall(C) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message(span_warning("Похоже, [C] сопротивля[pluralize_ru(user.gender, "ет", "ют")]ся захвату!"), \
						span_notice("Вы чувствуете знакомое ощущение в черепе, которое быстро проходит."))
		return

	if(C.mind.isholy)
		C.visible_message(span_warning("Похоже, [C] сопротивля[pluralize_ru(user.gender, "ет", "ют")]ся захвату!"), \
						span_notice("Ваша вера в [SSticker.Bible_deity_name] сохранила ваш разум чистым от всякого зла."))
		return

	return TRUE


/obj/effect/proc_holder/spell/vampire/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	H.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall/new_thrall(user.mind))
	if(jobban_isbanned(H, ROLE_VAMPIRE))
		SSticker.mode.replace_jobbanned_player(H, SPECIAL_ROLE_VAMPIRE_THRALL)
	H.Stun(4 SECONDS)
	user.create_log(CONVERSION_LOG, "vampire enthralled", H)
	H.create_log(CONVERSION_LOG, "was vampire enthralled", user)


/obj/effect/proc_holder/spell/vampire/thrall_commune
	name = "Телепатическая связь"
	desc = "Общайтесь со своими рабами с помощью блюспейс-телепатии."
	gain_desc = "Вы обрели способность общаться со своими рабами на расстоянии."
	action_icon_state = "vamp_communication"
	create_attack_logs = FALSE
	base_cooldown = 2 SECONDS


/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_handler() //so thralls can use it
	return


/datum/spell_targeting/select_vampire_network/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom) // Returns the vampire and their thralls. If user is a thrall then it will look up their master's network
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


/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_targeting()
	var/datum/spell_targeting/select_vampire_network/T = new
	return T


/obj/effect/proc_holder/spell/vampire/thrall_commune/cast(list/targets, mob/user)
	var/input = tgui_input_text(user, "Введите сообщение для передачи другим рабам", "Сообщение рабам")
	if(! input)
		revert_cast(user)
		return

	// if admins give this to a non vampire/thrall it is not my problem
	var/is_thrall = isvampirethrall(user)
	var/title = is_thrall ? "(Раб Вампира) [user.real_name]" : "<span class='dantalion'><font size='3'>(Мастер Вампир) [user.real_name]</font></span>"
	var/message = is_thrall ? "<span class='dantalion'>[input]</span>" : "<span class='dantalion'><font size='3'><b>[input]</b></font></span>"

	for(var/mob/player in targets)
		to_chat(player, "<i><span class='game say'>Рабская телепатия, <span class='name'>[title]</span> телепатезирует, [message]</span><i>")

	for(var/mob/ghost in GLOB.dead_mob_list)
		to_chat(ghost, "<i><span class='game say'>Рабская телепатия, <span class='name'>[title]</span> ([ghost_follow_link(user, ghost)]) телепатезирует, [message]</span><i>")

	log_say("(DANTALION) [input]", user)
	user.create_log(SAY_LOG, "(DANTALION) [input]")


/obj/effect/proc_holder/spell/vampire/pacify
	name = "Умиротворение"
	desc = "Временно умиротворяет цель, делая её неспособной причинить вред."
	gain_desc = "Вы обрели способность умиротворять агрессивные порывы гуманоида, не позволяя ему причинить кому-либо физический вред."
	action_icon_state = "pacify"
	base_cooldown = 10 SECONDS
	required_blood = 10
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/pacify/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.allowed_type = /mob/living/carbon/human
	return T


/obj/effect/proc_holder/spell/vampire/pacify/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		to_chat(H, span_notice("Вы вдруг почувствовали себя очень спокойно..."))
		SEND_SOUND(H, 'sound/hallucinations/i_see_you1.ogg')
		H.apply_status_effect(STATUS_EFFECT_PACIFIED)


/obj/effect/proc_holder/spell/vampire/switch_places
	name = "Подпространственный обмен"
	desc = "Поменяйтесь местами с целью. Также замедляет жертву и вызывает у нее галлюцинации."
	gain_desc = "Вы получили возможность меняться местами с выбранным существом."
	centcom_cancast = FALSE
	action_icon_state = "subspace_swap"
	base_cooldown = 5 SECONDS
	required_blood = 15
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/switch_places/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.try_auto_target = FALSE
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/vampire/switch_places/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	target.forceMove(user_turf)
	user.forceMove(target_turf)

	if(target.affects_vampire(user))
		target.Slowed(4 SECONDS)
		SEND_SOUND(target, 'sound/hallucinations/behind_you1.ogg')
		target.flash_eyes(2, TRUE, affect_silicon = TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion(user_turf, target, duration = 15 SECONDS, skip_nearby = FALSE)


/obj/effect/proc_holder/spell/vampire/self/decoy
	name = "Приманка"
	desc = "На короткое время станьте невидимым и создайте иллюзию для обмана, чтобы провести свою жертву."
	gain_desc = "Вы получили способность становиться невидимым и создавать обманные иллюзии."
	action_icon_state = "decoy"
	required_blood = 30
	base_cooldown = 20 SECONDS
	var/duration = 6 SECONDS


/obj/effect/proc_holder/spell/vampire/self/decoy/cast(list/targets, mob/user)
	var/user_turf = get_turf(user)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(user_turf)
	E.Copy_Parent(user, duration, 20)
	E.GiveTarget(user) //so it starts running right away
	E.Goto(user, E.move_to_delay, E.minimum_distance)
	user.make_invisible()
	playsound(user_turf, 'sound/hallucinations/look_up1.ogg', 50, TRUE)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, reset_visibility)), duration)


/obj/effect/proc_holder/spell/vampire/rally_thralls
	name = "Сплотить рабов"
	desc = "Снимает все обездвиживающие эффекты с находящихся рядом с вами рабов."
	gain_desc = "Вы получили способность снимать все обездвиживающие эффекты с ближайших рабов."
	action_icon_state = "thralls_up"
	required_blood = 40
	base_cooldown = 30 SECONDS


/obj/effect/proc_holder/spell/vampire/rally_thralls/create_new_targeting()
	var/datum/spell_targeting/aoe/thralls/T = new
	T.allowed_type = /mob/living/carbon/human
	T.range = 7
	return T


/datum/spell_targeting/aoe/thralls/valid_target(target, user, obj/effect/proc_holder/spell/spell, check_if_in_range)
	if(!isvampirethrall(target))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/rally_thralls/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		var/image/I = image('icons/effects/vampire_effects.dmi', "rallyoverlay", layer = EFFECTS_LAYER)
		playsound(H, 'sound/magic/staff_healing.ogg', 50)
		H.remove_CC()
		H.add_overlay(I)
		addtimer(CALLBACK(H, TYPE_PROC_REF(/atom, cut_overlay), I), 6 SECONDS) // this makes it obvious who your thralls are for a while.


/obj/effect/proc_holder/spell/vampire/self/share_damage
	name = "Кровавые узы"
	desc = "Создает сеть между вами и ближайшими рабами, которая равномерно распределяет весь получаемый урон."
	gain_desc = "Вы получили способность распределять урон между вами и вашими рабами."
	action_icon_state = "blood_bond"
	required_blood = 5


/obj/effect/proc_holder/spell/vampire/self/share_damage/cast(list/targets, mob/living/user)
	var/datum/status_effect/thrall_net/T = user.has_status_effect(STATUS_EFFECT_THRALL_NET)
	if(!T)
		user.apply_status_effect(STATUS_EFFECT_THRALL_NET, user.mind.has_antag_datum(/datum/antagonist/vampire))
		return
	qdel(T)


/obj/effect/proc_holder/spell/vampire/hysteria
	name = "Массовая истерия"
	desc = "Накладывает мощную иллюзию, заставляющую всех, кто находится поблизости, воспринимать окружающих как случайных животных после кратковременного ослепления. Также замедляет пострадавших."
	gain_desc = "Вы получили способность заставлять всех, кто находится рядом, воспринимать окружающих как случайных животных после кратковременного ослепления."
	action_icon_state = "hysteria"
	required_blood = 40
	base_cooldown = 60 SECONDS


/obj/effect/proc_holder/spell/vampire/hysteria/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new
	T.range = 8
	T.allowed_type = /mob/living/carbon/human
	return T


/obj/effect/proc_holder/spell/vampire/hysteria/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/target in targets)
		if(!target.affects_vampire(user))
			continue

		SEND_SOUND(target, 'sound/hallucinations/over_here1.ogg')
		target.Slowed(4 SECONDS)
		target.flash_eyes(2, TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion(get_turf(user), target, skip_nearby = FALSE)

