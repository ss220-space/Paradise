/* Misc toys
 *	Contains:
 *		Snap pops
 *		Codex gigas
 *		Mini gibber
 *		Toy big red button
 *		Fake cuffs
 *		Office desk toys
 */

// MARK: Snap pops
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Ого!"
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/get_ru_names()
	return alist(
		NOMINATIVE = "хлопушка",
		GENITIVE = "хлопушки",
		DATIVE = "хлопушке",
		ACCUSATIVE = "хлопушку",
		INSTRUMENTAL = "хлопушкой",
		PREPOSITIONAL = "хлопушке",
	)

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/snappop/proc/pop_burst(number = 3, cardinal_only = TRUE)
	do_sparks(number, cardinal_only, src)
	new ash_type(loc)
	visible_message(
		span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] взрывается!"),
		span_warning("Вы слышите хлопок!")
	)
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/obj/item/toy/snappop/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	var/is_silicon = issilicon(arrived)
	if(!ishuman(arrived) && !is_silicon) //i guess carp and shit shouldn't set them off
		return

	var/mob/living/arrived_mob = arrived
	if(is_silicon || arrived_mob.m_intent == MOVE_INTENT_RUN)
		to_chat(arrived_mob, span_danger("Вы наступаете на хлопушку!"))
		pop_burst(2, FALSE)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Ого! Ничего себе! Вот это да!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/item/toy/snappop/phoenix/get_ru_names()
	return alist(
		NOMINATIVE = "хлопушка \"Феникс\"",
		GENITIVE = "хлопушки \"Феникс\"",
		DATIVE = "хлопушке \"Феникс\"",
		ACCUSATIVE = "хлопушку \"Феникс\"",
		INSTRUMENTAL = "хлопушкой \"Феникс\"",
		PREPOSITIONAL = "хлопушке \"Феникс\"",
	)

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)

// MARK: Codex gigas
/obj/item/toy/codex_gigas
	name = "Toy Codex Gigas"
	desc = "Книга, которая поможет вам выдумывать дьяволов!"
	icon = 'icons/obj/library.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	icon_state = "demonomicon"
	item_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	var/list/messages_to_display = list()
	var/current_message_index = 0

/obj/item/toy/codex_gigas/get_ru_names()
	return alist(
		NOMINATIVE = "поддельный Кодекс Гигас",
		GENITIVE = "поддельного Кодекса Гигаса",
		DATIVE = "поддельному Кодексу Гигасу",
		ACCUSATIVE = "поддельный Кодекс Гигаса",
		INSTRUMENTAL = "поддельным Кодексом Гигасом",
		PREPOSITIONAL = "поддельном Кодексе Гигасе",
	)

