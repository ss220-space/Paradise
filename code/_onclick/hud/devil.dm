
//Soul counter is stored with the humans, it does weird when you place it here apparently...


/datum/hud/devil/New(mob/owner, ui_style = 'icons/mob/screen_midnight.dmi')
	..()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/drop(null, src)
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = ui_style
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_pull_resist
	static_inventory += mymob.pullin

	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "right hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = ITEM_SLOT_HAND_RIGHT
	static_inventory += inv_box
	hand_slots += inv_box

	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "left hand"
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = ITEM_SLOT_HAND_LEFT
	static_inventory += inv_box
	hand_slots += inv_box

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

	zone_select = new /atom/movable/screen/zone_sel(null, src, ui_style)

	lingchemdisplay = new /atom/movable/screen/ling/chems(null, src)
	devilsouldisplay = new /atom/movable/screen/devil/soul_counter(null, src)
	infodisplay += devilsouldisplay

	for(var/atom/movable/screen/inventory/inv in static_inventory)
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()


/datum/hud/devil/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/true_devil/D = mymob

	if(hud_version != HUD_STYLE_NOHUD)
		if(D.r_hand)
			D.r_hand.screen_loc = ui_rhand
			D.client.screen += D.r_hand
		if(D.l_hand)
			D.l_hand.screen_loc = ui_lhand
			D.client.screen += D.l_hand
	else
		if(D.r_hand)
			D.r_hand.screen_loc = null
		if(D.l_hand)
			D.l_hand.screen_loc = null

/mob/living/carbon/true_devil/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/devil(src, ui_style2icon(client.prefs.UI_style))
