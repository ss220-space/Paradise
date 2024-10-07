/// Cooldown between any gorilla actions (speech, orders, actions etc.).
#define GORILLA_ACTIONS_COOLDOWN (5 SECONDS)
/// Time gorilla will follow the user who fed it or make excited via attention phrase.
#define GORILLA_EXCITEMENT_TIME (8 SECONDS)
/// Befriend time per eaten banana. Maximum time is always equal or lower to TIME_PER_BANANA * BANANAS_TO_BEFRIEND.
#define TIME_PER_BANANA (1 MINUTES)
/// Bananas required to befriend non-rampage gorilla.
#define BANANAS_TO_BEFRIEND 5
/// Bananas required for gorilla to eat, in order to make everyone understand them.
#define BANANAS_TO_ENLIGHTEN 50


/mob/living/simple_animal/hostile/gorilla
	description_info = "<b>Руководство по работе с гориллами для самых маленьких:</b>\nВсе гориллы любят бананы и наверняка захотят поработать, если Вы предоставите им несколько этих замечательных фруктов.\nЕсли горилла уже работает на Вас, используйте указатель (средняя кнопка мышки), чтобы отдать животному команду на перемещение или подбор/сброс ящиков в указанную точку.\nДо тех пор пока горилла не нашла себе друга она будет отзываться по имени.\nТакже животное способно понимать дополнительные голосовые приказы, если их использовать в одном предложении с именем животного.\n<b>Команды:</b>\n- \"сидеть\", \"опустись\", \"сядь\", \"садись\", \"сесть\"\n- \"встать\", \"встань\", \"поднимись\", \"стоять\", \"стой\", \"выпрямись\"\n- \"пошли\", \"идём\", \"за мной\" \n- \"жди\", \"ожидай\", \"ждать\" \n- \"брось\", \"выброси\", \"урони\"\n- \"носи ящики\", \"хватай ящики\"\n- \"толкай ящики\", \"двигай ящики\""
	/// Сan gorilla have a master?
	var/can_befriend = TRUE
	/// What speech pieces make gorilla excited (turn off AI and make it follow the speaker). Works only without master and client.
	var/list/attention_phrases = list("goril", "banana", "monkey", "горил", "банан", "обезьян")
	/// Current gorilla master.
	var/mob/living/carbon/human/master
	/// Amount of bananas eaten.
	var/bananas_eaten = 0
	/// Timer used in befriend and excitement manipulations.
	var/befriend_timer
	/// Whether gorilla is currently waiting and will not follow its master.
	var/is_waiting = FALSE
	/// List of initial factions, gorilla has before befriend. We need this since initial value of a list is an empty list.
	var/list/initial_faction
	/// Associative list with key = user.UID(), value = bananas fed to gorilla. Used in befriending.
	var/list/friend2bananas
	/// Notify player about new powers.
	var/enlighten_message_done = FALSE
	/// Original target atom gorrilla's master pointed at.
	var/atom/point_target
	/// Turf adjacent to point_target, used in point movement manipulations.
	var/turf/target_turf
	/// Cooldown stamp used for various gorilla actions.
	COOLDOWN_DECLARE(gorilla_actions_cooldown)


/mob/living/simple_animal/hostile/gorilla/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Бананов съедено:", "[bananas_eaten]/[BANANAS_TO_ENLIGHTEN]")


