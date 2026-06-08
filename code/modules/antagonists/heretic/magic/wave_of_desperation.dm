/obj/effect/proc_holder/spell/aoe/wave_of_desperation
	name = "Волна отчаяния"
	desc = "Развязывает вас, отталкивает и сбивает с ног находящихся рядом людей, а также накладывает определённые эффекты Прикосновения Мансуса на всё вокруг. \
			Нельзя применить, если вы не ограничены, а стресс лишает вас сознания через 12 секунд!"
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "uncuff"
	sound = 'sound/magic/swap.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 5 MINUTES

	invocation = "'ТЪ'Б'СЬ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_range = 3


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/valid_target(mob/living/carbon/cast_on)
	return istype(cast_on) && (cast_on.handcuffed || cast_on.legcuffed)


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/can_cast(mob/user, charge_check, feedback)
	var/mob/living/carbon/human/human = action.owner
	return istype(human) && ..() && (human.handcuffed || human.legcuffed)


// Before the cast, we do some small AOE damage around the caster
/obj/effect/proc_holder/spell/aoe/wave_of_desperation/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!iscarbon(action.owner))
		return SPELL_CANCEL_CAST

	var/mob/living/carbon/human/human = action.owner
	if(human.handcuffed)
		human.visible_message(span_danger("[human.handcuffed.declent_ru(NOMINATIVE)] котор[genderize_ru(human.handcuffed.gender, "ый", "ое", "ую", "ые")] нос[pluralize_ru(human.gender, "ит", "ят")] [human.declent_ru(NOMINATIVE)] рассыпа[pluralize_ru(human.handcuffed.gender, "ет", "ют")]ся на множество осколков!"))
		QDEL_NULL(human.handcuffed)

	if(human.legcuffed)
		human.visible_message(span_danger("[human.legcuffed.declent_ru(NOMINATIVE)] котор[genderize_ru(human.legcuffed.gender, "ый", "ое", "ую", "ые")] нос[pluralize_ru(human.gender, "ит", "ят")] [human.declent_ru(NOMINATIVE)] рассыпа[pluralize_ru(human.handcuffed.gender, "ет", "ют")]ся на множество осколков!"))
		human.visible_message(span_danger("[human.legcuffed] on [human] shatters!"))
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


/obj/effect/proc_holder/spell/aoe/wave_of_desperation/cast(list/targets, mob/caster = usr)
	for(var/victim as anything in targets)
		if(!ismob(victim))
			SEND_SIGNAL(action.owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim)

		var/atom/movable/mover = victim
		if(!istype(mover))
			return

		if(mover.anchored)
			return

		var/our_turf = get_turf(caster)
		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(mover, our_turf)))
		mover.throw_at(throwtarget, 3, 1, force = MOVE_FORCE_STRONG)


/obj/effect/temp_visual/knockblast
	icon_state = "shield-flash"
	alpha = 180
