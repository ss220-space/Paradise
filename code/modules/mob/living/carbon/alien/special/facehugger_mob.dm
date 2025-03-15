#define IMPREGNATED_DAMAGE_AMOUNT 5
/mob/living/simple_animal/hostile/facehugger
	name = "facehugger"
	desc = "На конце хвоста у него есть что-то вроде трубки."
	ru_names = list(
		NOMINATIVE = "лицехват",
		GENITIVE = "лицехвата",
		DATIVE = "лицехвату",
		ACCUSATIVE = "лицехвата",
		INSTRUMENTAL = "лицехватом",
		PREPOSITIONAL = "лицехвате"
	)
	unique_name = TRUE
	icon = 'icons/mob/facehugger.dmi'
	icon_state = "facehugger"
	icon_living = "facehugger"
	icon_dead = "facehugger_dead"
	icon_resting = "facehugger_rest"
	icon_gib = "facehugger_gib"
	base_pixel_x = -8
	base_pixel_y = -8
	pixel_x = -8
	pixel_y = -8
	health = 30
	maxHealth = 30
	throwforce = 0
	melee_damage_lower = 0
	melee_damage_upper = 1
	obj_damage = FALSE
	ranged = 1
	ranged_message = "прыгает"
	ranged_cooldown_time = 3 SECONDS
	can_hide = TRUE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	AI_delay_max = 0.5 SECONDS
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB | PASSFENCE | PASSVEHICLE
	pass_flags_self =  PASSMOB
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	pull_force = MOVE_FORCE_EXTREMELY_WEAK
	environment_smash = ENVIRONMENT_SMASH_NONE
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	a_intent = INTENT_HARM
	intent = INTENT_HARM
	blood_volume = 20
	blood_color = "#05EE05"
	attacktext = "прыгает на лицо"
	attack_sound = 'sound/creatures/facehugger_attack.ogg'
	attacked_sound = 'sound/creatures/facehugger_attacked.ogg'
	talk_sound = 'sound/creatures/facehugger_talk.ogg'
	damaged_sound = 'sound/creatures/facehugger_damaged.ogg'
	death_sound = 'sound/creatures/facehugger_dies.ogg'
	speak_emote = list("hisses")
	stat_attack = UNCONSCIOUS // Necessary for them to attack (zombify) dead humans
	speed = -0.5
	holder_type = /obj/item/clothing/mask/facehugger
	blood_color = COLOR_LIGHT_GREEN
	gold_core_spawnable = FALSE
	faction = list("alien")
	use_pathfinding = TRUE
	can_strip = FALSE
	butcher_results = list()
	hud_type = /datum/hud/simple_animal/facehugger
	var/jumpdistance = 7
	var/jumpspeed = 1.5
	var/host_species = ""
	var/impregnated = FALSE
	var/impregnated_death = FALSE
	var/obj/item/clothing/mask/facehugger/hugger_holder

/mob/living/simple_animal/hostile/facehugger/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
		maxbodytemp = 330, \
	)

/mob/living/simple_animal/hostile/facehugger/Initialize(mapload)
	. = ..()
	add_language(LANGUAGE_HIVE_XENOS)
	add_language(LANGUAGE_XENOS)
	ranged_distance = jumpdistance - 1
	default_language = GLOB.all_languages[LANGUAGE_HIVE_XENOS]
	GLOB.aliens_list |= src

/mob/living/simple_animal/hostile/facehugger/Destroy()
	hugger_holder = null
	GLOB.aliens_list -= src
	. = ..()

/mob/living/simple_animal/hostile/facehugger/Life(seconds, times_fired)
	. = ..()
	if(impregnated)
		if((IMPREGNATED_DAMAGE_AMOUNT + bruteloss) >= maxHealth)
			impregnated_death = TRUE
		adjustBruteLoss(IMPREGNATED_DAMAGE_AMOUNT, TRUE)
		return .
	var/base_regen = -0.5
	if(locate(/obj/structure/alien/weeds) in loc)
		base_regen *= 2
	if(resting || body_position == LYING_DOWN)
		base_regen *= 2
	adjustBruteLoss(base_regen)

/mob/living/simple_animal/hostile/facehugger/pull_constraint(atom/movable/pulled_atom, state, supress_message = FALSE) //Prevents spore from pulling things
	if(!supress_message)
		to_chat(src, span_warning("Вы не можете ничего таскать."))
	return FALSE

/mob/living/simple_animal/hostile/facehugger/update_icons()
	. = ..()
	if(stat == CONSCIOUS && !(resting || body_position == LYING_DOWN) && IsStunned())
		icon_state = "[initial(icon_state)]_knock"

/mob/living/simple_animal/hostile/facehugger/set_resting(new_resting, silent, instant)
	if(hugger_holder)
		return
	. = ..()


/mob/living/simple_animal/hostile/facehugger/OpenFire(atom/A)
	if(impregnated)
		return

	if(IsStunned())
		return

	if(body_position == LYING_DOWN)
		set_resting(FALSE, silent = TRUE, instant = TRUE)

	if(check_friendly_fire)
		for(var/turf/T as anything in get_line(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return
	visible_message(span_danger("<b>[capitalize(declent_ru(NOMINATIVE))]</b> [ranged_message] на [A]!"))
	throw_at(A, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE, dodgeable = FALSE)
	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)

/mob/living/simple_animal/hostile/facehugger/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	. = ..()
	pass_flags &= ~PASSMOB
	add_traits(list(TRAIT_IMMOBILIZED, TRAIT_INCAPACITATED), THROWED_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(remove_throw_traits)), 3 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/mob/living/simple_animal/hostile/facehugger/proc/remove_throw_traits()
	if(!throwing)
		remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_INCAPACITATED), THROWED_TRAIT)
		pass_flags |= PASSMOB
		update_icons()

/mob/living/simple_animal/hostile/facehugger/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_INCAPACITATED), THROWED_TRAIT)
	pass_flags |= PASSMOB
	. = ..()
	COOLDOWN_START(src, ranged_cooldown, ranged_cooldown_time)
	if(iscarbon(hit_atom))
		try_hug(hit_atom)
		return .
	if(isturf(hit_atom))
		for(var/mob/living/carbon/target in hit_atom)
			if(CanHug(target))
				try_hug(target)
				return .
	try_hug(hit_atom)

/mob/living/simple_animal/hostile/facehugger/death(gibbed)
	. = ..()
	hugger_holder?.Die()
	if(impregnated_death)
		var/obj/item/clothing/mask/facehugger/hugger = !QDELETED(hugger_holder)? hugger_holder : new holder_type(loc)
		hugger.stat = DEAD
		hugger.icon_state = "[initial(hugger.icon_state)]_impregnated"
		hugger.layer = layer
		qdel(src)

/mob/living/simple_animal/hostile/facehugger/getTrail()
	if(getBruteLoss() < maxHealth / 2)
		return pick("xltrails_1", "xltrails_2")
	else
		return pick("xttrails_1", "xttrails_2")

/mob/living/simple_animal/hostile/facehugger/attack_hand(mob/living/carbon/human/M)
	var/turf/current_loc = loc
	if(impregnated || stat == DEAD)
		return ..()
	var/obj/item/clothing/mask/facehugger/hugger = get_scooped(M)
	var/result = hugger.attack_hand(M)
	if(!result)
		forceMove(current_loc)
		hugger.holdered_mob = null
		QDEL_NULL(hugger_holder)
		return (M.a_intent == INTENT_GRAB)? FALSE : ..()
	return result


/mob/living/simple_animal/hostile/facehugger/attack_proc()
	if(impregnated)
		return FALSE
	if(isstructure(target) && target.attack_animal(src))
		return TRUE
	return try_hug(target)

/mob/living/simple_animal/hostile/facehugger/proc/try_hug(atom/hit_atom)
	var/turf/current_loc = loc
	var/obj/item/clothing/mask/facehugger/hugger = get_scooped(hit_atom)
	if(!hugger)
		Stun(2 SECONDS, ignore_canstun = TRUE)
		update_icons()
		return FALSE
	if(hugger && !hugger.Attach(hit_atom))
		forceMove(current_loc)
		hugger.holdered_mob = null
		if(hugger.stat == DEAD)
			death()
		else
			Stun(2 SECONDS, ignore_canstun = TRUE)
			update_icons()
		QDEL_NULL(hugger_holder)
		if(CanHug(target))
			LoseTarget()
		return TRUE

/mob/living/simple_animal/hostile/facehugger/Stun(amount, ignore_canstun)
	var/stuncheck = isnull(IsStunned())
	. = ..()
	if(stuncheck && .)
		RegisterSignal(src, COMSIG_MOB_STATUS_EFFECT_ENDED, PROC_REF(on_status_effect_ended))

/mob/living/simple_animal/hostile/facehugger/proc/on_status_effect_ended(effect_type)
	SIGNAL_HANDLER
	update_icons()
	UnregisterSignal(src, COMSIG_MOB_STATUS_EFFECT_ENDED)

