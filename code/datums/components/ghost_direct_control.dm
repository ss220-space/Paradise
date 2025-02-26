/**
 * Component which lets ghosts click on a mob to take control of it
 */
/datum/component/ghost_direct_control
	/// Message to display upon successful possession
	var/assumed_control_message
	/// Type of ban you can get to prevent you from accepting this role
	var/ban_type
	/// Check Syndicate ban
	var/ban_syndicate
	/// Any extra checks which need to run before we take over
	var/datum/callback/extra_control_checks
	/// Callback run after someone successfully takes over the body
	var/datum/callback/after_assumed_control
	/// If we're currently awaiting the results of a ghost poll
	var/awaiting_ghosts = FALSE
	/// Aditional text of question
	var/question_text


/datum/component/ghost_direct_control/Initialize(
	ban_type = ROLE_SENTIENT,
	role_name = null,
	poll_question = null,
	poll_candidates = TRUE,
	antag_age_check = TRUE,
	check_antaghud = TRUE,
	poll_length = 10 SECONDS,
	ban_syndicate = FALSE,
	assumed_control_message = null,
	datum/callback/extra_control_checks,
	datum/callback/after_assumed_control,
	question_text,
)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/mob_parent = parent
	src.ban_type = ban_type
	src.ban_syndicate = ban_syndicate
	src.assumed_control_message = assumed_control_message || "Вы [mob_parent.declent_ru(NOMINATIVE)]!"
	src.extra_control_checks = extra_control_checks
	src.after_assumed_control = after_assumed_control
	src.question_text = question_text

	LAZYADD(GLOB.mob_spawners[format_text("[initial(mob_parent.name)]")], mob_parent)

	if(poll_candidates)
		INVOKE_ASYNC(src, PROC_REF(request_ghost_control), poll_question, role_name || "[parent]", poll_length, antag_age_check, check_antaghud)

/datum/component/ghost_direct_control/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_ghost_clicked))
	RegisterSignal(parent, COMSIG_LIVING_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(parent, COMSIG_IS_GHOST_CONTROLABLE, PROC_REF(on_ghost_controlable_check))

/datum/component/ghost_direct_control/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACK_GHOST, COMSIG_LIVING_EXAMINE, COMSIG_MOB_LOGIN))
	return ..()

/datum/component/ghost_direct_control/Destroy(force)
	extra_control_checks = null
	after_assumed_control = null

	var/mob/mob_parent = parent
	var/list/spawners = GLOB.mob_spawners[format_text("[initial(mob_parent.name)]")]
	LAZYREMOVE(spawners, mob_parent)
	if(!LAZYLEN(spawners))
		GLOB.mob_spawners -= format_text("[initial(mob_parent.name)]")
	return ..()

/// Inform ghosts that they can possess this
/datum/component/ghost_direct_control/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!isobserver(user))
		return
	var/mob/living/our_mob = parent
	if(our_mob.stat == DEAD || our_mob.key || awaiting_ghosts)
		return
	examine_text += span_boldnotice("Вы можете взять под контроль это существо, нажав на него.")

/// Send out a request for a brain
/datum/component/ghost_direct_control/proc/request_ghost_control(poll_question, role_name, poll_length, age_check, check_ahud)
	awaiting_ghosts = TRUE
	var/list/possible_ghosts = SSghost_spawns.poll_candidates(
		question = poll_question,
		role = ban_type,
		poll_time = poll_length,
		antag_age_check = age_check,
		check_antaghud = check_ahud,
		source = parent,
		role_cleanname = role_name
	)
	var/mob/chosen_one = (possible_ghosts.len)? pick(possible_ghosts): null
	awaiting_ghosts = FALSE
	if(isnull(chosen_one))
		return
	assume_direct_control(chosen_one)

/// A ghost clicked on us, they want to get in this body
/datum/component/ghost_direct_control/proc/on_ghost_clicked(mob/our_mob, mob/dead/observer/hopeful_ghost)
	SIGNAL_HANDLER
	if(our_mob.key)
		qdel(src)
		return
	if(!hopeful_ghost.client)
		return
	if(awaiting_ghosts)
		to_chat(hopeful_ghost, span_warning("В настоящее время идёт отбор кандидатов-призраков!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!SSticker.HasRoundStarted())
		to_chat(hopeful_ghost, span_warning("Вы не можете взять на себя управление этим существом до начала раунда!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	INVOKE_ASYNC(src, PROC_REF(attempt_possession), our_mob, hopeful_ghost)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// We got far enough to establish that this mob is a valid target, let's try to posssess it
/datum/component/ghost_direct_control/proc/attempt_possession(mob/our_mob, mob/dead/observer/hopeful_ghost)
	var/ghost_asked = tgui_alert(usr, "[question_text? question_text : "Стать [capitalize(our_mob.declent_ru(INSTRUMENTAL))]?"]", "Стать [capitalize(our_mob.declent_ru(INSTRUMENTAL))]?", list("Да", "Нет"))
	if(ghost_asked != "Да" || QDELETED(our_mob))
		return
	assume_direct_control(hopeful_ghost)

/// Grant possession of our mob, component is now no longer required
/datum/component/ghost_direct_control/proc/assume_direct_control(mob/harbinger)
	if(QDELETED(src))
		to_chat(harbinger, span_warning("Срок действия предложения о контроле над существом истёк!"))
		return
	if(jobban_isbanned(harbinger, ban_type) || (ban_syndicate && jobban_isbanned(harbinger, ROLE_SYNDICATE)))
		to_chat(harbinger, span_warning("Эта роль для вас заблокирована!"))
		return
	var/mob/living/new_body = parent
	if(new_body.stat == DEAD)
		to_chat(harbinger, span_warning("Это тело умерло, оно бесполезно!"))
		return
	if(new_body.key)
		to_chat(harbinger, span_warning("[capitalize(new_body.declent_ru(NOMINATIVE))] уже является разумным!"))
		qdel(src)
		return
	if(extra_control_checks && !extra_control_checks.Invoke(harbinger))
		return

	add_game_logs("took control of [new_body].", harbinger)
	// doesn't transfer mind because that transfers antag datum as well
	new_body.key = harbinger.key
	if(isanimal(new_body))
		var/mob/living/simple_animal/animal_body = new_body
		animal_body.toggle_ai(AI_OFF)
	// Already qdels due to below proc but just in case
	qdel(src)

/// When someone assumes control, get rid of our component
/datum/component/ghost_direct_control/proc/on_login(mob/harbinger)
	SIGNAL_HANDLER
	// This proc is called the very moment .key is set, so we need to force mind to initialize here if we want the invoke to affect the mind of the mob
	if(isnull(harbinger.mind))
		harbinger.mind_initialize()
	to_chat(harbinger, span_boldnotice(assumed_control_message))
	after_assumed_control?.Invoke(harbinger)
	qdel(src)


/datum/component/ghost_direct_control/proc/on_ghost_controlable_check(mob/user)
	SIGNAL_HANDLER
	return COMPONENT_GHOST_CONTROLABLE
