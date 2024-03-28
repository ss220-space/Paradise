/* this is a playing card deck based off of the Rider-Waite Tarot Deck.
*/

/obj/item/deck/tarot
	name = "deck of tarot cards"
	desc = "For all your occult needs!"
	icon_state = "deck_tarot"


/obj/item/deck/tarot/build_deck()
	for(var/tarotname in list("Fool","Magician","High Priestess","Empress","Emperor","Hierophant","Lovers","Chariot","Strength","Hermit","Wheel of Fortune","Justice","Hanged Man","Death","Temperance","Devil","Tower","Star","Moon","Sun","Judgement","World"))
		cards += new /datum/playingcard("[tarotname]", "tarot_major", "card_back_tarot")
	for(var/suit in list("wands","pentacles","cups","swords"))
		for(var/number in list("ace","two","three","four","five","six","seven","eight","nine","ten","page","knight","queen","king"))
			cards += new /datum/playingcard("[number] of [suit]", "tarot_[suit]", "card_back_tarot")


/obj/item/deck/tarot/deckshuffle()
	var/mob/living/user = usr
	if(cooldown < world.time - 1 SECONDS)
		var/list/newcards = list()
		while(cards.len)
			var/datum/playingcard/card = pick(cards)
			card.name = replacetext(card.name," reversed","")
			if(prob(50))
				card.name += " reversed"
			newcards += card
			cards -= card
		cards = newcards
		playsound(user, 'sound/items/cardshuffle.ogg', 50, 1)
		user.visible_message(span_notice("[user] shuffles [src]."), span_notice("You shuffle [src]."))
		cooldown = world.time

