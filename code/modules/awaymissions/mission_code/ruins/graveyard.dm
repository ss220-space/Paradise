/area/ruin/space/graveyard
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE

/area/ruin/space/graveyard/church
	name = "Space Graveyard Church"
	icon_state = "away1"
	ambientsounds = list('sound/ambience/ambicha4.ogg', 'sound/ambience/ambilava1.ogg', 'sound/ambience/ambilava3.ogg', 'sound/ambience/ambimo2.ogg', 'sound/ambience/ambiruin6.ogg')

/area/ruin/space/graveyard/graves
	name = "Space Graveyard Graves"
	icon_state = "away2"
	ambientsounds = list('sound/ambience/apathy.ogg')

///// The Undertaker Shuttle

/area/shuttle/funeral
	icon_state = "shuttle3"
	name = "Suneral Shuttle"
	parallax_movedir = SOUTH
	nad_allowed = TRUE

/obj/machinery/computer/shuttle/funeral
	name = "Funeral \"The Undertaker\" Shuttle Console"
	desc = "Used to call and send the funeral \"The Undertaker\" shuttle."
	shuttleId = "funeral"
	possible_destinations = "graveyard_church;graveyard_dock"


///// Graveyard items

/obj/structure/bookcase/ashframe
	name = "Shelf for ashes"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "case-0"


/obj/structure/bookcase/ashframe/generate_allowed_books()
	allowed_books = typecacheof(list(
		/obj/item/storage/funeral_urn,
	))


/obj/structure/bookcase/ashframe/update_icon_state()
	icon_state = "case-[min(length(contents), 5)]"


/obj/structure/bookcase/ashframe/random


/obj/structure/bookcase/ashframe/random/Initialize(mapload)
	var/number = rand(1,4)
	for(var/i = 1 to number)
		new /obj/item/storage/funeral_urn/random(src)
	update_icon(UPDATE_ICON_STATE)
	return ..()


/obj/item/storage/funeral_urn
	name = "Funeral urn"
	desc = "Dark ceramic urn filled with someone's ashes."
	icon_state = "funeral_urn"
	icon = 'icons/obj/decorations.dmi'
	item_state = "funeral_urn"
	max_integrity = 60
	w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/effect/decal/cleanable/ash,
		/obj/item/paper,
		/obj/item/photo,
		/obj/item/coin,
		/obj/item/ammo_casing,
	)
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	storage_slots = 3
	max_combined_w_class = 3
	display_contents_with_number = FALSE
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4


/obj/item/storage/funeral_urn/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/storage/funeral_urn/afterattack(atom/A, mob/user, proximity, params)
	if(istype(A,/obj/effect/decal/cleanable/ash))
		if(src.contents.len < storage_slots)
			var/obj/effect/decal/cleanable/ash/ash = A
			new /obj/item/ash_holder(src, ash)
			qdel(ash)
		else
			to_chat(user, span_notice("There are no place in [name]"))
	..()

/obj/item/storage/funeral_urn/Destroy()
	playsound(src, "shatter", 70, 1)
	for(var/obj/O in contents)
		if(istype(O,/obj/item/ash_holder))
			var/obj/effect/decal/cleanable/ash/return_ash = new(get_turf(src))
			return_ash.name = O.name
			return_ash.desc = O.desc
			qdel(O)
		else
			O.forceMove(get_turf(src))
	..()

/obj/item/storage/funeral_urn/with_ash

/obj/item/storage/funeral_urn/with_ash/Initialize(mapload)
	new /obj/item/ash_holder(src)
	. = ..()

/obj/item/storage/funeral_urn/random

