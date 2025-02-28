#define SCREEN_COVER 0
#define SCREEN_PAGE_INNER 1
#define SCREEN_PAGE_LAST 2

/**
  * # Newspaper
  *
  * A newspaper displaying the stories of all channels contained within.
  */
/obj/item/newspaper
	name = "newspaper"
	ru_names = list(
        NOMINATIVE = "газета",
        GENITIVE = "газеты",
        DATIVE = "газете",
        ACCUSATIVE = "газету",
        INSTRUMENTAL = "газетой",
        PREPOSITIONAL = "газете"
	)
	desc = "Выпуск \"Грифона\" — газеты, распространяемой на космических станциях НаноТрейзен."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "newspaper"
	item_state = "newspaper"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("стукнул")
	drop_sound = 'sound/items/handling/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/paper_pickup.ogg'
	/// The current screen to display.
	var/screen = 0
	/// The number of pages.
	var/pages = 0
	/// The currently selected page.
	var/curr_page = 0
	/// The channels to display as content.
	var/list/datum/feed_channel/news_content
	/// The security notice to display optionally.
	var/datum/feed_message/important_message = null
	/// The contents of a scribble made through pen, if any.
	var/scribble = ""
	/// The page of said scribble.
	var/scribble_page = null
	/// Whether the newspaper is rolled or not, making it a deadly weapon.
	var/rolled = FALSE

/obj/item/newspaper/Initialize(mapload)
	. = ..()
	if(!news_content)
		news_content = list()

/obj/item/newspaper/examine(mob/user)
	. = ..()
	if(rolled)
		. += span_notice("Вы должны развернуть её, если хотите прочитать.")
	else
		if(user.is_literate())
			if(in_range(user, src) || istype(user, /mob/dead/observer))
				attack_self(user)
			else
				. += span_notice("Вам нужно подойти поближе, если вы хотите это прочитать.")
		else
			. += span_notice("Вы не умеете читать.")

