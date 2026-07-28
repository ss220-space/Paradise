/datum/martial_art/force
	name = "Force Arts"
	weight = 11
	has_explaination_verb = TRUE
	grab_resist_chances = list(
		MARTIAL_GRAB_AGGRESSIVE = 20,
		MARTIAL_GRAB_NECK = 10,
		MARTIAL_GRAB_KILL = 5,
	)

	combos = list(
		/datum/martial_combo/force/force_push,
	)

	/// Keeps a recaller mob
	var/mob/living/recall_mob
	/// Keeps a recalled esword
	var/obj/item/bound_esword
	/// Keeps recall esword action
	var/datum/action/innate/force_esword_pull/esword_pull_action
	/// Keeps force grab victim
	var/mob/living/force_grab_target

	COOLDOWN_DECLARE(force_lightning)
	COOLDOWN_DECLARE(force_grab)

/datum/martial_art/force/teach(mob/living/carbon/human/user, make_temporary = FALSE)
	. = ..()

	if(!.)
		return

	RegisterSignal(user, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_ranged_secondary_attack))
	RegisterSignal(user, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_mob_item_attack))
	RegisterSignal(user, COMSIG_LIVING_START_PULL, PROC_REF(on_start_pull))
	RegisterSignal(user, COMSIG_ATOM_NO_LONGER_PULLING, PROC_REF(on_no_longer_pulling))

	esword_pull_action = new(src)
	esword_pull_action.Grant(user)
	ADD_TRAIT(user, TRAIT_TELEKINESIS, UNIQUE_TRAIT_SOURCE(src))

	to_chat(user, span_notice("Вы чувствуете странное спокойствие. Вы постигли Путь Силы."))

/datum/martial_art/force/remove(mob/living/carbon/human/user)
	if(!user)
		return .

	clear_force_grab()
	unbind_esword()
	esword_pull_action.Remove()
	REMOVE_TRAIT(user, TRAIT_TELEKINESIS, UNIQUE_TRAIT_SOURCE(src))

	UnregisterSignal(user, list(
		COMSIG_MOB_ATTACK_RANGED_SECONDARY,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_LIVING_START_PULL,
		COMSIG_ATOM_NO_LONGER_PULLING
	))

	. = ..()

/datum/martial_art/force/explaination_header(user)
	to_chat(user, "<b><i>Вы сосредотачиваетесь и чувствуете, как Сила течет сквозь вас...</i></b>")

/datum/martial_art/force/explaination_combos(user)
	. = ..()
	// We divide cooldown by 10 because it is counted in seconds already.
	to_chat(user, "[span_notice("Силовой захват")]: в режиме [span_yellow("Grab")] нажмите правой кнопкой мыши на жертву в пределах [FORCE_GRAB_MAX_DISTANCE] тайл[DECL_CREDIT(FORCE_GRAB_MAX_DISTANCE)], чтобы схватить её на расстоянии. Перезарядка [FORCE_GRAB_COOLDOWN / 10] секунд[DECL_SEC_MIN(FORCE_GRAB_COOLDOWN / 10)].")
	to_chat(user, "[span_notice("Силовая молния")]: в режиме [span_blue("Disarm")] нажмите правой кнопкой мыши на жертву в пределах [FORCE_LIGHTNING_MAX_DISTANCE] тайл[DECL_CREDIT(FORCE_LIGHTNING_MAX_DISTANCE)], чтобы поразить её молнией. Перезарядка: [FORCE_LIGHTNING_COOLDOWN / 10] секунд[DECL_SEC_MIN(FORCE_LIGHTNING_COOLDOWN / 10)].")
	to_chat(user, "[span_notice("Силовой бросок")]: в режиме броска нажмите левой кнопкой мыши на жертву, чтобы с [FORCE_THROW_DROPLIMB_CHANCE]% шансом отрубить ей конечность.")
	to_chat(user, "[span_notice("Призыв меча")]: нажмите на способность, чтобы привязать или призвать энергетический меч.")
	to_chat(user, "[span_notice("Телекинез")]: нажмите на предмет, чтобы удалённо управлять им.")

/datum/martial_art/force/explaination_footer(user)
	to_chat(user, "<b><i>Используйте свои способности с умом.</i></b>")

/datum/martial_art/force/explaination_notice(user)
	return

/datum/martial_art/force/get_resist_chance(grab_state, mob/living/victim)
	if(!grab_resist_chances || !HAS_TRAIT(victim, TRAIT_FORCE_GRASPED))
		return null
	switch(grab_state)
		if(GRAB_AGGRESSIVE)
			if(!isnull(grab_resist_chances[MARTIAL_GRAB_AGGRESSIVE]))	// can be 0 its a vaild number
				return grab_resist_chances[MARTIAL_GRAB_AGGRESSIVE]
		if(GRAB_NECK)
			if(!isnull(grab_resist_chances[MARTIAL_GRAB_NECK]))
				return grab_resist_chances[MARTIAL_GRAB_NECK]
		if(GRAB_KILL)
			if(!isnull(grab_resist_chances[MARTIAL_GRAB_KILL]))
				return grab_resist_chances[MARTIAL_GRAB_KILL]

