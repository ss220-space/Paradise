//Техника агрессивного маркетинга мистера Ченга
/datum/martial_art/mr_chang
	name = "Агрессивный маркетинг мистера Чанга"
	weight = 6
	combos = list(/datum/martial_combo/mr_chang/steal_card, /datum/martial_combo/mr_chang/stunning_discounts)
	has_explaination_verb = TRUE

/datum/martial_art/mr_chang/explaination_header(user)
	to_chat(user, "<b><i>\nПринимая позу лотоса, вы начинаете медитацию. Знания Мистера Чанга наполнаяют ваш разум.</i></b>")

/datum/martial_art/mr_chang/explaination_footer(user)
	to_chat(user, "<span class='notice'>Business lunch</span>: Глутамат натрия теперь восстанавливает 0,75 ожогового/физического урона. (Содержится в малом количестве в еде Mr. Chang)")
	to_chat(user, "<span class='notice'>TAKEYOMONEY</span>: Пачка купюр при броске наносит урон, пропорциональный толщине пачки.")
	to_chat(user, "<span class='notice'>Change please!</span>: Монеты при броске имеют шанс в 30% застрять в теле жертвы, нанося малый периодический урон")

/datum/martial_art/mr_chang/explaination_notice(user)
	to_chat(user, "<b><i>Шаги комбо могут быть произведены только пустой активной рукой!</i></b>")
