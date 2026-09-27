#define BASE_DISCONNECT_DAMAGE 25

/obj/machinery/netpod/proc/find_server()
	var/obj/machinery/quantum_server/server = server_ref?.resolve()
	if(server)
		return server

	server = locate(/obj/machinery/quantum_server) in oview(4, src)
	if(isnull(server))
		return

	server_ref = WEAKREF(server)
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_COMPLETE, PROC_REF(on_domain_complete))
	RegisterSignal(server, COMSIG_BITRUNNER_DOMAIN_SCRUBBED, PROC_REF(on_domain_scrubbed))

	return server

/obj/machinery/netpod/proc/enter_matrix()
	var/mob/living/carbon/human/pilot = occupant
	if(!ishuman(pilot) || pilot.stat == DEAD || isnull(pilot.mind))
		balloon_alert(pilot, "неподходящий пользователь")
		open_machine()
		return

	var/obj/machinery/quantum_server/server = find_server()
	if(isnull(server))
		balloon_alert(pilot, "сервер не подключён!")
		open_machine()
		return

	if(isnull(server.generated_domain) || !server.is_ready)
		balloon_alert(pilot, "домен не загружен!")
		open_machine()
		return

	balloon_alert(pilot, "устанавливаем соединение...")
	ADD_TRAIT(pilot, TRAIT_HANDS_BLOCKED, NETPOD_TRAIT)
	var/connection_established = do_after(pilot, 2 SECONDS, src)
	REMOVE_TRAIT(pilot, TRAIT_HANDS_BLOCKED, NETPOD_TRAIT)

	if(!connection_established)
		open_machine()
		return

	if(isnull(server.generated_domain) || !server.is_ready)
		balloon_alert(pilot, "домен не загружен!")
		open_machine()
		return

	var/mob/living/carbon/human/avatar = avatar_ref?.resolve()
	if(isnull(avatar) || avatar.stat != CONSCIOUS)
		avatar = server.start_new_connection(pilot, copy_body, netsuit)

	if(isnull(avatar))
		balloon_alert(pilot, "свободных выходов нет!")
		open_machine()
		return

	add_healing(pilot)

	if(!validate_entry(pilot, avatar))
		open_machine()
		return

	avatar_ref = WEAKREF(avatar)
	avatar.AddComponent(/datum/component/avatar_connection, pilot, server, src)

	connected = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/netpod/proc/add_healing(mob/living/carbon/target)
	if(target != occupant)
		return

	target.AddComponent(/datum/component/netpod_healing, src)
	target.playsound_local(get_turf(src), 'sound/effects/slosh.ogg', 20, TRUE)
	target.ExtinguishMob()

/obj/machinery/netpod/proc/validate_entry(mob/living/pilot, mob/living/avatar)
	if(QDELETED(pilot) || QDELETED(avatar) || QDELETED(src) || !is_operational())
		return FALSE

	if(occupant != pilot || isnull(pilot.mind) || pilot.stat != CONSCIOUS || avatar.stat == DEAD)
		return FALSE

	return TRUE

/obj/machinery/netpod/proc/sever_connection()
	if(isnull(occupant) || !connected)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_SEVER)

/obj/machinery/netpod/proc/disconnect_occupant(cause_damage = FALSE)
	connected = FALSE
	update_icon(UPDATE_ICON_STATE)

	var/mob/living/carbon/pilot = occupant
	if(isnull(pilot) || pilot.stat == DEAD)
		open_machine()
		return

	pilot.playsound_local(get_turf(src), 'sound/effects/phasein.ogg', 25, TRUE)
	pilot.EyeBlind(2 SECONDS)
	pilot.Weaken(2 SECONDS)

	if(!is_operational())
		open_machine()
		return

	var/heal_time = pilot.health < pilot.maxHealth ? 30 SECONDS : 2 SECONDS
	addtimer(CALLBACK(src, PROC_REF(auto_disconnect)), heal_time, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)

	if(!cause_damage)
		return

	var/obj/machinery/quantum_server/server = find_server()
	var/damage = BASE_DISCONNECT_DAMAGE * (1 - (server ? server.servo_bonus : 0))

	pilot.flash_eyes(visual = TRUE)
	pilot.adjust_organ_loss(INTERNAL_ORGAN_BRAIN, damage, BASE_DISCONNECT_DAMAGE)
	INVOKE_ASYNC(pilot, TYPE_PROC_REF(/mob/living, emote), "scream")
	to_chat(pilot, span_userdanger("Вас насильно отключили от аватара! Мысли путаются!"))

/obj/machinery/netpod/proc/auto_disconnect()
	if(isnull(occupant) || state_open || connected)
		return

	to_chat(occupant, span_notice("Капсула размыкает контакты и начинает откачивать раствор."))
	open_machine()

/obj/machinery/netpod/proc/on_integrity_changed(datum/source, old_value, new_value)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected || new_value >= old_value)
		return

	if(new_value > max_integrity * 0.5)
		return

	SEND_SIGNAL(src, COMSIG_BITRUNNER_NETPOD_INTEGRITY)

/obj/machinery/netpod/proc/on_domain_complete(datum/source, atom/movable/forge, reward_points)
	SIGNAL_HANDLER

	if(isnull(occupant) || !connected)
		return

	var/obj/item/card/id/card = occupant.get_id_card()
	if(isnull(card))
		return

	card.bitrunning_points += reward_points * BITRUNNER_POINTS_PER_REWARD

/obj/machinery/netpod/proc/on_domain_scrubbed(datum/source)
	SIGNAL_HANDLER

	var/mob/living/avatar = avatar_ref?.resolve()
	avatar_ref = null
	if(isnull(avatar))
		return

	qdel(avatar)

#undef BASE_DISCONNECT_DAMAGE