/mob/living/simple_animal/hostile/gorilla/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM || !istype(I, /obj/item/reagent_containers/food/snacks/grown/banana))
		return ..()

	add_fingerprint(user)
	if(!can_befriend)
		if(is_on_cooldown())
			return ..()
		start_action_cooldown()
		oogaooga(100, 200)
		custom_emote(EMOTE_VISIBLE, "безумно смотр%(ит,ят)% на [user], не реагируя на банан.", intentional = TRUE)
		return ..()

	if(client)
		if(is_on_cooldown())
			to_chat(user, span_warning("[user == src ? "Вы не можете" : "[capitalize(name)] не мож[pluralize_ru(gender, "ет", "гут")]"] настолько быстро поедать бананы!"))
			return ..()
		start_action_cooldown()
		eat_banana(I)
		to_chat(user, span_notice("Вы замечаете искру разума в глазах [name], но [genderize_ru(gender, "он", "она", "оно", "они")] не мо[pluralize_ru(gender, "жет", "гут")] устоять перед искушением!"))
		to_chat(src, span_notice("[user] покорм[genderize_ru(user.gender, "ил", "ила", "ило", "или")] Вас, возможно стоит [genderize_ru(user.gender, "его", "её", "его", "их")] отблагодарить..."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_on_cooldown())
		to_chat(user, span_warning("[capitalize(name)] сейчас занят[genderize_ru(gender, "", "а", "о", "ы")]."))
		return ..()

	start_action_cooldown()

	if(master)
		if(user == master && user.drop_item_ground(I))
			eat_banana(I, from_master_hand = TRUE)
			return ATTACK_CHAIN_BLOCKED_ALL

		face_atom(user)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "смотр%(ит,ят)% на банан, а затем на [master].", intentional = TRUE)
		return ..()

	if(user.drop_item_ground(I))
		eat_banana(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	face_atom(user)
	oogaooga(50)
	custom_emote(EMOTE_VISIBLE, "раздражённо смотр%(ит,ят)% на банан.", intentional = TRUE)
	return ..()


/mob/living/simple_animal/hostile/gorilla/hear_say(list/message_pieces, verb = "says", italics = FALSE, mob/speaker = null, sound/speech_sound, sound_vol, sound_frequency, use_voice = TRUE)
	if(client || !can_befriend || !ishuman(speaker) || speaker == src || incapacitated() || is_on_cooldown())
		return ..()

	var/full_message = lowertext(multilingual_to_message(message_pieces))
	var/name_found = find_phrase(full_message, get_names())

	if(!master)
		if(find_phrase(full_message, list("харамбе", "harambe")))
			custom_emote(EMOTE_VISIBLE, "прикрыва%(ет,ют)% лицо лапой, смахивая слезинку.", intentional = TRUE)

		else if(name_found && find_phrase(full_message, list("хорош", "молод", "красав", "красив", "работ", "сильн", "сила")))
			oogaooga(100, 150)
			custom_emote(EMOTE_VISIBLE, "одобрительно уха%(ет,ют)%.", intentional = TRUE)

		else if(name_found && find_phrase(full_message, list("урод", "мраз", "плох", "бездельн", "ленив", "гад", "мартышк")))
			face_atom(speaker)
			oogaooga(100, 150)
			custom_emote(EMOTE_VISIBLE, "рассерженно смотр%(ит,ят)% на [speaker].", intentional = TRUE)

		else if(find_phrase(full_message, attention_phrases))
			if(can_pass_adjacent(speaker, types_to_exclude = list(/mob, /obj/structure/table)) || length(get_path_to(src, get_turf(speaker), mintargetdist = 1)))
				check_buckled_gorilla()
				face_atom(speaker)
				oogaooga(100)
				custom_emote(EMOTE_VISIBLE, "выжидающе смотр%(ит,ят)% на [speaker].")
				toggle_ai(AI_OFF)
				Goto(speaker, move_to_delay, 2)
				if(befriend_timer)
					deltimer(befriend_timer)
				befriend_timer = addtimer(CALLBACK(src, PROC_REF(reset_behavior), TRUE, TRUE), GORILLA_EXCITEMENT_TIME, TIMER_STOPPABLE|TIMER_DELETE_ME)
			else
				face_atom(speaker)
				oogaooga(50)
				custom_emote(EMOTE_VISIBLE, "неодобрительно смотр%(ит,ят)% на [speaker].")

		start_action_cooldown()
		return ..()

	if(speaker != master || !name_found)
		return ..()

	var/confusion = FALSE
	var/start_cooldown = TRUE

	if(find_phrase(full_message, list("сидеть", "опустись", "сядь", "садись", "сесть")))
		if(LAZYLEN(crates_in_hand))
			check_buckled_gorilla()
			face_atom(master)
			oogaooga(100)
			custom_emote(EMOTE_VISIBLE, "хлопа%(ет,ют)% по ящику в лапах и смотр%(ит,ят)% на [master].", intentional = TRUE)
		else if(is_bipedal)
			check_buckled_gorilla()
			gorilla_toggle.Activate()
			oogaooga(100, 100)
			custom_emote(EMOTE_VISIBLE, "опуска%(ет,ют)%ся на все четыре конечности.", intentional = TRUE)
		else
			confusion = TRUE

	else if(find_phrase(full_message, list("встать", "встань", "поднимись", "стоять", "стой", "выпрямись")))
		if(!is_bipedal)
			check_buckled_gorilla()
			gorilla_toggle.Activate()
			oogaooga(100, 150)
			custom_emote(EMOTE_VISIBLE, "выпрямля%(ет,ют)% спину и свысока осматрива%(ет,ют)%ся.", intentional = TRUE)
		else
			confusion = TRUE

	else if(find_phrase(full_message, list("пошли", "идём", "идем", "за мной")))
		if(is_waiting)
			is_waiting = FALSE
			check_buckled_gorilla()
			face_atom(master)
			follow_master()
			oogaooga(100)
			if(is_bipedal)
				if(LAZYLEN(crates_in_hand))
					custom_emote(EMOTE_VISIBLE, "перехватыва%(ет,ют)% ящик поудобнее и устремля%(ет,ют)%ся к [master].", intentional = TRUE)
				else
					gorilla_toggle.Activate()
					custom_emote(EMOTE_VISIBLE, "опуска%(ет,ют)%ся на все конечности и устремля%(ет,ют)%ся к [master].", intentional = TRUE)
			else
				custom_emote(EMOTE_VISIBLE, "устремля%(ет,ют)%ся к [master].", intentional = TRUE)
		else
			confusion = TRUE

	else if(find_phrase(full_message, list("жди", "ожидай", "ждать")))
		if(!is_waiting)
			is_waiting = TRUE
			SSmove_manager.stop_looping(src)
			oogaooga(100)
			if(is_bipedal)
				if(LAZYLEN(crates_in_hand))
					custom_emote(EMOTE_VISIBLE, "грустно смотр%(ит,ят)% на ящик в лапах.", intentional = TRUE)
				else
					gorilla_toggle.Activate()
					custom_emote(EMOTE_VISIBLE, "усажива%(ет,ют)%ся на пол и зева%(ет,ют)%.", intentional = TRUE)
			else
				custom_emote(EMOTE_VISIBLE, "усажива%(ет,ют)%ся на пол и зева%(ет,ют)%.", intentional = TRUE)
		else
			confusion = TRUE

	else if(find_phrase(full_message, list("брось", "выброси", "урони")))
		if(LAZYLEN(crates_in_hand))
			check_buckled_gorilla()
			drop_all_crates(drop_location())
			oogaooga(100, 100)
		else
			oogaooga(50)
			custom_emote(EMOTE_VISIBLE, "с недоумением рассматрива%(ет,ют)% свои лапы.", intentional = TRUE)

	else if(find_phrase(full_message, list("носи ящики", "хватай ящики")))
		check_buckled_gorilla()
		a_intent_change(INTENT_HELP)
		face_atom(master)
		oogaooga(100)
		custom_emote(EMOTE_VISIBLE, "понимающе кива%(ет,ют)%, играя бицепсами.", intentional = TRUE)

	else if(find_phrase(full_message, list("толкай ящики", "двигай ящики")))
		check_buckled_gorilla()
		a_intent_change(INTENT_HARM)
		face_atom(master)
		oogaooga(100)
		custom_emote(EMOTE_VISIBLE, "утвердительно уха%(ет,ют)%.", intentional = TRUE)

	else if(find_phrase(full_message, list("банан", "кушать", "есть", "еда")))
		check_buckled_gorilla()
		face_atom(master)
		oogaooga(100, 200)
		custom_emote(EMOTE_VISIBLE, "начина%(ет,ют)% усердно кивать головой.", intentional = TRUE)

	else
		face_atom(master)
		oogaooga(100, 150)
		custom_emote(EMOTE_VISIBLE, "одобрительно смотр%(ит,ят)% на [master].", intentional = TRUE)

	if(confusion)
		face_atom(master)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "непонимающе смотр%(ит,ят)% на [master].", intentional = TRUE)

	if(start_cooldown)
		start_action_cooldown()

	return ..()


