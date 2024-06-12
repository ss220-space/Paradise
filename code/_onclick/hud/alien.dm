/atom/movable/screen/alien
	icon = 'icons/mob/screen_alien.dmi'

/atom/movable/screen/alien/leap
	name = "toggle leap"
	icon_state = "leap_off"

/atom/movable/screen/alien/leap/Click()
	if(isalienhunter(usr))
		var/mob/living/carbon/alien/humanoid/hunter/AH = usr
		AH.toggle_leap()

/atom/movable/screen/alien/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"

/atom/movable/screen/alien/nightvision/Click()
	var/mob/living/carbon/alien/humanoid/A = usr
	A.nightvisiontoggle()


/atom/movable/screen/alien/plasma_display
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display2"
	name = "plasma stored"
	screen_loc = ui_alienplasmadisplay


/mob/living/carbon/alien/humanoid/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/alien(src)

/datum/hud/alien/New(mob/living/carbon/alien/humanoid/owner)
	..()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/language_menu(null, src)
	using.screen_loc = ui_alien_language_menu
	static_inventory += using

	using = new /atom/movable/screen/act_intent/alien(null, src)
	using.icon_state = (mymob.a_intent == "hurt" ? INTENT_HARM : mymob.a_intent)
	using.screen_loc = ui_acti
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/mov_intent(null, src)
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using
	move_intent = using

	if(isalienhunter(mymob))
		mymob.leap_icon = new /atom/movable/screen/alien/leap(null, src)
		mymob.leap_icon.icon = 'icons/mob/screen_alien.dmi'
		mymob.leap_icon.screen_loc = ui_alien_leap
		static_inventory += mymob.leap_icon

//equippable shit
	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "r_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_r"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = ITEM_SLOT_HAND_RIGHT
	static_inventory += inv_box
	hand_slots += inv_box

	inv_box = new /atom/movable/screen/inventory/hand(null, src)
	inv_box.name = "l_hand"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "hand_l"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = ITEM_SLOT_HAND_LEFT
	static_inventory += inv_box
	hand_slots += inv_box

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(null, src)
	using.name = "hand"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "storage1"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_alien_storage_l
	inv_box.slot_id = ITEM_SLOT_POCKET_LEFT
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory(null, src)
	inv_box.name = "storage2"
	inv_box.icon = 'icons/mob/screen_alien.dmi'
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_alien_storage_r
	inv_box.slot_id = ITEM_SLOT_POCKET_RIGHT
	static_inventory += inv_box

//end of equippable shit

	using = new /atom/movable/screen/resist(null, src)
	using.name = "resist"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	static_inventory += using

	using = new /atom/movable/screen/drop(null, src)
	using.name = "drop"
	using.icon = 'icons/mob/screen_alien.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	static_inventory += using

	mymob.throw_icon = new /atom/movable/screen/throw_catch(null, src)
	mymob.throw_icon.icon = 'icons/mob/screen_alien.dmi'
	mymob.throw_icon.screen_loc = ui_drop_throw
	static_inventory += mymob.throw_icon

	mymob.healths = new /atom/movable/screen/healths/alien(null, src)
	infodisplay += mymob.healths

	nightvisionicon = new /atom/movable/screen/alien/nightvision(null, src)
	infodisplay += nightvisionicon

	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = 'icons/mob/screen_alien.dmi'
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_pull_resist
	hotkeybuttons += mymob.pullin

	alien_plasma_display = new /atom/movable/screen/alien/plasma_display(null, src)
	infodisplay += alien_plasma_display

	zone_select = new /atom/movable/screen/zone_sel/alien(null, src)
	static_inventory += zone_select

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance()


/datum/hud/alien/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/alien/humanoid/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
		if(H.r_store)
			H.r_store.screen_loc = ui_alien_storage_r
			H.client.screen += H.r_store
		if(H.l_store)
			H.l_store.screen_loc = ui_alien_storage_l
			H.client.screen += H.l_store
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null
		if(H.r_store)
			H.r_store.screen_loc = null
		if(H.l_store)
			H.l_store.screen_loc = null