/obj/item/newspaper/attack_self(mob/user)
	if(rolled)
		balloon_alert(user, "сначала разверните!")
		return
	if(user.is_literate())
		var/dat = {"<!DOCTYPE html><meta charset='UTF-8'>"}
		dat += "<style>"
		dat += "body { font-family: Arial, sans-serif; background-color: #f4f4f4; color: #333; margin: 0; padding: 20px; }"
		dat += ".newspaper { max-width: 800px; margin: 0 auto; background-color: #fff; padding: 20px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }"
		dat += ".newspaper-title { font-size: 2.5em; text-align: center; margin-bottom: 10px; }"
		dat += ".newspaper-subtitle { font-size: 0.8em; text-align: center; color: #666; margin-bottom: 20px; }"
		dat += ".entry { margin-bottom: 20px; border-bottom: 1px solid #ddd; padding-bottom: 20px; }"
		dat += ".entry:last-child { border-bottom: none; }"
		dat += ".entry-title { font-size: 1.5em; margin-bottom: 10px; }"
		dat += ".entry-text { font-size: 1em; line-height: 1.6; margin-bottom: 10px; }"
		dat += ".entry-image { max-width: 100%; height: auto; display: block; margin-bottom: 10px; }"
		dat += ".content-list { list-style-type: none; padding: 0; }"
		dat += ".content-list li { margin-bottom: 10px; font-size: 1.1em; }"
		dat += ".content-list li .page-number { color: #777; font-size: 0.9em; }"
		dat += ".navigation { text-align: center; margin-top: 20px; }"
		dat += ".navigation button { padding: 10px 20px; font-size: 1em; cursor: pointer; border: none; background-color: #333; color: #fff; margin: 0 5px; }"
		dat += ".navigation button:hover { background-color: #555; }"
		dat += ".censored { color: red; font-weight: bold; }"
		dat += ".scribble { font-style: italic; color: #888; }"
		dat += "</style>"
		dat += "<div class='newspaper'>"

		pages = 0
		switch(screen)
			if(SCREEN_COVER) // Cover
				dat += "<div class='newspaper-title'>Грифон</div>"
				dat += "<div class='newspaper-subtitle'>Газета, предназначенная для использования на космических объектах НаноТрейзен</div><hr>"
				if(!length(news_content))
					if(important_message)
						dat += "<ul class='content-list'>"
						dat += "<li><b>**Срочное сообщение от службы безопасности**</b> <span class='page-number'>\[Страница [pages+2]\]</span></li>"
						dat += "</ul>"
					else
						dat += "<i>Кроме заголовка, остальная часть газеты, ничего не распечатано...</i>"
				else
					dat += "<b>Содержание:</b><br>"
					dat += "<ul class='content-list'>"
					for(var/datum/feed_channel/NP in news_content)
						pages++
					if(important_message)
						dat += "<li><b>**Срочное сообщение от службы безопасности**</b> <span class='page-number'>\[Страница [pages+2]\]</span></li>"
					var/temp_page=0
					for(var/datum/feed_channel/NP in news_content)
						temp_page++
						dat += "<li><b>[NP.channel_name]</b> <span class='page-number'>\[Страница [temp_page+1]\]</span></li>"
					dat += "</ul>"
				if(scribble_page==curr_page)
					dat += "<br><i>В конце страницы есть небольшая пометка... Там написано: \"[scribble]\"</i>"
				dat += "<div class='navigation'><div style='float:right;'><a href='byond://?src=[UID()];next_page=1'>Далее</a></div> <div style='float:left;'><a href='byond://?src=[user.UID()];mach_close=newspaper_main'>Закрыть</a></div></div>"

			if(SCREEN_PAGE_INNER) // Inner pages
				for(var/datum/feed_channel/NP in news_content)
					pages++
				var/datum/feed_channel/C = news_content[curr_page]
				dat += "<div class='entry'>"
				dat += "<div class='entry-title'>[C.channel_name]</div>"
				dat += "<div class='entry-text'>Автор: <font color='maroon'>[C.author]</font></div><br>"
				if(C.censored)
					dat += "<div class='censored'>Этот канал был признан опасным для общего благополучия станции, поэтому был перенесён в категорию <b>Б</b>. Его содержимое не было передано в газету на момент печати.</div>"
				else
					if(!length(C.messages))
						dat += "<div class='entry-text'>Никакие записи не связаны с этим каналом...</div>"
					else
						var/i = 0
						for(var/datum/feed_message/MESSAGE in C.messages)
							var/title = (MESSAGE.censor_flags & CENSOR_STORY) ? "\[REDACTED\]" : MESSAGE.title
							var/body = (MESSAGE.censor_flags & CENSOR_STORY) ? "\[REDACTED\]" : MESSAGE.body
							i++
							dat += "<div class='entry-text'><b>[title]</b><br>[body]</div>"
							if(MESSAGE.img)
								user << browse_rsc(MESSAGE.img, "tmp_photo[i].png")
								dat += "<img class='entry-image' src='tmp_photo[i].png' width='180'><br>"
							dat += "<div class='entry-text'>Автор: <font color='maroon'>[MESSAGE.author]</font></div><br>"
				if(scribble_page==curr_page)
					dat += "<div class='scribble'><i>В конце страницы есть небольшая пометка... Там написано: \"[scribble]\"</i></div>"
				dat += "</div>"
				dat += "<div class='navigation'><div style='float:left;'><a href='byond://?src=[UID()];prev_page=1'>Назад</a></div> <div style='float:right;'><a href='byond://?src=[UID()];next_page=1'>Далее</a></div></div>"

			if(SCREEN_PAGE_LAST) // Last page
				for(var/datum/feed_channel/NP in news_content)
					pages++
				if(important_message!=null)
					dat += "<div class='entry'>"
					dat += "<div class='entry-title'>Внимание! Розыск!</div>"
					dat += "<div class='entry-text'><b>Имя нарушителя:</b> <font color='maroon'>[important_message.title]</font></div>"
					dat += "<div class='entry-text'><b>Описание:</b> [important_message.body]</div>"
					if(important_message.img)
						user << browse_rsc(important_message.img, "tmp_photow.png")
						dat += "<img class='entry-image' src='tmp_photow.png' width='180'>"
					else
						dat += "<div class='entry-text'><b>Фото:</b> Отсутствует</div>"
					dat += "</div>"
				else
					dat += "<div class='entry-text'><i>На этой странице нет ничего, кроме нескольких неинтересных объявлений...</i></div>"
				if(scribble_page==curr_page)
					dat += "<div class='scribble'><i>В конце страницы есть небольшая пометка... Там написано: \"[scribble]\"</i></div>"
				dat += "<div class='navigation'><div style='float:left;'><a href='byond://?src=[UID()];prev_page=1'>Назад</a></div></div>"

			else
				dat += "<div class='entry-text'>Извините, что прерываю ваше погружение. Это дерьмо баганулось. Сообщите об этой ошибке в <a href='https://discord.com/channels/617003227182792704/1070247648147275807' target='_blank'>баг-репорт-v2</a></div>"

		dat += "<br><hr><div align='center'>Страница: [curr_page+1]</div>"
		dat += "</div>" // Закрываем .newspaper

		user << browse(dat, "window=newspaper_main;size=625x800")
		onclose(user, "newspaper_main")
	else
		to_chat(user, "<span class='warning'>Бумага заполнена непонятными символами!</span>")

