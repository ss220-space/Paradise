
/mob/living/simple_animal/slime
	var/AIproc = 0 // determines if the AI loop is activated
	var/Atkcool = 0 // attack cooldown
	var/Discipline = 0 // if a slime has been hit with a freeze gun, or wrestled/attacked off a human, they become disciplined and don't attack anymore for a while
	var/Stun_time = 0 // stun variable
	var/Random_phrase_CD = 0

	// only single words commands for more performance
	var/static/list/slimes_names = list("slimes", "slime", "слаймы", "слайм")
	var/static/list/greeting_commands = list("hello", "hi", "hey", "привет", "здравствуй", "здравствуйте", "хай")
	var/static/list/follow_commands = list("follow", "пошли", "пойдём", "пойдем", "пойти", "идём", "идем", "идти")
	var/static/list/stop_commands = list("stop", "фу", "нельзя", "хватит", "перестань", "перестать", "прекрати", "прекратить")
	var/static/list/stay_commands = list("stay", "остановись", "стоять", "стой")
	var/static/list/attack_commands = list("attack", "бей", "бить", "атакуй", "атаковать", "нападай", "нападать", "напади", "ударь", "ударить", "фас", "апорт")
	var/static/list/eat_commands = list("eat", "ешь", "есть", "кушай", "кушать", "съешь", "съесть")
	var/static/list/defend_commands = list("defend", "защищай", "защищать", "помогай", "помоги", "помогать", "охраняй", "охранять")
	var/static/list/reproduce_commands = list("reproduce", "делись", "размножайся")
	var/static/list/no_reproduce_commands = list("grow", "расти")

	//Slime responce phrases
	var/static/list/greeting_phrases = list("Привет...", "Здравствовать...")
	var/static/list/follow_phrases = list("Вести...", "Пойти... ", "Моя идти... ")
	var/static/list/no_follow_phrases = list("Нет...", "Не идти...", "Не хотеть...")
	var/static/list/already_follow_phrases = list("Моя уже...", "Да...", "Идти...", "Следовать...")
	var/static/list/stay_phrases = list("Стоять...")
	var/static/list/no_stay_phrases = list("Нет... Не хотеть...")
	var/static/list/no_stay_follow_phrases = list("Нет... Моя следовать...")
	var/static/list/stop_attacking_phrases = list("Хорошо...", "Понимать...")
	var/static/list/stop_attacking_angry_phrases = list("Гррр...")
	var/static/list/stop_following_phrases = list("Больше не следовать...")
	var/static/list/stop_defend_phrases = list("Больше не защищать...")
	var/static/list/no_listen_phrases = list("Нет...", "Не буду...", "Не хотеть...", "Не слушать...")
	var/static/list/madness_phrases = list("ААААААА!?!?", "ЧАВО?!?!", "БИТЬ!")
	var/static/list/reproduce_phrases = list("Размножаться...")
	var/static/list/no_reproduce_phrases = list("Расти...")
	var/static/list/dont_recognize_phrases = list("Кого?", "Не понимать...", "Кто это?", "Не видеть")

/mob/living/simple_animal/slime/forceMove(atom/destination) //Debug code to catch slimes stuck in null space
	. = ..()
	if(!destination && !QDELETED(src))
		stack_trace("Slime moved to null space")


/mob/living/simple_animal/slime/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/temperature_diff = get_temperature(environment) - bodytemperature
	if(abs(temperature_diff) > 5)
		temperature_diff /=  5
		adjust_bodytemperature(temperature_diff)

	if(bodytemperature < SLIME_THAW_T)
		if(bodytemperature < SLIME_THAW_T)
			canmove = FALSE

		if(bodytemperature >= 0 && bodytemperature < SLIME_HURT_T)
			//SLIME_MAX_T_DMG at 0°, SLIME_MIN_T_DMG at SLIME_HURT_TEMPERATURE°С and linearly connects between them
			var/dmg = SLIME_MAX_T_DMG - (SLIME_MAX_T_DMG - SLIME_MIN_T_DMG)/SLIME_HURT_T*bodytemperature
			adjustBruteLoss(dmg)
	else
		canmove = TRUE

	updatehealth("handle environment")


/mob/living/simple_animal/slime/handle_status_effects()
	adjustBruteLoss(-passive_regeneration)

	attacked = clamp(attacked - 1, 0, 50)

	if(prob(10))
		Discipline = max(0, Discipline - 1)

	if(Discipline >= 5 && rabid && prob(60))
		rabid = FALSE


