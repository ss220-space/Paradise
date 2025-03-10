/obj/item/grenade/spawnergrenade
	name = "delivery grenade"
	desc = "Она взорвётся через 5 секунд, что вызовет выброс всех содержащихся в ней существ."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver
	spawner_type = /mob/living/simple_animal/hostile/viscerator

/obj/item/grenade/spawnergrenade/prime() // Prime now just handles the two loops that query for people in lockers and people who can see it.
	. = ..()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, TRUE)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_eyes()

		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			if(flags & ADMIN_SPAWNED)
				x.flags |= ADMIN_SPAWNED
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH, SOUTH, EAST, WEST))

			// Spawn some hostile syndicate critters

	qdel(src)
	return

/obj/item/grenade/spawnergrenade/manhacks
	name = "manhack delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/feral_cats
	name = "feral cat delivery grenade"
	desc = "Граната, содержащая 5 дегидратированных кошек!"
	ru_names = list(
		NOMINATIVE = "граната с дикими кошками",
		GENITIVE = "гранаты с дикими кошками",
		DATIVE = "гранате с дикими кошками",
		ACCUSATIVE = "гранату с дикими кошками",
		INSTRUMENTAL = "гранатой с дикими кошками",
		PREPOSITIONAL = "гранате с дикими кошками"
	)
	spawner_type = /mob/living/simple_animal/hostile/feral_cat
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/feral_cats/prime()			//Own proc for this because the regular one would flash people which was dumb.
	update_mob()
	if(spawner_type && deliveryamt)
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)

		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))


	qdel(src)
	return
