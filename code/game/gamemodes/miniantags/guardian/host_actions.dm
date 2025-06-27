/**
 * # Base guardian host action
 *
 * These are used by guardian hosts to interact with their guardians. These are not buttons that guardians themselves use.
 */
/datum/action/guardian
	name = "Generic guardian host action"
	icon_icon = 'icons/mob/guardian.dmi'
	button_icon_state = "base"
	var/mob/living/simple_animal/hostile/guardian/guardian

/datum/action/guardian/Grant(mob/M, mob/living/simple_animal/hostile/guardian/G)
	if(!G || !istype(G))
		stack_trace("/datum/action/guardian created with no guardian to link to.")
		qdel(src)
	guardian = G
	return ..()

/**
 * # Communicate action
 *
 * Allows the guardian host to communicate with their guardian.
 */
/datum/action/guardian/communicate
	name = "Связь"
	desc = "Телепатически свяжитесь со своим хранителем."
	button_icon_state = "communicate"

/datum/action/guardian/communicate/Trigger(left_click = TRUE)
	var/input = tgui_input_text(owner, "Введите сообщение для вашего хранителя:", "Сообщение")
	if(!input)
		return

	// Show the message to our guardian and to host.
	to_chat(guardian, span_changeling("<i>[owner]:</i> [input]"))
	to_chat(owner, span_changeling("<i>[owner]:</i> [input]"))
	add_say_logs(owner, input, guardian, "Guardian")

	// Show the message to any ghosts/dead players.
	for(var/mob/M in GLOB.dead_mob_list)
		if(M && M.client && M.stat == DEAD && !isnewplayer(M))
			to_chat(M, span_changeling("<i>Сообщение от хранителя <b>[owner]</b> ([ghost_follow_link(owner, ghost=M)]): [input]</i>"))

/**
 * # Recall guardian action
 *
 * Allows the guardian host to recall their guardian.
 */
/datum/action/guardian/recall
	name = "Отозвать Хранителя"
	desc = "Принудительно отозвать вашего хранителя."
	button_icon_state = "recall"

/datum/action/guardian/recall/Trigger(left_click = TRUE)
	guardian.Recall()

/**
 * # Reset guardian action
 *
 * Allows the guardian host to exchange their guardian's player for another.
 */
/datum/action/guardian/reset_guardian
	name = "Заменить Игрока-Хранителя"
	desc = "Замените игрока, управляющего вашим хранителем. Это можно сделать только один раз."
	button_icon_state = "reset"
	var/cooldown_timer

/datum/action/guardian/reset_guardian/IsAvailable()
	if(cooldown_timer)
		return FALSE
	return TRUE

/datum/action/guardian/reset_guardian/Trigger(left_click = TRUE)
	if(cooldown_timer)
		to_chat(owner, span_warning("Эта способность всё ещё перезаряжается."))
		return

	var/confirm = tgui_alert(owner, "Вы уверены, что хотите заменить вашего игрока-хранителя?", "Подтверждение", list("Да", "Нет"))
	if(confirm != "Да")
		return

	// Do this immediately, so the user can't spam a bunch of polls.
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 5 MINUTES)
	UpdateButtonIcon()

	to_chat(owner, span_danger("Поиск подходящего призрака..."))
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль [guardian.real_name]?", ROLE_GUARDIAN, FALSE, 15 SECONDS, source = guardian)

	if(!LAZYLEN(candidates))
		to_chat(owner, span_danger("Не нашлось призраков, готовых взять управление вашим хранителем. Попробуйте снова через 5 минут."))
		log_game("[owner](ckey: [owner.ckey]) has tried to replace their guardian, but there were no candidates willing to enroll.")
		return

	var/mob/dead/observer/new_stand = pick(candidates)
	to_chat(guardian, span_danger("Ваш хозяин сбросил вас, и ваше тело было захвачено призраком. Похоже, он был недоволен вашей работой."))
	to_chat(owner, span_danger("Ваш хранитель был успешно сброшен."))
	message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(guardian)])")

	guardian.ghostize()
	guardian.key = new_stand.key
	log_game("[guardian.key] has taken control of [guardian], owner: [guardian]")
	qdel(src)

/**
 * Takes the action button off cooldown and makes it available again.
 */
/datum/action/guardian/reset_guardian/proc/reset_cooldown()
	cooldown_timer = null
	UpdateButtonIcon()

/**
 * Grants all existing `/datum/action/guardian` type actions to the src mob.
 *
 * Called whenever the host gains their gauardian.
 */
/mob/living/proc/grant_guardian_actions(mob/living/simple_animal/hostile/guardian/G)
	if(!G || !istype(G))
		return
	for(var/action in subtypesof(/datum/action/guardian))
		var/datum/action/guardian/A = new action
		A.Grant(src, G)

/**
 * Removes all `/datum/action/guardian` type actions from the src mob.
 *
 * Called whenever the host loses their guardian.
 */
/mob/living/proc/remove_guardian_actions()
	for(var/action in actions)
		var/datum/action/A = action
		if(istype(A, /datum/action/guardian))
			A.Remove(src)
