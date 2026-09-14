/datum/action/cooldown/spell/conjure_item/pitchfork
	name = "Призвать вилы"
	desc = "Призывает/отзывает дьявольские вилы."

	item_type = /obj/item/twohanded/pitchfork/demonic

	button_icon_state = "pitchfork"
	background_icon_state = "bg_demon"
	cooldown_time = 5 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/conjure_item/pitchfork/greater
	name = "Призвать великие вилы"
	item_type = /obj/item/twohanded/pitchfork/demonic/greater

/datum/action/cooldown/spell/conjure_item/pitchfork/ascended
	name = "Призвать вилы Архидьявола"
	item_type = /obj/item/twohanded/pitchfork/demonic/ascended

/datum/action/cooldown/spell/conjure_item/pitchfork/krampus
	name = "Призвать вилы Крампуса"
	item_type = /obj/item/twohanded/pitchfork/demonic/greater/krampus

/datum/action/cooldown/spell/conjure_item/krampus_bag
	name = "Призвать мешок Крампуса"
	item_type = /obj/item/krampus_bag
	button_icon_state = "krampus_bag"
	button_icon = 'icons/obj/items.dmi'
	background_icon_state = "bg_demon"
	cooldown_time = 10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

/datum/action/cooldown/spell/conjure_item/violin
	name = "Призвать золотую скрипку"
	desc = "Призывает/отзывает дьявольскую золотую скрипку."

	item_type = /obj/item/instrument/violin/golden

	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "Non multum gaudeo cum Georgia."

	button_icon_state = "golden_violin"
	background_icon_state = "bg_demon"
