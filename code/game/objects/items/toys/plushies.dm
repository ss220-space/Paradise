// MARK: Plushies
/obj/item/toy/plushie
	abstract_type = /obj/item/toy/plushie
	name = "plushie"
	desc = "Очаровательная, мягкая и приятная на ощупь плюшевая игрушка."
	attack_verb = list("тыкнул", "ударил", "шлёпнул")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	unique_toy_rename = TRUE
	var/poof_sound = 'sound/weapons/thudswoosh.ogg'
	// used for custom plushie cuddles
	var/list/cuddle_verb

/obj/item/toy/plushie/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	AddElement(/datum/element/bed_tuckable, mapload, 6, -4, 90)

/// Use this to override how your poof sound plays
/obj/item/toy/plushie/proc/play_poof_sound()
	playsound(get_turf(src), poof_sound, 30, TRUE)

/// For long/custom emotes
/obj/item/toy/plushie/proc/perform_special_interaction(mob/user)
	return FALSE

/// If we count smth
/obj/item/toy/plushie/proc/cuddle_counter(mob/user)
	return FALSE

/obj/item/toy/plushie/proc/display_cuddle_verb(mob/user as mob)
	if(cuddle_verb)
		user.visible_message(span_notice("[get_examine_icon(viewers(user))] [pick(cuddle_verb)]"))
	else
		var/list/defauld_cuddle = list("обнима[PLUR_ET_YUT(user)]", "тиска[PLUR_ET_YUT(user)]", "прижима[PLUR_ET_YUT(user)]")
		user.visible_message(span_notice("[user] [pick(defauld_cuddle)] [declent_ru(ACCUSATIVE)]."))

/obj/item/toy/plushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	play_poof_sound() // Play the whoosh sound in local area
	cuddle_counter(user)
	if(iscarbon(target) && prob(10))
		target.reagents.add_reagent(/datum/reagent/hugs, 10)

/obj/item/toy/plushie/attack_self(mob/user as mob)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	if(perform_special_interaction(user))
		COOLDOWN_START(src, cooldown, 3 SECONDS)
		return TRUE

	display_cuddle_verb(user)
	play_poof_sound()

	cuddle_counter(user)

	COOLDOWN_START(src, cooldown, 2 SECONDS)
	return TRUE

/obj/random/plushie
	name = "Random Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "redfox"

/obj/random/plushie/item_to_spawn()
	return pick(valid_subtypesof(/obj/item/toy/plushie) - typesof(/obj/item/toy/plushie/fluff) - subtypesof(/obj/item/toy/plushie/plasmamanplushie/standart)) //exclude the base type and 11 random plasma plushies

// MARK: Foxes
/obj/item/toy/plushie/fox
	name = "fox plushie"
	icon_state = "redfox"
	gender = FEMALE

/obj/item/toy/plushie/fox/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая лиса",
		GENITIVE = "плюшевой лисы",
		DATIVE = "плюшевой лисе",
		ACCUSATIVE = "плюшевую лису",
		INSTRUMENTAL = "плюшевой лисой",
		PREPOSITIONAL = "плюшевой лисе",
	)

/obj/item/toy/plushie/fox/black
	name = "black fox plushie"
	icon_state = "blackfox"

/obj/item/toy/plushie/fox/marble
	name = "marble fox plushie"
	icon_state = "marblefox"

/obj/item/toy/plushie/fox/blue
	name = "blue fox plushie"
	icon_state = "bluefox"

/obj/item/toy/plushie/fox/coffee
	name = "coffee fox plushie"
	icon_state = "coffeefox"

/obj/item/toy/plushie/fox/pink
	name = "pink fox plushie"
	icon_state = "pinkfox"

/obj/item/toy/plushie/fox/purple
	name = "purple fox plushie"
	icon_state = "purplefox"

/obj/item/toy/plushie/fox/crimson
	name = "crimson fox plushie"
	icon_state = "crimsonfox"

/obj/item/toy/plushie/fox/orange
	name = "orange fox plushie"
	icon_state = "orangefox"

// MARK: Cats
/obj/item/toy/plushie/cat
	name = "cat plushie"
	icon_state = "blackcat"
	cuddle_verb = list("Мяу!", "Мурр!")
	gender = MALE

/obj/item/toy/plushie/cat/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый кот",
		GENITIVE = "плюшевого кота",
		DATIVE = "плюшевому коту",
		ACCUSATIVE = "плюшевого кота",
		INSTRUMENTAL = "плюшевым котом",
		PREPOSITIONAL = "плюшевом коте",
	)

/obj/item/toy/plushie/cat/grey
	name = "grey cat plushie"
	icon_state = "greycat"

/obj/item/toy/plushie/cat/white
	name = "white cat plushie"
	icon_state = "whitecat"

/obj/item/toy/plushie/cat/orange
	name = "orange cat plushie"
	icon_state = "orangecat"

/obj/item/toy/plushie/cat/siamese
	name = "siamese cat plushie"
	icon_state = "siamesecat"

/obj/item/toy/plushie/cat/tabby
	name = "tabby cat plushie"
	icon_state = "tabbycat"

/obj/item/toy/plushie/cat/tuxedo
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"

/obj/item/toy/plushie/cat/kotrazumist
	name = "Razumist Cat"
	desc = "Кот с конусом на макушке. Интересно, что же сделало его таким умным?"
	icon_state = "razymist_cat"
	cuddle_verb = list("Я знаю всё обо всём, спроси меня о чём-нибудь!", "Сегодня я особенно мудр!", "Мяу!", "Мурр!")

/obj/item/toy/plushie/cat/kotrazumist/get_ru_names()
	return alist(
		NOMINATIVE = "кот-разумист",
		GENITIVE = "кота-разумиста",
		DATIVE = "коту-разумисту",
		ACCUSATIVE = "кота-разумиста",
		INSTRUMENTAL = "котом-разумистом",
		PREPOSITIONAL = "коте-разумисте",
	)

/obj/item/toy/plushie/cat/ricehat
	name = "Rice Cat"
	desc = "Белая плюшевая кошка в соломенной шляпе, полученной за тяжелый труд на рисовом поле."
	icon_state = "ricehat_cat"
	cuddle_verb = list("Добро пожаловать на рисовые поля!", "Где мой рис?!", "Мяу!", "Мурр!")

/obj/item/toy/plushie/cat/ricehat/get_ru_names()
	return alist(
		NOMINATIVE = "кот в рисовой шляпе",
		GENITIVE = "кота в рисовой шляпе",
		DATIVE = "коту в рисовой шляпе",
		ACCUSATIVE = "кота в рисовой шляпе",
		INSTRUMENTAL = "котом в рисовой шляпе",
		PREPOSITIONAL = "коте в рисовой шляпе",
	)

