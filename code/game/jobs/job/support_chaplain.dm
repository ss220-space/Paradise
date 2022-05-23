//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = JOB_CHAPLAIN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = TRUE
	supervisors = "главой персонала"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)

	outfit = /datum/outfit/job/chaplain

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

	INVOKE_ASYNC(src, .proc/religion_pick, H)

/datum/outfit/job/chaplain/proc/religion_pick(mob/living/carbon/human/user)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(get_turf(user))
	B.customisable = TRUE // Only the initial bible is customisable
	user.put_in_l_hand(B)

	var/deity_name = "Космический Иисус"
	var/religion_name = "Христианство"
	var/new_religion = copytext_char(clean_input("Вы — священник. Как называется ваша вера? Название по-умолчанию: «Христианство».", "Название веры", religion_name, user), 1, MAX_NAME_LEN)

	if(!new_religion)
		new_religion = religion_name

	switch(lowertext(new_religion))
		if("христианство")
			B.name = "Святая Библия"
			B.gender = FEMALE
			deity_name = "Космический Иисус"
		if("сатанизм")
			B.name = "Нечистая Библия"
			B.gender = FEMALE
			deity_name = "Космический Сатана"
		if("ктулху")
			B.name = "Некрономикон"
			B.gender = MALE
			deity_name = "Великий Ктулху"
		if("ислам")
			B.name = "Коран"
			B.gender = MALE
			deity_name = "Аллах"
		if("сайентология")
			B.name = pick("Биография Рона Хаббарда", "Дианетика")
			B.gender = FEMALE
			deity_name = "Рон Хаббард"
		if("хаос")
			B.name = "Книга Лоргара"
			B.gender = FEMALE
			deity_name = "Тёмные боги"
		if("империум" || "империй" || "империя")
			B.name = "Молитвенник имперского гвардейца"
			B.gender = MALE
			deity_name = "Император"
		if("тулбоксия")
			B.name = "Тулбоксовый манифест робаста"
			B.gender = MALE
			deity_name = "Робаст"
		if("наука")
			switch(pick(50;PLURAL, 50;FEMALE))
				if(PLURAL)
					B.name = pick("Принципы относительности", "Очумелые ручки: Построй собственный варп-двигатель", "Тайны Блюспейса", "Игра в бога: коллекционное издание")
					B.gender = PLURAL
				if(FEMALE)
					B.name = pick("Квантовая загадка: Физика против Сознания", "Квантовая физика и теология", "Теория струн для чайников")
					B.gender = FEMALE
				else
					B.name = "Программирование Вселенной"
			deity_name = "Разум"
		else
			B.name = "Святое писание: [new_religion]"
			B.gender = NEUTER
	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)

	var/new_deity = copytext_char(clean_input("Кому или чему вы поклоняетесь? По-умолчанию это Космический Иисус.", "Объект поклонения", deity_name, user), 1, MAX_NAME_LEN)

	if(!length(new_deity) || (new_deity == "Космический Иисус"))
		new_deity = deity_name
	B.deity_name = new_deity
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

	user.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/chaplain_bless(null))

	if(SSticker)
		SSticker.Bible_deity_name = B.deity_name
