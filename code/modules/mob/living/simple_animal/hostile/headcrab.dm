
GLOBAL_LIST_INIT(hctypes, list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison))

//со временем наверное появятся воскрешающий и бронированный. наверное. если спрайтер еще хочет...

/mob/living/simple_animal/hostile/headcrab
	name = "headcrab"
	desc = "A small parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	health = 60
	maxHealth = 60
	dodging = 1
	melee_damage_lower = 5
	melee_damage_upper = 10
	ranged = 1
	ventcrawler = 2
	ranged_message = "leaps"
	ranged_cooldown_time = 40
	var/jumpdistance = 4
	var/jumpspeed = 2
	turns_per_move = 4
	bubble_icon = "alien"
	move_to_delay = 4.8
	speed = 1.25
	mob_size = MOB_SIZE_SMALL
	see_in_dark = 20
	attacktext = "грызёт"
	pass_flags = PASSTABLE | PASSMOB
	a_intent = INTENT_HARM
	attack_sound = list('sound/creatures/headcrab_attack1.ogg', 'sound/creatures/headcrab_attack2.ogg')
	speak_emote = list("hisses")
	var/is_zombie = FALSE
	stat_attack = DEAD // Necessary for them to attack (zombify) dead humans
	robust_searching = 1
	var/host_species = ""
	var/list/human_overlays = list()
	var/revive_cooldown = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/vent_cooldown = 40
	var/building = FALSE
	var/hiding = FALSE
	var/gonome = FALSE
	var/can_be_gonomed = TRUE
	var/infest = TRUE
	var/gonome_time = 468
	var/is_gonarch = FALSE // кажется уже какой-то спагетти код, прямо как писал американец ниже.
	var/is_monkey_type = FALSE

/mob/living/simple_animal/hostile/headcrab/Move(atom/newloc, dir, step_x, step_y)
	. = ..()

/mob/living/simple_animal/hostile/headcrab/proc/transfer_personality(var/client/candidate)

	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/user = create_headcrab_mind(candidate.ckey)
		user.transfer_to(src)
		candidate.mob = src
		ckey = candidate.ckey
		if(!is_zombie)
			to_chat(src, "<span class='notice'>You are a headcrab!</span>")
			to_chat(src, "To jump, try to use ranged attack.")
		else
			to_chat(src, "<span class='notice'>You are a zombie!</span>")
			to_chat(src, "Maybe you will try to kill humans for bodies for your little brothers?")

/mob/living/simple_animal/hostile/headcrab/proc/create_headcrab_mind(key)
	var/datum/mind/user = new /datum/mind(key)
	user.assigned_role = "Headcrab"
	user.special_role = "Headcrab"
	return user

