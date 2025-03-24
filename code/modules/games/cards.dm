/datum/playingcard
	var/name = "playing card"
	var/card_icon = "card_back"
	var/back_icon = "card_back"

/datum/playingcard/New(newname, newcard_icon, newback_icon)
	..()
	if(newname)
		name = newname
	if(newcard_icon)
		card_icon = newcard_icon
	if(newback_icon)
		back_icon = newback_icon


/obj/item/deck
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/playing_cards.dmi'
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0
	actions_types = list(/datum/action/item_action/draw_card, /datum/action/item_action/deal_card, /datum/action/item_action/deal_card_multi, /datum/action/item_action/shuffle)
	var/list/cards = list()
	/// Decks default to a single pack, setting it higher will multiply them by that number
	var/deck_size = 1
	/// The total number of cards. Set on init after the deck is fully built
	var/deck_total = 0
	/// Styling for the cards, if they have multiple sets of sprites
	var/card_style = null
	/// Styling for the deck, it they has multiple sets of sprites
	var/deck_style = null
	/// For decks without a full set of sprites
	var/simple_deck = FALSE
	/// Inherited card hit sound
	var/card_hitsound
	/// Inherited card force
	var/card_force = 0
	/// Inherited card throw force
	var/card_throwforce = 0
	/// Inherited card throw speed
	var/card_throw_speed = 4
	/// Inherited card throw range
	var/card_throw_range = 20
	/// Inherited card verbs
	var/card_attack_verb
	/// Inherited card resistance
	var/card_resistance_flags = FLAMMABLE
	/// To prevent spam shuffle
	COOLDOWN_DECLARE(shuffle_cooldown)


/obj/item/deck/Initialize(mapload)
	. = ..()
	for(var/deck in 1 to deck_size)
		build_deck()
	deck_total = LAZYLEN(cards)
	update_icon(UPDATE_ICON_STATE)


/obj/item/deck/proc/build_deck()
	return

/obj/item/deck/afterattack(atom/target, mob/user, proximity, params)
	if(!istype(target, /obj/item/cardhand))
		return
	var/success
	for(var/obj/item/cardhand/cardhand in target.loc)
		if(cardhand.parentdeck != src)
			continue
		for(var/datum/playingcard/card in cardhand.cards)
			cards += card
		qdel(cardhand)
		success = TRUE

	if(success)
		to_chat(user, span_notice("Вы кладёте свои карты вниз [declent_ru(GENITIVE)]."))
		update_icon(UPDATE_ICON_STATE)


