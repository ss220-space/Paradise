/datum/hud/construct/armoured/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen(null, src)
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "juggernaut_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths


/datum/hud/construct/builder/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen(null, src)
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "artificer_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths


/datum/hud/construct/wraith/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen(null, src)
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "wraith_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths


/datum/hud/construct/harvester/New(mob/owner)
	..()
	mymob.healths = new /atom/movable/screen(null, src)
	mymob.healths.icon = 'icons/mob/screen_construct.dmi'
	mymob.healths.icon_state = "harvester_health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths


/datum/hud/construct/New(mob/owner)
	..()
	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = 'icons/mob/screen_construct.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull
