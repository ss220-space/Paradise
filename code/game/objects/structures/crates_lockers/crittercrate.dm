/obj/structure/closet/critter
	name = "critter crate"
	desc = "Деревянный ящик. \
			Предназначен для транспортировки животных. \
			Открытие изнутри невозможно."
	ru_names = list(
		NOMINATIVE = "ящик для животных",
		GENITIVE = "ящика для животных",
		DATIVE = "ящику для животных",
		ACCUSATIVE = "ящик для животных",
		INSTRUMENTAL = "ящиком для животных",
		PREPOSITIONAL = "ящике для животных"
	)
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
	ru_names = list(
		NOMINATIVE = "ящик для животных (Корги)",
		GENITIVE = "ящика для животных (Корги)",
		DATIVE = "ящику для животных (Корги)",
		ACCUSATIVE = "ящик для животных (Корги)",
		INSTRUMENTAL = "ящиком для животных (Корги)",
		PREPOSITIONAL = "ящике для животных (Корги)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/corgi

/obj/structure/closet/critter/corgi/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/dog/corgi/Lisa

/obj/structure/closet/critter/dog_pug
	name = "dog pug crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Мопс)",
		GENITIVE = "ящика для животных (Мопс)",
		DATIVE = "ящику для животных (Мопс)",
		ACCUSATIVE = "ящик для животных (Мопс)",
		INSTRUMENTAL = "ящиком для животных (Мопс)",
		PREPOSITIONAL = "ящике для животных (Мопс)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/pug

/obj/structure/closet/critter/dog_bullterrier
	name = "dog bullterrier crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Бультерьер)",
		GENITIVE = "ящика для животных (Бультерьер)",
		DATIVE = "ящику для животных (Бультерьер)",
		ACCUSATIVE = "ящик для животных (Бультерьер)",
		INSTRUMENTAL = "ящиком для животных (Бультерьер)",
		PREPOSITIONAL = "ящике для животных (Бультерьер)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/bullterrier

/obj/structure/closet/critter/dog_tamaskan
	name = "dog tamaskan crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Тамасканская собака)",
		GENITIVE = "ящика для животных (Тамасканская собака)",
		DATIVE = "ящику для животных (Тамасканская собака)",
		ACCUSATIVE = "ящик для животных (Тамасканская собака)",
		INSTRUMENTAL = "ящиком для животных (Тамасканская собака)",
		PREPOSITIONAL = "ящике для животных (Тамасканская собака)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/tamaskan

/obj/structure/closet/critter/dog_german
	name = "dog german crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Немецкая овчарка)",
		GENITIVE = "ящика для животных (Немецкая овчарка)",
		DATIVE = "ящику для животных (Немецкая овчарка)",
		ACCUSATIVE = "ящик для животных (Немецкая овчарка)",
		INSTRUMENTAL = "ящиком для животных (Немецкая овчарка)",
		PREPOSITIONAL = "ящике для животных (Немецкая овчарка)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/german

/obj/structure/closet/critter/dog_brittany
	name = "dog brittany crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Бретонский эпаньоль)",
		GENITIVE = "ящика для животных (Бретонский эпаньоль)",
		DATIVE = "ящику для животных (Бретонский эпаньоль)",
		ACCUSATIVE = "ящик для животных (Бретонский эпаньоль)",
		INSTRUMENTAL = "ящиком для животных (Бретонский эпаньоль)",
		PREPOSITIONAL = "ящике для животных (Бретонский эпаньоль)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/brittany

/obj/structure/closet/critter/cow
	name = "cow crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Корова)",
		GENITIVE = "ящика для животных (Корова)",
		DATIVE = "ящику для животных (Корова)",
		ACCUSATIVE = "ящик для животных (Корова)",
		INSTRUMENTAL = "ящиком для животных (Корова)",
		PREPOSITIONAL = "ящике для животных (Корова)"
	)
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/critter/pig
	name = "pig crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Свинья)",
		GENITIVE = "ящика для животных (Свинья)",
		DATIVE = "ящику для животных (Свинья)",
		ACCUSATIVE = "ящик для животных (Свинья)",
		INSTRUMENTAL = "ящиком для животных (Свинья)",
		PREPOSITIONAL = "ящике для животных (Свинья)"
	)
	content_mob = /mob/living/simple_animal/pig