/obj/item/toy/codex_gigas/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	user.visible_message(
		span_notice("[user] нажима[PLUR_ET_YUT(user)] кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_notice("Вы нажимаете кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_sinister("Слышишь тихий щелчок.")
	)

	var/datum/devilinfo/devil = new
	messages_to_display = list()
	messages_to_display += "Интересные факты о: [devil.truename]"
	messages_to_display += devil.bane.law
	messages_to_display += devil.ban.law
	messages_to_display += devil.obligation.law
	messages_to_display += devil.banish.law

	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	COOLDOWN_START(src, cooldown, 60 SECONDS)

	current_message_index = 1
	display_next_message(user)

/obj/item/toy/codex_gigas/proc/display_next_message(mob/user)
	if(current_message_index > messages_to_display.len)
		messages_to_display = list()
		return

	var/message = messages_to_display[current_message_index]
	user.loc.visible_message(span_danger("[get_examine_icon(viewers(user.loc))] [message]"))
	current_message_index++
	addtimer(CALLBACK(src, PROC_REF(display_next_message), user), 1 SECONDS)

// MARK: Mini gibber
/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "Миниатюрная копия знаменитой мясорубки компании \"Нанотрейзен\"."
	icon_state = "minigibber"
	attack_verb = list("перемолол", "гибнул")
	w_class = WEIGHT_CLASS_SMALL
	var/obj/stored_miniature = null

/obj/item/toy/minigibber/get_ru_names()
	return alist(
		NOMINATIVE = "миниатюрная мясорубка",
		GENITIVE = "миниатюрной мясорубки",
		DATIVE = "миниатюрной мясорубке",
		ACCUSATIVE = "миниатюрную мясорубку",
		INSTRUMENTAL = "миниатюрной мясорубкой",
		PREPOSITIONAL = "миниатюрной мясорубке",
	)

/obj/item/toy/minigibber/attack_self(mob/user)
	if(stored_miniature)
		user.visible_message(span_danger("[DECLENT_RU_CAP(src, NOMINATIVE)] издаёт жуткий скрежет, уничтожая миниатюрную фигурку внутри!"))
		QDEL_NULL(stored_miniature)
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		COOLDOWN_START(src, cooldown, 5 SECONDS)
		return

	if(COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_notice("Вы нажимаете кнопку гиба на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		COOLDOWN_START(src, cooldown, 5 SECONDS)

/obj/item/toy/minigibber/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/toy/character))
		return ..()

	add_fingerprint(user)
	if(stored_miniature)
		to_chat(user, span_warning("Внутри уже есть [stored_miniature.declent_ru(NOMINATIVE)]!"))
		return ATTACK_CHAIN_PROCEED
	user.visible_message(span_notice("[user] вставляет [icon2html(I, viewers(I))] [I.declent_ru(ACCUSATIVE)] в мини-приёмник [declent_ru(GENITIVE)]..."))
	if(!do_after(user, 1 SECONDS, src, category = DA_CAT_TOOL) || stored_miniature)
		return ATTACK_CHAIN_PROCEED
	if(!user.drop_transfer_item_to_loc(I, src))
		return ..()
	to_chat(user, span_notice("Вы вставили [icon2html(I, user)] [I.declent_ru(ACCUSATIVE)] в [declent_ru(GENITIVE)]!"))
	stored_miniature = I
	return ATTACK_CHAIN_BLOCKED_ALL

// MARK: Toy big red button
/obj/item/toy/redbutton
	name = "big red button"
	desc = "Большая красная пластиковая кнопка. На обратной стороне надпись: \"От HonkCo Pranks?\"."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/redbutton/get_ru_names()
	return alist(
		NOMINATIVE = "большая красная кнопка",
		GENITIVE = "большой красной кнопки",
		DATIVE = "большой красной кнопке",
		ACCUSATIVE = "большую красную кнопку",
		INSTRUMENTAL = "большой красной кнопкой",
		PREPOSITIONAL = "большой красной кнопке",
	)

/obj/item/toy/redbutton/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		to_chat(user, span_alert("Ничего не происходит."))
		return FALSE

	user.visible_message(
		span_warning("[user] нажима[PLUR_ET_YUT(user)] большую красную кнопку."),
		span_notice("Вы нажимаете кнопку, раздаётся громкий звук!"),
		span_notice("Кнопка громко щёлкает.")
	)

	addtimer(CALLBACK(src, PROC_REF(boom)), 1 SECONDS)

	COOLDOWN_START(src, cooldown, 30 SECONDS)
	return TRUE

/obj/item/toy/redbutton/proc/boom()
	playsound(src, 'sound/effects/explosionfar.ogg', 50, FALSE, 0)
	for(var/mob/mob_in_range in range(10, get_turf(src))) // Checks range
		if(!mob_in_range.stat && !isAI(mob_in_range)) // Checks to make sure whoever's getting shaken is alive/not the AI
			shake_camera(mob_in_range, 2, 1)

// MARK: Fake handcuffs
/obj/item/restraints/handcuffs/toy
	desc = "Игрушечные наручники. Пластиковые, сделаны крайне дёшево."
	throwforce = 0
	breakout_time = 0
	ignoresClumsy = TRUE

// MARK: Magic 8-Ball
/obj/item/toy/eight_ball
	name = "Magic 8-Ball"
	desc = "Мистический! Волшебный! Для детей от 8 лет!"
	icon_state = "eight-ball"
	var/use_action = "трясёт шар"
	var/list/possible_answers = list("Определённо", "Все признаки указывают на \"да\".", "Скорее всего.", "Да.", "Спроси позже.", "Лучше не сейчас.", "Будущее неясно.", "Возможно.", "Сомнительно.", "Нет.", "Не рассчитывай на это.", "Никогда.")

/obj/item/toy/eight_ball/get_ru_names()
	return alist(
		NOMINATIVE = "бильярдный шар-восьмёрка",
		GENITIVE = "бильярдного шара-восьмёрки",
		DATIVE = "бильярдному шару-восьмёрке",
		ACCUSATIVE = "бильярдный шар-восьмёрку",
		INSTRUMENTAL = "бильярдным шаром-восьмёркой",
		PREPOSITIONAL = "бильярдном шаре-восьмёрке",
	)

/obj/item/toy/eight_ball/attack_self(mob/user as mob)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/answer = pick(possible_answers)
	user.visible_message(span_notice("[user] сосредотачива[PLUR_ET_YUT(user)]ся на своём вопросе и [use_action]..."))
	user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит: \"[answer]\""))

	COOLDOWN_START(src, cooldown, 3 SECONDS)
	return TRUE

