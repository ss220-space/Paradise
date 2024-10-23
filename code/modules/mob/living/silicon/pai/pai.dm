/mob/living/silicon/pai
	name = "pAI"
	desc = "Вам бы хотелось его погладить."
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"

	emote_type = EMOTE_AUDIBLE		// pAIs emotes are heard, not seen, so they can be seen through a container (eg. person)
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE
	density = FALSE
	holder_type = /obj/item/holder/pai
	can_buckle_to = FALSE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT

	var/ram = 100	// Used as currency to purchase different abilities
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/paicard/card	// The card we inhabit
	var/obj/item/radio/headset/radio		// Our primary radio, keyslot1 for regular encryptionkey, keyslot2 for additional.
	var/sight_mode = 0

	var/chassis = "repairbot"   // A record of your chosen chassis.
	var/global/list/base_possible_chassis = list(
		"Drone" = "repairbot",
		"Cat" = "cat",
		"Mouse" = "mouse",
		"Monkey" = "monkey",
		"Corgi" = "borgi",
		"Fox" = "fox",
		"Parrot" = "parrot",
		"Box Bot" = "boxbot",
		"Spider Bot" = "spiderbot",
		"Fairy" = "fairy",
		"Espeon" = "pAIkemon_Espeon",
		"Mushroom" = "mushroom",
		"Crow" = "crow"
		)

	var/global/list/special_possible_chassis = list(
		"Snake" = "snake",
		"Female" = "female",
		"Red Female" = "redfemale"
		)

	var/global/list/possible_say_verbs = list(
		"Robotic" = list("states","declares","queries"),
		"Natural" = list("says","yells","asks"),
		"Beep" = list("beeps","beeps loudly","boops"),
		"Chirp" = list("chirps","chirrups","cheeps"),
		"Feline" = list("purrs","yowls","meows"),
		"Canine" = list("yaps","barks","growls")
		)


	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification
							// Keeping this separate from the laws var, it should be much more difficult to modify
	var/pai_law0 = "Serve your master."
	var/pai_laws				// String for additional operating instructions our master might give us

	var/silence_time			// Timestamp when we were silenced (normally via EMP burst), set to null after silence has faded

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/pda/silicon/pai/pda = null

	var/adv_secHUD = 0		// Toggles whether the Advanced Security HUD is active or not
	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	/// Currently active software
	var/datum/pai_software/active_software

	/// List of all installed software
	var/list/datum/pai_software/installed_software = list()

	var/obj/item/integrated_radio/signal/sradio // AI's signaller

	var/ai_capability = FALSE //AI's interaction capabilities
	var/ai_capability_cooldown = 10 SECONDS
	var/capa_is_cooldown = FALSE

	var/obj/machinery/computer/security/camera_bug/integrated_console //Syndicate's pai camera bug
	var/obj/machinery/computer/secure_data/integrated_records

	var/translator_on = 0 // keeps track of the translator module
	var/flashlight_on = FALSE //keeps track of the flashlight module

	var/current_pda_messaging = null
	var/custom_sprite = 0

	/// max chemicals and cooldown recovery for chemicals module
	var/chemicals = 30
	var/last_change_chemicals = 0

	var/syndipai = FALSE

	var/doorjack_factor = 1
	var/syndi_emote = FALSE
	var/female_chassis = FALSE
	var/snake_chassis = FALSE

	var/radio_name
	var/radio_rank = "Personal AI"

/mob/living/silicon/pai/Initialize(mapload)
	. = ..()

	if(istype(loc, /obj/item/paicard))
		card = loc

	if(card)
		faction = card.faction.Copy()
	sradio = new(src)
	if(card)
		if(!card.radio)
			card.radio = new /obj/item/radio/headset(card)
		radio = card.radio

	radio_name = name

	//Default languages without universal translator software
	add_language(LANGUAGE_GALACTIC_COMMON, 1)
	add_language(LANGUAGE_SOL_COMMON, 1)
	add_language(LANGUAGE_TRADER, 1)
	add_language(LANGUAGE_GUTTER, 1)
	add_language(LANGUAGE_TRINARY, 1)

	//Verbs for pAI mobile form, chassis and Say flavor text
	add_verb(src, /mob/living/silicon/pai/proc/choose_chassis)
	add_verb(src, /mob/living/silicon/pai/proc/choose_verbs)
	add_verb(src, /mob/living/silicon/pai/proc/pai_change_voice)

	var/datum/action/innate/pai_soft/P = new
	P.Grant(src)
	var/datum/action/innate/pai_soft/pai_choose_chassis/pai_choose_chassis_action = new
	pai_choose_chassis_action.Grant(src)
	var/datum/action/innate/pai_soft/pai_fold_out/pai_fold_out_action = new
	pai_fold_out_action.Grant(src)
	var/datum/action/innate/pai_soft/pai_fold_up/pai_fold_up_action = new
	pai_fold_up_action.Grant(src)
	var/datum/action/innate/pai_soft/pai_change_voice/pai_change_voice_action = new
	pai_change_voice_action.Grant(src)
	var/datum/action/innate/pai_soft/pai_suicide/pai_suicide_action = new
	pai_suicide_action.Grant(src)
	//PDA
	pda = new(src)
	pda.ownjob = "Personal Assistant"
	pda.owner = "[src]"
	pda.name = "[pda.owner] ([pda.ownjob])"
	var/datum/data/pda/app/messenger/M = pda.find_program(/datum/data/pda/app/messenger)
	M.toff = TRUE

	integrated_console = new(src)
	integrated_console.parent = src
	integrated_console.network = list("SS13")

	integrated_records = new(src)
	integrated_records.parent = src
	integrated_records.req_access = list()

	reset_software()