/**
 * Parses message for specific phrases contained in a list.
 *
 * Arguments:
 * * message - message to parse.
 * * phrases - list with phrases to compare.
 */
/mob/living/simple_animal/hostile/gorilla/proc/find_phrase(message, list/phrases)
	for(var/piece in phrases)
		if(findtext(message, piece))
			return TRUE
	return FALSE


/**
 * Checks if gorillas is currently buckeld to something.
 *
 * Arguments:
 * * unbuckle - if `TRUE` gorilla will be unbuckled.
 */
/mob/living/simple_animal/hostile/gorilla/proc/check_buckled_gorilla(unbuckle = TRUE)
	. = !isnull(buckled)
	if(. && unbuckle)
		buckled.unbuckle_mob(src)


/**
 * Signal handler used to give gorilla various actions by pointing. Works only if gorilla is befrinded.
 *
 * Arguments:
 * * user - gorilla current master.
 * * pointed_at - original atom, user pointed at.
 */
/mob/living/simple_animal/hostile/gorilla/proc/check_pointed(mob/living/carbon/human/user, atom/pointed_at)
	//SIGNAL_HANDLER	// we cant use this here since we have possible waits in [get_path_to()] and input in [custom_emote()],
	set waitfor = FALSE	// and god damn spacemanDMM will not understand waitfor is set to FALSE in this proc

	if(!master || client)
		return

	if(is_on_cooldown())
		to_chat(master, span_warning("[capitalize(name)] сейчас занят[genderize_ru(gender, "", "а", "о", "ы")]."))
		return

	if(incapacitated())
		custom_emote(EMOTE_VISIBLE, "жалобно мыч%(ит,ат)% в сторону [master].", intentional = TRUE)
		return

	check_buckled_gorilla()
	start_action_cooldown()

	var/pointed_at_banana = istype(pointed_at, /obj/item/reagent_containers/food/snacks/grown/banana)

	// edge case of banana handling in master's inventory, while pointing at it
	if(pointed_at_banana && !isturf(pointed_at.loc) && get(pointed_at.loc, /mob/living/carbon/human) == master && !master.is_in_hands(pointed_at))
		face_atom(master)
		oogaooga(100, 150)
		custom_emote(EMOTE_VISIBLE, "начина%(ет,ют)% усердно кивать головой и радостно ухать.", intentional = TRUE)
		return

	var/obj/structure/bigDelivery/delivery = pointed_at
	var/pointed_at_crate = istype(pointed_at, /obj/structure/closet) || (istype(delivery) && istype(delivery.wrapped, /obj/structure/closet/crate))

	if(pointed_at_crate && LAZYLEN(crates_in_hand) >= crate_limit)
		oogaooga(100, 100)
		custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок, перехватывая ящик в лапах.", intentional = TRUE)
		return

	var/turf/pointed_turf = get_turf(pointed_at)
	var/pointed_at_check_type = pointed_at_crate || pointed_at_banana
	var/in_range = in_range(src, pointed_turf)

	if(in_range && can_pass_adjacent(pointed_turf, types_to_exclude = list(/mob, /obj/structure/closet, /obj/structure/bigDelivery, /obj/structure/table)))
		if(pointed_at_check_type)
			delayed_manipulation(pointed_at)
		else
			delayed_move_drop(pointed_at, move = !LAZYLEN(crates_in_hand))
		return

	if(in_range)
		face_atom(master)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок, смотря на [master].", intentional = TRUE)
		return

	var/list/path = get_path_to(src, pointed_turf, mintargetdist = (pointed_at_check_type || LAZYLEN(crates_in_hand)) ? 1 : null)
	var/path_length = length(path)
	if(!path_length)
		face_atom(master)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок, смотря на [master].", intentional = TRUE)
		return

	point_target = pointed_at
	target_turf = path[path_length]
	var/datum/move_loop/new_loop = Goto(target_turf, move_to_delay, timeout = 4 SECONDS)
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(move_postprocess))
	RegisterSignal(new_loop, COMSIG_QDELETING, PROC_REF(move_end))