/mob/living/simple_animal/hostile/headcrab/attack_ghost(mob/user)
	if(cannotPossess(user))
		to_chat(user, "<span class='boldnotice'>Upon using the antagHUD you forfeited the ability to join the round.</span>")
		return
	if(jobban_isbanned(user, "Syndicate"))
		to_chat(user, "<span class='warning'>You are banned from antagonists!</span>")
		return
	if(key)
		return
	if(stat != CONSCIOUS)
		return
	var/be_headcrab = alert("Become a [is_zombie ? "zombie" : "headcrab"]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_headcrab == "No" || !src || QDELETED(src))
		return
	if(key)
		return
	transfer_personality(user.client)

/mob/living/simple_animal/hostile/headcrab/verb/build_a_nest()
	set category = "Headcrab"
	set name = "Build a nest"
	set desc = "Sacrifice yourself after a big time to build a nest."

	var/turf/T = get_turf(src)
	for(var/obj/structure/spawner/headcrab in orange(60, T))
		to_chat(src, "There is a nest nearby, move more than 60 tiles away from it!")
		return

	if(building)
		return
	building = TRUE
	to_chat(src, "<span class='notice'>You start to falling apart...</span>")
	if(do_after(src, 600, target = src, progress=TRUE))
		for(var/obj/structure/spawner/headcrab in orange(60, T))
			to_chat(src, "There is a nest nearby, move more than 60 tiles away from it!")
			return
		var/obj/structure/spawner/headcrab/R = new /obj/structure/spawner/headcrab(src.loc)
		src.visible_message("<span class='notice'>[src] disintegrated, creating \a [R].\
			</span>", "<span class='notice'>You assemble \a [R].</span>")
		qdel(src)
	building = FALSE

/mob/living/simple_animal/hostile/headcrab/verb/infest_disable()
	set category = "Headcrab"
	set name = "Disable Infestation"
	set desc = "Disabling or enabling infestation of body."

	if(infest)
		infest = FALSE
	else
		infest = TRUE

	to_chat(src, "<span class=notice'>You have [infest ? "toggled" : "disabled" ] automatic infestation of body.</span>")

/mob/living/simple_animal/hostile/headcrab/verb/targeted_infest()
	set category = "Headcrab"
	set name = "Targeted Infest"
	set desc = "Infest a selected by you humanoid host."

	if(stat)
		to_chat(src, "You cannot infest a target in your current state.")
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(2,src))
		var/obj/item/organ/external/head/head = H.get_organ("head")
		if(head.is_robotic())
			continue
		if(H.stat == DEAD)
			choices += H

	var/mob/living/carbon/human/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src)
		return

	if(M.revive_cooldown > 0)
		to_chat(src ,"You must wait [revive_cooldown/10] seconds! Body is too warm after last infestation.")

	if(!do_after(src, 16, target = M))
		return

	if(M in orange(2, src))
		Zombify(M)
	else
		to_chat(src, "They are no longer in range!")
		return

/mob/living/simple_animal/hostile/headcrab/verb/hide_headcrab()
	set category = "Headcrab"
	set name = "Hide"
	set desc = "Become invisible to the common eye."

	if(stat != CONSCIOUS)
		return

	if(!hiding)
		layer = TURF_LAYER+0.2
		to_chat(src, "<span class=notice'>You are now hiding.</span>")
		hiding = TRUE
	else
		layer = MOB_LAYER
		to_chat(src, "<span class=notice'>You stop hiding.</span>")
		hiding = FALSE

/mob/living/simple_animal/hostile/headcrab/adjustHealth(damage)

	if(damage > 0)
		vent_cooldown += 40

	return ..()

/mob/living/simple_animal/hostile/headcrab/Life(seconds, times_fired)

	src.heal_overall_damage(0.2, 0.2)

	if(is_gonarch)
		return

	if(is_zombie && !gonome && can_be_gonomed)
		gonome_time--

	if(!is_zombie)
		vent_cooldown--
		revive_cooldown--

	if(gonome_time == 0)
		gonome_time = -10 // предотвращаем постоянно пополняющих себе хп зомби с атакой в 1000 урона
		gonome = TRUE
		to_chat(src, "<span class='notice'>You are evolved to gonome!</span>")
		to_chat(src, "Now you can shoot toxic vomit, healed for 25 health and have additional 50 health of maximum with additional 10 damage.")
		ranged = 1
		ranged_cooldown_time = 60
		src.heal_overall_damage(25, 25)
		melee_damage_lower += 5
		melee_damage_upper += 10
		obj_damage += 20
		projectiletype = /obj/item/projectile/toxinvomit
		projectilesound = 'sound/weapons/pierce.ogg'
		ranged_message = "pukes"
		desc += " This individual seems to have evolved, and it has been alive around for quite a long time."

	if(..() && !stat)
		if(!is_zombie && isturf(src.loc) && infest)
			for(var/mob/living/carbon/human/H in oview(src, 2)) //Only for corpse right next to/on same tile
				if(H.stat == DEAD /*|| (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD)*/ && H.revive_cooldown <= 0) //по неизвестной причине мартышки похоже до убирания этого условия не хотели зомбифицироваться
					Zombify(H)
					break
		if(times_fired % 4 == 0)
			for(var/mob/living/simple_animal/K in oview(src, 2)) //Only for corpse right next to/on same tile
				if(K.stat == DEAD || (!K.check_death_method() && K.health <= HEALTH_THRESHOLD_DEAD))
					visible_message("<span class='danger'>[src] consumes [K] whole!</span>")
					src.heal_overall_damage(10, 10)
					qdel(K)
					break

	if(key)
		return

	if(prob(2) && !is_zombie) //it was a proc with a name its_time_to_kill_yourself

		var/turf/probably_nest = get_turf(src)

		for(var/obj/structure/spawner/headcrab in orange(40, probably_nest))
			return

		visible_message("<span class='danger'>[src] are falled apart in headcrab's nest!</span>")
		qdel(src)
		new /obj/structure/spawner/headcrab(probably_nest)


	if(prob(26) && vent_cooldown <= 0 && !approaching_target && !in_melee)
		if(!is_zombie || is_monkey_type)
			for(var/obj/machinery/atmospherics/unary/vent_pump/ventilation in orange(4,src))
				if(!ventilation.welded)
					entry_vent = ventilation
					walk_to(src, entry_vent, 1)
					break

	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null

	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			var/list/vents = list()
			for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.parent.other_atmosmch)
				vents.Add(temp_vent)
			if(!vents.len)
				entry_vent = null
				return
			var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
			if(prob(75))
				audible_message("<B>[src] scrambles into the ventilation ducts!</B>", \
								"<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")

			spawn(rand(20,60))
				loc = exit_vent
				var/travel_time = round(get_dist(loc, exit_vent.loc) * 2)
				spawn(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return

					if(prob(50))
						audible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>")
					sleep(travel_time)

					if(!exit_vent || exit_vent.welded)
						loc = entry_vent
						entry_vent = null
						return
					loc = exit_vent.loc
					entry_vent = null
					vent_cooldown += 200
					step(src, pick(NORTH, SOUTH, EAST, WEST))
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)

