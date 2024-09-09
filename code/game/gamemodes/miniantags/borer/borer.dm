/mob/living/captive_brain
	name = "host brain"
	real_name = "host brain"
	tts_seed = "Gman"
	var/host_resisting = FALSE

/mob/living/captive_brain/say(message)
	if(client)
		if(check_mute(client.ckey, MUTE_IC))
			to_chat(src, span_warning("Вы не можете говорить в IC (muted)."))
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(istype(loc,/mob/living/simple_animal/borer))
		message = trim(sanitize(copytext_char(message, 1, MAX_MESSAGE_LEN)))
		if(!message)
			return
		add_say_logs(src, message)
		if(stat == DEAD)
			return say_dead(message)
		var/mob/living/simple_animal/borer/B = loc
		to_chat(src, "Вы тихо шепчете, \"[message]\"")
		to_chat(B.host, "<i><span class='alien'>Пленённый разум [src] шепчет, \"[message]\"</span></i>")

		for(var/mob/M in GLOB.mob_list)
			if(M.mind && isobserver(M))
				to_chat(M, "<i>Thought-speech, <b>[src]</b> -> <b>[B.truename]:</b> [message]</i>")

/mob/living/captive_brain/say_understands(var/mob/other, var/datum/language/speaking = null)
	var/mob/living/simple_animal/borer/B = loc
	if(!istype(B))
		log_runtime(EXCEPTION("Trapped mind found without a borer!"), src)
		return FALSE
	return B.host.say_understands(other, speaking)


/mob/living/captive_brain/resist()
	var/mob/living/simple_animal/borer/B = loc

	if(host_resisting)
		to_chat(src, span_notice("Вы уже пытаетесь вернуть своё тело!"))
		return

	host_resisting = TRUE
	to_chat(src, span_userdanger("Вы начинаете упорно сопротивляться контролю паразита (это займёт примерно минуту)."))
	to_chat(B.host, span_userdanger("Вы чувствуете, как пленённый разум [src] начинает сопротивляться."))
	var/delay = (rand(350,450) + B.host.getBrainLoss())
	if(!do_after(src, delay, B.host, ALL))
		return
	return_control(B)
	host_resisting = FALSE

/mob/living/captive_brain/proc/return_control(mob/living/simple_animal/borer/B)
	if(!B || !B.controlling)
		return

	B.host.apply_damage(rand(5, 10), BRAIN)
	to_chat(src, span_userdanger("Огромным усилием воли вы вновь обретаете контроль над своим телом!"))
	to_chat(B.host, span_userdanger("Вы чувствуете, как мозг носителя уходит из под вашего контроля. Вы успеваете разорвать связь прежде, чем сильные нейронные импульсы смогут навредить вам."))

	B.detach()

/mob/living/simple_animal/borer
	name = "cortical borer"
	real_name = "cortical borer"
	desc = "A small, quivering sluglike creature."
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	tts_seed = "Gman_e2"
	response_help = "pokes"
	response_disarm = "prods the"
	response_harm = "stomps on the"
	icon_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attacktext = "щипает"
	friendly = "prods"
	wander = 0
	mob_size = MOB_SIZE_TINY
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	faction = list("creature")
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	var/generation = 1
	var/static/list/borer_names = list(
			"Primary", "Secondary", "Tertiary", "Quaternary", "Quinary", "Senary",
			"Septenary", "Octonary", "Novenary", "Decenary", "Undenary", "Duodenary",
			)
	var/talk_inside_host = FALSE			// So that borers don't accidentally give themselves away on a botched message
	var/chemicals = 10						// Chemicals used for reproduction and chemical injection.
	var/max_chems = 250
	var/mob/living/carbon/human/host		// Human host for the brain worm.
	var/truename							// Name used for brainworm-speak.
	var/mob/living/captive_brain/host_brain	// Used for swapping control of the body back and forth.
	var/controlling							// Used in human death check.
	var/docile = FALSE						// Sugar can stop borers from acting.
	var/bonding = FALSE
	var/leaving = FALSE
	var/sneaking = FALSE
	var/hiding = FALSE
	var/datum/action/innate/borer/talk_to_host/talk_to_host_action = new
	var/datum/action/innate/borer/toggle_hide/toggle_hide_action = new
	var/datum/action/innate/borer/talk_to_borer/talk_to_borer_action = new
	var/datum/action/innate/borer/talk_to_brain/talk_to_brain_action = new
	var/datum/action/innate/borer/take_control/take_control_action = new
	var/datum/action/innate/borer/give_back_control/give_back_control_action = new
	var/datum/action/innate/borer/leave_body/leave_body_action = new
	var/datum/action/innate/borer/make_chems/make_chems_action = new
	var/datum/action/innate/borer/make_larvae/make_larvae_action = new
	var/datum/action/innate/borer/torment/torment_action = new
	var/datum/action/innate/borer/sneak_mode/sneak_mode_action = new

