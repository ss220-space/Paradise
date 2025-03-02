//does low brute damage, oxygen damage, and stamina damage and wets tiles when damaged
/datum/blobstrain/reagent/pressurized_slime
	name = "Сжатая слизь"
	description = "наносит низкий урон травмами и урон гипоксией, высокий урон выносливости и делает пол под целями очень скользкими, туша их."
	effectdesc = "также сделает плитки скользкими рядом с атакованными плитками. Устойчив к грубым атакам."
	analyzerdescdamage = "Наносит низкий урон травмами и урон гипоксией, высокий урон выносливости и делает пол под целями очень скользкими, туша их. Устойчив к атакам травмами."
	analyzerdesceffect = "При нападении или убийстве смазывает близлежащие плитки пола, тушая все на них."
	color = "#AAAABB"
	complementary_color = "#BBBBAA"
	blobbernaut_message = "emits slime at"
	message = "Блоб плюхается в тебя"
	message_living = ", и ты задыхаешься"
	reagent = /datum/reagent/blob/pressurized_slime

/datum/blobstrain/reagent/pressurized_slime/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) || damage_type != BURN)
		extinguisharea(B, damage)
	if(damage_type == BRUTE)
		return damage * 0.5
	return ..()

/datum/blobstrain/reagent/pressurized_slime/death_reaction(obj/structure/blob/B, damage_flag)
	if(damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER)
		B.visible_message(span_boldwarning("Блоб разрывается, обрызгивая область жидкостью!"))
		extinguisharea(B, 30)

/datum/blobstrain/reagent/pressurized_slime/proc/extinguisharea(obj/structure/blob/B, probchance)
	for(var/turf/simulated/T as anything in range(1, B))
		if(!istype(T) || iswallturf(T) || ismineralturf(T))
			continue
		if(prob(probchance))
			T.MakeSlippery(TURF_WET_LUBE, min_wet_time = 5 SECONDS, wet_time_to_add = 5 SECONDS)
			for(var/obj/O in T)
				O.extinguish()
			for(var/mob/living/L in T)
				L.adjust_wet_stacks(2.5)
				L.ExtinguishMob()

/datum/reagent/blob/pressurized_slime
	name = "Сжатая слизь"
	id = "blob_pressurized_slime"
	taste_description = "грязной губки для посуды"
	color = "#AAAABB"

/datum/reagent/blob/pressurized_slime/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	var/turf/simulated/location_turf = get_turf(exposed_mob)
	if(istype(location_turf) && !(iswallturf(location_turf) || ismineralturf(location_turf)) && prob(reac_volume))
		location_turf.MakeSlippery(TURF_WET_LUBE, min_wet_time = 5 SECONDS, wet_time_to_add = 5 SECONDS)
		exposed_mob.adjust_wet_stacks(reac_volume / 10)
	exposed_mob.apply_damage(0.4*reac_volume, BRUTE, forced=TRUE)
	if(exposed_mob)
		exposed_mob.adjustStaminaLoss(reac_volume, FALSE)
		exposed_mob.apply_damage(0.4 * reac_volume, OXY)
