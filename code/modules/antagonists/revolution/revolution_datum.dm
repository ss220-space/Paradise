/datum/antagonist/rev
	name = "Revolutionary"
	roundend_category = "Революционерами"
	show_in_roundend = FALSE
	job_rank = ROLE_REV
	special_role = SPECIAL_ROLE_REV
	antag_hud_type = ANTAG_HUD_REV
	antag_menu_name = "Революционер"
	clown_gain_text = "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
	clown_removal_text = "You lose your training and return to your own clumsy, clownish self."
	stinger_sound = 'sound/ambience/antag/revolutionary_tide.ogg'
	default_team_type = /datum/team/revolution
	var/can_be_deconverted = FALSE

/datum/antagonist/rev/can_be_owned(datum/mind/new_owner)
	var/datum/mind/tested = new_owner || owner
	if(tested in SSticker.mode.get_living_heads())
		return FALSE
	return ..()

/datum/antagonist/rev/give_objectives()
	add_objective(/datum/objective/revolution)

/datum/antagonist/rev/farewell()
	if(owner?.current && !silent)
		to_chat(owner.current, span_danger(span_fontsize3("<b>Вам промыли мозги! Вы больше не революционер!</b>")))

/datum/antagonist/rev/proc/switch_tier(new_tier)
	if(type == new_tier)
		return
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(type)
	old_owner.add_antag_datum(new_tier)


/datum/antagonist/rev/volunteer
	antag_hud_name = "hudrevolutionary"
	antag_menu_name = "Доброволец революции"

/datum/antagonist/rev/volunteer/greet()
	return span_danger(span_fontsize3("Вы добровольно примкнули к революции! Выполняйте приказы её лидеров и не вредите соратникам. \
		Товарищей вы опознаете по красным значкам, лидеров — по золотым. Синдикат не оставит вас без поддержки."))


/datum/antagonist/rev/slave
	antag_hud_name = "hudrevolutionaryslave"
	antag_menu_name = "Раб революции"
	can_be_deconverted = TRUE
	var/helplessness_timer

/datum/antagonist/rev/slave/greet()
	return span_danger(span_fontsize3("Ваш разум сломлен. Вы беспрекословно подчиняетесь главам революции — только их вы и способны узнать. \
		Страха вы больше не знаете."))

/datum/antagonist/rev/slave/on_gain()
	. = ..()
	helplessness_timer = addtimer(CALLBACK(src, PROC_REF(check_helplessness)), SLAVE_HELPLESS_DECONVERSION_INTERVAL, TIMER_LOOP | TIMER_STOPPABLE)

/datum/antagonist/rev/slave/Destroy(force)
	if(helplessness_timer)
		deltimer(helplessness_timer)
		helplessness_timer = null
	return ..()

/datum/antagonist/rev/slave/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_death))
	return user

/datum/antagonist/rev/slave/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	UnregisterSignal(user, COMSIG_MOB_DEATH)
	return user

/datum/antagonist/rev/slave/proc/on_death()
	SIGNAL_HANDLER
	if(prob(SLAVE_DEATH_DECONVERSION_CHANCE))
		INVOKE_ASYNC(SSticker.mode, TYPE_PROC_REF(/datum/game_mode, remove_revolutionary), owner)

/datum/antagonist/rev/slave/proc/check_helplessness()
	var/mob/living/slave = owner?.current
	if(!istype(slave) || slave.stat == DEAD)
		return
	if(slave.health >= 0 && !slave.IsSleeping())
		return
	if(prob(SLAVE_HELPLESS_DECONVERSION_CHANCE))
		SSticker.mode.remove_revolutionary(owner)

/datum/antagonist/rev/slave/add_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/rev_hud = GLOB.huds[ANTAG_HUD_REV]
	rev_hud.add_atom_to_hud(antag_mob)
	set_antag_hud(antag_mob, antag_hud_name)
	var/datum/atom_hud/antag/slave_hud = GLOB.huds[ANTAG_HUD_REV_SLAVE]
	slave_hud.show_to(antag_mob)

/datum/antagonist/rev/slave/remove_antag_hud(mob/living/antag_mob)
	var/datum/atom_hud/antag/rev_hud = GLOB.huds[ANTAG_HUD_REV]
	rev_hud.remove_atom_from_hud(antag_mob)
	set_antag_hud(antag_mob, null)
	var/datum/atom_hud/antag/slave_hud = GLOB.huds[ANTAG_HUD_REV_SLAVE]
	slave_hud.hide_from(antag_mob)


/datum/antagonist/rev/head
	name = "Head Revolutionary"
	special_role = SPECIAL_ROLE_HEAD_REV
	antag_hud_name = "hudheadrevolutionary"
	antag_menu_name = "Глава революции"

/datum/antagonist/rev/head/greet()
	return span_danger("Вы состоите в руководстве революции!")

/datum/antagonist/rev/head/add_antag_hud(mob/living/antag_mob)
	..()
	var/datum/atom_hud/antag/slave_hud = GLOB.huds[ANTAG_HUD_REV_SLAVE]
	slave_hud.add_atom_to_hud(antag_mob)

/datum/antagonist/rev/head/remove_antag_hud(mob/living/antag_mob)
	..()
	var/datum/atom_hud/antag/slave_hud = GLOB.huds[ANTAG_HUD_REV_SLAVE]
	slave_hud.remove_atom_from_hud(antag_mob)

/datum/antagonist/rev/head/finalize_antag()
	. = ..()
	SSticker.mode.equip_revolutionary(owner.current)

/proc/is_revolutionary(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/rev)

/proc/is_head_revolutionary(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/rev/head)

/proc/is_revolution_slave(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/rev/slave)
