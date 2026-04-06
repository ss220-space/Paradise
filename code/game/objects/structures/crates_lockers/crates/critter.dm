/obj/structure/closet/crate/critter
	name = "critter crate"
	desc = "Ящик, предназначенный для безопасной транспортировки животных. Он оснащён кислородным баллоном для безопасной перевозки в космосе."
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

/obj/structure/closet/crate/critter/get_ru_names()
    return list(
        NOMINATIVE = "ящик для животных",
        GENITIVE = "ящика для животных",
        DATIVE = "ящику для животных",
        ACCUSATIVE = "ящик для животных",
        INSTRUMENTAL = "ящиком для животных",
        PREPOSITIONAL = "ящике для животных",
    )

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

/obj/structure/closet/crate/critter/open()
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

/obj/structure/closet/crate/critter/corgi/get_ru_names()
    return list(
        NOMINATIVE = "ящик для корги",
        GENITIVE = "ящика для корги",
        DATIVE = "ящику для корги",
        ACCUSATIVE = "ящик для корги",
        INSTRUMENTAL = "ящиком для корги",
        PREPOSITIONAL = "ящике для корги",
    )

/obj/structure/closet/crate/critter/corgi/populate_contents()
	if(prob(50))
		content_mob = /mob/living/simple_animal/pet/dog/corgi/Lisa

/obj/structure/closet/crate/critter/dog_pug
	name = "dog pug crate"
	content_mob = /mob/living/simple_animal/pet/dog/pug

/obj/structure/closet/crate/critter/dog_pug/get_ru_names()
    return list(
        NOMINATIVE = "ящик для мопса",
        GENITIVE = "ящика для мопса",
        DATIVE = "ящику для мопса",
        ACCUSATIVE = "ящик для мопса",
        INSTRUMENTAL = "ящиком для мопса",
        PREPOSITIONAL = "ящике для мопса",
    )

/obj/structure/closet/crate/critter/dog_bullterrier
	name = "dog bullterrier crate"
	content_mob = /mob/living/simple_animal/pet/dog/bullterrier

/obj/structure/closet/crate/critter/dog_bullterrier/get_ru_names()
    return list(
        NOMINATIVE = "ящик для бультерьера",
        GENITIVE = "ящика для бультерьера",
        DATIVE = "ящику для бультерьера",
        ACCUSATIVE = "ящик для бультерьера",
        INSTRUMENTAL = "ящиком для бультерьера",
        PREPOSITIONAL = "ящике для бультерьера",
    )

/obj/structure/closet/crate/critter/dog_tamaskan
	name = "dog tamaskan crate"
	content_mob = /mob/living/simple_animal/pet/dog/tamaskan

/obj/structure/closet/crate/critter/dog_tamaskan/get_ru_names()
    return list(
        NOMINATIVE = "ящик для тамаскана",
        GENITIVE = "ящика для тамаскана",
        DATIVE = "ящику для тамаскана",
        ACCUSATIVE = "ящик для тамаскана",
        INSTRUMENTAL = "ящиком для тамаскана",
        PREPOSITIONAL = "ящике для тамаскана",
    )

/obj/structure/closet/crate/critter/dog_german
	name = "dog german crate"
	content_mob = /mob/living/simple_animal/pet/dog/german

/obj/structure/closet/crate/critter/dog_german/get_ru_names()
    return list(
        NOMINATIVE = "ящик для немецкой овчарки",
        GENITIVE = "ящика для немецкой овчарки",
        DATIVE = "ящику для немецкой овчарки",
        ACCUSATIVE = "ящик для немецкой овчарки",
        INSTRUMENTAL = "ящиком для немецкой овчарки",
        PREPOSITIONAL = "ящике для немецкой овчарки",
    )

/obj/structure/closet/crate/critter/dog_brittany
	name = "dog brittany crate"
	content_mob = /mob/living/simple_animal/pet/dog/brittany

/obj/structure/closet/crate/critter/dog_brittany/get_ru_names()
    return list(
        NOMINATIVE = "ящик для бигля",
        GENITIVE = "ящика для бигля",
        DATIVE = "ящику для бигля",
        ACCUSATIVE = "ящик для бигля",
        INSTRUMENTAL = "ящиком для бигля",
        PREPOSITIONAL = "ящике для бигля",
    )

/obj/structure/closet/crate/critter/cow
	name = "cow crate"
	content_mob = /mob/living/simple_animal/cow

/obj/structure/closet/crate/critter/cow/get_ru_names()
    return list(
        NOMINATIVE = "ящик для коровы",
        GENITIVE = "ящика для коровы",
        DATIVE = "ящику для коровы",
        ACCUSATIVE = "ящик для коровы",
        INSTRUMENTAL = "ящиком для коровы",
        PREPOSITIONAL = "ящике для коровы",
    )