/mob/living/simple_animal/borer/New(atom/newloc, var/gen=1)
	..(newloc)
	remove_from_all_data_huds()
	generation = gen
	add_language(LANGUAGE_HIVE_BORER)
	notify_ghosts("Мозговой червь появился в [get_area(src)]!", enter_link = "<a href=?src=[UID()];ghostjoin=1>(Click to enter)</a>", source = src, action = NOTIFY_ATTACK)
	real_name = "Cortical Borer [rand(1000,9999)]"
	truename = "[borer_names[min(generation, borer_names.len)]] [rand(1000,9999)]"
	GrantBorerActions()

/mob/living/simple_animal/borer/attack_ghost(mob/user)
	if(cannotPossess(user))
		to_chat(user, span_boldnotice("Upon using the antagHUD you forfeited the ability to join the round."))
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, span_warning("You are banned from antagonists!"))
		return
	if(key)
		return
	if(stat != CONSCIOUS)
		return
	var/be_borer = tgui_alert(user, "Become a cortical borer? (Warning, You can no longer be cloned!)", "Cortical Borer", list("Yes", "No"))
	if(be_borer != "Yes" || !src || QDELETED(src))
		return
	if(key)
		return
	transfer_personality(user.client)

/mob/living/simple_animal/borer/sentience_act()
	GrantBorerSpells()
	hide_borer()

/mob/living/simple_animal/borer/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Chemicals", chemicals)


/mob/living/simple_animal/borer/say(message, verb = "says", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	var/list/message_pieces = parse_languages(message)
	for(var/datum/multilingual_say_piece/S in message_pieces)
		if(S.speaking != GLOB.all_languages[LANGUAGE_HIVE_BORER] && loc == host && !talk_inside_host)
			Communicate(message)
			return
	return ..()


/mob/living/simple_animal/borer/proc/Communicate(var/sended_message)
	if(!host)
		to_chat(src, "У вас нет носителя!")
		return

	if(stat)
		to_chat(src, "Сейчас вы не в состоянии этого сделать.")
		return

	if(host.stat == DEAD)
		to_chat(src, span_warning("Мозг носителя не способен воспринимать вас сейчас!"))
		return

	if(!sended_message) //If we use "say", it won't ask us to write the message twice.
		sended_message = stripped_input(src, "Введите сообщение для носителя.", "Borer", "")

	if(!sended_message)
		return

	if(src && !QDELETED(src) && !QDELETED(host))
		var/say_string = (docile) ? "slurs" :"states"
		if(host)
			to_chat(host, "<span class='changeling'><i>[truename] [say_string]:</i> [sended_message]</span>")
			add_say_logs(src, sended_message, host, "BORER")
			for(var/M in GLOB.dead_mob_list)
				if(isobserver(M))
					to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[truename]</b> ([ghost_follow_link(src, ghost=M)]): [sended_message]</i>")
		to_chat(src, "<span class='changeling'><i>[truename] [say_string]:</i> [sended_message]</span>")
		add_verb(host, /mob/living/proc/borer_comm)
		talk_to_borer_action.Grant(host)

/mob/living/simple_animal/borer/verb/toggle_silence_inside_host()
	set name = "Toggle speech inside Host"
	set category = "Borer"
	set desc = "Toggle whether you will be able to say audible messages while inside your host."

	if(talk_inside_host)
		talk_inside_host = FALSE
		to_chat(src, span_notice("Теперь вы будете говорить в сознание носителя."))
	else
		talk_inside_host = TRUE
		to_chat(src, span_notice("Теперь вы сможете говорить, находясь внутри носителя."))

/mob/living/proc/borer_comm()
	set name = "Converse with Borer"
	set category = "Borer"
	set desc = "Communicate mentally with your borer."

	if(src.stat == DEAD) // This shouldn't appear if host is not alive, but double-check
		return

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B)
		return

	var/input = stripped_input(src, "Введите сообщение для мозгового червя.", "Сообщение", "")
	if(!input)
		return

	to_chat(B, "<span class='changeling'><i>[src] says:</i> [input]</span>")
	add_say_logs(src, input, B, "BORER")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[src]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[src] says:</i> [input]</span>")

