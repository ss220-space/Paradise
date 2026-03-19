/obj/item/weapons/tactical_sharpener
	name = "Diamond whetstone"
	desc = "Точильный камень с алмазным напылением"
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "anvil"
	item_state = "anvil"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/weapons/tactical_sharpener/afterattack(obj/item/I, mob/user, proximity)
	if(!proximity)
		return

	if(istype(I, /obj/item/weapons/tactical_hatchet))
		var/obj/item/weapons/tactical_hatchet/H = I

		if(!H.blunt)
			to_chat(user, ("Топор уже заточен"))
			return

		to_chat(user, ("Вы затачиваете топор."))
		H.sharpen()
		balloon_alert(user, "Заточка...")
		if(!do_after(user, 2 SECONDS, user, DA_IGNORE_USER_LOC_CHANGE | DA_IGNORE_LYING))     //тут прогрессбары и задержки заточки
			return