/mob/living/simple_animal/slime/Life()
	set invisibility = 0
	if(notransform)
		return
	if(..())		// if stat != DEAD

		//eat if buckled
		if(buckled)
			handle_feeding()

		//handle passive hunger, reproduce & evolve
		handle_nutrition()

		// Stop if the slime split during handle_nutrition()
		if(QDELETED(src))
			return

		// Handle reagents in slime
		handle_reagents()

		handle_targets()
		if(!ckey)
			handle_mood()
			handle_speech()
			handle_random_phrases()


/mob/living/simple_animal/slime/proc/handle_feeding()
	if(!isliving(buckled))
		return
	var/mob/living/L = buckled

	if(stat)
		Feedstop(stop_message = FALSE)

	if(L.stat == DEAD) // our victim died
		if(!client)
			if(!rabid && !attacked)
				if(L.LAssailant && L.LAssailant != L)
					if(prob(50))
						if(!(L.LAssailant in Friends))
							Friends[L.LAssailant] = 1
						else
							++Friends[L.LAssailant]
		else
			to_chat(src, "<i>This subject does not have a strong enough life energy anymore...</i>")

		if(L.client && ishuman(L))
			rabid = TRUE //we go rabid after finishing to feed on a human with a client.

		Feedstop()
		return

	if(!iscarbon(L) && !isanimal(L))
		Feedstop(incompatible = TRUE)
		return

	var/feed_mod = round(age_state.feed/3)
	var/totaldamage = 0
	totaldamage += L.adjustCloneLoss(rand(2, 4) + feed_mod)
	totaldamage += L.adjustToxLoss(rand(1, 2) + feed_mod)

	if(totaldamage <= 0) //if we did no(or negative!) damage to it, stop
		Feedstop(incompatible = TRUE)
		return

	if(L.client && prob(10))
		to_chat(L, span_userdanger(pick("You can feel your body becoming weak!", \
		"You feel like you're about to die!", \
		"You feel every part of your body screaming in agony!", \
		"A low, rolling pain passes through your body!", \
		"Your body feels as if it's falling apart!", \
		"You feel extremely weak!", \
		"A sharp, deep pain bathes every inch of your body!")))

	//Передача нутриентов, + небольшое поедание внутренних запасов, не смотря на поедание плоти (урон)
	var/nutrition_rand = rand(7 + age_state.feed * 2, 15 + age_state.feed * 4)
	add_nutrition(nutrition_rand)
	L.adjust_nutrition(-round(nutrition_rand / 4))

	//Heal yourself.
	adjustBruteLoss(-(3 + round(nutrition_rand / 4)))


/mob/living/simple_animal/slime/proc/add_nutrition(nutrition_to_add)
	set_nutrition(min((nutrition + nutrition_to_add), age_state.max_nutrition))
	if(nutrition >= age_state.grow_nutrition)
		if(powerlevel<10)
			if(prob(30-powerlevel*2))
				powerlevel++
	else if(nutrition >= age_state.hunger_nutrition + 100) //can't get power levels unless you're a bit above hunger level.
		if(powerlevel<5)
			if(prob(25-powerlevel*5))
				powerlevel++


/mob/living/simple_animal/slime/proc/handle_nutrition()

	// if a slime is starving, it starts losing its friends
	if(nutrition < age_state.starve_nutrition && !client)
		if(length(Friends) && prob(SLIME_LOOSE_FRIEND_CHANCE))
			var/mob/nofriend = pick(Friends)
			Friends[nofriend] = max(0, Friends[nofriend] - 1)
			if(!Friends[nofriend])
				Friends -= nofriend

	if(prob(15))
		adjust_nutrition(-age_state.nutrition_handle)

	if(nutrition >= age_state.grow_nutrition && amount_grown < age_state.amount_grown)
		adjust_nutrition(-20)
		amount_grown++
		update_action_buttons_icon()

		if(!ckey && amount_grown == age_state.amount_grown_for_split && \
			(age_state.age != SLIME_BABY && prob(chance_reproduce) || age_state.age == SLIME_ELDER) && \
			reproduce_behavior != SLIME_BEHAVIOR_EVOLVE)
			Reproduce()

	if (buckled || Target || ckey)
		return FALSE

	if(amount_grown >= age_state.amount_grown)
		if(age_state.age != SLIME_ELDER)
			if(reproduce_behavior != SLIME_BEHAVIOR_REPRODUCE)
				Evolve()
		else if(reproduce_behavior != SLIME_BEHAVIOR_EVOLVE)
			Reproduce()


