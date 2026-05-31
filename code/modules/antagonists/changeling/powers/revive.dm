/datum/action/changeling/revive
	name = "Регенерация"
	desc = "Мы регенерировали, вылечив весь урон сосуду."
	helptext = "Не рекомендуется использовать при свидетелях."
	button_icon_state = "revive"
	req_stat = DEAD
	bypass_fake_death = TRUE

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(mob/living/carbon/human/user)
	cling = IS_CHANGELING(user)
	if(cling.absorbed_count == 0)
		user.balloon_alert(user, "нужно больше ДНК")
		REMOVE_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)

		if(HAS_TRAIT(user, TRAIT_HUSK))
			to_chat(user, span_changeling("Стазис прерван из-за отсутствия ДНК, но мы смогли частично восстановить нашу ДНК для сторонней реанимации."))
			user.cure_husk()

		Remove(user)
		return FALSE

	if(istype(user.loc, /obj/structure/blob/special/core))
		to_chat(user, span_changeling("Окружающие вас щупальца блоба не дают вам регенерировать"))
		return FALSE

	to_chat(user, span_changeling("Мы регенерировали!"))
	REMOVE_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)

	if(user.pulledby)
		var/mob/living/carbon/grab_owner = user.pulledby
		user.visible_message(span_warning("[user] неожиданно бъёт [grab_owner] в лицо и вырывается из захвата!"))
		grab_owner.apply_damage(5, BRUTE, BODY_ZONE_HEAD, grab_owner.run_armor_check(BODY_ZONE_HEAD, MELEE))
		playsound(user.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)
		grab_owner.stop_pulling()

	user.revive()
	user.updatehealth("revive sting")
	user.update_blind_effects()
	user.update_blurry_effects()
	user.UpdateAppearance() //Ensures that the user's appearance matches their DNA.
	user.set_resting(FALSE, instant = TRUE)
	user.get_up(TRUE)
	user.update_revive() //Handle waking up the changeling after the regenerative stasis has completed.

	cling.acquired_powers -= src
	Remove(user)
	user.med_hud_set_status()
	user.med_hud_set_health()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