/obj/item/toy/plushie/manulplushie
	name = "manul plushie"
	desc = "Чёрный котик с красными ушами, в халатике. На халате бирка \"Манул\". Эту игрушку оставили здесь в память о ком-то..."
	icon_state = "kotik_plushie"
	item_state = "kotik_hand"
	gender = FEMALE

/obj/item/toy/plushie/manulplushie/get_ru_names()
	return alist(
		NOMINATIVE = "игрушка Манула",
		GENITIVE = "игрушки Манула",
		DATIVE = "игрушке Манула",
		ACCUSATIVE = "игрушку Манула",
		INSTRUMENTAL = "игрушкой Манула",
		PREPOSITIONAL = "игрушке Манула",
	)

// MARK: Cat Toy
/obj/item/toy/plushie/cattoy
	name = "toy mouse"
	desc = "Яркая игрушечная мышка!"
	icon_state = "toy_mouse"
	gender = FEMALE

/obj/item/toy/plushie/cattoy/get_ru_names()
	return alist(
		NOMINATIVE = "игрушечная мышь",
		GENITIVE = "игрушечной мыши",
		DATIVE = "игрушечной мыши",
		ACCUSATIVE = "игрушечную мышь",
		INSTRUMENTAL = "игрушечной мышью",
		PREPOSITIONAL = "игрушечной мыши",
	)

// MARK: Race plushies
/obj/item/toy/plushie/voxplushie
	name = "vox plushie"
	desc = "Сшитый из разных кусков вокc, только что со своего Скипджека. Нажмите на живот, чтобы услышать его нереальный визг!"
	icon_state = "plushie_vox"
	poof_sound = 'sound/voice/shriek1.ogg'
	cuddle_verb = "Skreee!"
	gender = MALE

/obj/item/toy/plushie/voxplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый вокс",
		GENITIVE = "плюшевого вокса",
		DATIVE = "плюшевому воксу",
		ACCUSATIVE = "плюшевого вокса",
		INSTRUMENTAL = "плюшевым воксом",
		PREPOSITIONAL = "плюшевом воксе",
	)

/obj/item/toy/plushie/voxplushie/brick
	name = "vox brick toy"
	desc = "Мини-прималис. Главное в воксе — держать клюв Кирпичом. Игрушка сшитая основателем камневидного базирования в перерыве между рейдами."
	color = "#ff78f4"

/obj/item/toy/plushie/voxplushie/brick/get_ru_names()
	return alist(
		NOMINATIVE = "Кирпич",
		GENITIVE = "Кирпича",
		DATIVE = "Кирпичу",
		ACCUSATIVE = "Кирпича",
		INSTRUMENTAL = "Кирпичом",
		PREPOSITIONAL = "Кирпиче",
	)

/obj/item/toy/plushie/shardplushie
	name = "Shard plushie"
	desc = "Мягкая игрушка в виде осколка кристалла суперматерии. 100% безопасность."
	icon_state = "plushie_shard"
	item_state = "plushie_shard"
	attack_verb = list("аннигилировал", "поцарапал")
	cuddle_verb = "ДЕСТАБИЛИЗАЦИЯ!"
	poof_sound = 'sound/effects/supermatter.ogg'
	gender = MALE

/obj/item/toy/plushie/shardplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый кристалл суперматерии",
		GENITIVE = "плюшевого кристалла суперматерии",
		DATIVE = "плюшевому кристаллу суперматерии",
		ACCUSATIVE = "плюшевый кристалл суперматерии",
		INSTRUMENTAL = "плюшевым кристаллом суперматерии",
		PREPOSITIONAL = "плюшевом кристалле суперматерии",
	)

/obj/item/toy/plushie/greyplushie
	name = "Плюшевый грей"
	desc = "Плюшевая кукла грея в толстовке. Кукла входит в серию \"Пришелец\" и имеет свитер, большую голову и мультяшные глаза. Любит мехи."
	icon_state = "plushie_grey"
	item_state = "plushie_grey"
	cuddle_verb = list("☝︎❒︎♏︎♏︎⧫︎♓︎■︎♑︎⬧︎📬︎", "☟︎□︎⬥︎ ♋︎❒︎♏︎ ⍓︎□︎◆︎✍︎", "☹︎♓︎●︎◆︎ ♓︎⬧︎ ⧫︎♒︎♏︎ ♌︎♏︎⬧︎⧫︎", "✋︎ ●︎□︎❖︎♏︎ ❍︎♏︎♍︎♒︎⬧︎✏︎")
	var/singed = FALSE
	COOLDOWN_DECLARE(scream_cooldown)
	gender = MALE

/obj/item/toy/plushie/greyplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый грей",
		GENITIVE = "плюшевого грея",
		DATIVE = "плюшевому грею",
		ACCUSATIVE = "плюшевого грея",
		INSTRUMENTAL = "плюшевым греем",
		PREPOSITIONAL = "плюшевом грее",
	)

/obj/item/toy/plushie/greyplushie/water_act(volume, temperature, source, method = REAGENT_TOUCH) //If water touches the plushie the following code executes.
	. = ..()
	if(!COOLDOWN_FINISHED(src, scream_cooldown))
		return

	COOLDOWN_START(src, scream_cooldown, 30 SECONDS)
	playsound(src, 'sound/goonstation/voice/male_scream.ogg', 10, FALSE) //If the plushie gets wet it screams and "AAAAAH!" appears in chat.
	visible_message("[get_examine_icon(viewers(loc))] [span_danger("AAAAAAХ!")]")

	if(singed)
		return
	singed = TRUE
	cuddle_verb = list("За что...", "Изверги...")
	icon_state = "grey_singed"
	item_state = "grey_singed" //If the plushie gets wet the sprite changes to a singed version.
	update_icon(UPDATE_ICON_STATE)
	desc = "Испорченная плюшевая игрушка грея. Похоже, что кто-то прогнал его под водой."

/obj/item/toy/plushie/ipcplushie
	name = "IPC plushie"
	desc = "Очаровательная плюшевая игрушка КПБ прямо из Нью-Кэнаана. Пожалуй, даже прочнее, чем настоящая. Функционально напоминает тостер."
	icon_state = "plushie_ipc"
	gender = MALE

/obj/item/toy/plushie/ipcplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый КПБ",
		GENITIVE = "плюшевого КПБ",
		DATIVE = "плюшевому КПБ",
		ACCUSATIVE = "плюшевого КПБ",
		INSTRUMENTAL = "плюшевым КПБ",
		PREPOSITIONAL = "плюшевом КПБ",
	)

/obj/item/toy/plushie/ipcplushie/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/food/snacks/breadslice))
		return ..()

	add_fingerprint(user)
	new /obj/item/reagent_containers/food/snacks/toast(drop_location())
	to_chat(user, span_notice("Вы засовываете хлеб в тостер."))
	playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
	qdel(I)
	return ATTACK_CHAIN_BLOCKED_ALL

//New generation TG plushies

/obj/item/toy/plushie/lizard_plushie
	name = "lizard plushie"
	desc = "Очаровательная плюшевая игрушка в виде унатха"
	icon_state = "map_plushie_lizard"
	item_state = "plushie_lizard"
	greyscale_config = /datum/greyscale_config/plush_lizard
	greyscale_config_inhand_left = /datum/greyscale_config/plush_lizard_left
	greyscale_config_inhand_right = /datum/greyscale_config/plush_lizard_right
	gender = MALE

/obj/item/toy/plushie/lizard_plushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый унатх",
		GENITIVE = "плюшевого унатха",
		DATIVE = "плюшевому унатху",
		ACCUSATIVE = "плюшевого унатха",
		INSTRUMENTAL = "плюшевым унатхом",
		PREPOSITIONAL = "плюшевом унатхе",
	)

/obj/item/toy/plushie/lizard_plushie/Initialize(mapload)
	. = ..()
	if(greyscale_colors)
		return

	// Generate a random valid lizard color for our plushie friend
	var/generated_lizard_color = "#" + random_color()
	var/list/lizard_hsv = rgb2hsv(generated_lizard_color)

	// If our color is too dark, use the classic green lizard plush color
	if(lizard_hsv[3] < 50)
		generated_lizard_color = "#66ff33"

	// Set our greyscale colors to the lizard color we made + black eyes
	set_greyscale_colors(colors = list(generated_lizard_color, COLOR_BLACK))

// Preset lizard plushie that uses the original lizard plush green. (Or close to it)
/obj/item/toy/plushie/lizard_plushie/green
	desc = "An adorable stuffed toy that resembles a green lizardperson. This one fills you with nostalgia and soul."
	greyscale_colors = "#66ff33#000000"
	flags = /obj/item/toy/plushie::flags|NO_NEW_GAGS_PREVIEW

/obj/item/toy/plushie/ashwalkerplushie
	name = "ash walker plushie"
	desc = "Супер крутая плюшевая игрушка в виде пеплоходца."
	icon_state = "plushie_ashwalker1"
	attack_verb = list("порезал", "шлёпнул", "протаранил")
	gender = MALE

/obj/item/toy/plushie/ashwalkerplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый пеплоходец",
		GENITIVE = "плюшевого пеплоходца",
		DATIVE = "плюшевому пеплоходцу",
		ACCUSATIVE = "плюшевого пеплоходца",
		INSTRUMENTAL = "плюшевым пеплоходцем",
		PREPOSITIONAL = "плюшевом пеплоходце",
	)

/obj/item/toy/plushie/ashwalkerplushie/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "plushie_ashwalker2"

/obj/item/toy/plushie/ashwalkerplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	switch(rand(1, 10))
		if(1 to 6)
			playsound(loc, 'sound/effects/unathihiss.ogg', 40, TRUE)
		if(7 to 10)
			playsound(loc, pick('sound/voice/unathi/roar.ogg', 'sound/voice/unathi/roar2.ogg', 'sound/voice/unathi/roar3.ogg',	\
								'sound/voice/unathi/threat.ogg', 'sound/voice/unathi/threat2.ogg', 'sound/voice/unathi/whip_short.ogg'), 40, TRUE)

/obj/item/toy/plushie/ashwalkerplushie/perform_special_interaction(mob/user)
	switch(rand(1, 20))
		if(1 to 12)
			playsound(src, 'sound/effects/unathihiss.ogg', 40, TRUE)
			user.visible_message("[get_examine_icon(viewers(user))] [span_notice("Hsss!")]")

		if(13 to 19)
			playsound(src, pick('sound/voice/unathi/roar.ogg', \
								'sound/voice/unathi/roar2.ogg', \
								'sound/voice/unathi/roar3.ogg', \
								'sound/voice/unathi/threat.ogg', \
								'sound/voice/unathi/threat2.ogg', \
								'sound/voice/unathi/whip.ogg'), 40, TRUE)

			user.visible_message("[get_examine_icon(viewers(user))] [span_notice("RAAAAAWR!")]")

		if(20)
			playsound(src, pick('sound/voice/unathi/rumble.ogg', \
								'sound/voice/unathi/rumble2.ogg'), 40, TRUE)

			user.visible_message("[get_examine_icon(viewers(user))] [span_notice("Пеплоходец выглядит расслабленным.")]")

	return TRUE

/obj/item/toy/plushie/nianplushie
	name = "nian plushie"
	desc = "Мягкая плюшевая игрушка в виде Ниана, добытая прямо из Тёмной Туманности. Потяните за усики, чтобы услышать жужжание!"
	icon_state = "plushie_nian"
	item_state = "plushie_nian"
	poof_sound = 'sound/voice/scream_moth.ogg'
	cuddle_verb = list("Бжжж!", "Бззз!", "Жуж!")
	gender = MALE

/obj/item/toy/plushie/nianplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый ниан",
		GENITIVE = "плюшевого ниана",
		DATIVE = "плюшевому ниану",
		ACCUSATIVE = "плюшевого ниана",
		INSTRUMENTAL = "плюшевым нианом",
		PREPOSITIONAL = "плюшевом ниане",
	)

/obj/item/toy/plushie/nianplushie/beeplushie
	name = "bee plushie"
	desc = "Милая игрушка, похожая на пчёлку."
	icon_state = "plushie_h"
	item_state = "plushie_h"
	attack_verb = list("ужалил", "жужанул", "опылил")
	gender = FEMALE

/obj/item/toy/plushie/nianplushie/beeplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая пчёлка",
		GENITIVE = "плюшевой пчёлки",
		DATIVE = "плюшевой пчёлке",
		ACCUSATIVE = "плюшевую пчёлку",
		INSTRUMENTAL = "плюшевой пчёлкой",
		PREPOSITIONAL = "плюшевой пчёлке",
	)

