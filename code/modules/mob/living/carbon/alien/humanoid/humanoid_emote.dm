/datum/emote/living/carbon/alien/humanoid
	mob_type_allowed_typecache = list(/mob/living/carbon/alien/humanoid)


/datum/emote/living/carbon/alien/humanoid/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "шип%(ит,ят)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	volume = 30
	sound = 'sound/voice/hiss1.ogg'


/datum/emote/living/carbon/alien/humanoid/gnarl
	key = "gnarl"
	key_third_person = "gnarls"
	message = "рыч%(ит,ат)% и сверка%(ет,ют)% зубами!"
	message_postfix = "в сторону %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	volume = 30
	sound = 'sound/voice/hiss4.ogg'

