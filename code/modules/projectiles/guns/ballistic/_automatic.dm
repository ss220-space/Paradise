/obj/item/gun/projectile/automatic
	var/select = GUN_BURST_MODE
	can_tactical = TRUE
	can_holster = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)
	var/fire_modes = GUN_MODE_SINGLE_BURST
	var/autofire_delay = 0.2 SECONDS

/obj/item/gun/projectile/automatic/Initialize(mapload)
	if(fire_modes == GUN_MODE_SINGLE_ONLY)
		actions_types = null
	. = ..()

/obj/item/gun/projectile/automatic/ComponentInitialize()
	. = ..()
	if(fire_modes != GUN_MODE_SINGLE_BURST_AUTO)
		return
	select = GUN_AUTO_MODE
	burst_size = 1
	AddComponent(/datum/component/automatic_fire, autofire_delay)

/obj/item/gun/projectile/automatic/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/update_overlays()
	. = ..()
	switch(select)
		if(GUN_SINGLE_MODE)
			. += "[initial(icon_state)]semi"
		if(GUN_BURST_MODE)
			. += "[initial(icon_state)]burst"

/obj/item/gun/projectile/automatic/ui_action_click(mob/user, datum/action/action, leftclick)
	if(istype(action, /datum/action/item_action/toggle_firemode))
		toggle_firemode()
		return TRUE
	. = ..()

/obj/item/gun/projectile/automatic/proc/toggle_firemode()
	if(fire_modes == GUN_MODE_SINGLE_ONLY)
		return // not available change modes
	var/mob/living/carbon/human/user = usr
	select++
	if(select >= fire_modes)
		select = GUN_SINGLE_MODE
	if(select == GUN_BURST_MODE && initial(burst_size) == 1)
		select = GUN_AUTO_MODE //skip burst mode if not configured burst size
	switch(select)
		if(GUN_SINGLE_MODE)
			burst_size = 1
			fire_delay = 0
			balloon_alert(user, "полуавтомат")
		if(GUN_BURST_MODE)
			burst_size = initial(burst_size) == 1 ? 2 : initial(burst_size)
			fire_delay = initial(fire_delay)
			balloon_alert(user, "отсечка по [burst_size] [declension_ru(burst_size, "патрону", "патрона", "патронов")]")
		if(GUN_AUTO_MODE)
			burst_size = 1
			fire_delay = initial(fire_delay)
			balloon_alert(user, "автоматический")
	SEND_SIGNAL(src, COMSIG_GUN_TOGGLE_FIREMODE, user, select)
	playsound(user, 'sound/weapons/gun_interactions/selector.ogg', 100, TRUE)
	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/projectile/automatic/can_shoot(mob/user)
	return get_ammo()

/obj/item/gun/projectile/automatic/CtrlClick(mob/user)
	if(user.is_in_hands(src) && chambered)
		process_chamber(TRUE, TRUE)
		balloon_alert(user, "патрон извлечён")
		playsound(loc, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, TRUE)
		return
	. = ..()
