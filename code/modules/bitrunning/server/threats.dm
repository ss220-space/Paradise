/obj/machinery/quantum_server/proc/add_threats(mob/living/threat)
	spawned_threat_refs += WEAKREF(threat)
	if(emagged)
		announce_jailbreak(threat)
	else
		threat.AddComponent(/datum/component/virtual_entity, src)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_THREAT_CREATED)

/obj/machinery/quantum_server/proc/announce_jailbreak(mob/living/threat)
	to_chat(threat, span_bolddanger("На мгновение вас пробирает дрожь от небывалой ясности."))
	to_chat(threat, span_notice("Вы могли бы пойти <i>куда угодно</i>. Даже покинуть эту симуляцию прямо сейчас."))
	to_chat(threat, span_danger("Но учтите: квантовая запутанность сотрёт всё, чем вы были раньше."))

/obj/machinery/quantum_server/proc/remove_threat(mob/living/threat)
	spawned_threat_refs -= WEAKREF(threat)

/obj/machinery/quantum_server/proc/station_spawn(mob/living/antag, obj/machinery/byteforge/chosen_forge)
	antag.balloon_alert(antag, "сканирование...")
	chosen_forge.setup_particles(TRUE)
	radio_announce("ТРЕВОГА КВАНТОВОГО СЕРВЕРА: обнаружен взлом периметра. Идёт несанкционированная последовательность входа...", "Квантовый сервер", SUP_FREQ, src)
	SEND_SIGNAL(src, COMSIG_BITRUNNER_STATION_SPAWN)

	var/timeout = 2 SECONDS
	if(!ishuman(antag))
		radio_announce("ТРЕВОГА КВАНТОВОГО СЕРВЕРА: протоколы сборки аварийно завершены. Покиньте помещение.", "Квантовый сервер", SUP_FREQ, src)
		timeout = 10 SECONDS

	var/bitrunners_alive = 0
	for(var/datum/weakref/connection_ref as anything in avatar_connection_refs)
		var/datum/component/avatar_connection/connection = connection_ref.resolve()
		var/mob/living/bitrunner = connection?.parent
		if(isnull(bitrunner) || bitrunner.stat > CONSCIOUS || !bitrunner.client)
			continue
		bitrunners_alive += 1
		timeout *= 5

	if(bitrunners_alive)
		to_chat(antag, span_warning("В домене всё ещё хозяйничают чужаки ([bitrunners_alive] шт.). Пока с ними не разберутся, выбраться будет тяжелее."))

	if(!do_after(antag, timeout) || QDELETED(chosen_forge) || QDELETED(antag) || QDELETED(src) || !is_ready || !is_operational())
		chosen_forge.setup_particles()
		return

	var/datum/component/glitch/effect = antag.AddComponent(/datum/component/glitch, src, chosen_forge)

	chosen_forge.charge_up()
	if(!do_after(antag, 1 SECONDS))
		chosen_forge.setup_particles()
		qdel(effect)
		return

	chosen_forge.flash()

	if(ishuman(antag))
		reset_equipment(antag)

	var/datum/antagonist/bitrunning_glitch/antag_datum = antag.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch)
	antag_datum?.show_in_roundend = TRUE

	qdel(antag.GetComponent(/datum/component/temporary_body))
	do_teleport(antag, get_turf(chosen_forge), asoundin = 'sound/effects/phasein.ogg', asoundout = 'sound/effects/phasein.ogg', bypass_area_flag = TRUE, ignore_blocking_traits = TRUE)

/obj/machinery/quantum_server/proc/collect_mutation_candidates()
	for(var/turf/tile as anything in domain_reservation.reserved_turfs)
		for(var/mob/living/creature in tile)
			if(creature.mind || ismegafauna(creature))
				continue
			mutation_candidate_refs |= WEAKREF(creature)

/obj/machinery/quantum_server/proc/get_mutation_target()
	while(length(mutation_candidate_refs))
		var/datum/weakref/candidate_ref = pick_n_take(mutation_candidate_refs)
		var/mob/living/candidate = candidate_ref.resolve()
		if(!QDELETED(candidate) && isnull(candidate.mind) && !ismegafauna(candidate))
			return candidate

/obj/machinery/quantum_server/proc/get_glitch_role()
	var/list/available = list()
	for(var/datum/antagonist/bitrunning_glitch/role as anything in subtypesof(/datum/antagonist/bitrunning_glitch))
		if(threat >= initial(role.threat))
			available += role

	if(!length(available))
		return

	var/datum/antagonist/bitrunning_glitch/chosen = pick(available)
	threat -= initial(chosen.threat) * 0.5
	return chosen

