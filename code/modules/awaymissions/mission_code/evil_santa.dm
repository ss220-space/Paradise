/area/vision_change_area/awaymission/evil_santa
	name = "Evil santa"
	poweralm = FALSE
	report_alerts = FALSE
	tele_proof = TRUE
	no_teleportlocs = TRUE

/area/vision_change_area/awaymission/evil_santa_storm
	name = "Evil santa forest"
	icon_state = "green"
	poweralm = FALSE
	report_alerts = FALSE
	tele_proof = TRUE
	no_teleportlocs = TRUE
	ambientsounds = list(
		'sound/ambience/spooky/haunting_ambience.ogg',
		'sound/ambience/spooky/suspenseful_ambience.ogg',
		'sound/ambience/spooky/scary_sci_fi_ambience.ogg',
		'sound/ambience/apathy.ogg',
		)

/area/vision_change_area/awaymission/evil_santa/spawn_s
	name = "Evil santa spawn south"
	icon_state = "awaycontent1"

/area/vision_change_area/awaymission/evil_santa/spawn_ne
	name = "Evil santa spawn north east"
	icon_state = "awaycontent2"
/area/vision_change_area/awaymission/evil_santa/spawn_nw
	name = "Evil santa spawn north west"
	icon_state = "awaycontent3"

/area/vision_change_area/awaymission/evil_santa/hut_n
	name = "Evil santa hut north"
	icon_state = "awaycontent4"

/area/vision_change_area/awaymission/evil_santa/hut_w
	name = "Evil santa hut west"
	icon_state = "awaycontent5"

/area/vision_change_area/awaymission/evil_santa/hut_e
	name = "Evil santa hut east"
	icon_state = "awaycontent6"

/area/vision_change_area/awaymission/evil_santa/mine
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

/area/vision_change_area/awaymission/evil_santa/mine/labyrinth_l
	name = "Evil santa left labyrinth"
	icon_state = "awaycontent8"

/area/vision_change_area/awaymission/evil_santa/mine/labyrinth_m
	name = "Evil santa middle labyrinth"
	icon_state = "awaycontent9"

/area/vision_change_area/awaymission/evil_santa/mine/labyrinth_r
	name = "Evil santa right labyrinth"
	icon_state = "awaycontent10"

/area/vision_change_area/awaymission/evil_santa/mine/terror_spider
	name = "Evil santa spider nest"
	icon_state = "awaycontent11"

/area/vision_change_area/awaymission/evil_santa/end/lounge
	name = "Evil santa lounge"
	icon_state = "awaycontent12"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = COLOR_WHITE

/area/vision_change_area/awaymission/evil_santa/end/hall
	name = "Evil santa hall"
	icon_state = "awaycontent13"
/area/vision_change_area/awaymission/evil_santa/end/santa
	name = "Evil santa fight"
	icon_state = "awaycontent14"
	var/battle = FALSE
	var/cooldown = FALSE
	var/list/naughty_guys
	var/mob/living/simple_animal/hostile/winter/santa/boss

/area/vision_change_area/awaymission/evil_santa/end/exit
	name = "Evil santa exit"
	icon_state = "awaycontent15"

/area/vision_change_area/awaymission/evil_santa/forest_labyrinth
	name = "Evil santa forest labyrinth"
	icon_state = "dark"
	ambientsounds = list(
			'sound/ambience/spooky/haunting_ambience.ogg',
			'sound/ambience/spooky/suspenseful_ambience.ogg',
			'sound/ambience/spooky/scary_sci_fi_ambience.ogg',
			)

/area/vision_change_area/awaymission/evil_santa/end/santa/proc/set_ready()
	cooldown = FALSE
	ready_or_not()

/area/vision_change_area/awaymission/evil_santa/end/santa/proc/UnlockBlastDoors()
	if(battle)
		battle = FALSE
		for(var/obj/machinery/door/poddoor/impassable/preopen/P in GLOB.airlocks)
			if(P.density && P.id_tag == "Evil_Santa_Arena" && P.z == z && !P.operating)
				addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/machinery/door, open)), 3 SECONDS)

/area/vision_change_area/awaymission/evil_santa/end/santa/proc/BlockBlastDoors()
	if(!battle)
		for(var/obj/machinery/door/poddoor/impassable/preopen/P in GLOB.airlocks)
			if(!P.density && P.id_tag == "Evil_Santa_Arena" && P.z == z && !P.operating)
				INVOKE_ASYNC(P, TYPE_PROC_REF(/obj/machinery/door, close))
		battle = TRUE
		for(var/mob/trapped_one in naughty_guys)
			to_chat(trapped_one, span_danger("YOU'VE BEEN TOO NAUGHTY THIS YEAR AND NOW YOU WILL BE PUNISHED!"))

/area/vision_change_area/awaymission/evil_santa/end/santa/proc/ready_or_not()
	SIGNAL_HANDLER
	if(!naughty_guys)
		naughty_guys = list()
	for(var/mob/living/carbon/naughty in naughty_guys)
		UnregisterSignal(naughty, COMSIG_MOB_DEATH)
		naughty_guys &= ~naughty

	if(!boss?.is_dead())
		var/list/maybe_naughty_guys = list()
		for(var/mob/living/carbon/naughty in src)
			maybe_naughty_guys |= naughty
		for(var/obj/mecha/robot in src)
			if(robot.occupant)
				maybe_naughty_guys |= robot.occupant
		for(var/obj/structure/closet/coffin in src)
			for(var/mob/living/carbon/body in coffin)
				maybe_naughty_guys |= body
		for(var/mob/living/carbon/naughty in maybe_naughty_guys)
			if(naughty.mind && !naughty.is_dead())
				naughty_guys |= naughty
				RegisterSignal(naughty, COMSIG_MOB_DEATH, PROC_REF(ready_or_not))

	if(naughty_guys.len > 0)
		BlockBlastDoors()
	else
		UnlockBlastDoors()

/area/vision_change_area/awaymission/evil_santa/end/santa/Entered(mob/living/carbon/naughty, area/old_area)
	. = ..()
	if(ismecha(naughty))
		var/obj/mecha/robot = naughty
		if(robot.occupant)
			naughty = robot.occupant
	if(!istype(naughty))
		return
	if(!boss || boss.is_dead())
		return
	if(cooldown)
		return
	cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(ready_or_not)), 4 SECONDS, TIMER_UNIQUE)
	addtimer(CALLBACK(src, PROC_REF(set_ready)), 5 SECONDS, TIMER_UNIQUE)

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
		/obj/item/storage/box/syndie_kit/mr_chang_technique,
		/obj/item/documents/syndicate/yellow/trapped,
		/obj/item/documents/nanotrasen,
		/obj/item/documents/syndicate/mining,
		/obj/item/paper/researchnotes,
		/obj/item/melee/energy/sword/pirate,
		/obj/item/stack/spacecash/c5000,
		/obj/item/stack/spacecash/c1000,
		/obj/item/storage/box/wizard/hardsuit,
		/obj/item/storage/box/syndie_kit/hardsuit,
		/obj/item/clothing/suit/space/hardsuit/champion/templar/premium,
		/obj/item/clothing/suit/space/hardsuit/soviet,
		/obj/item/clothing/suit/space/hardsuit/ancient,
		/obj/item/clothing/suit/space/eva/pirate/leader,
		/obj/item/clothing/head/helmet/space/eva/pirate/leader,
		/obj/item/hardsuit_shield/syndi,
		/obj/item/hardsuit_shield/wizard,
		/obj/vehicle/space/speedbike/red,
		/obj/vehicle/space/speedbike/red,
		/obj/vehicle/space/speedbike,
		/obj/vehicle/space/speedbike,
		/obj/vehicle/motorcycle,
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
		/obj/item/toy/plushie/pig,
		/obj/item/toy/plushie/pig,
		/obj/item/toy/plushie/pig,
		/obj/item/toy/xmas_cracker,
		/obj/item/toy/xmas_cracker,
		/obj/item/toy/pet_rock/naughty_coal,
		/obj/item/reagent_containers/food/snacks/sugar_coal,
		)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.temporarily_remove_item_from_inventory(src, force = TRUE)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/obj/effect/spawner/lootdrop/evil_santa_gift
	name = "evil santa reward gift spawner 1 to 3"
	icon_state = "evil_santa_gift"
	lootdoubles = FALSE

	loot = list(
				/obj/item/a_gift/evil_santa_reward = 33,
				/obj/item/a_gift = 67,
				)

/obj/item/paper/journal_scrap_1
	name = "Журнал неизвестного, страница 1"
	info = "И снова уголёк...<br> \
			Каждый год, как наступает этот дурацкий праздник - я обнаруживаю вместо подарка УГОЛЬ!.<br> \
			Но не в этот раз. Хватит с меня. В этом году всё будет по другому. Клянусь, я найду этого старикашку.<br> \
			И он отдаст мне ВСЕ подарки, если, конечно, он хочет жить долго и продолжать наслаждаться своим печеньем с молоком."

/obj/item/paper/journal_scrap_2
	name = "Журнал неизвестного, страница 9"
	info = "Свереный полюс... Все думали, что это всего лишь легенда, но он на самом деле живет здесь!<br> \
			А вот эльфы и сказочная деревушка - полная брехня. Не знаю, где он собирает все эти игрушки, но я обязательно выясню.<br> \
			Не так уж и много интересного тут на полюсе: снег, лес, да пара иглу; но в центре леса что то есть... Уверен он прячется там!.<br> \
			К слову, здесь очень приятный и липкий снег. Сегодня слепил снеговика."

/obj/item/paper/journal_scrap_3
	name = "Журнал неизвестного, страница 25"
	info = "Ох чёрт... Это хреново...<br> \
			Даже такой закаленный боец синдиката, как я, еле убежал от него. Едва не откинул концы...<br> \
			Он ждал меня... Он знал, что я приду. Он был готов.<br> \
			Едвали смогу выбраться. Оружие бы мне помогло, если бы я не решил его оставить...<br> \
			Я застрял в его шахте, надеюсь сигнал дойдет до базы и помощь придет... <br> \
			<br> \
			ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ. ОН ЗНАЕТ."