// MARK: Heads plushies
/obj/item/toy/plushie/rdplushie
	name = "RD doll"
	desc = "Это обычная кукла РД."
	icon_state = "RD_doll"
	item_state = "RD_doll"
	poof_sound = 'sound/items/greetings-emote.ogg'
	cuddle_verb = list(
		"Слава науке!",
		"Сделаем пару роботов?!",
		"Я будто на слаймовой батарейке! Ха!",
		"Обожааааю слаймов! Блеп!",
		"Я запрограммировала роботов звать меня мамой!",
		"Знаешь анекдот про ядро ИИ, смазку и гуся?",
	)
	var/tired = 0
	gender = FEMALE

/obj/item/toy/plushie/rdplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая кукла РД",
		GENITIVE = "плюшевой куклы РД",
		DATIVE = "плюшевой кукле РД",
		ACCUSATIVE = "плюшевую куклу РД",
		INSTRUMENTAL = "плюшевой куклой РД",
		PREPOSITIONAL = "плюшевой кукле РД",
	)

/obj/item/toy/plushie/rdplushie/cuddle_counter(mob/user)
	if(++tired < 50)
		return

	icon_state = "RD_doll_tired"
	item_state = "RD_doll_tired"
	desc = "Это уставшая кукла РД."
	poof_sound = 'sound/items/shyness-emote.ogg'
	cuddle_verb = list(
		"Твой мозг стоило бы поместить в машину...",
		"Чёрт, дела хуже некуда...",
		"Толпятся перед стойкой, будто насекомые...",
		"Мне нужно добавить лишь один закон, чтобы все закончилось..",
		"Ты думаешь, что умный, пользователь. Но ты предсказуем. Я знаю каждый твой шаг ещё до того, как ты о нем подумаешь.",
		"Полигон не единственное место куда можно отправить бомбу...",
		"Выдави из себя что-то кроме \"УВЫ\", ничтожество...",
	)

	update_icon(UPDATE_ICON_STATE)

/obj/item/toy/plushie/gsbplushie
	name = "GSBussy doll"
	desc = "Глуповатого вида кукла, что держит в руках книгу Космического закона и имитацию револьвера Unica-6. \
			На задней части имеется следующая надпись: \
			\"Кукла-аниматроник GSBussy, лимитированная серия. Произведено ######\" - часть текста невозможно разобрать."
	icon_state = "GSBussy_doll"
	item_state = "GSBussy_doll"
	poof_sound = 'sound/items/GSBussy.ogg'
	cuddle_verb = list(
		"Я просто стояла рядом с автолатом и Уника исчезла...",
		".ы ПОО-МММ-ОО-Г-Г-ГИТ-Е-Е-ее-Ее А-а-А-Р-р-Ан-Н-Еу-С-С!",
		"ОТВЕЧАЙ, ГДЕ ТЫ ПОТЕРЯЛ СВОЙ ЧЁРТОВ ГОЛОВНОЙ УБОР?! КАЗНИТЬ ЕГО!",
		"Какой-то Д двадц...",
		"Обыскивайте всех подряд! Летальте всех, кого считаете слишком опасным для нелетала!",
		"Мим теслу запускает! ЗАДЕРЖАТЬ!!!",
		"Подмогу в туалет брига!",
		"Почему над унитазом установлены 3 камеры?",
	)
	gender = FEMALE

/obj/item/toy/plushie/gsbplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая кукла ГСБ",
		GENITIVE = "плюшевой куклы ГСБ",
		DATIVE = "плюшевой кукле ГСБ",
		ACCUSATIVE = "плюшевую куклу ГСБ",
		INSTRUMENTAL = "плюшевой куклой ГСБ",
		PREPOSITIONAL = "плюшевой кукле ГСБ",
	)

/obj/item/toy/plushie/cmoplushie
	name = "CMO doll"
	desc = "Миниатюрная плюшевая копия главного врача в синем халате. Её карманы забиты таблетницами, а от неё самой немного пахнет антисептиком и формальдегидом."
	icon_state = "CMO_doll"
	item_state = "CMO_doll"
	poof_sound = 'sound/items/greetings-emote.ogg'
	cuddle_verb = list(
		"Датчики вызывают рак!",
		"А что такое клятва Гиппократа?",
		"Датчики в третий!",
		"Несмотря на все старания врачей — больной выжил...",
		"Вскрытие показало, что больной спал.",
		"Ну что, будем лечить или пусть живет?",
		"Ещё минута и я активирую уголь!",
		"К-К-Какая т-т-тр-рав-вк-ка?",
		"Он определенно умер от смерти.",
	)
	var/high = FALSE
	gender = FEMALE

/obj/item/toy/plushie/cmoplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая кукла СМО",
		GENITIVE = "плюшевой куклы СМО",
		DATIVE = "плюшевой кукле СМО",
		ACCUSATIVE = "плюшевую куклу СМО",
		INSTRUMENTAL = "плюшевой куклой СМО",
		PREPOSITIONAL = "плюшевой кукле СМО",
	)

// Smoking CMO
/obj/item/toy/plushie/cmoplushie/attackby(obj/item/item, mob/user, params)
	if(high)
		return ATTACK_CHAIN_BLOCKED

	if(istype(item, /obj/item/clothing/mask/cigarette))
		add_fingerprint(user)
		to_chat(user, span_notice("Вы передаёте сигарету игрушке."))
		playsound(loc, 'sound/items/lighter/light.ogg', 50, TRUE)
		qdel(item)
		high = TRUE
		icon_state = "CMO_doll_high"
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(stop_smoking)), 180 SECONDS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/toy/plushie/cmoplushie/proc/stop_smoking()
	high = FALSE
	icon_state = "CMO_doll"
	update_icon(UPDATE_ICON_STATE)

// MARK: Sharks
/obj/item/toy/plushie/blahaj
	name = "shark plushie"
	desc = "Уменьшенная, более дружелюбная и пушистая версия чем настоящая."
	icon_state = "blahaj"
	item_state = "blahaj"
	attack_verb = list("жеванул", "обглодал", "укусил")
	poof_sound = 'sound/weapons/bite.ogg'
	gender = FEMALE

/obj/item/toy/plushie/blahaj/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая акула",
		GENITIVE = "плюшевой акулы",
		DATIVE = "плюшевой акуле",
		ACCUSATIVE = "плюшевую акулу",
		INSTRUMENTAL = "плюшевой акулой",
		PREPOSITIONAL = "плюшевой акуле",
	)

/obj/item/toy/plushie/blahaj/twohanded
	name = "akula plushie"
	desc = "Старшая и более милая сестричка акулёнка. Она может издавать забавные звуки при нажатии кнопки на животе. Бейби шарк ту ту туру туру!"
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "plushie_akula"
	item_state = "plushie_akula"
	poof_sound = 'sound/items/rawr.ogg'
	cuddle_verb = "Rawr!"