/*//////////////////////
// MARK: COMBO WITH ITEM
*///////////////////////

/datum/martial_art/force/proc/on_mob_item_attack(mob/living/source, mob/living/target, list/modifiers, def_zone)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!user || !target || user.mind?.martial_art != src)
		return

	INVOKE_ASYNC(src, PROC_REF(handle_combo_async), user, target, user.a_intent)

/datum/martial_art/force/proc/handle_combo_async(mob/living/carbon/human/attacker, mob/living/defender, intent)
	if(intent == INTENT_HARM)
		harm_act(attacker, defender)
	else if(intent == INTENT_GRAB)
		grab_act(attacker, defender)
	else if(intent == INTENT_DISARM)
		disarm_act(attacker, defender)
	else
		help_act(attacker, defender)

/*//////////////////////
// MARK: DATUM ACTION
*///////////////////////

/datum/action/innate/force_esword_pull
	name = "Призыв меча"
	desc = "Привязывает к вам одиночный либо двойной энергетический меч, позволяя призывать его в руку."
	button_icon_state = "summons"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_HANDS_BLOCKED

/datum/action/innate/force_esword_pull/Activate()
	var/mob/living/carbon/human/user = owner
	var/datum/martial_art/force/force_art = target
	if(!user || !force_art)
		return

	var/obj/item/held = user.get_active_hand()
	if((is_esword(held) || is_dualsaber(held)) && held != force_art.bound_esword)
		force_art.bind_esword(held, user)
		return

	force_art.try_force_recall(user)

/datum/action/innate/force_esword_pull/Remove(mob/removed_from)
	var/datum/martial_art/force/force_art = target
	force_art.recall_mob = null
	return ..()

/*//////////////////////
// MARK: FORCE RECALL
*///////////////////////

/datum/martial_art/force/proc/bind_esword(obj/item/item, mob/living/carbon/human/user)
	if(!item || !user)
		return FALSE
	if(!(is_esword(item) || is_dualsaber(item)))
		return FALSE

	unbind_esword()
	bound_esword = item
	RegisterSignal(bound_esword, COMSIG_QDELETING, PROC_REF(qdel_esword))
	RegisterSignal(bound_esword, COMSIG_ITEM_RECALL, PROC_REF(on_recall))
	RegisterSignal(bound_esword, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	to_chat(user, span_notice("Вы связываете [bound_esword] с вашей волей."))

/datum/martial_art/force/proc/qdel_esword(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ITEM_RECALL, COMSIG_MOVABLE_IMPACT))
	unbind_esword()

/datum/martial_art/force/proc/on_recall(obj/item/esword, mob/living/user)
	SIGNAL_HANDLER
	if(esword.loc == user || esword.loc == user.loc)
		user.put_in_active_hand(esword)
		return

	recall_mob = user
	var/distance = get_dist(user, esword)
	esword.throw_at(user, distance + 1, esword.throw_speed, user)

/datum/martial_art/force/proc/on_impact(obj/item/esword, atom/hit_atom)
	SIGNAL_HANDLER
	if(!recall_mob || !hit_atom)
		return

	var/mob/living/carbon/human/human = recall_mob
	human.put_in_active_hand(esword)
	recall_mob = null

/datum/martial_art/force/proc/unbind_esword()
	if(bound_esword)
		UnregisterSignal(bound_esword, COMSIG_QDELETING)
	bound_esword = null

/datum/martial_art/force/proc/try_force_recall(mob/living/carbon/human/user)
	if(!user)
		return

	if(!bound_esword || QDELETED(bound_esword))
		to_chat(user, span_warning("Вы не ощущаете присутствие вашего оружия."))
		return

	if(bound_esword in user)
		return

	if(ismob(bound_esword.loc))
		var/mob/holder = bound_esword.loc
		if(!holder.drop_item_ground(bound_esword, force = TRUE))
			bound_esword.forceMove(get_turf(bound_esword))
	else if(!isturf(bound_esword.loc))
		bound_esword.forceMove(get_turf(bound_esword))

	if(!(bound_esword in view(user)))
		return

	SEND_SIGNAL(bound_esword, COMSIG_ITEM_RECALL, user)

/*//////////////////////
// MARK: RANGED SECONDARY
*///////////////////////