/mob/living/simple_animal/hostile/gorilla/proc/move_postprocess(datum/source)
	SIGNAL_HANDLER

	if(QDELETED(point_target) || QDELETED(target_turf))
		follow_master()
		return

	if(target_turf != loc)
		return

	if(istype(point_target, /obj/structure/closet) || istype(point_target, /obj/structure/bigDelivery) || istype(point_target, /obj/item/reagent_containers/food/snacks/grown/banana))
		delayed_manipulation(point_target, 0.3 SECONDS)
	else
		delayed_move_drop(point_target, 0.3 SECONDS)

	point_target = null
	target_turf = null


/mob/living/simple_animal/hostile/gorilla/proc/move_end(datum/source)
	SIGNAL_HANDLER

	follow_master()


/**
 * Result of pointing at banana or crate/closet.
 *
 * Arguments:
 * * pointed_at - original atom master pointed at.
 */
/mob/living/simple_animal/hostile/gorilla/proc/delayed_manipulation(atom/pointed_at, delay)
	set waitfor = FALSE
	if(isnum(delay))
		SLEEP_CHECK_DEATH(src, delay)
	start_action_cooldown()
	if(!QDELETED(pointed_at) && can_pass_adjacent(pointed_at, types_to_exclude = list(/mob, /obj/structure/closet, /obj/structure/bigDelivery, /obj/structure/table)))
		if(istype(pointed_at, /obj/structure/closet) || istype(pointed_at, /obj/structure/bigDelivery))
			manipulate_crate(pointed_at)
		else
			eat_banana(pointed_at, from_master_hand = (pointed_at.loc == master))
	else
		face_atom(master)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок[pointed_at ? ", смотря на [pointed_at]" : ""].", intentional = TRUE)
	follow_master()


