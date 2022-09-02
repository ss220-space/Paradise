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
	attacktext = "грызёт"
	pass_flags = PASSTABLE
	a_intent = INTENT_HARM
	attack_sound = list('sound/creatures/headcrab_attack1.ogg', 'sound/creatures/headcrab_attack2.ogg')
	speak_emote = list("hisses")
	var/is_zombie = 0
	stat_attack = DEAD // Necessary for them to attack (zombify) dead humans
	robust_searching = 1
	var/host_species = ""
	var/list/human_overlays = list()
	var/revive_cooldown = 0
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/vent_cooldown = 20
	var/building = FALSE
	var/hiding = FALSE

/mob/living/simple_animal/hostile/headcrab/proc/transfer_personality(var/client/candidate)

	if(!candidate || !candidate.mob)
		return

	if(!QDELETED(candidate) || !QDELETED(candidate.mob))
		var/datum/mind/M = create_headcrab_mind(candidate.ckey)
		M.transfer_to(src)
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
	if(!is_zombie)
		var/be_headcrab = alert("Become a headcrab? (Warning, You can no longer be cloned!)",,"Yes","No")
		if(be_headcrab == "No" || !src || QDELETED(src))
			return
		if(key)
			return
		transfer_personality(user.client)
	else
		var/be_headcrab = alert("Become a zombie? (Warning, You can no longer be cloned!)" ,,"Yes","No")
		if(be_headcrab == "No" || !src || QDELETED(src))
			return
		if(key)
			return
		transfer_personality(user.client)

/mob/living/simple_animal/hostile/headcrab/verb/build_a_nest()
	set category = "Headcrab"
	set name = "Build a nest"
	set desc = "Sacrifice yourself after a big time to build a nest."

	if(is_zombie)
		to_chat(src, "You cant use this, when zombie.")
		return

	var/turf/T = get_turf(src)
	for(var/obj/structure/spawner/headcrab in orange(60, T))
		to_chat(src, "There is a nest nearby, move more than 60 tiles away from it!")
		return

	if(building)
		return
	building = TRUE
	to_chat(src, "<span class='notice'>You start to falling apart...</span>")
	if(do_after(src, 500, target = src, progress=TRUE))
		for(var/obj/structure/spawner/headcrab in orange(60, T))
			to_chat(src, "There is a nest nearby, move more than 60 tiles away from it!")
			return
		var/obj/structure/spawner/headcrab/R = new /obj/structure/spawner/headcrab(src.loc)
		src.visible_message("<span class='notice'>[src] disintegrated, creating \a [R].\
			</span>", "<span class='notice'>You assemble \a [R].</span>")
		qdel(src)
	building = FALSE

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


/mob/living/simple_animal/hostile/headcrab/Life(seconds, times_fired)
	if(!is_zombie)
		revive_cooldown--

	vent_cooldown--

	if(..() && !stat)
		if(!is_zombie && isturf(src.loc))
			for(var/mob/living/carbon/human/H in oview(src, 2)) //Only for corpse right next to/on same tile
				if(H.stat == DEAD /*|| (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD)*/) //по неизвестной причине мартышки похоже до убирания этого условия не хотели зомбифицироваться
					Zombify(H)
					break
		if(times_fired % 4 == 0)
			for(var/mob/living/simple_animal/K in oview(src, 2)) //Only for corpse right next to/on same tile
				if(K.stat == DEAD || (!K.check_death_method() && K.health <= HEALTH_THRESHOLD_DEAD))
					visible_message("<span class='danger'>[src] consumes [K] whole!</span>")
					if(health < maxHealth)
						health += 10
					qdel(K)
					break

	if(src.ckey in GLOB.clients)
		return

	if(prob(1)) //it was a proc with a name its_time_to_kill_yourself

		var/turf/probably_nest = get_turf(src)

		for(var/obj/structure/spawner/headcrab in orange(60, probably_nest))
			return

		qdel(src)
		new /obj/structure/spawner/headcrab(src.loc)


	if(prob(15) && vent_cooldown <= 0)
		if(!is_zombie || is_zombie && host_species == "Monkey" || "Farwa" || "Neara" || "Stok" || "Wolpin")
			for(var/obj/machinery/atmospherics/unary/vent_pump/ventilation in view(16,src))
				if(!ventilation.welded)
					entry_vent = ventilation
					walk_to(src, entry_vent, 1)
					break

	if(travelling_in_vent)
		if(isturf(loc))
			travelling_in_vent = 0
			entry_vent = null
			vent_cooldown += 60

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
					var/area/new_area = get_area(loc)
					if(new_area)
						new_area.Entered(src)