/obj/structure/closet/crate/critter/pig
	name = "pig crate"
	content_mob = /mob/living/simple_animal/pig

/obj/structure/closet/crate/critter/pig/get_ru_names()
    return list(
        NOMINATIVE = "ящик для свиньи",
        GENITIVE = "ящика для свиньи",
        DATIVE = "ящику для свиньи",
        ACCUSATIVE = "ящик для свиньи",
        INSTRUMENTAL = "ящиком для свиньи",
        PREPOSITIONAL = "ящике для свиньи",
    )

/obj/structure/closet/crate/critter/goat
	name = "goat crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/goat

/obj/structure/closet/crate/critter/goat/get_ru_names()
    return list(
        NOMINATIVE = "ящик для козла",
        GENITIVE = "ящика для козла",
        DATIVE = "ящику для козла",
        ACCUSATIVE = "ящик для козла",
        INSTRUMENTAL = "ящиком для козла",
        PREPOSITIONAL = "ящике для козла",
    )

/obj/structure/closet/crate/critter/goat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/hostile/retaliate/goat/hump

/obj/structure/closet/crate/critter/turkey
	name = "turkey crate"
	content_mob = /mob/living/simple_animal/turkey

/obj/structure/closet/crate/critter/turkey/get_ru_names()
    return list(
        NOMINATIVE = "ящик для индейки",
        GENITIVE = "ящика для индейки",
        DATIVE = "ящику для индейки",
        ACCUSATIVE = "ящик для индейки",
        INSTRUMENTAL = "ящиком для индейки",
        PREPOSITIONAL = "ящике для индейки",
    )

/obj/structure/closet/crate/critter/chick
	name = "chicken crate"
	content_mob = /mob/living/simple_animal/chick

/obj/structure/closet/crate/critter/chick/get_ru_names()
    return list(
        NOMINATIVE = "ящик для цыплёнка",
        GENITIVE = "ящика для цыплёнка",
        DATIVE = "ящику для цыплёнка",
        ACCUSATIVE = "ящик для цыплёнка",
        INSTRUMENTAL = "ящиком для цыплёнка",
        PREPOSITIONAL = "ящике для цыплёнка",
    )

/obj/structure/closet/crate/critter/chick/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/cat
	name = "cat crate"
	content_mob = /mob/living/simple_animal/pet/cat

/obj/structure/closet/crate/critter/cat/get_ru_names()
    return list(
        NOMINATIVE = "ящик для кошки",
        GENITIVE = "ящика для кошки",
        DATIVE = "ящику для кошки",
        ACCUSATIVE = "ящик для кошки",
        INSTRUMENTAL = "ящиком для кошки",
        PREPOSITIONAL = "ящике для кошки",
    )

/obj/structure/closet/crate/critter/cat/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/cat/Proc
	if(prob(5))
		content_mob = /mob/living/simple_animal/pet/cat/fat

/obj/structure/closet/crate/critter/cat_white
	name = "white cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/white

/obj/structure/closet/crate/critter/cat_white/get_ru_names()
    return list(
        NOMINATIVE = "ящик для белой кошки",
        GENITIVE = "ящика для белой кошки",
        DATIVE = "ящику для белой кошки",
        ACCUSATIVE = "ящик для белой кошки",
        INSTRUMENTAL = "ящиком для белой кошки",
        PREPOSITIONAL = "ящике для белой кошки",
    )

/obj/structure/closet/crate/critter/cat_birman
	name = "birman cat crate"
	content_mob = /mob/living/simple_animal/pet/cat/birman

/obj/structure/closet/crate/critter/cat_birman/get_ru_names()
    return list(
        NOMINATIVE = "ящик для бирманской кошки",
        GENITIVE = "ящика для бирманской кошки",
        DATIVE = "ящику для бирманской кошки",
        ACCUSATIVE = "ящик для бирманской кошки",
        INSTRUMENTAL = "ящиком для бирманской кошки",
        PREPOSITIONAL = "ящике для бирманской кошки",
    )

/obj/structure/closet/crate/critter/fox
	name = "fox crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox

/obj/structure/closet/crate/critter/fox/get_ru_names()
    return list(
        NOMINATIVE = "ящик для лисы",
        GENITIVE = "ящика для лисы",
        DATIVE = "ящику для лисы",
        ACCUSATIVE = "ящик для лисы",
        INSTRUMENTAL = "ящиком для лисы",
        PREPOSITIONAL = "ящике для лисы",
    )

/obj/structure/closet/crate/critter/fox/populate_contents()
	if(prob(30))
		content_mob = /mob/living/simple_animal/pet/dog/fox/forest

/obj/structure/closet/crate/critter/fennec
	name = "fennec crate"
	content_mob = /mob/living/simple_animal/pet/dog/fox/fennec

