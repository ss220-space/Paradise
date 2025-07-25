///Tracking reasons
/datum/antagonist/heretic_monster
	name = "Древний ужас"
	roundend_category = "Heretics"
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	//stinger_sound = 'sound/music/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master


/datum/antagonist/heretic_monster/on_removal()
	if(silent)
		master = null
		return ..()

	if(master?.current)
		to_chat(master.current, span_warning("Вы чувствуете как связь с [owner.current.declent_ru(NOMINATIVE)] - вашим слугой, постепенно рассеивается."))

	if(!owner.current)
		master = null
		return ..()

	to_chat(owner.current, span_warning("Ваш разум расслабляется. [master ? "[master.current.declent_ru(NOMINATIVE)] больше не властен над вами." : "у вас больше нет Мастера."]"))
	owner.current.visible_message(span_warning("Вы чувствуете что [owner.current.declent_ru(NOMINATIVE)] освободился от цепей Мансуса!"), ignored_mobs = owner.current)
	master = null
	return ..()


/*
 * Set our [master] var to a new mind.
 */
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	var/datum/objective/master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Ваш мастер - [master.current.real_name]. Помогайте ему во всем."
	master_obj.completed = TRUE

	objectives += master_obj
	owner.prepare_announce_objectives()
	to_chat(owner, span_boldnotice("Вы [ishuman(owner.current) ? "вернулись с того света": "ужасное создание пришедшее"] сюда через Врата Мансуса."))
	to_chat(owner, span_notice("[master.current.declent_ru(NOMINATIVE)] - ваш мастер. Помогайте ему во всем."))
