/datum/hud/revenant
	var/atom/movable/screen/essence/revenant_essence
	var/atom/movable/screen/souls/revenant_souls

/datum/hud/revenant/New(mob/owner)
	. = ..()
	revenant_essence = new(null, src)
	revenant_souls = new(null, src)
	infodisplay += revenant_essence
	infodisplay += revenant_souls
	var/atom/movable/screen/using
	using = new /atom/movable/screen/act_intent/revenant(null, src)
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

	update_huds()

/datum/hud/revenant/proc/update_huds()
	revenant_essence.update_essence(mymob)
	revenant_souls.update_souls(mymob)

/datum/hud/revenant/Destroy()
	. = ..()
	QDEL_NULL(revenant_essence)
	QDEL_NULL(revenant_souls)

/atom/movable/screen/essence
	name = "доступная эссенция"
	icon_state = "essencehud"
	screen_loc = ui_health
	maptext_y = 5
	maptext_x = 2

/atom/movable/screen/essence/proc/update_essence(mob/living/simple_animal/revenant/owner)
	cut_overlays()
	maptext = null
	var/essence_threshold = owner.essence_regen_cap / 4
	var/hudnum = 1
	if(owner.essence >= essence_threshold)
		hudnum = 2
	if(owner.essence >= essence_threshold*2)
		hudnum = 3
	if(owner.essence >= essence_threshold*3)
		hudnum = 4
	maptext = "<font color='#d3f8fb'>[owner.essence]<br>[owner.essence_regen_cap]<font>"
	add_overlay(image(icon = 'icons/mob/screen_gen.dmi', icon_state = "essencehud-[hudnum]"))
	update_appearance()

/atom/movable/screen/souls
	name = "чистые души"
	icon_state = "soulshud"
	screen_loc = ui_healthdoll
	maptext_x = 19

/atom/movable/screen/souls/proc/update_souls(mob/living/simple_animal/revenant/owner)
	maptext = null
	maptext = "<font color='#d3f8fb'>[owner.perfectsouls]<font>"

/atom/movable/screen/act_intent/revenant
	icon = 'icons/effects/revenant.dmi'
