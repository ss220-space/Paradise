#define MINESWEEPER_ROWS 16
#define MINESWEEPER_COLUMNS 16
#define MINESWEEPER_BOMBS 40

/obj/machinery/arcade/minesweeper
	name = "Cапёр"
	icon_state = "minesweeper"
	desc = "Классическая аркадная игра про флашки, цифры и БОМБЫ."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	light_color = LIGHT_COLOR_LIGHTBLUE
	tts_seed = "Livsy"
	token_price = 100
	/// Livsy says after win
	var/list/win_phrases = list("Ох, ну надо же!", "Вот это да!", "Видимо в этот раз без взрыва!")
	/// Livsy says after loose
	var/list/loose_phrases = list("Ой! Чуть не задело!", "А ведь победа была так близко!", "Бабах!")
	/// Livsy has nothing to do
	var/list/random_phrases = list("Пупупупупу, дай кого-нибудь взорву!", "Не шевелись! Вокруг мины!")

	// Random phrases things
	var/last_random
	var/phrase_delay = 6000

	/// Extra prize if emagged
	var/list/emag_prizes = list(/obj/item/storage/box/bombsecurity, /obj/item/storage/box/thunderdome/bombarda, \
								/obj/item/storage/belt/grenade/frag, /obj/item/grenade/syndieminibomb, \
								/obj/item/storage/box/syndie_kit/c4)

	/// Thing, to make first touch safety
	var/first_touch = TRUE
	// Win condition things
	var/setted_flags = 0
	var/flagged_bombs = 0
	var/opened_cells = 0
	/// Decision to make interface untouchable in the momemnt of regenerating
	var/ignore_touches = FALSE
	/// Tgui message, which shows and hide
	var/show_message = ""
	/// Tech var, here we have all the info
	var/list/minesweeper_matrix = list()
	// generations vars(i didnt check if it works with nonstandart values)
	var/generation_rows = MINESWEEPER_ROWS
	var/generation_columns = MINESWEEPER_COLUMNS
	var/generation_bombs = MINESWEEPER_BOMBS

/obj/machinery/arcade/minesweeper/New()
	. = ..()
	make_empty_matr()
	last_random = world.time + rand(0, phrase_delay)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/arcade/minesweeper/proc/make_empty_matr()
	for(var/i in 1 to generation_rows)
		var/list/new_row = list()
		for(var/j in 1 to generation_columns)
			new_row["[j]"] = list("open" = FALSE, "bomb" = FALSE, "flag" = FALSE, "around" = 0)
		minesweeper_matrix["[i]"] = new_row
	first_touch = TRUE
	ignore_touches = FALSE
	tokens -= 1
	if(tokens < 0)
		tokens = 0
	if(tokens==0)
		SStgui.close_uis(src)
	show_message = ""
	SStgui.update_uis(src)

/obj/machinery/arcade/minesweeper/proc/speak(message)
	if(stat & NOPOWER)
		return
	if(!message)
		return

	atom_say(message)

/obj/machinery/arcade/minesweeper/process()
	. = ..()
	if(((last_random + phrase_delay) <= world.time) && prob(5))
		var/phrase = pick(random_phrases)
		speak(phrase)
		last_random = world.time

/obj/machinery/arcade/minesweeper/start_play(mob/user)
	in_use = FALSE // in_use is /obj/machinery/arcade var, which i do not neew, so i just made it unnessecary
	ui_interact(user)

/obj/machinery/arcade/minesweeper/emag_act(mob/user)
	. = ..()
	emagged = TRUE

/obj/machinery/arcade/minesweeper/update_overlays()
	. = ..()
	if(!(stat & BROKEN) && !(stat & NOPOWER))
		. += "minesweeper_screen"

/obj/machinery/arcade/minesweeper/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Minesweeper", "Сапер", 460, 650)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/arcade/minesweeper/ui_data(mob/user)
	var/list/data = list("matrix" = minesweeper_matrix, "showMessage" = show_message, "tokens" = tokens)
	return data

/obj/machinery/arcade/minesweeper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(ignore_touches)
		return
	switch(action)
		if("Square")
			switch(params["mode"])
				if("bomb")
					if(first_touch)
						generate_matrix(params["X"], params["Y"])
					open_cell(params["X"], params["Y"])
					if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
						on_loose(ui.user)
						SStgui.update_uis(src)
						return
				if("flag")
					if(first_touch || minesweeper_matrix[params["X"]][params["Y"]]["open"])
						return
					if(minesweeper_matrix[params["X"]][params["Y"]]["flag"])
						minesweeper_matrix[params["X"]][params["Y"]]["flag"] = FALSE
						setted_flags -= 1
						if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
							flagged_bombs -= 1
					else
						minesweeper_matrix[params["X"]][params["Y"]]["flag"] = TRUE
						setted_flags += 1
						if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
							flagged_bombs += 1
			check_win(ui.user)
			SStgui.update_uis(src)

