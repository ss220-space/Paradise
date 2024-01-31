/datum/emote/living/carbon
	mob_type_allowed_typecache = list(/mob/living/carbon)
	mob_type_blacklist_typecache = list(/mob/living/carbon/brain)


/datum/emote/living/carbon/blink
	key = "blink"
	key_third_person = "blinks"
	message = "морга%(ет,ют)%."


/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "быстро морга%(ет,ют)%."


/datum/emote/living/carbon/cross
	key = "cross"
	key_third_person = "crosses"
	message = "скрещива%(ет,ют)% руки."
	hands_use_check = TRUE


/datum/emote/living/carbon/chuckle
	key = "chuckle"
	key_third_person = "chuckles"
	message = "усмеха%(ет,ют)%ся."
	message_mime = "будто бы усмеха%(ет,ют)%ся."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("радостные", "оживлённые")


/datum/emote/living/carbon/cough
	key = "cough"
	key_third_person = "coughs"
	message = "кашля%(ет,ют)%!"
	message_mime = "бесшумно кашля%(ет,ют)%!"
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 120
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/carbon/cough/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_cough_sounds)
		else
			. = safepick(user.dna.species.male_cough_sounds)
	if(!.)
		return ..()


/datum/emote/living/carbon/moan
	key = "moan"
	key_third_person = "moans"
	message = "стон%(ет,ут)%!"
	message_mime = "кажется стон%(ет,ут)%!"
	muzzled_noises = list("болезненные")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/moan/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_moan_sound)
		else
			. = safepick(user.dna.species.male_moan_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/giggle
	key = "giggle"
	key_third_person = "giggles"
	message = "хихика%(ет,ют)%."
	message_mime = "бесшумно хихика%(ет,ют)%!"
	muzzled_noises = list("булькающие")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/giggle/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_giggle_sound)
		else
			. = safepick(user.dna.species.male_giggle_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/gurgle
	key = "gurgle"
	key_third_person = "gurgles"
	message = "изда%(ет,ют)% неприятное бульканье."
	muzzled_noises = list("неприятные", "гортанные")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/carbon/inhale
	key = "inhale"
	key_third_person = "inhales"
	message = "вдыха%(ет,ют)%."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("хриплые")


/datum/emote/living/carbon/inhale/deep
	key = "inhale_d"
	message = "дела%(ет,ют)% глубокий вдох."


/datum/emote/living/carbon/exhale
	key = "exhale"
	key_third_person = "exhales"
	message = "выдыха%(ет,ют)%."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH


/datum/emote/living/carbon/kiss
	key = "kiss"
	key_third_person = "kisses"
	message = "посыла%(ет,ют)% воздушный поцелуй."
	message_postfix = " %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	muzzled_noises = list("чмокающие")


/datum/emote/living/carbon/wave
	key = "wave"
	key_third_person = "waves"
	message = "маш%(ет,ут)%."
	message_postfix = " %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	hands_use_check = TRUE


/datum/emote/living/carbon/yawn
	key = "yawn"
	key_third_person = "yawns"
	message = "зева%(ет,ют)%."
	message_mime = "дела%(ет,ют)% вид, что зева%(ет,ют)%."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	muzzled_noises = list("усталые", "сонные")
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/yawn/get_sound(mob/living/carbon/human/user)
	if(ishuman(user))
		if(user.gender == FEMALE)
			return pick('sound/voice/yawn_female_1.ogg', 'sound/voice/yawn_female_2.ogg', 'sound/voice/yawn_female_3.ogg')
		return pick('sound/voice/yawn_male_1.ogg', 'sound/voice/yawn_male_2.ogg')
	return ..()


/datum/emote/living/carbon/laugh
	key = "laugh"
	key_third_person = "laughs"
	message = "сме%(ёт,ют)%ся."
	message_mime = "бесшумно сме%(ёт,ют)%ся."
	message_postfix = " над %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	muzzled_noises = list("счастливые", "радостные")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	age_based = TRUE
	volume = 70


/datum/emote/living/carbon/laugh/get_sound(mob/living/carbon/human/user)
	if(ishuman(user) && user.dna?.species)
		if(user.gender == FEMALE)
			. = safepick(user.dna.species.female_laugh_sound)
		else
			. = safepick(user.dna.species.male_laugh_sound)
	if(!.)
		return ..()


/datum/emote/living/carbon/scowl
	key = "scowl"
	key_third_person = "scowls"
	message = "мрачно смотр%(ит,ят)%."
	message_postfix = " на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX


/datum/emote/living/carbon/groan
	key = "groan"
	key_third_person = "groans"
	message = "болезненно вздыха%(ет,ют)%."
	message_mime = "как будто болезненно вздыха%(ет,ют)%."
	message_postfix = ", смотря на %t."
	message_param = EMOTE_PARAM_USE_POSTFIX
	muzzled_noises = list("болезненные")
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	unintentional_stat_allowed = UNCONSCIOUS


/datum/emote/living/carbon/sign
	key = "sign"
	key_third_person = "signs"
	message = "пыта%(ет,ют)%ся что-то показать."
	message_param = "показыва%(ет,ют)% число %t."
	param_desc = "number(0-10)"
	mob_type_blacklist_typecache = list(/mob/living/carbon/human)	// Humans get their own proc since they have fingers
	hands_use_check = TRUE
	target_behavior = EMOTE_TARGET_BHVR_NUM


/datum/emote/living/carbon/faint
	key = "faint"
	key_third_person = "faints"
	message = "пада%(ет,ют)% в обморок!"


/datum/emote/living/carbon/faint/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(. && isliving(user))
		user.AdjustSleeping(4 SECONDS)


/datum/emote/living/carbon/twirl
	key = "twirl"
	key_third_person = "twirls"
	message = "верт%(ит,ят)% что-то в руках."
	hands_use_check = TRUE


/datum/emote/living/carbon/twirl/run_emote(mob/user, params, type_override, intentional)

	var/obj/item/active_hand = user.get_active_hand()
	var/obj/item/inactive_hand = user.get_inactive_hand()

	if(!active_hand && !inactive_hand)
		to_chat(user, span_warning("You need something in your hand to use this emote!"))
		return TRUE

	var/obj/item/thing = active_hand ? active_hand : (inactive_hand ? inactive_hand : null)

	if(istype(thing, /obj/item/grab))
		var/obj/item/grab/grabbed = thing
		message = "крут%(ит,ят)% <b>[grabbed.affecting.name]</b>, удерживая [genderize_ru(grabbed.affecting.gender, "его", "её", "его", "их")] в захвате!"
		grabbed.affecting.emote("spin")

	else if(!(thing.flags & ABSTRACT))
		message = "верт%(ит,ят)% [thing.name] в руках!"

	else
		to_chat(user, span_warning("You cannot twirl [thing]!"))
		return TRUE

	. = ..()
	message = initial(message)