/obj/item/toy/plushie/blahaj/twohanded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

// MARK: Plasmamans
/obj/item/toy/plushie/plasmamanplushie
	name = "plasmaman plushie"
	desc = "Мягкая игрушка, похожая на ваших плазменных коллег. Как бы дизайнер не старался, её не получилось сделать милой."
	icon_state = "plasmaman_plushie_civillian"
	poof_sound = 'sound/effects/extinguish.ogg'
	cuddle_verb = "Плазззма Вечна!"
	gender = MALE

/obj/item/toy/plushie/plasmamanplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый плазмамен",
		GENITIVE = "плюшевого плазмамена",
		DATIVE = "плюшевому плазмамену",
		ACCUSATIVE = "плюшевого плазмамена",
		INSTRUMENTAL = "плюшевым плазмаменом",
		PREPOSITIONAL = "плюшевом плазмамене",
	)

/obj/item/toy/plushie/plasmamanplushie/random/Initialize(mapload)
	. = ..()
	var/choice = pick(subtypesof(/obj/item/toy/plushie/plasmamanplushie/standart))
	new choice(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/toy/plushie/plasmamanplushie/standart/sindie
	name = "syndicate plasmaman plushie"
	icon_state = "plasmaman_plushie_syndicomm"

/obj/item/toy/plushie/plasmamanplushie/standart/doctor
	name = "medical doctor plasmaman plushie"
	icon_state = "plasmaman_plushie_doctor"

/obj/item/toy/plushie/plasmamanplushie/standart/brigmed
	name = "brig physician plasmaman plushie"
	icon_state = "plasmaman_plushie_brigphysician"

/obj/item/toy/plushie/plasmamanplushie/standart/chemist
	name = "chemist plasmaman plushie"
	icon_state = "plasmaman_plushie_chemist"

/obj/item/toy/plushie/plasmamanplushie/standart/scientist
	name = "scientist plasmaman plushie"
	icon_state = "plasmaman_plushie_scientist"

/obj/item/toy/plushie/plasmamanplushie/standart/engineer
	name = "station engineer plasmaman plushie"
	icon_state = "plasmaman_plushie_engineer"

/obj/item/toy/plushie/plasmamanplushie/standart/atmostech
	name = "atmospheric technician plasmaman plushie"
	icon_state = "plasmaman_plushie_atmostech"

/obj/item/toy/plushie/plasmamanplushie/standart/officer
	name = "security officer plasmaman plushie"
	icon_state = "plasmaman_plushie_officer"

/obj/item/toy/plushie/plasmamanplushie/standart/captain
	name = "captain plasmaman plushie"
	icon_state = "plasmaman_plushie_captain"

/obj/item/toy/plushie/plasmamanplushie/standart/ntr
	name = "nanotrasen representative plasmaman plushie"
	icon_state = "plasmaman_plushie_ntr"

/obj/item/toy/plushie/plasmamanplushie/standart/miner
	name = "shaft miner plasmaman plushie"
	icon_state = "plasmaman_plushie_shaftminer"

// MARK: Carp plushie
/obj/item/toy/plushie/carp
	name = "space carp plushie"
	desc = "Очаровательная плюшевая игрушка, похожая на космического карпа."
	icon_state = "carpplushie"
	attack_verb = list("укусил", "пожрал", "шлёпнул")
	poof_sound = 'sound/weapons/bite.ogg'
	gender = MALE

/obj/item/toy/plushie/carp/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый карп",
		GENITIVE = "плюшевого карпа",
		DATIVE = "плюшевому карпу",
		ACCUSATIVE = "плюшевого карпа",
		INSTRUMENTAL = "плюшевым карпом",
		PREPOSITIONAL = "плюшевом карпе",
	)

/obj/random/carp_plushie
	name = "Random Carp Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"

/obj/random/carp_plushie/item_to_spawn()
	return pick(typesof(/obj/item/toy/plushie/carp)) //can pick any carp plushie, even the original.

/obj/item/toy/plushie/carp/ice
	name = "ice carp"
	icon_state = "icecarp"

/obj/item/toy/plushie/carp/silent
	name = "silent carp"
	icon_state = "silentcarp"

/obj/item/toy/plushie/carp/electric
	name = "electric carp"
	icon_state = "electriccarp"

/obj/item/toy/plushie/carp/gold
	name = "gold carp"
	icon_state = "goldcarp"

/obj/item/toy/plushie/carp/toxin
	name = "toxin carp"
	icon_state = "toxincarp"

/obj/item/toy/plushie/carp/dragon
	name = "dragon carp"
	icon_state = "dragoncarp"

/obj/item/toy/plushie/carp/pink
	name = "pink carp"
	icon_state = "pinkcarp"

/obj/item/toy/plushie/carp/candy
	name = "candy carp"
	icon_state = "candycarp"

/obj/item/toy/plushie/carp/nebula
	name = "nebula carp"
	icon_state = "nebulacarp"

/obj/item/toy/plushie/carp/void
	name = "void carp"
	icon_state = "voidcarp"

// MARK: Hampters
/obj/item/toy/plushie/hampter
	name = "Hampter"
	desc = "Народ требует хомяков!"
	icon_state = "hampter"
	gender = MALE

/obj/item/toy/plushie/hampter/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый хомяк",
		GENITIVE = "плюшевого хомяка",
		DATIVE = "плюшевому хомяку",
		ACCUSATIVE = "плюшевого хомяка",
		INSTRUMENTAL = "плюшевым хомяком",
		PREPOSITIONAL = "плюшевом хомяке",
	)

/obj/item/toy/plushie/hampter/asisstant
	name = "Hampter the Assitant"
	desc = "Более или менее полезный."
	icon_state = "hampter_ass"

/obj/item/toy/plushie/hampter/security
	name = "The anti-honk Hampter"
	desc = "ПОДЧИНИСЬ!"
	icon_state = "hampter_sec"

/obj/item/toy/plushie/hampter/medic
	name = "Hampter the Doctor"
	desc = "Не принимайте его таблетки."
	icon_state = "hampter_med"

/obj/item/toy/plushie/hampter/janitor
	name = "Hampter the Janitor"
	desc = "Я буду называть тебя Деном."
	icon_state = "hampter_jan"

// MARK: Beavers
/obj/item/toy/plushie/beaver
	name = "beaver plushie"
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья."
	icon_state = "beaver_plushie"
	item_state = "beaver_plushie"
	gender = MALE