/obj/machinery/arcade/minesweeper/proc/check_win(mob/user)
	if(flagged_bombs == generation_bombs && setted_flags == generation_bombs && opened_cells == (generation_rows * generation_columns - generation_bombs))
		on_win()

/obj/machinery/arcade/minesweeper/proc/on_win()
	show_message = "Ура! Победа!"
	ignore_touches = TRUE
	var/prize = /obj/item/stack/tickets
	new prize(get_turf(src), rand(50, 90))
	if(emagged)
		var/emag_prize = pick(emag_prizes)
		new emag_prize(get_turf(src))
	speak(pick(win_phrases))
	playsound(loc, 'sound/machines/ping.ogg', 20, 1)
	addtimer(CALLBACK(src, PROC_REF(make_empty_matr)), 5 SECONDS)

/obj/machinery/arcade/minesweeper/proc/on_loose(mob/user)
	show_message = "Ой-ой! Вот неудача!"
	ignore_touches = TRUE
	speak(pick(loose_phrases))
	if(emagged)
		user.gib()
	playsound(loc, 'sound/effects/explosionfar.ogg', 50, 1)
	addtimer(CALLBACK(src, PROC_REF(make_empty_matr)), 5 SECONDS)

/obj/machinery/arcade/minesweeper/proc/generate_matrix(var/x, var/y)
	var/bombs = 0
	flagged_bombs = 0
	setted_flags = 0
	opened_cells = 0
	var/list/ignore_list = list()
	var/num_x = text2num(x)
	var/num_y = text2num(y)
	for(var/ignore_x in list(num_x-1, num_x, num_x+1))
		for(var/ignore_y in list(num_y-1, num_y, num_y+1))
			ignore_list += "([ignore_x], [ignore_y])"
	while(bombs < generation_bombs)
		var/new_x = "[rand(1, generation_rows)]"
		var/new_y = "[rand(1, generation_columns)]"
		if("([new_x], [new_y])" in ignore_list)
			continue
		if(minesweeper_matrix[new_x][new_y]["bomb"])
			continue
		minesweeper_matrix[new_x][new_y]["bomb"] = TRUE
		if(new_x != "1")
			minesweeper_matrix["[text2num(new_x)-1]"][new_y]["around"] += 1
		if(new_y != "1")
			minesweeper_matrix[new_x]["[text2num(new_y)-1]"]["around"] += 1
		if(new_x != "1" && new_y != "1")
			minesweeper_matrix["[text2num(new_x)-1]"]["[text2num(new_y)-1]"]["around"] += 1
		if(new_x != "[generation_rows]")
			minesweeper_matrix["[text2num(new_x)+1]"][new_y]["around"] += 1
		if(new_y != "[generation_columns]")
			minesweeper_matrix[new_x]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "[generation_rows]" && new_y != "[generation_columns]")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "1" && new_y != "[generation_columns]")
			minesweeper_matrix["[text2num(new_x)-1]"]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "[generation_rows]" && new_y != "1")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)-1]"]["around"] += 1
		bombs++
	first_touch = FALSE

/obj/machinery/arcade/minesweeper/proc/open_cell(x, y)
	if(!minesweeper_matrix[x][y]["open"])
		minesweeper_matrix[x][y]["open"] = TRUE
		opened_cells += 1
		if(minesweeper_matrix[x][y]["flag"])
			minesweeper_matrix[x][y]["flag"] = FALSE
			setted_flags -= 1
			if(minesweeper_matrix[x][y]["bomb"])
				flagged_bombs -= 1
		if(minesweeper_matrix[x][y]["around"] == 0)
			update_zeros(x, y)

/obj/machinery/arcade/minesweeper/proc/update_zeros(x, y)
	var/new_x
	var/new_y

	if(x != "1")
		new_x = "[text2num(x)-1]"
		open_cell(new_x, y)

	if(y != "1")
		new_y = "[text2num(y)-1]"
		open_cell(x, new_y)

	if(x != "[generation_rows]")
		new_x = "[text2num(x)+1]"
		open_cell(new_x, y)

	if(y != "[generation_columns]")
		new_y = "[text2num(y)+1]"
		open_cell(x, new_y)

	if(x != "1" && y != "1")
		new_x = "[text2num(x)-1]"
		new_y = "[text2num(y)-1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "[generation_rows]" && y != "[generation_columns]")
		new_x = "[text2num(x)+1]"
		new_y = "[text2num(y)+1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "1" && y != "[generation_columns]")
		new_x = "[text2num(x)-1]"
		new_y = "[text2num(y)+1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "[generation_rows]" && y != "1")
		new_x = "[text2num(x)+1]"
		new_y = "[text2num(y)-1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

#undef MINESWEEPER_ROWS
#undef MINESWEEPER_COLUMNS
#undef MINESWEEPER_BOMBS