/mob/living/simple_animal/hostile/headcrab/OpenFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T in getline(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return

	if(!is_zombie && !is_gonarch)
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
		throw_at(A, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE)
		ranged_cooldown = world.time + ranged_cooldown_time
		vent_cooldown += 60

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()

	vent_cooldown += 80

	return ..()

/mob/living/simple_animal/hostile/headcrab/attack_hand(mob/living/carbon/human/M as mob)
	..()

	if(M.a_intent == INTENT_HELP && src.stat == DEAD && !is_zombie && !is_gonarch)
		scoop_up_headcrab(M)
	return ..()

/obj/item/reagent_containers/food/snacks/headcrab

	icon_state = "headcrab" //by default
	icon = 'icons/mob/headcrab.dmi'
	bitesize = 2
	list_reagents = list("protein" = 2, "nutriment" = 1)
	tastes = list("meat" = 1)
	foodtype = MEAT | RAW
	var/armored = FALSE

/obj/machinery/cooker/foodgrill/putIn(obj/item/In, mob/chef)
	..()

	var/obj/item/reagent_containers/food/snacks/headcrab/hc = In

	if(hc.armored)
		to_chat(chef, "<span class='notice'>Break his armor first!</span>")
		return

	if(istype(In, /obj/item/reagent_containers/food/snacks/headcrab) && !hc.armored)
		sleep(148)
		hc.list_reagents += list("nutriment" = 1)
		hc.foodtype += FRIED
		hc.foodtype -= RAW

/obj/item/reagent_containers/food/snacks/headcrab/attack(mob/M, mob/user, def_zone)
	..()

	if(istype(src, /obj/item/reagent_containers/food/snacks/headcrab) && src.armored)
		if(armored)
			to_chat(M, "<span class='notice'>Break his armor first!</span>")
		return

/obj/item/reagent_containers/food/snacks/headcrab/attack_self(mob/user)
	..()

	if(istype(src, /obj/item/reagent_containers/food/snacks/headcrab) && src.armored)
		if(do_after(src, 40, target = user, progress=TRUE))
			src.armored = FALSE
			to_chat(user, "<span class='notice'>His armor was breaked! Time to eat!</span>")
			var/number = 0
			number = rand(1,6)
			playsound(user.loc, "sound/effects/bone_break[number].ogg", 25, TRUE, ignore_walls = FALSE, is_global = null)

/obj/item/reagent_containers/food/snacks/headcrab/Post_Consume(mob/living/M)
	..()

	qdel(src)

	if(prob(6))
		to_chat(M, "<span class='notice'>Strange... Headcrab doesnt tastes like crab...</span>")

/mob/living/simple_animal/hostile/headcrab/proc/scoop_up_headcrab(var/mob/living/carbon/grabber)

	var/obj/item/reagent_containers/food/snacks/headcrab/H = new /obj/item/reagent_containers/food/snacks/headcrab(loc)
	H.name = name
	H.icon_state = icon_state
	H.desc = desc

	if(istype(src, /mob/living/simple_animal/hostile/headcrab/poison) || istype(src, /mob/living/simple_animal/hostile/headcrab/reviver))
		desc += " Eating and/or cooking this - a very bad idea."
		H.foodtype += TOXIC

	if(istype(src, /mob/living/simple_animal/hostile/headcrab/poison))
		H.list_reagents += list("headcrab_neurotoxin" = 2)
		H.bitesize = 4

	if(istype(src, /mob/living/simple_animal/hostile/headcrab/reviver))
		H.list_reagents += list("teslium" = 2)
		H.bitesize = 1

	if(istype(src, /mob/living/simple_animal/hostile/headcrab/armored))
		H.armored = TRUE
		H.list_reagents += list("protein" = 1, "nutriment" = 2)
		H.bitesize = 3

	if(istype(src, /mob/living/simple_animal/hostile/headcrab/fast))
		H.bitesize = 1

	src.forceMove(H)

	H.attack_hand(grabber)

	to_chat(grabber, "<span class='notice'>You scoop up \the [src].")
	return H

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	..()

	if(istype(src, /mob/living/simple_animal/hostile/headcrab) && src.stat == DEAD && istype(I, /obj/item/storage/bag/trash/))
		var/mob/living/simple_animal/hostile/headcrab/hcproc = src
		var/obj/item/storage/bag/trash/trash_bag = I
		var/obj/item/hold = hcproc.scoop_up_headcrab(user)
		trash_bag.handle_item_insertion(hold, prevent_warning = FALSE)

/mob/living/simple_animal/hostile/headcrab/New()

	..()

	add_language("Headcrab Hivemind") // в каждом раунде наверняка будет фраза "Штурмуем морг"
	default_language = GLOB.all_languages["Headcrab Hivemind"]
	name += " ([rand(1, 1000)])"
	real_name = name
	if(!is_zombie)
		verbs -= /mob/living/verb/pulled

/mob/living/simple_animal/hostile/headcrab/proc/Zombify(mob/living/carbon/human/H)
	if(!H.check_death_method())
		H.death()
	//var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor.getRating("melee"))
			maxHealth += A.armor.getRating("melee") //That zombie's got armor, I want armor!
	maxHealth += 200
	health = maxHealth
	if(H.job in list("Security Officer", "Head of Security", "Security Pod Pilot", "Warden", "Detective", "Brig Physician", "Blueshield") || H.job in get_all_centcom_jobs()) //аналог зомбайна
		name = "zomcur" // Хм-мм. Щиткуры-зомби. щи...ку...зомкуры! Как тебе?.. Ха. Зомкуры. Дошло? Хе-хе. О...кей.
	else
		name = "zombie"
	desc = "A corpse animated by the alien being on its head."
	name += " ([rand(1, 1000)])"
	real_name = name
	melee_damage_lower = 20
	melee_damage_upper = 25
	src.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/hide_headcrab
	src.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/build_a_nest
	src.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/infest_disable
	src.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/targeted_infest
	src.verbs += /mob/living/verb/pulled
	ranged = 0
	dodging = 0
	pass_flags |= PASSTABLE | PASSMOB | LETPASSTHROW
	stat_attack = CONSCIOUS // Disables their targeting of dead mobs once they're already a zombie
	icon = H.icon
	mob_size = MOB_SIZE_HUMAN
	pass_flags = null
	move_to_delay = 5.6
	speak = list('sound/creatures/zombie_idle1.ogg','sound/creatures/zombie_idle2.ogg','sound/creatures/zombie_idle3.ogg')
	speak_chance = 50
	obj_damage += 40 //используя мышечную массу тела хедкраб бъет сильнее объекты
	speak_emote = list("groans")
	attacktext = "кромсает"
	attack_sound = 'sound/creatures/zombie_attack.ogg'
	icon_state = "zombie2_s"
	/*if(head_organ)
		head_organ.h_style = null //ладно, сжалимся над игроками, пусть остается прическа.
	H.update_hair()*/
	host_species = H.dna.species.name
	if(ismonkeybasic(H) || isfarwa(H) || iswolpin(H) || isneara(H) || isstok(H))
		ventcrawler = 2
		maxHealth -= 100 //взамен на пользанье по вентам и скорость
		is_monkey_type = TRUE
		speed += 0.16
		move_to_delay -= 1.4
	else
		ventcrawler = 0
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)

	if(!istype(src, /mob/living/simple_animal/hostile/headcrab/reviver))
		visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")
	else
		visible_message("<span class='warning'>The corpse of [H.name] convulses a bit and suddenly rises!</span>")

	to_chat(src, "<span class='notice'>You are a zombie now!</span>")
	to_chat(src, "No ventcrawling now (if you are not monkey and etc). But more health.")

