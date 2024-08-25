/datum/emote/living
	mob_type_allowed_typecache = /mob/living
	mob_type_blacklist_typecache = list(
		/mob/living/carbon/brain,	// nice try
		/mob/living/captive_brain,
		/mob/living/silicon,
		/mob/living/simple_animal/bot,
		/mob/living/simple_animal/slime,
	)
	message_postfix = " на %t."


/datum/emote/living/should_play_sound(mob/user, intentional)
	if(user.mind?.miming)
		return FALSE  // shh
	return ..()


/datum/emote/living/blush
	key = "blush"
	key_third_person = "blushes"
	message = "красне%(ет,ют)%."


/datum/emote/living/bow
	key = "bow"
	key_third_person = "bows"
	message = "кланя%(ет,ют)%ся."
	message_postfix = " %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/burp
	key = "burp"
	key_third_person = "burps"
	message = "отрыгива%(ет,ют)%."
	message_mime = "довольно противно открыва%(ет,ют)% рот."
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("своеобразные")


/datum/emote/living/choke
	key = "choke"
	key_third_person = "chokes"
	message = "подавил%(ся,ась,ось,ись)%!"
	message_mime = "отчаянно хвата%(ет,ют)%ся за горло!"
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("гортанные", "громкие")
	age_based = TRUE
	cooldown = 5 SECONDS


/datum/emote/living/choke/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_choke_sound)
		else
			. = safepick(user.dna.species.male_choke_sound)
	if(!.)
		return ..()


/datum/emote/living/collapse
	key = "collapse"
	key_third_person = "collapses"
	message = "пада%(ет,ют)% без сознания!"
	emote_type = EMOTE_VISIBLE


/datum/emote/living/collapse/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(.)
		user.Paralyse(4 SECONDS)


/datum/emote/living/dance
	key = "dance"
	key_third_person = "dances"
	message = "радостно танцу%(ет,ют)%."
	hands_use_check = TRUE
	cooldown = 5 SECONDS
	var/dance_time = 3 SECONDS


/datum/emote/living/dance/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(. && istype(user))
		var/obj/structure/table/table = locate() in user.loc
		if(table)
			table.clumse_stuff(user)

		user.spin(dance_time, pick(0.1 SECONDS, 0.2 SECONDS))
		user.do_jitter_animation(rand(8 SECONDS, 16 SECONDS), dance_time / 4)


/datum/emote/living/jump
	key = "jump"
	key_third_person = "jumps"
	message = "прыга%(ет,ют)%!"


/datum/emote/living/deathgasp
	key = "deathgasp"
	key_third_person = "deathgasps"
	emote_type = EMOTE_AUDIBLE|EMOTE_VISIBLE  // make sure deathgasp gets runechatted regardless
	age_based = TRUE
	cooldown = 10 SECONDS
	volume = 40
	unintentional_stat_allowed = DEAD
	muzzle_ignore = TRUE // makes sure that sound is played upon death
	bypass_unintentional_cooldown = TRUE  // again, this absolutely MUST play when a user dies, if it can.
	message = "цепене%(ет,ют)% и расслабля%(ет,ют)%ся, %(его,её,его,их)% взгляд становится пустым и безжизненным..."
	message_robot = "на мгновение вздрагива%(ет,ют)% и замира%(ет,ют)%, %(его,её,его,их)% глаза медленно темнеют..."
	message_AI = "скрип%(ит,ят)% и мерца%(ет,ют)% экраном, пока %(его,её,его,их)% системы медленно отключаются..."
	message_alien = "изда%(ёт,ют)% тихий гортанный звук, зелёная кровь пузырится из %(его,её,его,их)% пасти..."
	message_larva = "с тошнотворным шипением выдыха%(ет,ют)% воздух и пада%(ет,ют)% на пол..."
	message_monkey = "изда%(ёт,ют)% тихий визг, пада%(ет,ют)% и переста%(ёт,ют)% двигаться..."
	message_simple = "переста%(ёт,ют)% двигаться..."

	mob_type_blacklist_typecache = list(
		/mob/living/carbon/brain,
		/mob/living/captive_brain,
	)


