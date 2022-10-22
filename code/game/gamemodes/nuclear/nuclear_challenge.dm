#define CHALLENGE_TELECRYSTALS 280
#define CHALLENGE_TIME_LIMIT 6000
#define CHALLENGE_SCALE_PLAYER 1 // How many player per scaling bonus
#define CHALLENGE_SCALE_BONUS 2 // How many TC per scaling bonus
#define CHALLENGE_MIN_PLAYERS 50
#define CHALLENGE_SHUTTLE_DELAY 18000 //30 minutes, so the ops have at least 10 minutes before the shuttle is callable. Gives the nuke ops at least 15 minutes before shuttle arrive.

/obj/item/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
	Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
	Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = FALSE
	var/total_tc = 0 //Total amount of telecrystals shared between nuke ops

/obj/item/nuclear_challenge/attack_self(mob/living/user)
	if(!check_allowed(user))
		return

	declaring_war = TRUE
	var/are_you_sure = alert(user, "Тщательно проконсультируйтесь со своей командой, прежде чем объявлять войну [station_name()]. Вы уверены, что хотите предупредить вражеский экипаж? У вас есть [-round((world.time-SSticker.round_start_time - CHALLENGE_TIME_LIMIT)/10)] секунд, чтобы решить.", "Объявить войну?", "Да", "Нет")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(are_you_sure == "No")
		to_chat(user, "Если подумать, элемент неожиданности всё же не так уж и плох.")
		return

	var/war_declaration = "[user.real_name] объяви[genderize_ru(user.gender,"л","ла","ло","ли")] о намерении полностью уничтожить [station_name()] с помощью ядерного устройства, и бросает вызов экипажу."

	declaring_war = TRUE
	var/custom_threat = alert(user, "Do you want to customize your declaration?", "Customize?", "Yes", "No")
	declaring_war = FALSE

	if(!check_allowed(user))
		return

	if(custom_threat == "Yes")
		declaring_war = TRUE
		war_declaration = stripped_input(user, "Insert your custom declaration", "Declaration")
		declaring_war = FALSE

	if(!check_allowed(user) || !war_declaration)
		return

	GLOB.event_announcement.Announce(war_declaration, "ОБЪЯВЛЕНИЕ ВОЙНЫ", 'sound/effects/siren.ogg')

	to_chat(user, "Вы привлекли внимание влиятельных сил в Синдикате. Ваша команда получила бонусный пакет телекристаллов. Вас ждёт великая награда, если вы выполните задание.")
	to_chat(user, "<b>Ваши бонусные телекристаллы были распределены между аплинками вашей команды.</b>")

	for(var/obj/machinery/computer/shuttle/syndicate/S in GLOB.machines)
		S.challenge = TRUE

	 // No. of player - Min. Player to dec, divided by player per bonus, then multipled by TC per bonus. Rounded.
	total_tc = CHALLENGE_TELECRYSTALS + round((((GLOB.player_list.len - CHALLENGE_MIN_PLAYERS)/CHALLENGE_SCALE_PLAYER) * CHALLENGE_SCALE_BONUS))
	share_telecrystals()
	config.shuttle_refuel_delay = CHALLENGE_SHUTTLE_DELAY
	qdel(src)

/obj/item/nuclear_challenge/proc/share_telecrystals()
	var/player_tc
	var/remainder

	player_tc = round(total_tc / GLOB.nuclear_uplink_list.len) //round to get an integer and not floating point
	remainder = total_tc % GLOB.nuclear_uplink_list.len

	for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
		U.hidden_uplink.uses += player_tc
	while(remainder > 0)
		for(var/obj/item/radio/uplink/nuclear/U in GLOB.nuclear_uplink_list)
			if(remainder <= 0)
				break
			U.hidden_uplink.uses++
			remainder--

/obj/item/nuclear_challenge/proc/check_allowed(mob/living/user)
	if(declaring_war)
		to_chat(user, "Вы уже находитесь в процессе объявления войны!")
		return FALSE
	if(GLOB.player_list.len < CHALLENGE_MIN_PLAYERS)
		to_chat(user, "Вражеский экипаж слишком мал, чтобы стоило объявлять ему войну.")
		return FALSE
	if(!is_admin_level(user.z))
		to_chat(user, "Чтобы использовать это, вы должны находиться на своей базе".")
		return FALSE
	if((world.time - SSticker.round_start_time) > CHALLENGE_TIME_LIMIT) // Only count after the round started
		to_chat(user, "Слишком поздно объявлять военные действия. Ваши благодетели уже заняты другими планами. Вам придется довольствоваться тем, что есть в наличии.")
		return FALSE
	for(var/obj/machinery/computer/shuttle/syndicate/S in GLOB.machines)
		if(S.moved)
			to_chat(user, "Шаттл тронулся с места! Вы утратили право объявить войну.")
			return FALSE
	return TRUE

#undef CHALLENGE_TIME_LIMIT
#undef CHALLENGE_MIN_PLAYERS
#undef CHALLENGE_SHUTTLE_DELAY
#undef CHALLENGE_TELECRYSTALS
#undef CHALLENGE_SCALE_PLAYER
#undef CHALLENGE_SCALE_BONUS