/obj/item/storage/funeral_urn/random/Initialize(mapload)
	var/pick_race
	if(prob(80))
		pick_race = SPECIES_HUMAN
	else
		pick_race = pick(SPECIES_VULPKANIN, SPECIES_TAJARAN, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_DIONA, SPECIES_KIDAN, SPECIES_MOTH)
	var/pick_sex
	pick_sex = pick(FEMALE, MALE)
	var/nam = random_name(gender = pick_sex, species = pick_race)
	var/cur_year = GLOB.game_year
	var/born = cur_year - rand(5,150)
	var/died = max(cur_year - rand(0,70),born)

	name = "Funeral urn of [nam]"
	description_info = "Here lies [nam], [born] - [died]."

	new /obj/item/ash_holder(src)
	if(prob(15))
		switch(rand(1,2))
			if(1)
				new /obj/item/coin/gold(src)
				new /obj/item/coin/gold(src)
			if(2)
				new /obj/item/coin/silver(src)
				new /obj/item/coin/silver(src)
	. = ..()

/obj/item/ash_holder
	name = "ash"
	desc = "Ashes to ashes, dust to dust, and into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	w_class = WEIGHT_CLASS_TINY

/obj/item/ash_holder/Initialize(mapload, var/obj/effect/decal/cleanable/ash/parent_ash = new)
	name = parent_ash.name
	desc = parent_ash.desc
	. = ..()

/obj/item/ash_holder/equipped(mob/user, slot, initial)
	. = ..()
	var/obj/item/return_ash = new /obj/effect/decal/cleanable/ash(get_turf(src))
	return_ash.name = name
	return_ash.desc = desc
	qdel(src)

/obj/structure/table/socle
	name = "Socle"
	desc = "A round piece of metal standing on column. It can not move."
	icon = 'icons/obj/decorations.dmi'
	icon_state = "socle"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags = LETPASSTHROW
	can_be_flipped = FALSE
	climbable = FALSE
	max_integrity = 100
	integrity_failure = 30
	smooth = NONE


/obj/effect/spawner/graveyard_statues
	name = "Statues"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x3"

/obj/effect/spawner/graveyard_statues/New()
	var/monument
	var/offset = 0
	switch(pick("big","small"))
		if("big")
			monument = pick(
				/obj/structure/statue/unknown,
				/obj/structure/statue/death,
			)

		if("small")
			monument = pick(
				/obj/structure/statue/noble,
				/obj/structure/statue/dude,
			)
			offset = 16
	var/obj/structure/statue/statue = new monument(get_turf(src))
	statue.pixel_x = offset
	..()

/obj/effect/spawner/graveyard_statues/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_QDEL

