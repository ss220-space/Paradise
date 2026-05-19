/*
 * Plushies
 */

/obj/item/toy/plushie
	name = "plushie"
	desc = "Очаровательная, мягкая и приятная на ощупь плюшевая игрушка."
	var/poof_sound = 'sound/weapons/thudswoosh.ogg'
	// used for custom plushie cuddles
	var/list/cuddle_verb
	attack_verb = list("тыкнул", "ударил", "шлёпнул")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	unique_toy_rename = TRUE
	COOLDOWN_DECLARE(cooldown)

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
		user.visible_message(span_notice("[user] [pick(defauld_cuddle)] the [src]."))

/obj/item/toy/plushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	play_poof_sound() // Play the whoosh sound in local area
	cuddle_counter(user)
	if(iscarbon(target) && prob(10))
		target.reagents.add_reagent("hugs", 10)

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
	return pick(subtypesof(/obj/item/toy/plushie) - typesof(/obj/item/toy/plushie/fluff) - subtypesof(/obj/item/toy/plushie/plasmamanplushie/standart)) //exclude the base type and 11 random plasma plushies

/*
 * Foxes
 */

/obj/item/toy/plushie/fox
	name = "fox plushie"
	icon_state = "redfox"

/obj/item/toy/plushie/fox/get_ru_names()
	return list(
		NOMINATIVE = "плюшевая лиса",
		GENITIVE = "плюшевой лисы",
		DATIVE = "плюшевой лисе",
		ACCUSATIVE = "плюшевую лису",
		INSTRUMENTAL = "плюшевой лисой",
		PREPOSITIONAL = "плюшевой лисе",
	)

/obj/item/toy/plushie/fox/black
	icon_state = "blackfox"

/obj/item/toy/plushie/fox/marble
	icon_state = "marblefox"

/obj/item/toy/plushie/fox/blue
	icon_state = "bluefox"

/obj/item/toy/plushie/fox/coffee
	icon_state = "coffeefox"

/obj/item/toy/plushie/fox/pink
	icon_state = "pinkfox"

/obj/item/toy/plushie/fox/purple
	icon_state = "purplefox"

/obj/item/toy/plushie/fox/crimson
	icon_state = "crimsonfox"

/obj/item/toy/plushie/fox/orange
	icon_state = "orangefox"

/obj/item/toy/plushie/fox/orange/grump
	name = "grumpy fox"
	desc = "An ancient plushie that seems particularly grumpy."

/obj/item/toy/plushie/fox/orange/grump/ComponentInitialize()
	. = ..()
	var/static/list/grumps = list("Ahh, yes, you're so clever, var editing that.", "Really?", "If you make a runtime with var edits, it's your own damn fault.",
	"Don't you dare post issues on the git when you don't even know how this works.", "Was that necessary?", "Ohhh, setting admin edited var must be your favorite pastime!",
	"Oh, so you have time to var edit, but you don't have time to ban that greytider?", "Oh boy, is this another one of those 'events'?", "Seriously, just stop.", "You do realize this is incurring proc call overhead.",
	"Congrats, you just left a reference with your dirty client and now that thing you edited will never garbage collect properly.", "Is it that time of day, again, for unecessary adminbus?")
	AddComponent(/datum/component/edit_complainer, grumps)

/*
 * Cats
 */
/obj/item/toy/plushie/cat
	name = "cat plushie"
	icon_state = "blackcat"
	cuddle_verb = list("Мяу!", "Мурр!")

/obj/item/toy/plushie/cat/get_ru_names()
	return list(
		NOMINATIVE = "плюшевый кот",
		GENITIVE = "плюшевого кота",
		DATIVE = "плюшевому коту",
		ACCUSATIVE = "плюшевого кота",
		INSTRUMENTAL = "плюшевым котом",
		PREPOSITIONAL = "плюшевом коте",
	)

/obj/item/toy/plushie/cat/grey
	icon_state = "greycat"

/obj/item/toy/plushie/cat/white
	icon_state = "whitecat"

/obj/item/toy/plushie/cat/orange
	icon_state = "orangecat"

/obj/item/toy/plushie/cat/siamese
	icon_state = "siamesecat"

/obj/item/toy/plushie/cat/tabby
	icon_state = "tabbycat"

/obj/item/toy/plushie/cat/tuxedo
	icon_state = "tuxedocat"

