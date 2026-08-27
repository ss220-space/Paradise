/datum/emote/living/carbon/alien/humanoid
	abstract_type = /datum/emote/living/carbon/alien/humanoid
	mob_type_allowed_typecache = list(/mob/living/carbon/alien/humanoid)
	keybind_category = KB_CATEGORY_EMOTE_ALIEN

/datum/emote/living/carbon/alien/humanoid/hiss
	name = "Шипеть"
	key = "hiss"
	key_third_person = "hisses"
	message = "шип%(ит,ят)%!"
	message_postfix = " на %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	volume = 30
	sound = SFX_HISS

/datum/emote/living/carbon/alien/humanoid/gnarl
	name = "Рычать"
	key = "gnarl"
	key_third_person = "gnarls"
	message = "рыч%(ит,ат)% и сверка%(ет,ют)% зубами!"
	message_postfix = "в сторону %t!"
	message_param = EMOTE_PARAM_USE_POSTFIX
	emote_type = EMOTE_AUDIBLE|EMOTE_MOUTH
	volume = 30
	sound = SFX_HISS
