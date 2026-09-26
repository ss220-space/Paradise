/* Action figures toys
 *	Contains:
 *		Mech prizes
 *		Owl and griffin
 *		DND Character minis
 *		Action figures
 */

// MARK: Mech prizes
/obj/item/toy/prize
	abstract_type = /obj/item/toy/prize
	icon_state = "ripleytoy"

/obj/item/toy/prize/attack_self(mob/user as mob)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
	playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)

	COOLDOWN_START(src, cooldown, 1 SECONDS)
	return TRUE

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	if(loc != user)
		..()

	to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
	playsound(user, 'sound/mecha/mechturn.ogg', 20, TRUE)

	COOLDOWN_START(src, cooldown, 1 SECONDS)
	return TRUE

/obj/random/mech
	abstract_type = /obj/random/mech
	name = "Random Mech Prize"
	desc = "This is a random prize"
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"

/obj/random/mech/item_to_spawn()
	return pick(valid_subtypesof(/obj/item/toy/prize)) //exclude the base type.

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Маленькая фигурка меха, собери всю коллекцию! Номер 1 из 11. Эта фигурка изображает \"Рипли\", который используется в работе шахтёров и инженеров."

/obj/item/toy/prize/ripley/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Рипли\"",
		GENITIVE = "фигурки меха \"Рипли\"",
		DATIVE = "фигурке меха \"Рипли\"",
		ACCUSATIVE = "фигурку меха \"Рипли\"",
		INSTRUMENTAL = "фигуркой меха \"Рипли\"",
		PREPOSITIONAL = "фигурке меха \"Рипли\"",
	)

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 2 из 11. Эта фигурка изображает \"Огнеборец\", который используется в работе шахтёров и инженеров. Огнеупорный!"
	icon_state = "fireripleytoy"

/obj/item/toy/prize/fireripley/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Огнеборец\"",
		GENITIVE = "фигурки меха \"Огнеборец\"",
		DATIVE = "фигурке меха \"Огнеборец\"",
		ACCUSATIVE = "фигурку меха \"Огнеборец\"",
		INSTRUMENTAL = "фигуркой меха \"Огнеборец\"",
		PREPOSITIONAL = "фигурке меха \"Огнеборец\"",
	)

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 3 из 11. Эта фигурка изображает чёрный вариант Рипли, который использовался \
			героем сериала \"Отряд смерти\", повествующего о безбашенных офицерах отряда быстрого реагирования."
	icon_state = "deathripleytoy"

/obj/item/toy/prize/deathripley/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Рипли-жнец\"",
		GENITIVE = "фигурки меха \"Рипли-жнец\"",
		DATIVE = "фигурке меха \"Рипли-жнец\"",
		ACCUSATIVE = "фигурку меха \"Рипли-жнец\"",
		INSTRUMENTAL = "фигуркой меха \"Рипли-жнец\"",
		PREPOSITIONAL = "фигурке меха \"Рипли-жнец\"",
	)

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 4 из 11. Эта фигурка изображает быстрый боевой мех \"Гигакс\". Пиу-пиу!"
	icon_state = "gygaxtoy"

/obj/item/toy/prize/gygax/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Гигакс\"",
		GENITIVE = "фигурки меха \"Гигакс\"",
		DATIVE = "фигурке меха \"Гигакс\"",
		ACCUSATIVE = "фигурку меха \"Гигакс\"",
		INSTRUMENTAL = "фигуркой меха \"Гигакс\"",
		PREPOSITIONAL = "фигурке меха \"Гигакс\"",
	)

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 5 из 11. Эта фигурка изображает тяжёлый боевой мех \"Дюранд\". Топ-топ!"
	icon_state = "durandprize"

/obj/item/toy/prize/durand/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Дюранд\"",
		GENITIVE = "фигурки меха \"Дюранд\"",
		DATIVE = "фигурке меха \"Дюранд\"",
		ACCUSATIVE = "фигурку меха \"Дюранд\"",
		INSTRUMENTAL = "фигуркой меха \"Дюранд\"",
		PREPOSITIONAL = "фигурке меха \"Дюранд\"",
	)

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 6 из 11. Да это же тот самый печально известный \"Хонкомех\"!"
	icon_state = "honkprize"

