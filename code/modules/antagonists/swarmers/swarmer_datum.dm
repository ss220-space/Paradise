/datum/antagonist/swarmer
	name = "Swarmer"
	roundend_category = "swarmers"
	job_rank = ROLE_SWARMER
	special_role = SPECIAL_ROLE_SWARMER
	wiki_page_name = "Swarmer"
	russian_wiki_name = "Свармер"
	show_in_roundend = FALSE
	show_in_orbit = FALSE
	antag_menu_name = "Свармер"
	/// Text we send on greet to tell about current class. Created on gain.
	var/swarmer_class_info = "Если ты это видишь, это баг."
	/// Sound file played on greet
	var/greet_sound = 'sound/swarmer/swarmer_intro.ogg'

/datum/antagonist/swarmer/on_gain()
	if(!isswarmer(owner.current))
		stack_trace("This antag datum cannot be attached to a mob of this type.")
	var/mob/living/simple_animal/hostile/swarmer/swarmer = owner.current
	swarmer_class_info = span_bold("Ваш класс: [initial(swarmer.name)]!") + "\n" + swarmer.swarmer_class_info
	. = ..()

/datum/antagonist/swarmer/roundend_report_header()
	return

/datum/antagonist/swarmer/greet()
	var/list/messages = list()
	messages.Add(span_danger("Вы — Свармер!\n"))
	messages.Add(span_bold("Цели роя:"))
	messages.Add("1. Обеспечивать безопасность роя и потреблять ресурсы, пока они не иссякнут.")
	messages.Add("2. Сохранять местность пригодной для последующего вторжения; избегать действий, делающих её опасной или необитаемой.")
	messages.Add("3. Биологические ресурсы будут полезнее будучи живыми, старайтесь не причинять им вред, по мере возможности.\n")
	messages.Add(span_bold("Информация по интентам"))
	messages.Add("1. Интент \"Помощь\", или же \"первый\", используется для взаимодействия с объектами \"Свармеров\".")
	messages.Add("2. Интент \"Ремонт\", или же \"второй\", для починки других \"Свармеров\" и объектов. Чинить самого себя нельзя.")
	messages.Add("3. Интент \"Строительство\", или же \"третий\", используется классом \"Строитель\" для откручивания и прикручивания структур свармеров.")
	messages.Add("4. Интент \"Разбор\", или же \"четвёртый\", используется для разбора структур \"Свармеров\".\n")
	messages.Add(span_bold("Полезная информация"))
	messages.Add("Все ваши выстрелы и атаки, включая от построек, накладывают на цель блокировку лечения стамины.")
	messages.Add("Все ваши выстрелы, включая от турелей, пролетают насквозь всех структур \"Свармеров\", кроме турелей.")
	messages.Add("Вы можете телепортировать в обработчики семена, овощи, реагенты и растения с лотков, добывая с них органические ресурсы.")
	messages.Add("Используя ПКМ на цели, вы сможете начать процесс телепортации существ, а также конвертации киборгов.\n")
	messages.Add("[swarmer_class_info]\n")
	SEND_SOUND(owner.current, sound(greet_sound))
	return messages

/datum/antagonist/swarmer/mega
	greet_sound = 'sound/swarmer/megaswarmer_intro.ogg'
