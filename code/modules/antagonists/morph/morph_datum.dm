/datum/antagonist/morph
	name = "Morph"
	roundend_category = "Морфами"
	roundend_blackbox_key = "morph"
	job_rank = ROLE_MORPH
	special_role = SPECIAL_ROLE_MORPH
	antag_menu_name = "Морф"
	wiki_page_name = "Morph"
	russian_wiki_name = "Морф"
	stinger_sound = 'sound/magic/mutate.ogg'

/datum/antagonist/morph/give_objectives()
	add_objective(/datum/objective/morph_eat)
	add_objective(/datum/objective/morph_procreate)

/datum/antagonist/morph/greet()
	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("<b>Вы — морф.<br></b>")))
	messages.Add(span_sinister("Вы жаждете съесть живых существ и желаете размножаться. Достигните этой цели, устраивая засады на ничего не подозревающую добычу, используя свои способности."))
	messages.Add(span_specialnotice("Будучи мерзостью, созданным в основном из клеток генокрада, вы можете принимать форму любого объекта поблизости, используя свою способность \"Мимикрия\""))
	messages.Add(span_specialnotice("Преобразование не останется незамеченным для наблюдателей."))
	messages.Add(span_specialnotice("В изменённой форме вы двигаетесь медленнее и наносите меньше урона."))
	messages.Add(span_specialnotice("Кроме того, любой, кто находится в радиусе трёх тайлов, заметит нечто странное, если осмотрит вас."))
	messages.Add(span_specialnotice("В этой форме вы можете \"Подготовить засаду\", используя свою способность."))
	messages.Add(span_specialnotice("Это позволит вам нанести огромный урон при первом ударе."))
	messages.Add(span_specialnotice("Если они коснутся вас, то ещё больше."))
	messages.Add(span_specialnotice("Наконец, вы можете атаковать любой предмет или мёртвое существо, чтобы поглотить его — это 1/3 вашего максимального здоровья и добавят к вашему запасу пищи."))
	messages.Add(span_specialnotice("Поедание предметов уменьшит ваш запас пищи.\n"))
	return messages


/datum/antagonist/morph/wizard
	name = "Awakened Morph"
	antag_menu_name = "Пробуждённый морф"
	var/datum/mind/summoner
	var/objective_verb = "Eat"

/datum/antagonist/morph/wizard/Destroy(force)
	summoner = null
	return ..()

/datum/antagonist/morph/wizard/give_objectives()
	add_objective(/datum/objective/assassinate, "[objective_verb] [summoner.current.real_name], the one who was foolish enough to awake you.", summoner)
	add_objective(/datum/objective/morph_eat, "[objective_verb] everyone and everything else while you're at it.")


/datum/objective/morph_eat
	explanation_text = "Съешьте как можно больше живых существ, чтобы утолить голод внутри вас."
	completed = TRUE
	needs_target = FALSE
	antag_menu_name = "Съесть живых существ"

/datum/objective/morph_procreate
	explanation_text = "Породите как можно больше себе подобных!"
	completed = TRUE
	needs_target = FALSE
	antag_menu_name = "Размножиться"
