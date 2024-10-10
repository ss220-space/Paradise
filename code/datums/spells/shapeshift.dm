/obj/effect/proc_holder/spell/shapeshift
	name = "Shapechange"
	desc = "Примите на время облик другого существа, чтобы использовать его способности. Выбирайте мудро, так как изменить выбор нельзя."
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 20 SECONDS
	cooldown_min = 5 SECONDS
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"

	var/shapeshift_type
	var/list/current_shapes = list()
	var/list/current_casters = list()
	var/list/possible_shapes = list(/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/construct/armoured)


/obj/effect/proc_holder/spell/shapeshift/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shapeshift/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.IsWeakened() || user.IsStunned())
		return FALSE

	if(!isturf(user.loc) && !length(current_casters)) //Can't use inside of things, such as a mecha
		return FALSE

	return ..()


/obj/effect/proc_holder/spell/shapeshift/cast(list/targets, mob/user = usr)
	for(var/mob/living/M in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			for(var/path in possible_shapes)
				var/mob/living/simple_animal/A = path
				animal_list[initial(A.name)] = path
			shapeshift_type = tgui_input_list(M, "Выберите свою животную форму!", "Пришло время превращения!", animal_list)
			if(!shapeshift_type) //If you aren't gonna decide I am!
				shapeshift_type = pick(animal_list)
			shapeshift_type = animal_list[shapeshift_type]
		if(M in current_shapes)
			Restore(M)
		else
			Shapeshift(M)


/obj/effect/proc_holder/spell/shapeshift/proc/Shapeshift(mob/living/caster)
	for(var/mob/living/mob in caster)
		if(HAS_TRAIT_FROM(mob, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src)))
			to_chat(caster, span_warning("Вы уже перевоплотились!"))
			return

	var/mob/living/shape = new shapeshift_type(get_turf(caster))
	caster.forceMove(shape)
	ADD_TRAIT(caster, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	current_shapes |= shape
	current_casters |= caster
	clothes_req = FALSE
	human_req = FALSE

	caster.mind.transfer_to(shape)


/obj/effect/proc_holder/spell/shapeshift/proc/Restore(mob/living/shape)
	var/mob/living/caster
	for(var/mob/living/M in shape)
		if(M in current_casters)
			caster = M
			break
	if(!caster)
		return
	caster.forceMove(get_turf(shape))
	REMOVE_TRAIT(caster, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)
	current_casters.Remove(caster)
	current_shapes.Remove(shape)

	shape.mind.transfer_to(caster)
	qdel(shape) //Gib it maybe ?


/obj/effect/proc_holder/spell/shapeshift/dragon
	name = "Dragon Form"
	desc = "После небольшой задержки примите форму пепельного дракона."
	invocation = "*scream"

	shapeshift_type = /mob/living/simple_animal/hostile/megafauna/dragon/lesser
	current_shapes = list(/mob/living/simple_animal/hostile/megafauna/dragon/lesser)
	current_casters = list()
	possible_shapes = list(/mob/living/simple_animal/hostile/megafauna/dragon/lesser)


/obj/effect/proc_holder/spell/shapeshift/dragon/Shapeshift(mob/living/caster)
	caster.visible_message("<span class='danger'>[caster] кричит в агонии из-за костей и когтей, вырывающихся из плоти!</span>",
		"<span class='danger'>Вы начинаете трансформацию.</span>")
	if(!do_after(caster, 5 SECONDS, caster, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		to_chat(caster, "<span class='warning'>Вы теряете концентрацию на заклинании!</span>")
		return
	return ..()


/obj/effect/proc_holder/spell/shapeshift/bats
	name = "Bat Form"
	desc = "Примите форму стаи летучих мышей."
	invocation = "none"
	invocation_type = "none"
	action_icon_state = "vampire_bats"
	gain_desc = "Вы получили способность превращаться в летучую мышь. Это слабая форма, не имеющая способностей, полезная только для скрытности."

	shapeshift_type = /mob/living/simple_animal/hostile/scarybat/batswarm
	current_shapes = list(/mob/living/simple_animal/hostile/scarybat/batswarm)
	current_casters = list()
	possible_shapes = list(/mob/living/simple_animal/hostile/scarybat/batswarm)


/obj/effect/proc_holder/spell/shapeshift/hellhound
	name = "Lesser Hellhound Form"
	desc = "Примите форму Адской гончей."
	invocation = "none"
	invocation_type = "none"
	action_background_icon_state = "bg_demon"
	action_icon_state = "glare"
	gain_desc = "Вы получили возможность превращаться в меньшую адскую гончую. Это боевая форма с различными способностями, выносливая, но не неуязвимая. Она имеет медленную регенерацию."

	shapeshift_type = /mob/living/simple_animal/hostile/hellhound
	current_shapes = list(/mob/living/simple_animal/hostile/hellhound)
	current_casters = list()
	possible_shapes = list(/mob/living/simple_animal/hostile/hellhound)


/obj/effect/proc_holder/spell/shapeshift/hellhound/greater
	name = "Greater Hellhound Form"
	shapeshift_type = /mob/living/simple_animal/hostile/hellhound/greater
	current_shapes = list(/mob/living/simple_animal/hostile/hellhound/greater)
	current_casters = list()
	possible_shapes = list(/mob/living/simple_animal/hostile/hellhound/greater)

