/datum/antagonist/heretic_monster
	name = "Древний ужас"
	roundend_category = "Heretics"
	special_role = SPECIAL_ROLE_HERETIC_MONSTER
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	antag_hud_type = ANTAG_HUD_HERETIC
	//stinger_sound = 'sound/music/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master
	/// Our objective to serve our master.
	var/datum/objective/master_obj


/datum/antagonist/heretic_monster/add_antag_hud(mob/living/antag_mob)
	. = ..()
	offset_heretic_antag_hud(antag_mob)
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.show_to(antag_mob)

/datum/antagonist/heretic_monster/remove_antag_hud(mob/living/antag_mob)
	. = ..()
	offset_heretic_antag_hud(antag_mob, 0)


/datum/antagonist/heretic_monster/give_objectives()
	// Seed the objective immediately so "Your current objectives" never shows empty.
	// The master's name gets filled in by set_owner before we greet the monster.
	master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Служите своему мастеру."
	master_obj.completed = TRUE
	objectives += master_obj


/datum/antagonist/heretic_monster/on_gain()
	// Suppress the default greeting/objective announcement: the master's name is filled in by set_owner
	// (or a "free" monster's objective is added directly) right after add_antag_datum. So we defer the
	// greeting by one tick - by then all synchronous setup is done, and we show the final objective with
	// the master's name once, with no empty or intermediate popup.
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
	if(master && !master_has_other_creatures())
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


/datum/antagonist/heretic_monster/proc/master_has_other_creatures()
	for(var/datum/antagonist/heretic_monster/other as anything in GLOB.antagonists)
		if(other != src && other.master == master)
			return TRUE
	return FALSE


/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	var/datum/antagonist/heretic/master_heretic = master?.has_antag_datum(/datum/antagonist/heretic)
	master_heretic?.reveal_antag_hud()
	if(!master_obj)
		give_objectives()
	master_obj.explanation_text = "Ваш мастер — [master.current.real_name]. Помогайте ему во всём."