/obj/item/deck/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cardhand))
		var/obj/item/cardhand/cardhand = I
		if(cardhand.parentdeck != src)
			balloon_alert(user, "карты из разных колод!")
			return ATTACK_CHAIN_PROCEED
		if(LAZYLEN(cardhand.cards) > 1)
			var/confirm = tgui_alert(user, "Вы уверены, что хотите вернуть [LAZYLEN(cardhand.cards)] [LAZYLEN(cardhand.cards) < 5 ? "карты" : "карт"] в колоду?", "Вернуть руку?", list("Да", "Нет"))
			if(confirm != "Да" || !Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
				return ATTACK_CHAIN_PROCEED
		for(var/datum/playingcard/card in cardhand.cards)
			cards += card
		qdel(cardhand)
		to_chat(user, span_notice("Вы кладёте свои карты вниз [declent_ru(GENITIVE)]."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/deck/examine(mob/user)
	. = ..()
	. += span_notice("В колоде [LAZYLEN(cards)] [declension_ru(LAZYLEN(cards), "карта", "карты", "карт")].")

/obj/item/deck/attack_hand(mob/user)
	draw_card(user)


// Datum actions
/datum/action/item_action/draw_card
	name = "Взять карту"
	desc = "Взять одну карту."
	button_icon_state = "draw"
	use_itemicon = FALSE


/datum/action/item_action/draw_card/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		owner.changeNext_click(CLICK_CD_RAPID)
		return D.draw_card(owner)
	return ..()


/datum/action/item_action/deal_card
	name = "Раздать карту"
	desc = "Раздать одну карту игроку рядом с вами."
	button_icon_state = "deal_card"
	use_itemicon = FALSE


/datum/action/item_action/deal_card/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card(usr)
	return ..()


/datum/action/item_action/deal_card_multi
	name = "Раздать несколько карт"
	desc = "Раздать несколько карт игроку рядом с вами."
	button_icon_state = "deal_card_multi"
	use_itemicon = FALSE


/datum/action/item_action/deal_card_multi/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card_multi(usr)
	return ..()


/datum/action/item_action/shuffle
	name = "Перетасовать"
	desc = "Перетасовать колоду."
	button_icon_state = "shuffle"
	use_itemicon = FALSE


/datum/action/item_action/shuffle/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deckshuffle(usr)
	return ..()


// Datum actions
/obj/item/deck/proc/draw_card(mob/living/carbon/human/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!LAZYLEN(cards))
		balloon_alert(user, "в колоде нет карт!")
		return

	var/obj/item/cardhand/cardhand = user.is_type_in_hands(/obj/item/cardhand)
	if(cardhand && (cardhand.parentdeck != src))
		balloon_alert(user, "карты из разных колод!")
		return

	if(!cardhand)
		cardhand = new(drop_location())
		user.put_in_hands(cardhand, ignore_anim = FALSE)

	var/datum/playingcard/play_card = cards[1]
	cardhand.cards += play_card
	cards -= play_card
	update_icon(UPDATE_ICON_STATE)
	cardhand.parentdeck = src
	cardhand.update_values()
	cardhand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message(
		span_notice("[user] тян[pluralize_ru(user.gender, "ет", "ут")] карту из колоды."),
		span_notice("Вы тянете карту из колоды. Это <b>[play_card]</b>.")
	)


/obj/item/deck/proc/deal_card(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!LAZYLEN(cards))
		balloon_alert(user, "в колоде нет карт!")
		return

	var/list/players = list()
	for(var/mob/living/carbon/player in viewers(3, user))
		if(!player.incapacitated() && !HAS_TRAIT(player, TRAIT_HANDS_BLOCKED))
			players += player

	if(!LAZYLEN(players))
		balloon_alert(user, "рядом нет игроков!")
		return

	var/mob/living/carbon/target = tgui_input_list(user, "Кому вы хотите раздать карту?", "Раздать карту", players)
	if(!user || !src || !target || !Adjacent(user) || get_dist(user, target) > 3 || target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED))
		return

	if(!LAZYLEN(cards))
		balloon_alert(user, "колода пуста!")
		return

	deal_at(user, target, 1)


/obj/item/deck/proc/deal_card_multi(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!LAZYLEN(cards))
		balloon_alert(user, "в колоде нет карт!")
		return

	var/dcard = tgui_input_number(usr, "Сколько карт вы хотите раздать? Вы можете раздать до <b>[LAZYLEN(cards)] [declension_ru(LAZYLEN(cards), "карты", "карт", "карт")]</b>.", "Раздать карты", 1, LAZYLEN(cards), 1)
	if(isnull(dcard) || !LAZYLEN(cards) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	dcard = clamp(min(round(abs(dcard)), LAZYLEN(cards)), 1, 10)	// we absolutely trust our players

	var/list/players = list()
	for(var/mob/living/carbon/player in viewers(3, user))
		if(!player.incapacitated() && !HAS_TRAIT(player, TRAIT_HANDS_BLOCKED))
			players += player

	if(!LAZYLEN(players))
		to_chat(user, span_warning("Вы хотите раздать <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")], но вокруг нет игроков!"))
		return
	to_chat(user, span_notice("Вы раздаёте <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")]."))

	var/mob/living/carbon/target = tgui_input_list(user, "Кому вы хотите раздать [dcard] [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")]?", "Раздать карты", players)
	if(!user || !src || !target || !Adjacent(user) || get_dist(user, target) > 3 || target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED))
		return

	if(LAZYLEN(cards) < dcard)
		balloon_alert(user, "в колоде недостаточно карт!")
		return

	deal_at(user, target, dcard)


/obj/item/deck/proc/deal_at(mob/user, mob/target, dcard) // Take in the no. of card to be dealt
	var/obj/item/cardhand/cardhand = new(get_step(user, user.dir))
	for(var/i in 1 to dcard)
		cardhand.cards += cards[1]
		cards -= cards[1]
		update_icon(UPDATE_ICON_STATE)
		cardhand.parentdeck = src
		cardhand.update_values()
		cardhand.concealed = TRUE
		cardhand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(user == target)
		user.visible_message(
			span_notice("[user] разда[pluralize_ru(user.gender, "ёт", "ют")] себе <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")]."),
			span_notice("Вы раздаёте себе <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")].")
		)
	else
		user.visible_message(
			span_notice("[user] разда[pluralize_ru(user.gender, "ёт", "ют")] [target] <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")]."),
			span_notice("Вы раздаёте [target] <b>[dcard]</b> [declension_ru(LAZYLEN(cards), "карту", "карты", "карт")].")
		)
	INVOKE_ASYNC(cardhand, TYPE_PROC_REF(/atom/movable, throw_at), get_step(target, target.dir), 3, 1, user)


