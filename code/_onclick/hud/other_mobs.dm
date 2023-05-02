/mob/living/simple_animal/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/simple_animal(src)

/datum/hud/simple_animal/New(mob/user)
	..()

	mymob.healthdoll = new /obj/screen/healthdoll/living()
	infodisplay += mymob.healthdoll

	var/obj/screen/using
	using = new /obj/screen/act_intent/simple_animal()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

//spiders
/mob/living/simple_animal/hostile/poison/giant_spider/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/simple_animal/spider(src)

/mob/living/simple_animal/hostile/poison/terror_spider/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/simple_animal/spider(src)

/mob/living/simple_animal/hostile/retaliate/araneus/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/simple_animal/spider(src)

/datum/hud/simple_animal/spider/New(mob/user)
	..()

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_spider.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull_icon"
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin
