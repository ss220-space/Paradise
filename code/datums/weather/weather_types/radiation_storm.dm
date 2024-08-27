//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = "<span class='danger'>The air begins to grow warm.</span>"

	weather_message = "<span class='userdanger'><i>You feel waves of heat wash over you! Find shelter!</i></span>"
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = "<span class='notice'>The air seems to be cooling off again.</span>"
	var/pre_maint_all_access
	area_type = /area
	protected_areas = list(/area/maintenance, /area/turret_protected/ai_upload, /area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai, /area/storage/emergency, /area/storage/emergency2, /area/crew_quarters/sleep, /area/security/brig, /area/shuttle)
	target_trait = STATION_LEVEL

	immunity_type = TRAIT_RADSTORM_IMMUNE

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)
	pre_maint_all_access = GLOB.maint_all_access
	if(!GLOB.maint_all_access)
		make_maint_all_access()


/datum/weather/rad_storm/can_weather_act(mob/living/mob_to_check)
	if(!prob(40))
		return FALSE
	return ..()


/datum/weather/rad_storm/weather_act(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_RADIMMUNE))
		return

	var/resist = target.getarmor(attack_flag = RAD)
	target.apply_effect(20, IRRADIATE, resist)

	if(!ishuman(target) || !prob(max(0, 100 - resist)))
		return

	randmuti(target)

	if(prob(50))
		if(prob(90))
			randmutb(target)
		else
			randmutg(target)
	target.check_genes(MUTCHK_FORCED)


/datum/weather/rad_storm/end()
	if(..())
		return
	GLOB.priority_announcement.Announce("Радиационная угроза миновала. Пожалуйста, вернитесь на свои рабочие места.", "ВНИМАНИЕ: ОБНАРУЖЕНА АНОМАЛИЯ.")
	status_alarm(FALSE)
	if(!pre_maint_all_access)
		revoke_maint_all_access()

/datum/weather/rad_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "radiation")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
