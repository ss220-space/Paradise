//does toxin damage, hallucination, targets think they're not hurt at all
/datum/blobstrain/reagent/regenerative_materia
	name = "Регенеративная Материя"
	description = "наносит средний начальный урон токсинами, впрыскивая яд, который наносит больший урон токсинами и заставляет цели верить, что они полностью здоровы. Ядро восстанавливается гораздо быстрее."
	analyzerdescdamage = "Наносит средний начальный урон токсинами, вводя яд, который наносит больший урон токсинами и заставляет цели верить, что они полностью здоровы. Ядро восстанавливается гораздо быстрее."
	color = "#A88FB7"
	complementary_color = "#AF7B8D"
	message_living = ", и вы чувствуешь себя <i>живым</i>"
	reagent = /datum/reagent/blob/regenerative_materia
	core_regen_bonus = 18
	point_rate_bonus = 2

/datum/reagent/blob/regenerative_materia
	name = "Регенеративная Материя"
	id = "blob_regenerative_materia"
	taste_description = "небес"
	color = "#A88FB7"

/datum/reagent/blob/regenerative_materia/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	if(iscarbon(exposed_mob))
		exposed_mob.Druggy(reac_volume * 2 SECONDS)
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent(/datum/reagent/blob/regenerative_materia, 0.2*reac_volume)
		exposed_mob.reagents.add_reagent(/datum/reagent/toxin/spore, 0.2*reac_volume)
	exposed_mob.apply_damage(0.7*reac_volume, TOX)

/datum/reagent/blob/regenerative_materia/on_mob_life(mob/living/affected_mob)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= affected_mob.adjustToxLoss(1 * REM, updating_health = FALSE)
	return ..() | update_flags

/datum/reagent/blob/regenerative_materia/on_mob_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.apply_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)

/datum/reagent/blob/regenerative_materia/on_mob_end_metabolize(mob/living/metabolizer)
	. = ..()
	metabolizer.remove_status_effect(/datum/status_effect/grouped/screwy_hud/fake_healthy, type)
