/obj/machinery/gameboard
	name = "Virtual Gameboard"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "gboard_on"
	desc = "A holographic table allowing the crew to have fun(TM) on boring shifts! One player per board."
	density = 1
	anchored = TRUE
	use_power = IDLE_POWER_USE
	var/cooling_down = 0
	light_color = LIGHT_COLOR_LIGHTBLUE
	var/list/processing_players = list()

/obj/machinery/gameboard/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/gameboard(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/cable_coil(null, 3)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)
	RefreshParts()

/obj/machinery/gameboard/process()
	for(var/player in processing_players)
		var/mob/p = player
		if(get_dist(src, p) > 1 && !istype(p, /mob/living/silicon))
			close_game(p)

/obj/machinery/gameboard/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(3, 3)


/obj/machinery/gameboard/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "gboard_off"
	else
		icon_state = "gboard_on"

/obj/machinery/gameboard/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(src.in_use)
		to_chat(user, "This gameboard is already in use!")
		return
	if(!anchored)
		to_chat(user, "The gameboard is not secured!")
		return
	interact(user)

/obj/machinery/gameboard/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	dat = replacetext(file2text('html/chess.html'), "\[hsrc]", UID())
	var/datum/asset/simple/chess/assets = get_asset_datum(/datum/asset/simple/chess)
	assets.send(user)

	var/datum/browser/popup = new(user, "SpessChess", name, 500, 800, src)
	popup.set_content(dat)
	popup.add_stylesheet("chess.css", 'html/browser/chess.css')
	popup.add_script("garbochess.js", 'html/browser/garbochess.js')
	//popup.add_script("boardui.js", 'html/browser/boardui.js')
	popup.add_script("jquery-1.8.2.min.js", 'html/browser/jquery-1.8.2.min.js')
	popup.add_script("jquery-ui-1.8.24.custom.min.js", 'html/browser/jquery-ui-1.8.24.custom.min.js')
	popup.set_window_options("titlebar=0")
	popup.open()
	user.set_machine(src)
	processing_players |= user

/obj/machinery/gameboard/proc/close_game(mob/user) //yes, shamelessly copied over from arcade_base
	in_use = 0
	user.unset_machine(src)
	user << browse(null, "window=SpessChess")
	if(user in processing_players)
		processing_players -= user
	return

/obj/machinery/gameboard/Topic(var/href, var/list/href_list)
	. = ..()
	var/prize = /obj/item/stack/tickets
	if(.)
		close_game(usr)
		return

	if(href_list["checkmate"])
		if(cooling_down)
			message_admins("Too many checkmates on chessboard, possible HREF exploits: [ADMIN_LOOKUPFLW(usr)]")
			return
		visible_message(span_info("[span_name("[src.name]")] beeps, \"WINNER!\""))
		new prize(get_turf(src), 80)
		close_game()
		cooling_down = 1
		spawn(600)
			cooling_down = 0

	if(href_list["close"])
		close_game(usr)

/obj/machinery/gameboard/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I, ignore_panel = TRUE))
		return TRUE

/obj/machinery/gameboard/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE
