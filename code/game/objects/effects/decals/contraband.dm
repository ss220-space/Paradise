// This is synced up to the poster placing animation.
#define PLACE_SPEED 30

// The poster item

/obj/item/poster
	name = "rolled-up poster"
	desc = "Постер оснащён собственной автоматической клеевой системой для удобного крепления на любую вертикальную поверхность. Его вульгарные темы сделали его контрабандой на объектах НаноТрейзен."
	icon = 'icons/obj/contraband.dmi'
	force = 0
	resistance_flags = FLAMMABLE
	var/poster_type
	var/obj/structure/sign/poster/poster_structure

/obj/item/poster/get_ru_names()
	return list(
		NOMINATIVE = "свёрнутый постер",
		GENITIVE = "свёрнутого постера",
		DATIVE = "свёрнутому постеру",
		ACCUSATIVE = "свёрнутый постер",
		INSTRUMENTAL = "свёрнутым постером",
		PREPOSITIONAL = "свёрнутом постере"
	)

/obj/item/poster/Initialize(mapload, obj/structure/sign/poster/new_poster_structure)
	. = ..()
	poster_structure = new_poster_structure
	if(!new_poster_structure && poster_type)
		poster_structure = new poster_type(src)

	// posters store what name and description they would like their rolled up form to take.
	if(poster_structure)
		name = poster_structure.poster_item_name
		desc = poster_structure.poster_item_desc
		icon_state = poster_structure.poster_item_icon_state

		name = "[name] - [poster_structure.original_name]"

/obj/item/poster/Destroy()
	poster_structure = null
	. = ..()

// These icon_states may be overriden, but are for mapper's convinence
/obj/item/poster/random_contraband
	name = "random contraband poster"
	poster_type = /obj/structure/sign/poster/contraband/random
	icon_state = "rolled_poster"

/obj/item/poster/random_official
	name = "random official poster"
	poster_type = /obj/structure/sign/poster/official/random
	icon_state = "rolled_poster_legit"

/obj/item/poster/syndicate_recruitment
	poster_type = /obj/structure/sign/poster/contraband/syndicate_recruitment
	icon_state = "rolled_poster"

/obj/item/poster/commando
	poster_type = /obj/structure/sign/poster/contraband/commando
	icon_state = "rolled_poster"

/obj/item/poster/cheng
	poster_type = /obj/structure/sign/poster/official/mr_cheng
	icon_state = "rolled_poster"

//############################## THE ACTUAL DECALS ###########################

/obj/structure/sign/poster
	name = "poster"
	desc = "Большой лист устойчивой к космическим условиям печатной бумаги."
	icon = 'icons/obj/contraband.dmi'
	anchored = TRUE
	var/original_name
	var/random_basetype
	var/ruined = FALSE
	var/never_random = FALSE // used for the 'random' subclasses.

	var/poster_item_name = "hypothetical poster"
	var/poster_item_desc = "This hypothetical poster item should not exist, let's be honest here."
	var/poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/get_ru_names()
	return list(
		NOMINATIVE = "постер",
		GENITIVE = "постера",
		DATIVE = "постеру",
		ACCUSATIVE = "постер",
		INSTRUMENTAL = "постером",
		PREPOSITIONAL = "постере"
	)

/obj/structure/sign/poster/Initialize(mapload)
	. = ..()
	if(random_basetype)
		randomise(random_basetype)
	if(!ruined)
		original_name = name
		name = "Постер – [name]"
		desc = "Большой лист устойчивой к космическим условиям печатной бумаги. [desc]"

/obj/structure/sign/poster/proc/randomise(base_type)
	var/list/poster_types = subtypesof(base_type)
	var/list/approved_types = list()
	for(var/t in poster_types)
		var/obj/structure/sign/poster/T = t
		if(initial(T.icon_state) && !initial(T.never_random))
			approved_types |= T

	var/obj/structure/sign/poster/selected = pick(approved_types)

	name = initial(selected.name)
	desc = initial(selected.desc)
	icon_state = initial(selected.icon_state)
	poster_item_name = initial(selected.poster_item_name)
	poster_item_desc = initial(selected.poster_item_desc)
	poster_item_icon_state = initial(selected.poster_item_icon_state)
	ruined = initial(selected.ruined)