/obj/item/deck/attack_self(mob/user)
	deckshuffle(user)


/obj/item/deck/click_alt(mob/user)
	deckshuffle(user)
	return CLICK_ACTION_SUCCESS


/obj/item/deck/proc/deckshuffle(mob/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	COOLDOWN_START(src, shuffle_cooldown, 1 SECONDS)
	cards = shuffle(cards)
	user.visible_message(
		span_notice("[user] тасу[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы тасуете [declent_ru(ACCUSATIVE)]."),
	)
	playsound(user, 'sound/items/cardshuffle.ogg', 50, TRUE)


/obj/item/deck/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!.)
		return FALSE

	var/mob/user = usr
	if(over_object != user || user.incapacitated() || !iscarbon(user))
		return FALSE

	if(user.put_in_hands(src, ignore_anim = FALSE))
		add_fingerprint(user)
		user.visible_message(
			span_notice("[user] поднима[pluralize_ru(user.gender, "ет", "ют")] [declent_ru(ACCUSATIVE)]."),
			span_notice("Вы поднимаете [declent_ru(ACCUSATIVE)].")
		)
		return TRUE

	return FALSE


/obj/item/pack
	name = "card pack"
	desc = "For those with disposable income."

	icon_state = "card_pack"
	icon = 'icons/obj/playing_cards.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/list/cards = list()
	var/parentdeck = null // For future card pack that need to be compatible with eachother i.e. cardemon


/obj/item/pack/attack_self(mob/user)
	user.visible_message(span_notice("[name] rips open [src]!"), span_notice("You rip open [src]!"))
	var/obj/item/cardhand/cardhand = new(drop_location())

	cardhand.cards += cards
	cards.Cut()
	user.temporarily_remove_item_from_inventory(src, force = TRUE)
	qdel(src)

	cardhand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.put_in_hands(cardhand, ignore_anim = FALSE)


/obj/item/cardhand
	name = "hand of cards"
	desc = "Несколько игральных карт."
	ru_names = list(
		NOMINATIVE = "игральные карты",
		GENITIVE = "игральных карт",
		DATIVE = "игральным картам",
		ACCUSATIVE = "игральные карты",
		INSTRUMENTAL = "игральными картами",
		PREPOSITIONAL = "игральных картах"
	)
	gender = PLURAL
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	throwforce = 0
	force = 0
	actions_types = list(/datum/action/item_action/remove_card, /datum/action/item_action/discard)
	pickup_sound = 'sound/items/handling/accessory_pickup.ogg'
	drop_sound = 'sound/items/handling/accessory_pickup.ogg'
	var/maxcardlen = 20
	var/concealed = FALSE
	var/list/cards = list()
	/// Tracked direction, which is used when updating the hand's appearance instead of messing with the local dir
	var/direction = NORTH
	var/parentdeck
	/// The player's picked card they want to take out. Stored in the hand so it can be passed onto the verb
	var/pickedcard


/obj/item/cardhand/proc/update_values()
	if(!parentdeck)
		return
	var/obj/item/deck/deck = parentdeck
	hitsound = deck.card_hitsound
	force = deck.card_force
	throwforce = deck.card_throwforce
	throw_speed = deck.card_throw_speed
	throw_range = deck.card_throw_range
	attack_verb = deck.card_attack_verb
	resistance_flags = deck.card_resistance_flags


/obj/item/cardhand/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		if(LAZYLEN(cards) > 1)
			balloon_alert(user, "одна карта за раз!")
			return ATTACK_CHAIN_PROCEED
		var/datum/playingcard/card = cards[1]
		if(card.name != "Blank Card")
			balloon_alert(user, "нельзя писать на этой карте!")
			return ATTACK_CHAIN_PROCEED
		var/rename = rename_interactive(user, card, use_prefix = FALSE, actually_rename = FALSE)
		if(rename && card.name == "Blank Card")
			card.name = rename
		// SNOWFLAKE FOR CAG, REMOVE IF OTHER CARDS ARE ADDED THAT USE THIS.
		card.card_icon = "cag_white_card"
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/cardhand))
		var/obj/item/cardhand/cardhand = I
		if(cardhand.parentdeck != parentdeck)
			balloon_alert(user, "карты из разных колод!")
			return ATTACK_CHAIN_PROCEED
		cardhand.concealed = concealed
		cards += cardhand.cards
		qdel(cardhand)
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/cardhand/attack_self(mob/user)
	if(LAZYLEN(cards) == 1)
		turn_hand(user)
		return
	user.set_machine(src)
	ui_interact(user)


