/mob/living/simple_animal/hostile/guardian/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/guardian(src)

/datum/hud/guardian/New(mob/owner)
	..()
	var/atom/movable/screen/using

	guardianhealthdisplay = new /atom/movable/screen/healths/guardian(null, src)
	infodisplay += guardianhealthdisplay

	using = new /atom/movable/screen/act_intent/guardian(null, src)
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/guardian/Manifest(null, src)
	using.screen_loc = ui_rhand
	static_inventory += using

	using = new /atom/movable/screen/guardian/Recall(null, src)
	using.screen_loc = ui_lhand
	static_inventory += using

	using = new /atom/movable/screen/guardian/ToggleMode(null, src)
	using.screen_loc = ui_storage1
	static_inventory += using

	using = new /atom/movable/screen/guardian/ToggleLight(null, src)
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /atom/movable/screen/guardian/Communicate(null, src)
	using.screen_loc = ui_back
	static_inventory += using


//HUD BUTTONS

/atom/movable/screen/guardian
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"

/atom/movable/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/atom/movable/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		if(G.loc == G.summoner)
			G.Manifest()

/atom/movable/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/atom/movable/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/atom/movable/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/atom/movable/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/atom/movable/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/atom/movable/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/atom/movable/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/atom/movable/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
