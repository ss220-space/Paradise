/// Fake telepathy - a voice in the head.
/datum/hallucination/telepathy
	random_hallucination_weight = 4
	hallucination_tier = HALLUCINATION_TIER_COMMON

/datum/hallucination/telepathy/start()
	hallucinator.balloon_alert(hallucinator, "вы слышите голос")
	to_chat(hallucinator, span_mind_control("Вы слышите голос в голове..."))
	to_chat(hallucinator, span_abductor(get_telepath_message()))
	return TRUE

/datum/hallucination/telepathy/proc/get_telepath_message()
	if(prob(0.001))
		return "лошадь"

	var/memo = pick(
		pick("Не доверяй никому.", "Они следят за тобой.", "Беги, пока можешь.", "Ты не один.", "Оно уже здесь."),
		pick("Убей их всех.", "Они хотят твоей смерти.", "Не дай им добраться до тебя.", "Они лгут тебе."),
		pick("Как дела?", "Ты слышал это?", "Что происходит?", "Ты в порядке?", "Где ты?"),
		pick("Ты слышал это?", "Что это было?", "Ты слышал шум?", "Кто-то идёт."),
		pick("Сомневаюсь в этом.", "Не верю им.", "Это ловушка.", "Они обманывают тебя."),
		pick("Беги!", "Уходи отсюда!", "Спасайся!", "Не останавливайся!"),
		pick("Убирайся!", "Проваливай!", "Не подходи!", "Оставь меня в покое!"),
		pick("Привет.", "Здравствуй.", "Рад тебя видеть.", "Давно не виделись."),
		pick("Я слежу за тобой.", "Ты мне не нравишься.", "Что ты задумал?", "Я знаю, что ты сделал."),
	)
	var/names = pick(
		hallucinator.real_name,
		hallucinator.name,
	)

	return replacetext(memo, "%TARGETNAME%", names)
