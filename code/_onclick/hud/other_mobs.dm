/datum/hud/simple_animal/New(mob/user)
	..()

	mymob.healthdoll = new /atom/movable/screen/healthdoll/living(null, src)
	infodisplay += mymob.healthdoll

	var/atom/movable/screen/using
	using = new /atom/movable/screen/act_intent/simple_animal(null, src)
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using


/datum/hud/corgi/New(mob/user)
	..()

	mymob.healths = new /atom/movable/screen/healths/corgi(null, src)
	infodisplay += mymob.healths

	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = 'icons/mob/screen_corgi.dmi'
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin


/datum/hud/simple_animal/spider/New(mob/user)
	..()

	mymob.pullin = new /atom/movable/screen/pull(null, src)
	mymob.pullin.icon = 'icons/mob/screen_spider.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull_icon"
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin
