
//malfunctioning combat drones
/mob/living/simple_animal/hostile/malf_drone
	name = "combat drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon_state = "drone3"
	icon_living = "drone3"
	icon_dead = "drone_dead"
	universal_speak = TRUE
	ranged = 1
	rapid = 3
	retreat_distance = 3
	minimum_distance = 3
	speak_chance = 5
	turns_per_move = 3
	response_help = "pokes the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speak = list("ALERT.", "Hostile-ile-ile entities dee-twhoooo-wected.", "Threat parameterszzzz- szzet.", "Bring sub-sub-sub-systems uuuup to combat alert alpha-a-a.")
	emote_see = list("beeps menacingly.", "whirrs threateningly.", "scans for targets.")
	a_intent = INTENT_HARM
	stop_automated_movement_when_pulled = FALSE
	health = 200
	maxHealth = 200
	speed = 8
	projectiletype = /obj/item/projectile/beam/immolator/weak
	projectilesound = 'sound/weapons/laser3.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	faction = list("malf_drone")
	deathmessage = "suddenly breaks apart."
	del_on_death = 1
	var/passive_mode = TRUE // if true, don't target anything.
	var/datum/effect_system/trail_follow/ion/ion_trail


/mob/living/simple_animal/hostile/malf_drone/Initialize(mapload)
	. = ..()
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()


/mob/living/simple_animal/hostile/malf_drone/Destroy()
	QDEL_NULL(ion_trail)
	return ..()


/mob/living/simple_animal/hostile/malf_drone/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/hostile/malf_drone/ListTargets()
	if(passive_mode)
		return list()
	return ..()

/mob/living/simple_animal/hostile/malf_drone/AttackingTarget()
	OpenFire(target) // prevents it pointlessly nuzzling its target in melee if its cornered

/mob/living/simple_animal/hostile/malf_drone/update_icons()
	if(passive_mode)
		icon_state = "drone_dead"
	else if(health / maxHealth > 0.9)
		icon_state = "drone3"
	else if(health / maxHealth > 0.7)
		icon_state = "drone2"
	else if(health / maxHealth > 0.5)
		icon_state = "drone1"
	else
		icon_state = "drone0"


/mob/living/simple_animal/hostile/malf_drone/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0)
		do_sparks(3, 1, src)
		passive_mode = FALSE
		update_icons()


/mob/living/simple_animal/hostile/malf_drone/Life(seconds, times_fired)
	. = ..()
	if(.) // mob is alive. We check this just in case Life() can fire for qdel'ed mobs.
		if(times_fired % 15 == 0) // every 15 cycles, aka 30 seconds, 50% chance to switch between modes
			scramble_settings()

/mob/living/simple_animal/hostile/malf_drone/proc/scramble_settings()
	if(prob(50))
		do_sparks(3, 1, src)
		passive_mode = !passive_mode
		if(passive_mode)
			visible_message("<span class='notice'>[src] retracts several targetting vanes.</span>")
			if(target)
				LoseTarget()
		else
			visible_message("<span class='warning'>[src] suddenly lights up, and additional targetting vanes slide into place.</span>")
		update_icons()

/mob/living/simple_animal/hostile/malf_drone/emp_act(severity)
	adjustHealth(100 / severity) // takes the same damage as a mining drone from emp

/mob/living/simple_animal/hostile/malf_drone/drop_loot()
	do_sparks(3, 1, src)

	var/turf/T = get_turf(src)

	//shards
	var/obj/O = new /obj/item/shard(T)
	step_to(O, get_turf(pick(view(7, src))))
	if(prob(75))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(50))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))
	if(prob(25))
		O = new /obj/item/shard(T)
		step_to(O, get_turf(pick(view(7, src))))

	//rods
	var/obj/item/stack/K = new /obj/item/stack/rods(T, pick(1, 2, 3, 4))
	step_to(K, get_turf(pick(view(7, src))))

	//plasteel
	K = new /obj/item/stack/sheet/plasteel(T, pick(1, 2, 3, 4))
	step_to(K, get_turf(pick(view(7, src))))

	//also drop dummy circuit boards deconstructable for research (loot)
	var/obj/item/circuitboard/C

	//spawn 1-4 boards of a random type
	var/spawnees = 0
	var/num_boards = rand(1, 4)
	var/list/options = list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512)
	for(var/i=0, i<num_boards, i++)
		var/chosen = pick(options)
		options.Remove(options.Find(chosen))
		spawnees |= chosen

	if(spawnees & 1)
		C = new(T)
		C.name = "Drone CPU motherboard"
		C.origin_tech = "programming=[rand(3, 6)]"

	if(spawnees & 2)
		C = new(T)
		C.name = "Drone neural interface"
		C.origin_tech = "biotech=[rand(3, 6)]"

	if(spawnees & 4)
		C = new(T)
		C.name = "Drone suspension processor"
		C.origin_tech = "magnets=[rand(3, 6)]"

	if(spawnees & 8)
		C = new(T)
		C.name = "Drone shielding controller"
		C.origin_tech = "bluespace=[rand(3, 6)]"

	if(spawnees & 16)
		C = new(T)
		C.name = "Drone power capacitor"
		C.origin_tech = "powerstorage=[rand(3, 6)]"

	if(spawnees & 32)
		C = new(T)
		C.name = "Drone hull reinforcer"
		C.origin_tech = "materials=[rand(3, 6)]"

	if(spawnees & 64)
		C = new(T)
		C.name = "Drone auto-repair system"
		C.origin_tech = "engineering=[rand(3, 6)]"

	if(spawnees & 128)
		C = new(T)
		C.name = "Drone plasma overcharge counter"
		C.origin_tech = "plasmatech=[rand(3, 6)]"

	if(spawnees & 256)
		C = new(T)
		C.name = "Drone targetting circuitboard"
		C.origin_tech = "combat=[rand(3, 6)]"

	if(spawnees & 512)
		C = new(T)
		C.name = "Corrupted drone morality core"
		C.origin_tech = "syndicate=[rand(3, 6)]"

/mob/living/simple_animal/hostile/malf_drone/syndicate
	stop_automated_movement_when_pulled = TRUE
	faction = list("syndicate")
	speak = list()

/mob/living/simple_animal/bot/ed209/combat_drone
	name = "\improper Combat Drone"
	desc = "An automated combat drone armed with state of the art weaponry and shielding."
	icon = 'icons/mob/animal.dmi'
	icon_state = "drone3"
	density = TRUE
	health = 200
	maxHealth = 200
	speed = 8

	model = "Combat Drone"
	bot_purpose = "devastion"
	bot_core_type = /obj/machinery/bot_core/syndicate
	window_name = "Standart Robot Control v1.6"
	path_image_color = "#FF0000"
	declare_arrests = FALSE
	idcheck = TRUE
	arrest_type = TRUE
	auto_patrol = FALSE
	projectile = /obj/item/projectile/beam/immolator/weak

/mob/living/simple_animal/bot/ed209/combat_drone/Initialize(mapload)
	. = ..()
	set_weapon()
	update_icon()

/mob/living/simple_animal/bot/ed209/combat_drone/update_icon_state()
	icon_state = initial(icon_state)

/mob/living/simple_animal/bot/ed209/combat_drone/setup_access()
	return

/mob/living/simple_animal/bot/ed209/syndicate/set_weapon()
	projectile = /obj/item/projectile/beam/immolator/weak

/mob/living/simple_animal/bot/ed209/combat_drone/turn_on()
	. = ..()
	update_icon()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/ed209/combat_drone/turn_off()
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/ed209/combat_drone/emag_act(mob/user)
	. = ..()
	update_icon()

/mob/living/simple_animal/bot/ed209/combat_drone/start_cuffing(mob/living/carbon/C)
	shootAt(C)

/mob/living/simple_animal/bot/ed209/combat_drone/stun_attack(mob/living/carbon/C)
	shootAt(C)

/obj/item/inactive_drone
	name = "Inactive drone"
	desc = "Большой дрон. Кажется, неактивен."
	w_class = WEIGHT_CLASS_GIGANTIC
	item_flags = NOPICKUP
	icon_state = "unactive_drone"

