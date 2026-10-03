/datum/emote/living/simple_animal
	abstract_type = /datum/emote/living/simple_animal
	mob_type_allowed_typecache = list(/mob/living/simple_animal)
	keybind_category = KB_CATEGORY_EMOTE_ANIMAL

/datum/emote/living/simple_animal/diona_chirp
	name = "Чирикать (диона)"
	key = "chirp"
	key_third_person = "chirps"
	message = "чирика%(ет,ют)%."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	sound = 'sound/creatures/nymphchirp.ogg'
	mob_type_allowed_typecache = list(/mob/living/simple_animal/diona)

/datum/emote/living/simple_animal/pet
	abstract_type = /datum/emote/living/simple_animal/pet

/**
 * Dog emotes
 */
/datum/emote/living/simple_animal/pet/dog
	abstract_type = /datum/emote/living/simple_animal/pet/dog
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/dog)

/datum/emote/living/simple_animal/pet/dog/bark
	name = "Лаять (пёс)"
	key = "bark"
	key_third_person = "barks"
	message = "ла%(ет,ют)%."
	message_postfix = " на %t."
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/simple_animal/pet/dog/bark/select_message_type(mob/living/simple_animal/pet/dog/user, msg, intentional)
	. = safepick(user.bark_emote)
	if(!.)
		return ..()

/datum/emote/living/simple_animal/pet/dog/bark/get_sound(mob/living/simple_animal/pet/dog/user)
	return safepick(user.bark_sound)

/datum/emote/living/simple_animal/pet/dog/yelp
	name = "Тявкать (пёс)"
	key = "yelp"
	key_third_person = "yelps"
	message = "тявка%(ет,ют)%!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	volume = 75

/datum/emote/living/simple_animal/pet/dog/yelp/get_sound(mob/living/simple_animal/pet/dog/user)
	return safepick(user.yelp_sound)

/datum/emote/living/simple_animal/pet/dog/growl
	name = "Рычать (пёс)"
	key = "growl"
	key_third_person = "growls"
	message = "рыч%(ит,ат)%!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	volume = 75

/datum/emote/living/simple_animal/pet/dog/growl/get_sound(mob/living/simple_animal/pet/dog/user)
	return safepick(user.growl_sound)

/**
 * Mouse
 */
/datum/emote/living/simple_animal/mouse
	abstract_type = /datum/emote/living/simple_animal/mouse
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	mob_type_allowed_typecache = list(/mob/living/simple_animal/mouse)

/datum/emote/living/simple_animal/mouse/squeak
	name = "Писк (мышь)"
	key = "squeak"
	key_third_person = "squeaks"
	message = "пищ%(ит,ат)%!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	volume = 40

/datum/emote/living/simple_animal/mouse/squeak/get_sound(mob/living/simple_animal/mouse/user)
	return user.squeak_sound

/datum/emote/living/simple_animal/mouse/scream
	name = "Кричать (мышь)"
	key = "scream"
	key_third_person = "screams"
	message = "тревожно пищ%(ит,ат)%!"
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	volume = 40

/datum/emote/living/simple_animal/mouse/scream/get_sound(mob/living/simple_animal/mouse/user)
	return user.damaged_sound

/**
 * Cat
 */
/datum/emote/living/simple_animal/pet/cat
	abstract_type = /datum/emote/living/simple_animal/pet/cat
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/cat)

/datum/emote/living/simple_animal/pet/cat/meow
	name = "Мяукать (кот)"
	key = "meow"
	key_third_person = "meows"
	message = "мяука%(ет,ют)%."
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE

/datum/emote/living/simple_animal/pet/cat/meow/get_sound(mob/living/simple_animal/pet/cat/user)
	return user.meow_sound

/datum/emote/living/simple_animal/pet/cat/hiss
	name = "Шипеть (кот)"
	key = "hiss"
	key_third_person = "hisses"
	message = "шип%(ит,ят)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/simple_animal/pet/cat/purr
	name = "Мурлыкать (кот)"
	key = "purr"
	key_third_person = "purrs"
	message = "мурлыка%(ет,ют)%."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/sit/cat
	name = "Сесть/Встать (кот)"
	message = null
	mob_type_allowed_typecache = list(/mob/living/simple_animal/pet/cat)

/datum/emote/living/sit/cat/run_emote(mob/living/simple_animal/pet/cat/user, params, type_override, intentional)
	user.sit()
	return TRUE

/**
 * Frog
 */
/datum/emote/living/simple_animal/frog_warcry
	name = "Боевой клич (лягушка)"
	key = "warcry"
	message = "изда%(ёт,ют)% боевой клич!"
	message_postfix = ", в сторону %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE
	vary = TRUE
	audio_cooldown = 6 SECONDS
	mob_type_allowed_typecache = list(/mob/living/simple_animal/frog)

/datum/emote/living/simple_animal/frog_warcry/get_sound(mob/living/simple_animal/frog/user)
	var/sound_frog = pick(user.scream_sound)
	return sound_frog
