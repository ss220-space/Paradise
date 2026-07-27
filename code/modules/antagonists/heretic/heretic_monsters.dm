/datum/antagonist/heretic_monster
	name = "Древний ужас"
	roundend_category = "Heretics"
	special_role = SPECIAL_ROLE_HERETIC_MONSTER
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	antag_hud_type = ANTAG_HUD_HERETIC
	/// Our master (a heretic)'s mind.
	var/datum/mind/master
	/// Our objective to serve our master.
	var/datum/objective/master_obj


/datum/antagonist/heretic_monster/add_antag_hud(mob/living/antag_mob)
	. = ..()
	if(master && antag_mob.stat != DEAD)
		add_team_hud(antag_mob, /datum/atom_hud/alternate_appearance/basic/heretic_team, master)

/datum/antagonist/heretic_monster/remove_antag_hud(mob/living/antag_mob)
	. = ..()
	remove_team_hud()


/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	RegisterSignal(our_mob, COMSIG_MOB_DEATH, PROC_REF(on_monster_death))
	RegisterSignal(our_mob, COMSIG_LIVING_REVIVE, PROC_REF(on_monster_revive))


/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	UnregisterSignal(our_mob, list(COMSIG_MOB_DEATH, COMSIG_LIVING_REVIVE))


/datum/antagonist/heretic_monster/proc/on_monster_death(mob/living/source, gibbed)
	SIGNAL_HANDLER

	remove_team_hud()
	if(!master || master_has_living_creatures())
		return
	var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
	master_heretic?.hide_antag_hud()


/datum/antagonist/heretic_monster/proc/on_monster_revive(mob/living/source)
	SIGNAL_HANDLER

	if(!master)
		return
	add_team_hud(source, /datum/atom_hud/alternate_appearance/basic/heretic_team, master)
	var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
	master_heretic?.reveal_antag_hud()


/datum/antagonist/heretic_monster/give_objectives()
	master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Служите своему мастеру."
	master_obj.completed = TRUE
	objectives += master_obj


/datum/antagonist/heretic_monster/on_gain()
	silent = TRUE
	. = ..()
	silent = initial(silent)
	addtimer(CALLBACK(src, PROC_REF(greet_monster)), 1)


/// Single greeting box, fired one tick after on_gain so the master (set in set_owner) is already known.
/datum/antagonist/heretic_monster/proc/greet_monster()
	if(!owner?.current)
		return
	SEND_SOUND(owner.current, sound('sound/music/heretic/heretic_gain.ogg'))
	var/list/messages = list()
	messages += span_userdanger("Вы [ishuman(owner.current) ? "вернулись с того света" : "ужасное создание, пришедшее"] сюда через Врата Обители!")
	if(master?.current)
		messages += span_boldnotice("[master.current.real_name] — ваш мастер. Помогайте ему во всём.")
	messages += owner.prepare_announce_objectives()
	to_chat(owner.current, custom_boxed_message("red_box center", messages.Join("<br>")))


/datum/antagonist/heretic_monster/handle_last_instance_removal()
	if(master && !master_has_living_creatures())
		var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
		master_heretic?.hide_antag_hud()

	if(silent)
		master = null
		return ..()

	if(master?.current)
		to_chat(master.current, span_warning("Вы чувствуете, как связь с [owner.current.declent_ru(INSTRUMENTAL)], вашим слугой, постепенно рассеивается."))

	if(!owner.current)
		master = null
		return ..()

	to_chat(owner.current, span_warning("Ваш разум расслабляется. [master ? "[DECLENT_RU_CAP(master.current, NOMINATIVE)] больше не властен над вами." : "У вас больше нет Мастера."]"))
	owner.current.visible_message(span_warning("Вы чувствуете, что [owner.current.declent_ru(NOMINATIVE)] освободил[GEND_SYA_AS_OS_IS(owner.current)] от цепей Обители!"), ignored_mobs = owner.current)
	master = null
	return ..()


/datum/antagonist/heretic_monster/proc/master_has_living_creatures()
	for(var/datum/antagonist/heretic_monster/other in GLOB.antagonists)
		if(other == src || other.master != master)
			continue
		var/mob/living/other_mob = other.owner?.current
		if(!QDELETED(other_mob) && other_mob.stat != DEAD)
			return TRUE
	return FALSE


/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	var/datum/antagonist/heretic/master_heretic = master?.has_antag_datum(/datum/antagonist/heretic)
	master_heretic?.reveal_antag_hud()
	if(master && !QDELETED(owner?.current))
		add_team_hud(owner.current, /datum/atom_hud/alternate_appearance/basic/heretic_team, master)
	if(!master_obj)
		give_objectives()
	master_obj.explanation_text = "Ваш мастер — [master.current.real_name]. Помогайте ему во всём."
