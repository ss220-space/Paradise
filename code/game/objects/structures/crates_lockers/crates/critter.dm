/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. It has an oxygen tank for safe transport in space."
	icon_state = "critter"
	base_icon_state = "critter"
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	var/already_opened = TRUE
	var/content_mob = null
	var/amount = 1
	var/datum/gas_mixture/air // Do it using internals/emergency_oxygen ??

/obj/structure/closet/crate/critter/proc/update_air()
	if(!air)
		air = new/datum/gas_mixture()
	air.set_oxygen(MOLES_O2STANDARD)
	air.set_nitrogen(MOLES_N2STANDARD)
	air.set_carbon_dioxide(0)
	air.set_temperature(T20C)

/obj/structure/closet/crate/critter/Initialize(mapload)
	. = ..()
	update_air()

/obj/structure/closet/crate/critter/Destroy()
	QDEL_NULL(air)
	return ..()

/obj/structure/closet/crate/critter/return_obj_air()
	return air

/obj/structure/closet/crate/critter/return_analyzable_air()
	return air

/obj/structure/closet/crate/critter/can_open()
	if(welded)
		return FALSE
	return TRUE

/obj/structure/closet/crate/critter/open(mob/living/user, force)
	if(!can_open())
		return FALSE

	if(isnull(content_mob)) // making sure we don't spawn anything too eldritch
		already_opened = TRUE
		return ..()

	if(!isnull(content_mob) && already_opened == FALSE)
		for(var/i in 1 to amount)
			var/mob/living/simple_animal/pet = new content_mob(loc)
			var/area/syndicate_area = get_area(src)
			if(istype(syndicate_area, /area/syndicate/unpowered/syndicate_space_base))
				pet.faction += "syndicate" // so that the turrets don't shoot at the animals from syndicate cargo
		already_opened = TRUE
	return ..()

/obj/structure/closet/crate/critter/close()
	update_air()
	..()
	return TRUE

/obj/structure/closet/crate/critter/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/obj/structure/closet/crate/critter/corgi
	name = "dog corgi crate"
	content_mob = /mob/living/simple_animal/pet/dog/corgi

/obj/structure/closet/crate/critter/corgi/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/dog/corgi/Lisa

/obj/structure/closet/crate/critter/dog_pug
	name = "dog pug crate"
	content_mob = /mob/living/simple_animal/pet/dog/pug

/obj/structure/closet/crate/critter/dog_bullterrier
	name = "dog bullterrier crate"
	content_mob = /mob/living/simple_animal/pet/dog/bullterrier

/obj/structure/closet/crate/critter/dog_tamaskan
	name = "dog tamaskan crate"
	content_mob = /mob/living/simple_animal/pet/dog/tamaskan

/obj/structure/closet/crate/critter/dog_german
	name = "dog german crate"
	content_mob = /mob/living/simple_animal/pet/dog/german

/obj/structure/closet/crate/critter/dog_brittany
	name = "dog brittany crate"
	content_mob = /mob/living/simple_animal/pet/dog/brittany

/obj/structure/closet/crate/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/crate/critter/pig
	name = "pig crate"
	content_mob = /mob/living/simple_animal/pig

/obj/structure/closet/crate/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/crate/critter/goat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/hostile/retaliate/goat/hump

/obj/structure/closet/crate/critter/turkey
	name = "turkey crate"
	content_mob = /mob/living/simple_animal/turkey

/obj/structure/closet/crate/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/crate/critter/chick/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/crate/critter/cat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/cat/Proc
	if(prob(5))
		content_mob = /mob/living/simple_animal/pet/cat/fat

/obj/structure/closet/crate/critter/cat_white
	name = "white cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/white

/obj/structure/closet/crate/critter/cat_birman
	name = "birman cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/birman

/obj/structure/closet/crate/critter/fox
	name = "fox crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox

/obj/structure/closet/crate/critter/fox/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/dog/fox/forest

/obj/structure/closet/crate/critter/fennec
	name = "fennec crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox/fennec

/obj/structure/closet/crate/critter/butterfly
	name = "butterfly crate"
	content_mob = /mob/living/simple_animal/butterfly

/obj/structure/closet/crate/critter/deer
	name = "deer crate"
	content_mob = /mob/living/simple_animal/deer

/obj/structure/closet/crate/critter/sloth
	name = "sloth crate"
	content_mob = /mob/living/simple_animal/pet/sloth

/obj/structure/closet/crate/critter/goose
	name = "goose crate"
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/crate/critter/gosling
	name = "gosling crate"
	content_mob = /mob/living/simple_animal/goose/gosling

/obj/structure/closet/crate/critter/gosling/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/wooly_mouse
	name = "wolly mice crate"
	content_mob = /mob/living/simple_animal/mouse/wooly

/obj/structure/closet/crate/critter/wooly_mouse/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/crate/critter/frog
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog

/obj/structure/closet/crate/critter/frog/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/frog/toxic
	content_mob = /mob/living/simple_animal/frog/toxic

/obj/structure/closet/crate/critter/snail
	name = "snail crate"
	content_mob = /mob/living/simple_animal/snail

/obj/structure/closet/crate/critter/snail/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/crate/critter/turtle
	name = "turtle crate"
	content_mob = /mob/living/simple_animal/turtle

/obj/structure/closet/crate/critter/iguana
	name = "iguana crate"
	content_mob = /mob/living/simple_animal/hostile/lizard

/obj/structure/closet/crate/critter/gator
	name = "gator crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/gator

/obj/structure/closet/crate/critter/croco
	name = "croco crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/croco

/obj/structure/closet/crate/critter/snake
	name = "snake crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/poison/snake

/obj/structure/closet/crate/critter/slime
	name = "slime crate"
	content_mob = /mob/living/simple_animal/slime

/obj/structure/closet/crate/critter/gorilla
	name = "gorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla

/obj/structure/closet/crate/critter/cargorilla
	name = "cargorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla/cargo_domestic