/datum/emote/living/deathgasp/select_message_type(mob/user, msg, intentional)
	if(ishuman(user))
		. = user.dna?.species?.death_message
	else if(isalien(user))
		var/mob/living/carbon/alien/alien = user
		. = alien.death_message
	else if(isanimal(user))
		var/mob/living/simple_animal/animal = user
		. = animal.deathmessage	// TODO: translate all death messages
	if(!.)
		return ..()


/datum/emote/living/deathgasp/should_play_sound(mob/user, intentional)
	if(user.is_muzzled() && intentional)
		return FALSE
	return ..()


/datum/emote/living/deathgasp/get_sound(mob/living/user)
	if(ishuman(user) && user.dna?.species)
		var/mob/living/carbon/human/human = user
		. = safepick(human.dna.species.death_sounds)

	else if(isalien(user))
		var/mob/living/carbon/alien/alien = user
		. = alien.death_sound

	else if(issilicon(user))
		var/mob/living/silicon/silicon = user
		. = silicon.death_sound

	else if(isanimal(user))
		var/mob/living/simple_animal/animal = user
		. = animal.death_sound

	if(!.)
		return ..()


/datum/emote/living/deathgasp/play_sound_effect(mob/living/carbon/human/user, intentional, sound_path, sound_volume)
	if(!ishuman(user))
		return ..()
	// special handling here: we don't want monkeys' gasps to sound through walls so you can actually walk past xenobio
	playsound(user.loc, sound_path, sound_volume, TRUE, -8, frequency = user.get_age_pitch(), ignore_walls = !isnull(user.mind))


/datum/emote/living/drool
	key = "drool"
	key_third_person = "drools"
	message = "нес%(ёт,ут)% чепуху."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/quiver
	key = "quiver"
	key_third_person = "quivers"
	message = "трепещ%(ет,ут)%."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/frown
	key = "frown"
	key_third_person = "frowns"
	message = "хмур%(ит,ят)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/gag
	key = "gag"
	key_third_person = "gags"
	message = "выворачивает."
	message_mime = "кажется выворачивает."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("рвотные", "громкие")


/datum/emote/living/glare
	key = "glare"
	key_third_person = "glares"
	message = "свирепо смотр%(ит,ят)%."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/grin
	key = "grin"
	key_third_person = "grins"
	message = "скал%(ит,ят)%ся в улыбке."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/grimace
	key = "grimace"
	key_third_person = "grimaces"
	message = "гримаснича%(ет,ют)%."


/datum/emote/living/look
	key = "look"
	key_third_person = "looks"
	message = "смотр%(ит,ят)%."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/bshake
	key = "bshake"
	key_third_person = "bshakes"
	message = "тряс%(ёт,ут)%ся."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/shudder
	key = "shudder"
	key_third_person = "shudders"
	message = "содрога%(ет,ют)%ся."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/point
	key = "point"
	key_third_person = "points"
	message = "указыва%(ет,ют)%."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/datum/emote/living/point/act_on_target(mob/user, target)
	if(!target)
		return
	user.pointed(target)


/datum/emote/living/point/run_emote(mob/living/carbon/human/user, params, type_override, intentional)
	// again, /tg/ has some flavor when pointing (like if you only have one leg) that applies debuffs
	// but it's so common that seems unnecessary here
	message_param = initial(message_param) // reset
	if(ishuman(user) && user.usable_hands == 0)
		if(user.usable_legs != 0)	// MY LEEEG!
			message_param = "пыта%(ет,ют)%ся указать ногой на %t."
		else
			// nugget
			message_param = "[span_userdanger("ударя%(ет,ют)%ся головой об пол")], пытаясь указать на %t."
	return ..()


