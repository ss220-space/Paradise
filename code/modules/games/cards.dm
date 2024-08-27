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
	deck_total = length(cards)
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
		to_chat(user, span_notice("You place your cards on the bottom of [src]."))
		update_icon(UPDATE_ICON_STATE)


/obj/item/deck/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/cardhand))
		var/obj/item/cardhand/cardhand = I
		if(cardhand.parentdeck != src)
			to_chat(user, span_warning("You cannot mix cards from different decks."))
			return ATTACK_CHAIN_PROCEED
		if(length(cardhand.cards) > 1)
			var/confirm = tgui_alert(user, "Are you sure you want to put your [length(cardhand.cards)] cards back into the deck?", "Return Hand", list("Yes", "No"))
			if(confirm != "Yes" || !Adjacent(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
				return ATTACK_CHAIN_PROCEED
		for(var/datum/playingcard/card in cardhand.cards)
			cards += card
		qdel(cardhand)
		to_chat(user, span_notice("You place your cards on the bottom of [src]."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/deck/examine(mob/user)
	. = ..()
	. += span_notice("It contains [length(cards) ? length(cards) : "no"] cards")


/obj/item/deck/attack_hand(mob/user)
	draw_card(user)


// Datum actions
/datum/action/item_action/draw_card
	name = "Draw - Draw one card"
	button_icon_state = "draw"
	use_itemicon = FALSE


/datum/action/item_action/draw_card/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		owner.changeNext_click(CLICK_CD_RAPID)
		return D.draw_card(owner)
	return ..()


/datum/action/item_action/deal_card
	name = "Deal - deal one card to a person next to you"
	button_icon_state = "deal_card"
	use_itemicon = FALSE


/datum/action/item_action/deal_card/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card(usr)
	return ..()


/datum/action/item_action/deal_card_multi
	name = "Deal multiple card - Deal multiple card to a person next to you"
	button_icon_state = "deal_card_multi"
	use_itemicon = FALSE


/datum/action/item_action/deal_card_multi/Trigger(left_click = TRUE)
	if(istype(target, /obj/item/deck))
		var/obj/item/deck/D = target
		return D.deal_card_multi(usr)
	return ..()


/datum/action/item_action/shuffle
	name = "Shuffle - shuffle the deck"
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

	if(!length(cards))
		to_chat(user, span_notice("There are no cards in the deck."))
		return

	var/obj/item/cardhand/cardhand = user.is_type_in_hands(/obj/item/cardhand)
	if(cardhand && (cardhand.parentdeck != src))
		to_chat(user, span_warning("You can't mix cards from different decks!"))
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
	user.visible_message(span_notice("[user] draws a card."), span_notice("You draw a card."))
	to_chat(user, span_notice("It's the [play_card]."))


/obj/item/deck/proc/deal_card(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!length(cards))
		to_chat(user, span_warning("There are no cards in the deck!"))
		return

	var/list/players = list()
	for(var/mob/living/carbon/player in viewers(3, user))
		if(!player.incapacitated() && !HAS_TRAIT(player, TRAIT_HANDS_BLOCKED))
			players += player

	if(!length(players))
		to_chat(user, span_warning("There are no players around!"))
		return

	var/mob/living/carbon/target = tgui_input_list(user, "Who do you wish to deal a card to?", "Deal Card", players)
	if(!user || !src || !target || !Adjacent(user) || get_dist(user, target) > 3 || target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED))
		return

	if(!length(cards))
		to_chat(user, span_warning("Deck is empty!"))
		return

	deal_at(user, target, 1)


/obj/item/deck/proc/deal_card_multi(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(!length(cards))
		to_chat(user, span_warning("There are no cards in the deck!"))
		return

	var/dcard = tgui_input_number(usr, "How many card(s) do you wish to deal? You may deal up to [length(cards)] cards.", "Deal Cards", 1, length(cards), 1)
	if(isnull(dcard) || !length(cards) || !Adjacent(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	dcard = clamp(min(round(abs(dcard)), length(cards)), 1, 10)	// we absolutely trust our players

	var/list/players = list()
	for(var/mob/living/carbon/player in viewers(3, user))
		if(!player.incapacitated() && !HAS_TRAIT(player, TRAIT_HANDS_BLOCKED))
			players += player

	if(!length(players))
		to_chat(user, span_warning("You decide to deal <b>[dcard]</b> card\s, but there are no players around!"))
		return
	to_chat(user, span_notice("You decide to deal <b>[dcard]</b> card\s."))

	var/mob/living/carbon/target = tgui_input_list(user, "Who do you wish to deal [dcard] card(s)?", "Deal Card", players)
	if(!user || !src || !target || !Adjacent(user) || get_dist(user, target) > 3 || target.incapacitated() || HAS_TRAIT(target, TRAIT_HANDS_BLOCKED))
		return

	if(length(cards) < dcard)
		to_chat(user, span_warning("The deck has no sufficient amount of cards anymore!"))
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
		user.visible_message(span_notice("[user] deals <b>[dcard]</b> card\s to [user.p_themselves()]."))
	else
		user.visible_message(span_notice("[user] deals <b>[dcard]</b> card\s to [target]."))
	INVOKE_ASYNC(cardhand, TYPE_PROC_REF(/atom/movable, throw_at), get_step(target, target.dir), 3, 1, user)


/obj/item/deck/attack_self(mob/user)
	deckshuffle(user)


/obj/item/deck/AltClick(mob/user)
	if(Adjacent(user))
		deckshuffle(user)


/obj/item/deck/proc/deckshuffle(mob/user)
	if(!COOLDOWN_FINISHED(src, shuffle_cooldown) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	COOLDOWN_START(src, shuffle_cooldown, 1 SECONDS)
	cards = shuffle(cards)
	user.visible_message(span_notice("[user] shuffles [src]."))
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
		user.visible_message(span_notice("[user] picks up [src]."))
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
	desc = "Some playing cards."
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
		if(length(cards) > 1)
			to_chat(user, span_warning("You can only write on a single card at once."))
			return ATTACK_CHAIN_PROCEED
		var/datum/playingcard/card = cards[1]
		if(card.name != "Blank Card")
			to_chat(user, span_notice("You cannot write on that card."))
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
			to_chat(user, span_notice("You cannot mix cards from other decks!"))
			return ATTACK_CHAIN_PROCEED
		cardhand.concealed = concealed
		cards += cardhand.cards
		qdel(cardhand)
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/cardhand/attack_self(mob/user)
	if(length(cards) == 1)
		turn_hand(user)
		return
	user.set_machine(src)
	interact(user)


/obj/item/cardhand/proc/turn_hand(mob/user)
	concealed = !concealed
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
	user.visible_message(span_notice("[user] [concealed ? "conceals" : "reveals"] their hand."))


/obj/item/cardhand/interact(mob/user)
	var/dat = "You have:<br>"
	for(var/card in cards)
		dat += "<a href='byond://?src=[UID()];pick=[card]'>The [card]</a><br>"
	dat += "Which card will you remove next?<br>"
	dat += "<a href='byond://?src=[UID()];pick=Turn'>Turn the hand over</a>"
	var/datum/browser/popup = new(user, "cardhand", "Hand of Cards", 400, 240)
	popup.set_content(dat)
	popup.open()


/obj/item/cardhand/Topic(href, href_list)
	if(..())
		return
	if(usr.stat || !ishuman(usr))
		return
	var/mob/living/carbon/human/cardUser = usr
	if(href_list["pick"])
		if(href_list["pick"] == "Turn")
			turn_hand(usr)
		else
			if(cardUser.is_in_hands(src))
				pickedcard = href_list["pick"]
				Removecard()
		cardUser << browse(null, "window=cardhand")


/obj/item/cardhand/examine(mob/user)
	. = ..()
	if(!concealed && length(cards))
		. += span_notice("It contains:")
		for(var/datum/playingcard/card in cards)
			. += span_notice("the [card.name].")


// Datum action here

/datum/action/item_action/remove_card
	name = "Remove a card - Remove a single card from the hand."
	button_icon_state = "remove_card"
	use_itemicon = FALSE


/datum/action/item_action/remove_card/IsAvailable()
	var/obj/item/cardhand/cardhand = target
	if(length(cardhand.cards) <= 1)
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
	name = "Discard - Place (a) card(s) from your hand in front of you."
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
		pickedcard = tgui_input_list(user, "Which card do you want to remove from the hand?", "Remove Card", pickablecards)
		if(!pickedcard)
			return

	if(QDELETED(src))
		return

	var/datum/playingcard/card = pickablecards[pickedcard]
	if(loc != user) // Don't want people teleporting cards
		return

	user.visible_message(
		span_notice("[user] draws a card from [user.p_their()] hand."),
		span_notice("You take the [pickedcard] from your hand."),
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
	if(!length(cards))
		qdel(src)
		return
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)


/obj/item/cardhand/proc/discard()
	var/mob/living/carbon/user = usr

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/maxcards = min(length(cards), 5)
	var/discards = tgui_input_number(usr, "How many cards do you want to discard? You may discard up to [maxcards] card(s)", "Discard Cards", max_value = maxcards)
	if(discards > maxcards || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	for(var/i in 1 to discards)
		var/list/to_discard = list()
		for(var/datum/playingcard/card in cards)
			to_discard[card.name] = card

		var/discarding = input("Which card do you wish to put down?") as null|anything in to_discard
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
		if(length(cards))
			update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_OVERLAYS)
		if(length(cardhand.cards))
			user.visible_message(
				span_notice("[user] plays the [discarding]."),
				span_notice("You play the [discarding]."),
			)
		cardhand.loc = get_step(user, user.dir)

	if(!length(cards))
		qdel(src)


/obj/item/cardhand/update_appearance(updates = ALL)
	if(!length(cards))
		return
	if(length(cards) <= 2)
		for(var/datum/action/action as anything in actions)
			action.UpdateButtonIcon()
	..()


/obj/item/cardhand/update_name(updates = ALL)
	. = ..()
	if(length(cards) > 1)
		name = "hand of [length(cards)] cards"
	else
		name = "playing card"


/obj/item/cardhand/update_desc(updates = ALL)
	. = ..()
	if(length(cards) > 1)
		desc = "Some playing cards."
	else
		if(concealed)
			desc = "A playing card. You can only see the back."
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

	if(length(cards) == 1)
		var/datum/playingcard/card = cards[1]
		var/image/image = new(icon, (concealed ? "[card.back_icon]" : "[card.card_icon]") )
		image.transform = M
		image.pixel_x += (-5+rand(10))
		image.pixel_y += (-5+rand(10))
		. += image
		return

	var/offset = FLOOR(20/length(cards) + 1, 1)
	// var/i = 0
	for(var/i in 1 to length(cards))
		var/datum/playingcard/card = cards[i]
		if(i >= 20)
			// skip the rest and just draw the last one on top
			. += render_card(cards[length(cards)], M, i, offset)
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

