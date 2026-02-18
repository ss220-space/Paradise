/mob/living/silicon/ai/Life(seconds, times_fired)
	//doesn't call parent because it's a horrible mess
	if(stat == DEAD)
		return

	var/turf/T = get_turf(src)
	if(stat != CONSCIOUS) //ai's fucked
		cameraFollow = null
		reset_perspective(null)
		unset_machine()

	updatehealth("life")
	if(stat == DEAD)
		return

	if(!eyeobj || QDELETED(eyeobj) || !eyeobj.loc)
		view_core()

	if(machine)
		machine.check_eye(src)

	if(malfhack?.aidisabled)
		to_chat(src, span_danger("ERROR: APC access disabled, hack attempt canceled."))
		deltimer(malfhacking)
		// This proc handles cleanup of screen notifications and
		// messenging the client
		malfhacked(malfhack)

	if(aiRestorePowerRoutine)
		adjustOxyLoss(1)
	else
		adjustOxyLoss(-1)

	var/area/my_area = get_area(src)

	if(!lacks_power())
		if(aiRestorePowerRoutine > POWER_RESTORATION_START)
			update_blind_effects()
			aiRestorePowerRoutine = POWER_RESTORATION_OFF
			update_sight()
			to_chat(src, "Alert cancelled. Power has been restored[aiRestorePowerRoutine == POWER_RESTORATION_SEARCH_APC ? "without our assistance" : ""].")
			send_ai_alarm(recover = TRUE)
	else
		if(lacks_power())
			if(!aiRestorePowerRoutine)
				update_blind_effects()
				aiRestorePowerRoutine = POWER_RESTORATION_START
				send_ai_alarm("Потеряно питание ИИ!")
				update_sight()
				to_chat(src, span_danger("You have lost power!"))

				if(!is_special_character(src))
					set_zeroth_law("")
					SSticker?.score?.save_silicon_laws(src, additional_info = "zero law was deleted due to power lost", log_all_laws = TRUE)

				spawn(20)
					to_chat(src, "Backup battery online. Scanners, camera, and radio interface offline. Beginning fault-detection.")
					sleep(50)
					my_area = get_area(src)
					T = get_turf(src)
					if(!lacks_power())
						to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
						aiRestorePowerRoutine = POWER_RESTORATION_OFF
						send_ai_alarm(recover = TRUE)
						update_blind_effects()
						update_sight()
						return
					to_chat(src, "Fault confirmed: missing external power. Shutting down main control system to save power.")
					sleep(20)
					to_chat(src, "Emergency control system online. Verifying connection to power network.")
					sleep(50)
					T = get_turf(src)
					if(isspaceturf(T))
						to_chat(src, "Unable to verify! No power connection detected!")
						aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
						return
					to_chat(src, "Connection verified. Searching for APC in power network.")
					sleep(50)

					my_area = get_area(src)
					T = get_turf(src)

					var/obj/machinery/power/apc/theAPC = null

					for(var/PRP in 1 to 4)
						for(var/obj/machinery/power/apc/APC in my_area)
							if(!(APC.stat & BROKEN))
								theAPC = APC
								break

						if(!theAPC)
							switch(PRP)
								if(1)
									to_chat(src, "Unable to locate APC!")
								else
									to_chat(src, "Lost connection with the APC!")
							aiRestorePowerRoutine = POWER_RESTORATION_SEARCH_APC
							return

						if(!lacks_power())
							to_chat(src, "Alert cancelled. Power has been restored without our assistance.")
							aiRestorePowerRoutine = POWER_RESTORATION_OFF
							send_ai_alarm(recover = TRUE)
							update_blind_effects()
							update_sight()
							to_chat(src, "Here are your current laws:")
							show_laws()
							return

						switch(PRP)
							if(1)
								to_chat(src, "APC located. Optimizing route to APC to avoid needless power waste.")
							if(2)
								to_chat(src, "Best route identified. Hacking offline APC power port.")
							if(3)
								to_chat(src, "Power port upload access confirmed. Loading control program into APC power port software.")
							if(4)
								to_chat(src, "Transfer complete. Forcing APC to execute program.")
								sleep(50)
								to_chat(src, "Receiving control information from APC.")
								sleep(2)
								//bring up APC dialog
								apc_override = TRUE
								theAPC.attack_ai(src)
								apc_override = FALSE
								aiRestorePowerRoutine = POWER_RESTORATION_APC_FOUND
						sleep(50)
						theAPC = null

/mob/living/silicon/ai/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	set_health(maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss())

	if(health <= maxHealth * 0.5 && health > 0)
		send_ai_alarm("Обнаружено критическое повреждение ИИ. Уровень целостности: [round((health / maxHealth) * 100)]%")

	update_stat("updatehealth([reason])", should_log)

/mob/living/silicon/ai/proc/lacks_power()
	var/turf/T = get_turf(src)
	var/area/A = get_area(src)
	return ((!A.power_equip) && A.requires_power == 1 || isspaceturf(T)) && !isitem(src.loc)

/mob/living/silicon/ai/rejuvenate()
	..()
	add_ai_verbs(src)

#define AI_MONITORING_SYSTEM "Система мониторинга ИИ"
#define AI_ALARM_COOLDOWN (1 MINUTES)

/mob/living/silicon/ai/proc/send_ai_alarm(reason = "Сообщите об этом в баг-репорт.", recover = FALSE)
	if(recover)
		send_ai_recover_alarm()
		return

	if(!COOLDOWN_FINISHED(src, ai_alarm_cooldown))
		return

	COOLDOWN_START(src, ai_alarm_cooldown, AI_ALARM_COOLDOWN)
	ai_recover_alarm_enabled = TRUE

	var/announcement = "Внимание! [reason] Требуется срочное вмешательство."
	send_ai_notification(announcement)

/mob/living/silicon/ai/proc/send_ai_recover_alarm()
	if(!ai_recover_alarm_enabled)
		return

	if(!COOLDOWN_FINISHED(src, ai_recover_alarm_cooldown))
		return

	COOLDOWN_START(src, ai_recover_alarm_cooldown, AI_ALARM_COOLDOWN)
	COOLDOWN_RESET(src, ai_alarm_cooldown)
	ai_recover_alarm_enabled = FALSE

	var/announcement = "Питание ИИ восстановлено."
	send_ai_notification(announcement)

/mob/living/silicon/ai/proc/send_ai_notification(message)
	var/obj/machinery/message_server/message_server = find_pda_server()
	if(!message_server)
		return

	radio_announce(message, AI_MONITORING_SYSTEM, COMM_FREQ, src)

	var/obj/item/pda/dummy_pda = new /obj/item/pda()
	dummy_pda.owner = AI_MONITORING_SYSTEM
	var/datum/data/pda/app/messenger/sender_messenger = dummy_pda.find_program(/datum/data/pda/app/messenger)

	if(!sender_messenger)
		qdel(dummy_pda)
		return

	for(var/obj/item/pda/pda as anything in GLOB.PDAs)
		if(!(pda.ownjob in GLOB.ai_death_alarm_jobs))
			continue

		var/datum/data/pda/app/messenger/messenger = pda.find_program(/datum/data/pda/app/messenger)
		if(!messenger?.can_receive())
			continue

		sender_messenger.create_message(pda, message = message)

	qdel(dummy_pda)

#undef AI_MONITORING_SYSTEM
#undef AI_ALARM_COOLDOWN