/mob/living/simple_animal/hostile/facehugger/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	var/atom/movable/overlay/animation = null
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	var/old_icon = icon
	icon = null
	invisibility = INVISIBILITY_ABSTRACT

	animation = new(loc)
	animation.pixel_x = pixel_x
	animation.pixel_x = pixel_y
	animation.icon_state = "blank"
	animation.icon = old_icon
	animation.master = src

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)

	flick(icon_gib, animation)
	remove_from_dead_mob_list()

	QDEL_IN(animation, 15)
	QDEL_IN(src, 15)
	return TRUE

/mob/living/simple_animal/hostile/facehugger/proc/on_impregnated()
	impregnated = TRUE
	hidden = TRUE
	update_layer()
	LoseTarget()
	var/target
	var/max_dist = 0

	for(var/obj/object in view(7, get_turf(src)))

		if(!isflower(object) && !istable(object))
			continue
		var/list/path = get_path_to(src, object)
		if(!path.len)
			continue
		var/dist = get_dist(object, src)
		if(dist > max_dist)
			max_dist = dist
			target = object

	if(target && !client)
		Goto(target, move_to_delay, 0)
		toggle_ai(AI_OFF)
	else
		retreat_distance = 10
		minimum_distance = 10

/mob/living/simple_animal/hostile/facehugger/get_blood_data(blood_id)
	var/blood_data = list()
	blood_data["blood_color"] = blood_color
	return blood_data

/mob/living/simple_animal/hostile/facehugger/get_blood_dna_list()
	return list("UNKNOWN DNA" = "X*")

/mob/living/simple_animal/hostile/facehugger/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages[LANGUAGE_HIVE_XENOS]

/mob/living/simple_animal/hostile/facehugger/attack_alien(mob/living/carbon/alien/humanoid/M)
	. = ..()
	var/obj/item/clothing/mask/facehugger/hugger = get_scooped(M)
	hugger.attack_alien(M)

/mob/living/simple_animal/hostile/facehugger/pick_up_mob(mob/living/carbon/human_to_ask)
	var/obj/item/hugger = get_scooped(human_to_ask)
	hugger.attack_hand(human_to_ask)


/mob/living/simple_animal/hostile/facehugger/get_scooped(mob/living/carbon/grabber)
	if(!holder_type)
		return

	if(!istype(grabber))
		return

	if(!isnull(hugger_holder))
		QDEL_NULL(hugger_holder)

	hugger_holder = new holder_type(loc, src)
	if(stat == DEAD)
		hugger_holder.Die()
	return hugger_holder

/mob/living/simple_animal/hostile/facehugger/CanAttack(atom/the_target)
	if(!iscarbon(the_target) || isalien(the_target))
		return FALSE

	var/mob/living/carbon/attack_target = the_target

	if(isfacehugger_mask(attack_target.wear_mask))
		return FALSE

	if(attack_target.get_int_organ(/obj/item/organ/internal/xenos/hivenode) && !impregnated)
		return FALSE

	if(attack_target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo) && !impregnated)
		return FALSE

	if(ishuman(the_target))
		var/mob/living/carbon/human/H = the_target
		if(!H.check_has_mouth())
			return FALSE

	return ..()

#undef IMPREGNATED_DAMAGE_AMOUNT

/mob/living/simple_animal/hostile/facehugger/player_controlled/ComponentInitialize()
	. = ..()
	AddComponent(\
		/datum/component/ghost_direct_control,\
		ban_type = ROLE_ALIEN,\
		poll_candidates = FALSE,\
		after_assumed_control = CALLBACK(src, PROC_REF(add_datum_if_not_exist)),\
	)

/mob/living/simple_animal/hostile/facehugger/proc/add_datum_if_not_exist()
	if(mind)
		mind.add_antag_datum(/datum/antagonist/facehugger, /datum/team/xenomorph)

/mob/living/simple_animal/hostile/facehugger/lamarr
	name = "Lamarr"
	ru_names = list(
		NOMINATIVE = "ламарр",
		GENITIVE = "ламарр",
		DATIVE = "ламарр",
		ACCUSATIVE = "ламарр",
		INSTRUMENTAL = "ламарр",
		PREPOSITIONAL = "ламарр"
	)
	desc = "В худшем случае она попытается... спариться с вашей головой."
	gender = FEMALE
	holder_type = /obj/item/clothing/mask/facehugger/lamarr
