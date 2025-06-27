
//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/blobstrain/reagent/radioactive_gel
	name = "Радиоактивный гель"
	description = "наносит средний урон токсинами и небольшой урон травмами, но облучает тех, кого задевает."
	effectdesc = "при получении урона облучает окружающих."
	analyzerdescdamage = "Наносит средний урон токсинами и небольшой урон травмами, но облучает тех, кого задевает."
	analyzerdesceffect = "При получении урона облучает окружающих."
	color = "#2476f0"
	complementary_color = "#24f0f0"
	blobbernaut_message = "splashes"
	message_living = ", и вы чувствуете странное тепло изнутри"
	reagent = /datum/reagent/blob/radioactive_gel


/datum/blobstrain/reagent/radioactive_gel/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == ENERGY || damage_flag == LASER) && prob(40))
		for(var/mob/living/l in range(5, B))
			l.apply_effect(damage, IRRADIATE)
	return ..()

/datum/reagent/blob/radioactive_gel
	name = "Рadioactive_gel"
	id = "blob_radioactive_gel"
	taste_description = "радиации"
	color = "#2476f0"

/datum/reagent/blob/radioactive_gel/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.3 * reac_volume, TOX)
	exposed_mob.apply_damage(0.2 * reac_volume, BRUTE) // lets not have IPC / plasmaman only take 7.5 damage from this
	if(exposed_mob.reagents)
		exposed_mob.reagents.add_reagent("uranium", 0.35 * reac_volume)