/**
 * Result of pointing at anything except crates or bananas.
 *
 * Arguments:
 * * pointed_at - original atom, master pointed at.
 */
/mob/living/simple_animal/hostile/gorilla/proc/delayed_move_drop(atom/pointed_at, delay, move = FALSE)
	set waitfor = FALSE
	if(isnum(delay))
		SLEEP_CHECK_DEATH(src, delay)
	start_action_cooldown()
	var/turf/pointed_turf = get_turf(pointed_at)
	var/turf_exist = !QDELETED(pointed_turf)
	if(turf_exist && can_pass_adjacent(pointed_turf, types_to_exclude = list(/mob, /obj/structure/table)) && LAZYLEN(crates_in_hand))
		face_atom(pointed_turf)
		drop_random_crate(pointed_turf)
	else
		if(turf_exist && move && loc != pointed_turf)
			Move(pointed_turf)
		face_atom(master)
		oogaooga(50)
		custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок, смотря на [master].", intentional = TRUE)
	follow_master()


/**
 * Banana consuming overmind.
 *
 * Arguments:
 * * banana - target banana to eat.
 * * giver - user who fed gorilla.
 * * throw_impact - whether this proc was called in result of throw impact.
 * * from_master_hand - whether fed person was a gorilla current master.
 */
/mob/living/simple_animal/hostile/gorilla/proc/eat_banana(obj/item/reagent_containers/food/snacks/grown/banana/banana, mob/giver, throw_impact = FALSE, from_master_hand = FALSE)
	check_buckled_gorilla()
	face_atom(get_turf(banana))
	playsound(loc, 'sound/items/eatfood.ogg', 100, TRUE)
	oogaooga(100, 100)
	bananas_eaten++
	apply_status_effect(STATUS_EFFECT_BANANA_POWER)

	if(!throw_impact)
		banana.do_pickup_animation(src)

	qdel(banana)

	if(client)
		if(check_enlighten() && !enlighten_message_done)
			enlighten_message_done = TRUE
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			update_sight()
			to_chat(src, span_boldnotice("Похоже поедание бананов не прошло даром, теперь все вокруг могут понимать Вашу речь!"))
		if(throw_impact)
			emote("flip")
			custom_emote(EMOTE_VISIBLE, "перехватыва%(ет,ют)% банан на лету и моментально проглатыва%(ет,ют)%.", intentional = TRUE)
		return
	if(master && befriend_timer)
		if(throw_impact)
			face_atom(master)
			emote("flip")
			custom_emote(EMOTE_VISIBLE, "перехватыва%(ет,ют)% банан на лету и благодарно смотр%(ит,ят)% на [master].", intentional = TRUE)
		else
			if(from_master_hand)
				emote("spin")
				custom_emote(EMOTE_VISIBLE, "бер%(ёт,ут)% банан из рук [master] и проворно проглатыва%(ет,ют)%.", intentional = TRUE)
			else
				custom_emote(EMOTE_VISIBLE, "удовлетворённо поеда%(ет,ют)% банан.", intentional = TRUE)
		var/time_left = timeleft(befriend_timer)
		deltimer(befriend_timer)
		var/new_time = min(time_left + TIME_PER_BANANA, BANANAS_TO_BEFRIEND * TIME_PER_BANANA)
		befriend_timer = addtimer(CALLBACK(src, PROC_REF(reset_behavior)), new_time, TIMER_STOPPABLE|TIMER_DELETE_ME)

	else if(giver)
		if(befriend_timer)
			deltimer(befriend_timer)
		var/giver_UID = giver.UID()
		if(LAZYIN(friend2bananas, giver_UID))
			LAZYSET(friend2bananas, giver_UID, ++friend2bananas[giver_UID])
		else
			LAZYSET(friend2bananas, giver_UID, 1)
		if(friend2bananas[giver_UID] < BANANAS_TO_BEFRIEND)
			if(throw_impact)
				emote("flip")
				custom_emote(EMOTE_VISIBLE, "перехватыва%(ет,ют)% банан на лету и моментально проглатыва%(ет,ют)%.", intentional = TRUE)
			else
				custom_emote(EMOTE_VISIBLE, "проглатыва%(ет,ют)% банан и жадно смотрит на [giver].", intentional = TRUE)
			toggle_ai(AI_OFF)
			Goto(giver, move_to_delay, 2)
			befriend_timer = addtimer(CALLBACK(src, PROC_REF(reset_behavior), TRUE, TRUE), GORILLA_EXCITEMENT_TIME, TIMER_STOPPABLE|TIMER_DELETE_ME)
		else
			emote("flip")
			custom_emote(EMOTE_VISIBLE, "начина%(ет,ют)% скакать и довольно ухать, вокруг [giver].", intentional = TRUE)
			update_master(giver)
			follow_master()
			befriend_timer = addtimer(CALLBACK(src, PROC_REF(reset_behavior)), BANANAS_TO_BEFRIEND * TIME_PER_BANANA, TIMER_STOPPABLE|TIMER_DELETE_ME)


