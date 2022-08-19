/datum/action/changeling/spiders
	name = "Spread Infestation"
	desc = "Our form divides, creating arachnids which will grow into deadly beasts."
	helptext = "The spiders are thoughtless creatures, and may attack their creators when fully grown. Requires at least 5 stored DNA."
	button_icon_state = "spread_infestation"
	chemical_cost = 45
	dna_cost = 1
	req_dna = 5

	//testing stuff, then change 5 - 45 and delete comment on dna

//Makes some spiderlings. Good for setting traps and causing general trouble.
/datum/action/changeling/spiders/sting_action(var/mob/user)
	for(var/i=0, i<2, i++)
		var/obj/structure/spider/spiderling/S = new(user.loc)
		S.grow_as = /mob/living/simple_animal/hostile/poison/changelingspider
		S.amount_grown = 97 //идеально для создания ловушек и проблем, отвлечь СБ, пока обыскивают, еще цену опрадывает.

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return 1

//копирование кода паука было сделано, потому что при спавне из обычных спайдерлингов был бы шанс спавна такого паука, а мы этого не хоим

#define SPINNING_WEB 1
#define LAYING_EGGS 2 //выпилить дефы, если будут претензии к херне ниже вкалывания яда
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//CHANGELING SPIDER
/mob/living/simple_animal/hostile/poison/changelingspider
	name = "strange giant spider"
	desc = "Giant and purple, it makes you shudder to look at it. This one has deep purple eyes."
	icon_state = "changelingspider"
	icon_living = "changelingspider"
	icon_dead = "changelingspiderdead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	emote_see = list("chitters")
	speak_chance = 1
	turns_per_move = 7
	see_in_dark = 15
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 145
	health = 145
	obj_damage = 100
	melee_damage_lower = 15
	melee_damage_upper = 15
	heat_damage_per_tick = 20	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	cold_damage_per_tick = 20	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	faction = list("spiders")
	move_to_delay = 4
	attacktext = "срывает плоть с"
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = NO_SPAWN
	var/venom_per_bite = 5
	var/busy = 0
	var/atom/cocoon_target
	var/fed = 0

/mob/living/simple_animal/hostile/poison/changelingspider/AttackingTarget()
	// This is placed here, NOT on /poison, because the other subtypes of /poison/ already override AttackingTarget() completely, and as such it would do nothing but confuse people there.
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, FALSE, inject_target, FALSE))
			C.reagents.add_reagent("spidertoxin", venom_per_bite)

//выпилить все что ниже, если будут претензии

/mob/living/simple_animal/hostile/poison/changelingspider/get_spacemove_backup()
	. = ..()
	// If we don't find any normal thing to use, attempt to use any nearby spider structure instead.
	if(!.)
		for(var/obj/structure/spider/S in range(1, get_turf(src)))
			return S

/mob/living/simple_animal/hostile/poison/changelingspider/handle_automated_movement() //Hacky and ugly.
	. = ..()
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(!busy && prob(1))
			stop_automated_movement = 1
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = 0
				walk(src,0)
		return 1

/mob/living/simple_animal/hostile/poison/changelingspider/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/changelingspider/handle_automated_movement() //Hacky and ugly.
	if(..())
		var/list/can_see = view(src, 10)
		if(!busy && prob(30))	//30% chance to stop wandering and do something
			//first, check for potential food nearby to cocoon
			for(var/mob/living/C in can_see)
				if(C.stat && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored) //да, знаю что требуется замена, но как-то поебать, они скорее будут сдыхать
					cocoon_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					//give up if we can't reach them after 10 seconds
					GiveUp(C)
					return
			//second, spin a sticky spiderweb on this tile
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				Web()
			else
				//third, lay an egg cluster there
				if(fed)
					LayEggs()
				else
					//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
					for(var/obj/O in can_see)
						if(O.anchored)
							continue

						if(isitem(O) || isstructure(O) || ismachinery(O))
							cocoon_target = O
							busy = MOVING_TO_TARGET
							stop_automated_movement = 1
							Goto(O, move_to_delay)
							//give up if we can't reach them after 10 seconds
							GiveUp(O)

		else if(busy == MOVING_TO_TARGET && cocoon_target)
			if(get_dist(src, cocoon_target) <= 1)
				Wrap()

	else
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/changelingspider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spread a sticky web to slow down prey."

	var/T = src.loc

	if(busy != SPINNING_WEB)
		busy = SPINNING_WEB
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
		stop_automated_movement = 1
		spawn(40)
			if(busy == SPINNING_WEB && src.loc == T)
				new /obj/structure/spider/stickyweb(T)
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/changelingspider/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."

	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1, src))
			if(L == src)
				continue
			if(L.stat != DEAD)
				continue
			if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in get_turf(src))
			if(O.anchored)
				continue
			if(!(isitem(O) || isstructure(O) || ismachinery(O)))
				continue
			if(Adjacent(O))
				choices += O
		if(length(choices))
			cocoon_target = input(src,"What do you wish to cocoon?") in null|choices
		else
			to_chat(src, "<span class='warning'>No suitable dead prey or wrappable objects found nearby.")
			return

	if(cocoon_target && busy != SPINNING_COCOON)
		busy = SPINNING_COCOON
		src.visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance around \the [cocoon_target].</span>")
		stop_automated_movement = 1
		walk(src,0)
		spawn(50)
			if(busy == SPINNING_COCOON)
				if(cocoon_target && istype(cocoon_target.loc, /turf) && get_dist(src,cocoon_target) <= 1)
					var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
					var/large_cocoon = 0
					C.pixel_x = cocoon_target.pixel_x
					C.pixel_y = cocoon_target.pixel_y
					for(var/obj/item/I in C.loc)
						I.loc = C
					for(var/obj/structure/S in C.loc)
						if(!S.anchored)
							S.loc = C
							large_cocoon = 1
					for(var/obj/machinery/M in C.loc)
						if(!M.anchored)
							M.loc = C
							large_cocoon = 1
					for(var/mob/living/L in C.loc)
						if(istype(L, /mob/living/simple_animal/hostile/poison/giant_spider))
							continue
						if(L.stat != DEAD)
							continue
						large_cocoon = 1
						L.loc = C
						C.pixel_x = L.pixel_x
						C.pixel_y = L.pixel_y
						fed++
						visible_message("<span class='danger'>\the [src] sticks a proboscis into \the [L] and sucks a viscous substance out.</span>")

						break
					if(large_cocoon)
						C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
			cocoon_target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/poison/changelingspider/verb/LayEggs()
	set name = "Lay Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs, but you must wrap a creature for feeding first."

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		src.visible_message("<span class='notice'>\the [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(src.loc)
					C.changeling = TRUE
					C.amount_grown = 70 //возможно придеться выпилить размножение
					C.faction = faction.Copy()
					fed--
			busy = 0
			stop_automated_movement = 0

#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
