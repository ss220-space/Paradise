/* this is a playing card deck based off of the Rider-Waite Tarot Deck.
*/

/obj/item/deck/tarot
	name = "deck of tarot cards"
	ru_names = list(
		NOMINATIVE = "колода карт таро",
		GENITIVE = "колоды карт таро",
		DATIVE = "колоде карт таро",
		ACCUSATIVE = "колоду карт таро",
		INSTRUMENTAL = "колодой карт таро",
		PREPOSITIONAL = "колоде карт таро"
	)
	desc = "Для всех ваших оккультных нужд!"
	icon_state = "deck_tarot"


/obj/item/deck/tarot/build_deck()
	for(var/tarotname in list("Шут", "Маг", "Верховная Жрица", "Императрица", "Император", "Иерофант", "Влюблённые", "Колесница", "Сила", "Отшельник", "Колесо Фортуны", "Справедливость", "Повешенный", "Смерть", "Умеренность", "Дьявол", "Башня", "Звезда", "Луна", "Солнце", "Суд", "Мир"))
		cards += new /datum/playingcard("[tarotname]", "tarot_major", "card_back_tarot")
	var/list/ru_suit = list(
		"wands" = "жезлов",
		"pentacles" = "пентаклей",
		"cups" = "кубков",
		"swords" = "мечей"
	)
	for(var/suit in list("wands","pentacles","cups","swords"))
		for(var/number in list("Туз", "Двойка", "Тройка", "Четвёрка", "Пятёрка", "Шестёрка", "Семёрка", "Восьмёрка", "Девятка", "Десятка", "Паж", "Рыцарь", "Королева", "Король"))
			cards += new /datum/playingcard("[number] [ru_suit[suit]]", "tarot_[suit]", "card_back_tarot")


/obj/item/deck/tarot/deckshuffle(mob/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	COOLDOWN_START(src, shuffle_cooldown, 1 SECONDS)
	var/list/newcards = list()
	while(cards.len)
		var/datum/playingcard/card = pick_n_take(cards)
		card.name = replacetext(card.name," перевёрнутая", "")
		if(prob(50))
			card.name += " перевёрнутая"
		newcards += card
	cards = newcards
	playsound(user, 'sound/items/cardshuffle.ogg', 50, TRUE)
	user.visible_message(
		span_notice("[user] тасу[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы тасуете [declent_ru(ACCUSATIVE)].")
	)