/obj/structure/sign/poster/screwdriver_act()
	return

/obj/structure/sign/poster/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(ruined)
		balloon_alert(user, "вы убираете остатки постера")
		qdel(src)
	else
		balloon_alert(user, "вы аккуратно снимаете постер")
		roll_and_drop(user.loc)

/obj/structure/sign/poster/attack_hand(mob/user)
	if(ruined)
		return
	visible_message("[user] разрывает [declent_ru(NOMINATIVE)] одним решительным движением!")
	playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, TRUE)

	var/obj/structure/sign/poster/ripped/R = new(loc)
	R.pixel_y = pixel_y
	R.pixel_x = pixel_x
	R.add_fingerprint(user)
	qdel(src)

/obj/structure/sign/poster/proc/roll_and_drop(loc, mob/user)
	if(ruined)
		qdel(src)
		return
	pixel_x = 0
	pixel_y = 0
	var/obj/item/poster/P = new(loc, src)
	if(user)
		transfer_fingerprints_to(P)
	forceMove(P)
	return P

//seperated to reduce code duplication. Moved here for ease of reference and to unclutter r_wall/attackby()
/turf/simulated/wall/proc/place_poster(obj/item/poster/P, mob/user)
	if(!P.poster_structure)
		return
	var/stuff_on_wall = 0
	for(var/obj/O in contents) //Let's see if it already has a poster on it or too much stuff
		if(istype(O, /obj/structure/sign/poster))
			balloon_alert(user, "нет места!")
			return
		stuff_on_wall++
		if(stuff_on_wall >= 4)
			balloon_alert(user, "нет места!")
			return

		balloon_alert(user, "размещение...") //Looks like it's uncluttered enough. Place the poster.

	var/obj/structure/sign/poster/D = P.poster_structure

	var/temp_loc = user.loc

	switch(getRelativeDirection(user, src))
		if(NORTH)
			D.pixel_x = 0
			D.pixel_y = 32
		if(EAST)
			D.pixel_x = 32
			D.pixel_y = 0
		if(SOUTH)
			D.pixel_x = 0
			D.pixel_y = -32
		if(WEST)
			D.pixel_x = -32
			D.pixel_y = 0
		else
			balloon_alert(user, "слишком далеко!")
			return

	P.transfer_fingerprints_to(D)
	flick("poster_being_set", D)
	D.forceMove(temp_loc)
	qdel(P)	//delete it now to cut down on sanity checks afterwards. Agouri's code supports rerolling it anyway
	playsound(D.loc, 'sound/items/poster_being_created.ogg', 100, TRUE)

	if(do_after(user, PLACE_SPEED, src))
		if(!D || QDELETED(D))
			return

		if(iswallturf(src) && user && user.loc == temp_loc)	//Let's check if everything is still there
			balloon_alert(user, "постер размещён")
			return

	balloon_alert(user, "постер упал!")
	D.roll_and_drop(temp_loc, user)


////////////////////////////////POSTER VARIATIONS////////////////////////////////

/obj/structure/sign/poster/ripped
	ruined = TRUE
	icon_state = "poster_ripped"
	name = "ripped poster"
	desc = "Вы не можете разобрать, что было изображено на постере. Он испорчен."

/obj/structure/sign/poster/ripped/get_ru_names()
	return list(
		NOMINATIVE = "порванный постер",
		GENITIVE = "порванного постера",
		DATIVE = "порванному постеру",
		ACCUSATIVE = "порванный постер",
		INSTRUMENTAL = "порванным постером",
		PREPOSITIONAL = "порванном постере"
	)

/obj/structure/sign/poster/random
	name = "random poster" // could even be ripped
	icon_state = "random_anything"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster

//contraband posters
/obj/structure/sign/poster/contraband
	poster_item_name = "contraband poster"
	poster_item_desc = "Этот постер оснащён собственной автоматической клеевой системой для удобного крепления на любую вертикальную поверхность. Его вульгарные темы сделали его контрабандой на объектах НаноТрейзен."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/contraband/get_ru_names()
	return list(
		NOMINATIVE = "контрабандный постер",
		GENITIVE = "контрабандного постера",
		DATIVE = "контрабандному постеру",
		ACCUSATIVE = "контрабандный постер",
		INSTRUMENTAL = "контрабандным постером",
		PREPOSITIONAL = "контрабандном постере"
	)

/obj/structure/sign/poster/contraband/random
	name = "random contraband poster"
	icon_state = "random_contraband"
	never_random = TRUE
	random_basetype = /obj/structure/sign/poster/contraband

/obj/structure/sign/poster/contraband/free_tonto
	name = "Освободите Тонто"
	desc = "Спасённый обрывок гораздо большего флага, цвета слились и выцвели от времени."
	icon_state = "poster1"

/obj/structure/sign/poster/contraband/atmosia_independence
	name = "Декларация независимости Атмосии"
	desc = "Реликвия неудавшегося восстания."
	icon_state = "poster2"

/obj/structure/sign/poster/contraband/fun_police
	name = "Fun Police"
	desc = "Постер, осуждающий силы безопасности станции."
	icon_state = "poster3"

/obj/structure/sign/poster/contraband/lusty_xenomorph
	name = "Похотливый Ксеноморф"
	desc = "Еретический постер, изображающий главную звезду столь же еретической книги."
	icon_state = "poster4"

/obj/structure/sign/poster/contraband/syndicate_recruitment
	name = "Набор в Синдикат"
	desc = "Увидьте галактику! Разрушьте коррумпированные мегакорпорации! Вступайте сегодня!"
	icon_state = "poster5"

/obj/structure/sign/poster/contraband/clown
	name = "Клоун"
	desc = "Хонк."
	icon_state = "poster6"

/obj/structure/sign/poster/contraband/smoke
	name = "Курите"
	desc = "Постер, рекламирующий сигареты конкурирующей корпорации."
	icon_state = "poster7"

/obj/structure/sign/poster/contraband/grey_tide
	name = "Grey Tide"
	desc = "Мятежный постер, символизирующий солидарность ассистентов."
	icon_state = "poster8"

/obj/structure/sign/poster/contraband/missing_gloves
	name = "Пропавшие перчатки"
	desc = "Этот постер ссылается на возмущение, вызванное сокращением финансирования НаноТрейзен на покупку изолированных перчаток."
	icon_state = "poster9"

/obj/structure/sign/poster/contraband/hacking_guide
	name = "Руководство по взлому"
	desc = "Этот постер подробно описывает внутреннюю работу стандартного шлюза НаноТрейзен. К сожалению, он устарел."
	icon_state = "poster10"

/obj/structure/sign/poster/contraband/rip_badger
	name = "Покойся с миром, Барсук"
	desc = "Этот мятежный постер ссылается на геноцид НаноТрейзен целой космической станции, полной барсуков."
	icon_state = "poster11"

/obj/structure/sign/poster/contraband/ambrosia_vulgaris
	name = "Амброзия Вульгарис"
	desc = "Этот постер выглядит довольно трипово, чувак."
	icon_state = "poster12"

/obj/structure/sign/poster/contraband/donut_corp
	name = "Donut Corp."
	desc = "Этот постер является несанкционированной рекламой Донат Корп."
	icon_state = "poster13"

/obj/structure/sign/poster/contraband/eat
	name = "ЕШЬ"
	desc = "Этот постер пропагандирует безудержное обжорство."
	icon_state = "poster14"