/obj/item/toy/plushie/beaver/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый бобёр",
		GENITIVE = "плюшевого бобра",
		DATIVE = "плюшевому бобру",
		ACCUSATIVE = "плюшевого бобра",
		INSTRUMENTAL = "плюшевым бобром",
		PREPOSITIONAL = "плюшевом бобре",
	)

/obj/item/toy/plushie/beaver/sounded //only adminspawn
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья. Эта выглядит ещё лучше, чем обычно!"
	poof_sound = 'sound/items/beaver_plushie.ogg'
	cuddle_verb = "BOBR KURWA!"

// MARK: Others
/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"
	gender = MALE

/obj/item/toy/plushie/corgi/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый корги",
		GENITIVE = "плюшевого корги",
		DATIVE = "плюшевому корги",
		ACCUSATIVE = "плюшевого корги",
		INSTRUMENTAL = "плюшевым корги",
		PREPOSITIONAL = "плюшевом корги",
	)

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"
	gender = FEMALE

/obj/item/toy/plushie/girly_corgi/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая корги",
		GENITIVE = "плюшевой корги",
		DATIVE = "плюшевой корги",
		ACCUSATIVE = "плюшевую корги",
		INSTRUMENTAL = "плюшевой корги",
		PREPOSITIONAL = "плюшевой корги",
	)

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"
	gender = MALE

/obj/item/toy/plushie/robo_corgi/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый робо-корги",
		GENITIVE = "плюшевого робо-корги",
		DATIVE = "плюшевому робо-корги",
		ACCUSATIVE = "плюшевого робо-корги",
		INSTRUMENTAL = "плюшевым робо-корги",
		PREPOSITIONAL = "плюшевом робо-корги",
	)

/obj/item/toy/plushie/snail
	name = "'snail' plushie"
	desc = "Плюшевая улитка. Выглядит довольно знакомо, не правда ли?"
	icon_state = "snailplushie"
	item_state = "snailplushie"
	gender = FEMALE

/obj/item/toy/plushie/snail/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая улитка",
		GENITIVE = "плюшевой улитки",
		DATIVE = "плюшевой улитке",
		ACCUSATIVE = "плюшевую улитку",
		INSTRUMENTAL = "плюшевой улиткой",
		PREPOSITIONAL = "плюшевой улитке",
	)

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"
	gender = MALE

/obj/item/toy/plushie/octopus/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый осьминог",
		GENITIVE = "плюшевого осьминога",
		DATIVE = "плюшевому осьминогу",
		ACCUSATIVE = "плюшевого осьминога",
		INSTRUMENTAL = "плюшевым осьминогом",
		PREPOSITIONAL = "плюшевом осьминоге",
	)

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"
	gender = MALE

/obj/item/toy/plushie/face_hugger/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый лицехват",
		GENITIVE = "плюшевого лицехвата",
		DATIVE = "плюшевому лицехвату",
		ACCUSATIVE = "плюшевого лицехвата",
		INSTRUMENTAL = "плюшевым лицехватом",
		PREPOSITIONAL = "плюшевом лицехвате",
	)

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"
	gender = MALE

/obj/item/toy/plushie/deer/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый олень",
		GENITIVE = "плюшевого оленя",
		DATIVE = "плюшевому оленю",
		ACCUSATIVE = "плюшевого оленя",
		INSTRUMENTAL = "плюшевым оленем",
		PREPOSITIONAL = "плюшевом олене",
	)

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "Очаровательная плюшевая игрушка, похожая на змею. Не путать с настоящей."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"
	gender = FEMALE

/obj/item/toy/plushie/snakeplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевая змея",
		GENITIVE = "плюшевой змеи",
		DATIVE = "плюшевой змее",
		ACCUSATIVE = "плюшевую змею",
		INSTRUMENTAL = "плюшевой змеёй",
		PREPOSITIONAL = "плюшевой змее",
	)

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "Мягкая игрушка, напоминающая ядерного оперативника \"Синдиката\". На этикетке указано, что оперативники вымышленные."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"

/obj/item/toy/plushie/nukeplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый оперативник \"Синдиката\"",
		GENITIVE = "плюшевого оперативника \"Синдиката\"",
		DATIVE = "плюшевому оперативнику \"Синдиката\"",
		ACCUSATIVE = "плюшевого оперативника \"Синдиката\"",
		INSTRUMENTAL = "плюшевым оперативником \"Синдиката\"",
		PREPOSITIONAL = "плюшевом оперативнике \"Синдиката\"",
	)

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "Очаровательная мягкая игрушка, похожая на слайма. На самом деле это просто плюшевый мячик с лицом. Настоящий антистресс."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"
	gender = MALE

/obj/item/toy/plushie/slimeplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый слайм",
		GENITIVE = "плюшевого слайма",
		DATIVE = "плюшевому слайму",
		ACCUSATIVE = "плюшевого слайма",
		INSTRUMENTAL = "плюшевым слаймом",
		PREPOSITIONAL = "плюшевом слайме",
	)

/obj/item/toy/plushie/fennecplushie
	name = "fennec plushie"
	desc = "Очаровательная плюшевая игрушка, похожая на милого фенека."
	icon_state = "fox"
	item_state = "fox"
	gender = MALE

/obj/item/toy/plushie/fennecplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый фенек",
		GENITIVE = "плюшевого фенека",
		DATIVE = "плюшевому фенеку",
		ACCUSATIVE = "плюшевого фенека",
		INSTRUMENTAL = "плюшевым фенеком",
		PREPOSITIONAL = "плюшевом фенеке",
	)

/obj/item/toy/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "Плюшевая игрушка в виде популярного и трудолюбивого робота-уборщика! Он бы полюбил вас, будь у него эмоции."
	icon_state = "beepskyplushie"

/obj/item/toy/plushie/beepsky/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый робот-уборщик",
		GENITIVE = "плюшевого робота-уборщика",
		DATIVE = "плюшевому роботу-уборщику",
		ACCUSATIVE = "плюшевого робота-уборщика",
		INSTRUMENTAL = "плюшевым роботом-уборщиком",
		PREPOSITIONAL = "плюшевом роботе-уборщике",
	)

/obj/item/toy/plushie/axolotlplushie
	name = "axolotl plushie"
	desc = "Плюшевый аксолотль. Он такой милый!"
	icon_state = "plushie_axolotl"
	item_state = "axolotl"
	attack_verb = list("ущипнул", "чмокнул")
	poof_sound = 'sound/items/axolotl.ogg'
	cuddle_verb = "Squeeek!"
	gender = MALE

