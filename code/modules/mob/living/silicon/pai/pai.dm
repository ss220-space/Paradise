/mob/living/silicon/pai
	name = "ПИИ"
	icon = 'icons/mob/pai.dmi'//
	icon_state = "repairbot"

	robot_talk_understand = 0
	emote_type = 2		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE
	density = 0
	holder_type = /obj/item/holder/pai

	var/ram = 100	// Used as currency to purchase different abilities
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/paicard/card	// The card we inhabit
	var/obj/item/radio/radio		// Our primary radio

	var/chassis = "repairbot"   // A record of your chosen chassis.
	var/global/list/possible_chassis = list(
		"Дрон" = "repairbot",
		"Корги" = "borgi",
		"Коробкобот" = "boxbot",
		"Кот" = "cat",
		"Лиса" = "fox",
		"Макака" = "monkey",
		"Мышь" = "mouse",
		"Попугай" = "parrot",
		"Спайдербот" = "spiderbot",
		"Фея" = "fairy"
		)

	var/global/list/possible_say_verbs = list(
		"Бипбупанье" = list("бипает","громко бипает","бупает"),
		"Человеческий" = list("говорит","кричит","спрашивает"),
		"Кошачий" = list("мурлычет","вопит","мяучит"),
		"Роботизированный" = list("утверждает","объявляет","запрашивает"),
		"Собачий" = list("тявкает","лает","рычит"),
		"Чириканье" = list("чирикает","щебечет","пищит"),
		)


	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification
							// Keeping this separate from the laws var, it should be much more difficult to modify
	var/pai_law0 = "Служите своему хозяину."
	var/pai_laws				// String for additional operating instructions our master might give us

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/pda/silicon/pai/pda = null

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	/// Currently active software
	var/datum/pai_software/active_software

	/// List of all installed software
	var/list/datum/pai_software/installed_software = list()

	var/obj/item/integrated_radio/signal/sradio // AI's signaller

	var/translator_on = 0 // keeps track of the translator module
	var/flashlight_on = FALSE //keeps track of the flashlight module

	var/current_pda_messaging = null
	var/custom_sprite = 0
	var/slowdown = 0

/mob/living/silicon/pai/New(var/obj/item/paicard)
	loc = paicard
	card = paicard
	if(card)
		faction = card.faction.Copy()
	sradio = new(src)
	if(card)
		if(!card.radio)
			card.radio = new /obj/item/radio(card)
		radio = card.radio

	//Default languages without universal translator software
	add_language("Galactic Common", 1)
	add_language("Sol Common", 1)
	add_language("Tradeband", 1)
	add_language("Gutter", 1)
	add_language("Trinary", 1)

	//Verbs for pAI mobile form, chassis and Say flavor text
	verbs += /mob/living/silicon/pai/proc/choose_chassis
	verbs += /mob/living/silicon/pai/proc/choose_verbs

	//PDA
	pda = new(src)
	pda.ownjob = "Личный помощник"
	pda.owner = "[src]"
	pda.name = "[pda.owner] ([pda.ownjob])"
	var/datum/data/pda/app/messenger/M = pda.find_program(/datum/data/pda/app/messenger)
	M.toff = TRUE

	// Software modules. No these var names have nothing to do with photoshop
	for(var/PS in subtypesof(/datum/pai_software))
		var/datum/pai_software/PSD = new PS(src)
		if(PSD.default)
			installed_software[PSD.id] = PSD

	active_software = installed_software["mainmenu"] // Default us to the main menu
	..()

/mob/living/silicon/pai/can_unbuckle()
	return FALSE

/mob/living/silicon/pai/can_buckle()
	return FALSE

/mob/living/silicon/pai/movement_delay()
	. = ..()
	. += slowdown
	. += 1 //A bit slower than humans, so they're easier to smash
	. += config.robot_delay

/mob/living/silicon/pai/update_icons()
	if(stat == DEAD)
		icon_state = "[chassis]_dead"
	else
		icon_state = resting ? "[chassis]_rest" : "[chassis]"

