//Ponchos!

/obj/item/clothing/neck/poncho
	name = "classic poncho"
	desc = "It can protect you from the scorching sun and save your strength in the desert. You can buy one of these for a fistful of credits."
	icon_state = "classicponcho"
	dying_key = DYE_REGISTRY_PONCHO
	var/flipped = FALSE
	item_color = "classic"
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/neck.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/neck.dmi',
		SPECIES_KIDAN = 'icons/mob/clothing/species/kidan/neck.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/neck.dmi',
		SPECIES_PLASMAMAN = 'icons/mob/clothing/species/plasmaman/neck.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/neck.dmi',
		SPECIES_ASHWALKER_BASIC = 'icons/mob/clothing/species/unathi/neck.dmi',
		SPECIES_ASHWALKER_SHAMAN = 'icons/mob/clothing/species/unathi/neck.dmi',
		SPECIES_DRACONOID =  'icons/mob/clothing/species/unathi/neck.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/neck.dmi',
		SPECIES_WRYN = 'icons/mob/clothing/species/wryn/neck.dmi'
	)

/obj/item/clothing/neck/poncho/update_icon_state()
	icon_state = "[item_color]poncho[flipped ? "_flip" : ""]"


/obj/item/clothing/neck/poncho/AltClick(mob/living/carbon/human/user)
	if(!(src in user))
		return ..()

	flip(user)


/obj/item/clothing/neck/poncho/verb/flip_poncho()
	set name = "Flip poncho"
	set category = "Object"
	set desc = "Flip poncho behind your back"
	set src in usr

	flip(usr)


/obj/item/clothing/neck/poncho/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	if(flipped)
		flipped = FALSE
		update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/neck/poncho/equipped(mob/user, slot, initial)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		if((slot != human.neck) && flipped)
			flipped = FALSE
			update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/neck/poncho/proc/flip(mob/living/carbon/human/user)
	if(!ishuman(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(user.neck != src)
		to_chat(user, span_warning("Poncho must be equipped before flipping!"))
		return
	flipped = !flipped
	update_icon(UPDATE_ICON_STATE)
	if(flipped)
		to_chat(user, "You flip [src] behind your back.")
	else
		to_chat(user, "You flip [src] to its normal position.")
	user.update_inv_neck()

/obj/item/clothing/neck/poncho/red
	name = "red poncho"
	desc = "It is a red dead color. It makes you look like a rascal."
	icon_state = "redponcho"
	item_color = "red"

/obj/item/clothing/neck/poncho/orange
	name = "orange poncho"
	desc = "This one in particular is especially nice for fooling around in."
	icon_state = "orangeponcho"
	item_color = "orange"

/obj/item/clothing/neck/poncho/yellow
	name = "yellow poncho"
	desc = "A souvenir shop curio straight from New New Mexico. Hola, Amigo!"
	icon_state = "yellowponcho"
	item_color = "yellow"

/obj/item/clothing/neck/poncho/green
	name = "green poncho"
	desc = "The lines on the cloth continue the mustache line quite well."
	icon_state = "greenponcho"
	item_color = "green"

/obj/item/clothing/neck/poncho/blue
	name = "blue poncho"
	desc = "Every bounty hunter's modern day outfit. Well conceals holster, ammunition loadout, body armor, scabbard, a pair of handguns, sawed-off shotgun and grenades."
	icon_state = "blueponcho"
	item_color = "blue"

/obj/item/clothing/neck/poncho/purple
	name = "purple poncho"
	desc = "The case when modern designers butchered the classics."
	icon_state = "purpleponcho"
	item_color = "purple"

/obj/item/clothing/neck/poncho/white
	name = "white poncho"
	desc = "An exact replica of the most famous gunfighter on the New Frontier. The one who was shot in a gunfight."
	icon_state = "whiteponcho"
	item_color = "white"

/obj/item/clothing/neck/poncho/black
	name = "black poncho"
	desc = "Label states, \"Do not ride your horse faster than 88 miles per hour to avoid breaking the time loop.\""
	icon_state = "blackponcho"
	item_color = "black"

/obj/item/clothing/neck/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseperable. Literally."
	icon_state = "shameponcho"
	item_color = "shame"
	undyeable = TRUE


/obj/item/clothing/neck/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/neck/poncho/security
	name = "corporate poncho"
	desc = "Пончо в корпоративных цветах, при его виде пропадает желание нелегально пересекать сектор"
	icon_state = "secponcho"
	item_color = "sec"

/obj/item/clothing/neck/poncho/mime
	name = "black and white poncho"
	desc = "The motley patterns unfold throughout the garment, forming the outline of a skull on the back."
	icon_state = "mimeponcho"
	item_color = "mime"

/obj/item/clothing/neck/poncho/rainbow
	name = "multicolored poncho"
	desc = "Popular among pacifists and other drug addicts."
	icon_state = "rainbowponcho"
	item_color = "rainbow"

/obj/item/clothing/neck/poncho/tactical
	name = "tactical poncho"
	desc = "A short and black poncho for some tactical operations in hot areas of space."
	icon_state = "tacticalponcho"
	item_color = "tactical"
	sprite_sheets = list()
	undyeable = TRUE