/mob/living/proc/trapped_mind_comm()
	set name = "Converse with Trapped Mind"
	set category = "Borer"
	set desc = "Communicate mentally with the trapped mind of your host."

	if(src.stat == DEAD)
		to_chat(src, span_warning("Мозг жертвы не способен воспринимать вас в этом состоянии!"))
		return

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(!B || !B.host_brain)
		return
	var/mob/living/captive_brain/CB = B.host_brain
	var/input = stripped_input(src, "Введите сообщение для пленённого разума.", "Сообщение", "")
	if(!input)
		return

	to_chat(CB, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")
	add_say_logs(B, input, CB, "BORER")

	for(var/M in GLOB.dead_mob_list)
		if(isobserver(M))
			to_chat(M, "<span class='changeling'><i>Borer Communication from <b>[B]</b> ([ghost_follow_link(src, ghost=M)]): [input]</i>")
	to_chat(src, "<span class='changeling'><i>[B.truename] says:</i> [input]</span>")

/mob/living/simple_animal/borer/Life(seconds, times_fired)

	..()

	if(host)

		if(!stat && host.stat != DEAD)

			if(host.reagents.has_reagent("sugar"))

				if(!docile)

					if(controlling)
						to_chat(host, span_notice("Вы чувствуете усыпляющий поток сахара в крови вашего носителя, убаюкивающий вас до бессилия.."))
					else
						to_chat(src, span_notice("Вы чувствуете усыпляющий поток сахара в крови вашего носителя, убаюкивающий вас до бессилия.."))
					docile = TRUE
			else
				if(docile)
					if(controlling)
						to_chat(host, span_notice("Вы приходите в себя, когда сахар покидает кровь вашего носителя."))
					else
						to_chat(src, span_notice("Вы приходите в себя, когда сахар покидает кровь вашего носителя."))
					docile = FALSE

			if(chemicals < max_chems && !sneaking)
				chemicals++
			if(controlling)

				if(docile)
					to_chat(host, span_notice("Вы слишком обессилели для того, чтобы продолжать контролировать тело носителя..."))
					host.release_control()
					return

				if(prob(5))
					host.apply_damage(rand(1, 2), BRAIN)

				if(prob(host.getBrainLoss()/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")

/mob/living/simple_animal/borer/handle_environment()
	if(host)
		return // Snuggled up, nice and warm, in someone's head
	else
		return ..()

/mob/living/simple_animal/borer/UnarmedAttack(mob/living/carbon/human/M)
	if(!can_unarmed_attack())
		return
	if(istype(M))
		to_chat(src, span_notice("Вы анализируете жизненные показатели [M]."))
		healthscan(src, M, 1, TRUE)

/obj/effect/proc_holder/spell/borer_infest
	name = "Infest"
	desc = "Infest a suitable humanoid host."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "infest"
	action_background_icon_state = "bg_alien"
	selection_activated_message = span_notice("Вы приготовились заразить жертву. <B>Left-click чтобы применить способность!</B>")
	selection_deactivated_message = span_notice("Вы прекратили свои попытки заразить жертву.")
	need_active_overlay = TRUE
	human_req = FALSE
	var/infesting = FALSE

/obj/effect/proc_holder/spell/borer_infest/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 1
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/borer_infest/can_cast(mob/living/user, charge_check = TRUE, show_message = FALSE)

	if (is_ventcrawling(user) || !src || user.stat || infesting)
		return FALSE
	. = ..()

/obj/effect/proc_holder/spell/borer_infest/valid_target(mob/living/carbon/human/target, user)
	return istype(target) && target.stat != DEAD && !ismachineperson(target)

/obj/effect/proc_holder/spell/borer_infest/cast(list/targets, mob/living/simple_animal/borer/user)
	var/mob/living/carbon/human/target = targets[1]

	if(!target)
		return

	infesting = TRUE
	to_chat(user, "Вы подползаете к [target] и начинаете искать [genderize_ru(target.gender,"его","её","его","их" )] слуховой проход...")

	if(!do_after(user, 5 SECONDS, target, NONE))
		to_chat(user, "Как только [target] отходит, вы срываетесь и падаете на пол.")
		infesting = FALSE
		return

	if(target.has_brain_worms())
		to_chat(user, span_warning("[target] уже заражён!"))
		infesting = FALSE
		return

	infesting = FALSE
	user.host = target
	add_attack_logs(user, user.host, "Infested as borer")
	target.borer = user
	user.forceMove(target)
	user.host.status_flags |= PASSEMOTES

	user.RemoveBorerActions()
	user.RemoveBorerSpells()
	user.GrantInfestActions()

	to_chat(user, span_boldnotice("Вы можете анализировать здоровье носителя при помощи Left-click."))

/mob/living/simple_animal/borer/verb/secrete_chemicals()
	set category = "Borer"
	set name = "Secrete Chemicals"
	set desc = "Push some chemicals into your host's bloodstream."

	if(!host)
		to_chat(src, "Вы не находитесь в теле носителя.")
		return

	if(stat)
		to_chat(src, "Вы не можете производить химикаты в вашем нынешнем состоянии.")
		return

	if(docile)
		to_chat(src, "<font color='blue'>Вы слишком обессилели для этого.</font>")
		return

	var/content = ""

	content += "<table>"

	for(var/datum in typesof(/datum/borer_chem))
		var/datum/borer_chem/C = datum
		var/cname = initial(C.chemname)
		var/datum/reagent/R = GLOB.chemical_reagents_list[cname]
		if(cname)
			content += "<tr><td><a class='chem-select' href='byond://?_src_=[UID()];src=[UID()];borer_use_chem=[cname]'>[R.name] ([initial(C.chemuse)])</a><p>[initial(C.chemdesc)]</p></td></tr>"

	content += "</table>"

	var/html = get_html_template(content)

	usr << browse(null, "window=ViewBorer[UID()]Chems;size=585x400")
	usr << browse(html, "window=ViewBorer[UID()]Chems;size=585x400")

	return

/mob/living/simple_animal/borer/Topic(href, href_list, hsrc)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)
	if(href_list["borer_use_chem"])
		locate(href_list["src"])
		if(!istype(src, /mob/living/simple_animal/borer))
			return

		var/topic_chem = href_list["borer_use_chem"]
		var/datum/borer_chem/C = null

		for(var/datum in typesof(/datum/borer_chem))
			var/datum/borer_chem/test = datum
			if(initial(test.chemname) == topic_chem)
				C = new test()
				break

		if(!C || !host || controlling || !src || stat)
			return
		var/datum/reagent/R = GLOB.chemical_reagents_list[C.chemname]
		if(chemicals < C.chemuse)
			to_chat(src, span_boldnotice("Вам нужно [C.chemuse] химикатов для выделения [R.name]!"))
			return

		to_chat(src, span_userdanger("Вы впрыскиваете [R.name] из своих резервуаров в кровь [host]."))
		host.reagents.add_reagent(C.chemname, C.quantity)
		chemicals -= C.chemuse
		add_attack_logs(src, host, "injected [R.name]")

		// This is used because we use a static set of datums to determine what chems are available,
		// instead of a table or something. Thus, when we instance it, we can safely delete it
		qdel(C)
	..()

/mob/living/simple_animal/borer/verb/hide_borer()
	set category = "Borer"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(host)
		to_chat(usr, span_warning("Вы не можете сделать этого, находясь внутри носителя."))
		return

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = TURF_LAYER+0.2
		to_chat(src, span_notice("Вы прячетесь."))
		hiding = TRUE
	else
		layer = MOB_LAYER
		to_chat(src, span_notice("Вы перестали прятаться."))
		hiding = FALSE

/obj/effect/proc_holder/spell/borer_dominate
	name = "Dominate Victim"
	desc = "Freeze the limbs of a potential host with supernatural fear."
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	action_icon_state = "genetic_cryo"
	action_background_icon_state = "bg_alien"
	selection_activated_message = span_notice("Вы приготовились поразить жертву. <B>Left-click чтобы применить способность!</B>")
	selection_deactivated_message = span_notice("Вы решили дать своей жертве шанс. Пока что.")
	need_active_overlay = TRUE
	human_req = FALSE

/obj/effect/proc_holder/spell/borer_dominate/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.range = 3
	T.click_radius = -1
	return T

/obj/effect/proc_holder/spell/borer_dominate/can_cast(mob/living/user, charge_check = TRUE, show_message = FALSE)

	if (is_ventcrawling(user) || !src || user.stat)
		return FALSE
	. = ..()

/obj/effect/proc_holder/spell/borer_dominate/valid_target(mob/living/carbon/human/target, user)
	return istype(target) && target.stat != DEAD

/obj/effect/proc_holder/spell/borer_dominate/cast(list/targets, mob/living/simple_animal/borer/user)
	var/mob/living/carbon/human/target = targets[1]

	if(target.has_brain_worms())
		to_chat(user, span_warning("Вы не можете позволить себе сделать это с тем, кто уже заражён.."))
		return

	to_chat(user, span_warning("Вы пронзили разум [target] пси-потоком, парализуя [genderize_ru(target.gender,"его","её","его","их" )] конечности волной первородного ужаса!"))
	to_chat(target, span_warning("Вы чувствуете, как на вас наваливается жуткое чувство страха, леденящее конечности и заставляющее сердце бешено колотиться."))
	target.Weaken(6 SECONDS)

/mob/living/simple_animal/borer/verb/release_host()
	set category = "Borer"
	set name = "Release Host"
	set desc = "Slither out of your host."


	if(!host)
		to_chat(src, "Вы не находитесь в теле носителя.")
		return

	if(stat)
		to_chat(src, "Вы не можете покинуть носителя в вашем текущем состоянии.")
		return

	if(docile)
		to_chat(src, span_notice("<font color='blue'>Вы слишком обессилели для этого.</font>"))
		return

	if(!host || !src)
		return

	leaving = !leaving
	let_go()
	leaving = FALSE

/mob/living/simple_animal/borer/proc/let_go()

	if(!host || !src || QDELETED(host) || QDELETED(src) || controlling)
		return
	if(stat)
		to_chat(src, "Вы не можете освободить цель в вашем текущем состоянии.")
		return
	if(leaving)
		to_chat(src, "Вы начинаете отсоединяться от синапсов носителя и пробираться наружу через его слуховой проход.")
	else
		to_chat(src, span_danger("Вы решили остаться в носителе."))

	// If we cast the spell a second time, it will be canceled
	if(!do_after(src, 20 SECONDS, host, ALL, extra_checks = CALLBACK(src, PROC_REF(borer_leaving), src)))
		return

	to_chat(src, "Вы выкручиваетесь из уха носителя и падаете на пол.")
	leave_host()

/mob/living/simple_animal/borer/proc/borer_leaving()
	if(!leaving || docile || bonding)
		return FALSE
	return TRUE

/mob/living/simple_animal/borer/proc/leave_host()

	if(!host)
		return
	if(controlling)
		detach()
	GrantBorerActions()
	GrantBorerSpells()
	RemoveInfestActions()
	forceMove(get_turf(host))
	machine = null

	host.reset_perspective(null)
	host.machine = null

	var/mob/living/carbon/H = host
	H.borer = null
	remove_verb(H, /mob/living/proc/borer_comm)
	talk_to_borer_action.Remove(host)
	H.status_flags &= ~PASSEMOTES
	host = null
	return

/mob/living/simple_animal/borer/verb/bond_brain()
	set category = "Borer"
	set name = "Assume Control"
	set desc = "Fully connect to the brain of your host."

	if(!host)
		to_chat(src, "Вы не находитесь в теле носителя.")
		return

	if(host.stat == DEAD)
		to_chat(src, "Носитель не может быть взят под контроль в его текущем состоянии.")
		return

	if(stat)
		to_chat(src, "Вы не можете сделать этого в вашем нынешнем состоянии.")
		return

	if(docile)
		to_chat(src, span_notice("<font color='blue'>Вы слишком обессилели для этого.</font>"))
		return

	if(QDELETED(src) || QDELETED(host))
		return

	bonding = !bonding

	if(bonding)
		to_chat(src, "Вы начинаете деликатно настраивать связь с мозгом носителя...")
	else
		to_chat(src, span_danger("Вы прекращаете свои попытки взять носителя под полный контроль."))

	var/delay = 300+(host.getBrainLoss()*5)

	// If we cast the spell a second time, it will be canceled
	if(!do_after(src, delay, host, ALL, extra_checks = CALLBACK(src, PROC_REF(borer_assuming), src)))
		bonding = FALSE
		return

	assume_control()
	bonding = FALSE

/mob/living/simple_animal/borer/proc/borer_assuming()
	if(!bonding || docile || leaving)
		return FALSE
	return TRUE

/mob/living/simple_animal/borer/proc/assume_control()

	if(!host || !src || controlling)
		return

	else
		to_chat(src, span_userdanger("Вы погружаете свои хоботки глубоко в кору головного мозга носителя, напрямую взаимодействуя с его нервной системой."))
		to_chat(host, span_userdanger("Вы чувствуете странное смещение за глазами, прежде чем постороннее сознание вытесняет ваше."))
		var/borer_key = src.key
		add_attack_logs(src, host, "Assumed control of (borer)")
		// host -> brain
		var/h2b_id = host.computer_id
		var/h2b_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		qdel(host_brain)
		host_brain = new(src)

		host_brain.ckey = host.ckey

		host_brain.name = host.name

		if(!host_brain.computer_id)
			host_brain.computer_id = h2b_id

		if(!host_brain.lastKnownIP)
			host_brain.lastKnownIP = h2b_ip

		// self -> host
		var/s2h_id = src.computer_id
		var/s2h_ip= src.lastKnownIP
		src.computer_id = null
		src.lastKnownIP = null

		host.ckey = src.ckey

		if(!host.computer_id)
			host.computer_id = s2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = s2h_ip

		controlling = TRUE

		add_verb(host, /mob/living/carbon/proc/release_control)
		add_verb(host, /mob/living/carbon/proc/punish_host)
		add_verb(host, /mob/living/carbon/proc/spawn_larvae)
		add_verb(host, /mob/living/carbon/proc/sneak_mode)
		remove_verb(host, /mob/living/proc/borer_comm)
		add_verb(host, /mob/living/proc/trapped_mind_comm)

		GrantControlActions()
		talk_to_borer_action.Remove(host)
		host.med_hud_set_status()

		if(src && !src.key)
			src.key = "@[borer_key]"
		return

/mob/living/carbon/proc/punish_host()
	set category = "Borer"
	set name = "Torment Host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain)
		to_chat(src, span_danger("Вы посылаете карающий всплеск психической агонии в мозг своего носителя."))
		to_chat(B.host_brain, span_danger("<FONT size=3>Ужасная, жгучая агония пронзает вас насквозь, вырывая беззвучный крик из глубин вашего запертого разума!</FONT>"))

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()

	set category = "Borer"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(B && B.host_brain)
		to_chat(src, span_danger("Вы убираете свои хоботки, освобождая [B.host_brain]."))

		B.detach()

	else
		log_runtime(EXCEPTION("Missing borer or missing host brain upon borer release."), src)

//Check for brain worms in head.
/mob/proc/has_brain_worms()
	return FALSE

/mob/living/carbon/has_brain_worms()

	if(borer)
		return borer

	return FALSE

/mob/living/carbon/proc/BorerControlling()
	var/mob/living/simple_animal/borer/borer = has_brain_worms()
	if(borer && borer.controlling)
		return TRUE
	return FALSE

/mob/living/carbon/proc/spawn_larvae()
	set category = "Borer"
	set name = "Reproduce"
	set desc = "Spawn several young."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.chemicals >= 100)
		to_chat(src, span_danger("Ваш хозяин дёргается и вздрагивает, когда вы быстро выводите личинку из своего слизнеподобного тела."))
		visible_message(span_danger("[src] яростно блюёт, изрыгая рвотные массы вместе с извивающимся, похожим на слизня существом!"))
		B.chemicals -= 100
		var/turf/T = get_turf(src)
		T.add_vomit_floor()
		new /mob/living/simple_animal/borer(T, B.generation + 1)

	else
		to_chat(src, "Вам требуется 100 химикатов для размножения!")
		return

/mob/living/carbon/proc/sneak_mode()
	set category = "Borer"
	set name = "Sneak mode"
	set desc = "Hides your status from medical huds."
	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.sneaking)
		to_chat(src, span_danger("Вы перестаете скрывать свое присутствие!"))
		B.sneaking = FALSE
		B.host.med_hud_set_status()
		return

	if(B.host_brain.ckey)
		to_chat(src, span_danger("Душа вашего хозяина не позволяет вам скрыть свое присутствие!"))
		return

	if(B.chemicals >= 50)
		B.sneaking = TRUE
		to_chat(src, span_notice("Вы скрываете ваше присутствие внутри хозяина!"))
		B.chemicals -= 50
		B.host.med_hud_set_status()

	else
		to_chat(src, "Вам требуется 50 химикатов для сокрытия вашего присутствия!")
		return

/mob/living/simple_animal/borer/proc/detach()

	if(!host || !controlling)
		return

	controlling = FALSE
	reset_perspective(null)
	machine = null
	sneaking = FALSE

	remove_verb(host, /mob/living/carbon/proc/release_control)
	remove_verb(host, /mob/living/carbon/proc/punish_host)
	remove_verb(host, /mob/living/carbon/proc/spawn_larvae)
	remove_verb(host, /mob/living/carbon/proc/sneak_mode)
	add_verb(host, /mob/living/proc/borer_comm)
	remove_verb(host, /mob/living/proc/trapped_mind_comm)

	RemoveControlActions()
	talk_to_borer_action.Grant(host)
	host.med_hud_set_status()

	if(host_brain)
		add_attack_logs(host, src, "Took control back (borer)")
		// host -> self
		var/h2s_id = host.computer_id
		var/h2s_ip= host.lastKnownIP
		host.computer_id = null
		host.lastKnownIP = null

		src.ckey = host.ckey

		if(!src.computer_id)
			src.computer_id = h2s_id

		if(!host_brain.lastKnownIP)
			src.lastKnownIP = h2s_ip

		// brain -> host
		var/b2h_id = host_brain.computer_id
		var/b2h_ip= host_brain.lastKnownIP
		host_brain.computer_id = null
		host_brain.lastKnownIP = null

		host.ckey = host_brain.ckey

		if(!host.computer_id)
			host.computer_id = b2h_id

		if(!host.lastKnownIP)
			host.lastKnownIP = b2h_ip

	qdel(host_brain)

	return