/obj/structure/closet/crate/critter/fennec/get_ru_names()
    return list(
        NOMINATIVE = "ящик для фенька",
        GENITIVE = "ящика для фенька",
        DATIVE = "ящику для фенька",
        ACCUSATIVE = "ящик для фенька",
        INSTRUMENTAL = "ящиком для фенька",
        PREPOSITIONAL = "ящике для фенька",
    )

/obj/structure/closet/crate/critter/butterfly
	name = "butterfly crate"
	content_mob = /mob/living/simple_animal/butterfly

/obj/structure/closet/crate/critter/butterfly/get_ru_names()
    return list(
        NOMINATIVE = "ящик для бабочки",
        GENITIVE = "ящика для бабочки",
        DATIVE = "ящику для бабочки",
        ACCUSATIVE = "ящик для бабочки",
        INSTRUMENTAL = "ящиком для бабочки",
        PREPOSITIONAL = "ящике для бабочки",
    )

/obj/structure/closet/crate/critter/deer
	name = "deer crate"
	content_mob = /mob/living/simple_animal/deer

/obj/structure/closet/crate/critter/deer/get_ru_names()
    return list(
        NOMINATIVE = "ящик для оленя",
        GENITIVE = "ящика для оленя",
        DATIVE = "ящику для оленя",
        ACCUSATIVE = "ящик для оленя",
        INSTRUMENTAL = "ящиком для оленя",
        PREPOSITIONAL = "ящике для оленя",
    )

/obj/structure/closet/crate/critter/sloth
	name = "sloth crate"
	content_mob = /mob/living/simple_animal/pet/sloth

/obj/structure/closet/crate/critter/sloth/get_ru_names()
    return list(
        NOMINATIVE = "ящик для ленивца",
        GENITIVE = "ящика для ленивца",
        DATIVE = "ящику для ленивца",
        ACCUSATIVE = "ящик для ленивца",
        INSTRUMENTAL = "ящиком для ленивца",
        PREPOSITIONAL = "ящике для ленивца",
    )

/obj/structure/closet/crate/critter/goose
	name = "goose crate"
	content_mob = /mob/living/simple_animal/goose

/obj/structure/closet/crate/critter/goose/get_ru_names()
    return list(
        NOMINATIVE = "ящик для гуся",
        GENITIVE = "ящика для гуся",
        DATIVE = "ящику для гуся",
        ACCUSATIVE = "ящик для гуся",
        INSTRUMENTAL = "ящиком для гуся",
        PREPOSITIONAL = "ящике для гуся",
    )

/obj/structure/closet/crate/critter/gosling
	name = "gosling crate"
	content_mob = /mob/living/simple_animal/goose/gosling

/obj/structure/closet/crate/critter/gosling/get_ru_names()
    return list(
        NOMINATIVE = "ящик для гусёнка",
        GENITIVE = "ящика для гусёнка",
        DATIVE = "ящику для гусёнка",
        ACCUSATIVE = "ящик для гусёнка",
        INSTRUMENTAL = "ящиком для гусёнка",
        PREPOSITIONAL = "ящике для гусёнка",
    )

/obj/structure/closet/crate/critter/gosling/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/wooly_mouse
	name = "wolly mice crate"
	content_mob = /mob/living/simple_animal/mouse/wooly

/obj/structure/closet/crate/critter/wooly_mouse/get_ru_names()
    return list(
        NOMINATIVE = "ящик для шерстистой мыши",
        GENITIVE = "ящика для шерстистой мыши",
        DATIVE = "ящику для шерстистой мыши",
        ACCUSATIVE = "ящик для шерстистой мыши",
        INSTRUMENTAL = "ящиком для шерстистой мыши",
        PREPOSITIONAL = "ящике для шерстистой мыши",
    )

/obj/structure/closet/crate/critter/wooly_mouse/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/crate/critter/frog
	name = "frog crate"
	content_mob = /mob/living/simple_animal/frog

/obj/structure/closet/crate/critter/frog/get_ru_names()
    return list(
        NOMINATIVE = "ящик для лягушки",
        GENITIVE = "ящика для лягушки",
        DATIVE = "ящику для лягушки",
        ACCUSATIVE = "ящик для лягушки",
        INSTRUMENTAL = "ящиком для лягушки",
        PREPOSITIONAL = "ящике для лягушки",
    )

/obj/structure/closet/crate/critter/frog/populate_contents()
	amount = rand(1, 3)

/obj/structure/closet/crate/critter/frog/toxic
	content_mob = /mob/living/simple_animal/frog/toxic

/obj/structure/closet/crate/critter/snail
	name = "snail crate"
	content_mob = /mob/living/simple_animal/snail