/datum/martial_art/force/proc/on_ranged_secondary_attack(mob/living/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!user || user.mind?.martial_art != src || !target || !isliving(target) || target == user || user.z != target.z)
		return

	/*//////////////////////
	// MARK: FORCE LIGHTNING
	*///////////////////////

	if(user.a_intent == INTENT_DISARM)
		if(get_dist(user, target) > FORCE_LIGHTNING_MAX_DISTANCE)
			user.balloon_alert(user, "далеко!")
			return

		if(!COOLDOWN_FINISHED(src, force_lightning))
			user.balloon_alert(user, "не готово!")
			return

		var/turf/target_turf = get_turf(target)
		if(!target_turf)
			return

		user.Beam(target, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 1 SECONDS)
		playsound(get_turf(user), 'sound/magic/lightningbolt.ogg', 50, TRUE, -1)
		COOLDOWN_START(src, force_lightning, FORCE_LIGHTNING_COOLDOWN)

		var/mob/living/primary_mob = target
		var/list/turfs = get_line(user, target_turf)
		for(var/turf/turf as anything in turfs)
			for(var/mob/living/turf_mob in turf)
				if(turf_mob == user || turf_mob == primary_mob)
					continue
				turf_mob.electrocute_act(FORCE_LIGHTNING_CHAIN_POWER, user, flags = SHOCK_NOSTUN)
				add_attack_logs(user, turf_mob, "Attacked with martial-art [src] : force lightning chain", ATKLOG_ALL)

		primary_mob.electrocute_act(FORCE_LIGHTNING_PRIMARY_POWER, user, flags = SHOCK_NOGLOVES, stun_duration = FORCE_LIGHTNING_STUN_DURATION)
		add_attack_logs(user, primary_mob, "Attacked with martial-art [src] : force lightning", ATKLOG_ALL)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	/*//////////////////////
	// MARK: FORCE GRAB
	*///////////////////////

	if(user.a_intent == INTENT_GRAB)
		if(get_dist(user, target) > FORCE_GRAB_MAX_DISTANCE)
			user.balloon_alert(user, "далеко!")
			return

		if(!COOLDOWN_FINISHED(src, force_grab))
			user.balloon_alert(user, "не готово!")
			return

		INVOKE_ASYNC(src, PROC_REF(try_force_grab), user, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/martial_art/force/proc/try_force_grab(mob/living/carbon/human/user, mob/living/victim)
	if(QDELETED(user) || QDELETED(victim))
		return

	if(!victim.grabbedby(user, supress_message = TRUE))
		return

	if(!victim.grippedby(user, grab_state_override = GRAB_AGGRESSIVE))
		return

	set_force_grab_target(user, victim)
	COOLDOWN_START(src, force_grab, FORCE_GRAB_COOLDOWN)
	playsound(user, 'sound/magic/force_choke.ogg', 50, TRUE)

	user.visible_message(
		span_warning("[user] взмахивает рукой, и [victim] оказывается захвачен невидимой силой!"),
		span_notice("Вы захватываете [victim] Силой!")
	)

/datum/martial_art/force/proc/set_force_grab_target(mob/living/carbon/human/user, mob/living/victim)
	if(!user || !victim)
		return

	clear_force_grab()
	force_grab_target = victim

	ADD_TRAIT(victim, TRAIT_FORCE_GRASPED, UNIQUE_TRAIT_SOURCE(src))
	ADD_TRAIT(victim, TRAIT_MOVE_FLYING, UNIQUE_TRAIT_SOURCE(src))

	RegisterSignal(victim, COMSIG_LIVING_LIFE, PROC_REF(on_force_grabbed_life))
	RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(on_force_grabbed_qdeleting))

/datum/martial_art/force/proc/clear_force_grab()
	if(!force_grab_target)
		return

	var/mob/living/target = force_grab_target
	UnregisterSignal(target, list(COMSIG_LIVING_LIFE, COMSIG_QDELETING))
	REMOVE_TRAIT(target, TRAIT_FORCE_GRASPED, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(target, TRAIT_MOVE_FLYING, UNIQUE_TRAIT_SOURCE(src))

	force_grab_target = null

/datum/martial_art/force/proc/on_force_grabbed_life(mob/living/source, seconds, times_fired)
	SIGNAL_HANDLER
	if(!source || source != force_grab_target || !source.pulledby)
		clear_force_grab()
		return

/datum/martial_art/force/proc/on_force_grabbed_qdeleting(mob/living/source)
	SIGNAL_HANDLER
	if(source == force_grab_target)
		clear_force_grab()

/datum/martial_art/force/proc/on_start_pull(mob/living/source, atom/movable/pulled, state, force)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/user = source
	if(!user || user.mind?.martial_art != src)
		return

/datum/martial_art/force/proc/on_no_longer_pulling(mob/living/source, atom/movable/old_pulling)
	SIGNAL_HANDLER
	if(isliving(old_pulling) && old_pulling == force_grab_target)
		clear_force_grab()