/obj/item/book/philosophy_of_death
	name = "Философия смерти"
	desc = "Эта книга переплетена вручную и украшена по краям позолотой. Видно, что ее создатель не сомневался в ее важности."
	icon_state = "demonomicon"
	author = "Немрис Мудрый"
	title = "Философия смерти"
	unique = 1
	forbidden = 1
	has_drm = TRUE
	dat = {"
		<br>Для начала поговорим о жизни и смерти — взаимно противоположных, но равно великих феноменах.

		<br>Жрецы утверждают, что смерть превыше жизни, поскольку является справедливым воздаянием богов. Но если это так, то выбор между небесным блаженством и адскими муками всецело зависит от прижизненных поступков человека, следовательно, жизнь для него намного важнее.

		<br>А как быть с теми, кто не придает значения богам, сомневается в загробном существовании и отрицает сверхъестественное? Для таких людей целью жизни является сама жизнь — с этой мудростью согласны даже некоторые жрецы. Но какие же сомнения порой одолевают этих поборников жизни! Какие кошмары глядят на них из глубины теней... Их страх перед смертью бывает столь велик, что полностью затмевает волю к жизни.

		<br>Я же скажу следующее. Забудьте обещания богов и отриньте ужас небытия, ибо только признав равенство жизни и смерти, можно постичь философию того и другого. Смерть может нести как веру, так и ужас — но только если вы сами ей это позволите. Взгляните в ее обсидиановые глаза, осознайте, что всему есть начало и конец, не бойтесь ни того, ни другого — и тогда вы достигнете берегов мудрости.

		<br><br>Так сказал Немрис.
		"}


////// Grave with loot spawner and evil soul
/obj/structure/pit/closed/graveyard_loot
	icon_state = "pit0"
	var/ever_opened = FALSE

/obj/structure/pit/closed/graveyard_loot/open()
	..()
	if(!ever_opened)
		ever_opened = TRUE
		if(prob(10))
			to_chat(usr, "<span class='danger'> HOW DARE YOU DISTURB THE DEAD?! </span>")
			new /obj/effect/particle_effect/smoke(get_turf(src))
			new /mob/living/simple_animal/hostile/carp/lostsoul(get_turf(src))

/obj/structure/pit/closed/graveyard_loot/populate_contents()
	new /obj/structure/closet/coffin/graveyard_loot(src)

/obj/structure/closet/coffin/graveyard_loot
	var/spawn_mob = null

/obj/structure/closet/coffin/graveyard_loot/open()
	..()
	if(spawn_mob)
		new spawn_mob(src.loc)
		spawn_mob = null
		new /obj/effect/particle_effect/smoke(get_turf(src))

/obj/structure/closet/coffin/graveyard_loot/populate_contents()
	var/medal = pick(/obj/item/clothing/accessory/medal, /obj/item/clothing/accessory/medal/fluff/elo, /obj/item/clothing/accessory/medal/heart)
	var/gun = pick(/obj/item/gun/projectile/shotgun/lethal/rusted, /obj/item/gun/projectile/revolver/nagant/rusted, /obj/item/gun/projectile/automatic/pistol)
	switch(rand(1,55))
		if(1 to 2)
			spawn_mob = /mob/living/simple_animal/hostile/zombie/space_graveyard/noble
			var/obj/item/stack/spacecash/big_money = new
			big_money.name = "Fat bundle of money"
			big_money.icon_state = "cashblue"
			big_money.amount = rand(1000, 5000)
			big_money.forceMove(src)
			new medal(src)
			new gun(src)
		if(3 to 6)
			spawn_mob = /mob/living/simple_animal/hostile/zombie/space_graveyard/noble/fast
			var/obj/item/stack/spacecash/little_money = new
			little_money.name = "Small bundle of money"
			little_money.amount = rand(100, 400)
			little_money.forceMove(src)
		if(7 to 8)
			spawn_mob = /mob/living/simple_animal/hostile/zombie/space_graveyard/dredd
			new /obj/item/decorations/bouquets/random(src)
		if(8 to 9)
			spawn_mob = /mob/living/simple_animal/hostile/zombie/space_graveyard/pirate
			var/obj/item/stack/spacecash/big_money = new
			big_money.name = "Fat bundle of money"
			big_money.icon_state = "cashblue"
			big_money.amount = rand(1000, 5000)
			big_money.forceMove(src)
			new /obj/item/reagent_containers/food/drinks/bottle/rum(src)
			new /obj/item/decorations/bouquets/random(src)
		if(10 to 50)
			var/mob/living/carbon/human/skeleton/dead/suit_and_shoes = new(src)
			suit_and_shoes.equipOutfit(/datum/outfit/space_graveyard/suit_and_shoes)
			new /obj/item/decorations/bouquets/random(src)
			if(prob(30))
				var/obj/item/stack/spacecash/little_money = new
				little_money.name = "Small bundle of money"
				little_money.amount = rand(100, 400)
				little_money.forceMove(src)
		else
			return

/mob/living/carbon/human/skeleton/dead
	name = "A skeleton"
	real_name = "A skeleton"
	health = -500
	deathgasp_on_death = FALSE

/mob/living/carbon/human/skeleton/dead/Initialize(mapload)
    . = ..()
    rename_character(src.name, "A skeleton")

/datum/outfit/space_graveyard/suit_and_shoes
	name = "Jacket and shoes"
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	shoes = /obj/item/clothing/shoes/centcom
