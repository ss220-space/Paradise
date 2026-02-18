//Radiation storms occur when the station passes through an irradiated area, and irradiate anyone not standing in protected areas (maintenance, emergency storage, etc.)
/datum/weather/rad_storm
	name = "radiation storm"
	desc = "A cloud of intense radiation passes through the area dealing rad damage to those who are unprotected."

	telegraph_duration = 400
	telegraph_message = span_danger_alt("The air begins to grow warm.")

	weather_message = span_userdanger_alt("<i>You feel waves of heat wash over you! Find shelter!</i>")
	weather_overlay = "ash_storm"
	weather_duration_lower = 600
	weather_color = "green"
	weather_sound = 'sound/misc/bloblarm.ogg'

	end_duration = 100
	end_message = span_notice_alt("The air seems to be cooling off again.")
	var/pre_maint_all_access
	area_type = /area
	protected_areas = list(/area/maintenance, /area/turret_protected/ai_upload, /area/turret_protected/ai_upload_foyer,
	/area/turret_protected/ai, /area/storage/emergency, /area/storage/emergency2, /area/crew_quarters/sleep, /area/security/brig, /area/shuttle,
	/area/coldcolony/malta/maintenance, /area/coldcolony/malta/turret_protected, /area/coldcolony/malta/outer/roadblock, /area/coldcolony/malta/resid_serv/crew_quarters/sleep,
	/area/coldcolony/malta/security/brig, /area/coldcolony/malta/security/securehallway, /area/coldcolony/malta/hallway/cargo_escape/exit)

	immunity_type = TRAIT_RADSTORM_IMMUNE

/datum/weather/rad_storm/endless
	weather_duration_upper = 10 HOURS

/datum/weather/rad_storm/telegraph()
	..()
	status_alarm(TRUE)
	pre_maint_all_access = SSmapping.maint_all_access
	if(SSmapping.maint_all_access)
		return

	SSmapping.make_maint_all_access()

/datum/weather/rad_storm/can_weather_act(mob/living/mob_to_check)
	if(!prob(40))
		return FALSE
	return ..()

/datum/weather/rad_storm/weather_act(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_RADIMMUNE) || HAS_TRAIT(target, TRAIT_NO_RADIATION_EFFECTS))
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

	status_alarm(FALSE)
	if(pre_maint_all_access)
		GLOB.minor_announcement.announce(
			message = "Радиационная угроза миновала. Пожалуйста, вернитесь на свои рабочие места. Доступ к дверям будет немедленно восстановлен.",
			new_title = ANNOUNCE_ANOMALY_RU
		)
		return

	GLOB.minor_announcement.announce(
		message = "Радиационная угроза миновала. Пожалуйста, вернитесь на свои рабочие места.",
		new_title = ANNOUNCE_ANOMALY_RU
	)
	addtimer(CALLBACK(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping, revoke_maint_all_access)), 10 SECONDS) // Bit of time to get out / break into somewhere.

/datum/weather/rad_storm/proc/status_alarm(active)	//Makes the status displays show the radiation warning for those who missed the announcement.
	if(active)
		post_status(STATUS_DISPLAY_ALERT, "radiation")
	else
		post_status(STATUS_DISPLAY_TRANSFER_SHUTTLE_TIME)
