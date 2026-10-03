//sets you on fire, does burn damage, explodes into flame when burnt, weak to water
/datum/blobstrain/reagent/blazing_oil
	name = "Пылающее масло"
	description = "наносит высокий урон от ожогов и подожигает цели."
	effectdesc = "при горении также выпускает вспышки пламени, игнорирует урон от горения, но получает урон от воды."
	analyzerdescdamage = "Наносит высокий урон от ожогов и поджигает цели."
	analyzerdesceffect = "При попадании выпускает вспышки пламени, игнорирует урон от горения, но получает урон от воды и других огнетушащих жидкостей."
	color = "#B68D00"
	complementary_color = "#BE5532"
	blobbernaut_message = "splashes"
	message = "Блоб обрызгивает вас горящим маслом"
	message_living = ", и вы чувствуете, как ваша кожа обугливается и плавится"
	reagent = /datum/reagent/blob/blazing_oil
	fire_based = TRUE

/datum/blobstrain/reagent/blazing_oil/extinguish_reaction(obj/structure/blob/B)
	B.take_damage(4.5, BURN, ENERGY)

/datum/blobstrain/reagent/blazing_oil/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if(damage_type == BURN && damage_flag != ENERGY)
		for(var/turf/simulated/T in range(1, B))
			if(iswallturf(T) || ismineralturf(T))
				continue
			var/obj/structure/blob/C = locate() in T
			if(!(C?.overmind && C.overmind.blobstrain.type == B.overmind.blobstrain.type) && prob(80))
				var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(T)
				hotspot.temperature = 1000
				hotspot.recolor()
	if(damage_flag == FIRE)
		return FALSE
	return ..()