/mob/living/simple_animal/borer/proc/transfer_personality(var/client/candidate)

	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/M = create_borer_mind(candidate.ckey)
		M.transfer_to(src)
		candidate.mob = src
		ckey = candidate.ckey
		var/list/messages = list()
		messages.Add(span_notice("Вы - Мозговой Червь!"))
		messages.Add("Забирайтесь в голову своей жертвы, используйте скрытность, убеждение и свои способности к управлению разумом, чтобы сохранить себя, своё потомство и своего носителя в безопасности и тепле.")
		messages.Add("Сахар сводит на нет ваши способности, избегайте его любой ценой!")
		messages.Add("Вы можете разговаривать со своими коллегами-борерами, используя '[get_language_prefix(LANGUAGE_HIVE_BORER)]'.")
		to_chat(src, chat_box_purple(messages.Join("<br>")))
		GrantBorerSpells()
		hide_borer()

/proc/create_borer_mind(key)
	var/datum/mind/M = new /datum/mind(key)
	M.assigned_role = "Cortical Borer"
	M.special_role = "Cortical Borer"
	return M

/mob/living/simple_animal/borer/proc/GrantBorerActions()
	toggle_hide_action.Grant(src)


/mob/living/simple_animal/borer/proc/RemoveBorerActions()
	toggle_hide_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantBorerSpells()
	mind?.AddSpell(new /obj/effect/proc_holder/spell/borer_infest)
	mind?.AddSpell(new /obj/effect/proc_holder/spell/borer_dominate)

