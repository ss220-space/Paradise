/obj/effect/proc_holder/spell/aoe/wave_of_desperation
	name = "Волна Отчаяния"
	desc = "Развязывает вас, отталкивает и сбивает с ног находящихся рядом гуманоидов, а также накладывает определённые эффекты Хватки Обители на всё вокруг. \
			Можно применить только если вы скованны. Можно применять без фокуса."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "uncuff"
	sound = 'sound/magic/swap.ogg'

	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 5 MINUTES

	invocation = "'ТЪ'Б'СЬ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 3


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/valid_target(mob/living/carbon/cast_on)
	return istype(cast_on) && (cast_on.handcuffed || cast_on.legcuffed)


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/can_cast(mob/user, charge_check, show_message)
	var/mob/living/carbon/human/human = action.owner
	if(!istype(human) || !..())
		return FALSE
	return TRUE


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr)
	var/mob/living/carbon/human/human = user
	if(!istype(human) || (!human.handcuffed && !human.legcuffed))
		to_chat(user, span_warning("\"[name]\" можно применить, только будучи скованным!"))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/before_cast(list/targets, mob/user = usr)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!iscarbon(action.owner))
		return SPELL_CANCEL_CAST

	var/mob/living/carbon/human/human = action.owner
	if(human.handcuffed)
		human.visible_message(span_danger("[DECLENT_RU_CAP(human.handcuffed, NOMINATIVE)] котор[GEND_YI_AYA_OE_YE(human.handcuffed)] нос[PLUR_IT_YAT(human)] [human.declent_ru(NOMINATIVE)] рассыпа[PLUR_ET_YUT(human.handcuffed)]ся на множество осколков!"))
		QDEL_NULL(human.handcuffed)

	if(human.legcuffed)
		human.visible_message(span_danger("[DECLENT_RU_CAP(human.legcuffed, NOMINATIVE)] котор[GEND_YI_AYA_OE_YE(human.legcuffed)] нос[PLUR_IT_YAT(human)] [human.declent_ru(NOMINATIVE)] рассыпа[PLUR_ET_YUT(human.legcuffed)]ся на множество осколков!"))
		QDEL_NULL(human.legcuffed)

	human.apply_status_effect(/datum/status_effect/heretic_lastresort)
	new /obj/effect/temp_visual/knockblast(get_turf(human))

	for(var/mob/living/victim in get_things_to_cast_on(human, radius_override = 1))
		victim.AdjustKnockdown(3 SECONDS)
		victim.AdjustParalysis(0.5 SECONDS)


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_range))
		if(nearby == action.owner || nearby == center || isarea(nearby))
			continue

		if(!ismob(nearby))
			. += nearby
			continue

		var/mob/living/nearby_mob = nearby
		if(!isturf(nearby_mob.loc))
			continue

		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue

		if(nearby_mob.can_block_magic(antimagic_flags))
			continue

		. += nearby_mob


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast(list/targets, mob/user = usr)
	var/our_turf = get_turf(user)
	for(var/atom/movable/mover in get_things_to_cast_on(user, radius_override = aoe_range))
		if(ismob(mover))
			SEND_SIGNAL(action.owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, mover)
		else
			SEND_SIGNAL(action.owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, mover)

		if(mover.anchored)
			continue

		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(mover, our_turf)))
		mover.throw_at(throwtarget, 3, 1, force = MOVE_FORCE_STRONG)


/obj/effect/temp_visual/knockblast
	icon_state = "shield-flash"
	alpha = 180
