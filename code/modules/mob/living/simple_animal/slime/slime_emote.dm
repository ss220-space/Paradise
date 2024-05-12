/// Sentinel value; passing this as mood sets mood to null.
#define MOOD_RESET "reset"


/datum/emote/living/simple_animal/slime
	mob_type_allowed_typecache = list(/mob/living/simple_animal/slime)
	mob_type_blacklist_typecache = null
	/// Apply mood of the emote. Set this to MOOD_RESET to cause the emote to reset the mood back to default.
	var/mood


/datum/emote/living/simple_animal/slime/run_emote(mob/living/simple_animal/slime/user, params, type_override, intentional)
	. = ..()
	if(. && mood)
		user.mood = (mood == MOOD_RESET) ? null : mood
		user.regenerate_icons()


/datum/emote/living/simple_animal/slime/bounce
	key = "bounce"
	key_third_person = "bounces"
	message = "подпрыгива%(ет,ют)% на месте."


/datum/emote/living/simple_animal/slime/jiggle
	key = "jiggle"
	key_third_person = "jiggles"
	message = "покачива%(ет,ют)%ся!"


/datum/emote/living/simple_animal/slime/light
	key = "light"
	key_third_person = "lights"
	message = "начина%(ет,ют)% светиться и через некоторое время затуха%(ет,ют)%."


/datum/emote/living/simple_animal/slime/vibrate
	key = "vibrate"
	key_third_person = "vibrates"
	message = "вибриру%(ет,ют)%!"


/datum/emote/living/simple_animal/slime/noface
	// mfw no face
	key = "noface"
	mood = MOOD_RESET


/datum/emote/living/simple_animal/slime/smile
	key = "smile"
	mood = "mischevous"


/datum/emote/living/simple_animal/slime/colon_three
	key = ":3"
	mood = ":3"


/datum/emote/living/simple_animal/slime/colon_double_three
	key = ":33"
	mood = ":33"


/datum/emote/living/simple_animal/slime/pout
	key = "pout"
	mood = "pout"


/datum/emote/living/simple_animal/slime/sad
	key = "frown"
	mood = "sad"


/datum/emote/living/simple_animal/slime/scowl
	key = "scowl"
	mood = "angry"


#undef MOOD_RESET
