/obj/structure/sign
	icon = 'icons/obj/decals.dmi'
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	layer = NOT_HIGH_OBJ_LAYER
	max_integrity = 100
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	var/does_emissive = FALSE
	var/random_number = FALSE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)


/obj/structure/sign/Initialize(mapload)
	. = ..()
	if(does_emissive || random_number)
		update_icon(UPDATE_OVERLAYS)


/obj/structure/sign/update_overlays()
	. = ..()

	underlays.Cut()
	if(does_emissive)
		underlays += emissive_appearance(icon, "[icon_state]_lightmask", src)
	if(random_number)
		add_overlay(mutable_appearance(icon, "_num[pick("0","1","2","3","4","5","6","7","8","9","10","inf")]"))

/obj/structure/sign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/weapons/slash.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 80, TRUE)


/obj/structure/sign/screwdriver_act(mob/user, obj/item/I)
	if(istype(src, /obj/structure/sign/double))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	balloon_alert(user, "откручено")
	var/obj/item/sign/S = new(src.loc)
	S.name = name
	S.desc = desc
	S.icon_state = icon_state
	//var/icon/I = icon('icons/obj/decals.dmi', icon_state)
	//S.icon = I.Scale(24, 24)
	S.sign_state = icon_state
	qdel(src)


/obj/item/sign
	name = "sign"
	desc = ""
	ru_names = list(
		NOMINATIVE = "табличка",
		GENITIVE = "таблички",
		DATIVE = "табличке",
		ACCUSATIVE = "табличку",
		INSTRUMENTAL = "табличкой",
		PREPOSITIONAL = "табличке"
	)
	icon = 'icons/obj/decals.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FLAMMABLE
	var/sign_state = ""


/obj/item/sign/screwdriver_act(mob/living/user, obj/item/I)
	if(!isturf(loc))
		return

	var/direction = input("В каком направлении?", "Выбор направления") in list("Север", "Восток", "Юг", "Запад", "Отмена")
	if(direction == "Отмена")
		return TRUE // These gotta be true or we stab the sign
	if(QDELETED(src))
		return TRUE // Unsure about this, but stabbing something that doesnt exist seems like a bad idea

	var/obj/structure/sign/sign = new(loc)
	switch(direction)
		if("Север")
			sign.pixel_y = 32
		if("Восток")
			sign.pixel_x = 32
		if("Юг")
			sign.pixel_y = -32
		if("Запад")
			sign.pixel_x = -32
		else
			return TRUE // We dont want to stab it or place it, so we return
	sign.name = name
	sign.desc = desc
	sign.icon_state = sign_state
	balloon_alert(user, "прикручено")
	qdel(src)
	return TRUE


/obj/structure/sign/double/map
	name = "station map"
	desc = "Фотография станции в рамке."
	ru_names = list(
		NOMINATIVE = "карта станции",
		GENITIVE = "карты станции",
		DATIVE = "карте станции",
		ACCUSATIVE = "карту станции",
		INSTRUMENTAL = "картой станции",
		PREPOSITIONAL = "карте станции"
	)
	max_integrity = 500

/obj/structure/sign/double/map/left
	icon_state = "map-left"

/obj/structure/sign/double/map/right
	icon_state = "map-right"

/obj/structure/sign/double/no_idiots
	name = "Счетный знак"
	desc = "Показывает, сколько дней станция работает без идиотов на панели управления кристаллом СуперМатерии."

/obj/structure/sign/double/no_idiots/left
	icon_state = "no_idiots_left"
	random_number = TRUE

/obj/structure/sign/double/no_idiots/right
	icon_state = "no_idiots_right"

/obj/structure/sign/securearea
	name = "ЗАКРЫТАЯ ЗОНА"
	desc = "Предупреждающий знак с надписью \"ЗАКРЫТАЯ ЗОНА\""
	icon_state = "securearea"

/obj/structure/sign/biohazard
	name = "БИОЛОГИЧЕСКАЯ ОПАСНОСТЬ"
	desc = "Предупреждающий знак с надписью \"БИОЛОГИЧЕСКАЯ ОПАСНОСТЬ\""
	icon_state = "bio"