/obj/structure/sign/poster/contraband/tools
	name = "Инструменты"
	desc = "Этот постер выглядит как реклама инструментов, но на самом деле это скрытый выпад в адрес инструментов ЦК."
	icon_state = "poster15"

/obj/structure/sign/poster/contraband/power
	name = "Мощь"
	desc = "Плакат сообщает, что не только у НаноТразен есть сила."
	icon_state = "poster16"

/obj/structure/sign/poster/contraband/power_people
	name = "Власть народу"
	desc = "К чёрту этих парней из EDF!"
	icon_state = "poster17"

/obj/structure/sign/poster/contraband/communist_state
	name = "Коммунистическое государство"
	desc = "Да здравствует Коммунистическая партия!"
	icon_state = "poster18"

/obj/structure/sign/poster/contraband/lamarr
	name = "Ламарр"
	desc = "Этот постер изображает Ламарра. Вероятно, создан Директором Исследований, работавшим на Синдикат."
	icon_state = "poster19"

/obj/structure/sign/poster/contraband/borg_fancy_1
	name = "Элегантный борг"
	desc = "Быть элегантным может любой борг, нужен только костюм."
	icon_state = "poster20"

/obj/structure/sign/poster/contraband/borg_fancy_2
	name = "Элегантный борг v2"
	desc = "Элегантный борг, теперь только для самых стильных."
	icon_state = "poster21"

/obj/structure/sign/poster/contraband/kss13
	name = "Космической Станции 13 не существует"
	desc = "Постер, высмеивающий отрицание ЦК существования заброшенной Космической Станции 13."
	icon_state = "poster22"

/obj/structure/sign/poster/contraband/rebels_unite
	name = "Повстанцы, объединяйтесь"
	desc = "Постер, призывающий восстать против НаноТрейзен."
	icon_state = "poster23"

/obj/structure/sign/poster/contraband/c20r
	name = "C-20r"
	desc = "Постер, рекламирующий пистолет-пулемёт C-20r от \"Скарборо Армс\"."
	icon_state = "poster24"

/obj/structure/sign/poster/contraband/have_a_puff
	name = "Затянись"
	desc = "Кого волнует рак лёгких, когда ты кайфуешь?"
	icon_state = "poster25"

/obj/structure/sign/poster/contraband/revolver
	name = "Револьвер"
	desc = "Семь выстрелов хватит на всех."
	icon_state = "poster26"

/obj/structure/sign/poster/contraband/d_day_promo
	name = "Промо D-Day"
	desc = "Рекламный постер какого-то рэпера."
	icon_state = "poster27"

/obj/structure/sign/poster/contraband/syndicate_pistol
	name = "Пистолет Синдиката"
	desc = "Этот постер рекламирует вам ахуенно-шикарные пистолеты синдиката."
	icon_state = "poster28"

/obj/structure/sign/poster/contraband/energy_swords
	name = "Энергетические мечи"
	desc = "Все цвета кровавой радуги убийств."
	icon_state = "poster29"

/obj/structure/sign/poster/contraband/red_rum
	name = "Красный ром"
	desc = "Взгляд на этот постер вызывает желание убивать."
	icon_state = "poster30"

/obj/structure/sign/poster/contraband/cc64k_ad
	name = "Реклама CC 64d"
	desc = "Последний портативный компьютер от \"Комрад Тех\" с целыми 64 КБ оперативной памяти!"
	icon_state = "poster31"

/obj/structure/sign/poster/contraband/punch_shit
	name = "Ломай всё"
	desc = "Тебе не нужна причина, чтобы что-либо ударить, будь мужиком!"
	icon_state = "poster32"

/obj/structure/sign/poster/contraband/the_griffin
	name = "Гриффин"
	desc = "Гриффин приказывает тебе быть мудаком настолько, насколько это возможно. Ты подчинишься?"
	icon_state = "poster33"

/obj/structure/sign/poster/contraband/pinup_syn
	name = "Пин-ап девушка Синди Кейт"
	desc = "Этот постер изображает Синди Кейт, соблазнительную исполнительницу, хорошо известную в менее приличных кругах."
	icon_state = "poster34"

