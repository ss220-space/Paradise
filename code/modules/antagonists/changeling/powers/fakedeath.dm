/datum/action/changeling/fakedeath
	name = "Регенеративный стазис"
	desc = "Мы погружаемся в стазис, который позволяет регенерировать любые повреждения и обмануть наших врагов."
	button_icon_state = "fake_death"
	power_type = CHANGELING_INNATE_POWER
	req_stat = DEAD

/datum/action/changeling/fakedeath/sting_action(mob/living/user)
	if(user.stat != DEAD)
		cling.calculate_stasis_delay(user)
		user.emote("deathgasp")
		user.timeofdeath = world.time
		user.persistent_client?.time_of_death = world.time

	ADD_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)		//play dead
	user.updatehealth("fakedeath sting")

	var/stasis_delay = CLING_FAKEDEATH_TIME + cling.fakedeath_delay
	addtimer(CALLBACK(src, PROC_REF(ready_to_regenerate), user), stasis_delay)
	to_chat(user, span_changeling("Мы впали в стазис. Регенерация займёт <b>[stasis_delay / 10] секунд[DECL_SEC_MIN(stasis_delay / 10)]</b>."))
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/fakedeath/proc/ready_to_regenerate(mob/user)
	if(!QDELETED(user) && !QDELETED(src) && ischangeling(user) && cling?.acquired_powers)
		cling.fakedeath_delay = 0 SECONDS
		user.balloon_alert(user, "мы закончили регенерировать")
		cling.give_power(new /datum/action/changeling/revive)

/datum/action/changeling/fakedeath/can_sting(mob/user)
	if(HAS_TRAIT(user, TRAIT_FAKEDEATH))
		user.balloon_alert(user, "мы уже регенерируем")
		return FALSE

	if(!ishuman(user))
		user.balloon_alert(user, "неверная форма")
		return FALSE

	if(!user.stat)//Confirmation for living changelings if they want to fake their death
		if(tgui_alert(user, "Мы уверены, что хотим инсценировать нашу смерть?", "Регенерирующий стазис", list("Да", "Нет")) != "Да")
			return FALSE

	return ..()