/obj/item/toy/plushie/cat/kotrazumist
	name = "Razumist Cat"
	desc = "Кот с конусом на макушке. Интересно, что же сделало его таким умным?"
	icon_state = "razymist_cat"
	cuddle_verb = list("Я знаю всё обо всём, спроси меня о чём-нибудь!", "Сегодня я особенно мудр!", "Мяу!", "Мурр!")

/obj/item/toy/plushie/cat/kotrazumist/get_ru_names()
	return list(
		NOMINATIVE = "кот разумист",
		GENITIVE = "кота разумиста",
		DATIVE = "коту разумисту",
		ACCUSATIVE = "кота разумиста",
		INSTRUMENTAL = "котом разумистом",
		PREPOSITIONAL = "коте разумисте",
	)

/obj/item/toy/plushie/cat/ricehat
	name = "Rice Cat"
	desc = "Белая плюшевая кошка в соломенной шляпе, полученной за тяжелый труд на рисовом поле."
	icon_state = "ricehat_cat"
	cuddle_verb = list("Добро пожаловать на рисовые поля!", "Где мой рис?!", "Мяу!", "Мурр!")

/obj/item/toy/plushie/cat/ricehat/get_ru_names()
	return list(
		NOMINATIVE = "кот в рисовой шляпе",
		GENITIVE = "кота в рисовой шляпе",
		DATIVE = "коту в рисовой шляпе",
		ACCUSATIVE = "кота в рисовой шляпе",
		INSTRUMENTAL = "котом в рисовой шляпе",
		PREPOSITIONAL = "коте в рисовой шляпе",
	)

/obj/item/toy/plushie/manulplushie
	name = "manul plushie"
	desc = "Чёрный котик в красными ушами, в халатике, на халате бирка \"Манул\". Кто-то оставил эту игрушку здесь в память..."
	icon_state = "kotik_plushie"
	item_state = "kotik_hand"

/obj/item/toy/plushie/manulplushie/get_ru_names()
	return list(
		NOMINATIVE = "игрушка Манула",
		GENITIVE = "игрушки Манула",
		DATIVE = "игрушке Манула",
		ACCUSATIVE = "игрушку Манула",
		INSTRUMENTAL = "игрушкой Манула",
		PREPOSITIONAL = "игрушке Манула",
	)

/*
 * Cat Toy
 */
/obj/item/toy/plushie/cattoy
	name = "toy mouse"
	desc = "Яркая игрушечная мышка!"
	icon_state = "toy_mouse"

/obj/item/toy/plushie/cattoy/get_ru_names()
	return list(
		NOMINATIVE = "игрушечная мышь",
		GENITIVE = "игрушечной мыши",
		DATIVE = "игрушечной мыши",
		ACCUSATIVE = "игрушечную мышь",
		INSTRUMENTAL = "игрушечной мышью",
		PREPOSITIONAL = "игрушечной мыши",
	)

/*
 * Races
 */
/obj/item/toy/plushie/voxplushie
	name = "vox plushie"
	desc = "A stitched-together vox, fresh from the skipjack. Press its belly to hear it skree!"
	desc = "Сшитый из разных кусков вокc, только что со своего Скипджека. Нажмите на живот, чтобы услышать его нереальный визг!"
	icon_state = "plushie_vox"
	poof_sound = 'sound/voice/shriek1.ogg'
	cuddle_verb = "Skreee!"

/obj/item/toy/plushie/voxplushie/get_ru_names()
	return list(
		NOMINATIVE = "плюшевый вокс",
		GENITIVE = "плюшевого вокса",
		DATIVE = "плюшевому воксу",
		ACCUSATIVE = "плюшевого вокса",
		INSTRUMENTAL = "плюшевым воксом",
		PREPOSITIONAL = "плюшевом воксе",
	)

/obj/item/toy/plushie/shardplushie
	name = "Shard plushie"
	desc = "Мягкая игрушка в виде осколка кристалла суперматерии. 100% безопасность."
	icon_state = "plushie_shard"
	item_state = "plushie_shard"
	attack_verb = list("аннигилировал", "поцарапал")
	cuddle_verb = "ДЕСТАБИЛИЗАЦИЯ!"
	poof_sound = 'sound/effects/supermatter.ogg'

