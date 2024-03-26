/mob/living/simple_animal/hostile/asteroid/marrowweaver
	name = "marrow weaver"
	desc = "A big, angry, venomous spider. It likes to snack on bone marrow. Its preferred food source is you."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "weaver"
	icon_living = "weaver"
	icon_aggro = "weaver"
	icon_dead = "weaver_dead"
	throw_message = "bounces harmlessly off the"
	butcher_results = list(/obj/item/stack/ore/uranium = 2, /obj/item/stack/sheet/bone = 2, /obj/item/stack/sheet/sinew = 1, /obj/item/stack/sheet/animalhide/weaver_chitin = 3, /obj/item/reagent_containers/food/snacks/monstermeat/spiderleg = 2)
	loot = list()
	attacktext = "кусает" //can we revert all translation in our code?
	gold_core_spawnable = HOSTILE_SPAWN
	health = 220
	maxHealth = 220
	vision_range = 8
	move_to_delay = 16
	speed = 3
	melee_damage_lower = 13
	melee_damage_upper = 16
	stat_attack = 1
	robust_searching = 1
	nightvision = 7
	ventcrawler = 2
	pass_flags = PASSTABLE
	attack_sound = 'sound/weapons/bite.ogg'
	deathmessage = "rolls over, frothing at the mouth before stilling."
	var/poison_type = "spore"
	var/poison_per_bite = 5
	var/buttmad = 0
	var/melee_damage_lower_angery0 = 13
	var/melee_damage_upper_angery0 = 16
	var/melee_damage_lower_angery1 = 15
	var/melee_damage_upper_angery1 = 20
	var/anger_move_to_delay = 8
	var/anger_speed = 4
	needs_gliding = FALSE

/mob/living/simple_animal/hostile/asteroid/marrowweaver/adjustHealth(amount, updating_health = TRUE)
	if(buttmad == 0)
		if(health < maxHealth/3)
			buttmad = 1
			visible_message(span_danger("[src] chitters in rage, baring its fangs!"))
			melee_damage_lower = melee_damage_lower_angery1
			melee_damage_upper = melee_damage_upper_angery1
			move_to_delay = anger_move_to_delay
			speed = anger_speed
			poison_type = "venom"
			poison_per_bite = 6
			needs_gliding = TRUE
	else if(buttmad == 1)
		if(health > maxHealth/2)
			buttmad = 0
			visible_message(span_notice("[src] seems to have calmed down, but not by much."))
			melee_damage_lower = melee_damage_lower_angery0
			melee_damage_upper = melee_damage_upper_angery0
			poison_type = initial(poison_type)
			speed = initial(speed)
			poison_per_bite = initial(poison_per_bite)
			needs_gliding = FALSE
	..()

/mob/living/simple_animal/hostile/asteroid/marrowweaver/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(target.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		if((L.stat == DEAD) && (health < maxHealth) && ishuman(L))
			if(fiesta(L, FALSE))
				var/mob/living/carbon/human/H = L
				var/turf/T = get_turf(H)
				H.add_splatter_floor(T)	//Visual proc from disembowel(), just for exclude organ dropping (brains), but stay cool.
				playsound(T, 'sound/effects/splat.ogg', 25, 1)	//Sound proc for the same reason.
				src.visible_message(
					span_danger("[src] drools some toxic goo into [L]'s innards..."),
					span_danger("Before sucking out the slurry of bone marrow and flesh, healing itself!"),
					"<span class-'userdanger>You liquefy [L]'s innards with your venom and suck out the resulting slurry, revitalizing yourself.</span>")
				adjustBruteLoss(round(-H.maxHealth/2))
			else
				to_chat(src, span_warning("There are no organs left in this corpse."))

/mob/living/simple_animal/hostile/asteroid/marrowweaver/CanAttack(atom/A)
	if(..())
		return TRUE
	if((health < maxHealth) && ishuman(A) && !faction_check_mob(A))
		if(fiesta(A))
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/asteroid/marrowweaver/proc/fiesta(var/mob/living/carbon/human/snack, preparing = TRUE)
	var/foundorgans = 0
	var/list/organs = snack.get_organs_zone(BODY_ZONE_CHEST)
	for(var/obj/item/organ/internal/I as anything in organs)
		if(!istype(I, /obj/item/organ/internal/brain))
			foundorgans ++
			if(!preparing)
				qdel(I)
	if(foundorgans)
		return TRUE
	return FALSE

/obj/item/stack/sheet/animalhide/weaver_chitin
	name = "weaver chitin"
	desc = "A chunk of hardened and layered chitin from a marrow weaver's carapace."
	icon = 'icons/obj/mining.dmi'
	icon_state = "chitin"
	singular_name = "chitin chunk"

//better and dangerous subtype for regular lavaland. Slightly faster and NO MORE XRAY.

/mob/living/simple_animal/hostile/asteroid/marrowweaver/dangerous
	health = 320
	maxHealth = 320
	vision_range = 8
	nightvision = 8
	speed = 5
	move_to_delay = 14
	anger_move_to_delay = 6
	anger_speed = 6

/mob/living/simple_animal/hostile/asteroid/marrowweaver/dangerous/random/Initialize(mapload)
	. = ..()
	if(prob(15))
		new /mob/living/simple_animal/hostile/asteroid/marrowweaver/frost(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/marrowweaver/frost
	name = "frostbite weaver"
	desc = "A big, angry, venomous ice spider. It likes to snack on bone marrow. Its preferred food source is you."
	icon_state = "weaver_ice"
	icon_living = "weaver_ice"
	icon_aggro = "weaver_ice"
	icon_dead = "weaver_ice_dead"
	melee_damage_lower = 10 //stronger venom, but weaker attack.
	melee_damage_upper = 13
	poison_type = "frostoil"
	poison_per_bite = 5

/mob/living/simple_animal/hostile/asteroid/marrowweaver/tendril
	fromtendril = TRUE

/mob/living/simple_animal/hostile/asteroid/marrowweaver/frost/tendril
	fromtendril = TRUE
