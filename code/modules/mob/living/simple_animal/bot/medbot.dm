//Medbot
/mob/living/simple_animal/bot/medbot
	name = "\improper Medibot"
	desc = "A little medical robot. He looks somewhat underwhelmed."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "medibot0"
	density = FALSE
	anchored = FALSE
	health = 20
	maxHealth = 20
	pass_flags = PASSMOB|PASSFLAPS

	radio_channel = "Medical"

	bot_type = MED_BOT
	bot_filter = RADIO_MEDBOT
	model = "Medibot"
	bot_purpose = "seek out hurt crewmembers and ensure that they are healed"
	bot_core_type = /obj/machinery/bot_core/medbot
	window_id = "automed"
	window_name = "Automatic Medical Unit v1.1"
	path_image_color = "#DDDDFF"
	data_hud_type = DATA_HUD_MEDICAL_ADVANCED

	/// Can be set to draw from this for reagents.
	var/obj/item/reagent_containers/glass/reagent_glass = null
	/// Set to "tox", "ointment" or "o2" for the other two firstaid kits.
	var/skin = null
	var/mob/living/carbon/patient = null
	var/mob/living/carbon/oldpatient = null
	var/oldloc = null
	var/last_found = 0
	var/last_warning = 0
	/// Don't spam the "HEY I'M COMING" messages
	var/last_newpatient_speak = 0
	/// How much reagent do we inject at a time?
	var/injection_amount = 15
	/// Start healing when they have this much damage in a category
	var/heal_threshold = 10
	/// Use reagents in beaker instead of default treatment agents.
	var/use_beaker = FALSE
	/// If active, the bot will transmit a critical patient alert to MedHUD users.
	var/declare_crit = TRUE
	/// Prevents spam of critical patient alerts.
	var/declare_cooldown = FALSE
	/// If enabled, the Medibot will not move automatically.
	var/stationary_mode = FALSE
	///Setting which reagents to use to treat what by default. By id.
	var/treatment_brute = "salglu_solution"
	var/treatment_oxy = "salbutamol"
	var/treatment_fire = "salglu_solution"
	var/treatment_tox = "charcoal"
	var/treatment_virus = "spaceacillin"
	/// If on, the bot will attempt to treat viral infections, curing them if possible.
	var/treat_virus = TRUE
	/// Self explanatory :)
	var/shut_up = FALSE
	/// Will it only treat operatives?
	var/syndicate_aligned = FALSE
	var/drops_parts = TRUE

/mob/living/simple_animal/bot/medbot/tox
	skin = "tox"

/mob/living/simple_animal/bot/medbot/o2
	skin = "o2"

/mob/living/simple_animal/bot/medbot/brute
	skin = "brute"

/mob/living/simple_animal/bot/medbot/fire
	skin = "ointment"

/mob/living/simple_animal/bot/medbot/adv
	skin = "adv"

/mob/living/simple_animal/bot/medbot/fish
	skin = "fish"

/mob/living/simple_animal/bot/medbot/machine
	skin = "machine"

/mob/living/simple_animal/bot/medbot/paramed
	skin = "paramed"

/mob/living/simple_animal/bot/medbot/mysterious
	name = "\improper Mysterious Medibot"
	desc = "International Medibot of mystery."
	skin = "bezerk"
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"

/mob/living/simple_animal/bot/medbot/syndicate
	name = "Suspicious Medibot"
	desc = "You'd better have insurance!"
	skin = "bezerk"
	faction = list("syndicate")
	treatment_oxy = "perfluorodecalin"
	treatment_brute = "bicaridine"
	treatment_fire = "kelotane"
	treatment_tox = "charcoal"
	syndicate_aligned = TRUE
	bot_core_type = /obj/machinery/bot_core/medbot/syndicate
	control_freq = BOT_FREQ + 1000 // make it not show up on lists
	radio_channel = "Syndicate"
	radio_config = list("Common" = 1, "Medical" = 1, "Syndicate" = 1)


/mob/living/simple_animal/bot/medbot/syndicate/Initialize(mapload, new_skin)
	. = ..()
	Radio.syndiekey = new /obj/item/encryptionkey/syndicate


/mob/living/simple_animal/bot/medbot/syndicate/emagged
	emagged = 2
	declare_crit = FALSE
	drops_parts = FALSE