/**
 * Simple follow its master if gorilla is not waiting.
 */
/mob/living/simple_animal/hostile/gorilla/proc/follow_master()
	if(master && !is_waiting)
		check_buckled_gorilla()
		Goto(master, move_to_delay, 2)


/**
 * Changes current gorilla master.
 *
 * Arguments:
 * * user - new gorilla master.
 */
/mob/living/simple_animal/hostile/gorilla/proc/update_master(mob/living/carbon/human/user)
	if(user)
		LAZYCLEARLIST(friend2bananas)
		initial_faction = faction.Copy()
		faction = list("neutral", "monkey", "jungle")
		faction += "\ref[user]"
		master = user
		toggle_ai(AI_OFF)
		RegisterSignal(user, COMSIG_MOB_POINTED, PROC_REF(check_pointed))
		RegisterSignal(user, COMSIG_MOB_DEATH, PROC_REF(on_death))


/**
 * Resetting gorilla after master's death.
 */
/mob/living/simple_animal/hostile/gorilla/proc/on_death(mob/living/carbon/human/user, gibbed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(reset_behavior), FALSE)


/**
 * Reset variables for gorilla after end of friendship or after excitement is finished.
 *
 * Arguments:
 * * play_emote - whether to play visible custom emote.
 * * end_of_excitement - marker to distinguish excitement reset from default.
 */
/mob/living/simple_animal/hostile/gorilla/proc/reset_behavior(play_emote = TRUE, end_of_excitement = FALSE)
	check_buckled_gorilla()
	SSmove_manager.stop_looping(src)
	toggle_ai(AI_ON)
	if(play_emote)
		oogaooga(100, 200)
		custom_emote(EMOTE_VISIBLE, "недовольно кряхт%(ит,ят)% и отворачива%(ет,ют)%ся[master ? " от [master]" : ""].", intentional = TRUE)
	if(end_of_excitement)
		befriend_timer = null
		return
	is_waiting = FALSE
	enlighten_message_done = FALSE
	bananas_eaten = 0
	lighting_alpha = initial(lighting_alpha)
	update_sight()
	LAZYCLEARLIST(friend2bananas)
	if(master)
		UnregisterSignal(master, list(COMSIG_MOB_POINTED, COMSIG_MOB_DEATH))
		master = null
		point_target = null
		target_turf = null
	if(LAZYLEN(crates_in_hand))
		drop_all_crates(drop_location())
	if(is_bipedal)
		gorilla_toggle.Activate()
	if(initial_faction)
		faction = initial_faction
		initial_faction = null
	if(befriend_timer)
		deltimer(befriend_timer)
		befriend_timer = null


/**
 * Is gorilla enlightened enough by bananas?
 */
/mob/living/simple_animal/hostile/gorilla/proc/check_enlighten()
	return bananas_eaten >= BANANAS_TO_ENLIGHTEN


/**
 * Starts general actions cooldown for gorilla.
 */
/mob/living/simple_animal/hostile/gorilla/proc/start_action_cooldown()
	COOLDOWN_START(src, gorilla_actions_cooldown, GORILLA_ACTIONS_COOLDOWN)


/**
 * Checks general actions cooldown for gorilla. Returns `TRUE` if still in progress.
 */
/mob/living/simple_animal/hostile/gorilla/proc/is_on_cooldown()
	return !COOLDOWN_FINISHED(src, gorilla_actions_cooldown)


#undef GORILLA_ACTIONS_COOLDOWN
#undef GORILLA_EXCITEMENT_TIME
#undef TIME_PER_BANANA
#undef BANANAS_TO_BEFRIEND
#undef BANANAS_TO_ENLIGHTEN