/obj/structure/sign/electricshock
	name = "ВЫСОКОЕ НАПРЯЖЕНИЕ"
	desc = "Предупреждающий знак с надписью \"ВЫСОКОЕ НАПРЯЖЕНИЕ\""
	icon_state = "shock"

/obj/structure/sign/examroom
	name = "ЭКЗАМЕН"
	desc = "Указательный знак с надписью \"ЭКЗАМЕНАЦИОННАЯ КОМНАТА\""
	icon_state = "examroom"

/obj/structure/sign/vacuum
	name = "ВПЕРЕДИ ЖЕСТКИЙ ВАКУУМ"
	desc = "Предупреждающий знак с надписью \"ВПЕРЕДИ ЖЕСТКИЙ ВАКУУМ\""
	icon_state = "space"

/obj/structure/sign/vacuum/external
	name = "ВНЕШНИЙ ШЛЮЗ"
	desc = "Предупреждающий знак с надписью \"ВНЕШНИЙ ШЛЮЗ\""
	layer = MOB_LAYER

/obj/structure/sign/deathsposal
	name = "УТИЛИЗАЦИЯ ВЕДЕТ В КОСМОС"
	desc = "Предупреждающий знак с надписью \"УТИЛИЗАЦИЯ ВЕДЕТ В КОСМОС\""
	icon_state = "deathsposal"

/obj/structure/sign/pods
	name = "СПАСАТЕЛЬНЫЕ КАПСУЛЫ"
	desc = "Предупреждающий знак с надписью \"СПАСАТЕЛЬНЫЕ КАПСУЛЫ\""
	icon_state = "pods"

/obj/structure/sign/fire
	name = "ОПАСНОСТЬ: ОГОНЬ"
	desc = "Предупреждающий знак с надписью \"ОПАСНОСТЬ: ОГОНЬ\""
	icon_state = "fire"
	resistance_flags = FIRE_PROOF

/obj/structure/sign/nosmoking_1
	name = "КУРЕНИЕ ЗАПРЕЩЕНО"
	desc = "Предупреждающий знак с надписью \"КУРЕНИЕ ЗАПРЕЩЕНО\""
	icon_state = "nosmoking"
	resistance_flags = FLAMMABLE

/obj/structure/sign/nosmoking_2
	name = "КУРЕНИЕ ЗАПРЕЩЕНО"
	desc = "Предупреждающий знак с надписью \"КУРЕНИЕ ЗАПРЕЩЕНО\""
	icon_state = "nosmoking2"

/obj/structure/sign/radiation
	name = "РАДИАЦИОННАЯ ОПАСНОСТЬ"
	desc = "Предупреждающий знак, предупреждающий о потенциальной радиационной опасности."
	icon_state = "radiation"

/obj/structure/sign/radiation/rad_area
	name = "РАДИОАКТИВНАЯ ЗОНА"
	desc = "Предупреждающий знак с надписью \"РАДИОАКТИВНАЯ ЗОНА\""

/obj/structure/sign/xeno_warning_mining
	name = "ОПАСНАЯ ИНОПЛАНЕТНАЯ ЖИЗНЬ"
	desc = "Знак, предупреждающий о враждебной инопланетной жизни поблизости"
	icon = 'icons/obj/mining.dmi'
	icon_state = "xeno_warning"

/obj/structure/sign/redcross
	name = "медбэй"
	desc = "Межгалактический символ медицинских учреждений. Здесь, вероятно, вам окажут помощь."
	icon_state = "redcross"

/obj/structure/sign/greencross
	name = "медбэй"
	desc = "Межгалактический символ медицинских учреждений. Здесь, вероятно, вам окажут помощь."
	icon_state = "greencross"

/obj/structure/sign/goldenplaque
	name = "награда \"Самый робастный мужчина\""
	desc = "Робаст – это не действие или образ жизни, а состояние ума. Лишь те, чья воля крепка настолько, чтобы в час кризиса спасти друга от врага познали истинную суть робаста. Оставайтесь сильными, друзья."
	icon_state = "goldenplaque"