/obj/structure/closet/critter/goat
	name = "goat crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Козёл)",
		GENITIVE = "ящика для животных (Козёл)",
		DATIVE = "ящику для животных (Козёл)",
		ACCUSATIVE = "ящик для животных (Козёл)",
		INSTRUMENTAL = "ящиком для животных (Козёл)",
		PREPOSITIONAL = "ящике для животных (Козёл)"
	)
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/critter/goat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/hostile/retaliate/goat/hump

/obj/structure/closet/critter/turkey
	name = "turkey crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Индейка)",
		GENITIVE = "ящика для животных (Индейка)",
		DATIVE = "ящику для животных (Индейка)",
		ACCUSATIVE = "ящик для животных (Индейка)",
		INSTRUMENTAL = "ящиком для животных (Индейка)",
		PREPOSITIONAL = "ящике для животных (Индейка)"
	)
	content_mob = /mob/living/simple_animal/turkey

/obj/structure/closet/critter/chick
	name = "chicken crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Курица)",
		GENITIVE = "ящика для животных (Курица)",
		DATIVE = "ящику для животных (Курица)",
		ACCUSATIVE = "ящик для животных (Курица)",
		INSTRUMENTAL = "ящиком для животных (Курица)",
		PREPOSITIONAL = "ящике для животных (Курица)"
	)
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/critter/chick/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/cat
	name = "cat crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Кошка)",
		GENITIVE = "ящика для животных (Кошка)",
		DATIVE = "ящику для животных (Кошка)",
		ACCUSATIVE = "ящик для животных (Кошка)",
		INSTRUMENTAL = "ящиком для животных (Кошка)",
		PREPOSITIONAL = "ящике для животных (Кошка)"
	)
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/critter/cat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/cat/Proc
	if(prob(5))
		content_mob = /mob/living/simple_animal/pet/cat/fat

/obj/structure/closet/critter/cat_white
	name = "white cat crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Белая кошка)",
		GENITIVE = "ящика для животных (Белая кошка)",
		DATIVE = "ящику для животных (Белая кошка)",
		ACCUSATIVE = "ящик для животных (Белая кошка)",
		INSTRUMENTAL = "ящиком для животных (Белая кошка)",
		PREPOSITIONAL = "ящике для животных (Белая кошка)"
	)
	content_mob = /mob/living/simple_animal/pet/cat/white

/obj/structure/closet/critter/cat_birman
	name = "birman cat crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Бирманская кошка)",
		GENITIVE = "ящика для животных (Бирманская кошка)",
		DATIVE = "ящику для животных (Бирманская кошка)",
		ACCUSATIVE = "ящик для животных (Бирманская кошка)",
		INSTRUMENTAL = "ящиком для животных (Бирманская кошка)",
		PREPOSITIONAL = "ящике для животных (Бирманская кошка)"
	)
	content_mob = /mob/living/simple_animal/pet/cat/birman

/obj/structure/closet/critter/fox
	name = "fox crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Лиса)",
		GENITIVE = "ящика для животных (Лиса)",
		DATIVE = "ящику для животных (Лиса)",
		ACCUSATIVE = "ящик для животных (Лиса)",
		INSTRUMENTAL = "ящиком для животных (Лиса)",
		PREPOSITIONAL = "ящике для животных (Лиса)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/fox

/obj/structure/closet/critter/fox/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/dog/fox/forest

/obj/structure/closet/critter/fennec
	name = "fennec crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Фенёк)",
		GENITIVE = "ящика для животных (Фенёк)",
		DATIVE = "ящику для животных (Фенёк)",
		ACCUSATIVE = "ящик для животных (Фенёк)",
		INSTRUMENTAL = "ящиком для животных (Фенёк)",
		PREPOSITIONAL = "ящике для животных (Фенёк)"
	)
	content_mob = /mob/living/simple_animal/pet/dog/fox/fennec