/proc/get_glitch_ready_servers()
	. = list()
	for(var/obj/machinery/quantum_server/server as anything in SSmachines.get_by_type(/obj/machinery/quantum_server))
		if(server.can_spawn_glitch())
			. += server

/obj/machinery/quantum_server/proc/can_spawn_glitch()
	if(isnull(generated_domain) || generated_domain.difficulty == BITRUNNER_DIFFICULTY_NONE || !is_operational())
		return FALSE

	for(var/datum/weakref/candidate_ref as anything in mutation_candidate_refs)
		var/mob/living/candidate = candidate_ref.resolve()
		if(!QDELETED(candidate) && isnull(candidate.mind) && !ismegafauna(candidate))
			return TRUE

	return FALSE

/obj/machinery/quantum_server/proc/setup_glitch(datum/antagonist/bitrunning_glitch/forced_role)
	var/mob/living/mutation_target = get_mutation_target()
	if(isnull(mutation_target))
		log_debug("vdom: [src] had no valid mutation target left for a glitch")
		return

	var/datum/antagonist/bitrunning_glitch/chosen_role = forced_role || get_glitch_role()
	if(isnull(chosen_role))
		log_debug("vdom: [src] had no glitch role available at threat [threat]")
		return

	mutation_target.AddComponent(/datum/component/digital_aura)

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates(
		question = "Хотите сыграть за сбой виртуального домена? Вы вернётесь в своё тело, когда домен выгрузят.",
		role = ROLE_GLITCH,
		poll_time = 20 SECONDS,
		source = mutation_target,
		role_cleanname = initial(chosen_role.antag_menu_name),
	)

	if(!length(candidates))
		qdel(mutation_target.GetComponent(/datum/component/digital_aura))
		log_debug("vdom: nobody signed up to play a glitch on [src]")
		return

	return spawn_glitch(chosen_role, mutation_target, pick(candidates))

/obj/machinery/quantum_server/proc/spawn_glitch(datum/antagonist/bitrunning_glitch/chosen_role, mob/living/mutation_target, mob/dead/observer/ghost)
	if(QDELETED(mutation_target))
		return

	if(QDELETED(src) || isnull(generated_domain) || !is_operational())
		qdel(mutation_target.GetComponent(/datum/component/digital_aura))
		return

	var/mob/living/glitch
	if(ispath(chosen_role, /datum/antagonist/bitrunning_glitch/netguardian))
		glitch = new /mob/living/basic/netguardian(mutation_target.loc)
	else
		var/mob/living/carbon/human/humanoid_glitch = new(mutation_target.loc)
		humanoid_glitch.faction = mutation_target.faction.Copy()
		humanoid_glitch.faction |= ROLE_GLITCH
		ghost.client?.prefs.copy_to(humanoid_glitch)
		humanoid_glitch.UpdateAppearance()
		glitch = humanoid_glitch

	mutation_target.gib()
	glitch.add_traits(list(TRAIT_TEMPORARY_BODY), INNATE_TRAIT)
	if(ghost.mind)
		glitch.AddComponent( \
			/datum/component/temporary_body, \
			old_mind = ghost.mind, \
			old_body = ghost.mind.current, \
			delete_on_death = TRUE, \
		)

	glitch.possess_by_player(ghost.key)
	if(isnull(glitch.mind))
		glitch.mind_initialize()

	glitch.mind.add_antag_datum(chosen_role)
	glitch.AddComponent(/datum/component/digital_aura)

	add_threats(glitch)
	playsound(glitch, 'sound/effects/phasein.ogg', 50, TRUE)
	message_admins("[key_name_admin(glitch)] was made into a bitrunning glitch at [ADMIN_JMP(src)].")
	return glitch

/obj/machinery/quantum_server/proc/has_awake_glitch()
	for(var/datum/weakref/threat_ref as anything in spawned_threat_refs)
		var/mob/living/threat = threat_ref.resolve()
		if(isnull(threat?.client) || threat.stat != CONSCIOUS)
			continue
		if(threat.mind?.has_antag_datum(/datum/antagonist/bitrunning_glitch))
			return TRUE

	return FALSE

/obj/machinery/quantum_server/proc/notify_spawned_threats()
	for(var/datum/weakref/threat_ref as anything in spawned_threat_refs)
		var/mob/living/spawned_threat = threat_ref.resolve()
		if(isnull(spawned_threat?.mind) || spawned_threat.stat >= UNCONSCIOUS)
			continue

		spawned_threat.throw_alert(ALERT_BITRUNNER_RESET, /atom/movable/screen/alert/bitrunning/reset)
		to_chat(spawned_threat, span_userdanger("Вас пометили на удаление. Спасибо за службу."))