/obj/item/toy/plushie/shardplushie/get_ru_names()
	return list(
		NOMINATIVE = "плюшевый кристалл суперматерии",
		GENITIVE = "плюшевого кристалла суперматерии",
		DATIVE = "плюшевому кристаллу суперматерии",
		ACCUSATIVE = "плюшевого кристалла суперматерии",
		INSTRUMENTAL = "плюшевым кристаллом суперматерии",
		PREPOSITIONAL = "плюшевом кристалле суперматерии",
	)

/obj/item/toy/plushie/greyplushie
	name = "Плюшевый грей"
	desc = "Плюшевая кукла грея в толстовке. Кукла входит в серию \"Пришелец\" и имеет свитер, большую голову и мультяшные глаза. Любит мехов."
	icon_state = "plushie_grey"
	item_state = "plushie_grey"
	cuddle_verb = list("☝︎❒︎♏︎♏︎⧫︎♓︎■︎♑︎⬧︎📬︎", "☟︎□︎⬥︎ ♋︎❒︎♏︎ ⍓︎□︎◆︎✍︎", "☹︎♓︎●︎◆︎ ♓︎⬧︎ ⧫︎♒︎♏︎ ♌︎♏︎⬧︎⧫︎", "✋︎ ●︎□︎❖︎♏︎ ❍︎♏︎♍︎♒︎⬧︎✏︎")
	var/singed = FALSE
	var/scream_cooldown = FALSE //Defaults the plushie to being off cooldown. Sets the scream_cooldown var.

/obj/item/toy/plushie/greyplushie/get_ru_names()
	return list(
		NOMINATIVE = "плюшевый грей",
		GENITIVE = "плюшевого грея",
		DATIVE = "плюшевому грею",
		ACCUSATIVE = "плюшевого грея",
		INSTRUMENTAL = "плюшевым греем",
		PREPOSITIONAL = "плюшевом грее",
	)

/obj/item/toy/plushie/greyplushie/water_act(volume, temperature, source, method = REAGENT_TOUCH) //If water touches the plushie the following code executes.
	. = ..()
	if(scream_cooldown)
		return
	scream_cooldown = TRUE //water_act executes the scream_cooldown var, setting it on cooldown.
	addtimer(CALLBACK(src, PROC_REF(reset_screamdown)), 30 SECONDS) //After 30 seconds the reset_coolodown() proc will execute, resetting the cooldown.
	playsound(src, 'sound/goonstation/voice/male_scream.ogg', 10, FALSE)//If the plushie gets wet it screams and "AAAAAH!" appears in chat.
	visible_message("[get_examine_icon(viewers(loc))] [span_danger("AAAAAAХ!")]")
	if(singed)
		return
	singed = TRUE
	cuddle_verb = list("За что...", "Изверги...")
	icon_state = "grey_singed"
	item_state = "grey_singed"//If the plushie gets wet the sprite changes to a singed version.
	update_icon(UPDATE_ICON_STATE)
	desc = "Испорченная плюшевая игрушка грея. Похоже, что кто-то прогнал его под водой."

/obj/item/toy/plushie/greyplushie/proc/reset_screamdown()
	scream_cooldown = FALSE //Resets the scream interaction cooldown.

/obj/item/toy/plushie/ipcplushie
	name = "IPC plushie"
	desc = "Очаровательная плюшевая игрушка IPC прямо из Нью-Кэнаана. Пожалуй, даже прочнее, чем настоящая. Функционально напоминает тостер."
	icon_state = "plushie_ipc"

/obj/item/toy/plushie/ipcplushie/get_ru_names()
	return list(
		NOMINATIVE = "плюшевый КПБ",
		GENITIVE = "плюшевого КПБ",
		DATIVE = "плюшевому КПБ",
		ACCUSATIVE = "плюшевого КПБ",
		INSTRUMENTAL = "плюшевым КПБ",
		PREPOSITIONAL = "плюшевом КПБ",
	)

/obj/item/toy/plushie/ipcplushie/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/breadslice))
		add_fingerprint(user)
		new /obj/item/reagent_containers/food/snacks/toast(drop_location())
		to_chat(user, span_notice("Вы засовываете хлеб в тостер."))
		playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

//New generation TG plushies

/obj/item/toy/plushie/lizard_plushie
	name = "lizard plushie"
	desc = "Очаровательная плюшевая игрушка в виде унатха"
	icon_state = "map_plushie_lizard"
	item_state = "plushie_lizard"
	greyscale_config = /datum/greyscale_config/plush_lizard
	greyscale_config_inhand_left = /datum/greyscale_config/plush_lizard_left
	greyscale_config_inhand_right = /datum/greyscale_config/plush_lizard_right

