/datum/action/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	button_icon_state = "revive"
	req_stat = DEAD
	bypass_fake_death = TRUE

//Revive from regenerative stasis
/datum/action/changeling/revive/sting_action(mob/living/carbon/user)

	to_chat(user, span_changeling("We have regenerated."))

	REMOVE_TRAIT(user, TRAIT_FAKEDEATH, CHANGELING_TRAIT)

	if(user.pulledby)
		var/mob/living/carbon/grab_owner = user.pulledby
		user.visible_message(span_warning("[user] suddenly hits [grab_owner] in the face and slips out of their grab!"))
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

	cling.regenerating = FALSE
	cling.acquired_powers -= src
	Remove(user)
	user.med_hud_set_status()
	user.med_hud_set_health()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

