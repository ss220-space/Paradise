/datum/event/communications_blackout
	var/syndicate = FALSE


/datum/event/communications_blackout/announce(false_alarm)
	var/alert = syndicate ? "Обнаружено враждебное вмешательство в работу телекоммуникаций." : "Обнаружены ионосферные аномалии."

	var/alert_text = pick(list(
							"[alert] Неизбежен временный сбой связи. Пожалуйста, свяжитесь с вашим*%fj 00)`5 vc-БЗЗЗ",
							"[alert] Неизбежен временный сбо*3mga;b4;'1v?-БЗЗЗЗ",
							"[alert] Неизбежен време#MCi46:5.;@63-БЗЗЗЗЗ",
							"[copytext(alert, 1, 18)]'fZ\\kg5_0-БЗЗЗЗЗ",
							"[copytext(alert, 1, 7)]:%? MCayj^j<.3-БЗЗЗЗЗ",
							"#4nd%;f4y6,>?%-БЗЗЗЗЗЗЗ"
						))

	var/list/awared_ones = active_ais()
	for(var/mob/living/silicon/ai/AI as anything in awared_ones)	//AIs are always aware of communication blackouts.
		to_chat(AI, "<span class='ВНИМАНИЕ'><br><b>[alert_text]</b><br></span>")

	if(syndicate || false_alarm || prob(30))	//most of the time, we don't want an announcement, so as to allow AIs to fake blackouts.
		GLOB.event_announcement.Announce(alert_text)


/datum/event/communications_blackout/start()
	var/time = rand(1800, 3000)
	// This only affects the cores, relays should be unaffected imo
	for(var/obj/machinery/tcomms/core/T in GLOB.tcomms_machines)
		T.start_ion()
		// Bring it back sometime between 3-5 minutes. This uses deciseconds, so 1800 and 3000 respecticely.
		// The AI cannot disable this, it must be waited for
		addtimer(CALLBACK(T, TYPE_PROC_REF(/obj/machinery/tcomms, end_ion)), time)
	addtimer(CALLBACK(src, PROC_REF(toggle_monitors)), time)
	GLOB.communications_blackout = TRUE


/datum/event/communications_blackout/proc/toggle_monitors()
	GLOB.communications_blackout = FALSE
	return


/datum/event/communications_blackout/syndicate
	syndicate = TRUE
