/*

LEGION

Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.

It has two attack modes that it constantly rotates between.

In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.

When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 2500
	maxHealth = 2500
	icon_state = "mega_legion"
	icon_living = "mega_legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	attacktext = "грызёт"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 40
	melee_damage_upper = 40
	wander = 0
	speed = 2
	ranged = 1
	del_on_death = 1
	retreat_distance = 5
	minimum_distance = 5
	pixel_x = -32
	base_pixel_x = -32
	pixel_y = -16
	base_pixel_y = -16
	maptext_height = 96
	maptext_width = 96
	ranged_cooldown_time = 20
	var/charging = FALSE
	var/firing_laser = FALSE
	internal_type = /obj/item/gps/internal/legion
	medal_type = BOSS_MEDAL_LEGION
	score_type = LEGION_SCORE
	loot = list(/obj/item/storm_staff)
	crusher_loot = list(/obj/item/storm_staff, /obj/item/crusher_trophy/empowered_legion_skull)
	enraged_loot = /obj/item/disk/fauna_research/legion
	vision_range = 13
	elimination = 1
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	mouse_opacity = MOUSE_OPACITY_ICON
	stat_attack = UNCONSCIOUS // Overriden from /tg/ - otherwise Legion starts chasing its minions


/mob/living/simple_animal/hostile/megafauna/legion/Initialize(mapload)
	. = ..()
	update_transform(2)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)


/mob/living/simple_animal/hostile/megafauna/legion/enrage()
	health = 1250
	maxHealth = 1250
	update_transform(0.66)
	loot = list(/datum/nothing)
	crusher_loot = list(/datum/nothing)
	var/mob/living/simple_animal/hostile/megafauna/legion/legiontwo = new(get_turf(src))
	legiontwo.update_transform(0.66)
	legiontwo.loot = list(/datum/nothing)
	legiontwo.crusher_loot = list(/datum/nothing)
	legiontwo.health = 1250
	legiontwo.maxHealth = 1250
	legiontwo.enraged = TRUE


/mob/living/simple_animal/hostile/megafauna/legion/unrage()
	. = ..()
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
		if(other != src)
			other.loot = list(/obj/item/storm_staff)
			other.crusher_loot = list(/obj/item/storm_staff, /obj/item/crusher_trophy/empowered_legion_skull)
			other.maxHealth = 2500
			other.health = 2500
	if(!QDELETED(src))
		qdel(src) //Suprise, it's the one on lavaland that regrows to full.


/mob/living/simple_animal/hostile/megafauna/legion/death(gibbed)
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
		if(other != src)
			other.loot = list(/obj/item/storm_staff)
			other.crusher_loot = list(/obj/item/storm_staff, /obj/item/crusher_trophy/empowered_legion_skull)
			return ..()
	UnlockBlastDoors("11119")
	return ..()


/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/L = target
		if(L.stat == UNCONSCIOUS)
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
			A.infest(L)

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(world.time >= ranged_cooldown && !charging)
		if(prob(30))
			visible_message("<span class='warning'><b>[src] charges!</b></span>")
			SpinAnimation(speed = 20, loops = 5)
			ranged = 0
			retreat_distance = 0
			minimum_distance = 0
			move_to_delay = 2
			set_varspeed(0)
			charging = 1
			ranged_cooldown = world.time + 3 SECONDS
			SLEEP_CHECK_DEATH(src, 3 SECONDS)
			set_ranged()
		else if(prob(60))
			firing_laser = TRUE
			var/beam_angle = get_angle(src, locate(target.x - 1, target.y, target.z)) // -1 to account for the legion sprite offset.
			var/turf/target_location = locate(x + (50 * sin(beam_angle)), y + (50 * cos(beam_angle)), z)
			var/beam_time = 0.25 SECONDS + ((health / maxHealth) SECONDS)
			playsound(loc, 'sound/effects/basscannon.ogg', 200, TRUE)
			Beam(target_location, icon_state = "death_laser", time = beam_time, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/disintegration_telegraph, beam_layer = ON_EDGED_TURF_LAYER)
			addtimer(CALLBACK(src, PROC_REF(fire_disintegration_laser), target_location), beam_time)
			ranged_cooldown = world.time + beam_time + 2 SECONDS
			SLEEP_CHECK_DEATH(src, beam_time + 2 SECONDS)
			firing_laser = FALSE
		else if(prob(40))
			var/mob/living/simple_animal/hostile/big_legion/A = new(loc)
			A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			visible_message("<span class='danger'>A monstrosity emerges from [src]</span>",
			"<span class='userdanger'>You summon a big [A]!</span>")
			ranged_cooldown = world.time + 5 SECONDS
		else
			var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/A
			if(enraged)
				A = new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/advanced/tendril(loc)
			else
				A = new /mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril(loc)
			if(!enraged || prob(33))
				A.GiveTarget(target)
			else
				for(var/mob/living/carbon/human/H in range(7, src))
					if(H.stat == DEAD)
						A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			visible_message("<span class='danger'>A [A] emerges from [src]!</span>",
			"<span class='userdanger'>You summon a [A]!</span>")
			ranged_cooldown = world.time + 2 SECONDS

/mob/living/simple_animal/hostile/megafauna/legion/MoveToTarget()
	if(firing_laser)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/legion/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(firing_laser)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/megafauna/legion/Goto(target, delay, minimum_distance)
	if(firing_laser)
		return
	..()

/mob/living/simple_animal/hostile/megafauna/legion/proc/set_ranged()
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	move_to_delay = 2
	charging = FALSE

/mob/living/simple_animal/hostile/megafauna/legion/proc/fire_disintegration_laser(location)
	playsound(loc, 'sound/weapons/marauder.ogg', 200, TRUE)
	Beam(location, icon_state = "death_laser", time = 2 SECONDS, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/reacting/disintegration, beam_layer = ON_EDGED_TURF_LAYER)
	for(var/turf/t as anything in get_line(src, location))
		if(ismineralturf(t))
			var/turf/simulated/mineral/M = t
			M.attempt_drill(src)
		if(iswallturf(t))
			var/turf/simulated/wall/W = t
			W.thermitemelt(time = 1 SECONDS)
		for(var/mob/living/M in t)
			if(faction_check(M.faction, faction, FALSE))
				continue
			if(M.stat == DEAD)
				visible_message("<span class='danger'>[M] is disintegrated by the beam!</span>")
				M.dust()
			else if(M != src)
				playsound(M,'sound/weapons/sear.ogg', 50, TRUE, -4)
				to_chat(M, "<span class='userdanger'>You're struck by a disintegration laser!</span>")
				var/limb_to_hit = M.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
				var/armor = M.run_armor_check(limb_to_hit, LASER)
				M.apply_damage(70 - ((health / maxHealth) * 20), BURN, limb_to_hit, armor)


/mob/living/simple_animal/hostile/megafauna/legion/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE


/mob/living/simple_animal/hostile/megafauna/legion/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()

	if(GLOB.necropolis_gate && !GLOB.necropolis_gate.legion_triggered)
		GLOB.necropolis_gate.toggle_the_gate(src, TRUE)

	if(!. || QDELETED(src))
		return .

	// we shrink sprite until scaling reaches value of 0.5, no megafauna midgets plz
	update_transform((0.5 + (health / maxHealth)) / current_size)

	if(amount > 0 && (enraged || prob(33)))
		var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A
		if(enraged)
			A = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/advanced(loc)
		else
			A = new /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion(loc)
		A.GiveTarget(target)
		A.friends = friends
		A.faction = faction


/obj/item/gps/internal/legion
	icon_state = null
	gpstag = "Mysterious Signal"
	desc = "The message repeats."
	invisibility = INVISIBILITY_ABSTRACT
