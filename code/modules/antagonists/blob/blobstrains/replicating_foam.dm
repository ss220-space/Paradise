/datum/blobstrain/reagent/replicating_foam
	name = "Репликационная пена"
	description = "наносит средний урон травмами и иногда дополнительно расширяется при расширении."
	shortdesc = "наносит средний урон травмами."
	effectdesc = "также будет расширяться при атаке ожогами, но получает больше урона травмами."
	color = "#7B5A57"
	complementary_color = "#57787B"
	analyzerdescdamage = "Наносит средний урон травмами."
	analyzerdesceffect = "Расширяется при атаке ожогами, иногда дополнительно расширяется при расширении и уязвим к урону травмами."
	reagent = /datum/reagent/blob/replicating_foam


/datum/blobstrain/reagent/replicating_foam/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BRUTE)
		damage = damage * 2
	else if(damage_type == BURN && damage > 0 && B.get_integrity() - damage > 0 && prob(50))
		if(damage_flag == FIRE)
			return ..()
		var/obj/structure/blob/newB = B.expand(null, null, 0)
		if(newB)
			newB.update_integrity(B.get_integrity() - damage)
			newB.update_blob()
	return ..()


/datum/blobstrain/reagent/replicating_foam/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/camera/blob/O)
	if(prob(30))
		newB.expand(null, null, 0) //do it again!
	return TRUE

/datum/reagent/blob/replicating_foam
	name = "Репликационная пена"
	id = "blob_replicating_foam"
	taste_description = "дублирования"
	color = "#7B5A57"

/datum/reagent/blob/replicating_foam/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.7*reac_volume, BRUTE, forced = TRUE)
