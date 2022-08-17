/mob/living/simple_animal/hostile/cruiser
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead" // Does not actually exist. del_on_death.
	icon_gib = "syndicate_gib" // Does not actually exist. del_on_death.
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 300
	health = 300
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "бьёт"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	check_friendly_fire = 1
	status_flags = CANPUSH
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier)
	del_on_death = 1
	sentience_type = SENTIENCE_OTHER

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/cruiser/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	attacktext = "рубит"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 28
	status_flags = 0
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier, /obj/item/melee/energy/sword/saber/red, /obj/item/shield/energy)
	var/melee_block_chance = 20
	var/ranged_block_chance = 35

/mob/living/simple_animal/hostile/cruiser/melee/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(O.force)
		if(prob(melee_block_chance))
			visible_message("<span class='boldwarning'>[src] blocks the [O] with its shield! </span>")
		else
			var/damage = O.force
			if(O.damtype == STAMINA)
				damage = 0
			if(force_threshold && damage < force_threshold)
				visible_message("<span class='boldwarning'>[src] is unharmed by [O]!</span>")
				return
			adjustHealth(damage)
			visible_message("<span class='boldwarning'>[src] has been attacked with the [O] by [user]. </span>")
		playsound(loc, O.hitsound, 25, 1, -1)
	else
		to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
		visible_message("<span class='warning'>[user] gently taps [src] with the [O]. </span>")


/mob/living/simple_animal/hostile/cruiser/melee/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	if(prob(ranged_block_chance))
		visible_message("<span class='danger'>[src] blocks [Proj] with its shield!</span>")
	else
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			adjustHealth(Proj.damage)
	return 0

/mob/living/simple_animal/hostile/cruiser/melee/space
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	speed = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatecommando, /obj/item/melee/energy/sword/saber/red, /obj/item/shield/energy)

/mob/living/simple_animal/hostile/cruiser/melee/space/Process_Spacemove(var/movement_dir = 0)
	return TRUE


/mob/living/simple_animal/hostile/cruiser/ranged
	ranged = 1
	rapid = 2
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	projectilesound = 'sound/weapons/gunshots/gunshot.ogg'
	casingtype = /obj/item/ammo_casing/c45
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatesoldier, /obj/item/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/cruiser/ranged/space
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/syndicatecommando, /obj/item/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/cruiser/ranged/space/Process_Spacemove(var/movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/cruiser/ranged/space/autogib
	loot = list()//gonna gibe, no loot.