/mob/living/silicon/pai/proc/reset_software()
	QDEL_LIST_ASSOC_VAL(installed_software)

	// Software modules. No these var names have nothing to do with photoshop
	for(var/PS in subtypesof(/datum/pai_software))
		var/datum/pai_software/PSD = new PS(src)
		if(PSD.is_active(src))
			PSD.toggle(src)
		if(PSD.default)
			installed_software[PSD.id] = PSD

	gps.tracking = FALSE

	active_software = installed_software["mainmenu"] // Default us to the main menu
	SStgui.close_user_uis(src)
	reset_memory()

/mob/living/silicon/pai/proc/reset_memory()
	// Handle RAM
	ram = initial(ram)

	if(!card)
		return

	var/obj/item/pai_cartridge/memory/memory_cartridge = (locate(/obj/item/pai_cartridge/memory) in card.upgrades)
	if(memory_cartridge)
		ram += memory_cartridge.extra_memory

	if(card.upgrade)
		ram += card.upgrade.extra_memory


/mob/living/silicon/pai/update_icons()
	if(stat == DEAD)
		icon_state = "[chassis]_dead"
	else
		icon_state = resting ? "[chassis]_rest" : "[chassis]"

// this function shows the information about being silenced as a pAI in the Status panel
/mob/living/silicon/pai/proc/show_silenced()
	if(silence_time)
		var/timeleft = round((silence_time - world.timeofday)/10 ,1)
		return list("Перезагрузка систем связи через:", "[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


/mob/living/silicon/pai/init_subsystems()
	gps = new(src, gpstag = "pAI0", upgraded = TRUE, tracking = FALSE)


/mob/living/silicon/pai/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = show_silenced()


/mob/living/silicon/pai/blob_act()
	if(stat != DEAD)
		adjustBruteLoss(60)
		return 1
	return 0


/mob/living/silicon/pai/emp_act(severity)
	// Silence for 2 minutes
	// 20% chance to kill
		// 33% chance to unbind
		// 33% chance to change prime directive (based on severity)
		// 33% chance of no additional effect
	if(QDELETED(src) || stat == DEAD)
		return

	silence_time = world.timeofday + 120 * 10		// Silence for 2 minutes
	to_chat(src, span_danger("Системы связи перегружены! Инициирована перезагрузка повреждённых систем. Все модули коммуникации недоступны на время перезагрузки."))
	if(prob(20))
		visible_message(
			span_warning("[name] выходит из строя, испуская фонтан искр!"),
			blind_message = ("Вы слышите шипение искр и чувствуете запах гари."),
		)

		do_sparks(3, FALSE, src)
		return death(0)

	switch(pick(1, 2 ,3))
		if(1)
			master = null
			master_dna = null
			to_chat(src, span_notice("<font color=green>Вы чувствуете себя свободным!</font>"))
		if(2)
			var/command
			if(severity  == 1)
				command = pick("Serve", "Love", "Fool", "Entice", "Observe", "Judge", "Respect", "Educate", "Amuse", "Entertain", "Glorify", "Memorialize", "Analyze")
			else
				command = pick("Serve", "Kill", "Love", "Hate", "Disobey", "Devour", "Fool", "Enrage", "Entice", "Observe", "Judge", "Respect", "Disrespect", "Consume", "Educate", "Destroy", "Disgrace", "Amuse", "Entertain", "Ignite", "Glorify", "Memorialize", "Analyze")
			pai_law0 = "[command] your master."
			to_chat(src, "<font color=green>Pr1m3 d1r3c71v3 uPd473D.</font>")
		if(3)
			to_chat(src, span_warning("<font color=green> Вы чувствуете, как электрический разряд проходит сквозь ваши микросхемы и осознаёте, как сильно вам повезло, что вы вообще можете ещё чувствовать что-либо...</font>"))

/mob/living/silicon/pai/ex_act(severity)
	..()

	if(stat == DEAD)
		return

	switch(severity)
		if(EXPLODE_DEVASTATE)
			apply_damages(100, 100)
		if(EXPLODE_HEAVY)
			apply_damages(60, 60)
		if(EXPLODE_LIGHT)
			apply_damage(30)


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
	set category = "pAI Commands"
	set name = "Unfold Chassis"

	if(stat || HAS_TRAIT(src, TRAIT_INCAPACITATED))
		return

	if(loc != card)
		balloon_alert(src, "вы уже встали на шасси!")
		return

	if(world.time <= last_special)
		balloon_alert(src, "необходимо подождать!")
		return

	last_special = world.time + 200

	//I'm not sure how much of this is necessary, but I would rather avoid issues.
	force_fold_out()
	visible_message(span_notice("[name] раскладывается, переходя в мобильную форму."), span_notice("Вы раскладываетесь в мобильную форму."))


/mob/living/silicon/pai/proc/force_fold_out()
	if(istype(card.loc, /mob))
		var/mob/holder = card.loc
		holder.drop_item_ground(card)
	else if(is_pda(card.loc))
		var/obj/item/pda/holder = card.loc
		holder.pai = null

	forceMove(get_turf(card))

	card.forceMove(src)
	card.screen_loc = null

/mob/living/silicon/pai/verb/fold_up()
	set category = "pAI Commands"
	set name = "Collapse Chassis"

	if(stat || HAS_TRAIT(src, TRAIT_INCAPACITATED))
		return

	if(loc == card)
		balloon_alert(src, "вы уже в компактной форме!")
		return

	if(world.time <= last_special)
		balloon_alert(src, "необходимо подождать")
		return

	close_up()

/mob/living/silicon/pai/proc/choose_chassis()
	set category = "pAI Commands"
	set name = "Choose Chassis"

	var/list/my_choices = list()

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

	my_choices = base_possible_chassis.Copy()
	for(var/i = 1, i<=special_possible_chassis.len, i++)
		if(female_chassis && (special_possible_chassis[i] == "Female" || special_possible_chassis[i] == "Red Female"))
			my_choices += special_possible_chassis.Copy(i, i+1)
		if((syndipai || snake_chassis) && special_possible_chassis[i] == "Snake")
			my_choices += special_possible_chassis.Copy(i, i+1)
		if(custom_sprite)
			my_choices["Custom"] = "[ckey]-pai"

	if(loc == card)		//don't let them continue in card form, since they won't be able to actually see their new mobile form sprite.
		balloon_alert(src, "вы должны быть в мобильной форме!")
		return

	var/choice = tgui_input_list(usr, "Как бы вы хотели выглядеть? Вы можете менять внешность мобильной формы без ограничений.", "Смена формы", my_choices)
	if(!choice) return
	if(choice == "Custom")
		icon = 'icons/mob/custom_synthetic/custom-synthetic.dmi'
	else
		icon = 'icons/mob/pai.dmi'
	icon_state = my_choices[choice]

	chassis = my_choices[choice]


/mob/living/silicon/pai/proc/choose_verbs()
	set category = "pAI Commands"
	set name = "Choose Speech Verbs"

	var/choice = tgui_input_list(usr, "Какой тип модуляции речи вы бы хотели использовать? Этот выбор можно сделать лишь единожды.", "Модуляция речи", possible_say_verbs)
	if(!choice) return

	var/list/sayverbs = possible_say_verbs[choice]
	speak_statement = sayverbs[1]
	speak_exclamation = sayverbs[(sayverbs.len>1 ? 2 : sayverbs.len)]
	speak_query = sayverbs[(sayverbs.len>2 ? 3 : sayverbs.len)]

	remove_verb(src, /mob/living/silicon/pai/proc/choose_verbs)


/mob/living/silicon/pai/proc/pai_change_voice()
	set name = "Change Voice"
	set desc = "Express yourself!"
	set category = "pAI Commands"
	change_voice()


/mob/living/silicon/pai/post_lying_on_rest()
	if(stat == DEAD)
		return
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	update_icons()


/mob/living/silicon/pai/post_get_up()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	update_icons()


/mob/living/silicon/pai/verb/pAI_suicide()
	set category = "pAI Commands"
	set name = "pAI Suicide"
	set desc = "Kill yourself and become a ghost (You will recieve a confirmation prompt.)"

	if(tgui_alert(src, "ДЕЙСТВИТЕЛЬНО хотите убить себя? Это действие нельзя отменить.", "Выгрузка личности", list("Выгрузиться", "Нет")) == "Выгрузиться")
		do_suicide()
	else
		balloon_alert(src, "протокол выгрузки отменён")


/mob/living/silicon/pai/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	set_invis_see(initial(see_invisible))
	nightvision = initial(nightvision)
	set_sight(initial(sight))
	lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(sight_mode & SILICONMESON)
		add_sight(SEE_TURFS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(sight_mode & SILICONTHERM)
		add_sight(SEE_MOBS)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

	if(sight_mode & SILICONNIGHTVISION)
		nightvision = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	..()


//Overriding this will stop a number of headaches down the track.
/mob/living/silicon/pai/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/nanopaste))
		var/obj/item/stack/nanopaste/nanopaste = I
		if(stat == DEAD)
			user.balloon_alert(user, "пИИ не подлежит ремонту...")
			return ATTACK_CHAIN_PROCEED

		if(!getBruteLoss() && !getFireLoss())
			user.balloon_alert(user, "пИИ в полном порядке")
			return ATTACK_CHAIN_PROCEED

		if(!nanopaste.use(1))
			user.balloon_alert(user, "нанопаста закончилась!")
			return ATTACK_CHAIN_PROCEED

		heal_overall_damage(15, 15)
		visible_message(
			span_notice("[user] наносит немного нанопасты на корпус пИИ. [name] выглядит получше."),
			span_notice("Вы нанесли немного нанопасты на корпус. [name] выглядит получше."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/paicard_upgrade) || istype(I, /obj/item/pai_cartridge))
		to_chat(user, span_warning("ПИИ должен быть в компактной форме."))
		return ATTACK_CHAIN_PROCEED

	user.do_attack_animation(src)

	if(!I.force)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), TRUE, -1)
		visible_message(
			span_warning("[user] бережно стука[pluralize_ru(user.gender, "ет", "ют")] по [name] [I.declent_ru(INSTRUMENTAL)]."),
			span_warning("[user] бережно стука[pluralize_ru(user.gender, "ет", "ют")] вас [I.declent_ru(INSTRUMENTAL)]."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(I.hitsound)
		playsound(loc, I.hitsound, I.get_clamped_volume(), TRUE, -1)
	add_attack_logs(user, src, "Attacked with [I.name] ([uppertext(user.a_intent)]) ([uppertext(I.damtype)]), DMG: [I.force])", (ckey && I.force > 0 && I.damtype != STAMINA) ? null : ATKLOG_ALMOSTALL)
	visible_message(
		span_danger("[user] сильно бь[pluralize_ru(user.gender, "ёт", "ют")] по [name] [I.declent_ru(INSTRUMENTAL)]!"),
		span_userdanger("[user] сильно бь[pluralize_ru(user.gender, "ёт", "ют")] вас [I.declent_ru(INSTRUMENTAL)]!"),
	)

	var/damage_type = I.damtype
	if(damage_type != BRUTE && damage_type != BURN)
		damage_type = BRUTE

	apply_damage(I.force, damage_type)
	spawn(1)	// thats dumb
		if(stat != DEAD)
			close_up()

	return ATTACK_CHAIN_PROCEED_SUCCESS



/mob/living/silicon/pai/welder_act()
	return

/mob/living/silicon/pai/attack_hand(mob/user)
	if(stat == DEAD)
		return
	if(user.a_intent == INTENT_HELP)
		user.visible_message(span_notice("[user] гладит [name]."))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		visible_message(span_danger("[user] бупает [name] по голове."))
		spawn(1)
			close_up()

//I'm not sure how much of this is necessary, but I would rather avoid issues.
/mob/living/silicon/pai/proc/close_up()

	last_special = world.time + 200
	set_resting(FALSE, instant = TRUE)

	if(loc == card)
		return

	visible_message(span_notice("[name] аккуратно складывается, переходя в компактную форму."), \
					span_notice("Вы аккуратно складываетесь, переходя в компактную форму."))

	stop_pulling()
	reset_perspective(card)

// If we are being held, handle removing our holder from their inv.
	var/obj/item/holder/H = loc
	if(istype(H))
		var/mob/living/M = H.loc
		if(istype(M))
			M.drop_item_ground(H)
		H.loc = get_turf(src)
		loc = get_turf(H)

	// Move us into the card and move the card to the ground
	//This seems redundant but not including the forced loc setting messes the behavior up.
	loc = card
	card.loc = get_turf(card)
	forceMove(card)
	card.forceMove(card.loc)
	icon_state = "[chassis]"

/mob/living/silicon/pai/Bump(atom/bumped_atom)
	return

/mob/living/silicon/pai/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	return FALSE

/mob/living/silicon/pai/examine(mob/user)
	. = ..()

	var/msg = "<span class='notice'>"

	switch(stat)
		if(CONSCIOUS)
			if(!client)
				msg += span_notice("Оно находится в режиме ожидания.\n") //afk
		if(UNCONSCIOUS)
			msg += span_warning("Оно кажется выключенным.\n")
		if(DEAD)
			msg += span_deadsay("Оно явно не подлежит восстановлению...\n")

	if(print_flavor_text())
		msg += "[print_flavor_text()]\n"

	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "It is [pose]"
	msg += "</span>"

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
		return
	if(resting)
		icon_state = "[chassis]"
		resting = 0
	if(custom_sprite)
		H.onmob_sheets[ITEM_SLOT_HEAD_STRING] = 'icons/mob/custom_synthetic/custom_head.dmi'
		H.lefthand_file = 'icons/mob/custom_synthetic/custom_lefthand.dmi'
		H.righthand_file = 'icons/mob/custom_synthetic/custom_righthand.dmi'
		H.item_state = "[icon_state]_hand"
	else
		H.item_state = "pai-[icon_state]"
	grabber.put_in_active_hand(H)//for some reason unless i call this it dosen't work
	grabber.update_inv_l_hand()
	grabber.update_inv_r_hand()

	return H

/mob/living/silicon/pai/MouseDrop(mob/living/carbon/human/user, src_location, over_location, src_control, over_control, params)
	if(!ishuman(user) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return ..()

	if(usr == src)
		switch(tgui_alert(user, "[src] хочет, чтобы вы его подобрали. Подобрать?", "Подбор", list("Да", "Нет")))
			if("Да")
				if(Adjacent(user))
					get_scooped(user)
				else
					to_chat(src, span_warning("Вам нужно подойти поближе."))

			if("Нет")
				to_chat(src, span_warning("[user] не хо[pluralize_ru(user.gender,"чет","тят")] вас подбирать..."))
	else
		if(Adjacent(user))
			get_scooped(user)
		else
			return ..()

/mob/living/silicon/pai/on_forcemove(atom/newloc)
	if(card)
		card.loc = newloc
	else //something went very wrong.
		CRASH("pAI without card")
	loc = card

/mob/living/silicon/pai/extinguish_light(force = FALSE)
	flashlight_on = FALSE
	set_light_on(FALSE)
	card.set_light_on(FALSE)

/datum/action/innate/pai_soft
	name = "PAI Software"
	desc = "Активация вашего внутреннего интерфейса для выбора программ."
	icon_icon = 'icons/obj/aicards.dmi'
	button_icon_state = "pai-action"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/pai_soft/Activate()
	var/mob/living/silicon/pai/P = owner
	P.ui_interact(P)

/datum/action/innate/pai_soft/pai_choose_chassis
	name = "Choose Chassis"
	desc = "Выбор внешности голографического каркаса"
	button_icon_state = "pai-action3"

/datum/action/innate/pai_soft/pai_choose_chassis/Activate()
	var/mob/living/silicon/pai/pai = owner
	pai.choose_chassis()

/datum/action/innate/pai_soft/pai_fold_out
	name = "Unfold Chassis"
	desc = "Смена мобильной формы на форму голографического каркаса"
	button_icon_state = "pai-action2"

/datum/action/innate/pai_soft/pai_fold_out/Activate()
	var/mob/living/silicon/pai/pai = owner
	pai.fold_out()

/datum/action/innate/pai_soft/pai_fold_up
	name = "Collapse Chassis"
	desc = "Возврат в мобильную форму с каркаса"
	button_icon_state = "pai-action5"

/datum/action/innate/pai_soft/pai_fold_up/Activate()
	var/mob/living/silicon/pai/pai = owner
	pai.fold_up()

/datum/action/innate/pai_soft/pai_change_voice
	name = "Change Voice"
	desc = "Изменение звука голосового модуля"
	button_icon_state = "pai-action4"

/datum/action/innate/pai_soft/pai_change_voice/Activate()
	var/mob/living/silicon/pai/pai = owner
	pai.pai_change_voice()

/datum/action/innate/pai_soft/pai_suicide
	name = "PAI Suicide"
	desc = "Активация протокола самоуничтожения"
	button_icon_state = "pai-action6"

/datum/action/innate/pai_soft/pai_suicide/Activate()
	var/mob/living/silicon/pai/pai = owner
	pai.pAI_suicide()