/mob/living/simple_animal/borer/proc/RemoveBorerSpells()
	mind?.RemoveSpell(/obj/effect/proc_holder/spell/borer_infest)
	mind?.RemoveSpell(/obj/effect/proc_holder/spell/borer_dominate)

/mob/living/simple_animal/borer/proc/GrantInfestActions()
	talk_to_host_action.Grant(src)
	leave_body_action.Grant(src)
	take_control_action.Grant(src)
	make_chems_action.Grant(src)

/mob/living/simple_animal/borer/proc/RemoveInfestActions()
	talk_to_host_action.Remove(src)
	take_control_action.Remove(src)
	leave_body_action.Remove(src)
	make_chems_action.Remove(src)

/mob/living/simple_animal/borer/proc/GrantControlActions()
	talk_to_brain_action.Grant(host)
	give_back_control_action.Grant(host)
	make_larvae_action.Grant(host)
	sneak_mode_action.Grant(host)
	torment_action.Grant(host)

/mob/living/simple_animal/borer/proc/RemoveControlActions()
	talk_to_brain_action.Remove(host)
	make_larvae_action.Remove(host)
	give_back_control_action.Remove(host)
	sneak_mode_action.Remove(host)
	torment_action.Remove(host)

/datum/action/innate/borer
	background_icon_state = "bg_alien"