/datum/emote/living/pout
	key = "pout"
	key_third_person = "pouts"
	message = "надува%(ет,ют)% губы."


/datum/emote/living/scream
	key = "scream"
	key_third_person = "screams"
	message = "крич%(ит,ат)%!"
	message_mime = "делает вид, что крич%(ит,ат)%!"
	message_simple = "скул%(ит,ят)%."
	message_alien = "рыч%(ит,ат)%!"
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	mob_type_blacklist_typecache = list(
		// Humans and silicons get specialized scream.
		/mob/living/carbon/human,
		/mob/living/silicon,
		/mob/living/captive_brain,
		/mob/living/simple_animal/slime,
	)
	vary = TRUE
	volume = 80


/datum/emote/living/scream/get_sound(mob/living/user)
	if(isalien(user))
		return 'sound/voice/hiss5.ogg'
	return ..()


/datum/emote/living/shake
	key = "shake"
	key_third_person = "shakes"
	message = "тряс%(ёт,ут)% головой."


/datum/emote/living/shiver
	key = "shiver"
	key_third_person = "shivers"
	message = "дрож%(ит,ат)%."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/sigh
	key = "sigh"
	key_third_person = "sighs"
	message = "вздыха%(ет,ют)%."
	message_mime = "кажется вздыха%(ет,ют)%."
	muzzled_noises = list("тихие")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 70


/datum/emote/living/sigh/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_sigh_sound)
		else
			. = safepick(user.dna.species.male_sigh_sound)
	if(!.)
		return ..()


/datum/emote/living/sigh/happy
	key = "hsigh"
	key_third_person = "hsighs"
	message = "удовлетворённо вздыха%(ет,ют)%."
	message_mime = "кажется удовлетворённо вздыха%(ет,ют)%."
	muzzled_noises = list("довольные", "удовлетворённые")


/datum/emote/living/sit
	key = "sit"
	key_third_person = "sits"
	message = "сад%(ит,ят)%ся."


/datum/emote/living/smile
	key = "smile"
	key_third_person = "smiles"
	message = "улыба%(ет,ют)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	species_type_blacklist_typecache = list(/datum/species/skrell)	// they got their own


/datum/emote/living/wsmile
	key = "wsmile"
	key_third_person = "wsmiles"
	message = "слабо улыба%(ет,ют)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	species_type_blacklist_typecache = list(/datum/species/skrell)


/datum/emote/living/smug
	key = "smug"
	key_third_person = "smugs"
	message = "самодовольно ухмыля%(ет,ют)%ся."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/sniff
	key = "sniff"
	key_third_person = "sniffs"
	message = "нюха%(ет,ют)%."
	message_mime = "бесшумно втягива%(ет,ют)% воздух."
	emote_type = EMOTE_AUDIBLE
	unintentional_stat_allowed = UNCONSCIOUS
	vary = TRUE
	age_based = TRUE
	volume = 30


/datum/emote/living/sniff/get_sound(mob/living/user)
	if(user.gender == FEMALE)
		return 'sound/voice/sniff_female.ogg'
	return 'sound/voice/sniff_male.ogg'


/datum/emote/living/snore
	key = "snore"
	key_third_person = "snores"
	message = "храп%(ит,ят)%."
	message_mime = "крепко сп%(ит,ят)%."
	message_simple = "вороча%(ет,ют)%ся во сне."
	message_robot = "грез%(ит,ят)% об электроовцах..."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	volume = 70
	age_based = TRUE


/datum/emote/living/snore/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_snore_sound)
		else
			. = safepick(user.dna.species.male_snore_sound)
	if(!.)
		return ..()


/datum/emote/living/nightmare
	key = "nightmare"
	message = "содрога%(ет,ют)%ся во сне."
	emote_type = EMOTE_VISIBLE
	stat_allowed = UNCONSCIOUS
	max_stat_allowed = UNCONSCIOUS
	unintentional_stat_allowed = UNCONSCIOUS
	max_unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/nightmare/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return FALSE
	user.dir = pick(GLOB.cardinal)