/obj/item/toy/prize/honk/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка Хонкомеха",
		GENITIVE = "фигурки Хонкомеха",
		DATIVE = "фигурке Хонкомеха",
		ACCUSATIVE = "фигурку Хонкомеха",
		INSTRUMENTAL = "фигуркой Хонкомеха",
		PREPOSITIONAL = "фигурке Хонкомеха",
	)

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 7 из 11. Эта фигурка изображает мощный боевой мех — \"Мародёр\". Бегите в укрытие!"
	icon_state = "marauderprize"

/obj/item/toy/prize/marauder/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Мародёр\"",
		GENITIVE = "фигурки меха \"Мародёр\"",
		DATIVE = "фигурке меха \"Мародёр\"",
		ACCUSATIVE = "фигурку меха \"Мародёр\"",
		INSTRUMENTAL = "фигуркой меха \"Мародёр\"",
		PREPOSITIONAL = "фигурке меха \"Мародёр\"",
	)

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 8 из 11. Эта фигурка изображает один из сильнейших боевых мехов — \"Серафим\". Кому-то не повезло..."
	icon_state = "seraphprize"

/obj/item/toy/prize/seraph/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Серафим\"",
		GENITIVE = "фигурки меха \"Серафим\"",
		DATIVE = "фигурке меха \"Серафим\"",
		ACCUSATIVE = "фигурку меха \"Серафим\"",
		INSTRUMENTAL = "фигуркой меха \"Серафим\"",
		PREPOSITIONAL = "фигурке меха \"Серафим\"",
	)

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 9 из 11. Эта фигурка изображает смертоносный мех — \"Маулер\". Берегитесь!"
	icon_state = "maulerprize"

/obj/item/toy/prize/mauler/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Маулер\"",
		GENITIVE = "фигурки меха \"Маулер\"",
		DATIVE = "фигурке меха \"Маулер\"",
		ACCUSATIVE = "фигурку меха \"Маулер\"",
		INSTRUMENTAL = "фигуркой меха \"Маулер\"",
		PREPOSITIONAL = "фигурке меха \"Маулер\"",
	)

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 10 из 11. Эта фигурка изображает белый изворотливый мех \"Одиссей\". Его используют врачи и парамедики по всей галактике."
	icon_state = "odysseusprize"

/obj/item/toy/prize/odysseus/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Одиссей\"",
		GENITIVE = "фигурки меха \"Одиссей\"",
		DATIVE = "фигурке меха \"Одиссей\"",
		ACCUSATIVE = "фигурку меха \"Одиссей\"",
		INSTRUMENTAL = "фигуркой меха \"Одиссей\"",
		PREPOSITIONAL = "фигурке меха \"Одиссей\"",
	)

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mаленькая фигурка меха, собери всю коллекцию! Номер 11 из 11. Это мистический боевой мех — \"Фазон\". Никто не останется в безопасности!"
	icon_state = "phazonprize"

/obj/item/toy/prize/phazon/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка меха \"Фазон\"",
		GENITIVE = "фигурки меха \"Фазон\"",
		DATIVE = "фигурке меха \"Фазон\"",
		ACCUSATIVE = "фигурку меха \"Фазон\"",
		INSTRUMENTAL = "фигуркой меха \"Фазон\"",
		PREPOSITIONAL = "фигурке меха \"Фазон\"",
	)

// MARK: Owl and griffin
/obj/item/toy/owl
	name = "owl action figure"
	desc = "Фигурка, созданная по образу \"Совы\", защитницы справедливости."
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/owl/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка \"супергерой Сова\"",
		GENITIVE = "фигурки \"супергерой Сова\"",
		DATIVE = "фигурке \"супергерой Сова\"",
		ACCUSATIVE = "фигурку \"супергерой Сова\"",
		INSTRUMENTAL = "фигуркой \"супергерой Сова\"",
		PREPOSITIONAL = "фигурке \"супергерой Сова\"",
	)

