
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
		for(var/turf/simulated/T as anything in range(1, B))
			if(iswallturf(T) || ismineralturf(T))
				continue
			var/obj/structure/blob/C = locate() in T
			if(!(C && C.overmind && C.overmind.blobstrain.type == B.overmind.blobstrain.type) && prob(80))
				new /obj/effect/hotspot(T)
	if(damage_flag == FIRE)
		return FALSE
	return ..()

/datum/reagent/blob/blazing_oil
	name = "Пылающее масло"
	id = "blob_blazing_oil"
	taste_description = "горящее масло"
	color = "#B68D00"

/datum/reagent/blob/blazing_oil/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.adjust_fire_stacks(round(reac_volume/10))
	exposed_mob.IgniteMob()
	if(exposed_mob)
		exposed_mob.apply_damage(0.8*reac_volume, BURN, forced=TRUE)
	if(iscarbon(exposed_mob))
		exposed_mob.emote("scream")