// this function shows the information about being silenced as a pAI in the Status panel
/mob/living/silicon/pai/proc/show_silenced()
	if(silence_time)
		var/timeleft = round((silence_time - world.timeofday)/10 ,1)
		stat(null, "Перезагрузка система коммуникаций через [(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


/mob/living/silicon/pai/Stat()
	..()
	statpanel("Status")
	if(client.statpanel == "Status")
		show_silenced()

	if(proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)

/mob/living/silicon/pai/blob_act()
	if(stat != DEAD)
		adjustBruteLoss(60)
		return 1
	return 0

/mob/living/silicon/pai/restrained()
	if(istype(loc,/obj/item/paicard))
		return 0
	..()

/mob/living/silicon/pai/MouseDrop(atom/over_object)
	return

/mob/living/silicon/pai/emp_act(severity)
	// Silence for 2 minutes
	// 20% chance to kill
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect

	silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	to_chat(src, "<font color=green><b>Перегрузка коммуникационного контура. Отключение и перезагрузка коммуникационного контура… Функции речи и обмена сообщениями будут недоступны до завершения перезагрузки.</b></font>")
	if(prob(20))
		var/turf/T = get_turf_or_move(loc)
		for(var/mob/M in viewers(T))
			M.show_message("<span class='warning'>Сноп искр вылетает из [src].</span>", 3, "<span class='warning'>Вы чувствуете запах озона и слышите громкий треск электрических искр.</span>", 2)
		return death(0)

	switch(pick(1,2,3))
		if(1)
			master = null
			master_dna = null
			to_chat(src, "<font color=green>Вы чувствуете свободу.</font>")
		if(2)
			var/command
			if(severity  == 1)
				command = pick("Любите", "Одурачьте", "Entice", "Обольстите", "Судите", "Уважайте", "Обучите", "Забавляйте", "Развлекайте", "Славьте", "Увековечьте", "Анализируйте вслух")
			else
				command = pick("Убейте", "Любите", "Ненавидьте", "Не слушайтесь", "Подчините", "Одурачьте", "Бесите", "Обольстите", "Судите", "Уважайте", "Не уважайте", "Обучите", "Уничтожьте", "Раздражайте", "Предайте", "Продайте", "Опозорьте", "Забавляйте", "Развлекайте", "Подожгите", "Отравите", "Задушите", "Славьте", "Увековечьте", "Анализируйте вслух")
			pai_law0 = "[command] своего хозяина."
			to_chat(src, "<font color=green>0CH0BHA9I DuPEKTuBA u3MEHEHA.</font>")
		if(3)
			to_chat(src, "<font color=green>Электрический импульс проходит по вашим схемам, и вы остро осознаёте, как вам повезло, что вы вообще ещё можете что-то чувствовать…</font>")

/mob/living/silicon/pai/ex_act(severity)
	..()

	switch(severity)
		if(1.0)
			if(stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
		if(2.0)
			if(stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if(stat != 2)
				adjustBruteLoss(30)

	return


// See software.dm for ui_act()

/mob/living/silicon/pai/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		add_attack_logs(M, src, "Animal attacked for [damage] damage")
		adjustBruteLoss(damage)

// Procs/code after this point is used to convert the stationary pai item into a
// mobile pai mob. This also includes handling some of the general shit that can occur
// to it. Really this deserves its own file, but for the moment it can sit here. ~ Z

/mob/living/silicon/pai/verb/fold_out()
	set category = "Команды ПИИ"
	set name = "Развернуть шасси"

	if(stat || sleeping || paralysis || IsWeakened())
		return

	if(loc != card)
		to_chat(src, "<span class='warning'>Вы уже находитесь в мобильной форме!!</span>")
		return

	if(world.time <= last_special)
		to_chat(src, "<span class='warning'>Шасси ещё не готово к развёртыванию, подождите!</span>")
		return

	last_special = world.time + 200

	//I'm not sure how much of this is necessary, but I would rather avoid issues.
	force_fold_out()

	visible_message("<span class='notice'>[src] раскладывается в мобильную форму.</span>", "<span class='notice'>Вы раскладываетесь в мобильную форму.</span>")

/mob/living/silicon/pai/proc/force_fold_out()
	if(istype(card.loc, /mob))
		var/mob/holder = card.loc
		holder.unEquip(card)
	else if(istype(card.loc, /obj/item/pda))
		var/obj/item/pda/holder = card.loc
		holder.pai = null

	forceMove(get_turf(card))

	card.forceMove(src)
	card.screen_loc = null

/mob/living/silicon/pai/verb/fold_up()
	set category = "Команды ПИИ"
	set name = "Сложить шасси"

	if(stat || sleeping || paralysis || IsWeakened())
		return

	if(loc == card)
		to_chat(src, "<span class='warning'>Ваше шасси уже сложено!</span>")
		return

	if(world.time <= last_special)
		to_chat(src, "<span class='warning'>Шасси ещё не готово к свёртыванию, подождите!</span>")
		return

	close_up()

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "Команды ПИИ"
	set name = "Выбрать шасси"

	var/list/my_choices = list()
	var/choice
	var/finalized = "Нет"

	//check for custom_sprite
	if(!custom_sprite)
		var/file = file2text("config/custom_sprites.txt")
		var/lines = splittext(file, "\n")

		for(var/line in lines)
		// split & clean up
			var/list/Entry = splittext(line, ":")
			for(var/i = 1 to Entry.len)
				Entry[i] = trim(Entry[i])

			if(Entry.len < 2 || Entry[1] != "pai")			//ignore incorrectly formatted entries or entries that aren't marked for pAI
				continue

			if(Entry[2] == ckey)							//They're in the list? Custom sprite time, var and icon change required
				custom_sprite = 1
				my_choices["Custom"] = "[ckey]-pai"

	my_choices = possible_chassis.Copy()
	if(custom_sprite)
		my_choices["Custom"] = "[ckey]-pai"

	if(loc == card)		//don't let them continue in card form, since they won't be able to actually see their new mobile form sprite.
		to_chat(src, "<span class='warning'>Для переконфигурации шасси вы должны быть в мобильной форме.</span>")
		return

	while(finalized == "Нет" && client)
		choice = input(usr,"Какой вы хотите выбрать образ в мобильной форме? Выбор может быть сделан только один раз.","Выбор мобильной формы") as null|anything in my_choices
		if(!choice) return
		if(choice == "Custom")
			icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		else
			icon = 'icons/mob/pai.dmi'
		icon_state = my_choices[choice]
		finalized = alert("Взгляните на свой спрайт. Вы именно такой хотели выбрать?",,"Нет","Да")

	chassis = my_choices[choice]
	verbs -= /mob/living/silicon/pai/proc/choose_chassis

/mob/living/silicon/pai/proc/choose_verbs()
	set category = "Команды ПИИ"
	set name = "Выбор голосовых глаголов"

	var/choice = input(usr,"Какой стиль звучание голоса вы предпочитаете?\nВыбор может быть сделан только один раз.","Выбор голоса") as null|anything in possible_say_verbs
	if(!choice) return

	var/list/sayverbs = possible_say_verbs[choice]
	speak_statement = sayverbs[1]
	speak_exclamation = sayverbs[(sayverbs.len>1 ? 2 : sayverbs.len)]
	speak_query = sayverbs[(sayverbs.len>2 ? 3 : sayverbs.len)]

	verbs -= /mob/living/silicon/pai/proc/choose_verbs


/mob/living/silicon/pai/lay_down()
	set category = "IC"
	set name = "Rest"

	// Pass lying down or getting up to our pet human, if we're in a rig.
	if(stat == CONSCIOUS && istype(loc,/obj/item/paicard))
		resting = 0
	else
		resting = !resting
		to_chat(src, "<span class='notice'>Теперь вы [resting ? "отдыхаете" : "встали"].</span>")

	update_icons()
	update_canmove()

//Overriding this will stop a number of headaches down the track.
/mob/living/silicon/pai/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/N = W
		if(stat == DEAD)
			to_chat(user, "<span class='danger'>[src] уже ничем не помочь.</span>")
		else if(getBruteLoss() || getFireLoss())
			heal_overall_damage(15, 15)
			N.use(1)
			user.visible_message("<span class='notice'>[user.name] применя[pluralize_ru(user.gender,"ет","ют")] немного [W] на повреждённые области [src].</span>",\
				"<span class='notice'>Вы применяете немного [W] на повреждённые части [name].</span>")
		else
			to_chat(user, "<span class='notice'>Все системы [name] в порядке.</span>")

		return
	else if(W.force)
		visible_message("<span class='danger'>[user.name] атаку[pluralize_ru(user.gender,"ет","ют")] [src] с помощью [W]!</span>")
		adjustBruteLoss(W.force)
	else
		visible_message("<span class='warning'>[user.name] безвредно стука[pluralize_ru(user.gender,"ет","ют")] [src] с помощью [W].</span>")
	spawn(1)
		if(stat != 2)
			close_up()
	return

/mob/living/silicon/pai/welder_act()
	return

/mob/living/silicon/pai/attack_hand(mob/user as mob)
	if(stat == DEAD)
		return
	if(user.a_intent == INTENT_HELP)
		user.visible_message("<span class='notice'>[user] глад[pluralize_ru(user.gender,"ит","ят")] [src].</span>")
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		visible_message("<span class='danger'>[user.name] щёлка[pluralize_ru(user.gender,"ет","ют")] [src].</span>")
		spawn(1)
			close_up()

//I'm not sure how much of this is necessary, but I would rather avoid issues.
/mob/living/silicon/pai/proc/close_up()

	last_special = world.time + 200
	resting = 0
	if(loc == card)
		return

	visible_message("<span class='notice'>[src] аккуратно складывается в себя, ужимаясь в прямоугольник.</span>", "<span class='notice'>Вы аккуратно складываетесь в себя, ужимаясь в прямоугольник.</span>")

	stop_pulling()
	reset_perspective(card)

// If we are being held, handle removing our holder from their inv.
	var/obj/item/holder/H = loc
	if(istype(H))
		var/mob/living/M = H.loc
		if(istype(M))
			M.unEquip(H)
		H.loc = get_turf(src)
		loc = get_turf(H)

	// Move us into the card and move the card to the ground
	//This seems redundant but not including the forced loc setting messes the behavior up.
	loc = card
	card.loc = get_turf(card)
	forceMove(card)
	card.forceMove(card.loc)
	icon_state = "[chassis]"

/mob/living/silicon/pai/Bump()
	return

/mob/living/silicon/pai/Bumped()
	return

/mob/living/silicon/pai/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	return FALSE

/mob/living/silicon/pai/update_canmove(delay_action_updates = 0)
	. = ..()
	density = 0 //this is reset every canmove update otherwise

/mob/living/silicon/pai/examine(mob/user)
	. = ..()

	var/msg = "<span class='info'>"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += "Кажется, этот ПИИ сейчас в режиме ожидания." //afk
		if(UNCONSCIOUS)
			msg += "\n<span class='warning'>Кажется, этот ПИИ не отвечает.</span>"
		if(DEAD)
			msg += "\n<span class='deadsay'>Этот ПИИ выглядит полностью неисправным.</span>"

	if(print_flavor_text())
		msg += "\n[print_flavor_text()]"

	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "Он[genderize_ru(src.gender,"","а","о","и")] [pose]"
	msg += "\n*---------*</span>"

	. += msg

/mob/living/silicon/pai/bullet_act(var/obj/item/projectile/Proj)
	..(Proj)
	if(stat != 2)
		spawn(1)
			close_up()
	return 2

// No binary for pAIs.
/mob/living/silicon/pai/binarycheck()
	return 0

// Handle being picked up.


/mob/living/silicon/pai/get_scooped(mob/living/carbon/grabber)
	var/obj/item/holder/H = ..()
	if(!istype(H))
		return
	if(stat == DEAD)
		H.icon = 'icons/mob/pai.dmi'
		H.icon_state = "[chassis]_dead"
		return
	if(resting)
		icon_state = "[chassis]"
		resting = 0
	if(custom_sprite)
		H.icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
		H.icon_override = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.icon_state = "[icon_state]"
		H.item_state = "[icon_state]_hand"
	else
		H.icon_state = "pai-[icon_state]"
		H.item_state = "pai-[icon_state]"
	grabber.put_in_active_hand(H)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H

/mob/living/silicon/pai/MouseDrop(atom/over_object)
	var/mob/living/carbon/human/H = over_object //changed to human to avoid stupid issues like xenos holding pAIs.
	if(!istype(H) || !Adjacent(H))  return ..()
	if(usr == src)
		switch(alert(H, "[src] хочет чтобы вы [genderize_ru(src.gender,"его","её","его","их")] подняли. Поднять?",,"Да","Нет"))
			if("Да")
				if(Adjacent(H))
					get_scooped(H)
				else
					to_chat(src, "<span class='warning'>Вам нужно оставаться рядом, чтобы вас подняли.</span>")
			if("Нет")
				to_chat(src, "<span class='warning'>[H] реша[pluralize_ru(H.gender,"ет","ют")] не поднимать вас.</span>")
	else
		if(Adjacent(H))
			get_scooped(H)
		else
			return ..()

/mob/living/silicon/pai/on_forcemove(atom/newloc)
	if(card)
		card.loc = newloc
	else //something went very wrong.
		CRASH("pAI without card")
	loc = card

/mob/living/silicon/pai/extinguish_light()
	flashlight_on = FALSE
	set_light(0)
	card.set_light(0)


/mob/living/silicon/pai/update_runechat_msg_location()
	if(istype(loc, /obj/item/paicard))
		runechat_msg_location = loc
	else
		runechat_msg_location = src