/obj/item/cardhand/proc/turn_hand(mob/user)
	concealed = !concealed
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message(
		span_notice("[user] [concealed ? "скрыва" : "показыва"][pluralize_ru(user.gender, "ет", "ют")] свою руку с картами."),
		span_notice("Вы [concealed ? "скрыва" : "показыва"]ете свою руку с картами.")
	)

/obj/item/cardhand/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlayingCard")
		ui.open()

/obj/item/cardhand/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(usr.stat || !ishuman(usr))
		return

	switch(action)
		if("turn")
			turn_hand(usr)
		if("pick")
			if(ishuman(usr) && usr.is_in_hands(src))
				pickedcard = params["card"]
				Removecard()

	SStgui.update_uis(src)
	return TRUE

/obj/item/cardhand/ui_data(mob/user)
	var/list/data = list()
	data["cards"] = cards

	return data

/obj/item/cardhand/examine(mob/user)
	. = ..()
	if(!concealed && LAZYLEN(cards))
		. += span_notice("Имеется:")
		for(var/datum/playingcard/card in cards)
			. += span_notice("[card.name].")


// Datum action here

/datum/action/item_action/remove_card
	name = "Убрать карту"
	desc = "Убрать одну карту из руки."
	button_icon_state = "remove_card"
	use_itemicon = FALSE


/datum/action/item_action/remove_card/IsAvailable()
	var/obj/item/cardhand/cardhand = target
	if(LAZYLEN(cardhand.cards) <= 1)
		return FALSE
	return ..()


/datum/action/item_action/remove_card/Trigger(left_click = TRUE)
	if(!IsAvailable())
		return
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/cardhand = target
		return cardhand.Removecard()
	return ..()


/datum/action/item_action/discard
	name = "Сбросить"
	desc = "Положить карту(ы) из вашей руки перед собой."
	button_icon_state = "discard"
	use_itemicon = FALSE


/datum/action/item_action/discard/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/cardhand))
		var/obj/item/cardhand/cardhand = target
		return cardhand.discard()
	return ..()


// No more datum action here

/obj/item/cardhand/proc/Removecard()
	var/mob/living/carbon/user = usr

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	var/pickablecards = list()
	for(var/datum/playingcard/card in cards)
		pickablecards[card.name] = card

	if(!pickedcard)
		pickedcard = tgui_input_list(user, "Какую карту вы хотите убрать из руки?", "Убрать карту", pickablecards)
		if(!pickedcard)
			return

	if(QDELETED(src))
		return

	var/datum/playingcard/card = pickablecards[pickedcard]
	if(loc != user) // Don't want people teleporting cards
		return

	user.visible_message(
		span_notice("[user] тян[pluralize_ru(user.gender, "ет", "ют")] карту из своей руки."),
		span_notice("Вы тянете [pickedcard] из своей руки."),
	)
	pickedcard = null

	var/obj/item/cardhand/cardhand = new(drop_location())
	user.put_in_hands(cardhand, ignore_anim = FALSE)
	cardhand.cards += card
	cards -= card
	cardhand.parentdeck = parentdeck
	cardhand.update_values()
	cardhand.concealed = concealed
	cardhand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	if(!LAZYLEN(cards))
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)