/datum/emote/living/stare
	key = "stare"
	key_third_person = "stares"
	message = "пял%(ит,ят)%ся."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/strech
	key = "stretch"
	key_third_person = "stretches"
	message = "размина%(ет,ют)% конечности."
	message_robot = "проверя%(ет,ют)% приводы."


/datum/emote/living/sulk
	key = "sulk"
	key_third_person = "sulks"
	message = "ду%(ет,ют)%ся."


/datum/emote/living/sway
	key = "sway"
	key_third_person = "sways"
	message = "умопомрачительно круж%(ит,ат)%ся."


/datum/emote/living/swear
	key = "swear"
	key_third_person = "swears"
	message = "руга%(ет,ют)%ся!"
	message_mime = "дела%(ет,ют)% непристойный жест!"
	message_simple = "изда%(ёт,ют)% сердитый шум!"
	message_robot = "изда%(ёт,ют)% серию исключительно оскорбительных сигналов!"
	message_postfix = " в сторону %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	mob_type_blacklist_typecache = list(
		/mob/living/carbon/brain,
		/mob/living/captive_brain,
		/mob/living/simple_animal/slime,
	)


/datum/emote/living/tilt
	key = "tilt"
	key_third_person = "tilts"
	message = "наклоня%(ет,ют)% голову на бок."


/datum/emote/living/tremble
	key = "tremble"
	key_third_person = "trembles"
	message = "дрож%(ит,ат)% в ужасе!"


/datum/emote/living/twitch
	key = "twitch"
	key_third_person = "twitches"
	message = "сильно дёрга%(ет,ют)%ся."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/twitch_s
	key = "twitch_s"
	message = "дёрга%(ет,ют)%ся."
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/whimper
	key = "whimper"
	key_third_person = "whimpers"
	message = "хныч%(ет,ут)%."
	message_mime = "каж%(ет,ут)%ся ранен%(ым,ой,ым,ыми)%."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("тихие", "жалкие")


/datum/emote/living/custom
	key = "me"
	key_third_person = "custom"
	message = null
	mob_type_blacklist_typecache = list(
		/mob/living/carbon/brain,	// nice try
		/mob/living/captive_brain,
	)

	// Custom emotes should be able to be forced out regardless of context.
	// It falls on the caller to determine whether or not it should actually be called.
	unintentional_stat_allowed = DEAD


/datum/emote/living/custom/proc/check_invalid(mob/user, input)
	var/static/regex/stop_bad_mime = regex(@"says|exclaims|yells|asks")
	if(stop_bad_mime.Find(input, 1, 1))
		to_chat(user, span_danger("Invalid emote."))
		return TRUE
	return FALSE


/datum/emote/living/custom/run_emote(mob/user, params, type_override = null, intentional = FALSE)
	var/custom_emote
	var/custom_emote_type

	if(QDELETED(user))
		return FALSE
	else if(user.client && check_mute(user.client.ckey, MUTE_IC))
		to_chat(user, span_boldwarning("You cannot send IC messages (muted)."))
		return FALSE
	else if(!params)
		custom_emote = tgui_input_text(user, "Choose an emote to display.", "Custom Emote")
		if(custom_emote && !check_invalid(user, custom_emote))
			var/type = tgui_alert(user, "Is this a visible or hearable emote?", "Custom Emote", list("Visible", "Hearable"))
			switch(type)
				if("Visible")
					custom_emote_type = EMOTE_VISIBLE
				if("Hearable")
					custom_emote_type = EMOTE_AUDIBLE
				else
					to_chat(user, span_warning("Unable to use this emote, must be either hearable or visible."))
					return
	else
		custom_emote = params
		if(type_override)
			custom_emote_type = type_override

	message = custom_emote
	emote_type = custom_emote_type
	. = ..()
	message = initial(message)
	emote_type = initial(emote_type)