/obj/item/toy/owl/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/message = pick("На этот раз тебе не уйти, Грифон!", "Стой, преступник!", "Ух! Ух!", "Я — ночь!")
	to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
	playsound(user, 'sound/creatures/hoot.ogg', 25, TRUE)
	user.visible_message(span_danger("[get_examine_icon(viewers(user))] [message]"))

	COOLDOWN_START(src, cooldown, 3 SECONDS)
	return TRUE

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "Фигурка, созданная по образу и подобию \"Грифона\", криминального гения."
	icon_state = "griffinprize"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/griffin/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка \"суперзлодей Грифон\"",
		GENITIVE = "фигурки \"суперзлодей Грифон\"",
		DATIVE = "фигурке \"суперзлодей Грифон\"",
		ACCUSATIVE = "фигурку \"суперзлодей Грифон\"",
		INSTRUMENTAL = "фигуркой \"суперзлодей Грифон\"",
		PREPOSITIONAL = "фигурке \"суперзлодей Грифон\"",
	)

/obj/item/toy/griffin/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/message = pick("Ты не остановишь меня, Сова!", "Мой план безупречен! Хранилище моё!", "Карррр!", "Меня никогда не поймаешь!")
	to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
	playsound(user, 'sound/creatures/caw.ogg', 25, TRUE)
	user.visible_message(span_danger("[get_examine_icon(viewers(user))] [message]"))

	COOLDOWN_START(src, cooldown, 3 SECONDS)
	return TRUE


// MARK: DND Character minis
// Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	abstract_type = /obj/item/toy/character
	w_class = WEIGHT_CLASS_SMALL
	pixel_z = 5

/obj/item/toy/character/alien
	name = "Xenomorph Miniature"
	desc = "Миниатюрный ксеноморф. Жуткий!"
	icon_state = "aliencharacter"

/obj/item/toy/character/alien/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра ксеноморфа",
		GENITIVE = "миниатюры ксеноморфа",
		DATIVE = "миниатюре ксеноморфа",
		ACCUSATIVE = "миниатюру ксеноморфа",
		INSTRUMENTAL = "миниатюрой ксеноморфа",
		PREPOSITIONAL = "миниатюре ксеноморфа",
	)

/obj/item/toy/character/cleric
	name = "Cleric Miniature"
	desc = "Крошечный жрец со своим крошечным посохом."
	icon_state = "clericcharacter"

/obj/item/toy/character/cleric/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра жреца",
		GENITIVE = "миниатюры жреца",
		DATIVE = "миниатюре жреца",
		ACCUSATIVE = "миниатюру жреца",
		INSTRUMENTAL = "миниатюрой жреца",
		PREPOSITIONAL = "миниатюре жреца",
	)

/obj/item/toy/character/warrior
	name = "Warrior Miniature"
	desc = "Из этого меча вышла бы неплохая зубочистка."
	icon_state = "warriorcharacter"

/obj/item/toy/character/warrior/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра воина",
		GENITIVE = "миниатюры воина",
		DATIVE = "миниатюре воина",
		ACCUSATIVE = "миниатюру воина",
		INSTRUMENTAL = "миниатюрой воина",
		PREPOSITIONAL = "миниатюре воина",
	)

/obj/item/toy/character/thief
	name = "Thief Miniature"
	desc = "Эй, куда делся мой кошелёк?!"
	icon_state = "thiefcharacter"

/obj/item/toy/character/thief/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра плута",
		GENITIVE = "миниатюры плута",
		DATIVE = "миниатюре плута",
		ACCUSATIVE = "миниатюру плута",
		INSTRUMENTAL = "миниатюрой плута",
		PREPOSITIONAL = "миниатюре плута",
	)

/obj/item/toy/character/wizard
	name = "Wizard Miniature"
	desc = "МАГИЯ!"
	icon_state = "wizardcharacter"

/obj/item/toy/character/wizard/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра волшебника",
		GENITIVE = "миниатюры волшебника",
		DATIVE = "миниатюре волшебника",
		ACCUSATIVE = "миниатюру волшебника",
		INSTRUMENTAL = "миниатюрой волшебника",
		PREPOSITIONAL = "миниатюре волшебника",
	)

/obj/item/toy/character/cthulhu
	name = "Cthulhu Miniature"
	desc = "Тёмный лорд вернулся!"
	icon_state = "darkmastercharacter"

/obj/item/toy/character/cthulhu/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра Ктулху",
		GENITIVE = "миниатюры Ктулху",
		DATIVE = "миниатюре Ктулху",
		ACCUSATIVE = "миниатюру Ктулху",
		INSTRUMENTAL = "миниатюрой Ктулху",
		PREPOSITIONAL = "миниатюре Ктулху",
	)

