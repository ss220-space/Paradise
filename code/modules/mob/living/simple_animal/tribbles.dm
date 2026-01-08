GLOBAL_VAR_INIT(totaltribbles, 0)   //global variable so it updates for all tribbles, not just the new one being made.
#define MAX_TRIBBLES 30
#define MAX_GESTATION 30

/mob/living/simple_animal/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	icon_living = "tribble1"
	icon_dead = "tribble1_dead"
	speak = list("Prrrrr...")
	speak_emote = list("мурлычет", "заливается трелью")
	emote_hear = list("мурчит", "мурлычет")
	emote_see = list("катается туда-сюда", "кружится")
	tts_seed = "Meepo"
	speak_chance = 10
	turns_per_move = 5
	maxHealth = 10
	health = 10
	butcher_results = list(/obj/item/stack/sheet/fur = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	var/gestation = 0

/mob/living/simple_animal/tribble/New()
	..()
	var/list/types = list("tribble1","tribble2","tribble3")
	src.icon_state = pick(types)
	src.icon_living = src.icon_state
	src.icon_dead = "[src.icon_state]_dead"
	//random pixel offsets so they cover the floor
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)
	GLOB.totaltribbles += 1

/mob/living/simple_animal/tribble/attack_hand(mob/user)
	. = ..()

	if(stat == DEAD)
		return

	var/obj/item/toy/tribble/new_tribble = new /obj/item/toy/tribble(user.loc)
	new_tribble.icon_state = icon_state
	new_tribble.item_state = icon_state
	new_tribble.gestation = gestation
	new_tribble.pickup(user)
	user.put_in_active_hand(new_tribble)
	qdel(src)

/mob/living/simple_animal/tribble/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/scalpel))
		to_chat(user, span_notice("You try to neuter the tribble, but it's moving too much and you fail!"))
	else if(istype(I, /obj/item/cautery))
		to_chat(user, span_notice("You try to un-neuter the tribble, but it's moving too much and you fail!"))
	return ..()

/mob/living/simple_animal/tribble/proc/procreate()
	if(GLOB.totaltribbles >= MAX_TRIBBLES)
		return

	var/list/possible_turfs = RANGE_TURFS(1, src)
	shuffle(possible_turfs)

	for(var/turf/possible_loc in possible_turfs)
		if(locate(type) in possible_loc)
			continue

		gestation = 0
		new /mob/living/simple_animal/tribble(possible_loc)
		return

/mob/living/simple_animal/tribble/Life(seconds, times_fired)
	. = ..()
	if(health <= 0) //no mostly dead procreation
		return

	if(gestation < 0)
		return

	if(gestation < MAX_GESTATION)
		gestation++
		return

	if(!SPT_PROB(80, seconds))
		return

	procreate()

/mob/living/simple_animal/tribble/death(gibbed) // Gotta make sure to remove tribbles from the list on death
	// Only execute the below if we successfully died
	. = ..(gibbed)

	if(!.)
		return FALSE

	GLOB.totaltribbles = max(0, GLOB.totaltribbles - 1)

#undef MAX_TRIBBLES
#undef MAX_GESTATION

//||Item version of the trible ||
/obj/item/toy/tribble
	name = "tribble"
	desc = "It's a small furry creature that makes a soft trill."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribble1"
	item_state = "tribble1"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL
	var/gestation = 0

/obj/item/toy/tribble/attack_self(mob/user) //hug that tribble (and play a sound if we add one)
	..()
	to_chat(user, span_notice("You nuzzle the tribble and it trills softly."))

/obj/item/toy/tribble/dropped(mob/user, slot, silent = FALSE) //now you can't item form them to get rid of them all so easily
	new /mob/living/simple_animal/tribble(user.loc)
	for(var/mob/living/simple_animal/tribble/T in user.loc)
		T.icon_state = src.icon_state
		T.icon_living = src.icon_state
		T.icon_dead = "[src.icon_state]_dead"
		T.gestation = src.gestation

	to_chat(user, span_notice("The tribble gets up and wanders around."))
	. = ..()

/obj/item/toy/tribble/attackby(obj/item/I, mob/user, params) //neutering and un-neutering
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || gestation < 0)
		return .

	if(istype(I, /obj/item/scalpel))
		gestation = -1
		to_chat(user, span_notice("You neuter the tribble so that it can no longer re-produce."))
		return .

	if(istype(I, /obj/item/cautery))
		gestation = 0
		to_chat(user, span_notice("You fuse some recently cut tubes together, it should be able to reproduce again."))

//||Fur and Fur Products ||

/obj/item/stack/sheet/fur //basic fur sheets (very lumpy furry piles of sheets)
	name = "pile of fur"
	desc = "The by-product of tribbles."
	singular_name = "fur piece"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "sheet-fur"
	origin_tech = "materials=2"

/obj/item/clothing/ears/earmuffs/tribblemuffs //earmuffs but with tribbles
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "tribblemuffs"
	item_state = "tribblemuffs"

/* The advanced cold protection of the non-coat items has been removed, so as not
	to give patreon donors an unfair advantage - the winter coat provides equivalent
	cold protection
*/
/obj/item/clothing/gloves/furgloves
	desc = "These gloves are warm and furry."
	name = "fur gloves"
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furglovesico"
	item_state = "furgloves"
	transfer_prints = TRUE
	transfer_blood = TRUE
	undyeable = TRUE

// Equivalent to a winter coat's hood
/obj/item/clothing/head/furcap
	name = "fur cap"
	desc = "A warm furry cap."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcap"
	item_state = "furcap"

	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/furboots
	name = "fur boots"
	desc = "Warm, furry boots."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furboots"
	item_state = "furboots"

// As a donator piece of clothing, this is now in line with the winter coat
/obj/item/clothing/suit/furcoat
	name = "fur coat"
	desc = "A trenchcoat made from fur. You could put an oxygen tank in one of the pockets."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcoat"
	item_state = "furcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO
	allowed = list (/obj/item/tank/internals/emergency_oxygen)
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/neck/cloak/furcape
	name = "fur cape"
	desc = "A cape made from fur. You'll really be stylin' now."
	icon = 'icons/mob/tribbles.dmi'
	icon_state = "furcape"
	item_state = "furcape"
	cold_protection = UPPER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
