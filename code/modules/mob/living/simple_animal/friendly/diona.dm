/*
	Tiny babby plant critter plus procs.
*/

//Mob defines.
/mob/living/simple_animal/diona
	name = "diona nymph"
	icon = 'icons/mob/monkey.dmi'
	icon_state = "nymph"
	icon_living = "nymph"
	icon_dead = "nymph_dead"
	icon_resting = "nymph_sleep"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 50
	health = 50
	voice_name = "нимфа дионы"
	speak_emote = list("щебечет", "стрекочет")
	emote_hear = list("щебечет", "стрекочет")
	emote_see = list("щебечет", "стрекочет")
	tts_seed = "Priest"

	response_help  = "гладит"
	response_disarm = "толкает"
	response_harm   = "бьёт"

	melee_damage_lower = 1
	melee_damage_upper = 1
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'

	speed = 0
	stop_automated_movement = 0
	turns_per_move = 4

	var/list/donors = list()
	holder_type = /obj/item/holder/diona
	can_collar = TRUE

	a_intent = INTENT_HELP

	var/random_name = TRUE
	var/gestalt_alert = "слился с гештальтом" //used in adding and clearing alert
	var/evolve_donors = 5 //amount of blood donors needed before evolving
	var/awareness_donors = 3 //amount of blood donors needed for understand language
	var/nutrition_need = 500 //amount of nutrition needed before evolving

	var/datum/action/innate/diona/merge/merge_action = new()
	var/datum/action/innate/diona/evolve/evolve_action = new()
	var/datum/action/innate/diona/steal_blood/steal_blood_action = new()

/mob/living/simple_animal/diona/get_ru_names()
	return list(
		NOMINATIVE = "нимфа дионы",
		GENITIVE = "нимфы дионы",
		DATIVE = "нимфе дионы",
		ACCUSATIVE = "нимфу дионы",
		INSTRUMENTAL = "нимфой дионы",
		PREPOSITIONAL = "нимфе дионы"
	)

/mob/living/simple_animal/diona/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/datum/action/innate/diona/merge
	name = "Слияние с гештальтом"
	icon_icon = 'icons/mob/human_races/r_diona.dmi'
	button_icon_state = "preview"

/datum/action/innate/diona/merge/Activate()
	var/mob/living/simple_animal/diona/user = owner
	user.merge()

/datum/action/innate/diona/evolve
	name = "Эволюция"
	icon_icon = 'icons/obj/machines/cloning.dmi'
	button_icon_state = "pod_cloning"

/datum/action/innate/diona/evolve/Activate()
	var/mob/living/simple_animal/diona/user = owner
	user.evolve()

/datum/action/innate/diona/steal_blood
	name = "Кража крови"
	icon_icon = 'icons/goonstation/objects/iv.dmi'
	button_icon_state = "bloodbag"

/datum/action/innate/diona/steal_blood/Activate()
	var/mob/living/simple_animal/diona/user = owner
	user.steal_blood()

/mob/living/simple_animal/diona/New()
	..()
	if(name == initial(name)) //To stop Pun-Pun becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	add_language(LANGUAGE_DIONA)
	merge_action.Grant(src)
	evolve_action.Grant(src)
	steal_blood_action.Grant(src)

/mob/living/simple_animal/diona/OnUnarmedAttack(atom/A)
	if(isdiona(A) && (src in A.contents)) //can't attack your gestalt
		visible_message("[capitalize(src.declent_ru(NOMINATIVE))] слегка шевелится.")
	else
		..()

/mob/living/simple_animal/diona/run_resist()
	..()
	split()

/mob/living/simple_animal/diona/attack_hand(mob/living/carbon/human/M)
	//Let people pick the little buggers up.
	if(M.a_intent == INTENT_HELP)
		if(isdiona(M))
			gestalt_heal(M)
		else
			get_scooped(M)
	else
		..()
/mob/living/simple_animal/diona/MouseDrop(mob/living/carbon/human/user, src_location, over_location, src_control, over_control, params)
	if(isdiona(user)) // diona with NO HANDS?? Now it's not trouble.
		gestalt_heal(user)
		return FALSE
	return ..()

