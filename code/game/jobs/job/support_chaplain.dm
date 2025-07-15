//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = JOB_TITLE_CHAPLAIN
	flag = JOB_FLAG_CHAPLAIN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = TRUE
	supervisors = "the head of personnel"
	department_head = list(JOB_TITLE_HOP)
	selection_color = "#d1e8d3"
	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Priest","Monk","Preacher","Reverend","Oracle","Nun","Imam","Exorcist")
	outfit = /datum/outfit/job/chaplain

	//God will not give you a salary roflcat
	salary = 60
	min_start_money = 10
	max_start_money = 200

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	uniform = /obj/item/clothing/under/rank/chaplain
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	pda = /obj/item/pda/chaplain
	backpack_contents = list(
		/obj/item/camera/spooky = 1,
		/obj/item/nullrod = 1
	)

/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(visualsOnly)
		return

	if(H.mind)
		H.mind.isholy = TRUE
		ADD_TRAIT(H, TRAIT_HEALS_FROM_HOLY_PYLONS, INNATE_TRAIT)

	INVOKE_ASYNC(src, PROC_REF(religion_pick), H)

/datum/outfit/job/chaplain/proc/religion_pick(mob/living/carbon/human/user)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(get_turf(user))
	B.customisable = TRUE // Only the initial bible is customisable
	user.put_in_l_hand(B)

	var/religion_name = "Христианство"
	var/book_name
	var/new_religion = tgui_input_text(usr, "Вы - Священник. Как вы хотите назвать свою веру? По умолчанию - Христианство.", "Смена названия", religion_name, user, max_length = MAX_NAME_LEN)

	if(!new_religion)
		new_religion = religion_name

	switch(lowertext(new_religion))
		if("христианство", "православие", "христьянство")
			B.name = "The Holy Bible"
			B.ru_names = list(
				NOMINATIVE = "Святая Библия",
				GENITIVE = "Святой Библии",
				DATIVE = "Святой Библии",
				ACCUSATIVE = "Святую Библию",
				INSTRUMENTAL = "Святой Библией",
				PREPOSITIONAL = "Святой Библии"
			)
		if("сатанизм")
			B.name = "The Unholy Bible"
			B.ru_names = list(
				NOMINATIVE = "Сатанинская библия",
				GENITIVE = "Сатанинской библии",
				DATIVE = "Сатанинской библии",
				ACCUSATIVE = "Сатанинскую библию",
				INSTRUMENTAL = "Сатанинской библией",
				PREPOSITIONAL = "Сатанинской библии"
			)
		if("ктулху", "культ ктулху")
			B.name = "The Necronomicon"
			B.ru_names = list(
				NOMINATIVE = "Некрономикон",
				GENITIVE = "Некрономикона",
				DATIVE = "Некрономикону",
				ACCUSATIVE = "Некрономикон",
				INSTRUMENTAL = "Некрономиконом",
				PREPOSITIONAL = "Некрономиконе"
			)
		if("ислам")
			B.name = "Quran"
			B.ru_names = list(
				NOMINATIVE = "Коран",
				GENITIVE = "Корана",
				DATIVE = "Корану",
				ACCUSATIVE = "Коран",
				INSTRUMENTAL = "Кораном",
				PREPOSITIONAL = "Коране"
			)
		if("саентология")
			book_name = pick("Биография Л. Рона Хаббарда", "Дианетика")
			B.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
			B.ru_names = list(
				NOMINATIVE = book_name,
				GENITIVE = book_name,
				DATIVE = book_name,
				ACCUSATIVE = book_name,
				INSTRUMENTAL = book_name,
				PREPOSITIONAL = book_name
			)
		if("хаос")
			B.name = "The Book of Lorgar"
			B.ru_names = list(
				NOMINATIVE = "Книга Лоргара",
				GENITIVE = "Книги Лоргара",
				DATIVE = "Книге Лоргара",
				ACCUSATIVE = "Книгу Лоргара",
				INSTRUMENTAL = "Книгой Лоргара",
				PREPOSITIONAL = "Книге Лоргара"
			)
		if("империум")
			B.name = "Uplifting Primer"
			B.ru_names = list(
				NOMINATIVE = "Воодушевляющая памятка Имперского пехотинца",
				GENITIVE = "Воодушевляющей памятки Имперского пехотинца",
				DATIVE = "Воодушевляющей памятке Имперского пехотинца",
				ACCUSATIVE = "Воодушевляющую памятку Имперского пехотинца",
				INSTRUMENTAL = "Воодушевляющей памяткой Имперского пехотинца",
				PREPOSITIONAL = "Воодушевляющей памятке Имперского пехотинца"
			)
		if("toolboxia")
			B.name = "Toolbox Manifesto Robusto"
			B.ru_names = list(
				NOMINATIVE = "Манифест Робаста",
				GENITIVE = "Манифеста Робаста",
				DATIVE = "Манифесту Робаста",
				ACCUSATIVE = "Манифест Робаста",
				INSTRUMENTAL = "Манифестом Робаста",
				PREPOSITIONAL = "Манифесте Робаста"
			)
		if("наука")
			book_name = pick("Принцип Относительности ", "Квантовая Загадка: Встреча Физики с Сознанием", "Программируя Вселенную", "Квантовая Физика и Теология", "Теория Струн для Чайников", "Оч.умелые Ручки. Варп-Двигатель и Машина Времени", "Загадки Блюспейса", "Играя в Бога: Коллекционное издание")
			B.name = pick("Principle of Relativity", "	", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
			B.ru_names = list(
				NOMINATIVE = "Книга" + "\"[book_name]\"",
				GENITIVE = "Книги" + "\"[book_name]\"",
				DATIVE = "Книге" + "\"[book_name]\"",
				ACCUSATIVE = "Книгу" + "\"[book_name]\"",
				INSTRUMENTAL = "Книгой" + "\"[book_name]\"",
				PREPOSITIONAL = "Книга" + "\"[book_name]\"",
			)
		else
			B.name = "The Holy Book of \"[new_religion]\""
			B.ru_names = list(
				NOMINATIVE = "Священная книга религии \"[new_religion]\"",
				GENITIVE = "Священной книги религии \"[new_religion]\"",
				DATIVE = "Священной книге религии \"[new_religion]\"",
				ACCUSATIVE = "Священную книгу религии \"[new_religion]\"",
				INSTRUMENTAL = "Священной книгой религии \"[new_religion]\"",
				PREPOSITIONAL = "Священной книге религии \"[new_religion]\""
			)
	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)

	var/deity_name = "Иисус Космос"
	var/new_deity = tgui_input_text(usr, "Кому вы поклоняетесь? По умолчанию - Иисус, Космо-Христос.", "", deity_name, user, max_length = MAX_NAME_LEN)

	if(!length(new_deity) || (new_deity == "Иисус, Космо-Христос"))
		new_deity = deity_name
	B.deity_name = new_deity
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

	user.AddSpell(new /obj/effect/proc_holder/spell/chaplain_bless(null))

	if(SSticker)
		SSticker.Bible_deity_name = B.deity_name