/obj/item/toy/eight_ball/conch
	name = "Magic Conch Shell"
	desc = "Да здравствует волшебная раковина!"
	icon_state = "conch"
	use_action = "тянет за верёвочку"
	possible_answers = list("Да.", "Нет.", "Спроси ещё раз.", "Ничего.", "Я так не думаю.", "Ни то, ни другое.", "Может быть, когда-нибудь.")

/obj/item/toy/eight_ball/conch/get_ru_names()
	return alist(
		NOMINATIVE = "волшебная раковина",
		GENITIVE = "волшебной раковины",
		DATIVE = "волшебной раковине",
		ACCUSATIVE = "волшебную раковину",
		INSTRUMENTAL = "волшебной раковиной",
		PREPOSITIONAL = "волшебной раковине",
	)

// MARK: Office desk toys
/obj/item/toy/desk
	abstract_type = /obj/item/toy/desk
	name = "desk toy master"
	desc = "A object that does not exist. Parent Item"
	layer = ABOVE_MOB_LAYER
	var/on = 0
	var/activation_sound = 'sound/items/buttonclick.ogg'

/obj/item/toy/desk/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_rotation)

/obj/item/toy/desk/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/attack_self(mob/user)
	on = !on
	if(activation_sound)
		playsound(src.loc, activation_sound, 75, TRUE)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "Обычная офисная игрушка, работающая на энергии микротермоядерного синтеза. Генерирует только магнетизм и скуку."
	icon_state= "desktoy"

/obj/item/toy/desk/officetoy/get_ru_names()
	return alist(
		NOMINATIVE = "офисная игрушка",
		GENITIVE = "офисной игрушки",
		DATIVE = "офисной игрушке",
		ACCUSATIVE = "офисную игрушку",
		INSTRUMENTAL = "офисной игрушкой",
		PREPOSITIONAL = "офисной игрушке",
	)

/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "Древний человекоподобный идол птицы, которому поклонялись клерки и офисные работники."
	icon_state= "dippybird"

/obj/item/toy/desk/dippingbird/get_ru_names()
	return alist(
		NOMINATIVE = "игрушка \"пьющая птичка\"",
		GENITIVE = "игрушки \"пьющей птички\"",
		DATIVE = "игрушке \"пьющей птички\"",
		ACCUSATIVE = "игрушку \"пьющую птичку\"",
		INSTRUMENTAL = "игрушкой \"пьющей птички\"",
		PREPOSITIONAL = "игрушке \"пьющей птички\"",
	)

/obj/item/toy/desk/newtoncradle
	name = "Newton's cradle"
	desc = "Древняя модель сверхмощного оружия XXI века, демонстрирующая, что сэр Исаак Ньютон — самый смертоносный ублюдок в космосе."
	icon_state = "newtoncradle"
	var/datum/looping_sound/newtonballs/soundloop

/obj/item/toy/desk/newtoncradle/get_ru_names()
	return alist(
		NOMINATIVE = "игрушка \"Колыбель Ньютона\"",
		GENITIVE = "игрушки \"Колыбели Ньютона\"",
		DATIVE = "игрушке \"Колыбели Ньютона\"",
		ACCUSATIVE = "игрушку \"Колыбель Ньютона\"",
		INSTRUMENTAL = "игрушкой \"Колыбелью Ньютона\"",
		PREPOSITIONAL = "игрушке \"Колыбели Ньютона\"",
	)

/obj/item/toy/desk/newtoncradle/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/newtoncradle/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Обычный офисный вентилятор."
	icon_state = "fan"
	var/datum/looping_sound/fanblow/soundloop

/obj/item/toy/desk/fan/get_ru_names()
	return alist(
		NOMINATIVE = "вентилятор",
		GENITIVE = "вентилятора",
		DATIVE = "вентилятору",
		ACCUSATIVE = "вентилятор",
		INSTRUMENTAL = "вентилятором",
		PREPOSITIONAL = "вентиляторе",
	)

/obj/item/toy/desk/fan/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/fan/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()
