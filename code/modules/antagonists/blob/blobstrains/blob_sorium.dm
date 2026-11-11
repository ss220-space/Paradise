//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/blobstrain/reagent/b_sorium
	name = "Сорий"
	description = "наносит высокий урон травмами и отбрасывает людей в стороны."
	effectdesc = "при попадании создает сориумный взрыв."
	analyzerdescdamage = "Наносит высокий урон травмами и отбрасывает людей в стороны."
	analyzerdesceffect = "При попадании создает сориумный взрыв."
	color = "#808000"
	complementary_color = "#a2a256"
	blobbernaut_message = "splashes"
	message = "Блоб врезается в вас и отбрасывает в сторону"
	reagent = /datum/reagent/blob/b_sorium

/datum/blobstrain/reagent/b_sorium/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(prob(damage))
		reagent_vortex(B, TRUE, damage * 0.7)
	return ..()
