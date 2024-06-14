/obj/machinery/minesweeper
	name = "Minesweeper"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gboard_on"
	desc = "A holographic table allowing the crew to have fun(TM) on boring shifts! One player per board."
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/first_touch = TRUE
	var/setted_flags = 0
	var/flagged_bombs = 0
	var/opened_cells = 0
	var/list/minesweeper_matrix = list()

/obj/machinery/minesweeper/New()
	. = ..()
	make_empty_matr()

/obj/machinery/minesweeper/proc/make_empty_matr()
	for(var/i in 1 to 16)
		var/list/new_row = list()
		for(var/j in 1 to 16)
			new_row["[j]"] = list("open" = FALSE, "bomb" = FALSE, "flag" = FALSE, "around" = 0)
		minesweeper_matrix["[i]"] = new_row
	first_touch = TRUE

/obj/machinery/minesweeper/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!anchored)
		to_chat(user, "The gameboard is not secured!")
		return
	ui_interact(user)

/obj/machinery/minesweeper/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Minesweeper", "Minesweeper", 800, 800)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/minesweeper/ui_data(mob/user)
	var/list/data = list("matrix" = minesweeper_matrix)
	return data

/obj/machinery/minesweeper/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("Square")
			switch(params["mode"])
				if("bomb")
					if(first_touch)
						generate_matrix(params["X"], params["Y"])
					open_cell(params["X"], params["Y"])
					if(minesweeper_matrix[params["X"]][params["Y"]]["bomb"])
						to_chat(ui.user, "Лошара проиграл")
						make_empty_matr()
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

/obj/machinery/minesweeper/proc/check_win(mob/user)
	if(flagged_bombs == 40 && setted_flags == 40 && opened_cells == (16 * 16 - 40))
		to_chat(user, "МОЛОДЦА")
		make_empty_matr()

/obj/machinery/minesweeper/proc/generate_matrix(var/x, var/y)
	var/bombs = 0
	flagged_bombs = 0
	setted_flags = 0
	opened_cells = 0
	while(bombs < 40)
		var/new_x = "[rand(1, 16)]"
		var/new_y = "[rand(1, 16)]"
		if(new_x == x && new_y == y)
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
		if(new_x != "16")
			minesweeper_matrix["[text2num(new_x)+1]"][new_y]["around"] += 1
		if(new_y != "16")
			minesweeper_matrix[new_x]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "16" && new_y != "16")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "1" && new_y != "16")
			minesweeper_matrix["[text2num(new_x)-1]"]["[text2num(new_y)+1]"]["around"] += 1
		if(new_x != "16" && new_y != "1")
			minesweeper_matrix["[text2num(new_x)+1]"]["[text2num(new_y)-1]"]["around"] += 1
		bombs++
	first_touch = FALSE

/obj/machinery/minesweeper/proc/open_cell(x, y)
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

/obj/machinery/minesweeper/proc/update_zeros(x, y)
	var/new_x
	var/new_y

	if(x != "1")
		new_x = "[text2num(x)-1]"
		open_cell(new_x, y)

	if(y != "1")
		new_y = "[text2num(y)-1]"
		open_cell(x, new_y)

	if(x != "16")
		new_x = "[text2num(x)+1]"
		open_cell(new_x, y)

	if(y != "16")
		new_y = "[text2num(y)+1]"
		open_cell(x, new_y)

	if(x != "1" && y != "1")
		new_x = "[text2num(x)-1]"
		new_y = "[text2num(y)-1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "16" && y != "16")
		new_x = "[text2num(x)+1]"
		new_y = "[text2num(y)+1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "1" && y != "16")
		new_x = "[text2num(x)-1]"
		new_y = "[text2num(y)+1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)

	if(x != "16" && y != "1")
		new_x = "[text2num(x)+1]"
		new_y = "[text2num(y)-1]"
		if(minesweeper_matrix[new_x][y]["open"] && minesweeper_matrix[x][new_y]["open"])
			open_cell(new_x, new_y)
