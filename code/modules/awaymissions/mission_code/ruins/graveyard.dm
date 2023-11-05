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
	possible_destinations = "trade_dock;graveyard_dock"


///// Graveyard items

/obj/structure/bookcase/ashframe
	name = "Shelf for ashes"
	icon = 'icons/obj/decorations.dmi'
	icon_state = "case-0"
	allowed_books = list(/obj/item/storage/funeral_urn)

/obj/structure/bookcase/ashframe/update_icon()
	if(contents.len < 5)
		icon_state = "case-[contents.len]"
	else
		icon_state = "case-5"

/obj/structure/bookcase/ashframe/random

/obj/structure/bookcase/ashframe/random/Initialize()
	var/number = rand(1,4)
	for(var/i = 0, i < number, i++)
		new /obj/item/storage/funeral_urn/random(src)
	..()

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
	can_be_hit = FALSE
	storage_slots = 3
	max_combined_w_class = 3
	display_contents_with_number = FALSE
	force = 3
	throwforce = 2
	throw_speed = 3
	throw_range = 4

/obj/item/storage/funeral_urn/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pen) || istype(I, /obj/item/flashlight/pen))
		rename_interactive(user, I)
	else
		return ..()

/obj/item/storage/funeral_urn/afterattack(atom/A, mob/user as mob, proximity)
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
			var/obj/item/return_ash = new /obj/effect/decal/cleanable/ash(get_turf(src))
			return_ash.name = O.name
			return_ash.desc = O.desc
			qdel(O)
		else
			O.forceMove(get_turf(src))
	..()

/obj/item/storage/funeral_urn/random

/obj/item/storage/funeral_urn/random/Initialize()
	var/pick_race
	if(prob(80))
		pick_race = "Human"
	else
		pick_race = pick("Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona", "Kidan", "Nian")
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
	..()

/obj/item/ash_holder
	name = "ash"
	desc = "Ashes to ashes, dust to dust, and into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	w_class = WEIGHT_CLASS_TINY
	var/obj/effect/decal/cleanable/ash/return_ash

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
	climbable = FALSE
	max_integrity = 100
	integrity_failure = 30
	smooth = SMOOTH_FALSE

/obj/structure/table/socle/flip()
	return

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
	qdel(src)
	..()

/////Заготовка лута для могил
/*
mogila/populate_contents()
	new /obj/structure/closet/coffin/graveyard_loot(src)
*/
/obj/structure/closet/coffin/graveyard_loot/Initialize()
	var/money = pick(/obj/item/stack/spacecash/c5000, /obj/item/stack/spacecash/c1000, /obj/item/stack/spacecash/c500)
	var/little_money = pick(/obj/item/stack/spacecash/c50, /obj/item/stack/spacecash/c100, /obj/item/stack/spacecash/c200)
	var/medal = pick(/obj/item/clothing/accessory/medal, /obj/item/clothing/accessory/medal/fluff/elo, /obj/item/clothing/accessory/medal/heart)
	var/gun = pick(/obj/item/gun/projectile/shotgun/lethal/rusted, /obj/item/gun/projectile/revolver/nagant/rusted, /obj/item/gun/projectile/automatic/pistol)
	if(prob(90))
		if(prob(10))
			new /mob/living/simple_animal/hostile/zombie/graveyard(src)
			new gun(src)
			new medal(src)
			new money(src)
		else if(prob(10))
			new /mob/living/simple_animal/hostile/zombie/whiteship(src)
			new /obj/item/decorations/bouquets/random(src)
			new little_money(src)
		else if(prob(5))
			new /obj/item/clothing/head/helmet/street_judge(src)
			new /obj/item/clothing/suit/armor/vest/street_judge(src)
			new /obj/item/gun/projectile/automatic/pistol/enforcer/lethal(src)
			new /obj/item/clothing/shoes/jackboots(src)
			new /obj/item/clothing/gloves/combat(src)
			new /obj/item/clothing/under/rank/security(src)
			new /obj/item/clothing/mask/gas/sechailer(src)
			new /obj/item/clothing/accessory/lawyers_badge(src)
		else
			new /obj/effect/mob_spawn/human/skeleton(src)
			new /obj/item/decorations/bouquets/random(src)
			new little_money(src)
	..()
/*
			var/mob/skeleton = new /obj/effect/mob_spawn/human/skeleton
			new /obj/item/decorations/bouquets/random(src)
			new little_money(src)
			skeleton.forceMove(src)

/obj/item/clothing/accessory/medal
/obj/item/clothing/accessory/medal/fluff/elo
/obj/item/clothing/accessory/medal/heart

/obj/item/stack/spacecash/c1000

/obj/item/melee/energy/sword/pirate

/obj/item/clothing/gloves/ring/gold/blessed
/obj/item/clothing/gloves/ring/fluff/benjaminfallout

/obj/item/clothing/head/helmet/street_judge
/obj/item/clothing/suit/armor/vest/street_judge
/obj/item/gun/projectile/automatic/pistol/enforcer/lethal
/obj/item/clothing/shoes/jackboots
/obj/item/clothing/gloves/combat
/obj/item/clothing/under/rank/security
/obj/item/clothing/mask/gas/sechailer
/obj/item/clothing/accessory/lawyers_badge
*/


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