/obj/structure/sign/kiddieplaque
	name = "табличка разработчиков ИИ"
	desc = "Рядом с очень длинным списком имен и должностей есть рисунок маленького ребенка. У ребенка глаза косят, и он пускает слюни. Под изображением кто-то выцарапал слово \"ПАКЕТЫ\""
	icon_state = "kiddieplaque"

/obj/structure/sign/atmosplaque
	name = "мемориальная доска отдела \"ZAS\""
	desc = "Эта табличка установлена в память погибших атмосферников. Здесь увековечены те, кто пал жертвой неукротимой стихии – сгоревшие заживо, отравленные газами и раздавленные разгерметизацией. \"Они знали, на что шли\""
	icon_state = "atmosplaque"

/obj/structure/sign/beautyplaque
	name = "награда \"Божественная Грация\""
	desc = "Истинная красота не требует анализа! Позвольте чувствам вести вас — подобно тому, как частицы устремляются к сингулярности, не задумываясь о пути. Прекрасное познаётся сердцем, а не разумом"
	icon_state = "beautyplaque"

/obj/structure/sign/kidanplaque
	name = "трофей кидана"
	desc = "Мертвая нимфа Дионы, прибитая к доске."
	icon_state = "kidanplaque"

/obj/structure/sign/tajarplaque
	name = "фотография таяры"
	desc = "Красивая фотография таяры, закрепленная на доске."
	icon_state = "tajarplaque"

/obj/structure/sign/mech
	name = "картина меха"
	desc = "Картина бота ED-209."
	icon_state = "mech"

/obj/structure/sign/nuke
	name = "картина ядерной боеголовки"
	desc = "Просто картина ядерной боеголовки, ничего лишнего."
	icon_state = "nuke"

/obj/structure/sign/clown
	name = "рисунок клоуна"
	desc = "Рисунок клоуна и мима. Уфффф..."
	icon_state = "clown"

/obj/structure/sign/bobross
	name = "успокаивающая картина"
	desc = "Мы не совершаем ошибок, только счастливые маленькие случайности."
	icon_state = "bob"

/obj/structure/sign/singulo
	name = "картина сингулярности"
	desc = "Завораживающая картина сингулярности. Кажется, она засасывает вас..."
	icon_state = "singulo"

/obj/structure/sign/barber
	name = "знак парикмахерской"
	desc = "Вращающаяся вывеска, указывающая на близость парикмахерской."
	icon_state = "barber"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/chinese
	name = "знак китайского ресторана"
	desc = "Светящийся дракон приглашает вас внутрь."
	icon_state = "chinese"
	does_emissive = TRUE
	blocks_emissive = FALSE

/obj/structure/sign/bathhouse
	name = "знак бани"
	desc = "Старая но рабочая табличка. Здесь изображён банный инвентарь."
	icon_state = "banya"

/obj/structure/sign/science
	name = "НАУКА!"
	desc = "Предупреждающий знак с надписью \"НАУКА!\""
	icon_state = "science1"

/obj/structure/sign/chemistry
	name = "ХИМИЯ"
	desc = "Предупреждающий знак с надписью \"ХИМИЯ\""
	icon_state = "chemistry1"

/obj/structure/sign/botany
	name = "ГИДРОПОНИКА"
	desc = "Предупреждающий знак с надписью \"ГИДРОПОНИКА\""
	icon_state = "hydro1"

/obj/structure/sign/xenobio
	name = "КСЕНОБИОЛОГИЯ"
	desc = "Знак, обозначающий область, где исследуются ксенобиологические существа."
	icon_state = "xenobio"

/obj/structure/sign/evac
	name = "ЭВАКУАЦИЯ"
	desc = "Знак, обозначающий область, где проводятся процедуры эвакуации."
	icon_state = "evac"

/obj/structure/sign/drop
	name = "ДЕСАНТНЫЕ КАПСУЛЫ"
	desc = "Знак, обозначающий область, где проводятся процедуры загрузки десантных капсул."
	icon_state = "drop"

