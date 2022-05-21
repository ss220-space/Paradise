#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "Отвратительная, пульсирующая масса плоти."
	speak_emote = list("булькает")
	emote_hear = list("булькает")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 2
	a_intent = INTENT_HARM
	gender = MALE
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = 2

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	minbodytemp = 0
	maxHealth = 150
	health = 150
	environment_smash = 1
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = 0
	attacktext = "обгладывает"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/morphed = 0
	var/atom/movable/form = null
	var/morph_time = 0

	var/list/examine_text_list

	var/playstyle_string = {"<b><font size=3 color='red'>Вы — морф.</font><br>Вы — мерзость, созданная в основном из генокрадских клеток. Вы можете принять форму чего угодно поблизости, кликнув по нему <kbd>Shift</kbd> + <kbd>ЛКМ</kbd>. Это можно делать не чаще одного раза в 5 секунд. При этом те, кто вас видит, заметят этот процесс.<br>Будучи превращённым, вы двигаетесь быстрее, но наносите меньше урона. Кроме того, любой в пределах трёх плиток от вас заметит странную неправильность, если осмотрит вас. Вы можете восстановить свою первоначальную форму во время трансформирования, кликнув по себе <kbd>Shift</kbd> + <kbd>ЛКМ</kbd>.<br>Кроме этого, вы можете атаковать любой предмет или мёртвое существо, чтобы поглотить его. Поглощённое существо восстановят ⅓ вашего максимального здоровья.</b>"}

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	real_name = "magical morph"
	desc = "Отвратительная, пульсирующая масса плоти. Выглядит как-то очень… по-магически."

/mob/living/simple_animal/hostile/morph/wizard/New()
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/smoke)
	AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall)

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = examine_text_list.Copy()
		if(get_dist(user, src) <= 3)
			. += "<span class='warning'>Во внешнем виде вы замечаете что-то очень неправильное…</span>"
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	if(istype(A,/obj/screen))
		return 0
	if(istype(A,/obj/singularity))
		return 0
	if(istype(A,/mob/living/simple_animal/hostile/morph))
		return 0
	return 1

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] поглощает [A] целиком!</span>")
		A.forceMove(src)
		return 1
	return 0

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed(A))
			assume(A)
	else
		to_chat(src, "<span class='warning'>Ваша маскировочная кожа всё ещё восстанавливается!</span>")
		..()

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	morphed = 1
	form = target
	visible_message("<span class='warning'>[src] резко начинает искривляться и менять форму, становясь копией [target]!</span>", \
					"<span class='notice'>Вы перекручиваете своё тело и принимаете форму [target].</span>")

	appearance = target.appearance
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	//Morphed is weaker
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = 0
	examine_text_list = form.examine(src)
	morph_time = world.time + MORPH_COOLDOWN
	return

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = 0
	form = null
	examine_text_list = null // Free that memory
	visible_message("<span class='warning'>[src] резко проваливается сам в себя, расползаясь массой зелёной плоти!</span>", \
					"<span class='notice'>Вы возвращаетесь в своё нормальное тело.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	overlays.Cut()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)

	morph_time = world.time + MORPH_COOLDOWN

/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	if(stat == DEAD && gibbed)
		for(var/atom/movable/AM in src)
			AM.forceMove(loc)
			if(prob(90))
				step(AM, pick(GLOB.alldirs))
	// Only execute the below if we successfully died
	if(!.)
		return FALSE
	if(morphed)
		visible_message("<span class='warning'>[src] искривляется и расползается массой зелёной плоти!</span>", \
						"<span class='userdanger'>Ваша кожа рвётся! Ваша плоть распадается! Никакая маскировка не сможет защитить ва…</span>")
		restore()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(var/list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/movable/A in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
	else if(istype(target,/obj/item)) // Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src, 20, target = I))
				eat(I)
			return
	return ..()