/mob/living/simple_animal/slime/proc/handle_reagents()
	for(var/datum/reagent/current_reagent as anything in reagents.reagent_list)
		reagents.remove_reagent(current_reagent.id, current_reagent.metabolization_rate)


/mob/living/simple_animal/slime/proc/get_hunger_level()
	. = SLIME_HUNGER_NOT_HUNGRY
	if(nutrition < age_state.starve_nutrition)
		. = SLIME_HUNGER_STARVING
	else if(((nutrition < age_state.grow_nutrition) && prob(25)) || (nutrition < age_state.hunger_nutrition))
		. = SLIME_HUNGER_HUNGRY

/mob/living/simple_animal/slime/proc/AIprocess(patience = age_state.patience)  // the master AI process

	if(AIproc || stat || client)
		return

	AIproc = TRUE

	while(AIproc && stat != DEAD && Target)

		if(!canmove || client || Target.health <= -70 || Target.stat == DEAD || \
			locate(/mob/living/simple_animal/slime) in Target.buckled_mobs)
			Target = null
			break

		if(Adjacent(Target))
			switch(target_behavior)
				if(SLIME_BEHAVIOR_ATTACK)
					//slime can also eat if the target has weakened enough
					if(Target.client && Target.health < 20)
						target_behavior = SLIME_BEHAVIOR_EAT
						continue
					if(!Atkcool)
						Atkcool = TRUE
						addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), SLIME_ATTACK_COOLDOWN)
						Target.attack_slime(src)
						target_patience = patience

				if(SLIME_BEHAVIOR_EAT)
					//attack if uneatable
					if(!CanFeedon(Target))
						target_behavior = SLIME_BEHAVIOR_ATTACK
						continue
					//attack if target not weak enough
					if(Target.client && Target.health >= 20)
						target_behavior = SLIME_BEHAVIOR_ATTACK
						continue

					if(!Atkcool)
						Feedon(Target)
						target_patience = patience

		else if(Target in view(12, src))
			step_to(src, Target)
			target_patience = max(0, target_patience - 1)
			if(target_patience <= 0 || Stun_time > world.time || Discipline)
				target_patience = 0
				Target = null
		else
			Target = null
			break

		var/sleeptime = max(1, movement_delay())

		sleep(sleeptime + 2) // this is about as fast as a player slime can go

	AIproc = FALSE


/mob/living/simple_animal/slime/proc/handle_targets()
	var/is_stunned = Stun_time > world.time
	var/is_angry = attacked || rabid
	var/hungry = get_hunger_level()

	update_canmove()

	if(client || !canmove || buckled || AIproc && is_stunned)
		return

	if(!Target)
		switch(hungry)
			if(SLIME_HUNGER_NOT_HUNGRY)
				if(is_angry)
					set_new_target(find_target(FALSE, TRUE), SLIME_BEHAVIOR_ATTACK)

			if(SLIME_HUNGER_HUNGRY)
				if(!Leader && !holding_still)
					set_new_target(find_target(TRUE, is_angry), SLIME_BEHAVIOR_EAT)

			if(SLIME_HUNGER_STARVING)
				set_new_target(find_target(TRUE, TRUE), SLIME_BEHAVIOR_EAT)

	// If we have no target, we are wandering or following orders
	if(!Target)
		if (Leader)
			if(holding_still)
				holding_still = max(holding_still - 1, 0)
			else if(canmove && isturf(loc))
				step_to(src, Leader)

		else if(hungry)
			if (holding_still)
				holding_still = max(holding_still - hungry, 0)
			else if(canmove && isturf(loc) && prob(50 * hungry))
				step(src, pick(GLOB.cardinal))

		else
			if(holding_still)
				holding_still = max(holding_still - 1, 0)
			else if (pulledby in Friends)
				holding_still = max(Friends[pulledby], 10)
			else if(canmove && isturf(loc) && prob(33))
				step(src, pick(GLOB.cardinal))