/obj/structure/sign/poster/contraband/wanted
	name = "Вода Калиевич"
	desc = "На постере изображён лысый мужчина с чёрными глазами, 30 лет, разыскиваемый по всей галактике. Что он сделал, чтобы быть таким разыскиваемым..."
	icon_state = "poster35"

/obj/structure/sign/poster/contraband/very_robust
	name = "РОБАСТ"
	desc = "Вы видите слегка потрёпанный постер, на котором изображён КРАСНЫЙ ящик для инструментов и надпись \"Осторожно, РОБАСТ!\". Некоторые говорят, что эта красная краска на постере сделана из настоящей крови."
	icon_state = "poster36"

/obj/structure/sign/poster/contraband/commando
	name = "Коммандос"
	desc = "Вы видите мускулистого мужчину в боевой экипировке. Сам вид этого постера вызывает запах настоящей маскулинности."
	icon_state = "poster37"

/obj/structure/sign/poster/contraband/lostcat
	name = "Пропала кошка"
	desc = "Кисик пропал. Вооружён и опасен."
	icon_state = "poster38"

/obj/structure/sign/poster/contraband/bad_guy
	name = "Плохой парень"
	desc = "Перекур. На постере изображён парень с сигаретой, который призывает людей курить на работе."
	icon_state = "poster39"

/obj/structure/sign/poster/contraband/ninja
	name = "Космический ниндзя"
	desc = "Это постер, изображающий главного героя самого популярного анимационного сериала в галактике, \"Космический ниндзя\". Надпись на нём гласит, что новый сезон скоро начнётся."
	icon_state = "poster40"

/obj/structure/sign/poster/contraband/Enlist_Syndicate
	name = "Вступайте в Синдикат"
	desc = "Увидьте галактику! Разрушьте коррумпированные мегакорпорации! Получайте зарплату! Вступайте сегодня!"
	icon_state = "poster41"

/obj/structure/sign/poster/contraband/Enlist_Gorlex
	name = "Вступайте"
	desc = "Вступайте в ряды Горлексских Мародёров сегодня! Увидьте галактику, убейте корпоратов, получите оплату!"
	icon_state = "poster42"

//official posters
/obj/structure/sign/poster/official
	poster_item_name = "motivational poster"
	poster_item_desc = "Официальный постер от НаноТрейзен, призванный воспитывать покорную и послушную рабочую силу. Оснащён передовой клеевой основой для удобного крепления на любую вертикальную поверхность."
	poster_item_icon_state = "rolled_poster_legit"

/obj/structure/sign/poster/official/get_ru_names()
	return list(
		NOMINATIVE = "мотивационный постер",
		GENITIVE = "мотивационного постера",
		DATIVE = "мотивационному постеру",
		ACCUSATIVE = "мотивационный постер",
		INSTRUMENTAL = "мотивационным постером",
		PREPOSITIONAL = "мотивационном постере"
	)

/obj/structure/sign/poster/official/random
	name = "random official poster"
	random_basetype = /obj/structure/sign/poster/official
	icon_state = "random_official"
	never_random = TRUE

/obj/structure/sign/poster/official/here_for_your_safety
	name = "На страже вашей безопасности"
	desc = "Постер, прославляющий службу безопасности станции."
	icon_state = "poster1_legit"

/obj/structure/sign/poster/official/nanotrasen_logo
	name = "Логотип НаноТрейзен"
	desc = "Постер с изображением логотипа НаноТрейзен."
	icon_state = "poster2_legit"

/obj/structure/sign/poster/official/cleanliness
	name = "Чистота"
	desc = "Постер, предупреждающий об опасностях плохой гигиены."
	icon_state = "poster3_legit"

/obj/structure/sign/poster/official/help_others
	name = "Помогайте другим"
	desc = "Постер, призывающий помогать другим членам экипажа."
	icon_state = "poster4_legit"

