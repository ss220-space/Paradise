///Tracking reasons
/datum/antagonist/heretic_monster
	name = "Древний ужас"
	roundend_category = "Heretics"
	special_role = SPECIAL_ROLE_HERETIC_MONSTER
	job_rank = ROLE_HERETIC
	antag_hud_name = "heretic_beast"
	//stinger_sound = 'sound/music/heretic/heretic_gain.ogg'
	/// Our master (a heretic)'s mind.
	var/datum/mind/master
	/// Our objective to serve our master.
	var/datum/objective/master_obj


/datum/antagonist/heretic_monster/give_objectives()
	// Создаём цель сразу, чтобы плашка "Your current objectives" не появлялась пустой.
	// Имя мастера проставится в set_owner ещё до того, как мы поприветствуем монстра.
	master_obj = new()
	master_obj.owner = owner
	master_obj.explanation_text = "Служите своему мастеру."
	master_obj.completed = TRUE
	objectives += master_obj


/datum/antagonist/heretic_monster/on_gain()
	// Глушим стандартное приветствие/объявление целей: имя мастера нам выдаёт set_owner (или объектив
	// "свободного" монстра добавляется напрямую) СРАЗУ после add_antag_datum. Поэтому откладываем
	// приветствие на один тик — к этому моменту вся синхронная донастройка готова, и мы один раз
	// показываем финальную цель с именем мастера, без пустой или промежуточной плашки.
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
	messages += span_userdanger("Вы [ishuman(owner.current) ? "вернулись с того света" : "ужасное создание, пришедшее"] сюда через Врата Мансуса!")
	if(master?.current)
		messages += span_boldnotice("[master.current.real_name] — ваш мастер. Помогайте ему во всём.")
	messages += owner.prepare_announce_objectives()
	to_chat(owner.current, custom_boxed_message("red_box center", messages.Join("<br>")))


/datum/antagonist/heretic_monster/handle_last_instance_removal()
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
	// Цель уже создана в give_objectives(); подставляем имя мастера. Приветствие с этой целью
	// покажет отложенный greet_monster() — set_owner всегда вызывается сразу после add_antag_datum.
	if(!master_obj)
		give_objectives()
	master_obj.explanation_text = "Ваш мастер — [master.current.real_name]. Помогайте ему во всём."
