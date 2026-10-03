/datum/action/cooldown/spell/shapeshift/animal_form
	name = "Shapechange"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	cooldown_time = 20 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS
	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	var/chosen = FALSE
	possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/construct/armoured,
	)