/datum/action/innate/borer/talk_to_host
	name = "Converse with Host"
	desc = "Send a silent message to your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_host/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.Communicate()

/datum/action/innate/borer/toggle_hide
	name = "Toggle Hide"
	desc = "Become invisible to the common eye. Toggled on or off."
	button_icon_state = "borer_hiding_false"

/datum/action/innate/borer/toggle_hide/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.hide_borer()
	button_icon_state = "borer_hiding_[B.hiding ? "true" : "false"]"
	UpdateButtonIcon()

/datum/action/innate/borer/talk_to_borer
	name = "Converse with Borer"
	desc = "Communicate mentally with your borer."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_borer/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.borer_comm()

/datum/action/innate/borer/talk_to_brain
	name = "Converse with Trapped Mind"
	desc = "Communicate mentally with the trapped mind of your host."
	button_icon_state = "alien_whisper"

/datum/action/innate/borer/talk_to_brain/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.trapped_mind_comm()

/datum/action/innate/borer/take_control
	name = "Assume Control"
	desc = "Fully connect to the brain of your host."
	button_icon_state = "borer_brain"

/datum/action/innate/borer/take_control/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.bond_brain()

/datum/action/innate/borer/give_back_control
	name = "Release Control"
	desc = "Release control of your host's body."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/give_back_control/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.release_control()

