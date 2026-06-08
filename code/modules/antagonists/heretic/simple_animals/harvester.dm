/mob/living/simple_animal/hostile/construct/harvester/heretic
	name = "Ржавый Жнец"
	desc = "Длинный, тонкий, ветхий конструкт, изначально созданный, чтобы возвестить о возвышении Нар'Си, \
			но затем оскверненный и заржавевший под натиском сил Мансуса."
	construct_spells = list(
		/obj/effect/proc_holder/spell/aoe/rust_conversion,
		/obj/effect/proc_holder/spell/pointed/rust_construction,
	)
	can_repair = FALSE
	faction = list(FACTION_HERETIC)
	melee_damage_lower = 20
	melee_damage_upper = 25
	sight = SEE_MOBS
	response_harm = "кромсает"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	playstyle_string = span_bold("Вы — Ржавый Жнец, созданный для служения Нар'Си, извращенный для исполнения воли Мансуса. \
								Вы хрупки и слабы, но вы разрываете культистов (только) на части при каждой атаке. \
								Следуйте приказам своего Хозяина!")


/mob/living/simple_animal/hostile/construct/harvester/heretic/get_ru_names()
	return list(
		NOMINATIVE = "Ржавый Жнец",
		GENITIVE = "Ржавого Жнеца",
		DATIVE = "Ржавому Жнецу",
		ACCUSATIVE = "Ржавого Жнеца",
		INSTRUMENTAL = "Ржавым Жнецом",
		PREPOSITIONAL = "Ржавом Жнеце"
	)


/mob/living/simple_animal/hostile/construct/harvester/heretic/Initialize(mapload)
	. = ..()
	grant_abilities()
	ADD_TRAIT(src, TRAIT_MANSUS_TOUCHED, UID())
	add_filter("rusted_harvester", 3, list("type" = "outline", "color" = COLOR_GREEN, "size" = 2, "alpha" = 40))
	RegisterSignal(src, COMSIG_MOB_ENSLAVED_TO, PROC_REF(link_master))


/mob/living/simple_animal/hostile/construct/harvester/heretic/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	to_chat(src, span_bold(playstyle_string))


/mob/living/simple_animal/hostile/construct/harvester/heretic/AttackingTarget()
	. = ..()
	if(!.)
		return

	do_attack_animation(target, ATTACK_EFFECT_SLASH)


/// If the attack is a limbless carbon, abort the attack, paralyze them, and get a special message from Nar'Sie.
/mob/living/simple_animal/hostile/construct/harvester/heretic/OnUnarmedAttack(atom/attack_target, proximity_flag)
	if(!iscarbon(attack_target))
		return ..()

	var/mob/living/carbon/human/human_target = attack_target

	for(var/obj/item/organ/external/limb as anything in human_target.bodyparts)
		if(limb.limb_zone == BODY_ZONE_HEAD || limb.limb_zone == BODY_ZONE_CHEST)
			continue

		return ..() //if any arms or legs exist, attack

	human_target.Paralyse(6 SECONDS)
	visible_message(span_danger("[declent_ru(NOMINATIVE)] сбивает [human_target.declent_ru(ACCUSATIVE)] с ног!"))


/obj/effect/proc_holder/spell/seek_master
	name = "Найти своего хозяина"
	desc = "Используйте прямую связь с Мансусом, чтобы чувствовать определить местонахождение вашего хозяина."
	//buttontooltipstyle = "cult"
	action_icon_state = "cult_mark"
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_background_icon_state = "bg_heretic"
	//overlay_icon_state = "bg_heretic_border"
	var/tracking = TRUE
	var/mob/living/simple_animal/hostile/construct/the_construct


/obj/effect/proc_holder/spell/seek_master/New(Target)
	. = ..()
	the_construct = Target
	the_construct.seeking = TRUE


/obj/effect/proc_holder/spell/seek_master/on_spell_gain(mob/living/player)
	the_construct = player
	..()


/mob/living/simple_animal/hostile/construct/harvester/heretic/proc/link_master(mob/self, mob/master)
	SIGNAL_HANDLER
	construct_master = master
	RegisterSignal(construct_master, COMSIG_LIVING_DEATH, PROC_REF(on_master_death))


/mob/living/simple_animal/hostile/construct/harvester/heretic/proc/on_master_death(mob/self, mob/master)
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Ваша связь с Мансусом внезапно обрывается, когда ваш хозяин [construct_master.declent_ru(NOMINATIVE)] погибает! Без [genderize_ru(construct_master.gender, "его", "её", "его", "их")] поддержки ваше тело рассыпается..."))
	visible_message(span_alert("[declent_ru(NOMINATIVE)] внезапно рассыпается в пыль!"))
	death()


/mob/living/simple_animal/hostile/construct/harvester/heretic/attack_animal(mob/living/simple_animal/user, list/modifiers)
	// They're pretty fragile so this is probably necessary to prevent bullshit deaths.
	if(user == src)
		return

	return ..()


/mob/living/simple_animal/hostile/construct/harvester/heretic/proc/grant_abilities()
	AddElement(/datum/element/wall_walker, or_trait = TRAIT_RUSTY)
	AddElement(/datum/element/leeching_walk)
	AddComponent(\
		/datum/component/amputating_limbs,\
		surgery_time = 1.5 SECONDS,\
		surgery_verb = "slicing",\
		minimum_stat = CONSCIOUS,\
		pre_hit_callback = CALLBACK(src, PROC_REF(is_cultist_handler)),\
	)
	AddComponent(/datum/component/damage_aura,\
		range = 3,\
		brute_damage = 0.5,\
		burn_damage = 0.5,\
		toxin_damage = 0.5,\
		stamina_damage = 4,\
		simple_damage = 1.5,\
		immune_factions = list(FACTION_HERETIC),\
		damage_message = span_boldwarning("Ваше тело увядает из-за разъедающей ауры [declent_ru(GENITIVE)]."),\
		message_probability = 7,\
		current_owner = src,\
	)
	var/obj/effect/proc_holder/spell/seek_master/seek = new(src)
	mind.AddSpell(seek)


// These aren't friends they're assholes
// Don't let them be near you!
/mob/living/simple_animal/hostile/construct/harvester/heretic/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!.) //dead or deleted
		return

	if(!SPT_PROB(7, seconds_per_tick))
		return

	var/turf/adjacent = get_step(src, pick(GLOB.alldirs))
	// 90% chance to be directional, otherwise what we're on top of
	var/turf/space/land = (is_space_or_openspace(adjacent) && prob(90)) ? adjacent : get_turf(src)
	do_rust_heretic_act(land)

	if(!prob(7))
		return

	to_chat(src, span_notice("Из вашего тела исходит потусторонняя энергия."))


/mob/living/simple_animal/hostile/construct/harvester/heretic/proc/is_cultist_handler(mob/victim)
	return iscultist(victim)