/mob/living/simple_animal/slime/proc/find_target(to_eat, very_angry)
	var/list/targets = list()
	for(var/mob/living/L in view(7,src))
		// Ignore dead mobs & friends
		if(L.stat == DEAD || (L in Friends))
			continue

		//does not try to eat inedible or occupied by someone else
		if(to_eat && (issilicon(L) || ismachineperson(L) || locate(/mob/living/simple_animal/slime) in L.buckled_mobs))
			continue

		//Disciplined slimes never attack humans, but they can attack monkeys and larvas.
		if(Discipline && !islarva(L) && !issmall(L))
			continue

		//Small chance to attack human
		if(!very_angry && !issmall(L) && ishuman(L) && prob(95))
			continue

		var/ally = FALSE
		for(var/F in faction)
			if(F == "neutral") //slimes are neutral so other mobs not target them, but they can target neutral mobs
				continue
			if(F in L.faction)
				ally = TRUE
				break
		if(ally)
			continue

		targets += L

	if(!length(targets))
		return FALSE

	. = targets[1]

	var/min_dist = 9999
	var/cur_dist
	for(var/mob/living/L as anything in targets)
		if(Adjacent(L))
			return L
		cur_dist = get_dist(loc, L.loc)
		if(cur_dist < min_dist)
			min_dist = cur_dist
			. = L

/mob/living/simple_animal/slime/proc/set_new_target(target, behavior, patience = age_state.patience)
	if(target)
		Target = target
	if(patience)
		target_patience = patience
	if(behavior)
		target_behavior = behavior
	if(!AIproc)
		INVOKE_ASYNC(src, PROC_REF(AIprocess), patience)


/mob/living/simple_animal/slime/handle_automated_movement()
	return //slime random movement is currently handled in handle_targets()

/mob/living/simple_animal/slime/handle_automated_speech()
	return //slime random speech is currently handled in handle_speech()


/mob/living/simple_animal/slime/proc/handle_mood()
	if(rabid || attacked)
		set_mood(SLIME_MOOD_ANGRY)
		return
	else if(Target)
		set_mood(SLIME_MOOD_MISCHIEVOUS)
		return
	else if(Discipline)
		set_mood(SLIME_MOOD_POUT)
		return
	else if((mood in list(SLIME_MOOD_SAD, SLIME_MOOD_3, SLIME_MOOD_33)) && prob(80))
		return
	set_mood(FALSE)

/mob/living/simple_animal/slime/proc/set_mood(new_mood)
	if(new_mood != mood)
		mood = new_mood
		regenerate_icons()


