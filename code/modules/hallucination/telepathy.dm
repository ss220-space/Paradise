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
		return "ERP запрещено"

	var/memo = pick(
		pick("%TARGETNAME% не доверяй никому.", "Они следят за тобой.", "Беги, пока можешь.", "%TARGETNAME%, ты не один.", "Оно уже здесь."),
		pick("Убей их всех.", "Они хотят твоей смерти.", "Не дай им добраться до тебя.", "Они лгут тебе."),
		pick("Как дела?", "Ты слышал это?", "Что происходит?", "Ты в порядке?", "Где ты?"),
		pick("Ты слышал это?", "Что это было?", "Ты слышал шум?", "Кто-то идёт."),
		pick("Сомневаюсь в этом.", "Не верю им.", "Это ловушка.", "Они обманывают тебя."),
		pick("Беги!", "Уходи отсюда!", "Спасайся!", "Не останавливайся!"),
		pick("Убирайся!", "Проваливай!", "%TARGETNAME% не подходи!", "Оставь меня в покое!"),
		pick("Привет.", "Здравствуй.", "Рад тебя видеть.", "Давно не виделись."),
		pick("Я слежу за тобой, %TARGETNAME%.", "Ты мне не нравишься.", "Что ты задумал?", "Я знаю, что ты сделал, %TARGETNAME%."),
		pick("Твоё сердце бьётся слишком быстро. Я могу его остановить.", "Дай мне порулить.", "Ты ведь не собираешься это есть?", "Мы видим всё, что видишь ты."),
		pick("Почему ты не принял таблетку?"),
		pick("Я в твоих венах.", "Кровь такая тёплая...", "Мы почти дома.", "Оно уже отложило яйца."),
		pick("Не моргай.", "Твои глаза чешутся изнутри.", "Посмотри на свои руки. Это точно твои руки?", "Они идут по вентиляции."),
		pick("Прости.", "Это было необходимо.", "Ты сам этого хотел.", "Мы все умрём здесь."),
		pick("Посмотри в зеркало. Кто там?", "Они уже за дверью.", "Беги в космос, там безопасно."),
	)
	var/names = pick(
		hallucinator.real_name,
		hallucinator.name,
	)

	return replacetext(memo, "%TARGETNAME%", names)