/mob/living/simple_animal/diona/proc/gestalt_heal(mob/living/carbon/human/M)
	if(!Adjacent(M))
		return FALSE
	forceMove(M)
	if(stat != CONSCIOUS)
		qdel(src)
		to_chat(M, span_notice("Тело нимфы сливается с вашим гештальтом."))
		return TRUE // TRUE if nymph was deleted, FALSE - if not. Maybe I need this later..

	if(ckey)
		to_chat(src, span_notice("Ваше сознание соединяется с [M], когда вы сливаетесь с гештальтом."))
		to_chat(M, span_notice("Ваше сознание соединяется с нимфой, когда она сливается с гештальтом."))
		throw_alert(gestalt_alert, /atom/movable/screen/alert/nymph, new_master = src) //adds a screen alert that can call resist
		return FALSE

	to_chat(M, span_notice("Вы начинаете принимать нимфу в свой гештальт."))

	if(!ckey && do_after(M, 5 SECONDS, M, ALL))
		var/list/stock_limbs = /datum/species/diona::has_limbs
		for(var/limb_zone in stock_limbs)
			if(!M.bodyparts_by_name[limb_zone])
				var/list/organ_data = stock_limbs[limb_zone]
				var/limb_path = organ_data["path"]
				var/obj/item/organ/new_organ = new limb_path(M)
				organ_data["descriptor"] = new_organ.name
				to_chat(M, span_notice("Нимфа занимает пустующее место в гештальте в качестве конечности."))
				M.recalculate_limbs_status()
				M.regenerate_icons()
				qdel(src)
				return TRUE

		var/list/stock_organs = /datum/species/diona::has_organ
		for(var/organ_slot in stock_organs)
			if(!M.internal_organs_slot[organ_slot])
				var/organ_path = stock_organs[organ_slot]
				new organ_path(M)
				to_chat(M, span_notice("Нимфа занимает пустующее место в гештальте в качестве органа."))
				qdel(src)
				return TRUE

		to_chat(M, span_notice("Ваше сознание соединяется с нимфой, когда она сливается с гештальтом."))
	return FALSE

/mob/living/simple_animal/diona/proc/merge()
	if(stat != CONSCIOUS)
		return FALSE

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in view(1,src))
		if(!(Adjacent(H)) || !isdiona(H))
			continue
		choices += H

	if(!choices.len)
		balloon_alert(src, "нет подходящей дионы!")
		return FALSE

	var/mob/living/M = tgui_input_list(src, "С кем вы хотите слиться?", , choices)

	if(!M || !src || !(Adjacent(M)) || stat != CONSCIOUS) //input can take a while, so re-validate
		return FALSE

	if(isdiona(M))
		to_chat(M, "Вы чувствуете, как ваша сущность переплетается с [src], когда он сливается с вашей биомассой.")
		M.status_flags |= PASSEMOTES
		to_chat(src, "Вы чувствуете, как ваша сущность переплетается с [M], сливаясь с его биомассой.")
		forceMove(M)
		throw_alert(gestalt_alert, /atom/movable/screen/alert/nymph, new_master = src) //adds a screen alert that can call resist
		return TRUE
	else
		return FALSE

/mob/living/simple_animal/diona/proc/split()
	if((stat != CONSCIOUS) || !isdiona(loc))
		return FALSE
	var/mob/living/carbon/human/D = loc
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	to_chat(loc, "Вы чувствуете острую потерю, когда [src.declent_ru(NOMINATIVE)] отделяется от вашей биомассы.")
	to_chat(src, "Вы выныриваете из глубин биомассы [loc] и с лёгким шлепком падаете на землю.")
	forceMove(T)

	var/hasMobs = FALSE
	for(var/atom/A in D.contents)
		if(istype(A, /mob/) || istype(A, /obj/item/holder))
			hasMobs = TRUE
	if(!hasMobs)
		D.status_flags &= ~PASSEMOTES

	clear_alert(gestalt_alert)
	return TRUE