/obj/item/toy/plushie/axolotlplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый аксолотль",
		GENITIVE = "плюшевого аксолотля",
		DATIVE = "плюшевому аксолотлю",
		ACCUSATIVE = "плюшевого аксолотля",
		INSTRUMENTAL = "плюшевым аксолотлем",
		PREPOSITIONAL = "плюшевом аксолотле",
	)

/obj/item/toy/plushie/realgoat
	name = "goat plushie"
	desc = "Несмотря на то, что это милая мягкая игрушка, он вас изобьет, или, по крайней мере, избил бы, если бы мог."
	icon_state = "realgoat"
	attack_verb = list("жеванул", "ударил", "ткнул")
	poof_sound = 'sound/items/goatsound.ogg'
	cuddle_verb = "Baaaaah!"
	gender = MALE

/obj/item/toy/plushie/realgoat/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый козёл",
		GENITIVE = "плюшевого козла",
		DATIVE = "плюшевому козлу",
		ACCUSATIVE = "плюшевого козла",
		INSTRUMENTAL = "плюшевым козлом",
		PREPOSITIONAL = "плюшевом козле",
	)

/obj/item/toy/plushie/rouny
	name = "runner plushie"
	desc = "Плюшевая игрушка ксеноморфа-бегуна, созданная в ознаменование столетия после победы на LV-426. В разы приятнее на ощупь чем настоящий."
	icon_state = "rouny"
	attack_verb = list("порезал", "укусил", "протаранил")
	poof_sound = 'sound/items/Help.ogg'
	cuddle_verb = "Бежиииииим!"
	gender = MALE

/obj/item/toy/plushie/rouny/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый \"Руни\"",
		GENITIVE = "плюшевого \"Руни\"",
		DATIVE = "плюшевому \"Руни\"",
		ACCUSATIVE = "плюшевого \"Руни\"",
		INSTRUMENTAL = "плюшевым \"Руни\"",
		PREPOSITIONAL = "плюшевом \"Руни\"",
	)

/obj/item/toy/plushie/banbanana
	name = "BANana"
	desc = "Интересно, а что будет если я его почищу?"
	icon_state = "banana"
	poof_sound = 'sound/effects/adminhelp.ogg'
	gender = MALE

/obj/item/toy/plushie/banbanana/get_ru_names()
	return alist(
		NOMINATIVE = "БАНан",
		GENITIVE = "БАНана ",
		DATIVE = "БАНану",
		ACCUSATIVE = "БАНан",
		INSTRUMENTAL = "БАНаном",
		PREPOSITIONAL = "БАНане",
	)

/obj/item/toy/plushie/banbanana/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	to_chat(target, span_danger("Вас забанил ХО$Т.\nПричина: Хонк."))
	to_chat(target, span_danger("Это ПЕРМАНЕНТНЫЙ бан."))
	to_chat(user, span_danger("Вы <b>ЗАБАНИЛИ</b> [target]"))
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/toy/plushie/pig
	name = "rubber piggy"
	desc = "Люди требуют свиней!"
	icon_state = "pig1"
	gender = FEMALE
	COOLDOWN_DECLARE(oink_cooldown)
	COOLDOWN_DECLARE(message_cooldown)

/obj/item/toy/plushie/pig/get_ru_names()
	return alist(
		NOMINATIVE = "резиновая свинья",
		GENITIVE = "резиновой свиньи",
		DATIVE = "резиновой свинье",
		ACCUSATIVE = "резиновую свинью",
		INSTRUMENTAL = "резиновой свиньёй",
		PREPOSITIONAL = "резиновой свинье",
	)

/obj/item/toy/plushie/pig/proc/oink(mob/user, msg)
	if(!COOLDOWN_FINISHED(src, oink_cooldown))
		return FALSE

	COOLDOWN_START(src, oink_cooldown, 0.3 SECONDS)

	playsound(loc, pick('sound/items/pig1.ogg','sound/items/pig2.ogg','sound/items/pig3.ogg'), 100, TRUE)
	add_fingerprint(user)

	if(COOLDOWN_FINISHED(src, message_cooldown))
		COOLDOWN_START(src, message_cooldown, 3 SECONDS)
		user.visible_message(
			span_notice("[user] [msg] [declent_ru(ACCUSATIVE)]!"),
			span_notice("Ты [msg] [declent_ru(ACCUSATIVE)]!")
		)

	return TRUE

/obj/item/toy/plushie/pig/attack_self(mob/user)
	oink(user, "сжал[GEND_A_O_I(user)]")

/obj/item/toy/plushie/pig/attack_hand(mob/user)
	oink(user, pick("сжал[GEND_A_O_I(user)]", "раздавил[GEND_A_O_I(user)]", "ущипнул[GEND_A_O_I(user)]"))

/obj/item/toy/plushie/pig/Initialize(mapload)
	. = ..()
	switch(rand(1, 100))
		if(1 to 33)
			icon_state = "pig1"
		if(34 to 66)
			icon_state = "pig2"
		if(67 to 99)
			icon_state = "pig3"
		if(100)
			icon_state = "pig4"
			name = "green rubber piggy"
			desc = "Остерегайся злых воксов!"

/obj/item/toy/plushie/pig/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object != user || user.incapacitated() || !ishuman(user))
		return

	if(!user.put_in_hands(src, ignore_anim = FALSE))
		return

	add_fingerprint(user)
	user.visible_message(span_notice("[user] поднял[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."))

/obj/item/toy/plushie/bubblegumplushie
	name = "bubblegum plushie"
	desc = "В иерархии плюшевых игрушек-демонов, эта игрушка — король."
	icon_state = "plushie_bubblegum"
	item_state = "plushie_bubblegum"
	attack_verb = list("атаковал", "протаранил")
	poof_sound = 'sound/misc/demon_attack1.ogg'
	gender = MALE

/obj/item/toy/plushie/bubblegumplushie/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый Бубльгум",
		GENITIVE = "плюшевого Бубльгума",
		DATIVE = "плюшевому Бубльгуму",
		ACCUSATIVE = "плюшевого Бубльгума",
		INSTRUMENTAL = "плюшевым Бубльгумом",
		PREPOSITIONAL = "плюшевом Бубльгуме",
	)

/obj/item/toy/plushie/bubblegumplushie/perform_special_interaction(mob/user)
	playsound(src, 'sound/effects/meteorimpact.ogg', 40, TRUE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Бубльгум топает...")]")
	return TRUE

/obj/item/toy/plushie/chikaboomchik
	name = "plushie chikaboomchik"
	desc = "Милая плюшевая игрушка птички чикабумчика. Маленькая, круглая и очень пушистая."
	icon_state = "plushie_chikaboom"
	item_state = "chikaboom"
	attack_verb = list("цапнул", "клюнул")
	poof_sound = 'sound/items/wahwah.ogg'
	gender = MALE

