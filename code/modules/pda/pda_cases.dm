/obj/item/pda_case
	name = "silicone PDA сase"
	desc = "Прозрачный силиконовый чехол."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda_case"
	/// New icon state for the PDA
	var/new_icon_state = "pda-clear"
	/// New item state for the PDA
	var/new_item_state = "pda-clear"
	/// New description for the PDA
	var/new_desc = ""
	/// New sound for the received messages, in a format of associative list: sound name -> sound file
	var/list/new_ttone


/obj/item/pda_case/Destroy()
	new_ttone?.Cut()
	return ..()


/obj/item/pda/proc/apply_pda_case(obj/item/pda_case/new_case)
	if(!istype(new_case))
		CRASH("Wrong item passed into apply_pda_case().")
	if(new_case.new_ttone)
		ttone_sound |= new_case.new_ttone
		ttone = new_case.new_ttone[1]
	current_case = new_case
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)


/obj/item/pda/proc/remove_pda_case()
	if(!current_case)
		return
	if(current_case.new_ttone)
		ttone_sound -= current_case.new_ttone
		if(ttone == current_case.new_ttone[1])
			ttone = initial(ttone)
	QDEL_NULL(current_case)
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)


/obj/item/pda_case/beer
	name = "PDA case \"BEER\""
	desc = "Роскошный чехол, олицетворяющий собой кружку пива. Позволяет выбрать уникальный звук для входящих сообщений (\"beer\")."
	icon_state = "pda_case_beer"
	new_desc = "На обратной стороне чехла можно заметить глубокомысленную цитату: \"На станции только и разговоров, что о пиве...\" Использовать PDA как кружку всё ещё не рекомендуется."
	new_icon_state = "pda-beer"
	new_item_state = "pda-beer"
	new_ttone = list("beer" = 'sound/items/PDA/beer.ogg')