/obj/item/toy/character/lich
	name = "Lich Miniature"
	desc = "Непревзойденный аннигилятор."
	icon_state = "lichcharacter"

/obj/item/toy/character/lich/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюра лича",
		GENITIVE = "миниатюры лича",
		DATIVE = "миниатюре лича",
		ACCUSATIVE = "миниатюру лича",
		INSTRUMENTAL = "миниатюрой лича",
		PREPOSITIONAL = "миниатюре лича",
	)

/obj/item/storage/box/characters
	name = "Box of Miniatures"
	desc = "Лучшие друзья ботана."

/obj/item/storage/box/characters/get_ru_names()
	return alist(
		NOMINATIVE = "коробка с миниатюрами",
		GENITIVE = "коробки с миниатюрами",
		DATIVE = "коробке с миниатюрами",
		ACCUSATIVE = "коробку с миниатюрами",
		INSTRUMENTAL = "коробкой с миниатюрами",
		PREPOSITIONAL = "коробке с миниатюрами",
	)

/obj/item/storage/box/characters/populate_contents()
	new /obj/item/toy/character/alien(src)
	new /obj/item/toy/character/cleric(src)
	new /obj/item/toy/character/warrior(src)
	new /obj/item/toy/character/thief(src)
	new /obj/item/toy/character/wizard(src)
	new /obj/item/toy/character/cthulhu(src)
	new /obj/item/toy/character/lich(src)

// MARK: Xenomorph action figure
/obj/item/toy/toy_xeno
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA представляет новую фигурку \"Xenos Isolated\"! В комплект входят реалистичные звуковые эффекты. Чтобы активировать их, потяните за шнурок."
	w_class = WEIGHT_CLASS_SMALL
	bubble_icon = "alien"

/obj/item/toy/toy_xeno/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечный ксеноморф",
		GENITIVE = "игрушечного ксеноморфа",
		DATIVE = "игрушечному ксеноморфу",
		ACCUSATIVE = "игрушечного ксеноморфа",
		INSTRUMENTAL = "игрушечным ксеноморфом",
		PREPOSITIONAL = "игрушечном ксеноморфе",
	)

/obj/item/toy/toy_xeno/update_icon_state()
	icon_state = COOLDOWN_FINISHED(src, cooldown) ? initial(icon_state) : "[initial(icon_state)]_used"

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_warning("Верёвка [declent_ru(GENITIVE)] еще не замоталась!"))
		return FALSE

	user.visible_message(span_notice("[user] дергает[PLUR_ET_YUT(user)] верёвку на [declent_ru(PREPOSITIONAL)]."))
	COOLDOWN_START(src, cooldown, 5 SECONDS)
	update_icon(UPDATE_ICON_STATE)

	addtimer(CALLBACK(src, PROC_REF(play_hiss)), 0.5 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(reset_icon)), 5 SECONDS)
	return TRUE

/obj/item/toy/toy_xeno/proc/play_hiss()
	if(COOLDOWN_FINISHED(src, cooldown))
		return

	atom_say("Hiss!")
	var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
	playsound(get_turf(src), pick(possible_sounds), 50, TRUE)

/obj/item/toy/toy_xeno/proc/reset_icon()
	update_icon(UPDATE_ICON_STATE)

// MARK: Action figures
/obj/random/figure
	abstract_type = /obj/item/toy/figure
	name = "Random Action Figure"
	desc = "This is a random toy action figure"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"

/obj/random/figure/item_to_spawn()
	return pick(valid_subtypesof(/obj/item/toy/figure))

/obj/item/toy/figure
	abstract_type = /obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "Бренд \"Space Life\"... погодите, что это вообще за штука?"
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_SMALL
	var/toysay = "Чё за хуйню вы натворили?"

/obj/item/toy/figure/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка неустановленного персонажа",
		GENITIVE = "фигурки неустановленного персонажа",
		DATIVE = "фигурке неустановленного персонажа",
		ACCUSATIVE = "фигурку неустановленного персонажа",
		INSTRUMENTAL = "фигуркой неустановленного персонажа",
		PREPOSITIONAL = "фигурке неустановленного персонажа",
	)

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит \"[toysay]\"."))
	playsound(user, 'sound/machines/click.ogg', 20, TRUE)

	COOLDOWN_START(src, cooldown, 3 SECONDS)
	return TRUE

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "Вечно страдающий главный врач из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "cmo"
	toysay = "Переключи датчики!"