/obj/item/cardhand/proc/discard()
	var/mob/living/carbon/user = usr

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/maxcards = min(LAZYLEN(cards), 5)
	var/discards = tgui_input_number(usr, "Сколько карт вы хотите сбросить? Вы можете сбросить до <b>[maxcards]</b> карт[maxcards == 1 ? "ы" : ""].", "Сбросить карты", max_value = maxcards)
	if(discards > maxcards || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	for(var/i in 1 to discards)
		var/list/to_discard = list()
		for(var/datum/playingcard/card in cards)
			to_discard[card.name] = card

		var/discarding = input("Какую карту вы хотите положить?") as null|anything in to_discard
		if(!discarding)
			continue

		if(loc != user) // Don't want people teleporting cards
			return

		if(QDELETED(src))
			return

		var/datum/playingcard/card = to_discard[discarding]
		to_discard.Cut()

		var/obj/item/cardhand/cardhand = new type(drop_location())
		cardhand.cards += card
		cards -= card
		cardhand.concealed = FALSE
		cardhand.parentdeck = parentdeck
		cardhand.update_values()
		cardhand.direction = user.dir
		cardhand.update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(LAZYLEN(cards))
			update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(LAZYLEN(cardhand.cards))
			user.visible_message(
				span_notice("[user] клад[pluralize_ru(user.gender, "ёт", "ют")] [discarding]."),,
				span_notice("Вы кладёте [discarding]."),
			)
		cardhand.loc = get_step(user, user.dir)

	if(!LAZYLEN(cards))
		qdel(src)


/obj/item/cardhand/update_appearance(updates = ALL)
	if(!LAZYLEN(cards))
		return
	if(LAZYLEN(cards) <= 2)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	..()


/obj/item/cardhand/update_name(updates = ALL)
	. = ..()
	if(LAZYLEN(cards) > 1)
		name = "hand of [LAZYLEN(cards)] cards"
		ru_names = list(
			NOMINATIVE = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "а", "ы", "")]",
			GENITIVE = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "ы", "", "")]",
			DATIVE = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "е", "ам", "ам")]",
			ACCUSATIVE = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "у", "ы", "")]",
			INSTRUMENTAL = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "ой", "ами", "ами")]",
			PREPOSITIONAL = "[LAZYLEN(cards)] карт[declension_ru(LAZYLEN(cards), "е", "ах", "ах")]"
		)
	else
		name = "playing card"
		ru_names = list(
			NOMINATIVE = "игральная карта",
			GENITIVE = "игральной карты",
			DATIVE = "игральной карте",
			ACCUSATIVE = "игральную карту",
			INSTRUMENTAL = "игральной картой",
			PREPOSITIONAL = "игральной карте"
		)
	. = ..()


/obj/item/cardhand/update_desc(updates = ALL)
	. = ..()
	if(LAZYLEN(cards) > 1)
		desc = "Какие-то игральные карты."
	else
		if(concealed)
			desc = "Игральная карта. Видна только её рубашка."
		else
			var/datum/playingcard/card = cards[1]
			desc = "\A [card.name]."


/obj/item/cardhand/update_icon_state()
	return


/obj/item/cardhand/update_overlays()
	. = ..()
	var/matrix/M = matrix()
	switch(direction)
		if(NORTH)
			M.Translate( 0,  0)
		if(SOUTH)
			M.Turn(180)
			M.Translate( 0,  4)
		if(WEST)
			M.Turn(-90)
			M.Translate( 3,  0)
		if(EAST)
			M.Turn(90)
			M.Translate(-2,  0)

	if(LAZYLEN(cards) == 1)
		var/datum/playingcard/card = cards[1]
		var/image/image = new(icon, (concealed ? "[card.back_icon]" : "[card.card_icon]") )
		image.transform = M
		image.pixel_x += (-5+rand(10))
		image.pixel_y += (-5+rand(10))
		. += image
		return

	var/offset = FLOOR(20/LAZYLEN(cards) + 1, 1)
	// var/i = 0
	for(var/i in 1 to LAZYLEN(cards))
		var/datum/playingcard/card = cards[i]
		if(i >= 20)
			// skip the rest and just draw the last one on top
			. += render_card(cards[LAZYLEN(cards)], M, i, offset)
			break
		. += render_card(card, M, i, offset)
		i++


/obj/item/cardhand/proc/render_card(datum/playingcard/card, matrix/mat, index, offset)
	var/image/I = new(icon, (concealed ? "[card.back_icon]" : "[card.card_icon]") )
	switch(direction)
		if(SOUTH)
			I.pixel_x = 8 - (offset * index)
		if(WEST)
			I.pixel_y = -6 + (offset * index)
		if(EAST)
			I.pixel_y = 8 - (offset * index)
		else
			I.pixel_x = -7 + (offset * index)
	I.transform = mat
	return I


/obj/item/cardhand/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(user)
		direction = user.dir
	else
		direction = NORTH
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)


/obj/item/cardhand/pickup(mob/user)
	. = ..()
	direction = NORTH
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)