/obj/structure/sign/custodian
	name = "УБОРЩИК"
	desc = "Знак, обозначающий область, где работает уборщик."
	icon_state = "custodian"

/obj/structure/sign/engineering
	name = "ИНЖЕНЕРИЯ"
	desc = "Знак, обозначающий область, где работают инженеры."
	icon_state = "engine"

/obj/structure/sign/cargo
	name = "КАРГО"
	desc = "Знак, обозначающий зону стыковки грузовых кораблей."
	icon_state = "cargo"

/obj/structure/sign/med
	name = "МЕДБЭЙ"
	desc = "Знак, обозначающий область, где исцеление реально."
	icon_state = "med"

/obj/structure/sign/comand
	name = "МОСТИК"
	desc = "Знак, обозначающий место, где бухает всё начальство."
	icon_state = "comand"

/obj/structure/sign/security
	name = "БЕЗОПАСНОСТЬ"
	desc = "В этой зоне закон не просто исполняется — он дышит вам в затылок."
	icon_state = "security"

/obj/structure/sign/holy
	name = "СВЯТЫНЯ"
	desc = "Здесь обитают боги — или те, кто называет себя богами."
	icon_state = "holy"

/obj/structure/sign/restroom
	name = "ТУАЛЕТ"
	desc = "Тот самый знак, который все ищут в критический момент."
	icon_state = "restroom"

/obj/structure/sign/medbay
	name = "МЕДБЭЙ"
	desc = "Межгалактический символ медицинских учреждений. Здесь, вероятно, вам окажут помощь."
	icon_state = "bluecross"

/obj/structure/sign/medbay/alt
	icon_state = "bluecross2"

/obj/structure/sign/directions/floor
	name = "Этаж"
	desc = "Указательный знак, указывающий, на каком этаже вы находитесь."
	icon_state = "level"

/obj/structure/sign/directions/floor/alt
	icon_state = "level_alt"

/obj/structure/sign/directions/science
	name = "Исследовательский отдел"
	desc = "Указательный знак, указывающий, в каком направлении находится исследовательский отдел."
	icon_state = "direction_sci"

/obj/structure/sign/directions/engineering
	name = "Инженерный отдел"
	desc = "Указательный знак, указывающий, в каком направлении находится инженерный отдел."
	icon_state = "direction_eng"

/obj/structure/sign/directions/security
	name = "Служба безопасности"
	desc = "Указательный знак, указывающий, в каком направлении находится служба безопасности."
	icon_state = "direction_sec"

/obj/structure/sign/directions/medical
	name = "Медицинский блок"
	desc = "Указательный знак, указывающий, в каком направлении находится медицинский блок."
	icon_state = "direction_med"

/obj/structure/sign/directions/evac
	name = "Эвакуация"
	desc = "Указательный знак, указывающий, в каком направлении находится шаттл эвакуации."
	icon_state = "direction_evac"

/obj/structure/sign/directions/cargo
	name = "Отдел карго"
	desc = "Указательный знак, указывающий, в каком направлении находится отдел карго."
	icon_state = "direction_supply"

/obj/structure/sign/explosives
	name = "ВЗРЫВЧАТЫЕ ВЕЩЕСТВА"
	desc = "Предупреждающий знак с надписью \"ВЗРЫВЧАТЫЕ ВЕЩЕСТВА\""
	icon_state = "explosives"

/obj/structure/sign/explosives/alt
	name = "ВЗРЫВЧАТЫЕ ВЕЩЕСТВА"
	desc = "Предупреждающий знак с надписью \"ВЗРЫВЧАТЫЕ ВЕЩЕСТВА\""
	icon_state = "explosives2"

/obj/structure/sign/cave
	name = "портрет Кейва Джонсона"
	desc = "Когда вселенная швыряет в вас камни из плазмы — вы не \"изучаете их свойства\"! Вы берете эти камни, перемалываете в токсичную пыль и запускаете ей в лицо всем скептикам! Руководство ноет о \"технике безопасности\"? ПЛЕВАТЬ НА НИХ! Найдите ассистентов, которые не побоятся взорвать эту смесь в своих руках, во благо науки!"
	icon_state = "cave"
