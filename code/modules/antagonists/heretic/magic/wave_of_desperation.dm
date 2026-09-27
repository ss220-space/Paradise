/datum/action/cooldown/spell/aoe/wave_of_desperation
	name = "Волна Отчаяния"
	desc = "Развязывает вас, отталкивает и сбивает с ног находящихся рядом гуманоидов, а также накладывает определённые эффекты Хватки Обители на всё вокруг. \
			Можно применить только если вы скованны. Можно применять без фокуса."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "uncuff"
	sound = 'sound/magic/swap.ogg'

	cooldown_time = 5 MINUTES

	invocation = "'ТЪ'Б'СЬ"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	aoe_radius = 3


/datum/action/cooldown/spell/aoe/wave_of_desperation/is_valid_target(mob/living/carbon/cast_on)
	return istype(cast_on) && (cast_on.handcuffed || cast_on.legcuffed)


/datum/action/cooldown/spell/aoe/wave_of_desperation/can_cast_spell(feedback = TRUE)
	var/mob/living/carbon/human/human = owner
	if(!istype(human) || !..())
		return FALSE

	if(!human.handcuffed && !human.legcuffed)
		if(feedback)
			to_chat(owner, span_warning("\"[name]\" можно применить, только будучи скованным!"))
		return FALSE

	return TRUE


/datum/action/cooldown/spell/aoe/wave_of_desperation/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!iscarbon(owner))
		return SPELL_CANCEL_CAST

	var/mob/living/carbon/human/human = owner
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


/datum/action/cooldown/spell/aoe/wave_of_desperation/get_things_to_cast_on(atom/center, radius_override)
	. = list()
	for(var/atom/nearby in orange(center, radius_override ? radius_override : aoe_radius))
		if(nearby == owner || nearby == center || isarea(nearby))
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


/datum/action/cooldown/spell/aoe/wave_of_desperation/cast(atom/cast_on)
	. = ..()
	var/our_turf = get_turf(owner)
	for(var/atom/movable/mover in get_things_to_cast_on(owner, radius_override = aoe_radius))
		if(ismob(mover))
			SEND_SIGNAL(owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, mover)
		else
			SEND_SIGNAL(owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, mover)

		if(mover.anchored)
			continue

		var/throwtarget = get_edge_target_turf(our_turf, get_dir(our_turf, get_step_away(mover, our_turf)))
		mover.throw_at(throwtarget, 3, 1, force = MOVE_FORCE_STRONG)


/obj/effect/temp_visual/knockblast
	icon_state = "shield-flash"
	alpha = 180