/obj/structure/closet/crate/critter/snail/get_ru_names()
    return list(
        NOMINATIVE = "ящик для улитки",
        GENITIVE = "ящика для улитки",
        DATIVE = "ящику для улитки",
        ACCUSATIVE = "ящик для улитки",
        INSTRUMENTAL = "ящиком для улитки",
        PREPOSITIONAL = "ящике для улитки",
    )

/obj/structure/closet/crate/critter/snail/populate_contents()
	amount = rand(1, 5)

/obj/structure/closet/crate/critter/turtle
	name = "turtle crate"
	content_mob = /mob/living/simple_animal/turtle

/obj/structure/closet/crate/critter/turtle/get_ru_names()
    return list(
        NOMINATIVE = "ящик для черепахи",
        GENITIVE = "ящика для черепахи",
        DATIVE = "ящику для черепахи",
        ACCUSATIVE = "ящик для черепахи",
        INSTRUMENTAL = "ящиком для черепахи",
        PREPOSITIONAL = "ящике для черепахи",
    )

/obj/structure/closet/crate/critter/iguana
	name = "iguana crate"
	content_mob = /mob/living/simple_animal/hostile/lizard

/obj/structure/closet/crate/critter/iguana/get_ru_names()
    return list(
        NOMINATIVE = "ящик для ящерицы",
        GENITIVE = "ящика для ящерицы",
        DATIVE = "ящику для ящерицы",
        ACCUSATIVE = "ящик для ящерицы",
        INSTRUMENTAL = "ящиком для ящерицы",
        PREPOSITIONAL = "ящике для ящерицы",
    )

/obj/structure/closet/crate/critter/gator
	name = "gator crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/gator

/obj/structure/closet/crate/critter/gator/get_ru_names()
    return list(
        NOMINATIVE = "ящик для аллигатора",
        GENITIVE = "ящика для аллигатора",
        DATIVE = "ящику для аллигатора",
        ACCUSATIVE = "ящик для аллигатора",
        INSTRUMENTAL = "ящиком для аллигатора",
        PREPOSITIONAL = "ящике для аллигатора",
    )

/obj/structure/closet/crate/critter/croco
	name = "croco crate"
	content_mob = /mob/living/simple_animal/hostile/lizard/croco

/obj/structure/closet/crate/critter/croco/get_ru_names()
    return list(
        NOMINATIVE = "ящик для крокодила",
        GENITIVE = "ящика для крокодила",
        DATIVE = "ящику для крокодила",
        ACCUSATIVE = "ящик для крокодила",
        INSTRUMENTAL = "ящиком для крокодила",
        PREPOSITIONAL = "ящике для крокодила",
    )

/obj/structure/closet/crate/critter/snake
	name = "snake crate"
	content_mob = /mob/living/simple_animal/hostile/retaliate/poison/snake

/obj/structure/closet/crate/critter/snake/get_ru_names()
    return list(
        NOMINATIVE = "ящик для змеи",
        GENITIVE = "ящика для змеи",
        DATIVE = "ящику для змеи",
        ACCUSATIVE = "ящик для змеи",
        INSTRUMENTAL = "ящиком для змеи",
        PREPOSITIONAL = "ящике для змеи",
    )

/obj/structure/closet/crate/critter/slime
	name = "slime crate"
	content_mob = /mob/living/simple_animal/slime

/obj/structure/closet/crate/critter/slime/get_ru_names()
    return list(
        NOMINATIVE = "ящик для слизня",
        GENITIVE = "ящика для слизня",
        DATIVE = "ящику для слизня",
        ACCUSATIVE = "ящик для слизня",
        INSTRUMENTAL = "ящиком для слизня",
        PREPOSITIONAL = "ящике для слизня",
    )

/obj/structure/closet/crate/critter/gorilla
	name = "gorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla

/obj/structure/closet/crate/critter/gorilla/get_ru_names()
    return list(
        NOMINATIVE = "ящик для гориллы",
        GENITIVE = "ящика для гориллы",
        DATIVE = "ящику для гориллы",
        ACCUSATIVE = "ящик для гориллы",
        INSTRUMENTAL = "ящиком для гориллы",
        PREPOSITIONAL = "ящике для гориллы",
    )

/obj/structure/closet/crate/critter/cargorilla
	name = "cargorilla crate"
	content_mob = /mob/living/simple_animal/hostile/gorilla/cargo_domestic

/obj/structure/closet/crate/critter/cargorilla/get_ru_names()
    return list(
        NOMINATIVE = "ящик для каргориллы",
        GENITIVE = "ящика для каргориллы",
        DATIVE = "ящику для каргориллы",
        ACCUSATIVE = "ящик для каргориллы",
        INSTRUMENTAL = "ящиком для каргориллы",
        PREPOSITIONAL = "ящике для каргориллы",
    )