/obj/item/toy/figure/cmo/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка главного врача",
		GENITIVE = "фигурки главного врача",
		DATIVE = "фигурке главного врача",
		ACCUSATIVE = "фигурку главного врача",
		INSTRUMENTAL = "фигуркой главного врача",
		PREPOSITIONAL = "фигурке главного врача",
	)

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "Безликий и безволосый кошмар станции из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "assistant"
	toysay = "Грейтайд един!"

/obj/item/toy/figure/assistant/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка ассистента",
		GENITIVE = "фигурки ассистента",
		DATIVE = "фигурке ассистента",
		ACCUSATIVE = "фигурку ассистента",
		INSTRUMENTAL = "фигуркой ассистента",
		PREPOSITIONAL = "фигурке ассистента",
	)

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "Верный атмосферный техник из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "atmos"
	toysay = "Слава Атмосии!"

/obj/item/toy/figure/atmos/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка атмосферного специалиста",
		GENITIVE = "фигурки атмосферного специалиста",
		DATIVE = "фигурке атмосферного специалиста",
		ACCUSATIVE = "фигурку атмосферного специалиста",
		INSTRUMENTAL = "фигуркой атмосферного специалиста",
		PREPOSITIONAL = "фигурке атмосферного специалиста",
	)

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "Очаровательный бармен из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "bartender"
	toysay = "Где моя обезьяна?"

/obj/item/toy/figure/bartender/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка бармена",
		GENITIVE = "фигурки бармена",
		DATIVE = "фигурке бармена",
		ACCUSATIVE = "фигурку бармена",
		INSTRUMENTAL = "фигуркой бармена",
		PREPOSITIONAL = "фигурке бармена",
	)

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	desc = "Киборг с железной волей из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "borg"
	toysay = "Я. СНОВА. ЖИВОЙ."

/obj/item/toy/figure/borg/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка киборга",
		GENITIVE = "фигурки киборга",
		DATIVE = "фигурке киборга",
		ACCUSATIVE = "фигурку киборга",
		INSTRUMENTAL = "фигуркой киборга",
		PREPOSITIONAL = "фигурке киборга",
	)

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	desc = "Ботаник-наркоман из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "botanist"
	toysay = "Чувак, я вижу цвета..."

/obj/item/toy/figure/botanist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка ботаника",
		GENITIVE = "фигурки ботаника",
		DATIVE = "фигурке ботаника",
		ACCUSATIVE = "фигурку ботаника",
		INSTRUMENTAL = "фигуркой ботаника",
		PREPOSITIONAL = "фигурке ботаника",
	)

/obj/item/toy/figure/captain
	name = "Captain action figure"
	desc = "Некомпетентный капитан из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "captain"
	toysay = "Экипаж, ядерный диск в безопасности, он у меня в трусах!"

/obj/item/toy/figure/captain/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка капитана",
		GENITIVE = "фигурки капитана",
		DATIVE = "фигурке капитана",
		ACCUSATIVE = "фигурку капитана",
		INSTRUMENTAL = "фигуркой капитана",
		PREPOSITIONAL = "фигурке капитане",
	)

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "Трудолюбивый грузчик из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "cargotech"
	toysay = "За Каргонию!"

/obj/item/toy/figure/cargotech/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка грузчика",
		GENITIVE = "фигурки грузчика",
		DATIVE = "фигурке грузчика",
		ACCUSATIVE = "фигурку грузчика",
		INSTRUMENTAL = "фигуркой грузчика",
		PREPOSITIONAL = "фигурке грузчика",
	)

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "Умелый главный инженер из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "ce"
	toysay = "Подключите соляры!"

/obj/item/toy/figure/ce/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка главного инженера",
		GENITIVE = "фигурки главного инженера",
		DATIVE = "фигурке главного инженера",
		ACCUSATIVE = "фигурку главного инженера",
		INSTRUMENTAL = "фигуркой главного инженера",
		PREPOSITIONAL = "фигурке главного инженера",
	)

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "Одержимый священник из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "chaplain"
	toysay = "Боги, сделайте меня машиной для убийств!"