/mob/living/simple_animal/bot/medbot/update_icon_state()
	if(!on)
		icon_state = "medibot0"
		return
	if(mode == BOT_HEALING)
		icon_state = "medibots[stationary_mode]"
		return
	else if(stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "medibot2"
	else
		icon_state = "medibot1"


/mob/living/simple_animal/bot/medbot/update_overlays()
	. = ..()
	if(skin)
		. += "medskin_[skin]"


/mob/living/simple_animal/bot/medbot/Initialize(mapload, new_skin)
	. = ..()
	var/datum/job/doctor/J = new /datum/job/doctor
	access_card.access += J.get_access()
	prev_access = access_card.access
	qdel(J)

	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

	if(new_skin)
		skin = new_skin
	update_icon()


/mob/living/simple_animal/bot/medbot/bot_reset()
	..()
	patient = null
	oldpatient = null
	oldloc = null
	last_found = world.time
	declare_cooldown = FALSE
	update_icon()


/mob/living/simple_animal/bot/medbot/proc/soft_reset() //Allows the medibot to still actively perform its medical duties without being completely halted as a hard reset does.
	path = list()
	patient = null
	mode = BOT_IDLE
	last_found = world.time
	update_icon()


/mob/living/simple_animal/bot/medbot/set_custom_texts()
	text_hack = "You corrupt [name]'s reagent processor circuits."
	text_dehack = "You reset [name]'s reagent processor circuits."
	text_dehack_fail = "[name] seems damaged and does not respond to reprogramming!"


/mob/living/simple_animal/bot/medbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += "<TT><B>Medical Unit Controls v1.1</B></TT><BR><BR>"
	dat += "Status: <a href='byond://?src=[UID()];power=1'>[on ? "On" : "Off"]</A><BR>"
	dat += "Maintenance panel panel is [open ? "opened" : "closed"]<BR>"
	dat += "Beaker: "
	if(reagent_glass)
		dat += "<a href='byond://?src=[UID()];eject=1'>Loaded \[[reagent_glass.reagents.total_volume]/[reagent_glass.reagents.maximum_volume]\]</a>"
	else
		dat += "None Loaded"
	dat += "<br>Behaviour controls are [locked ? "locked" : "unlocked"]<hr>"
	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += "<TT>Healing Threshold: "
		dat += "<a href='byond://?src=[UID()];adj_threshold=-10'>--</a> "
		dat += "<a href='byond://?src=[UID()];adj_threshold=-5'>-</a> "
		dat += "[heal_threshold] "
		dat += "<a href='byond://?src=[UID()];adj_threshold=5'>+</a> "
		dat += "<a href='byond://?src=[UID()];adj_threshold=10'>++</a>"
		dat += "</TT><br>"

		dat += "<TT>Injection Level: "
		dat += "<a href='byond://?src=[UID()];adj_inject=-5'>-</a> "
		dat += "[injection_amount] "
		dat += "<a href='byond://?src=[UID()];adj_inject=5'>+</a> "
		dat += "</TT><br>"

		dat += "Reagent Source: "
		dat += "<a href='byond://?src=[UID()];use_beaker=1'>[use_beaker ? "Loaded Beaker (When available)" : "Internal Synthesizer"]</a><br>"

		dat += "Treat Viral Infections: <a href='byond://?src=[UID()];virus=1'>[treat_virus ? "Yes" : "No"]</a><br>"
		dat += "The speaker switch is [shut_up ? "off" : "on"]. <a href='byond://?src=[UID()];togglevoice=[1]'>Toggle</a><br>"
		dat += "Critical Patient Alerts: <a href='byond://?src=[UID()];critalerts=1'>[declare_crit ? "Yes" : "No"]</a><br>"
		dat += "Patrol Station: <a href='byond://?src=[UID()];operation=patrol'>[auto_patrol ? "Yes" : "No"]</a><br>"
		dat += "Stationary Mode: <a href='byond://?src=[UID()];stationary=1'>[stationary_mode ? "Yes" : "No"]</a><br>"

	return dat


/mob/living/simple_animal/bot/medbot/Topic(href, href_list)
	if(..())
		return TRUE

	if(href_list["adj_threshold"])
		var/adjust_num = text2num(href_list["adj_threshold"])
		heal_threshold += adjust_num
		if(heal_threshold < 5)
			heal_threshold = 5
		if(heal_threshold > 75)
			heal_threshold = 75

	else if(href_list["adj_inject"])
		var/adjust_num = text2num(href_list["adj_inject"])
		injection_amount += adjust_num
		if(injection_amount < 5)
			injection_amount = 5
		if(injection_amount > 15)
			injection_amount = 15

	else if(href_list["use_beaker"])
		use_beaker = !use_beaker

	else if(href_list["eject"] && (!isnull(reagent_glass)))
		reagent_glass.forceMove(get_turf(src))
		reagent_glass = null

	else if(href_list["togglevoice"])
		shut_up = !shut_up

	else if(href_list["critalerts"])
		declare_crit = !declare_crit

	else if(href_list["stationary"])
		stationary_mode = !stationary_mode
		path = list()
		update_icon()

	else if(href_list["virus"])
		treat_virus = !treat_virus

	update_controls()


/mob/living/simple_animal/bot/medbot/attackby(obj/item/I, mob/user, params)
	var/current_health = health
	if(user.a_intent == INTENT_HARM)
		current_health = health
		. = ..()
		if(ATTACK_CHAIN_CANCEL_CHECK(.) || health >= current_health)
			return .
		step_to(src, (get_step_away(src, user)))	//if medbot took some damage
		return .

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(locked)
			to_chat(user, span_warning("You cannot insert a beaker because the panel is locked!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(reagent_glass)
			to_chat(user, span_warning("There is already a beaker loaded!"))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..() | ATTACK_CHAIN_NO_AFTERATTACK
		reagent_glass = I
		to_chat(user, span_notice("You insert [I]."))
		show_controls(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	current_health = health
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || health >= current_health)
		return .
	step_to(src, (get_step_away(src, user)))	//if medbot took some damage


/mob/living/simple_animal/bot/medbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		declare_crit = FALSE
		if(user)
			to_chat(user, span_notice("You short out [src]'s reagent synthesis circuits."))
		audible_message(span_danger("[src] buzzes oddly!"))
		flick("medibot_spark", src)
		if(user)
			oldpatient = user


/mob/living/simple_animal/bot/medbot/process_scan(mob/living/carbon/human/H)
	if(buckled)
		if((last_warning + 30 SECONDS) < world.time)
			speak(span_danger("Movement restrained! Unit on standby!"))
			playsound(loc, 'sound/machines/buzz-two.ogg', 50, FALSE)
			last_warning = world.time
		return
	if(H.stat == DEAD)
		return

	if((H == oldpatient) && (world.time < last_found + 20 SECONDS))
		return

	if(assess_patient(H))
		last_found = world.time
		if((last_newpatient_speak + 30 SECONDS) < world.time) //Don't spam these messages!
			var/list/messagevoice = list("Hey, [H.name]! Hold on, I'm coming." = 'sound/voice/mcoming.ogg',
										"Wait [H.name]! I want to help!" = 'sound/voice/mhelp.ogg',
										"[H.name], you appear to be injured!" = 'sound/voice/minjured.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(loc, messagevoice[message], 50, FALSE)
			last_newpatient_speak = world.time
		return H


/mob/living/simple_animal/bot/medbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_HEALING)
		return

	if(frustration > 8)
		oldpatient = patient
		soft_reset()

	if(!patient)
		if(!shut_up && prob(1))
			var/list/messagevoice = list("Radar, put a mask on!" = 'sound/voice/mradar.ogg',
										"There's always a catch, and I'm the best there is." = 'sound/voice/mcatch.ogg',
										"I knew it, I should've been a plastic surgeon." = 'sound/voice/msurgeon.ogg',
										"What kind of medbay is this? Everyone's dropping like flies." = 'sound/voice/mflies.ogg',
										"Delicious!" = 'sound/voice/mdelicious.ogg')
			var/message = pick(messagevoice)
			speak(message)
			playsound(loc, messagevoice[message], 50, FALSE)
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE) //If in stationary mode, scan range is limited to adjacent patients.
		patient = scan(/mob/living/carbon/human, oldpatient, scan_range)
		oldpatient = patient

	if(patient && (get_dist(src,patient) <= 1)) //Patient is next to us, begin treatment!
		if(mode != BOT_HEALING)
			mode = BOT_HEALING
			update_icon()
			frustration = 0
			medicate_patient(patient)
		return

	//Patient has moved away from us!
	else if(patient && length(path) && (get_dist(patient,path[length(path)]) > 2))
		path = list()
		mode = BOT_IDLE
		last_found = world.time

	else if(stationary_mode && patient) //Since we cannot move in this mode, ignore the patient and wait for another.
		soft_reset()
		return

	if(patient && !length(path) && (get_dist(src,patient) > 1))
		path = get_path_to(src, patient, max_distance = 30, access = access_card.GetAccess())
		mode = BOT_MOVING
		if(!length(path)) //try to get closer if you can't reach the patient directly
			path = get_path_to(src, patient, max_distance = 30, mintargetdist = 1, access = access_card.GetAccess())
			if(!length(path)) //Do not chase a patient we cannot reach.
				soft_reset()

	if(length(path) && patient)
		if(!bot_move(path[length(path)]))
			oldpatient = patient
			soft_reset()
		return

	if(length(path) > 8 && patient)
		frustration++

	if(auto_patrol && !stationary_mode && !patient)
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()


/mob/living/simple_animal/bot/medbot/proc/assess_beaker_injection(mob/living/carbon/C)
	//If we have and are using a medicine beaker, return any reagent the patient is missing
	if(use_beaker && reagent_glass?.reagents.total_volume)
		for(var/datum/reagent/R in reagent_glass.reagents.reagent_list)
			if(!C.reagents.has_reagent(R.id))
				return R.id


/mob/living/simple_animal/bot/medbot/proc/assess_viruses(mob/living/carbon/C)
	. = FALSE

	if(!treat_virus)
		return

	for(var/datum/disease/D as anything in C.diseases)
		if(!(D.visibility_flags & HIDDEN_HUD) && D.discovered && D.severity != NONTHREAT)
			return TRUE //Medbots see viruses if they displayed on HUD, ignoring safe viruses


/mob/living/simple_animal/bot/medbot/proc/select_medication(mob/living/carbon/C, beaker_injection)
	var/treatable_virus = assess_viruses(C)
	var/treatable_brute = C.getBruteLoss() >= heal_threshold
	var/treatable_fire = C.getFireLoss() >= heal_threshold
	var/treatable_oxy = C.getOxyLoss() >= (heal_threshold + 15)
	var/treatable_tox = C.getToxLoss() >= heal_threshold

	if((!C.has_organic_damage() || !(treatable_brute || treatable_fire || treatable_oxy || treatable_tox)) && !treatable_virus)
		return //No organic damage or injuries aren't severe enough, and no virus to treat; abort mission

	if(beaker_injection)
		return beaker_injection //Custom beaker injections have priority

	if(treatable_virus && !C.reagents.has_reagent(treatment_virus))
		return treatment_virus
	if(treatable_brute && !C.reagents.has_reagent(treatment_brute))
		return treatment_brute
	if(treatable_fire && !C.reagents.has_reagent(treatment_fire))
		return treatment_fire
	if(treatable_oxy && !C.reagents.has_reagent(treatment_oxy))
		return treatment_oxy
	if(treatable_tox && !C.reagents.has_reagent(treatment_tox))
		return treatment_tox


/mob/living/simple_animal/bot/medbot/proc/assess_patient(mob/living/carbon/C)
	//Time to see if they need medical help!
	if(C.stat == DEAD)
		return FALSE //welp too late for them!

	if(C.suiciding)
		return FALSE //Kevorkian school of robotic medical assistants.

	// is secretly a silicon
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.dna.species && H.dna.species.reagent_tag == PROCESS_SYN)
			return FALSE

	if(emagged == 2 || hijacked) //Everyone needs our medicine. (Our medicine is toxins)
		return TRUE

	if(syndicate_aligned && !("syndicate" in C.faction))
		return FALSE

	if(declare_crit && C.health <= 0) //Critical condition! Call for help!
		declare(C)

	if(!isnull(select_medication(C, assess_beaker_injection(C))))
		return TRUE //If a valid medicine option for the patient exists, they require treatment


/mob/living/simple_animal/bot/medbot/UnarmedAttack(atom/A)
	if(!can_unarmed_attack())
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		patient = C
		mode = BOT_HEALING
		update_icon()
		medicate_patient(C)
		update_icon()
	else
		..()


/mob/living/simple_animal/bot/medbot/examinate(atom/A as mob|obj|turf in view(client.maxview(), client.eye))
	..()
	if(has_vision(information_only = TRUE))
		chemscan(src, A)



/mob/living/simple_animal/bot/medbot/proc/medicate_patient(mob/living/carbon/C)
	if(!on)
		return

	if(!istype(C))
		oldpatient = patient
		soft_reset()
		return

	if(C.stat == DEAD || HAS_TRAIT(C, TRAIT_FAKEDEATH))
		var/list/messagevoice = list("No! Stay with me!" = 'sound/voice/mno.ogg',
									"Live, damnit! LIVE!" = 'sound/voice/mlive.ogg',
									"I...I've never lost a patient before. Not today, I mean." = 'sound/voice/mlost.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(loc, messagevoice[message], 50, FALSE)
		oldpatient = patient
		soft_reset()
		return

	var/reagent_id
	var/beaker_injection //If and what kind of beaker reagent needs to be injected

	if(emagged == 2 || hijacked) //Emagged! Time to poison everybody.
		reagent_id = "pancuronium"
	else
		beaker_injection = assess_beaker_injection(C)
		reagent_id = select_medication(C, beaker_injection)

	if(!reagent_id) //If they don't need any of that they're probably cured!
		var/list/messagevoice = list("All patched up!" = 'sound/voice/mpatchedup.ogg',
									"An apple a day keeps me away." = 'sound/voice/mapple.ogg',
									"Feel better soon!" = 'sound/voice/mfeelbetter.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(loc, messagevoice[message], 50, FALSE)
		bot_reset()
		return
	else
		if(!emagged && !hijacked && check_overdose(patient, reagent_id, injection_amount))
			soft_reset()
			return
		C.visible_message(span_danger("[src] is trying to inject [patient]!"),
									span_userdanger("[src] is trying to inject you!"))

		addtimer(CALLBACK(src, PROC_REF(do_inject), C, !isnull(beaker_injection), reagent_id), 3 SECONDS)


/mob/living/simple_animal/bot/medbot/proc/do_inject(mob/living/carbon/C, inject_beaker, reagent_id)
	if(QDELETED(src) || QDELETED(C))
		return
	if(in_range(src, patient) && on && assess_patient(patient))
		if(inject_beaker)
			if(use_beaker && reagent_glass?.reagents.total_volume)
				var/fraction = min(injection_amount/reagent_glass.reagents.total_volume, 1)
				reagent_glass.reagents.reaction(patient, REAGENT_INGEST, fraction)
				reagent_glass.reagents.trans_to(patient, injection_amount) //Inject from beaker instead.
		else
			patient.reagents.add_reagent(reagent_id, injection_amount)

		C.visible_message(span_danger("[src] injects [patient] with its syringe!"),
						span_userdanger("[src] injects you with its syringe!"))
	else
		visible_message("[src] retracts its syringe.")

	update_icon()
	soft_reset()


/mob/living/simple_animal/bot/medbot/proc/check_overdose(mob/living/carbon/patient, reagent_id, injection_amount)
	var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
	if(!R.overdose_threshold)
		return FALSE
	var/current_volume = patient.reagents.get_reagent_amount(reagent_id)
	if(current_volume + injection_amount > R.overdose_threshold)
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/medbot/explode()
	on = FALSE
	visible_message(span_userdanger("[src] blows apart!"))
	var/turf/Tsec = get_turf(src)

	if(drops_parts)
		switch(skin)
			if("ointment")
				new /obj/item/storage/firstaid/fire/empty(Tsec)
			if("tox")
				new /obj/item/storage/firstaid/toxin/empty(Tsec)
			if("o2")
				new /obj/item/storage/firstaid/o2/empty(Tsec)
			if("brute")
				new /obj/item/storage/firstaid/brute/empty(Tsec)
			if("adv")
				new /obj/item/storage/firstaid/adv/empty(Tsec)
			if("bezerk")
				var/obj/item/storage/firstaid/tactical/empty/T = new(Tsec)
				T.syndicate_aligned = syndicate_aligned //This is a special case since Syndicate medibots and the mysterious medibot look the same; we also dont' want crew building Syndicate medibots if the mysterious medibot blows up.
			if("fish")
				new /obj/item/storage/firstaid/aquatic_kit(Tsec)
			if("machine")
				new /obj/item/storage/firstaid/machine/empty(Tsec)
			if("paramed")
				new /obj/item/storage/firstaid/paramed/empty(Tsec)
			else
				new /obj/item/storage/firstaid(Tsec)

		new /obj/item/assembly/prox_sensor(Tsec)

		new /obj/item/healthanalyzer(Tsec)

		if(prob(50))
			drop_part(robot_arm, Tsec)

	if(reagent_glass)
		reagent_glass.forceMove(Tsec)
		reagent_glass = null

	if(emagged && prob(25))
		playsound(loc, 'sound/voice/minsult.ogg', 50, FALSE)

	do_sparks(3, TRUE, src)
	..()


/mob/living/simple_animal/bot/medbot/proc/declare(crit_patient)
	if(declare_cooldown)
		return
	if(syndicate_aligned)
		return
	var/area/location = get_area(src)
	speak("Medical emergency! [crit_patient ? "<b>[crit_patient]</b>" : "A patient"] is in critical condition at [location]!", radio_channel)
	declare_cooldown = TRUE
	spawn(200) //Twenty seconds
		declare_cooldown = FALSE


/obj/machinery/bot_core/medbot
	req_access = list(ACCESS_MEDICAL, ACCESS_ROBOTICS)


/obj/machinery/bot_core/medbot/syndicate
	req_access = list(ACCESS_SYNDICATE)