/obj/structure/sign/poster/official/build
	name = "Стройте"
	desc = "Постер, прославляющий инженерную команду."
	icon_state = "poster5_legit"

/obj/structure/sign/poster/official/bless_this_spess
	name = "Благослови это место"
	desc = "Постер, благословляющий эту область."
	icon_state = "poster6_legit"

/obj/structure/sign/poster/official/science
	name = "Наука"
	desc = "Постер с изображением атома."
	icon_state = "poster7_legit"

/obj/structure/sign/poster/official/ian
	name = "Иан"
	desc = "Гав-гав. Тяв!"
	icon_state = "poster8_legit"

/obj/structure/sign/poster/official/obey
	name = "Повинуйтесь"
	desc = "Постер, призывающий зрителя подчиняться власти."
	icon_state = "poster9_legit"

/obj/structure/sign/poster/official/walk
	name = "Ходите"
	desc = "Постер, призывающий зрителя ходить, а не бегать."
	icon_state = "poster10_legit"

/obj/structure/sign/poster/official/state_laws
	name = "Озвучь Законы"
	desc = "Постер, призывающий киборгов озвучивать свои законы."
	icon_state = "poster11_legit"

/obj/structure/sign/poster/official/love_ian
	name = "Любите Иана"
	desc = "Иан - это любовь, Иан - это жизнь."
	icon_state = "poster12_legit"

/obj/structure/sign/poster/official/space_cops
	name = "Космические копы."
	desc = "Постер, рекламирующий телешоу «Космические копы»."
	icon_state = "poster13_legit"

/obj/structure/sign/poster/official/ue_no
	name = "Ue No."
	desc = "Этот постер полностью на японском."
	icon_state = "poster14_legit"

/obj/structure/sign/poster/official/get_your_legs
	name = "Получи свои НОГИ"
	desc = "НОГИ: Наука, Опыт, Гениальность, Идеология."
	icon_state = "poster15_legit"

/obj/structure/sign/poster/official/do_not_question
	name = "Не задавайте вопросов"
	desc = "Постер, призывающий зрителя не задавать вопросы о том, что им не положено знать."
	icon_state = "poster16_legit"

/obj/structure/sign/poster/official/work_for_a_future
	name = "Работайте ради будущего"
	desc = "Постер, призывающий работать ради своего будущего."
	icon_state = "poster17_legit"

/obj/structure/sign/poster/official/soft_cap_pop_art
	name = "Поп-арт с мягкой кепкой"
	desc = "Постер-репродукция дешёвого поп-арта."
	icon_state = "poster18_legit"

/obj/structure/sign/poster/official/safety_internals
	name = "Безопасность: Дыхательные аппараты"
	desc = "Постер, призывающий зрителя носить дыхательные аппараты в редких условиях, где нет кислорода или воздух стал токсичным."
	icon_state = "poster19_legit"

/obj/structure/sign/poster/official/safety_eye_protection
	name = "Безопасность: Защита глаз"
	desc = "Постер, призывающий зрителя носить защиту для глаз при работе с химикатами, дымом или ярким светом."
	icon_state = "poster20_legit"

/obj/structure/sign/poster/official/safety_report
	name = "Безопасность: Докладывайте"
	desc = "Постер, призывающий зрителя докладывать о подозрительной деятельности службе безопасности."
	icon_state = "poster21_legit"

/obj/structure/sign/poster/official/report_crimes
	name = "Сообщайте о преступлениях"
	desc = "Постер, призывающий быстро сообщать о преступлениях или мятежном поведении службе безопасности станции."
	icon_state = "poster22_legit"

/obj/structure/sign/poster/official/ion_rifle
	name = "Ионная винтовка"
	desc = "Постер с изображением ионной винтовки."
	icon_state = "poster23_legit"

/obj/structure/sign/poster/official/foam_force_ad
	name = "Реклама \"Пенная сила\""
	desc = "Пенная сила: пеняй или будь пеной!"
	icon_state = "poster24_legit"