/obj/item/toy/figure/chaplain/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка священника",
		GENITIVE = "фигурки священника",
		DATIVE = "фигурке священника",
		ACCUSATIVE = "фигурку священника",
		INSTRUMENTAL = "фигуркой священника",
		PREPOSITIONAL = "фигурке священника",
	)

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "Повар-каннибал из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "chef"
	toysay = "Клянусь, это не человечина."

/obj/item/toy/figure/chef/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка повара",
		GENITIVE = "фигурки повара",
		DATIVE = "фигурке повара",
		ACCUSATIVE = "фигурку повара",
		INSTRUMENTAL = "фигуркой повара",
		PREPOSITIONAL = "фигурке повара",
	)

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	desc = "Незаконный химик из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "chemist"
	toysay = "Забери свои таблетки!"

/obj/item/toy/figure/chemist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка химика",
		GENITIVE = "фигурки химика",
		DATIVE = "фигурке химика",
		ACCUSATIVE = "фигурку химика",
		INSTRUMENTAL = "фигуркой химика",
		PREPOSITIONAL = "фигурке химика",
	)

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "Озорной клоун из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "clown"
	toysay = "Хонк!"

/obj/item/toy/figure/clown/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка клоуна",
		GENITIVE = "фигурки клоуна",
		DATIVE = "фигурке клоуна",
		ACCUSATIVE = "фигурку клоуна",
		INSTRUMENTAL = "фигуркой клоуна",
		PREPOSITIONAL = "фигурке клоуна",
	)

/obj/item/toy/figure/ian
	name = "Ian action figure"
	desc = "Очаровательный корги из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "ian"
	toysay = "Гав!"

/obj/item/toy/figure/ian/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка Иана",
		GENITIVE = "фигурки Иана",
		DATIVE = "фигурке Иана",
		ACCUSATIVE = "фигурку Иана",
		INSTRUMENTAL = "фигуркой Иана",
		PREPOSITIONAL = "фигурке Иана",
	)

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "Гениальный детектив из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "detective"
	toysay = "На этом шлюзе есть следы серого комбинезона и изоляционных перчаток."

/obj/item/toy/figure/detective/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка детектива",
		GENITIVE = "фигурки детектива",
		DATIVE = "фигурке детектива",
		ACCUSATIVE = "фигурку детектива",
		INSTRUMENTAL = "фигуркой детектива",
		PREPOSITIONAL = "фигурке детектива",
	)

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	desc = "Это персонаж из сериала \"Отряд смерти\", в котором безбашенные офицеры отряда быстрого реагирования противостоят угрозам, \
			исходящим из всех уголков галактики! Входит в коллекцию фигурок SS12 от \"Space life\"."
	icon_state = "dsquad"
	toysay = "Уничтожить все угрозы!"

/obj/item/toy/figure/dsquad/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка офицера \"Отряда смерти\"",
		GENITIVE = "фигурки офицера \"Отряда смерти\"",
		DATIVE = "фигурке офицера \"Отряда смерти\"",
		ACCUSATIVE = "фигурку офицера \"Отряда смерти\"",
		INSTRUMENTAL = "фигуркой офицера \"Отряда смерти\"",
		PREPOSITIONAL = "фигурке офицера \"Отряда смерти\"",
	)

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "Сумасшедший инженер из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "engineer"
	toysay = "О боже, сингулярность сбежала!"

/obj/item/toy/figure/engineer/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка инженера",
		GENITIVE = "фигурки инженера",
		DATIVE = "фигурке инженера",
		ACCUSATIVE = "фигурку инженера",
		INSTRUMENTAL = "фигуркой инженера",
		PREPOSITIONAL = "фигурке инженера",
	)

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "Лысеющий генетик из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "geneticist"
	toysay = "Я не квалифицирован для этой работы."

/obj/item/toy/figure/geneticist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка генетика",
		GENITIVE = "фигурки генетика",
		DATIVE = "фигурке генетика",
		ACCUSATIVE = "фигурку генетика",
		INSTRUMENTAL = "фигуркой генетика",
		PREPOSITIONAL = "фигурке генетика",
	)

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	desc = "Назойливый глава персонала из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "hop"
	toysay = "Бумаги, пожалуйста!"

/obj/item/toy/figure/hop/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка главы персонала",
		GENITIVE = "фигурки главы персонала",
		DATIVE = "фигурке главы персонала",
		ACCUSATIVE = "фигурку главы персонала",
		INSTRUMENTAL = "фигуркой главы персонала",
		PREPOSITIONAL = "фигурке главы персонала",
	)

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "Кровожадный глава службы безопасности из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "hos"
	toysay = "Космозакон? Чего?"