/obj/item/newspaper/Topic(href, href_list)
	if(..())
		return
	if(!( (Adjacent(usr) && !istype(usr, /mob/dead/observer)) || (istype(usr, /mob/dead/observer) && usr.can_advanced_admin_interact()) ))
		return
	usr.set_machine(src)
	if(href_list["next_page"])
		if(curr_page == pages + 1)
			return //Don't need that at all, but anyway.
		else if(curr_page == pages) //We're at the middle, get to the end
			screen = SCREEN_PAGE_LAST
		else if(curr_page == 0) //We're at the start, get to the middle
			screen = SCREEN_PAGE_INNER
		curr_page++
		playsound(loc, "pageturn", 50, TRUE)
		attack_self(usr)
	else if(href_list["prev_page"])
		if(curr_page == 0)
			return
		else if(curr_page == 1)
			screen = SCREEN_COVER
		else if(curr_page == pages + 1) //we're at the end, let's go back to the middle.
			screen = SCREEN_PAGE_INNER
		curr_page--
		playsound(loc, "pageturn", 50, TRUE)
		attack_self(usr)


/obj/item/newspaper/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		if(rolled)
			balloon_alert(user, "сначала разверните!")
			return ATTACK_CHAIN_PROCEED
		if(scribble_page == curr_page)
			to_chat(user, span_notice("На этой странице уже есть пометка... Вы же не хотите сделать всё слишком запутанным, правда?"))
			balloon_alert(user, "нет места!")
			return ATTACK_CHAIN_PROCEED
		var/new_scribble = tgui_input_text(user, "Напишите что-то", "Newspaper")
		if(!new_scribble || !Adjacent(user))
			return ATTACK_CHAIN_PROCEED
		scribble_page = curr_page
		scribble = new_scribble
		user.visible_message(
			span_notice("[user] делает пометку в газете."),
			span_notice("Вы сделали пометку на [curr_page] станице."),
		)
		attack_self(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/newspaper/click_alt(mob/user)
	rolled = !rolled
	icon_state = "newspaper[rolled ? "_rolled" : ""]"
	update_icon()
	var/verbtext = "[rolled ? "" : "un"]roll"
	user.visible_message(span_notice("[user] [verbtext]s [src]."),\
							span_notice("You [verbtext] [src]."))
	name = "[rolled ? "rolled" : ""] [initial(name)]"
	return CLICK_ACTION_SUCCESS

#undef SCREEN_COVER
#undef SCREEN_PAGE_INNER
#undef SCREEN_PAGE_LAST
