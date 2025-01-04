//does massive brute and burn damage, but can only expand manually
/datum/blobstrain/reagent/networked_fibers
	name = "Сетевые волокна"
	description = "наносит большое количество урона травмами и ожогами и генерирует ресурсы быстрее, но может расширяться только с помощью перемещения ядра или узлов."
	shortdesc = "наносит сочетание урона травмами и ожогами."
	effectdesc = "перемещает ваше ядро ​​или узел при ручном расширении рядом с ним."
	analyzerdescdamage = "Наносит большое количество урона травмами и ожогами."
	analyzerdesceffect = "Мобильный и быстро генерирует ресурсы."
	color = "#4F4441"
	complementary_color = "#414C4F"
	reagent = /datum/reagent/blob/networked_fibers
	core_regen_bonus = 5

/datum/blobstrain/reagent/networked_fibers/expand_reaction(obj/structure/blob/spawning_blob, obj/structure/blob/new_blob, turf/chosen_turf, mob/camera/blob/overmind, offstation)
	if(!overmind && new_blob.overmind || offstation)
		new_blob.overmind.add_points(1)
		if(offstation)
			to_chat(usr, span_warning("Двигать ядро или узел за пределы станции нельзя."))
		qdel(new_blob)
		return FALSE

	var/list/range_contents = (is_there_multiz())? urange_multiz(1, new_blob) : range(1, new_blob)

	for(var/obj/structure/blob/possible_expander in range_contents)
		if(possible_expander.overmind == overmind && (istype(possible_expander, /obj/structure/blob/special/core) || istype(possible_expander, /obj/structure/blob/special/node)))
			new_blob.forceMove(get_turf(possible_expander))
			possible_expander.forceMove(chosen_turf)
			possible_expander.setDir(get_dir(new_blob, possible_expander))
			return TRUE
	overmind.add_points(BLOB_EXPAND_COST)
	qdel(new_blob)
	return FALSE

//does massive brute and burn damage, but can only expand manually
/datum/reagent/blob/networked_fibers
	name = "Сетевые волокна"
	id = "blob_networked_fibers"
	taste_description = "эффективность"
	color = "#4F4441"

/datum/reagent/blob/networked_fibers/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, BRUTE, forced = TRUE)
	if(!QDELETED(exposed_mob))
		exposed_mob.apply_damage(0.6*reac_volume, BURN, forced = TRUE)