/obj/structure/sign/poster/official/cohiba_robusto_ad
	name = "Реклама Коиба Робусто"
	desc = "Коиба Робусто – стильные сигары."
	icon_state = "poster25_legit"

/obj/structure/sign/poster/official/anniversary_vintage_reprint
	name = "Винтажная репродукция к 50-летию"
	desc = "Репродукция постера 2505 года, посвящённая 50-летию \"НаноПостер\", дочерней компании НаноТрейзен."
	icon_state = "poster26_legit"

/obj/structure/sign/poster/official/fruit_bowl
	name = "Фруктовая тарелка"
	desc = "Просто, но впечатляюще."
	icon_state = "poster27_legit"

/obj/structure/sign/poster/official/pda_ad
	name = "Реклама КПК"
	desc = "Постер, рекламирующий последнюю модель КПК от поставщиков НаноТрейзен."
	icon_state = "poster28_legit"

/obj/structure/sign/poster/official/enlist
	name = "Вступайте"
	desc = "Вступайте в резерв ОБР НаноТрейзен сегодня!"
	icon_state = "poster29_legit"

/obj/structure/sign/poster/official/nanomichi_ad
	name = "Реклама Nanomichi"
	desc = "Постер, рекламирующий аудиокассеты бренда Наномичи."
	icon_state = "poster30_legit"

/obj/structure/sign/poster/official/twelve_gauge
	name = "12 калибр"
	desc = "Постер, восхваляющий превосходство патронов калибра 12g."
	icon_state = "poster31_legit"

/obj/structure/sign/poster/official/high_class_martini
	name = "Высококлассный мартини"
	desc = "Я же сказал взболтать, а не смешивать."
	icon_state = "poster32_legit"

/obj/structure/sign/poster/official/the_owl
	name = "Сова"
	desc = "Сова сделает всё возможное, чтобы защитить станцию. А вы?"
	icon_state = "poster33_legit"

/obj/structure/sign/poster/official/spiders
	name = "Риск пауков"
	desc = "Постер, объясняющий, что делать при виде гигантских пауков."
	icon_state = "poster34_legit"

/obj/structure/sign/poster/official/kill_syndicate
	name = "Убивайте Синдикат"
	desc = "Постер, требующий, чтобы весь экипаж был готов сражаться с Синдикатом."
	icon_state = "poster35_legit"

/obj/structure/sign/poster/official/air1
	name = "Информация о воздухе"
	desc = "Постер, напоминающий экипажу о баллонах с воздухом."
	icon_state = "poster36_legit"

/obj/structure/sign/poster/official/air2
	name = "Информация о воздухе"
	desc = "Постер, напоминающий экипажу о баллонах с воздухом."
	icon_state = "poster37_legit"

/obj/structure/sign/poster/official/dig
	name = "Копайте ради славы!"
	desc = "Постер, пытающийся убедить экипаж добывать руду."
	icon_state = "poster38_legit"

/obj/structure/sign/poster/official/religious
	name = "Религиозный постер"
	desc = "Обычный религиозный постер, призывающий верить."
	icon_state = "poster39_legit"

/obj/structure/sign/poster/official/healthy
	name = "Оставайтесь здоровыми!"
	desc = "Здоровый экипаж — счастливый экипаж!"
	icon_state = "poster40_legit"

/obj/structure/sign/poster/official/vodka
	name = "Водка"
	desc = "Рекламный постер водки, от настоящих мужчин для настоящих мужчин. Почувствуйте себя космическим медведем."
	icon_state = "poster41_legit"

/obj/structure/sign/poster/official/tsf_emblem
	name = "Эмблема ТСФ"
	desc = "Патриотический постер с эмблемой ТСФ и скучным текстом о чести морпехов."
	icon_state = "poster42_legit"