/mob/living/simple_animal/hostile/headcrab/OpenFire(atom/A)
	if(check_friendly_fire && !is_zombie)
		for(var/turf/T in getline(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
	throw_at(A, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE)
	ranged_cooldown = world.time + ranged_cooldown_time
	vent_cooldown += 5

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	. = ..()

	vent_cooldown += 5

/mob/living/simple_animal/hostile/headcrab/New()

	..()

	add_language("Headcrab Hivemind")
	default_language = GLOB.all_languages["Headcrab Hivemind"]

	name += " ([rand(1, 1000)])"
	real_name = name

/mob/living/simple_animal/hostile/headcrab/proc/Zombify(mob/living/carbon/human/H)
	if(!H.check_death_method())
		H.death()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor.getRating("melee"))
			maxHealth += A.armor.getRating("melee") //That zombie's got armor, I want armor!
	maxHealth += 200
	health = maxHealth
	var/rank = H.get_assignment()
	if(rank == "Security Officer" || "Security Pod Pilot" || "Warden" || "Head Of Security") //аналог зомбайна
		name = "zomcur" // Хм-мм. Щиткуры-зомби. щи...ку...зомкуры! Как тебе?.. Ха. Зомкуры. Дошло? Хе-хе. О...кей.
	else
		name = "zombie"
	desc = "A corpse animated by the alien being on its head."
	name += " ([rand(1, 1000)])"
	real_name = name
	melee_damage_lower = 20
	melee_damage_upper = 25
	H.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/hide_headcrab
	H.verbs -= /mob/living/simple_animal/hostile/headcrab/verb/build_a_nest
	ranged = 0
	dodging = 0
	if(host_species == "Monkey" || "Farwa" || "Neara" || "Stok" || "Wolpin")
		ventcrawler = 2
	else
		ventcrawler = 0
	stat_attack = CONSCIOUS // Disables their targeting of dead mobs once they're already a zombie
	icon = H.icon
	speak = list('sound/creatures/zombie_idle1.ogg','sound/creatures/zombie_idle2.ogg','sound/creatures/zombie_idle3.ogg')
	speak_chance = 50
	obj_damage += 40 //используя мышечную массу тела хедкраб бъет сильнее объекты
	speak_emote = list("groans")
	attacktext = "кромсает"
	attack_sound = 'sound/creatures/zombie_attack.ogg'
	icon_state = "zombie2_s"
	if(head_organ)
		head_organ.h_style = null
	H.update_hair()
	host_species = H.dna.species.name
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)

	visible_message("<span class='warning'>[H.name]'s body suddenly rises!")

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
			M.loc = get_turf(src)
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
	speed = 0.5
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
	melee_damage_lower = 8
	melee_damage_upper = 20
	attack_sound = list('sound/creatures/poison_headcrab_attack1.ogg', 'sound/creatures/poison_headcrab_attack2.ogg', 'sound/creatures/poison_headcrab_attack3.ogg')
	speak_emote = list("shrilly squeaks")
	var/neurotoxin_per_jump = 5
	var/poison_headcrabs = 0

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

	poison_headcrabs = 3
	desc += " It's [src.poison_headcrabs] [src.poison_headcrabs == 1 ? "headcrab" : "headcrabs" ] on it's back."

	melee_damage_lower = 25
	melee_damage_upper = 30

	to_chat(src, "There are [poison_headcrabs] on your back. Use ranged attack to throw them at enemies.")

	speed = 2.85
	ranged = 1
	maxHealth += 25
	health = maxHealth //как никак, танк
	obj_damage += 40 //ядовитый зомби выступает что-то вроде танка, поэтому и здоровья с уроном побольше.

/mob/living/simple_animal/hostile/headcrab/poison/Stat()
	..()

	if(!is_zombie)
		return

	statpanel("Status")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		stat("Headcrabs", poison_headcrabs)

/mob/living/simple_animal/hostile/headcrab/poison/AttackingTarget()
	. = ..()

	if(. && neurotoxin_per_jump > 0 && iscarbon(target) && target.reagents && !is_zombie)
		var/inject_target = pick("chest", "head")
		var/mob/living/carbon/victim = target
		if(victim.stunned || victim.can_inject(null, FALSE, inject_target, FALSE))
			if(victim.eye_blurry < 60)
				victim.AdjustEyeBlurry(10)
				visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
			victim.reagents.add_reagent("headcrabneurotoxin", neurotoxin_per_jump)

/mob/living/simple_animal/hostile/headcrab/poison/OpenFire(atom/target)
	. = ..()

	if(!src.ckey in GLOB.clients && prob(65)) //игрок кидаться может всегда, а ИИ лишь с шансом.
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
				to_chat(src, "No more headcrabs on your back, pal!")
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
	health = 125
	maxHealth = 125
	ranged_cooldown_time = 45
	speed = 1.1
	jumpdistance = 2
	jumpspeed = 0.5
	damage_coeff = list(BRUTE = 0.88, BURN = 0.88)

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
	melee_damage_lower = 4
	melee_damage_upper = 8
	jumpdistance = 6
	jumpspeed = 3
	speak_emote = list("buzzing like an electricity")
	damage_coeff = list(BURN = 0.95)
	revive_cooldown = 30

/mob/living/simple_animal/hostile/headcrab/reviver/AttackingTarget()
	. = ..()

	if(prob(50))
		do_sparks(1, 1, src)

	if(prob(95))
		var/mob/living/carbon/C = target
		C.adjustFireLoss(12)
	else
		target.reagents.add_reagent("teslium", 6)

	playsound(src.loc, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg'), 20, 1)

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

	H.shock_internal_organs(100)
	H.set_heartattack(FALSE) //уподобление оригиналу, что-то вроде оживления.
	src.revive_cooldown += 15

/mob/living/simple_animal/hostile/headcrab/reviver/Destroy()
	. = ..()

	var/turf/death_loc = get_turf(src)

	var/mob/living/simple_animal/hostile/headcrab/reviver/headcrab = new /mob/living/simple_animal/hostile/headcrab/reviver(death_loc) //уподобление оригиналу, этот вид хедкраба должен быть убит вне тела.

	headcrab.revive_cooldown += 30