/mob/living/simple_animal/hostile/headcrab/death()
	..()
	if(is_zombie)
		qdel(src)

/mob/living/simple_animal/hostile/headcrab/handle_automated_speech() // This way they have different screams when attacking, sometimes. Might be seen as sphagetthi code though.
	if(speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				playsound(get_turf(src), pick(speak), 200, 1)

/mob/living/simple_animal/hostile/headcrab/Destroy()
	if(contents)
		for(var/mob/M in contents)
			M.forceMove(get_turf(src))
	return ..()

/mob/living/simple_animal/hostile/headcrab/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/CanAttack(atom/the_target)
	if(stat_attack == DEAD && isliving(the_target) && !ishuman(the_target))
		var/mob/living/L = the_target
		if(L.stat == DEAD)
			// Override default behavior of stat_attack, to stop headcrabs targeting dead mobs they cannot infect, such as silicons.
			return FALSE
	return ..()

//GONOME STUFF

/mob/living/simple_animal/hostile/headcrab/Stat()
	..()

	if(gonome || !is_zombie || !can_be_gonomed)
		return

	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		stat("Time until Evolution", gonome_time)

/obj/item/projectile/toxinvomit
	name = "toxic vomit" // for gonome
	damage = 15
	damage_type = BURN
	stamina = 25
	drowsy = 5
	jitter = 5
	eyeblur = 2
	slur = 5
	icon_state = "toxinvomit"

/obj/item/projectile/toxinvomit/on_hit(mob/living/target)
	. = ..()

	var/mob/living/victim = target

	victim.adjustToxLoss(rand(0,6))

	if(istype(firer, /mob/living/simple_animal/hostile/headcrab/poison))
		victim.adjustToxLoss(rand(2,8))
		target.reagents.add_reagent("headcrab_neurotoxin", rand(2,4))

//NOT GONOME STUFF

/mob/living/simple_animal/hostile/headcrab/fast
	name = "fast headcrab"
	desc = "A fast parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "fast_headcrab"
	icon_living = "fast_headcrab"
	icon_dead = "fast_headcrab_dead"
	health = 40
	maxHealth = 40
	ranged_cooldown_time = 30
	turns_per_move = 2
	move_to_delay = 3.8
	speed = 0.75
	jumpdistance = 8
	jumpspeed = 4
	speak_emote = list("screech")

/mob/living/simple_animal/hostile/headcrab/fast/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/fast/Zombify(mob/living/carbon/human/H)
	. = ..()
	speak = list('sound/creatures/fast_zombie_idle1.ogg','sound/creatures/fast_zombie_idle2.ogg','sound/creatures/fast_zombie_idle3.ogg')

	melee_damage_lower = 15
	melee_damage_upper = 20
	move_to_delay = 5.6

	var/newname = "fast [name]"

	name = newname

	maxHealth -= 40
	health = maxHealth //быстрые обычно менее жирные по хп. сделеам так же.

	speed = 0.55

/mob/living/simple_animal/hostile/headcrab/poison
	name = "poison headcrab"
	desc = "A poison parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "poison_headcrab"
	icon_living = "poison_headcrab"
	icon_dead = "poison_headcrab_dead"
	health = 80
	maxHealth = 80
	ranged_cooldown_time = 50
	jumpdistance = 3
	jumpspeed = 1
	ranged = 1
	speed = 1.4
	move_to_delay = 6.5
	melee_damage_lower = 8
	melee_damage_upper = 20
	attack_sound = list('sound/creatures/poison_headcrab_attack1.ogg', 'sound/creatures/poison_headcrab_attack2.ogg', 'sound/creatures/poison_headcrab_attack3.ogg')
	speak_emote = list("shrilly squeaks")
	var/neurotoxin_per_jump = 6
	var/poison_headcrabs = 0
	can_be_gonomed = FALSE

/mob/living/simple_animal/hostile/headcrab/poison/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/poison/Zombify(mob/living/carbon/human/H)
	. = ..()

	speak = list('sound/creatures/poison_zombie_idle1.ogg','sound/creatures/poison_zombie_idle2.ogg','sound/creatures/poison_zombie_idle3.ogg', 'sound/creatures/poison_zombie_idle4.ogg')

	poison_headcrabs = rand(3,4)
	desc += " It's [src.poison_headcrabs] [src.poison_headcrabs == 1 ? "headcrab" : "headcrabs" ] on it's back."

	melee_damage_lower = 25
	melee_damage_upper = 30
	move_to_delay = 22

	var/newname = "poison [name]"

	name = newname

	to_chat(src, "There are [poison_headcrabs] on your back. Use ranged attack to throw them at enemies.")

	speed = 2.85
	ranged_cooldown_time = 100
	maxHealth += 25
	health = maxHealth //как никак, танк
	obj_damage += 40 //ядовитый зомби выступает что-то вроде танка, поэтому и здоровья с уроном побольше.

	sleep(20)

	ranged = 1

/mob/living/simple_animal/hostile/headcrab/poison/Stat()
	..()

	if(!is_zombie || poison_headcrabs == 0)
		return

	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		stat("Headcrabs", poison_headcrabs)

/mob/living/simple_animal/hostile/headcrab/poison/AttackingTarget()
	. = ..()

	if(iscarbon(target) && !src.is_zombie)
		var/inject_target = pick("chest", "head")
		var/mob/living/carbon/victim = target
		if(neurotoxin_per_jump > 0 && iscarbon(victim))
			victim.reagents.add_reagent("headcrab_neurotoxin", neurotoxin_per_jump + rand(0,2))
			if(victim.eye_blurry < 60)
				victim.AdjustEyeBlurry(10)
				visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")

	if(iscarbon(target) && src.is_zombie && prob(46))
		var/mob/living/carbon/victim = target
		victim.reagents.add_reagent("headcrab_neurotoxin", rand(1,2) + rand(0,2))

/mob/living/simple_animal/hostile/headcrab/poison/OpenFire(atom/target)
	. = ..()

	if(!key && prob(26) && src.is_zombie) //игрок кидаться может всегда, а ИИ лишь с шансом.
		return

	if(src.is_zombie && isturf(src.loc) && src.poison_headcrabs != 0) // в оригинале несколько хедркабов было на спине у ядовитого, и еще... он ими кидался. у нас же он их внезапно рожает и умеет кидаться
		if(check_friendly_fire)
			for(var/turf/loc in getline(src,target)) // Not 100% reliable but this is faster than simulating actual trajectory
				for(var/mob/living/victim in loc)
					if(victim == src || victim == target)
						continue
					if(faction_check_mob(victim) && !attack_same)
						return
			var/turf/zombie_loc = get_turf(src)
			var/mob/living/simple_animal/hostile/headcrab/poison/headcrab = new(zombie_loc)
			src.poison_headcrabs--
			headcrab.poison_headcrabs = 0 //был баг с мгновенным размножением. нет. нельзя.
			desc = "A corpse animated by the alien being on its head. It's [src.poison_headcrabs] [src.poison_headcrabs == 1 ? "headcrab" : "headcrabs" ] on it's back."
			if(src.poison_headcrabs == 0)
				desc = "A corpse animated by the alien being on its head."
				ranged = 0
				to_chat(src, "No more headcrabs on your back, pal! But... You can be gonome now!")
				can_be_gonomed = TRUE
				gonome_time -= 40
				speed = 2.70 // больше нет ноши на спине... да и компенсация отсутсвия дальней атаки
				move_to_delay = 20.4
			visible_message("<span class='danger'><b>[src]</b> throwing [headcrab] at [target]!</span>")
			playsound(src, list('sound/effects/poison_headcrab_throw1.ogg', 'sound/effects/poison_headcrab_throw2.ogg'), 45, 1)
			headcrab.throw_at(target, headcrab.jumpdistance, headcrab.jumpspeed, spin = FALSE, diagonals_first = TRUE)
/*

=================================================
(                                               )
(       NO SPRITES, BUT CODED                   )
(                                               )
=================================================

*/

/mob/living/simple_animal/hostile/headcrab/armored //no sprites, but coded
	name = "armored headcrab"
	desc = "An armored parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	harm_intent_damage = 2
	move_to_delay = 7
	health = 125
	maxHealth = 125
	ranged_cooldown_time = 45
	speed = 1.1
	jumpdistance = 2
	jumpspeed = 0.5
	speak_emote = list("slowly hisses")
	damage_coeff = list(BRUTE = 0.88, BURN = 0.88, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

/mob/living/simple_animal/hostile/headcrab/armored/attack_hand(mob/living/carbon/human/M)

	if(src.stat == DEAD)
		return

	var/mob/living/carbon/idiot = M
	if(!(PIERCEIMMUNE in idiot.dna.species.species_traits))
		var/obj/item/organ/external/affecting = idiot.get_organ("[idiot.hand ? "l" : "r" ]_hand")
		M.emote("scream")
		to_chat(idiot, "<span class='danger'>Ouch! That was a bad idea, his spikes are painful and armor so strong!</span>")
		if(affecting.receive_damage(4 * 2))
			idiot.UpdateDamageIcon()

/mob/living/simple_animal/hostile/headcrab/armored/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/armored/Zombify(mob/living/carbon/human/H)
	. = ..()

	maxHealth += 60 //armored? armored.
	health = maxHealth
	move_to_delay = 16

	var/newname = "armored [name]"

	name = newname

	speed = 1.2

/mob/living/simple_animal/hostile/headcrab/reviver //no sprites, but coded //x2
	name = "reviver headcrab"
	desc = "A strange parasitic creature that would like to connect with your brain stem through your upper body. It looks like, that it can shock you."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	health = 45
	maxHealth = 45
	ranged_cooldown_time = 35
	speed = 0.75
	move_to_delay = 4.6
	turns_per_move = 1
	melee_damage_lower = 4
	melee_damage_upper = 8
	jumpdistance = 6
	jumpspeed = 3
	speak_emote = list("buzzing like an electricity")
	damage_coeff = list(BRUTE = 1, BURN = 0.92, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	revive_cooldown = 30

/mob/living/simple_animal/hostile/headcrab/reviver/AttackingTarget()
	. = ..()

	var/mob/living/carbon/victim = target

	if(prob(50))
		do_sparks(1, 1, src)
		playsound(src.loc, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg'), 20, 1)

	if(prob(86))
		victim.adjustFireLoss(rand(0,4))
	else
		target.reagents.add_reagent("teslium", rand(2,4))

	if(prob(66))
		victim.adjustStaminaLoss(rand(6.5,12.5)) //stuncrab 12.5

/mob/living/simple_animal/hostile/headcrab/reviver/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/reviver/Zombify(mob/living/carbon/human/H)
	. = ..()

	speed = 0.80

	var/newname = "revived [name]"

	name = newname
	move_to_delay = 6.8

	H.shock_internal_organs(100)
	H.set_heartattack(FALSE) //уподобление оригиналу, что-то вроде оживления.
	src.revive_cooldown += 15

/mob/living/simple_animal/hostile/headcrab/reviver/death(gibbed)
	. = ..()

	var/turf/death_loc = get_turf(src)

	var/mob/living/simple_animal/hostile/headcrab/reviver/headcrab = new /mob/living/simple_animal/hostile/headcrab/reviver(death_loc) //уподобление оригиналу, этот вид хедкраба должен быть убит вне тела.

	headcrab.revive_cooldown += 30

/mob/living/simple_animal/hostile/headcrab/gonarch
	name = "gonarch"
	desc = "The highest stage of the evolution of the Headcrab. It generates even more of its own kind and is better than some nest. And it's definitely not a parasite that would like to connect with your brain stem. Strange."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab" //да-да, опять без спрайтов, но накодировано, понадеемся, что появится спрайтер.
	icon_dead = "headcrab_dead"
	gender = FEMALE
	health = 400
	maxHealth = 400
	dodging = 0
	melee_damage_lower = 40
	melee_damage_upper = 60
	ranged = 0
	ventcrawler = 0
	turns_per_move = 8
	move_to_delay = 18
	speed = 0.28
	obj_damage = 264
	armour_penetration = 15
	environment_smash = 3
	attacktext = "pierces" //по просьбе ларентоун отменил перевод. вообще не логично, это я создал этого моба, и я по-русски написал его аттак текст. где перевод? я вообще мог подшутить и оставить наследование attacktext от хедкраба. однако грызть гонарх не может...
	pass_flags = PASSTABLE | PASSMOB | LETPASSTHROW //огромная хервоина на четырех ногах, очевидно, что через нее можно пролететь снизу, пройти.
	attack_sound = list()
	speak_emote = list("howling")
	is_gonarch = TRUE
	stat_attack = CONSCIOUS // бесит это наследование, когда не надо, не убрать.
	robust_searching = 1
	damage_coeff = list(BRUTE = 0.80, BURN = 0.80, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)

	var/max_mobs = 10
	var/spawn_time = 600 //ходячий спавнер.
	var/mob_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	var/spawn_text = "birthing from"
	var/spawner_type = /datum/component/spawner

/mob/living/simple_animal/hostile/headcrab/gonarch/CanAttack(atom/the_target)
	var/mob/living/L = the_target
	if(L.stat == CONSCIOUS || L.stat == UNCONSCIOUS) //никого не щадить.
		return TRUE //никого не щадить
	return ..()


/mob/living/simple_animal/hostile/headcrab/gonarch/Initialize(mapload)
	. = ..()
	AddComponent(spawner_type, mob_types, spawn_time, faction, spawn_text, max_mobs)

/*

=================================================
(                                               )
(                SPRITED                        )
(                                               )
=================================================

*/

/obj/structure/crabmissile
	name = "crab missile"
	desc = "A small black capsule, which previously contained parasitic creatures Headcrabs. Death to NanoTrasen. Glory to Syndicate."
	icon_state = "crabmissile"
	density = TRUE
	anchored = TRUE
	max_integrity = 1000
	integrity_failure = 60

/obj/structure/crabmissile/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/crabmissile/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The main <b>bolts</b> are visible.</span>"

/obj/structure/crabmissile/wrench_act(mob/user, obj/item/I)
	if(flags & NODECONSTRUCT)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 100, volume = I.tool_volume))
		var/turf/dismantle_location = get_turf(src)
		var/obj/item/stack/sheet/metal/materials = new /obj/item/stack/sheet/metal(dismantle_location)
		qdel(src)
		materials.amount = 26
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		if(prob(24))
			var/which_one = pick(GLOB.hctypes)
			new which_one(dismantle_location)
			visible_message(src, "<span class='danger'>Inside [src] was hiding a headcrab!</span>")

/datum/action/changeling/revive/sting_action(mob/living/carbon/user)

	for(var/mob/living/simple_animal/hostile/headcrab/hc in orange(user, 1))
		hc.adjustBruteLoss(1000)

	for(var/mob/living/simple_animal/hostile/blob/blobspore/bs in orange(user, 1))
		bs.adjustBruteLoss(1000)

	..()
