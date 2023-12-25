/area/awaymission/evil_santa
	name = "Evil santa"
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE
	tele_proof = TRUE
	no_teleportlocs = TRUE

/area/awaymission/evil_santa_storm
	name = "Evil santa forest"
	icon_state = "green"
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE
	tele_proof = TRUE
	no_teleportlocs = TRUE
	ambientsounds = list('sound/ambience/apathy.ogg')

/area/awaymission/evil_santa/spawn_s
	name = "Evil santa spawn south"
	icon_state = "awaycontent1"

/area/awaymission/evil_santa/spawn_ne
	name = "Evil santa spawn north east"
	icon_state = "awaycontent2"
/area/awaymission/evil_santa/spawn_nw
	name = "Evil santa spawn north west"
	icon_state = "awaycontent3"

/area/awaymission/evil_santa/hut_n
	name = "Evil santa hut north"
	icon_state = "awaycontent4"

/area/awaymission/evil_santa/hut_w
	name = "Evil santa hut west"
	icon_state = "awaycontent5"

/area/awaymission/evil_santa/hut_e
	name = "Evil santa hut east"
	icon_state = "awaycontent6"

/area/awaymission/evil_santa/mine
	name = "Evil santa mines"
	icon_state = "awaycontent7"
	ambientsounds = list(
				'sound/ambience/spooky/howled_4.ogg',\
				'sound/ambience/spooky/psy_amb.ogg',\
				'sound/ambience/spooky/rnd_ugrnd_amb_4.ogg',\
				'sound/ambience/spooky/rnd_ugrnd_amb_5.ogg',\
				'sound/ambience/spooky/ugrnd_ambient_banging_1.ogg',\
				'sound/ambience/spooky/ugrnd_ambient_banging_2.ogg',\
				'sound/ambience/spooky/ugrnd_drip_3.ogg',\
				'sound/ambience/spooky/ugrnd_drip_4.ogg',\
				'sound/ambience/spooky/ugrnd_drip_5.ogg',\
				'sound/ambience/spooky/ugrnd_drip_6.ogg',\
				'sound/ambience/spooky/ugrnd_drip_7.ogg',\
				'sound/ambience/spooky/ugrnd_lab_3.ogg',\
				'sound/ambience/spooky/ugrnd_whispers_1.ogg',\
				'sound/ambience/spooky/ugrnd_whispers_4.ogg'
				)

/area/awaymission/evil_santa/mine/labyrinth_l
	name = "Evil santa left labyrinth"
	icon_state = "awaycontent8"

/area/awaymission/evil_santa/mine/labyrinth_m
	name = "Evil santa middle labyrinth"
	icon_state = "awaycontent9"

/area/awaymission/evil_santa/mine/labyrinth_r
	name = "Evil santa right labyrinth"
	icon_state = "awaycontent10"

/area/awaymission/evil_santa/mine/terror_spider
	name = "Evil santa spider nest"
	icon_state = "awaycontent11"

/area/awaymission/evil_santa/end/lounge
	name = "Evil santa lounge"
	icon_state = "awaycontent12"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/evil_santa/end/hall
	name = "Evil santa hall"
	icon_state = "awaycontent13"
/area/awaymission/evil_santa/end/santa
	name = "Evil santa fight"
	icon_state = "awaycontent14"

/area/awaymission/evil_santa/end/exit
	name = "Evil santa exit"
	icon_state = "awaycontent15"
	requires_power = TRUE

/area/awaymission/evil_santa/forest_labyrinth
	name = "Evil santa forest labyrinth"
	icon_state = "dark"