/obj/item/toy/plushie/lizard_plushie/get_ru_names()
	return list(
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

/obj/item/toy/plushie/ashwalkerplushie/get_ru_names()
	return list(
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
	desc = "Мягкая плюшевая игрушка в виде Ниана, добытая прямо из туманности. Потяните за усики, чтобы услышать жужжание!"
	icon_state = "plushie_nian"
	item_state = "plushie_nian"
	poof_sound = 'sound/voice/scream_moth.ogg'
	cuddle_verb = list("Бжжж!", "Бззз!", "Жуж!")

/obj/item/toy/plushie/nianplushie/get_ru_names()
	return list(
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
	return list(
		NOMINATIVE = "плюшевая пчёлка",
		GENITIVE = "плюшевой пчёлки",
		DATIVE = "плюшевой пчёлке",
		ACCUSATIVE = "плюшевую пчёлку",
		INSTRUMENTAL = "плюшевой пчёлкой",
		PREPOSITIONAL = "плюшевой пчёлке",
	)

/*
 * Heads
 */
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

/obj/item/toy/plushie/rdplushie/cuddle_counter(mob/user)
	if(++tired < 100)
		return

	icon_state = "RD_doll_tired"
	item_state = "RD_doll_tired"
	desc = "Это уставшая кукла РД."
	poof_sound = 'sound/items/shyness-emote.ogg'
	cuddle_verb = list("Твой мозг стоило бы поместить в машину...",
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
			«Кукла-аниматроник GSBussy, лимитированная серия. Произведено ######» - часть текста невозможно разобрать."
	icon_state = "GSBussy_doll"
	item_state = "GSBussy_doll"
	poof_sound = 'sound/items/GSBussy.ogg'
	cuddle_verb = list(
		"Я просто стояла рядом с автолатом и Уника исчезла...",
		".ы ПОО-МММ-ОО-Г-Г-ГИТ-Е-Е-ее-Ее А-а-А-Р-р-Ан-Н-Еу-С-С!",
		"ОТВЕЧАЙ, ГДЕ ТЫ ПОТЕРЯЛ СВОЙ ЧЁРТОВ ГОЛОВНОЙ УБОР?! КАЗНИТЬ ЕГО!", "Какой-то Д двадц...",
		"Обыскивайте всех подряд! Летальте всех, кого считаете слишком опасным для нелетала!",
		"Мим теслу запускает! ЗАДЕРЖАТЬ!!!",
		"Подмогу в туалет брига!",
		"Почему над унитазом установлены 3 камеры?",
	)

/*
 * Sharks
 */
/obj/item/toy/plushie/blahaj
	name = "shark plushie"
	desc = "Уменьшенная, более дружелюбная и пушистая версия чем настоящая."
	gender = MALE
	icon_state = "blahaj"
	item_state = "blahaj"
	attack_verb = list("жеванул", "обглодал", "укусил")
	poof_sound = 'sound/weapons/bite.ogg'

/obj/item/toy/plushie/blahaj/twohanded
	name = "akula plushie"
	desc = "Старшая и более милая сестричка акулёнка. Она может издавать забавные звуки при нажатии кнопки на животе. Бейби шарк ту ту туру туру!"
	gender = FEMALE
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "plushie_akula"
	item_state = "plushie_akula"
	poof_sound = 'sound/items/rawr.ogg'
	cuddle_verb = "Rawr!"

/obj/item/toy/plushie/blahaj/twohanded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/*
 * Plasmaman
 */
/obj/item/toy/plushie/plasmamanplushie
	name = "plasmaman plushie"
	desc = "A stuffed toy that resembles your purple coworkers. Mmm, yeah, in true plasmaman fashion, it's not cute at all despite the designer's best efforts."
	icon_state = "plasmaman_plushie_civillian"
	var/pmanlbite = 'sound/effects/extinguish.ogg'

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

/obj/item/toy/plushie/plasmamanplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, pmanlbite, 20, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/plasmamanplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/effects/extinguish.ogg', 20, FALSE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Плазззма Вечна!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/*
 * Carp plushie
 */

/obj/item/toy/plushie/carp
	name = "space carp plushie"
	desc = "Очаровательная плюшевая игрушка, похожая на космического карпа."
	icon_state = "carpplushie"
	attack_verb = list("укусил", "пожрал", "шлёпнул")
	poof_sound = 'sound/weapons/bite.ogg'

/obj/item/toy/plushie/carp/get_ru_names()
	return list(
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
	icon_state = "icecarp"

/obj/item/toy/plushie/carp/silent
	icon_state = "silentcarp"

/obj/item/toy/plushie/carp/electric
	icon_state = "electriccarp"

/obj/item/toy/plushie/carp/gold
	icon_state = "goldcarp"

/obj/item/toy/plushie/carp/toxin
	icon_state = "toxincarp"

/obj/item/toy/plushie/carp/dragon
	icon_state = "dragoncarp"

/obj/item/toy/plushie/carp/pink
	icon_state = "pinkcarp"

/obj/item/toy/plushie/carp/candy
	icon_state = "candycarp"

/obj/item/toy/plushie/carp/nebula
	icon_state = "nebulacarp"

/obj/item/toy/plushie/carp/void
	icon_state = "voidcarp"

/*
 * Hampters
 */
/obj/item/toy/plushie/hampter
	name = "Hampter"
	desc = "The people demand hampters!"
	icon_state = "hampter"

/obj/item/toy/plushie/hampter/asisstant
	name = "Hampter the Assitant"
	desc = "More or less helpful."
	icon_state = "hampter_ass"

/obj/item/toy/plushie/hampter/security
	name = "The anti-honk Hampter"
	desc = "OBEY!"
	icon_state = "hampter_sec"

/obj/item/toy/plushie/hampter/medic
	name = "Hampter the Doctor"
	desc = "Don't take his pills."
	icon_state = "hampter_med"

/obj/item/toy/plushie/hampter/janitor
	name = "Hampter the Janitor"
	desc = "I'll call you - Den."
	icon_state = "hampter_jan"

/*
 * Beavers
 */
/obj/item/toy/plushie/beaver
	name = "beaver plushie"
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья."
	icon_state = "beaver_plushie"
	item_state = "beaver_plushie"
	gender = MALE

/obj/item/toy/plushie/beaver/sounded //only adminspawn
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья. Эта выглядит ещё лучше, чем обычно!"

/obj/item/toy/plushie/beaver/sounded/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	user.visible_message(span_boldnotice("BOBR KURWA!"))
	playsound(user, 'sound/items/beaver_plushie.ogg', 50, FALSE)
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/*
 * Others
 */
/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"

/obj/item/toy/plushie/snail
	name = "'snail' plushie"
	desc = "It looks quite familiar, right?"
	icon_state = "snailplushie"
	item_state = "snailplushie"

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "An stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"

/obj/item/toy/plushie/foxplushie
	name = "fox plushie"
	desc = "An adorable stuffed toy resembling a cute fox."
	icon_state = "fox"
	item_state = "fox"

/obj/item/toy/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "A plushie of a popular industrious cleaning robot! If it could feel emotions, it would love you."
	icon_state = "beepskyplushie"

/obj/item/toy/plushie/axolotlplushie
	name = "axolotl plushie"
	desc = "An adorable stuffed toy that resembles an axolotl. Not to be mistaken for the real thing."
	icon_state = "plushie_axolotl"
	item_state = "axolotl"
	attack_verb = list("ущипнул", "чмокнул")
	var/axolotlbite = 'sound/items/axolotl.ogg'

/obj/item/toy/plushie/axolotlplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, axolotlbite, 20, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/axolotlplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/axolotl.ogg', 20, FALSE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Squeeek!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/realgoat
	name = "goat plushie"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same, or at least it would if it wasn't a normal plushie."
	icon_state = "realgoat"
	attack_verb = list("жеванул", "ударил", "ткнул")
	var/goatbite = 'sound/items/goatsound.ogg'

/obj/item/toy/plushie/realgoat/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, goatbite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/realgoat/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/goatsound.ogg', 10, FALSE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Baaaaah!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/rouny
	name = "runner plushie"
	desc = "A plushie depicting a xenomorph runner, made to commemorate the centenary of the Battle of LV-426. Much cuddlier than the real thing."
	icon_state = "rouny"
	attack_verb = list("порезал", "укусил", "протаранил")
	var/rounibite = 'sound/items/Help.ogg'

/obj/item/toy/plushie/rouny/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, rounibite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/rouny/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/Help.ogg', 10, FALSE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Бежиииииим!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/banbanana
	name = "BANana"
	desc = "What happens if I peel it?"
	icon_state = "banana"

/obj/item/toy/plushie/banbanana/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	to_chat(target, span_danger("Вас забанил ХО$Т.\nПричина: Хонк."))
	to_chat(target, span_danger("Это ПЕРМАНЕНТНЫЙ бан."))
	to_chat(user, span_danger("Вы <b>ЗАБАНИЛИ</b> [target]"))
	playsound(loc, 'sound/effects/adminhelp.ogg', 25)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/toy/plushie/pig
	name = "rubber piggy"
	desc = "The people demand pigs!"
	icon_state = "pig1"
	var/spam_flag = 0
	var/message_spam_flag = 0

/obj/item/toy/plushie/pig/proc/oink(mob/user, msg)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(loc, pick('sound/items/pig1.ogg','sound/items/pig2.ogg','sound/items/pig3.ogg'), 100, TRUE)
		add_fingerprint(user)
		if(message_spam_flag == 0)
			message_spam_flag = 1
			user.visible_message(span_notice("[user] [msg] [declent_ru(ACCUSATIVE)]!"), span_notice("Вы [msg] [declent_ru(ACCUSATIVE)]!"))
			spawn(30)
				message_spam_flag = 0
		spawn(3)
			spam_flag = 0
	return

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
			desc = "Watch out for angry voxes!"

/obj/item/toy/plushie/pig/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(over_object != user || user.incapacitated() || !ishuman(user))
		return

	if(!user.put_in_hands(src, ignore_anim = FALSE))
		return

	add_fingerprint(user)
	user.visible_message(span_notice("[user] поднял[GEND_A_O_I(user)] [declent_ru(ACCUSATIVE)]."))

/obj/item/toy/plushie/bubblegumplushie
	name = "bubblegum plushie"
	desc = "In what passes for a heirarchy among slaughter demon plushies, this one is king."
	icon_state = "plushie_bubblegum"
	item_state = "plushie_bubblegum"
	attack_verb = list("атаковал", "протаранил")
	var/bubblestep = 'sound/effects/meteorimpact.ogg'
	var/bubbleattack = 'sound/misc/demon_attack1.ogg'

/obj/item/toy/plushie/bubblegumplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, pick(bubblestep, bubbleattack), 40, TRUE)

/obj/item/toy/plushie/bubblegumplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, bubblestep, 40, TRUE)
	user.visible_message("[get_examine_icon(viewers(user))] [span_danger("Бубльгум топает...")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/chikaboomchik
	name = "Плюшевый Чикабумчик"
	desc = "Милая плюшевая игрушка птички Чикабумчика. Маленькая, круглая и очень пушистая."
	icon_state = "plushie_chikaboom"
	item_state = "chikaboom"
	attack_verb = list("цапнул", "клюнул")
	poof_sound = 'sound/items/wahwah.ogg'

/obj/item/toy/plushie/chikaboomchik/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	playsound(loc, 'sound/items/wahwah.ogg', 50, FALSE)
	COOLDOWN_START(src, cooldown, 3 SECONDS)

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

/obj/item/toy/plushie/wet_owl/get_ru_names()
	return list(
		NOMINATIVE = "мокрая сова",
		GENITIVE = "мокрой совы",
		DATIVE = "мокрой сове",
		ACCUSATIVE = "мокрую сову",
		INSTRUMENTAL = "мокрой совой",
		PREPOSITIONAL = "мокрой сове",
	)

/obj/item/toy/plushie/wet_owl/water_act(volume, temperature, source, method)
	. = ..()
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

// Little cute Ninja plushie
/obj/item/toy/plushie/ninja
	name = "space ninja plushie"
	desc = "A protagonist of one of the most popular cartoon series on this side of galaxy. \"運命の忍者矢\""
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_plushie_green"
	item_state = "ninja_plushie_green"
	var/plushie_color

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
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		var/plushie_color = pick("green","blue","red")
		update_icon(UPDATE_ICON_STATE)
		switch(plushie_color)
			if("green")
				user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит: \"Я не боюсь тьмы! Я сама тьма!\""))
			if("blue")
				user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит: \"Твой жалкий свет меня не остановит!\""))
			if("red")
				user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит: \"Ты можешь бежать, но не сможешь спрятаться!\""))
		plushie_color = null