/obj/structure/closet/critter/butterfly
	name = "butterfly crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Бабочка)",
		GENITIVE = "ящика для животных (Бабочка)",
		DATIVE = "ящику для животных (Бабочка)",
		ACCUSATIVE = "ящик для животных (Бабочка)",
		INSTRUMENTAL = "ящиком для животных (Бабочка)",
		PREPOSITIONAL = "ящике для животных (Бабочка)"
	)
	content_mob = /mob/living/simple_animal/butterfly

/obj/structure/closet/critter/deer
	name = "deer crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Олень)",
		GENITIVE = "ящика для животных (Олень)",
		DATIVE = "ящику для животных (Олень)",
		ACCUSATIVE = "ящик для животных (Олень)",
		INSTRUMENTAL = "ящиком для животных (Олень)",
		PREPOSITIONAL = "ящике для животных (Олень)"
	)
	content_mob = /mob/living/simple_animal/deer

/obj/structure/closet/critter/sloth
	name = "sloth crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Ленивец)",
		GENITIVE = "ящика для животных (Ленивец)",
		DATIVE = "ящику для животных (Ленивец)",
		ACCUSATIVE = "ящик для животных (Ленивец)",
		INSTRUMENTAL = "ящиком для животных (Ленивец)",
		PREPOSITIONAL = "ящике для животных (Ленивец)"
	)
	content_mob = /mob/living/simple_animal/pet/sloth

/obj/structure/closet/critter/goose
	name = "goose crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Гусь)",
		GENITIVE = "ящика для животных (Гусь)",
		DATIVE = "ящику для животных (Гусь)",
		ACCUSATIVE = "ящик для животных (Гусь)",
		INSTRUMENTAL = "ящиком для животных (Гусь)",
		PREPOSITIONAL = "ящике для животных (Гусь)"
	)
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/critter/gosling
	name = "gosling crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Гусёнок)",
		GENITIVE = "ящика для животных (Гусёнок)",
		DATIVE = "ящику для животных (Гусёнок)",
		ACCUSATIVE = "ящик для животных (Гусёнок)",
		INSTRUMENTAL = "ящиком для животных (Гусёнок)",
		PREPOSITIONAL = "ящике для животных (Гусёнок)"
	)
	content_mob = /mob/living/simple_animal/goose/gosling

/obj/structure/closet/critter/gosling/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/wooly_mouse
	name = "wolly mice crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Мохнатая мышь)",
		GENITIVE = "ящика для животных (Мохнатая мышь)",
		DATIVE = "ящику для животных (Мохнатая мышь)",
		ACCUSATIVE = "ящик для животных (Мохнатая мышь)",
		INSTRUMENTAL = "ящиком для животных (Мохнатая мышь)",
		PREPOSITIONAL = "ящике для животных (Мохнатая мышь)"
	)
	content_mob = /mob/living/simple_animal/mouse/wooly

/obj/structure/closet/critter/wooly_mouse/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/frog
	name = "frog crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Лягушка)",
		GENITIVE = "ящика для животных (Лягушка)",
		DATIVE = "ящику для животных (Лягушка)",
		ACCUSATIVE = "ящик для животных (Лягушка)",
		INSTRUMENTAL = "ящиком для животных (Лягушка)",
		PREPOSITIONAL = "ящике для животных (Лягушка)"
	)
	content_mob = /mob/living/simple_animal/frog

/obj/structure/closet/critter/frog/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/critter/frog/toxic
	name = "toxic frog crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Ядовитая лягушка)",
		GENITIVE = "ящика для животных (Ядовитая лягушка)",
		DATIVE = "ящику для животных (Ядовитая лягушка)",
		ACCUSATIVE = "ящик для животных (Ядовитая лягушка)",
		INSTRUMENTAL = "ящиком для животных (Ядовитая лягушка)",
		PREPOSITIONAL = "ящике для животных (Ядовитая лягушка)"
	)
	content_mob = /mob/living/simple_animal/frog/toxic

/obj/structure/closet/critter/snail
	name = "snail crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Улитка)",
		GENITIVE = "ящика для животных (Улитка)",
		DATIVE = "ящику для животных (Улитка)",
		ACCUSATIVE = "ящик для животных (Улитка)",
		INSTRUMENTAL = "ящиком для животных (Улитка)",
		PREPOSITIONAL = "ящике для животных (Улитка)"
	)
	content_mob = /mob/living/simple_animal/snail