/area/awaymission/evil_santa/end/santa/proc/UnlockBlastDoors(target_id_tag)
	target_id_tag = "Evil_Santa_Arena"
	for(var/obj/machinery/door/poddoor/preopen/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.open()

/area/awaymission/evil_santa/end/santa/proc/BlockBlastDoors(target_id_tag)
	target_id_tag = "Evil_Santa_Arena"
	for(var/obj/machinery/door/poddoor/preopen/P in GLOB.airlocks)
		if(P.density && P.id_tag == target_id_tag && P.z == z && !P.operating)
			P.close()

/area/awaymission/evil_santa/end/santa/Entered(var/mob/living/carbon/naughty)
	. = ..()
	for(var/mob/living/simple_animal/hostile/winter/santa/fat_man)
		if(fat_man.is_dead())
			return
	sleep(50)
	if(naughty > 0 && !naughty.is_dead())
		BlockBlastDoors()
		to_chat(usr, "<span class='danger'> YOU'VE BEEN TOO NAUGHTY THIS YEAR AND NOW YOU WILL BE PUNISHED! </span>")
	else
		UnlockBlastDoors()

/obj/item/paper/journal_scrap_1
	name = "survivor's journal page 1"
	info = "Coal again.<br> \
			Every year, coal in my stockings when this stupid holiday comes around.<br> \
			Not this year though. This year will be different. I'm going to find that fat man, I swear.<br> \
			He'll have to give me all the good presents, if he wants to live long enough to get any cookies."

/obj/item/paper/journal_scrap_2
	name = "survivor's journal page 9"
	info = "The North Pole... You'd think it was a part of his legend, but he actually lives there!<br> \
			The elves and village are a lie though. Not sure where the toys come from yet, but I'll get them.<br> \
			Not much out here, a couple little shacks and a big igloo in the center... Bet he's inside that.<br> \
			On an unrelated note, great packing snow. Built a snowman today."

/obj/item/paper/journal_scrap_3
	name = "survivor's journal page 25"
	info = "Oh man... This is bad...<br> \
			Not even my Syndicate training was a match for him. Barely made it out with my life.<br> \
			He was just waiting for me... He knew. He was ready.<br> \
			Couldn't make it back to my shack. That gun would have helped, if only I brought it...<br> \
			Cave-in has me trapped in here, I just hope the distress signal reaches help in time... <br> \
			<br> \
			He knows. He knows. He knows. He knows. He knows. He knows. He knows. He knows. He knows."

/obj/effect/decal/rail_way
	name = "Old rails"
	desc = "Old and rusty rails. Looks like they were lying here for hundreds of years."
	icon = 'icons/obj/mining.dmi'
	icon_state = "rail"
	layer = TURF_LAYER

/mob/living/simple_animal/hostile/monkey_shaftminer
	name = "Monkey shaftminer"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_chance = 10
	speak_emote = list("growls","roars")
	faction = list("hostile", "syndicate", "winter")
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "monkey_shaftminer"
	maxHealth = 50
	health = 50
	speed = 0
	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	loot = list(/obj/effect/mob_spawn/human/corpse/monkey_shaftminer, /obj/item/pickaxe)

/obj/effect/mob_spawn/human/corpse/monkey_shaftminer
	mob_type = /mob/living/carbon/human/lesser/monkey
	death = TRUE
	name = "Dead monkey shaftminer"
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet-monkey"
	outfit = /datum/outfit/monkey_shaftminer

/datum/outfit/monkey_shaftminer
	name = "Monkey shaftminer"

	uniform = /obj/item/clothing/under/jester
	shoes = /obj/item/clothing/shoes/orange
	head = /obj/item/clothing/head/jester
	l_pocket = /obj/item/grown/bananapeel

/obj/item/a_gift/evil_santa_reward

/obj/item/a_gift/evil_santa_reward/attack_self(mob/M as mob)
	var/gift_type = pick(
		/obj/item/toy/xmas_cracker,
		/obj/item/storage/box/syndie_kit/mr_chang_technique,
		/obj/item/documents/syndicate/yellow/trapped,
		/obj/item/documents/nanotrasen,
		/obj/item/documents/syndicate/mining,
		/obj/item/paper/researchnotes,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/stack/spacecash/c5000,
		/obj/item/storage/box/wizard/hardsuit,
		/obj/item/storage/box/syndie_kit/hardsuit,
		/obj/item/clothing/suit/space/hardsuit/champion/templar/premium,
		/obj/item/clothing/suit/space/hardsuit/soviet,
		/obj/item/clothing/suit/space/hardsuit/ancient,
		/obj/item/clothing/suit/space/eva/pirate/leader,
		/obj/item/clothing/head/helmet/space/eva/pirate/leader,
		/obj/item/hardsuit_shield/syndi,
		/obj/vehicle/space/speedbike/red,
		/obj/vehicle/space/speedbike,
		/obj/vehicle/motorcycle,
		/obj/vehicle/snowmobile/blue/key,
		/obj/vehicle/snowmobile/key,
		/obj/vehicle/car,
		/obj/item/dnainjector/insulation,
		/obj/item/dnainjector/nobreath,
		/obj/item/dnainjector/runfast,
		/obj/item/dnainjector/hulkmut,
		/obj/item/dnainjector/morph,
		/obj/item/dnainjector/xraymut,
		/obj/item/grenade/confetti,
		/obj/item/grenade/confetti,
		)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.temporarily_remove_item_from_inventory(src, force = TRUE)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/obj/effect/spawner/lootdrop/evil_santa_gift
	name = "50% bouquet spawner"
	icon_state = "evil_santa_gift"
	lootdoubles = 0

	loot = list(
				/obj/item/a_gift/evil_santa_reward = 33,
				/obj/item/a_gift = 67,
				)
