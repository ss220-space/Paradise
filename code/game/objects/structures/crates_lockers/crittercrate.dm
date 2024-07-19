/obj/structure/closet/critter
	name = "critter crate"
	desc = "A crate designed for safe transport of animals. Only openable from the outside."
	icon_state = "critter"
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	var/already_opened = 0
	var/content_mob = null
	var/amount = 1
	var/datum/gas_mixture/env

/obj/structure/closet/critter/proc/updateEnv()
	if(!env)
		env = new/datum/gas_mixture()
	env.oxygen = MOLES_O2STANDARD
	env.nitrogen = MOLES_N2STANDARD
	env.carbon_dioxide = 0
	env.temperature = T20C

/obj/structure/closet/critter/Initialize(mapload)
    . = ..()
    updateEnv()

/obj/structure/closet/critter/Destroy()
	. = ..()
	QDEL_NULL(env)

/obj/structure/closet/critter/return_air()
	return env

/obj/structure/closet/critter/assume_air(datum/gas_mixture/giver)
	return null

/obj/structure/closet/critter/remove_air(amount)
	return env

/obj/structure/closet/critter/return_analyzable_air()
	return env

/obj/structure/closet/critter/can_open()
	if(welded)
		return 0
	return 1

/obj/structure/closet/critter/open()
	if(!can_open())
		return 0

	if(content_mob == null) //making sure we don't spawn anything too eldritch
		already_opened = 1
		return ..()

	if(content_mob != null && already_opened == 0)
		for(var/i = 1, i <= amount, i++)
			var/mob/living/simple_animal/pet = new content_mob(loc)
			var/area/SA = get_area(src)
			if(istype(SA, /area/syndicate/unpowered/syndicate_space_base))
				pet.faction += "syndicate" //чтобы туррели по зверушкам из синди карго не стреляли
		already_opened = 1
	. = ..()

/obj/structure/closet/critter/close()
	updateEnv()
	..()
	return 1

/obj/structure/closet/critter/shove_impact(mob/living/target, mob/living/attacker)
	return FALSE

/obj/structure/closet/critter/corgi
	name = "dog corgi crate"
	content_mob = /mob/living/simple_animal/pet/dog/corgi

/obj/structure/closet/critter/corgi/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/dog/corgi/Lisa

/obj/structure/closet/critter/dog_pug
	name = "dog pug crate"
	content_mob = /mob/living/simple_animal/pet/dog/pug

/obj/structure/closet/critter/dog_bullterrier
	name = "dog bullterrier crate"
	content_mob = /mob/living/simple_animal/pet/dog/bullterrier

/obj/structure/closet/critter/dog_tamaskan
	name = "dog tamaskan crate"
	content_mob = /mob/living/simple_animal/pet/dog/tamaskan

/obj/structure/closet/critter/dog_german
	name = "dog german crate"
	content_mob = /mob/living/simple_animal/pet/dog/german

/obj/structure/closet/critter/dog_brittany
	name = "dog brittany crate"
	content_mob = /mob/living/simple_animal/pet/dog/brittany

/obj/structure/closet/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/pig
	name = "pig crate"
	content_mob = /mob/living/simple_animal/pig

/obj/structure/closet/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/turkey
	name = "turkey crate"
	content_mob = /mob/living/simple_animal/turkey

/obj/structure/closet/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/chick/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/critter/cat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/cat/Proc
	if(prob(5))
		content_mob = /mob/living/simple_animal/pet/cat/fat

/obj/structure/closet/critter/cat_white
	name = "white cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/white

/obj/structure/closet/critter/cat_birman
	name = "birman cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/birman

/obj/structure/closet/critter/fox
	name = "fox crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox

/obj/structure/closet/critter/fox/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/dog/fox/forest

/obj/structure/closet/critter/fennec
	name = "fennec crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox/fennec

/obj/structure/closet/critter/butterfly
	name = "butterfly crate"
	content_mob = /mob/living/simple_animal/butterfly

/obj/structure/closet/critter/deer
	name = "deer crate"
	content_mob = /mob/living/simple_animal/deer

/obj/structure/closet/critter/sloth
	name = "sloth crate"
	content_mob = /mob/living/simple_animal/pet/sloth

/obj/structure/closet/critter/goose
	name = "goose crate"
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/critter/gosling
	name = "gosling crate"
	content_mob = /mob/living/simple_animal/goose/gosling

/obj/structure/closet/critter/gosling/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/hamster
	name = "hamster crate"
	content_mob = /mob/living/simple_animal/mouse/hamster

/obj/structure/closet/critter/hamster/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/frog
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog

/obj/structure/closet/critter/frog/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/frog/toxic
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog/toxic

/obj/structure/closet/critter/snail
	name = "snail crate"
	content_mob = /mob/living/simple_animal/snail

/obj/structure/closet/critter/snail/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/turtle
	name = "turtle crate"
	content_mob = /mob/living/simple_animal/turtle

/obj/structure/closet/critter/iguana
	name = "iguana crate"
	content_mob = /mob/living/simple_animal/hostile/lizard

/obj/structure/closet/critter/gator
	name = "gator crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/gator

/obj/structure/closet/critter/croco
	name = "croco crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/croco

/obj/structure/closet/critter/snake
	name = "snake crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/poison/snake

/obj/structure/closet/critter/slime
	name = "slime crate"
	content_mob = /mob/living/simple_animal/slime

/obj/structure/closet/critter/gorilla
	name = "gorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla

/obj/structure/closet/critter/cargorilla
	name = "cargorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla/cargo_domestic

