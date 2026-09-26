/datum/action/changeling/digitalcamo
	name = "Цифровой камуфляж"
	desc = "Мы развиваем способность изменять свой силуэт, чтобы избегать поисковые алгоритмы камер. Можно использовать в низшей форме."
	helptext = "Нас нельзя отследить камерами, но при ближайшем рассмотрении можно заметить странности."
	button_icon_state = "digital_camo"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1

/datum/action/changeling/digitalcamo/Remove(mob/user)
	REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
	..()

/datum/action/changeling/digitalcamo/sting_action(mob/user)
	if(HAS_TRAIT_FROM(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
		REMOVE_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		user.balloon_alert(user, "нас можно отследить")
	else
		ADD_TRAIT(user, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT)
		user.balloon_alert(user, "камуфляж активен")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
