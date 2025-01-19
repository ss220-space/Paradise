//does brute, burn, and toxin damage, and cools targets down
/datum/blobstrain/reagent/cryogenic_poison
	name = "Криогенный яд"
	description = "впрыскивает в цель замораживающий яд, нанося небольшой урон от удара, но нанося большой урон с течением времени."
	analyzerdescdamage = "Вводит в цель замораживающий яд, который постепенно затвердевает внутренние органы цели."
	color = "#8BA6E9"
	complementary_color = "#7D6EB4"
	blobbernaut_message = "injects"
	message = "Блоб ранит вас"
	message_living = ", и вы чувствуете, что ваши внутренности твердеют"
	reagent = /datum/reagent/blob/cryogenic_poison

/datum/reagent/blob/cryogenic_poison
	name = "Криогенный яд"
	id = "blob_cryogenic_poison"
	description = "впрыскивает в цель замораживающий яд, который со временем наносит большой урон."
	color = "#8BA6E9"
	taste_description = "заморозка мозга"

/datum/reagent/blob/cryogenic_poison/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/frostoil, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/consumable/drink/cold/ice, 0.3*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/cryogenic_poison, 0.3*reac_volume)
	exposed_mob.apply_damage(0.2*reac_volume, BRUTE, forced=TRUE)

/datum/reagent/blob/cryogenic_poison/on_mob_life(mob/living/carbon/exposed_mob, seconds_per_tick, times_fired)
	. = ..()
	var/need_mob_update
	need_mob_update = exposed_mob.adjustBruteLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += exposed_mob.adjustFireLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	need_mob_update += exposed_mob.adjustToxLoss(0.5 * REM * seconds_per_tick, updating_health = FALSE)
	if(need_mob_update)
		. = STATUS_UPDATE_HEALTH