/obj/structure/closet/critter/snail/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/critter/turtle
	name = "turtle crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Черепаха)",
		GENITIVE = "ящика для животных (Черепаха)",
		DATIVE = "ящику для животных (Черепаха)",
		ACCUSATIVE = "ящик для животных (Черепаха)",
		INSTRUMENTAL = "ящиком для животных (Черепаха)",
		PREPOSITIONAL = "ящике для животных (Черепаха)"
	)
	content_mob = /mob/living/simple_animal/turtle

/obj/structure/closet/critter/iguana
	name = "iguana crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Игуана)",
		GENITIVE = "ящика для животных (Игуана)",
		DATIVE = "ящику для животных (Игуана)",
		ACCUSATIVE = "ящик для животных (Игуана)",
		INSTRUMENTAL = "ящиком для животных (Игуана)",
		PREPOSITIONAL = "ящике для животных (Игуана)"
	)
	content_mob = /mob/living/simple_animal/hostile/lizard

/obj/structure/closet/critter/gator
	name = "gator crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Аллигатор)",
		GENITIVE = "ящика для животных (Аллигатор)",
		DATIVE = "ящику для животных (Аллигатор)",
		ACCUSATIVE = "ящик для животных (Аллигатор)",
		INSTRUMENTAL = "ящиком для животных (Аллигатор)",
		PREPOSITIONAL = "ящике для животных (Аллигатор)"
	)
	content_mob = /mob/living/simple_animal/hostile/lizard/gator

/obj/structure/closet/critter/croco
	name = "croco crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Крокодил)",
		GENITIVE = "ящика для животных (Крокодил)",
		DATIVE = "ящику для животных (Крокодил)",
		ACCUSATIVE = "ящик для животных (Крокодил)",
		INSTRUMENTAL = "ящиком для животных (Крокодил)",
		PREPOSITIONAL = "ящике для животных (Крокодил)"
	)
	content_mob = /mob/living/simple_animal/hostile/lizard/croco

/obj/structure/closet/critter/snake
	name = "snake crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Змея)",
		GENITIVE = "ящика для животных (Змея)",
		DATIVE = "ящику для животных (Змея)",
		ACCUSATIVE = "ящик для животных (Змея)",
		INSTRUMENTAL = "ящиком для животных (Змея)",
		PREPOSITIONAL = "ящике для животных (Змея)"
	)
	content_mob = /mob/living/simple_animal/hostile/retaliate/poison/snake

/obj/structure/closet/critter/slime
	name = "slime crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Слайм)",
		GENITIVE = "ящика для животных (Слайм)",
		DATIVE = "ящику для животных (Слайм)",
		ACCUSATIVE = "ящик для животных (Слайм)",
		INSTRUMENTAL = "ящиком для животных (Слайм)",
		PREPOSITIONAL = "ящике для животных (Слайм)"
	)
	content_mob = /mob/living/simple_animal/slime

/obj/structure/closet/critter/gorilla
	name = "gorilla crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Горилла)",
		GENITIVE = "ящика для животных (Горилла)",
		DATIVE = "ящику для животных (Горилла)",
		ACCUSATIVE = "ящик для животных (Горилла)",
		INSTRUMENTAL = "ящиком для животных (Горилла)",
		PREPOSITIONAL = "ящике для животных (Горилла)"
	)
	content_mob = /mob/living/simple_animal/hostile/gorilla

/obj/structure/closet/critter/cargorilla
	name = "cargorilla crate"
	ru_names = list(
		NOMINATIVE = "ящик для животных (Каргорилла)",
		GENITIVE = "ящика для животных (Каргорилла)",
		DATIVE = "ящику для животных (Каргорилла)",
		ACCUSATIVE = "ящик для животных (Каргорилла)",
		INSTRUMENTAL = "ящиком для животных (Каргорилла)",
		PREPOSITIONAL = "ящике для животных (Каргорилла)"
	)
	content_mob = /mob/living/simple_animal/hostile/gorilla/cargo_domestic