/obj/item/toy/figure/hos/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка главы службы безопасности",
		GENITIVE = "фигурки главы службы безопасности",
		DATIVE = "фигурке главы службы безопасности",
		ACCUSATIVE = "фигурку главы службы безопасности",
		INSTRUMENTAL = "фигуркой главы службы безопасности",
		PREPOSITIONAL = "фигурке главы службы безопасности",
	)

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "Националистичный квартирмейстер из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "qm"
	toysay = "Хайль Каргония!"

/obj/item/toy/figure/qm/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка квартирмейстера",
		GENITIVE = "фигурки квартирмейстера",
		DATIVE = "фигурке квартирмейстера",
		ACCUSATIVE = "фигурку квартирмейстера",
		INSTRUMENTAL = "фигуркой квартирмейстера",
		PREPOSITIONAL = "фигурке квартирмейстера",
	)

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "Грязный уборщик из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "janitor"
	toysay = "Читай знаки, идиот."

/obj/item/toy/figure/janitor/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка уборщика",
		GENITIVE = "фигурки уборщика",
		DATIVE = "фигурке уборщика",
		ACCUSATIVE = "фигурку уборщика",
		INSTRUMENTAL = "фигуркой уборщика",
		PREPOSITIONAL = "фигурке уборщика",
	)

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	desc = "Недооцененный юрист из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "lawyer"
	toysay = "СРП говорит, что они виновны! Взлом — доказательство того, что они враги корпорации!"

/obj/item/toy/figure/lawyer/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка адвоката",
		GENITIVE = "фигурки адвоката",
		DATIVE = "фигурке адвоката",
		ACCUSATIVE = "фигурку адвоката",
		INSTRUMENTAL = "фигуркой адвоката",
		PREPOSITIONAL = "фигурке адвоката",
	)

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "Тихий библиотекарь из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "librarian"
	toysay = "Однажды, в..."

/obj/item/toy/figure/librarian/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка библиотекаря",
		GENITIVE = "фигурки библиотекаря",
		DATIVE = "фигурке библиотекаря",
		ACCUSATIVE = "фигурку библиотекаря",
		INSTRUMENTAL = "фигуркой библиотекаря",
		PREPOSITIONAL = "фигурке библиотекаря",
	)

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "Утомленный врач из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "md"
	toysay = "Пациент уже мёртв!"

/obj/item/toy/figure/md/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка врача",
		GENITIVE = "фигурки врача",
		DATIVE = "фигурке врача",
		ACCUSATIVE = "фигурку врача",
		INSTRUMENTAL = "фигуркой врача",
		PREPOSITIONAL = "фигурке врача",
	)

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "... из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/mime/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка мима",
		GENITIVE = "фигурки мима",
		DATIVE = "фигурке мима",
		ACCUSATIVE = "фигурку мима",
		INSTRUMENTAL = "фигуркой мима",
		PREPOSITIONAL = "фигурке мима",
	)

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "Вооруженный до зубов шахтёр из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "miner"
	toysay = "О боже, оно жрёт мои кишки!"

/obj/item/toy/figure/miner/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка шахтёра",
		GENITIVE = "фигурки шахтёра",
		DATIVE = "фигурке шахтёра",
		ACCUSATIVE = "фигурку шахтёра",
		INSTRUMENTAL = "фигуркой шахтёра",
		PREPOSITIONAL = "фигурке шахтёра",
	)

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	desc = "Это таинственный ниндзя! Входит в коллекцию фигурок SS12 от \"Space life\"."
	icon_state = "ninja"
	toysay = "О боже! Хватит стрелять, я косплеер!"

/obj/item/toy/figure/ninja/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка ниндзи",
		GENITIVE = "фигурки ниндзи",
		DATIVE = "фигурке ниндзи",
		ACCUSATIVE = "фигурку ниндзи",
		INSTRUMENTAL = "фигуркой ниндзи",
		PREPOSITIONAL = "фигурке ниндзи",
	)

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "Это тот самый смертоносный волшебник, метающий заклинания! Входит в коллекцию фигурок SS12 от \"Space life\"."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/wizard/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка мага",
		GENITIVE = "фигурки мага",
		DATIVE = "фигурке мага",
		ACCUSATIVE = "фигурку мага",
		INSTRUMENTAL = "фигуркой мага",
		PREPOSITIONAL = "фигурке мага",
	)

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	desc = "Амбициозный директор исследований из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "rd"
	toysay = "Уничтожить всех боргов!"

