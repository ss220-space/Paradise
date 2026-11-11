/datum/action/cooldown/spell/touch/corrosive_acid_spit
	name = "Едкая кислота"
	desc = "Подготовить кислоту для ближнего боя. Эта кислота разъедает почти всё и наносит тяжёлый урон всем, у кого нет надлежащей защиты."
	hand_path = /obj/item/melee/touch_attack/alien/corrosive_acid
	button_icon_state = "alien_acid"
	background_icon_state = "bg_alien"
	background_icon_state_active = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS
	invocation_type = INVOCATION_NONE
	invocation = ""
	spell_requirements = NONE
	draw_message = span_noticealien_alt("Вы срыгиваете кислоту в руку и готовитесь её использовать.")
	drop_message = span_noticealien_alt("Вы решаете пока не тратить кислоту...")
	cooldown_time = 1
	var/plasma_cost = 200
	var/acid_power = 400

/datum/action/cooldown/spell/touch/corrosive_acid_spit/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src)
	return handler

/datum/action/cooldown/spell/touch/corrosive_acid_spit/is_valid_target(atom/cast_on)
	if(isalien(cast_on))
		return FALSE
	return TRUE

/// Remove second can_cast_spell so we wont check plasma cost again
/datum/action/cooldown/spell/touch/corrosive_acid_spit/can_hit_with_hand(atom/victim, mob/living/caster)
	if(!can_cast_on_self && victim == caster)
		return FALSE
	if(!is_valid_target(victim))
		return FALSE
	var/obj/item/organ/internal/xenos/plasmavessel/vessel = caster.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
	if(!vessel)
		return FALSE

	if(vessel.stored_plasma < plasma_cost)
		to_chat(caster, span_warning("Для использования этой способности нужно как минимум [plasma_cost] плазм[DECL_U_Y_Y(plasma_cost)]!"))
		return FALSE
	if(!(caster.mobility_flags & MOBILITY_USE))
		caster.balloon_alert(caster, "не достать!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/touch/corrosive_acid_spit/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/carbon/alien/alien_caster = caster

	if(!victim.acid_act(acid_power, 100))
		to_chat(alien_caster, span_noticealien("Вы не можете растворить этот объект."))
		return FALSE
	playsound(victim, 'sound/items/welder.ogg', 150, TRUE)
	caster.visible_message(span_alertalien("[alien_caster] изрыгает комки мерзкой субстанции на [victim.declent_ru(ACCUSATIVE)]. Она начинает шипеть и плавиться под пузырящейся массой кислоты!"))
	add_attack_logs(alien_caster, victim, "Applied corrosive acid") // Want this logged
	alien_caster.adjust_alien_plasma(-plasma_cost)
	return TRUE

/datum/action/cooldown/spell/touch/corrosive_acid_spit/sentinel
	plasma_cost = 150

/datum/action/cooldown/spell/touch/corrosive_acid_spit/praetorian
	plasma_cost = 100

/datum/action/cooldown/spell/touch/corrosive_acid_spit/queen
	plasma_cost = 50
	acid_power = 1000

/obj/item/melee/touch_attack/alien/corrosive_acid
	name = "Едкая кислота"
	desc = "Кулак смерти."
	icon_state = "alien_acid"