/mob/living/simple_animal/diona/proc/evolve()
	if(stat != CONSCIOUS)
		return FALSE

	if(donors.len < evolve_donors)
		balloon_alert(src, "нужно больше крови!")
		return FALSE

	if(nutrition < nutrition_need)
		balloon_alert(src, "нужно больше сорняков!")
		return FALSE

	if(isdiona(loc) && !split()) //if it's merged with diona, needs to able to split before evolving
		return FALSE

	visible_message(span_danger("[capitalize(src.declent_ru(NOMINATIVE))] начинает дрожать и разрывается, порождая новые побеги дионеи."), span_danger("Ваше сознание разделяется. Мы поглощаем питательные вещества и разрастаемся в гештальт-форму."))

	var/mob/living/carbon/human/diona/adult = new(get_turf(loc))
	adult.set_species(/datum/species/diona)

	if(istype(loc, /obj/item/holder/diona))
		var/obj/item/holder/diona/L = loc
		forceMove(L.loc)
		qdel(L)

	for(var/datum/language/L in languages)
		adult.add_language(L.name)
	adult.regenerate_icons()

	if(random_name)
		adult.name = "diona ([rand(100,999)])"
		adult.real_name = adult.name
		adult.real_name = adult.dna.species.get_random_name()
		//I hate this being here of all places but unfortunately dna is based on real_name!
	else
		adult.name = name
		adult.real_name = real_name

	mind.transfer_to(adult)

	for(var/obj/item/W in contents)
		drop_item_ground(W)

	qdel(src)
	return TRUE

// Consumes plant matter other than weeds to evolve
/mob/living/simple_animal/diona/proc/consume(obj/item/reagent_containers/food/snacks/grown/G)
	if(nutrition >= nutrition_need) // Prevents griefing by overeating plant items without evolving.
		to_chat(src, span_warning("Вы полностью сыты! Может, пора подрасти?"))
	else
		if(do_after(src, 2 SECONDS, G, max_interact_count = 1))
			visible_message("[capitalize(src.declent_ru(NOMINATIVE))] жадно поглощает [G.declent_ru(ACCUSATIVE)].","Вы жадно пожираете [G.declent_ru(ACCUSATIVE)].")
			playsound(loc, 'sound/items/eatfood.ogg', 30, FALSE, frequency = 1.5)
			if(G.reagents.get_reagent_amount("nutriment") + G.reagents.get_reagent_amount("plantmatter") < 1)
				adjust_nutrition(2)
			else
				adjust_nutrition((G.reagents.get_reagent_amount("nutriment") + G.reagents.get_reagent_amount("plantmatter")) * 2)
			qdel(G)

/mob/living/simple_animal/diona/proc/steal_blood()
	if(stat != CONSCIOUS)
		return FALSE

	var/list/choices = list()
	for(var/mob/living/carbon/human/H in oview(1,src))
		if(Adjacent(H) && !HAS_TRAIT(H, TRAIT_NO_BLOOD))
			choices += H

	if(!choices.len)
		balloon_alert(src, "нет подходящего донора!")
		return FALSE

	var/mob/living/carbon/human/M = tgui_input_list(src, "У кого вы хотите взять образец крови?", , choices)

	if(!M || !src || !(Adjacent(M)) || stat != CONSCIOUS) //input can take a while, so re-validate
		return FALSE

	if(HAS_TRAIT(M, TRAIT_NO_BLOOD))
		balloon_alert(src, "нет крови!")
		return FALSE

	if(donors.Find(M.real_name))
		balloon_alert(src, "повторный образец!")
		return FALSE

	visible_message(span_danger("[src] выпускает щупальце и забирает образец крови [M]."),span_danger("Вы выпускаете щупальце и забираете образец крови [M]."))
	donors += M.real_name
	for(var/datum/language/L in M.languages)
		if(!(L.flags & HIVEMIND))
			languages |= L

	spawn(25)
		update_progression()

/mob/living/simple_animal/diona/proc/update_progression()
	if(stat != CONSCIOUS || !donors.len)
		return FALSE

	if(donors.len == evolve_donors)
		to_chat(src, span_noticealien("Вы готовы к следующей стадии роста."))
	else if(donors.len == awareness_donors)
		universal_understand = 1
		to_chat(src, span_noticealien("Ваше сознание расширяется - теперь вы понимаете окружающих."))
	else
		to_chat(src, span_noticealien("Кровь проникает в вас, принося воспоминания и черты личности."))


/mob/living/simple_animal/diona/put_in_hands(obj/item/I, force = FALSE, qdel_on_fail = FALSE, merge_stacks = TRUE, ignore_anim = TRUE, silent = FALSE)
	var/atom/drop_loc = drop_location()
	I.forceMove(drop_loc)
	I.pixel_x = I.base_pixel_x
	I.pixel_y = I.base_pixel_y
	I.layer = initial(I.layer)
	SET_PLANE_EXPLICIT(I, initial(I.plane), drop_loc)
	I.dropped(src, NONE, silent)


/mob/living/simple_animal/diona/put_in_active_hand(obj/item/I, force = FALSE, ignore_anim = TRUE)
	balloon_alert(src, "нет рук!")
	return