//Speech understanding
/mob/living/simple_animal/slime/proc/handle_speech()
	if(!speech_buffer.len)
		return

	var/to_say = ""
	var/who = speech_buffer[1]
	var/phrase = speech_buffer[2]

	if(!is_command_to_me(phrase))
		return

	if(madness_check(who))
		return

	switch(identify_command(phrase))
		if(SLIME_COMMAND_GREETING)
			to_say = pick(greeting_phrases)

		if(SLIME_COMMAND_FOLLOW)
			if(Friends[who] >= SLIME_FRIENDSHIP_FOLLOW)
				if(Leader)
					if(Leader == who)
						to_say = pick(already_follow_phrases)
					else if(Friends[who] > Friends[Leader])
						Leader = who
						holding_still = 0
						to_say = "Хорошо, моя пойти за [who]..."
					else
						to_say = "Нет, моя идти за [Leader]!"
				else
					Leader = who
					holding_still = 0
					to_say = pick(follow_phrases)
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_STAY)
			if(Friends[who] >= SLIME_FRIENDSHIP_STAY)
				if(Leader && Leader != who && Friends[who] < Friends[Leader])
					to_say = pick(no_stay_follow_phrases)
				else
					holding_still = Friends[who] * 30
					Leader = null
					to_say = pick(stay_phrases)
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_STOP)
			var/datum/component/slime_defender/slime_defender_component = GetComponent(/datum/component/slime_defender)
			if(buckled) // We are asked to stop feeding
				if(Friends[who] >= SLIME_FRIENDSHIP_STOPEAT)
					Feedstop()
					Target = null
					if(Friends[who] < SLIME_FRIENDSHIP_STOPEAT_NOANGRY)
						--Friends[who]
						to_say = pick(stop_attacking_angry_phrases) // I'm angry but I do it
					else
						to_say = pick(stop_attacking_phrases)
				else
					to_say = pick(no_listen_phrases)
			else if(Target) // We are asked to stop chasing
				if(Friends[who] >= SLIME_FRIENDSHIP_STOPCHASE)
					Target = null
					if(Friends[who] < SLIME_FRIENDSHIP_STOPCHASE_NOANGRY)
						--Friends[who]
						to_say = pick(stop_attacking_angry_phrases) // I'm angry but I do it
					else
						to_say = pick(stop_attacking_phrases)
				else
					to_say = pick(no_listen_phrases)
			else if(slime_defender_component)
				if(Friends[who] >= SLIME_FRIENDSHIP_STOPDEFEND)
					slime_defender_component?.RemoveComponent()
					Leader = null
					to_say = pick(stop_defend_phrases)
				else
					to_say = pick(no_listen_phrases)
			else if(Leader) // We are asked to stop following
				if(Leader != who && Friends[who] < Friends[Leader])
					to_say = pick(no_listen_phrases)
				else
					Leader = null
					to_say = pick(stop_following_phrases)

		if(SLIME_COMMAND_ATTACK)
			var/mob/living/attack_target = get_target_from_command(phrase)
			if(!attack_target)
				to_say = pick(dont_recognize_phrases)
			else if(Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
				if(isslime(attack_target) || Friends[attack_target] && (Friends[who] - Friends[attack_target] < SLIME_FRIENDSHIP_ATTACK))
					to_say = "НЕТ! [attack_target] быть друг..."
					--Friends[who]
				else
					set_new_target(attack_target, SLIME_BEHAVIOR_ATTACK, age_state.patience * max(1, Friends[who]/10))
					to_say = "Да... Бить [attack_target]..."
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_EAT)
			var/mob/living/attack_target = get_target_from_command(phrase)
			if(!attack_target)
				to_say = pick(dont_recognize_phrases)
			else if(Friends[who] >= SLIME_FRIENDSHIP_ATTACK)
				if(isslime(attack_target) || Friends[attack_target] && (Friends[who] - Friends[attack_target] < SLIME_FRIENDSHIP_ATTACK))
					to_say = "НЕТ! [attack_target] быть друг..."
					--Friends[who]
				else
					set_new_target(attack_target, SLIME_BEHAVIOR_EAT, age_state.patience * max(1, Friends[who]/10))
					to_say = "Да... Есть [attack_target]..."
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_DEFEND)
			var/mob/living/carbon/human/defend_target = get_target_from_command(phrase)
			if(!defend_target)
				to_say = pick(dont_recognize_phrases)
			else if(Friends[who] >= SLIME_FRIENDSHIP_DEFEND)
				if(istype(defend_target))
					Leader = defend_target
					holding_still = 0
					defend_target.AddComponent(/datum/component/slime_defender, src)
					to_say = "Защищать [defend_target]..."
				else
					to_say = pick(no_listen_phrases)
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_REPRODUCE)
			if(Friends[who] >= SLIME_FRIENDSHIP_REPRODUCE_CONTROL)
				reproduce_behavior = SLIME_BEHAVIOR_REPRODUCE
				to_say = "Размножаться..."
			else
				to_say = pick(no_listen_phrases)

		if(SLIME_COMMAND_NOREPRODUCE)
			if(Friends[who] >= SLIME_FRIENDSHIP_REPRODUCE_CONTROL)
				reproduce_behavior = SLIME_BEHAVIOR_EVOLVE
				to_say = "Расти..."
			else
				to_say = pick(no_listen_phrases)

	speech_buffer = list()

	if(to_say && !stat)
		say(to_say)


/mob/living/simple_animal/slime/proc/madness_check(target)
	if(rabid && prob(20))
		set_new_target(target, SLIME_BEHAVIOR_ATTACK, age_state.patience * 10)
		say(pick(madness_phrases))
		return TRUE
	return FALSE