/datum/action/innate/borer/leave_body
	name = "Release Host"
	desc = "Slither out of your host."
	button_icon_state = "borer_leave"

/datum/action/innate/borer/leave_body/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.release_host()

/datum/action/innate/borer/make_chems
	name = "Secrete Chemicals"
	desc = "Push some chemicals into your host's bloodstream."
	button_icon_state = "fleshmend"

/datum/action/innate/borer/make_chems/Activate()
	var/mob/living/simple_animal/borer/B = owner
	B.secrete_chemicals()

/datum/action/innate/borer/make_larvae
	name = "Reproduce"
	desc = "Spawn several young."
	button_icon_state = "borer_reproduce"

/datum/action/innate/borer/make_larvae/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.spawn_larvae()

/datum/action/innate/borer/torment
	name = "Torment Host"
	desc = "Punish your host with agony."
	button_icon_state = "blind"

/datum/action/innate/borer/torment/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.punish_host()

/datum/action/innate/borer/sneak_mode
	name = "Sneak mode"
	desc = "Hides your status from medical huds."
	button_icon_state = "chameleon_skin"

/datum/action/innate/borer/sneak_mode/Activate()
	var/mob/living/simple_animal/borer/B = owner.has_brain_worms()
	B.host = owner
	B.host.sneak_mode()