/obj/structure/sign/poster/official/wetskrell
	name = "WetSkrell"
	desc = "Вы видите симпатичную скрелл в красном платье и с длинными головными щупальцами, украшенными декоративными лентами. Это реклама сайта с \"процедурами для взрослых\", wetskrell.nt."
	icon_state = "poster43_legit"

/obj/structure/sign/poster/official/keepcalm
	name = "Сохраняйте спокойствие"
	desc = "Этот постер выполнен в знаменитом дизайне Новой Земли, хотя и слегка изменён. Кто-то написал букву O поверх A на постере."
	icon_state = "poster44_legit"

/obj/structure/sign/poster/official/pinup_a
	name = "Пин-ап девушка Синди"
	desc = "Этот постер изображает историческую корпоративную ПР-девушку Синди в особенно женственной позе."
	icon_state = "poster45_legit"

/obj/structure/sign/poster/official/pinup_b
	name = "Пин-ап девушка Эми"
	desc = "Этот постер изображает Эми, нимфоманку-легенду дальнего космоса. Как появилась эта фотография, неизвестно."
	icon_state = "poster46_legit"

/obj/structure/sign/poster/official/insp_law
	name = "Вдохновляющий юрист"
	desc = "Вдохновляющий постер, изображающий скреллианского юриста. Кажется, он что-то кричит, яростно указывая вправо."
	icon_state = "poster47_legit"

/obj/structure/sign/poster/official/space_a
	name = "Постер восхищения космосом"
	desc = "Этот постер создан \"Дженерерик Спейс Компани\" как часть серии памятных постеров о чудесах космоса. Один из трёх."
	icon_state = "poster48_legit"

/obj/structure/sign/poster/official/space_b
	name = "Постер восхищения Марсом"
	desc = "Этот постер создан \"Дженерерик Спейс Компани\" как часть серии памятных постеров о чудесах космоса. Третий из трёх."
	icon_state = "poster49_legit"

/obj/structure/sign/poster/official/wild_west
	name = "Дикое Карго"
	desc = "Красивое дикое место со своим шерифом."
	icon_state = "poster50_legit"

/obj/structure/sign/poster/official/razumause
	name = "Разумышь"
	desc = "Эй, эй! Что может пойти не так, да?"
	icon_state = "poster51_legit"

/obj/structure/sign/poster/official/assist_pride
	name = "Гордость ассистента"
	desc = "Даже в космосе профессия ассистента востребована. И этот постер показывает вам их красоту."
	icon_state = "poster52_legit"

/obj/structure/sign/poster/official/mr_cheng
	name = "Мистер Чанг!"
	desc = "Ошеломляющие скидки! Лучшее качество продукции! Хорошие цены на множество товаров! Только у мистера Чанга."
	icon_state = "poster53_legit"

/obj/structure/sign/poster/secret
	poster_item_name = "Secret poster"
	poster_item_desc = "Крайне Секретный постер."
	poster_item_icon_state = "rolled_poster"

/obj/structure/sign/poster/secret/get_ru_names()
	return list(
		NOMINATIVE = "секретный постер",
		GENITIVE = "секретного постера",
		DATIVE = "секретному постеру",
		ACCUSATIVE = "секретный постер",
		INSTRUMENTAL = "секретным постером",
		PREPOSITIONAL = "секретном постере"
	)

/obj/structure/sign/poster/secret/lady
	name = "Девушка-учёный"
	desc = "Потрясающе выглядящая девушка в лабораторном халате. Уфф, горяча!"
	icon_state = "poster1_secret"

/obj/structure/sign/poster/secret/Viper
	name = "Разыскивается офицер Синдиката"
	desc = "На постере изображён: рыжеволосый мужчина в авиаторских очках, чуть за 30, с сигарой во рту, одетый в шубу поверх тактической водолазки."
	icon_state = "poster2_secret"

/obj/structure/sign/poster/secret/lizard
	name = "Развратная ящерица"
	desc = "Этот похабный постер изображает ящерицу, которая готовится к брачному периоду."
	icon_state = "poster3_secret"

#undef PLACE_SPEED