/mob/living/simple_animal/slime/proc/handle_random_phrases()
	Random_phrase_CD = max(0, Random_phrase_CD - 1)
	if(Random_phrase_CD)
		return

	if(prob(1))
		emote(pick("bounce", "sway", "light", "vibrate", "jiggle"))
		set_mood(SLIME_MOOD_3)
		return

	var/list/phrases = list()

	var/slimes_near = 0
	var/dead_slimes = 0
	var/list/friends_near = list()
	for(var/mob/living/L in view(7, src))
		if(isslime(L) && L != src)
			++slimes_near
			if(L.stat == DEAD)
				++dead_slimes
		if(L in Friends)
			friends_near += L

	if(prob(sqrtor0(slimes_near)))
		if(slimes_near > 1)
			phrases += "Слаймы други..."
		else if(slimes_near)
			phrases += "Слайм друг..."

	if(!slimes_near && prob(1))
		set_mood(SLIME_MOOD_SAD)
		phrases += "Одинокий..."

	if(prob(dead_slimes))
		set_mood(SLIME_MOOD_SAD)
		phrases += "Что с ним быть?"

	for(var/M in friends_near)
		if(prob(clamp(Friends[M]/10, 0, 3)))
			if(nutrition < age_state.hunger_nutrition)
				set_mood(SLIME_MOOD_SAD)
				phrases += "[M]... дать еда..."
			else
				set_mood(SLIME_MOOD_3)
				phrases += "[M]... друг..."

	if((powerlevel > 3) && prob(1))
		phrases += "Бззз..."
	else if((powerlevel > 5) && prob(1))
		phrases += "Вжжж..."
	else if((powerlevel > 8) && prob(1))
		phrases += "ЖЖЖ!"

	if(Target && prob(3))
		phrases += "[Target]... вкусный..."

	if((nutrition < age_state.hunger_nutrition) && prob(1) || (nutrition < age_state.starve_nutrition) && prob(5))
		set_mood(SLIME_MOOD_SAD)
		phrases += pick("Хотеть... еда...", "Нужен... еда...", \
						"Голодный...", "Где еда?", "Хотеть есть...")

	if((rabid || attacked) && prob(10))
		phrases += pick("Грр...", "Рррр...", "Хррр...", "Унн...")

	if(prob(1))
		phrases += pick("Равр...", "Блоп...", "Плюх...", "Буп...", "Блорблюм...", "Блорбл...")

	if(mood == SLIME_MOOD_3 && prob(10))
		set_mood(SLIME_MOOD_33)
		phrases += "Мурр..."

	if(mood == SLIME_MOOD_SAD && prob(10))
		phrases += "Скучно..."

	if(bodytemperature < SLIME_THAW_T && prob(10))
		set_mood(SLIME_MOOD_SAD)
		phrases += pick("Холод...")

	if(buckled)
		var/mob/living/food = buckled
		if(food.client && prob(10) || !food.client && prob(1))
			set_mood(SLIME_MOOD_3)
			phrases += pick("Ням...", "Вкусно...")

	if(!stat && length(phrases))
		Random_phrase_CD = 10
		say(pick(phrases))


/mob/living/simple_animal/slime/proc/identify_command(text)
	var/list/words = splittext(text, regex(" |\\.|\\,|\\!|\\?"))
	for(var/word in words)
		if(word in greeting_commands)
			return SLIME_COMMAND_GREETING
		if(word in follow_commands)
			return SLIME_COMMAND_FOLLOW
		if(word in stay_commands)
			return SLIME_COMMAND_STAY
		if(word in stop_commands)
			return SLIME_COMMAND_STOP
		if(word in attack_commands)
			return SLIME_COMMAND_ATTACK
		if(word in eat_commands)
			return SLIME_COMMAND_EAT
		if(word in defend_commands)
			return SLIME_COMMAND_DEFEND
		if(word in reproduce_commands)
			return SLIME_COMMAND_REPRODUCE
		if(word in no_reproduce_commands)
			return SLIME_COMMAND_NOREPRODUCE

/mob/living/simple_animal/slime/proc/is_command_to_me(text)
	var/list/words = splittext(text, regex(" |\\.|\\,|\\!|\\?"))

	if(words[1] == num2text(number))
		return TRUE

	//slimes respond to a part of their name, but not less than 5 characters
	if(length_char(words[1]) >= min(length_char(name), 5) && findtext(name, words[1]))
		return TRUE

	if(words[1] in slimes_names)
		return TRUE
	return FALSE


/mob/living/simple_animal/slime/proc/get_target_from_command(text)
	var/target
	var/list/words = splittext(text, regex(" |\\.|\\,|\\!|\\?"))
	for(var/i in 1 to length(words) - 1)
		if(words[i] in attack_commands + eat_commands + defend_commands)
			target = words[i+1]
			break

	//slimes recognize a target by part of its name, but not less than 5 characters
	for(var/mob/living/L in view(7, src) - list(src))
		if(length_char(target) >= min(length_char(L.name), 5) && findtext(L.name, target))
			return L