/obj/item/unactive_drone/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/drone_modules/drone_BCM))
		to_chat(user, span_notice("Вы установили модуль в слот."))
		new /mob/living/simple_animal/bot/ed209/combat_drone(get_turf(src))
		qdel(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(I, /obj/item/drone_modules/drone_IFF))
		to_chat(user, span_notice("Вы установили модуль в слот."))
		new /mob/living/simple_animal/hostile/malf_drone/syndicate(get_turf(src))
		qdel(src)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(istype(I, /obj/item/drone_modules/drone_AI))
		to_chat(user, span_notice("Вам не стоит отходить вместе с платой от дрона, пока он не активируется."))
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за боевого дрона?", ROLE_SENTIENT, FALSE, 10 SECONDS, source = src)
		if(!src || QDELETED(src) || !I || get_dist(src, I) > 1)
			return
		if(length(candidates))
			var/mob/living/simple_animal/hostile/malf_drone/syndicate/S = new /mob/living/simple_animal/hostile/malf_drone/syndicate(get_turf(src))
			var/mob/M = pick(candidates)
			S.key = M.key
			S.master_commander = user
			S.sentience_act()
			to_chat(S, "Модуль активирован. Основная задача: подчинение [user.name]. Дополнительная задача: уничтожение враждебных единиц не относящихся к Синдикату в подконтрольном секторе.")
			S.mind.store_memory("<B>Подчиняться [user.name].</B>")
			qdel(src)
			qdel(I)
			return ATTACK_CHAIN_BLOCKED_ALL
		else
			to_chat(user, span_alert("Похоже, пока что возможности для активации модуля нет. Стоит попробовать позже."))
	. = ..()

/obj/item/drone_manual
	name = "Strange looking Manual"
	desc = "Довольно толстая книжка, на обложке которой вы можете увидеть дрона."
	icon_state = "drone_manual"

/obj/item/drone_manual/attack_self(mob/user)
	. = ..()
	to_chat(user, span_alert("После того как вы пробежались глазами по содержанию книги, она рассыпалась пеплом. Но, кажется, вы можете вспомнить пару методов работы, описанных там - самодельные платы и базовую модель самого дрона."))
	user.mind.learned_recipes += list(/datum/crafting_recipe/drone,
		/datum/crafting_recipe/drone_circ,
		/datum/crafting_recipe/drone_circ_adv,
		/datum/crafting_recipe/drone_circ_ai)
	user.faction += list("syndicate")
	qdel(src)

/obj/item/drone_modules
	name = "Drone module"
	desc = "Если вы это видите - сообщите в баг-репорты."
	icon_state = "drone_BCM"
	var/explanation = "Вы не должны были этого видеть."

/obj/item/drone_modules/examine(mob/user)
	. = ..()
	for(var/datum/crafting_recipe/D in user.mind.learned_recipes)
		if(D.result == type && explanation)
			. += explanation

/obj/item/drone_modules/drone_BCM
	name = "Drone BCM"
	desc = "Неплохо сделанная плата."
	explanation = "Это базовая версия платы стандартного модуля для боевых дронов, сделанная по схеме из книги. Она позволит управлять роботом как обычным дроном без интеллекта."

/obj/item/drone_modules/drone_IFF
	name = "Drone IFFM"
	desc = "Неплохо сделанная плата."
	icon_state = "drone_IFF"
	explanation = "Это плата модуля Свой-Чужой для боевых дронов. Сделанная по схеме из книги, она не допускает изменений - а значит, дроны с подобным модулем всегда будут участвовать в бою на стороне Синдиката."

/obj/item/drone_modules/drone_AI
	name = "Drone AICM"
	desc = "Неплохо сделанная плата."
	icon_state = "drone_AI"
	explanation = "Это продвинутый модуль контроля для боевых дронов. Позволит дрону получить более продвинутый интеллект. Но первоначальное подключение все ещё зависит от внутренней сети, которая может и не быть активной."
