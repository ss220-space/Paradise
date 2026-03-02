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

/datum/emote/living/carbon/smoking
	key = "smoking"
	key_third_person = "smoked"
	message = "затягивается и выдыхает облако табачного дыма."
	message_mime = "беззвучно затягивается и выдыхает облако табачного дыма."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH

/datum/emote/living/carbon/finish_smoking
	key = "finish_smoking"
	key_third_person = "finished_smoking"
	message = "делает сильную затяжку и выкидывает окурок."
	message_mime = "делает сильную беззвучную затяжку и выкидывает окурок."
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH

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
	hands_use_check = TRUE

#define BUBBLE_TIME 4 SECONDS

/atom/movable/proc/spinning_item_in_bubble(atom/displayed_atom)
	if(!displayed_atom)
		return
	var/obj/effect/thought_bubble_effect = new
	var/mutable_appearance/thought_bubble = mutable_appearance(
		'icons/effects/effects.dmi',
		thought_bubble_image,
		layer = POINT_LAYER,
		offset_spokesman = src,
		plane = POINT_PLANE,
		appearance_flags = KEEP_APART,
	)

	thought_bubble.pixel_w = 16
	thought_bubble.alpha = 200
	thought_bubble.transform = matrix().Translate(0, 32)

	thought_bubble_effect.appearance = thought_bubble
	vis_contents += thought_bubble_effect
	LAZYADD(update_on_z, thought_bubble_effect)

	var/obj/effect/spinner = new
	spinner.appearance = displayed_atom.appearance
	spinner.plane = FLOAT_PLANE
	spinner.layer = FLOAT_LAYER

	spinner.SpinAnimation(6, 1, TRUE, 6)
	thought_bubble_effect.vis_contents += spinner

	addtimer(CALLBACK(src, PROC_REF(clear_point_bubble), thought_bubble_effect), BUBBLE_TIME)
	QDEL_IN(spinner, BUBBLE_TIME)

	thought_bubble_effect.alpha = 0
	animate(thought_bubble_effect, alpha = 255, time = 0.5 SECONDS, easing = EASE_OUT)
	animate(alpha = 255, time = BUBBLE_TIME - 1 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)

/datum/emote/living/carbon/twirl/run_emote(mob/living/user, params, type_override, intentional)
	var/mob/living/grabbed_mob
	var/obj/item/held_item = user.get_active_hand()
	if(!held_item && isliving(user.pulling) && user.grab_state > GRAB_PASSIVE && !isnull(user.pull_hand) && (user.pull_hand == PULL_WITHOUT_HANDS || user.pull_hand == user.hand))
		grabbed_mob = user.pulling
	if(!held_item && !grabbed_mob)
		held_item = user.get_inactive_hand()
		if(!held_item && isliving(user.pulling) && user.grab_state > GRAB_PASSIVE && !isnull(user.pull_hand) && (user.pull_hand == PULL_WITHOUT_HANDS || user.pull_hand != user.hand))
			grabbed_mob = user.pulling

	if(!held_item && !grabbed_mob)
		user.balloon_alert(user, "вы ничего не держите!")
		return TRUE

	if(held_item)
		if(held_item.item_flags & ABSTRACT)
			user.balloon_alert(user, "неподходящий предмет!")
			return TRUE
		held_item.SpinAnimation(6, 1, TRUE, 6)
		user.spinning_item_in_bubble(held_item)

	else if(grabbed_mob)
		message = "крут%(ит,ят)% <b>[grabbed_mob.name]</b>, удерживая [GEND_HIS_HER(grabbed_mob)] в захвате!"
		grabbed_mob.spin(32, 1)

	. = ..()
	message = initial(message)

#undef BUBBLE_TIME
