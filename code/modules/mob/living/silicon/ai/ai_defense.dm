/mob/living/silicon/ai/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(!SSticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return
	..()

/mob/living/silicon/ai/attack_slime(mob/living/simple_animal/slime/user)
	return //immune to slimes

/mob/living/silicon/ai/adjust_slot_machine_lose_effect()
	if (prob(EMAGGED_SLOT_MACHINE_GIB_CHANCE))
		to_chat(src, span_warningbig("Критическая неудача!<br>Неизвестная сила заставляет вас отключиться."))
		src.death() // AI gib cause no body ghost error
		return
	to_chat(src, span_warning("Неудача! [src.name] получает видимые повреждения."))
	src.adjustBruteLoss(rand(15, 20))