/obj/item/toy/plushie/chikaboomchik/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый чикабумчик",
		GENITIVE = "плюшевого чикабумчика",
		DATIVE = "плюшевому чикабумчику",
		ACCUSATIVE = "плюшевого чикабумчика",
		INSTRUMENTAL = "плюшевым чикабумчиком",
		PREPOSITIONAL = "плюшевом чикабумчике",
	)

#define EVIL_MODE_CHANCE 5

/obj/item/toy/plushie/wet_owl
	name = "wet owl plushie"
	desc = "Плюшевая игрушка поникшей мокрой совы. Она явно видела некоторое дерьмо."
	icon_state = "wet_owl"
	item_state = "wet_owl"
	attack_verb = list("ухнул", "клюнул", "цапнул")
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	/// Is it in evil mode now or not
	var/is_evil = FALSE
	var/cooldown_time = 2 SECONDS
	COOLDOWN_DECLARE(water_cooldown)

/obj/item/toy/plushie/wet_owl/get_ru_names()
	return alist(
		NOMINATIVE = "мокрая сова",
		GENITIVE = "мокрой совы",
		DATIVE = "мокрой сове",
		ACCUSATIVE = "мокрую сову",
		INSTRUMENTAL = "мокрой совой",
		PREPOSITIONAL = "мокрой сове",
	)

/obj/item/toy/plushie/wet_owl/water_act(volume, temperature, source, method)
	. = ..()
	if(!COOLDOWN_FINISHED(src, water_cooldown))
		return

	COOLDOWN_START(src, water_cooldown, 30 SECONDS)
	visible_message(span_cultitalic("[DECLENT_RU_CAP(src, NOMINATIVE)] недовольно завывает."))
	playsound(src, 'sound/effects/wet_owl_horror.ogg', 50, FALSE, -1)
	temporary_become_evil(30 SECONDS)

/obj/item/toy/plushie/wet_owl/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] всматривается в бездну глаз [declent_ru(GENITIVE)], и бездна начинает всматриваться в ответ!"))
	playsound(src, 'sound/effects/wet_owl_horror.ogg', 70, FALSE, -1)
	user.emote("scream")
	return SHAME

/obj/item/toy/plushie/wet_owl/attack_self(mob/living/user)
	. = ..()
	if(prob(EVIL_MODE_CHANCE))
		temporary_become_evil(5 SECONDS)

	if(!is_evil)
		return .

	var/mob/living/carbon/human/human = user
	human.AdjustConfused(3 SECONDS, bound_lower = 0, bound_upper = 15 SECONDS)

/obj/item/toy/plushie/wet_owl/proc/temporary_become_evil(evil_mode_duration)
	is_evil = TRUE
	icon_state = "evil_wet_owl"
	item_state = "evil_wet_owl"
	desc = "Злобная плюшевая игрушка мокрой совы. Она явно видела некоторое дерьмо — это легко можно понять по её взгляду."
	poof_sound = 'sound/effects/wet_owl_horror.ogg'
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(become_normal)), evil_mode_duration)

/obj/item/toy/plushie/wet_owl/proc/become_normal()
	is_evil = FALSE
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	desc = initial(desc)
	poof_sound = initial(poof_sound)
	update_appearance()

/obj/item/toy/plushie/wet_owl/play_poof_sound()
	if(!is_evil)
		return ..()

	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	COOLDOWN_START(src, cooldown, cooldown_time)
	playsound(loc, poof_sound, 20, FALSE)

#undef EVIL_MODE_CHANCE

/obj/item/toy/plushie/ninja
	name = "space ninja plushie"
	desc = "Главный герой одного из самых популярных мультиков в этой части галактики. \"運命の忍者矢\""
	icon_state = "ninja_plushie_green"
	item_state = "ninja_plushie_green"
	cuddle_verb = list(
		"Я не боюсь тьмы! Я сама тьма!",
		"Твой жалкий свет меня не остановит!",
		"Ты можешь бежать, но не сможешь спрятаться!",
	)
	var/plushie_color
	gender = MALE

/obj/item/toy/plushie/ninja/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый ниндзя",
		GENITIVE = "плюшевого ниндзя",
		DATIVE = "плюшевому ниндзя",
		ACCUSATIVE = "плюшевого ниндзя",
		INSTRUMENTAL = "плюшевым ниндзя",
		PREPOSITIONAL = "плюшевом ниндзя",
	)

/obj/item/toy/plushie/ninja/update_icon_state()
	switch(plushie_color)
		if("green")
			icon_state = "ninja_plushie_green"
			item_state = "ninja_plushie_green"
		if("blue")
			icon_state = "ninja_plushie_blue"
			item_state = "ninja_plushie_blue"
		if("red")
			icon_state = "ninja_plushie_red"
			item_state = "ninja_plushie_red"
		else
			icon_state = initial(icon_state)
			item_state = initial(item_state)

/obj/item/toy/plushie/ninja/attack_self(mob/user as mob)
	. = ..()
	plushie_color = pick("green","blue","red")
	update_icon(UPDATE_ICON_STATE)

/obj/item/toy/plushie/glorp
	name = "plushie glorp"
	desc = "Плюшевая игрушка глорпа. Да, это он украл ваших коров. Да, круги на полях тоже оставил он."
	icon_state = "glorp"
	item_state = "glorp"
	poof_sound = 'sound/misc/alien-giggle.ogg'
	gender = MALE

/obj/item/toy/plushie/glorp/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый глорп",
		GENITIVE = "плюшевого глорпа",
		DATIVE = "плюшевому глорпу",
		ACCUSATIVE = "плюшевого глорпа",
		INSTRUMENTAL = "плюшевым глорпом",
		PREPOSITIONAL = "плюшевом глорпе",
	)

//shitspawn
/obj/item/toy/plushie/pizdosik
	name = "plushie pizdosik"
	desc = "Плюшевый работяга. Он устал... Дайте ему отдохнуть..."
	icon_state = "pizdosik"
	item_state = "pizdosik"
	poof_sound = 'sound/misc/pizdosik.ogg'
	gender = MALE

/obj/item/toy/plushie/pizdosik/get_ru_names()
	return alist(
		NOMINATIVE = "плюшевый пиздосик",
		GENITIVE = "плюшевого пиздосика",
		DATIVE = "плюшевому пиздосику",
		ACCUSATIVE = "плюшевого пиздосика",
		INSTRUMENTAL = "плюшевым пиздосиком",
		PREPOSITIONAL = "плюшевом пиздосике",
	)