/obj/item/toy/figure/rd/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка директора исследований",
		GENITIVE = "фигурки директора исследований",
		DATIVE = "фигурке директора исследований",
		ACCUSATIVE = "фигурку директора исследований",
		INSTRUMENTAL = "фигуркой директора исследований",
		PREPOSITIONAL = "фигурке директора исследований",
	)

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "Искусный робототехник из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "roboticist"
	toysay = "Он сам просил боргизацию!"

/obj/item/toy/figure/roboticist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка робототехника",
		GENITIVE = "фигурки робототехника",
		DATIVE = "фигурке робототехника",
		ACCUSATIVE = "фигурку робототехника",
		INSTRUMENTAL = "фигуркой робототехника",
		PREPOSITIONAL = "фигурке робототехника",
	)

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "Безумный учёный из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "scientist"
	toysay = "Кто-то другой сделал эти бомбы!"

/obj/item/toy/figure/scientist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка учёного",
		GENITIVE = "фигурки учёного",
		DATIVE = "фигурке учёного",
		ACCUSATIVE = "фигурку учёного",
		INSTRUMENTAL = "фигуркой учёного",
		PREPOSITIONAL = "фигурке учёного",
	)

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	desc = "Это ядерный оперативник в кроваво-красном костюме! Входит в коллекцию фигурок SS12 от \"Space life\"."
	icon_state = "syndie"
	toysay = "Заберите этот ёбанный диск!"

/obj/item/toy/figure/syndie/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка ядерного оперативника",
		GENITIVE = "фигурки ядерного оперативника",
		DATIVE = "фигурке ядерного оперативника",
		ACCUSATIVE = "фигурку ядерного оперативника",
		INSTRUMENTAL = "фигуркой ядерного оперативника",
		PREPOSITIONAL = "фигурке ядерного оперативника",
	)

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "Злоупотребляющий властью офицер службы безопасности из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "secofficer"
	toysay = "Я есть закон!"

/obj/item/toy/figure/secofficer/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка офицера службы безопасности",
		GENITIVE = "фигурки офицера службы безопасности",
		DATIVE = "фигурке офицера службы безопасности",
		ACCUSATIVE = "фигурку офицера службы безопасности",
		INSTRUMENTAL = "фигуркой офицера службы безопасности",
		PREPOSITIONAL = "фигурке офицера службы безопасности",
	)

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	desc = "Заразный вирусолог из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "virologist"
	toysay = "Это не мой вирус!"

/obj/item/toy/figure/virologist/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка вирусолога",
		GENITIVE = "фигурки вирусолога",
		DATIVE = "фигурке вирусолога",
		ACCUSATIVE = "фигурку вирусолога",
		INSTRUMENTAL = "фигуркой вирусолога",
		PREPOSITIONAL = "фигурке вирусолога",
	)

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "Забывчивый смотритель из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "warden"
	toysay = "Казнить за взлом!"

/obj/item/toy/figure/warden/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка смотрителя",
		GENITIVE = "фигурки смотрителя",
		DATIVE = "фигурке смотрителя",
		ACCUSATIVE = "фигурку смотрителя",
		INSTRUMENTAL = "фигуркой смотрителя",
		PREPOSITIONAL = "фигурке смотрителя",
	)

/obj/item/toy/figure/magistrate
	name = "Magistrate action figure"
	desc = "Справедливый магистрат из коллекции фигурок SS12 от \"Space life\"."
	icon_state = "magistrate"
	toysay = "Казнить или не казнить — вот в чём вопрос."

/obj/item/toy/figure/magistrate/get_ru_names()
	return alist(
		NOMINATIVE = "фигурка магистрата",
		GENITIVE = "фигурки магистрата",
		DATIVE = "фигурке магистрата",
		ACCUSATIVE = "фигурку магистрата",
		INSTRUMENTAL = "фигуркой магистрата",
		PREPOSITIONAL = "фигурке магистрата",
	)
