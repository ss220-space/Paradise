/mob/living/simple_animal/hostile/mushroom
	name = "walking mushroom"
	desc = "It's a massive mushroom... with legs?"
	icon_state = "mushroom_color"
	icon_living = "mushroom_color"
	icon_dead = "mushroom_dead"
	speak_chance = 0
	turns_per_move = 1
	maxHealth = 10
	health = 10
	butcher_results = list(/obj/item/reagent_containers/food/snacks/hugemushroomslice = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "whacks"
	harm_intent_damage = 5
	obj_damage = 0
	melee_damage_lower = 1
	melee_damage_upper = 1
	attack_same = 2
	attacktext = "грызёт"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("mushroom")
	environment_smash = 0
	stat_attack = DEAD
	mouse_opacity = MOUSE_OPACITY_ICON
	speed = 1
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	robust_searching = 1
	speak_emote = list("squeaks")
	deathmessage = "fainted"
	var/powerlevel = 0 //Tracks our general strength level gained from eating other shrooms
	var/bruised = 0 //If someone tries to cheat the system by attacking a shroom to lower its health, punish them so that it wont award levels to shrooms that eat it
	var/recovery_cooldown = FALSE //So you can't repeatedly revive it during a fight
	var/faint_ticker = 0 //If we hit three, another mushroom's gonna eat us
	var/image/cap_living = null //Where we store our cap icons so we dont generate them constantly to update our icon
	var/image/cap_dead = null

/mob/living/simple_animal/hostile/mushroom/examine(mob/user)
	. = ..()
	if(health >= maxHealth)
		. += "<span class='notice'>It looks healthy.</span>"
	else
		. += "<span class='warning'>It looks like it's been roughed up.</span>"

/mob/living/simple_animal/hostile/mushroom/Life(seconds, times_fired)
	..()
	if(!stat)//Mushrooms slowly regenerate if conscious, for people who want to save them from being eaten
		adjustBruteLoss(-2)

/mob/living/simple_animal/hostile/mushroom/New()//Makes every shroom a little unique
	melee_damage_lower += rand(3, 5)
	melee_damage_upper += rand(10,20)
	maxHealth += rand(40,60)
	move_to_delay = rand(3,11)
	var/cap_color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	cap_living = image('icons/mob/animal.dmi',icon_state = "mushroom_cap")
	cap_dead = image('icons/mob/animal.dmi',icon_state = "mushroom_cap_dead")
	cap_living.color = cap_color
	cap_dead.color = cap_color
	UpdateMushroomCap()
	health = maxHealth
	..()

/mob/living/simple_animal/hostile/mushroom/CanAttack(atom/the_target) // Mushroom-specific version of CanAttack to handle stupid attack_same = 2 crap so we don't have to do it for literally every single simple_animal/hostile because this shit never gets spawned
	if(!the_target || isturf(the_target) || istype(the_target, /atom/movable/lighting_object))
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if (!faction_check_mob(L) && attack_same == 2)
			return FALSE
		if(L.stat > stat_attack)
			return FALSE

		return TRUE

	return FALSE


/mob/living/simple_animal/hostile/mushroom/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	//Possibility to flee from a fight just to make it more visually interesting
	if(. && amount > 0 && !retreat_distance && prob(33))
		retreat_distance = 5
		addtimer(VARSET_CALLBACK(src, retreat_distance, null), 3 SECONDS)


/mob/living/simple_animal/hostile/mushroom/attack_animal(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/mushroom) && stat == DEAD)
		var/mob/living/simple_animal/hostile/mushroom/M = L
		if(faint_ticker < 2)
			M.visible_message("[M] chews a bit on [src].")
			faint_ticker++
			return TRUE
		M.visible_message("<span class='warning'>[M] devours [src]!</span>")
		var/level_gain = (powerlevel - M.powerlevel)
		if(level_gain >= -1 && !bruised && !M.ckey)//Player shrooms can't level up to become robust gods.
			if(level_gain < 1)//So we still gain a level if two mushrooms were the same level
				level_gain = 1
			M.LevelUp(level_gain)
		M.adjustBruteLoss(-M.maxHealth)
		qdel(src)
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/mushroom/revive()
	..()
	icon_state = "mushroom_color"
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	UpdateMushroomCap()

/mob/living/simple_animal/hostile/mushroom/proc/UpdateMushroomCap()
	cut_overlays()

	if(health == 0)
		add_overlay(cap_dead)
	else
		add_overlay(cap_living)

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/simple_animal/hostile/mushroom/proc/Recover()
	visible_message(span_notice("[src] starts to slowly recover."))
	faint_ticker = 0
	revive()
	UpdateMushroomCap()
	recovery_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, recovery_cooldown, FALSE), 30 SECONDS)


/mob/living/simple_animal/hostile/mushroom/proc/LevelUp(var/level_gain)
	if(powerlevel <= 9)
		powerlevel += level_gain
		if(prob(25))
			melee_damage_lower += (level_gain * rand(1,5))
		else
			melee_damage_upper += (level_gain * rand(1,5))
		maxHealth += (level_gain * rand(1,5))
	adjustBruteLoss(-maxHealth) //They'll always heal, even if they don't gain a level, in case you want to keep this shroom around instead of harvesting it


/mob/living/simple_animal/hostile/mushroom/proc/Bruise()
	if(!bruised && !stat)
		visible_message(span_notice("The [name] was bruised!"))
		bruised = TRUE


/mob/living/simple_animal/hostile/mushroom/attackby(obj/item/I, mob/user, params)
	var/current_health
	if(user.a_intent == INTENT_HARM)
		current_health = health
		. = ..()
		if(!ATTACK_CHAIN_CANCEL_CHECK(.) && health < current_health)
			Bruise()
		return .

	if(istype(I, /obj/item/reagent_containers/food/snacks/grown/mushroom))
		if(stat != DEAD)
			to_chat(user, span_warning("The [name] should be dead to recover it."))
			return ATTACK_CHAIN_PROCEED
		if(recovery_cooldown)
			to_chat(user, span_warning("The [name] is still recovering. Wait a bit more."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		Recover()
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	current_health = health
	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.) && health < current_health)
		Bruise()


/mob/living/simple_animal/hostile/mushroom/attack_hand(mob/living/carbon/human/M as mob)
	..()
	if(M.a_intent == INTENT_HARM)
		Bruise()

/mob/living/simple_animal/hostile/mushroom/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	if(isitem(AM))
		var/obj/item/T = AM
		if(T.throwforce)
			Bruise()

/mob/living/simple_animal/hostile/mushroom/bullet_act()
	..()
	Bruise()

/mob/living/simple_animal/hostile/mushroom/harvest()
	var/counter
	for(counter=0, counter<=powerlevel, counter++)
		var/obj/item/reagent_containers/food/snacks/hugemushroomslice/S = new /obj/item/reagent_containers/food/snacks/hugemushroomslice(src.loc)
		S.reagents.add_reagent("psilocybin", powerlevel)
		S.reagents.add_reagent("omnizine", powerlevel)
		S.reagents.add_reagent("synaptizine", powerlevel)
	qdel(src)
