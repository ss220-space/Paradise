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


/datum/antagonist/heretic_monster/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	// Mutual team markers with our master (see the heretic datum's apply_innate_effects). Datum-based
	// rather than trait-based so a monster shapeshifted into a mundane animal still counts.
	add_team_hud(our_mob, list(/datum/antagonist/heretic, /datum/antagonist/heretic_monster))
	// A ghost possesses the summon (key set) before it gets this datum, so its client attaches before the
	// markers exist - re-apply them on login so it actually sees its master, and again after any relog.
	RegisterSignal(our_mob, COMSIG_MOB_LOGIN, PROC_REF(on_login), override = TRUE)


/datum/antagonist/heretic_monster/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/our_mob = mob_override || owner.current
	UnregisterSignal(our_mob, COMSIG_MOB_LOGIN)
	our_mob.remove_alt_appearance("antag_team_hud_[our_mob.UID()]")


/datum/antagonist/heretic_monster/proc/on_login(mob/living/source)
	SIGNAL_HANDLER
	if(QDELETED(source) || owner?.current != source)
		return
	add_team_hud(source, list(/datum/antagonist/heretic, /datum/antagonist/heretic_monster))


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
	// We're already off GLOB.antagonists by now, so if no sibling remains the master loses their last
	// servant and their team marker hides again (mirror of set_owner revealing it).
	if(master && !master_has_other_creatures())
		var/datum/antagonist/heretic/master_heretic = master.has_antag_datum(/datum/antagonist/heretic)
		master_heretic?.hide_team_hud()

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


/// Whether our master still commands another creature besides us.
/datum/antagonist/heretic_monster/proc/master_has_other_creatures()
	for(var/datum/antagonist/heretic_monster/other as anything in GLOB.antagonists)
		if(other != src && other.master == master)
			return TRUE
	return FALSE


/// Set our [master] var to a new mind.
/datum/antagonist/heretic_monster/proc/set_owner(datum/mind/master)
	src.master = master
	// Being bound to a master is what reveals the master heretic's own team marker (they stay unmarked
	// until they summon their first creature). Our marker is already up from apply_innate_effects.
	var/datum/antagonist/heretic/master_heretic = master?.has_antag_datum(/datum/antagonist/heretic)
	master_heretic?.reveal_team_hud()
	// The objective was already created in give_objectives(); fill in the master's name. The deferred
	// greet_monster() will show it - set_owner is always called right after add_antag_datum.
	if(!master_obj)
		give_objectives()
	master_obj.explanation_text = "Ваш мастер — [master.current.real_name]. Помогайте ему во всём."
