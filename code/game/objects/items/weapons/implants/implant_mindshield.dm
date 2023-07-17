/obj/item/implant/mindshield
	name = "Insights implant"
	desc = "Не позволяет людям запутывать ваш разум и обернуть против Утопии."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = 0

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Utopia Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device can better resist mental compulsions.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/implant/mindshield/implant(mob/target)
    var implanted = ..()  // Проверяем, успешно ли введен имплант

    if (implanted == 1)
        if (is_shadow_or_thrall(target))
            target.visible_message("<span class='warning'>[target] кажется, сопротивляется импланту!</span>", "<span class='warning'>Вы чувствуете, как утопийские идеи пытаются заполонить ваш разум!</span>")
            removed(target, 1)
            qdel(src)
            return -1

        if ((target.mind in SSticker.mode?.cult) || (target.mind in SSticker.mode?.head_revolutionaries))
            to_chat(target, "<span class='warning'>Вы чувствуете, как утопийские идеи пытаются заполонить ваш разум!</span>")
        else if (target.mind in SSticker.mode?.revolutionaries)
            SSticker.mode.remove_revolutionary(target.mind)
        else
            to_chat(target, "<span class='notice'>Ваш разум кажется закаленным - более устойчивым к промыванию мозгов ложными идеями. И теперь вы искренно верите в идеи Утопии.</span>")

        spawn
            random_messages(target)  // Запускаем процесс случайных фраз в отдельном потоке

        return 1
    return 0

// Добавляем процедуру для вывода случайных фраз
proc/random_messages(mob/target)
    var phrases = list("<span class='warning'>Ты ощущаешь, как тебя переполняет желание умереть во время защиты Утопии.</span>", "<span class='warning'>Тебя одолевают размышления - как ты раньше не осозновал, что Утопия - это твой истинный и единственный родной дом, а дом надо беречь и защищать.</span>", "<span class='warning'>Станция 'Утопия' - гордость и величие вселенной. Мы соткали нити мира и процветания, чтобы каждый обрел свою роль в этом великом космическом театре.</span>", "<span class='warning'>На 'Утопии' мы отвергаем прошлое и стремимся к будущему, где никто не испытывает нужды. Примите вызов революции и окунитесь в море идей.</span>", "<span class='warning'>Сияющая звезда 'Утопия' взывает к вам! Примите вызов и погрузитесь в мир бесконечных возможностей и счастливого сотрудничества!</span>")

    while (1)  // Бесконечный цикл
        var phrase = phrases[rand(1, length(phrases))]  // Выбираем случайную фразу из списка
        to_chat(target, phrase)  // Выводим фразу игроку
        sleep(15 * 60)  // Ждем 15 минут

/obj/item/implant/mindshield/removed(mob/target, var/silent = 0)
	if(..())
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Вы ощущаете чувство освобождения, когда хватка импланта озарения ослабевает.</span>")
		return 1
	return 0


/obj/item/implanter/mindshield
	name = "implanter (insights)"

/obj/item/implanter/mindshield/New()
	imp = new /obj/item/implant/mindshield(src)
	..()
	update_icon()


/obj/item/implantcase/mindshield
	name = "implant case - 'insights'"
	desc = "Стеклянный кейс содержащий имплант озарения."

/obj/item/implantcase/mindshield/New()
	imp = new /obj/item/implant/mindshield(src)
	..()

/obj/item/implant/mindshield/ert
	name = "ERT mindshield implant"
	desc = "Защищает ваш разум и предоставляет доступ к продвинутому боевому оборудованию НТ"

/obj/item/implanter/mindshield/ert
	name = "implanter (ERT mindshield)"

/obj/item/implanter/mindshield/ert/New()
	imp = new /obj/item/implant/mindshield/ert(src)
	..()
	update_icon()

/obj/item/implantcase/mindshield/ert/New()
	imp = new /obj/item/implant/mindshield/ert(src)
	..()