/obj/effect/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	return SWARMER_ACT_IMPOSSIBLE

/obj/effect/mob_spawn/swarmer/swarmer_act(mob/living/simple_animal/hostile/swarmer/user)
	if(tgui_alert(user, "Вы точно хотите разобрать оболочку Свармера?", "Разбор оболочки", list("Да", "Нет")) == "Нет")
		return SWARMER_ACT_IMPOSSIBLE
	return SWARMER_ACT_POSSIBLE | SWARMER_ACT_POSSIBLE_ACTION_CONSUME

/obj/effect/mob_spawn/swarmer/integrate_amount()
	return SWARMER_SPAWN_VALUE
