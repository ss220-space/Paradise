/atom/movable/screen/swarmer
	icon = 'icons/mob/screen_swarmer.dmi'

/atom/movable/screen/swarmer/Click()
	if(!isswarmer(usr))
		return FALSE
	return TRUE

/atom/movable/screen/swarmer/toggle_light
	icon_state = "ui_light"
	name = "Переключить свет"
	desc = "Включает или выключает встроенную подсветку."

/atom/movable/screen/swarmer/toggle_light/Click()
	if(!..())
		return
	var/mob/living/simple_animal/hostile/swarmer/swarmer = usr
	swarmer.toggle_light()

/atom/movable/screen/swarmer/contact_swarmers
	icon_state = "ui_contact_swarmers"
	name = "Связь роя"
	desc = "Отправить сообщение всем свармерам, если они, конечно, есть."

/atom/movable/screen/swarmer/contact_swarmers/Click()
	if(!..())
		return
	var/mob/living/simple_animal/hostile/swarmer/swarmer = usr
	swarmer.contact_swarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/atom/movable/screen/using

	mymob.healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += mymob.healthdoll

	using = new /atom/movable/screen/act_intent/swarmer(null, src)
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	using = new /atom/movable/screen/swarmer/toggle_light(null, src)
	using.screen_loc = ui_drop_throw
	static_inventory += using

	using = new /atom/movable/screen/swarmer/contact_swarmers(null, src)
	using.screen_loc = ui_inventory
	static_inventory += using
