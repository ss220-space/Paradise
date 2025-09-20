// Given to heretic monsters.
/obj/effect/proc_holder/spell/shapeshift/eldritch
	name = "Метаморфоза" // 177013 :)
	desc = "Заклинание, позволяющее вам принять облик другого существа, приобретая его способности. \
			Сделав выбор, вы больше не сможете принимать другую форму."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"

	school = SCHOOL_FORBIDDEN
	invocation = "М'Т'М'РФ'З"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	possible_shapes = list(
		/mob/living/simple_animal/hostile/carp,
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/fox,
		/mob/living/simple_animal/bot/secbot,
	)
