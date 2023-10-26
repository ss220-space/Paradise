/area/ruin/space/graveyard
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE

/area/ruin/space/graveyard/church
	name = "Space graveyard church"
	icon_state = "away1"

/area/ruin/space/graveyard/graves
	name = "Space graveyard graves"
	icon_state = "away2"

///// Graveyard items
///// Ashes related

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
	var/number = rand(1,6)
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
	display_contents_with_number = TRUE
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
		var/obj/effect/decal/cleanable/ash = A
		ash.forceMove(src)
	..()

/obj/item/storage/funeral_urn/Destroy()
	for(var/obj/O in contents)
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

	new /obj/effect/decal/cleanable/ash(src)
	if(prob(15))
		switch(rand(1,2))
			if(1)
				new /obj/item/coin/gold(src)
				new /obj/item/coin/gold(src)
			if(2)
				new /obj/item/coin/silver(src)
				new /obj/item/coin/silver(src)
	..()

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

/obj/effect/spawner/graveyard_statues/Initialize()
	pick(
		new /obj/structure/statue/noble(src),
		new /obj/structure/statue/dude(src),
		new /obj/structure/statue/unknown(src),
		new /obj/structure/statue/death(src),
	)
	..()
